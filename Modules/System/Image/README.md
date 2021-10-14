This module provides an API for working with images in Business Central. The module provide some basic for manipulating images. For example, you might want images to always display in a certain width and height, so we've added the ability to do things like resize and crop images. 

You can use this module to: 
- Load and store images
- Resize images
- Crop images


### How to load an image
```c
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
```c
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
```c
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
