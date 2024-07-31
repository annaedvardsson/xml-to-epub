<?php

declare(strict_types=1);

function prepareXml(string $tmp_dir): DOMDocument
{
    $xml_file = getXmlFile($tmp_dir);
    $xml = loadXmlDocument($xml_file);

    $counter = 1;
    addCoverId($xml->documentElement, $counter);

    $counter = 1;
    addEpubId($xml->documentElement, $counter);

    $counter = 1;
    addNoteId($xml, $counter);

    $counter = 1;
    $folder = basename($xml_file, '.xml');
    processImages($xml, $tmp_dir, $counter, $folder);

    $counter = 1;
    $counter = addNcxId($xml->documentElement, $counter);
    addNcxIdToPagenum($xml->documentElement, $counter);
    trimTagContent($xml, 'pagenum');

    renameXmlElements($xml);

    return $xml;
}

function getXmlFile(string $tmp_dir): string
{
    $xml_files = glob($tmp_dir . '/**/*.xml');
    if (count($xml_files) !== 1) {
        throw new Exception("Error: Expected one, and only one, XML file inside the zip.");
    }
    return $xml_files[0];
}

function loadXmlDocument(string $xml_file): DOMDocument
{
    $xml = new DOMDocument();
    if (!$xml->load($xml_file)) {
        throw new Exception("Failed to load XML file.");
    }
    return $xml;
}

function addCoverId(DOMElement $element, int &$counter): void
{
    foreach ($element->childNodes as $child) {
        if ($child->nodeType === XML_ELEMENT_NODE) {
            if ($child->nodeName === 'level1' && $child->getAttribute('id') === 'level1_1') {
                $cover_id = 'c' . $counter;
                $child->setAttribute('cover_id', $cover_id);
                $counter++;

                foreach ($child->childNodes as $subchild) {
                    if ($subchild->nodeType === XML_ELEMENT_NODE && $subchild->nodeName === 'prodnote') {
                        $sub_cover_id = 'c' . $counter;
                        $subchild->setAttribute('cover_id', $sub_cover_id);
                        $counter++;
                    }
                }
            }

            addCoverId($child, $counter);
        }
    }
}

function addEpubId(DOMNode $node, int &$counter): void
{
    $tags = [
        'level1' => true, 'level2' => true, 'level3' => true, 'level4' => true,
        'h1' => true, 'h2' => true, 'h3' => true, 'h4' => true, 'p' => true, 'prodnote' => true,
        'note' => true, 'noteref' => true, 'pagenum' => true, 'img' => true,
        'aside' => true, 'sidebar' => true, 'li' => true, 'lic' => true, 'dl' => true, 'dt' => true, 'dd' => true,
        'table' => true, 'tbody' => true, 'caption' => true, 'th' => true, 'tr' => true, 'td' => true
    ];
    $id_prefix = 'epub_id';

    foreach ($node->childNodes as $child) {
        if ($child->nodeType === XML_ELEMENT_NODE && isset($tags[$child->nodeName])) {
            setElementId($child, $counter, $id_prefix);
        }
        addEpubId($child, $counter);
    }
}

function setElementId(DOMElement $element, int &$counter, string $id_prefix): void
{
    if ($element->nodeName === 'level1') {
        $counter_as_string = (string) $counter;
        $body_id = 'ei_' . str_pad($counter_as_string, 4, '0', STR_PAD_LEFT);
        $element->setAttribute('body_id', $body_id);
        $counter++;
    }


    $counter_as_string = (string) $counter;
    $id = 'ei_' . str_pad($counter_as_string, 4, '0', STR_PAD_LEFT);
    $element->setAttribute($id_prefix, $id);
    $counter++;

    if ($element->nodeName === 'level1' && $element->getAttribute('class') === 'footnotes') {
        $counter_as_string = (string) $counter;
        $footnote_id = 'ei_' . str_pad($counter_as_string, 4, '0', STR_PAD_LEFT);
        $element->setAttribute('footnote_id', $footnote_id);
        $counter++;
    }
}

function addNoteId(DOMDocument $xml, int &$counter): void
{
    $noterefs = $xml->getElementsByTagName('noteref');
    $notes = $xml->getElementsByTagName('note');

    foreach ($noterefs as $noteref) {
        $idref = $noteref->getAttribute('idref');
        foreach ($notes as $note) {
            $note_id = '#' . $note->getAttribute('id');
            if ($idref === $note_id) {
                $note_id = sprintf('fn-%014d', $counter);
                $noteref->setAttribute('note_id', $note_id);
                $note->setAttribute('note_id', $note_id);
                $counter++;
                break;
            }
        }
    }
}

function processImages(DOMDocument $xml, string $tmp_dir, int &$counter, string $folder): void
{
    $date = date('ymd');
    $images = $xml->getElementsByTagName('img');
    foreach ($images as $img) {
        $img_id = sprintf('img-%s-%012d-normal', $date, $counter);
        $new_img_name = $img_id . '.jpg';
        $img->setAttribute('img_id', $new_img_name);

        copyImage($img->getAttribute('src'), $tmp_dir, $new_img_name, $folder);

        if ($img->getAttribute('src') === 'cover.jpg') {
            copyImage('cover.jpg', $tmp_dir, 'cover.jpg', $folder);
        }

        $counter++;
    }
}

function copyImage($src, string $tmp_dir, $new_name, $folder): void
{
    $source_path = $tmp_dir . '/' . $folder . '/' . $src;
    $target_path = $tmp_dir . '/epub/EPUB/images/' . $new_name;
    if (!copy($source_path, $target_path)) {
        echo "Failed to copy $source_path to $target_path\n";
    }
}

function addNcxId(DOMNode $node, int &$counter): int
{
    $tags = ['level1', 'level2', 'level3', 'level4', 'prodnote', 'note'];
    foreach ($node->childNodes as $child) {
        if ($child->nodeType === XML_ELEMENT_NODE && in_array($child->nodeName, $tags)) {
            $id = $child->getAttribute('id');
            if ($child->nodeName === 'prodnote' && empty($id)) {
                continue;
            } elseif ($child->nodeName === 'note') {
                if (str_ends_with($id, '1')) {
                    $number = (string) $counter;
                    $child->setAttribute('ncx_id', $number);
                    $counter++;
                }
            } else {
                $number = (string) $counter;
                $child->setAttribute('ncx_id', $number);
                $counter++;
            }
        }
        addNcxId($child, $counter);
    }
    return $counter;
}

function addNcxIdToPagenum(DOMNode $node, int &$counter): void
{
    foreach ($node->childNodes as $child) {
        if ($child->nodeType === XML_ELEMENT_NODE && $child->nodeName === 'pagenum' && $child->nodeName !== 'prodnote') {
            $number = (string) $counter;
            $child->setAttribute('ncx_id', $number);
            $counter++;
        }
        addNcxIdToPagenum($child, $counter);
    }
}

function trimTagContent(DOMDocument $xml, string $tag_name): void
{
    foreach ($xml->getElementsByTagName($tag_name) as $element) {
        $element->nodeValue = trim($element->nodeValue);
    }
}

function renameXmlElements(DOMDocument $xml): DOMDocument
{
    renameXmlTags($xml, 'rearmatter', 'backmatter');
    renameXmlClassAttribute($xml, 'jacketcopy', 'cover');
    renameXmlClassAttribute($xml, 'footnotes', 'chapter', 'footnotes');

    return $xml;
}

function renameXmlTags(DOMDocument $xml, string $old_name, string $new_name): void
{
    $elements = $xml->getElementsByTagName($old_name);
    for ($i = $elements->length - 1; $i >= 0; $i--) {
        $element = $elements->item($i);
        $new_element = $xml->createElement($new_name);

        foreach ($element->childNodes as $child) {
            $new_element->appendChild($child->cloneNode(true));
        }

        foreach ($element->attributes as $attr) {
            $new_element->setAttribute($attr->nodeName, $attr->nodeValue);
        }

        $element->parentNode->replaceChild($new_element, $element);
    }
}

function renameXmlClassAttribute(DOMDocument $xml, string $old_class, string $new_class, ?string $original_class = null): void
{
    $xpath = new DOMXPath($xml);
    $elements = $xpath->query("//*[@class='$old_class']");

    foreach ($elements as $element) {
        $element->setAttribute('class', $new_class);
        if ($original_class !== null) {
            $element->setAttribute('original_class', $original_class);
        }
    }
}
