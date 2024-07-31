# Project Overview
This project is a PHP CLI tool to convert a ZIP file containing an XML and JPG files into a functional EPUB file.

## Execution Instructions
To execute the script, use the following command:  
`php index.php [source path] [target path]`
- [source path]: The absolute path to the source ZIP file containing the XML and JPG files.
- [target path]: The absolute path where the resulting EPUB file will be saved.

### Development Mode
For development purposes, you can set the environment variable DEV to "true" to disable the removal of temporary files and activate functions that facilitate easier comparison with target EPUB files:  
`$env:DEV = "true"; php index.php [source path] [target path]`

## Timeline
### Current
Approx. four weeks of total work
- Week 1: Research and study of basic XML, XHTML, EPUB and XSLT tutorials
- Week 2: Develop a basic program that produces a functional EPUB with most content relevant to the example source file
- Week 3: Cleanup, removal of redundant code, improved transforms and additional formatting
- Week 4: Refactoring, addition of rudimentary error handling and typing

### Future Work
- Improve transforms to better adhere to DTBook/DAISY XML guidelines
- Enhance error handling and validation
- Add automated tests
- ...
