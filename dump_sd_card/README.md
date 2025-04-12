# Dump SD Card

### Overview
This is a quick script to copy the contents of my Sony SD cards to folders on my desktop named by the date the files were created in the camera, then divided into sub-folders for photos and video. I do this task almost daily and having this script will help me work more quickly and make sure files are getting into the right place when multiple days are on one SD card.

#### Limitations
The script currently does not dynamically read the path for the output files or the SD card, and it may not correctly parse more complex scenarios like multiple sub-folders in the photos directory. There are plenty of future improvements I can make, and some refactoring and automated tests will likely be needed if this is to be a long-standing project.

### In use
`./bin/run` from the root of this project will copy files off of a Sony mirrorless camera formatted SD card to the desktop, dividing them into folders by date, and separating photos and videos within each dated folder. The default behavior is to add a suffix to the file name if it already exists in the destination folder, but if you wish to overwrite existing files you can run the tool with an optional environment variable to overwrite duplicates with `UNSAFE_COPY=true ./bin/run`.

#### Additional tools
- `./bin/fix_folder_names`: takes an input of a folder with sub-folders named like `12.10.2024` and renames those folders using the same date but in the desired `2024-12-10` format
- `./bin/fix_timestamps`: copies the original timestamps from video files dumped off a Sony SD card to the files with the same name in an output folder after being processed by Catalyst
