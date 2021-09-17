#!/bin/bash
# Made by Jackson Casey || Wed Aug 25th, 2021
# All rights reserved.

helpText() { 
    echo -e "\x1b[1mLabToPdf by Jaxcksn Help\x1b[0m"
    echo -e "\nUsage: LabToPdf (-c) inputFile"
    echo -e "Optional Flags:"
    echo -e "\t-c\tDisables the addition of CSS wrapping fixes being added"
    echo -e "\t-h\tShows this help text."
    exit 0;
}

chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

ApplyFix=false
while getopts ch opt; do
    case $opt in 
        h) helpText; exit ;;
        c) ApplyFix=true ;;
        :) echo "Missing argument for option -$OPTARG"; exit 1;;
       \?) echo "Unknown option -$OPTARG"; exit 1;;
    esac
done

shift $((OPTIND-1))

JOURNALFILE=$1;
FILENAME="${JOURNALFILE##*/}" # Grabs the name of the file 
FILETYPE="${FILENAME##*.}" # Grabs the extension of the file


throwError() {
    local errorMSG="$1"
    echo -e "\x1b[1;91m✘ Error:\x1b[0m $errorMSG"
    exit 1
}

throwWarning() {
    local errorMSG="$1"
    echo -e "\x1b[1;93m⚠ Warning:\x1b[0m $errorMSG"
}



toHTML() {
    echo -e "\x1b[1;34m>\x1b[0m Converting ${FILENAME} to an HTML file..."
    jupyter nbconvert --to html "$JOURNALFILE" > /dev/null 2>&1 || throwError "Failed to convert notebook to HTML, make sure that nbconvert is installed & in your path." # Converts to an HTML file.
    if [ $ApplyFix = true ];
    then
        echo -e "\x1b[1;34m>\x1b[0m Adding CSS word wrap properties..."
        sed -i.bak 's/pre { line-height: 125%; }/& pre,code,kbd,samp {  white-space: pre-wrap;  word-wrap: normal; word-break: normal !important;}/' "$DIR/$OUTPUTNAME.html" > /dev/null 2>&1 || throwWarning "SED failed to edit HTML file, CSS  properties will not appear in final PDF." && rm -- "$DIR/$OUTPUTNAME.html.bak" > /dev/null 2>&1  # Using SED to add the CSS wrap properties 
    fi;
    echo -e "\x1b[1;32m✔\x1b[0m Sucessfully converted notebook to HTML file!"
    echo -e "\x1b[1;34m>\x1b[0m Attempting conversion from HTML to PDF File..."
    local htmlfile="$DIR/$OUTPUTNAME.html" # The location of the HTML file
    local fulldir="$(realpath $htmlfile)" # The full system path of the HTML file
    "$chrome" --headless --run-all-compositor-stages-before-draw  --virtual-time-budget=20000 --print-to-pdf-no-header --print-to-pdf="$DIR/$OUTPUTNAME.pdf" "file:///$fulldir" > /dev/null 2>&1 && rm "$DIR/$OUTPUTNAME.html"
    echo -e "\x1b[1;32m✔\x1b[0m Successfully converted notebook to PDF file to $DIR/$OUTPUTNAME.pdf"
}

main() {
printf "\n\x1b[1;34m==========  %s  ==========\x1b[0m\n" "LabToPDF v1.0"
#echo -e "\x1b[1m Starting conversion from Jupyter Notebook to PDF File"
echo -e "\x1b[1;34m>\x1b[0m Checking supplied file..."
if [ -r $JOURNALFILE ] && [ -s $JOURNALFILE ] && [ "$FILETYPE" == "ipynb" ];
then
    echo -e "\x1b[1;32m✔\x1b[0m Check complete. File is a valid Juypter Notebook."
    NAME="$(basename -a $JOURNALFILE)" # The basename of the file.
    DIR="$(dirname $JOURNALFILE)" # The directory of the file
    OUTPUTNAME="${NAME%%.*}" # The name of the file itself, no extension or path.
    toHTML
else 
    echo 'Check failed. Invalid/Inreadable Journal File Supplied'
    exit 1
fi
}



main


