<?php

declare(strict_types=1);

require 'support_files/functions/prepare_xml.php';
require 'support_files/functions/create_epub.php';
require 'support_files/functions/tools.php';

$input_file = $argv[1];
$output_file = $argv[2];

try {

    $tmp_dir = unzip($input_file);

    createEpubDirectories($tmp_dir);
    copyStaticFiles($tmp_dir);

    $xml = prepareXml($tmp_dir);

    createEpubNavXhtml($tmp_dir, $xml);
    createEpubNavNcx($tmp_dir, $xml);

    transformXmlToXhtml($tmp_dir, $xml);

    createEpubPackageOpf($tmp_dir, $xml);

    zipAsEpub($tmp_dir, $output_file);

    if (getenv('DEV')) {
        savePreparedXml($tmp_dir, $xml);
        removeIdRegex($tmp_dir);
        removeWhitespaceRegex($tmp_dir);
    } else {
        deleteTmpFilesAndFolders($tmp_dir);
    }

    echo 'The file "' . $output_file . '" was created and saved.';

} catch (RuntimeException $e) {
    throw $e;
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
