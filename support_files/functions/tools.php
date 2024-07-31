<?php

declare(strict_types=1);

function savePreparedXml(string $tmp_dir, DOMDocument $xml): void
{
        $xml_prepared = $tmp_dir . '/Prepared.xml';
        $xml->save($xml_prepared);
}

function removeIdRegex(string $tmp_dir): void
{
    $directory = $tmp_dir . '/epub/EPUB';

    foreach (new DirectoryIterator($directory) as $file_info) {
        if ($file_info->isDot() || !$file_info->isFile()) {
            continue;
        }

        $file_path = $file_info->getPathname();
        $content = file_get_contents($file_path);

        $content = preg_replace('/id="ei_\d{4}/', 'id="', $content);

        file_put_contents($file_path, $content);
    }
}

function removeWhitespaceRegex(string $tmp_dir): void
{
    $directory = $tmp_dir . '/epub/EPUB';

    foreach (new DirectoryIterator($directory) as $file_info) {
        if ($file_info->isDot() || !$file_info->isFile()) {
            continue;
        }

        $file_path = $file_info->getPathname();
        $content = file_get_contents($file_path);

        $content = preg_replace('/\s+/', ' ', $content);

        file_put_contents($file_path, $content);
    }
}
