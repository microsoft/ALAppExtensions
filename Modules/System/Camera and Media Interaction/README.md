Contains functionality that enables users to interact with a camera or media.
# Public Objects
## Camera (Page 1908)

 Provides an interface for accessing the camera on the client device.
 

### IsAvailable (Method) <a name="IsAvailable"></a> 

 Checks whether the camera on the client device is available.
 

#### Syntax
```
procedure IsAvailable(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the camera is available, false otherwise.
### SetAllowEdit (Method) <a name="SetAllowEdit"></a> 

 Indicates whether simple editing is allowed before the picture is stored.
 

#### Syntax
```
procedure SetAllowEdit(AllowEdit: Boolean)
```
#### Parameters
*AllowEdit ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

True to enable simple editing, false otherwise.

### SetEncodingType (Method) <a name="SetEncodingType"></a> 

 Sets the returned image file's encoding. The default is [JPEG](#JPEG).
 

#### Syntax
```
procedure SetEncodingType(EncodingType: Enum "Image Encoding")
```
#### Parameters
*EncodingType ([Enum "Image Encoding"]())* 

The encoding to use when saving the picture.

### SetQuality (Method) <a name="SetQuality"></a> 
The picture quality must be in the range from 0 to 100.


 Sets the quality of the saved image, expressed as a number
 between 0 and 100, where 100 is the highest available resolution.
 The default is 50.
 

#### Syntax
```
procedure SetQuality(Quality: Integer)
```
#### Parameters
*Quality ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The quality of the picture to be taken.

### GetPicture (Method) <a name="GetPicture"></a> 
The picture is not available.


 Gets the picture that was taken when the page was opened.
 An error is displayed if the function is called without opening the page first.
 

#### Syntax
```
procedure GetPicture(var TempBlob: Codeunit "Temp Blob")
```
#### Parameters
*TempBlob ([Codeunit "Temp Blob"]())* 

The object to put the picture BLOB in.

### GetPicture (Method) <a name="GetPicture"></a> 
The picture is not available.


 Gets the picture that was taken when the page was opened.
 An error is displayed if the function is called without opening the page first.
 

#### Syntax
```
procedure GetPicture(Stream: Instream)
```
#### Parameters
*Stream ([Instream]())* 

The InStream to read the picture from.


## Media Upload (Page 1909)

 Provides an interface for accessing the media on the client device.
 

### IsAvailable (Method) <a name="IsAvailable"></a> 

 Checks whether media upload on the client device is available.
 

#### Syntax
```
procedure IsAvailable(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the media upload is available, false otherwise.
### SetMediaType (Method) <a name="SetMediaType"></a> 

 Sets the type of media to select from.
 

#### Syntax
```
procedure SetMediaType(MediaType: Enum "Media Type")
```
#### Parameters
*MediaType ([Enum "Media Type"]())* 

The type of media to upload.

### SetUploadFromSavedPhotoAlbum (Method) <a name="SetUploadFromSavedPhotoAlbum"></a> 

 Sets the media source to Saved Photo Album. The default media source is Photo Library.
 

Has no effect on Android.

#### Syntax
```
procedure SetUploadFromSavedPhotoAlbum(UploadFromSavedPhotoAlbum: Boolean)
```
#### Parameters
*UploadFromSavedPhotoAlbum ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Whether to upload media from Saved Photo Album.

### GetMedia (Method) <a name="GetMedia"></a> 
The picture is not available.


 Gets the picture or video that was chosen when the page was opened.
 An error is displayed if the function is called without opening the page first.
 

#### Syntax
```
procedure GetMedia(var TempBlob: Codeunit "Temp Blob")
```
#### Parameters
*TempBlob ([Codeunit "Temp Blob"]())* 

The object to put the picture BLOB in.

### GetMedia (Method) <a name="GetMedia"></a> 
The picture is not available.


 Gets the picture or video that was chosen when the page was opened.
 An error is thrown if the function is called without opening the page first.
 

#### Syntax
```
procedure GetMedia(Stream: Instream)
```
#### Parameters
*Stream ([Instream]())* 

The InStream to read the picture from.


## Image Encoding (Enum 1908)

 Specifies the supported encodings for the Camera Interaction page.
 

### JPEG (value: 0)


 JPEG image encoding format.
 

### PNG (value: 1)


 PNG image encoding format.
 


## Media Type (Enum 1909)

 Specifies media type for the Media Interaction page.
 

### All Media (value: 0)


 Choose from either pictures or videos.
 

### Picture (value: 1)


 Choose from pictures.
 

### Video (value: 2)


 Choose from videos.
 

