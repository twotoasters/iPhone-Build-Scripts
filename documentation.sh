#!/bin/sh
#
# Build the doxygen documentation for the project and load the docset into Xcode 
#
# Created by Fred McCann on 03/16/2010.
# http://www.duckrowing.com
#
# Based on the build script provided by Apple:
# http://developer.apple.com/tools/creatingdocsetswithdoxygen.html
#
# Set the variable $COMPANY_RDOMAIN_PREFIX equal to the reverse domain name of your comany
# Example: com.duckrowing
#

COMPANY_RDOMAIN_PREFIX="com.twotoasters"

DOXYGEN_PATH=/Applications/Doxygen.app/Contents/Resources/doxygen
DOCSET_PATH=$SOURCE_ROOT/Build/$PRODUCT_NAME.docset

if ! [ -f "$SOURCE_ROOT/Doxyfile" ] 
then 
  echo doxygen config file does not exist
  $DOXYGEN_PATH -g "$SOURCE_ROOT/Doxyfile"
fi

#  Append the proper input/output directories and docset info to the config file.
#  This works even though values are assigned higher up in the file. Easier than sed.

cp "$SOURCE_ROOT/Doxyfile" "$TEMP_DIR/Doxyfile"

echo "INPUT = \"$SOURCE_ROOT/Code\"" >> "$TEMP_DIR/Doxyfile"
echo "OUTPUT_DIRECTORY = \"$DOCSET_PATH\"" >> "$TEMP_DIR/Doxyfile"
echo "RECURSIVE = YES" >> "$TEMP_DIR/Doxyfile"
echo "EXTRACT_ALL        = YES" >> "$TEMP_DIR/Doxyfile"
#echo "JAVADOC_AUTOBRIEF        = YES" >> "$TEMP_DIR/Doxyfile"
echo "GENERATE_LATEX        = NO" >> "$TEMP_DIR/Doxyfile"
echo "GENERATE_DOCSET        = YES" >> "$TEMP_DIR/Doxyfile"
echo "DOCSET_FEEDNAME = \"$PRODUCT_NAME Documentation\"" >> "$TEMP_DIR/Doxyfile"
echo "DOCSET_BUNDLE_ID       = $COMPANY_RDOMAIN_PREFIX.$PRODUCT_NAME" >> "$TEMP_DIR/Doxyfile"
echo "PROJECT_NAME       = \"$PRODUCT_NAME\"" >> "$TEMP_DIR/Doxyfile"

#  Run doxygen on the updated config file.
#  Note: doxygen creates a Makefile that does most of the heavy lifting.

$DOXYGEN_PATH "$TEMP_DIR/Doxyfile"

#  make will invoke docsetutil. Take a look at the Makefile to see how this is done.

make -C "$DOCSET_PATH/html" install

#  Construct a temporary applescript file to tell Xcode to load a docset.

rm -f "$TEMP_DIR/loadDocSet.scpt"

echo "tell application \"Xcode\"" >> "$TEMP_DIR/loadDocSet.scpt"
echo "load documentation set with path \"/Users/$USER/Library/Developer/Shared/Documentation/DocSets/$COMPANY_RDOMAIN_PREFIX.$PRODUCT_NAME.docset\"" >> "$TEMP_DIR/loadDocSet.scpt"
echo "end tell" >> "$TEMP_DIR/loadDocSet.scpt"

#  Run the load-docset applescript command.
osascript "$TEMP_DIR/loadDocSet.scpt"

exit 0
				
