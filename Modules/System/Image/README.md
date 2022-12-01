This module provides an API for working with images in Business Central. The module provide some basic for manipulating images. For example, you might want images to always display in a certain width and height, so we've added the ability to do things like resize and crop images. 

You can use this module to: 
- Load and store images
- Resize images
- Crop images


### How to load an image
```
procedure Example()
var
    Image: Codeunit Image;
    Instream: InStream;
    FileName: Text;
begin
    DownloadFromStream(Instream, '', '', '', FileName);
    Image.FromStream(Instream);
end;
```

On a side note, the Image module will verify that a stream of data is an image, and can be presented as an image, when you load them. Data verification is important when you build an app or extension for Business Central that uses image content.

### How to manipulate an image
The following examples show how to resize and crop images.

##### Resize an image
```
procedure Example()
var
    Image: Codeunit Image;
    InStream: InStream;
    OutStream: OutStream;
    FileName: Text;
begin

    DownloadFromStream(InStream, '', '', '', FileName);
    Image.FromStream(InStream);
    Image.Resize(600, 800);
    Image.Save(OutStream);	

```
##### Crop an image
```
procedure Example()
var
    Image: Codeunit Image;
    InStream: InStream;
    OutStream: OutStream;
    FileName: Text;
begin
	DownloadFromStream(InStream, '', '', '', FileName);
    Image.FromStream(InStream);
    Image.Crop(0, 0, 600, 800);
    Image.Save(OutStream);		

end;
```

##### Save an image in a new format
```
procedure Example()
var
    TempBlob: Codeunit "Temp Blob";
    Image: Codeunit Image;
    InStream: InStream;
    OutStream: OutStream;
    FileName: Text;
begin
    UploadIntoStream('', '', '', FileName, InStream);

    Image.FromStream(InStream);
    Image.SetFormat(Enum::"Image Format"::Png);

    TempBlob.CreateOutStream(OutStream);
    Image.Save(OutStream);	

    TempBlob.CreateInStream(InStream);
    FileName := FileName + '.png';
    DownloadFromStream(InStream, '', '', '', FileName);
end;
```

# Public Objects
## Image (Codeunit 3971)

 Provides functionality for working with images.
 

### Crop (Method) <a name="Crop"></a> 
X and Y is not within the image dimensions.


 Crops the image based on a rectangle specified by the user.
 The resulting crop will be a hole-cut in the image made by the rectangle.
 

The Rectangles top left corner has to be within the image dimensions,
 but specifying a width or height that makes the rectangle go outside the image dimensions is allowed.
 Anything outside the image dimensions will be filled with the image background color.

#### Syntax
```
procedure Crop(X: Integer; Y: Integer; Width: Integer; Height: Integer)
```
#### Parameters
*X ([Integer](https://go.microsoft.com/fwlink/?linkid=2209956))* 

X coordinate of the rectangle.

*Y ([Integer](https://go.microsoft.com/fwlink/?linkid=2209956))* 

Y coordinate of the rectangle.

*Width ([Integer](https://go.microsoft.com/fwlink/?linkid=2209956))* 

Width of rectangle.

*Height ([Integer](https://go.microsoft.com/fwlink/?linkid=2209956))* 

Height of the rectangle./

### GetFormatAsText (Method) <a name="GetFormatAsText"></a> 

 Gets the image format as a text.
 

#### Syntax
```
procedure GetFormatAsText(): Text
```
#### Return Value
*[Text](https://go.microsoft.com/fwlink/?linkid=2210031)*

A text containing the format value.
### GetFormat (Method) <a name="GetFormat"></a> 

 Gets the image format as an Enum "Image Format".
 

#### Syntax
```
procedure GetFormat(): Enum "Image Format"
```
#### Return Value
*[Enum "Image Format"]()*

The enum value.
### SetFormat (Method) <a name="SetFormat"></a> 

 Sets the image format from an Enum "Image Format".
 

#### Syntax
```
procedure SetFormat(ImageFormat: Enum "Image Format")
```
### FromBase64 (Method) <a name="FromBase64"></a> 

 Creates an Image from base64 encoding.
 

#### Syntax
```
procedure FromBase64(Base64Text: Text)
```
#### Parameters
*Base64Text ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

A base64 encoded string the contains the image.

### FromStream (Method) <a name="FromStream"></a> 
Stream do not contain valid image data


 Creates an image from the specified data stream.
 

#### Syntax
```
procedure FromStream(InStream: InStream)
```
#### Parameters
*InStream ([InStream](https://go.microsoft.com/fwlink/?linkid=2210033))* 

A Stream that contains the image data.

### GetWidth (Method) <a name="GetWidth"></a> 

 Gets the width in pixels.
 

#### Syntax
```
procedure GetWidth(): Integer
```
#### Return Value
*[Integer](https://go.microsoft.com/fwlink/?linkid=2209956)*

The width in pixels.
### GetHeight (Method) <a name="GetHeight"></a> 

 Gets the height in pixels.
 

#### Syntax
```
procedure GetHeight(): Integer
```
#### Return Value
*[Integer](https://go.microsoft.com/fwlink/?linkid=2209956)*

The height in pixels.
### Resize (Method) <a name="Resize"></a> 
Width and Height is less than one.


 Resizes the Image to the specified size.
 

#### Syntax
```
procedure Resize(Width: Integer; Height: Integer)
```
#### Parameters
*Width ([Integer](https://go.microsoft.com/fwlink/?linkid=2209956))* 

The resize width.

*Height ([Integer](https://go.microsoft.com/fwlink/?linkid=2209956))* 

The resize height.

### Save (Method) <a name="Save"></a> 

 Saves the image to the specified stream in the specified format.
 

#### Syntax
```
procedure Save(OutStream: OutStream)
```
#### Parameters
*OutStream ([OutStream](https://go.microsoft.com/fwlink/?linkid=2210034))* 

A Stream that will store the image data.

### ToBase64 (Method) <a name="ToBase64"></a> 

 Convert the image to a base64 encoded string.
 

#### Syntax
```
procedure ToBase64(): Text
```
#### Return Value
*[Text](https://go.microsoft.com/fwlink/?linkid=2210031)*

A string containing the image data encoded with base64.

## Image Format (Enum 3971)

 This enum contains the Image format types.
 

### Bmp (value: 0)


 Bmp image format
 

### Emf (value: 1)


 Emf image format
 

### Exif (value: 2)


 Exif image format
 

### Gif (value: 3)


 Gif image format
 

### Icon (value: 5)


 Icon image format
 

### Jpeg (value: 6)


 Jpeg image format
 

### Png (value: 7)


 Png image format
 

### Tiff (value: 8)


 Tiff image format
 

### Wmf (value: 9)


 Wmf image format
 

