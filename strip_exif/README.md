# Image Exif Sanitizer

A Ruby CLI tool that strips all metadata (GPS location, camera serial numbers, embedded thumbnails, and device info) from images before sharing them online—while preserving core camera exposure settings: Focal Length, Shutter Speed, ISO, and Aperture.

## Why Use This?

Most EXIF stripping tools either leave hidden metadata behind (like MakerNotes or secondary embedded thumbnails) or wipe everything, including exposure data you might want to share with other photographers.

This tool performs a full-wipe reset on the image metadata and surgically restores only the requested exposure tags.

## Prerequisites

This script relies on ExifTool, the industry-standard tool for reading and writing metadata.

### Installing ExifTool

* **macOS** (via Homebrew):
brew install exiftool
* **Ubuntu / Debian**:
sudo apt update && sudo apt install libimage-exiftool-perl
* **Arch Linux**:
sudo pacman -S exiftool
* **Windows**: Download the executable from exiftool.org and add it to your System PATH.

## Installation

1. Save `strip_exif.rb` to your working directory.
2. Ensure you have Ruby installed (run `ruby -v` in your terminal to check).
3. Make the script executable (macOS/Linux): `chmod +x strip_exif.rb`

## Usage

Pass one or multiple image paths to the script as arguments:

```shell
# Process a single image:
./strip_exif.rb photo.jpg

# Process multiple images at once:
./strip_exif.rb photo1.jpg photo2.png /path/to/photo3.jpg

# Process all JPEG files in a directory:
./strip_exif.rb *.jpg
```

## What Gets Removed vs. Kept

**Removed (Privacy Concerns):**

* GPS coordinates & altitude
* Device serial numbers & owner names
* Date and time original
* Software / editing history
* Embedded thumbnail previews
* Proprietary camera MakerNotes

**Preserved (Camera Settings):**

* **Focal Length** (-FocalLength)
* **Shutter Speed** (-ExposureTime)
* **Aperture** (-FNumber)
* **ISO** (-ISO)

## Caution

This script overwrites the target file directly (`-overwrite_original`). Always keep a backup of your original raw or master image files before running batch operations!
