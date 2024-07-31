<?php

declare(strict_types=1);

function unzip(string $input_file): string
{
    $zip = new ZipArchive;
    try {
        if ($zip->open($input_file) === TRUE) {
            $tmp_dir = uniqid('temp_dir_');
            if (!mkdir($tmp_dir)) {
                throw new Exception("Failed to create temporary directory.");
            }
            $zip->extractTo($tmp_dir);
        } else {
            throw new Exception("Failed to open the zip file.");
        }
    } finally {
        if ($zip->status === ZipArchive::ER_OK) {
            $zip->close();
        }
    }

    return $tmp_dir;
}

function createEpubDirectories(string $tmp_dir): void
{
    $directories = [
        "$tmp_dir/epub",
        "$tmp_dir/epub/EPUB",
        "$tmp_dir/epub/EPUB/css",
        "$tmp_dir/epub/EPUB/images",
        "$tmp_dir/epub/META-INF"
    ];

    foreach ($directories as $directory) {
        mkdir($directory);
    }
}

function copyStaticFiles(string $tmp_dir): void
{
    $source_folder = 'support_files/static_files/';
    $target_folder = "$tmp_dir/epub/";
    $files = [
        'epub.css' => 'EPUB/css/',
        'container.xml' => 'META-INF/',
        'mimetype' => '',
    ];

    foreach ($files as $file => $target) {
        $source_path = $source_folder . $file;
        $target_path = $target_folder . $target . $file;

        if (!copy($source_path, $target_path)) {
            echo "Failed to copy $target_path...\n";
        }
    }
}

function createEpubNavXhtml(string $tmp_dir, DOMDocument $xml): void
{
    $xsl_file = "support_files/transforms/transform_xml_for_nav_xhtml.xsl";
    $xsl = new DOMDocument;
    $xsl->load($xsl_file);

    $proc = new XSLTProcessor;
    $proc->importStyleSheet($xsl);

    $result = $proc->transformToXML($xml);

    file_put_contents("$tmp_dir/epub/EPUB/nav.xhtml", $result);
}

function createEpubNavNcx(string $tmp_dir, DOMDocument $xml): void
{
    $xsl_file = "support_files/transforms/transform_xml_for_nav_ncx.xsl";
    $xsl = new DOMDocument;
    $xsl->load($xsl_file);

    $proc = new XSLTProcessor;
    $proc->importStyleSheet($xsl);

    $result = $proc->transformToXML($xml);

    file_put_contents("$tmp_dir/epub//EPUB/nav.ncx", $result);
}

function transformXmlToXhtml(string $tmp_dir, DOMDocument $xml): void
{
    $xsl_file = "support_files/transforms/transform_xml_for_each_level1.xsl";
    $xsl = new DOMDocument;
    $xsl->load($xsl_file);

    $proc = new XSLTProcessor;
    $proc->importStyleSheet($xsl);

    $xpath = new DOMXPath($xml);
    $xpath->registerNamespace('dt', 'http://www.daisy.org/z3986/2005/dtbook/');

    $level1_elements = $xpath->query("//dt:level1");
    $identifier = $xpath->evaluate("string(//dt:meta[@name='dc:Identifier']/@content)");

    foreach ($level1_elements as $index => $level1) {
        $id = $level1->getAttribute('id');
        $class = $level1->getAttribute('class') ?: $level1->parentNode->nodeName;

        $index_as_string = (string) ($index + 1);
        $file_index = str_pad($index_as_string, 3, '0', STR_PAD_LEFT);
        $filename = "$tmp_dir/epub/EPUB/{$identifier}-{$file_index}-{$class}.xhtml";

        $proc->setParameter('', 'level1_id', $id);
        $result = $proc->transformToXML($xml);

        file_put_contents($filename, $result);
    }
}

class OpfPackage
{
    public string $uid;
    public string $title;
    public string $creator;
    public string $date;
    public string $format;
    public string $language;
    public string $publisher;
    public string $source;
    public string $modified;
    public string $guidelines;
    public string $supplier;
    public array $items;
    public array $itemrefs;
}

class OpfItem
{
    public string $href;
    public string $id;
    public string $media_type;
    public ?string $properties;

    public function __construct(string $href, string $id, string $media_type, ?string $properties)
    {
        $this->href = $href;
        $this->id = $id;
        $this->media_type = $media_type;
        $this->properties = $properties;
    }
}

class OpfItemref
{
    public string $idref;
    public ?string $linear;

    public function __construct(string $idref, ?string $linear)
    {
        $this->idref = $idref;
        $this->linear = $linear;
    }
}

function createEpubPackageOpf(string $tmp_dir, DOMDocument $xml): void
{
    $opf_package = prepareEpubPackageOpf($tmp_dir, $xml);
    writeEpubPackageOpf($tmp_dir, $opf_package);
}

function prepareEpubPackageOpf(string $tmp_dir, DOMDocument $xml): OpfPackage
{
    $xpath = new DOMXPath($xml);
    $xpath->registerNamespace('dt', 'http://www.daisy.org/z3986/2005/dtbook/');

    $opf_package = new OpfPackage();

    // Add metadata info
    $opf_package->uid = $xpath->evaluate("string(//dt:meta[@name='dtb:uid']/@content)");
    $opf_package->title = $xpath->evaluate("string(//dt:meta[@name='dc:Title']/@content)");
    $opf_package->creator = $xpath->evaluate("string(//dt:meta[@name='dc:Creator'][1]/@content)");
    $opf_package->date = $xpath->evaluate("string(//dt:meta[@name='dc:Date']/@content)");
//    $opf_package->format = 'EPUB3';
    $opf_package->format = $xpath->evaluate("string(//dt:meta[@name='dc:Format']/@content)");
    $opf_package->language = $xpath->evaluate("string(//dt:meta[@name='dc:Language']/@content)");
    $opf_package->publisher = $xpath->evaluate("string(//dt:meta[@name='dc:Publisher']/@content)");
    $opf_package->source = $xpath->evaluate("string(//dt:meta[@name='dc:Source']/@content)");
    $opf_package->modified = date(DATE_ATOM);
    $opf_package->guidelines = $xpath->evaluate("string(//dt:meta[@name='track:Guidelines']/@content)");
    $opf_package->supplier = $xpath->evaluate("string(//dt:meta[@name='track:Supplier']/@content)");

    //Add manifest info
    $directory = "$tmp_dir/epub/EPUB";
    $fixed_items = [
        ["css/epub.css", 'css', 'text/css', null],
        ['nav.ncx', 'ncx', 'application/x-dtbncx+xml', null],
        ['nav.xhtml', 'nav', 'application/xhtml+xml', 'nav'],
        ["images/cover.jpg", 'coverimg', "image/jpeg", "cover-image"],
    ];

    foreach ($fixed_items as $item) {
        $full_path = $directory . "/" . $item[0];
        if (!file_exists($full_path)) {
            throw new RuntimeException($item[0] . ' not found in ' . $directory);
        }

        $opf_package->items[] = new OpfItem($item[0], $item[1], $item[2], $item[3]);
    }

    $iterator = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($directory));
    $image_array = [];
    $spine_array = [];

    foreach ($iterator as $file) {
        if ($file->isDir()) {
            continue;
        }

        $filepath = $file->getPathname();
        $file_name = $file->getFileName();
        $file_extension = pathinfo($file_name, PATHINFO_EXTENSION);
        $media_type = getMediaType($file_name);

        if ($file_extension == 'xhtml' && $file_name != 'nav.xhtml') {
            $content = file_get_contents($filepath);
            $body_id = extractBodyId($content);

            if (str_ends_with($file_name, 'cover.xhtml')) {
                $opf_package->items[] = new OpfItem("$file_name", 'cover', "$media_type", null);
            } else {
                $opf_package->items[] = new OpfItem("$file_name", "item-$body_id", "$media_type", null);
            }

            $image_ids = extractImageIds($content);
            foreach ($image_ids as $src => $image_id) {
                $image_array[$src] = $image_id;
            }

            $spine_array[] = $body_id;
        }
    }

    foreach ($image_array as $src => $image_id) {
        $media_type = getMediaType($src);
        $opf_package->items[] = new OpfItem("$src", "item-$image_id", "$media_type", null);
    }

    //Add spine info
    foreach ($spine_array as $id) {
        if ($id == 'c1') {
            $opf_package->itemrefs[] = new OpfItemref("cover", 'no');
        } else {
            $opf_package->itemrefs[] = new OpfItemref("item-$id", null);
        }
    }

    return $opf_package;
}

function writeEpubPackageOpf(string $tmp_dir, OpfPackage $opf_package): void
{
    $writer = new XMLWriter();
    $writer->openMemory();
    $writer->setIndent(true);
    $writer->startDocument('1.0', 'UTF-8');

    $writer->startElement('package');
    $writer->writeAttribute('xmlns', 'http://www.idpf.org/2007/opf');
    $writer->writeAttribute('xmlns:dc', 'http://purl.org/dc/elements/1.1/');
    $writer->writeAttribute('xmlns:epub', 'http://www.idpf.org/2007/ops');
    $writer->writeAttribute('version', '3.0');
    $writer->writeAttribute('unique-identifier', 'pub-identifier');
    $writer->writeAttribute('prefix', 'scandinavia: http://www.xyz.se/epub');

    {
        $writer->startElement('metadata');
        {
            $writer->startElement('dc:identifier');
            $writer->writeAttribute('id', 'pub-identifier');
            $writer->text($opf_package->uid);
            $writer->endElement();

            $writer->startElement('dc:title');
            $writer->text($opf_package->title);
            $writer->endElement();

            $writer->startElement('dc:creator');
            $writer->text($opf_package->creator);
            $writer->endElement();

            $writer->startElement('dc:date');
            $writer->text($opf_package->date);
            $writer->endElement();

            $writer->startElement('dc:format');
            $writer->text($opf_package->format);
            $writer->endElement();

            $writer->startElement('dc:language');
            $writer->text($opf_package->language);
            $writer->endElement();

            $writer->startElement('dc:publisher');
            $writer->text($opf_package->publisher);
            $writer->endElement();

            $writer->startElement('dc:source');
            $writer->text($opf_package->source);
            $writer->endElement();

            $writer->startElement('meta');
            $writer->writeAttribute('property', 'dcterms:modified');
            $writer->text($opf_package->modified);
            $writer->endElement();

            $writer->startElement('meta');
            $writer->writeAttribute('name', 'dcterms:modified');
            $writer->writeAttribute('content', $opf_package->modified);
            $writer->endElement();

            $writer->startElement('meta');
            $writer->writeAttribute('property', 'scandinavia:guidelines');
            $writer->text($opf_package->guidelines);
            $writer->endElement();

            $writer->startElement('meta');
            $writer->writeAttribute('name', 'scandinavia:guidelines');
            $writer->writeAttribute('content', $opf_package->guidelines);
            $writer->endElement();

            $writer->startElement('meta');
            $writer->writeAttribute('property', 'scandinavia:supplier');
            $writer->text($opf_package->supplier);
            $writer->endElement();

            $writer->startElement('meta');
            $writer->writeAttribute('name', 'scandinavia:supplier');
            $writer->writeAttribute('content', $opf_package->supplier);
            $writer->endElement();
        }
        $writer->endElement();

        $writer->startElement('manifest');
        foreach ($opf_package->items as $item) {
            $writer->startElement('item');
            $writer->writeAttribute('href', $item->href);
            $writer->writeAttribute('id', $item->id);
            $writer->writeAttribute('media-type', $item->media_type);
            if ($item->properties) {
                $writer->writeAttribute('properties', $item->properties);
            }
            $writer->endElement();
        }
        $writer->endElement();

        $writer->startElement('spine');
        $writer->writeAttribute('toc', 'ncx');
        $writer->writeAttribute('page-progression-direction', 'ltr');
        foreach ($opf_package->itemrefs as $itemref) {
            $writer->startElement('itemref');
            $writer->writeAttribute('idref', $itemref->idref);
            if ($itemref->linear) {
                $writer->writeAttribute('linear', $itemref->linear);
            }
            $writer->endElement();
        }
        $writer->endElement();
    }
    $writer->endElement();

    $result = $writer->outputMemory();
    file_put_contents("$tmp_dir/epub/EPUB/package.opf", $result);
}

function zipAsEpub(string $tmp_dir, string $output_file): void
{
    $zip = new ZipArchive;
    try {
        if ($zip->open($output_file, ZipArchive::CREATE) === TRUE) {
            addFilesToZip($zip, "$tmp_dir/epub", $tmp_dir);
        } else {
            throw new Exception('Failed to create ZIP archive');
        }
    } catch (Exception $e) {
        echo $e->getMessage() . "\n";
        exit(1);
    } finally {
        if ($zip->status === ZipArchive::ER_OK) {
            $zip->close();
        }
    }
}

function addFilesToZip(ZipArchive $zip, string $dir, string $tmp_dir): void
{
    // Add Separately since mimetype should be added first
    $zip->addFile("$tmp_dir/epub/mimetype", 'mimetype');
    $zip->addFile("$tmp_dir/epub/META-INF/container.xml", 'META-INF/container.xml');

    $files = scandir($dir);
    foreach ($files as $file) {
        if ($file != '.' && $file != '..') {
            $file_path = "$dir/$file";
            if (is_dir($file_path)) {
                addFilesToZip($zip, $file_path, $tmp_dir);
            } else {
                $zip->addFile($file_path, substr($file_path, strlen("$tmp_dir/epub") + 1));
            }
        }
    }
}

function getMediaType(string $filename): string
{
    $ext = pathinfo($filename, PATHINFO_EXTENSION);
    $media_types = [
        'css' => 'text/css',
        'jpg' => 'image/jpeg',
        'jpeg' => 'image/jpeg',
        'ncx' => 'application/x-dtbncx+xml',
        'xhtml' => 'application/xhtml+xml',
    ];
    return $media_types[$ext] ?? 'application/octet-stream';
}

function extractBodyId(string $content): ?string
{
    if (preg_match('/<body[^>]*id="([^"]*)"/', $content, $matches)) {
        return $matches[1];
    }
    return null;
}

function extractImageIds(string $content): array
{
    $image_ids = [];

    if (preg_match_all('/<img[^>]*src="([^"]*)"[^>]*id="([^"]*)"/', $content, $matches)) {
        foreach ($matches[1] as $index => $src) {
            $id = $matches[2][$index];
            $image_ids[$src] = $id;
        }
    }

    return $image_ids;
}

function deleteTmpFilesAndFolders(string $dir): void
{
    $files = glob("$dir/*");

    foreach ($files as $file) {
        if (is_file($file)) {
            unlink($file);
        } elseif (is_dir($file)) {
            deleteTmpFilesAndFolders("$file/");
        }
    }

    rmdir($dir);
}
