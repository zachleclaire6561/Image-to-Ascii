# Image File To Ascii Art

This bash script allows you to convert an image into ascii art

### Dependencies:
Image Magick (Download here: https://imagemagick.org/script/download.php)

### Usage:
The script has 3-4 primary parameter along with 2 option ones
1. Image file name (required)
2. Dimensions of Ascii Art: X by Y (optional)
3. Background color (black or white)
4. Output format (stdout or append to file)

### Example:
1. In terminal type: sh toAscii.sh boat.png 50 50
2. Select black background (0)
3. Select the text output (1)
4. Enter the file name boat.txt

### Behind the scenes:
1. The file is verified to exist, readable, and have a valid file extension
2. This boat image is converted into the following resized boat image to make it easier to process

![boat image](https://github.com/zachleclaire6561/Project-1/blob/master/test/boat.png)


![resized boat](https://github.com/zachleclaire6561/Project-1/blob/master/test/resized_boat.png)

3. This resized boat is processed and the output is printed to boat.txt

![ascii output](https://github.com/zachleclaire6561/Project-1/blob/master/test/ascii_boat.PNG)
