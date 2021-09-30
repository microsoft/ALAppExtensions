This module provides functionality to add, look up, and select product videos.

Use this module to do the following:

- Display a video on a new page.
- Add links to the Product Videos page.
- Get all videos associated with a category.

For example, use this to access video tutorials.


# Public Objects
## Video (Codeunit 3710)
 Lists and enables playing of available videos.

### Play (Method) <a name="Play"></a> 
 Use a link to display a video in a new page. 

#### Syntax
```
procedure Play(Url: Text)
```
#### Parameters
*Url ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

 The link to the video.

### Register (Method) <a name="Register"></a> 
 Adds a link to a video to the Product Videos page.
 

#### Syntax
```
procedure Register(AppID: Guid; Title: Text[250]; VideoUrl: Text[2048])
```
#### Parameters
*AppID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

 The ID of the extension that registers this video.

*Title ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

 The title of the video.

*VideoUrl ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

 The link to the video.

### Register (Method) <a name="Register"></a> 
 Adds a link to a video to the Product Videos page.
 

#### Syntax
```
procedure Register(AppID: Guid; Title: Text[250]; VideoUrl: Text[2048]; Category: Enum "Video Category")
```
#### Parameters
*AppID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

 The ID of the extension that registers this video.

*Title ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

 The title of the video.

*VideoUrl ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

 The link to the video.

*Category ([Enum "Video Category"]())* 

 The video category.

### Register (Method) <a name="Register"></a> 
 Adds a link to a video to the Product Videos page.
 

#### Syntax
```
procedure Register(AppID: Guid; Title: Text[250]; VideoUrl: Text[2048]; TableNum: Integer; SystemId: Guid)
```
#### Parameters
*AppID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

 The ID of the extension that registers this video.

*Title ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

 The title of the video.

*VideoUrl ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

 The link to the video.

*TableNum ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

 The table number of the record that is the source of this video.

*SystemId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

 The system id of the record related to this video. This is
 used to raise the OnVideoPlayed event with that record once the video is
 played.

### Register (Method) <a name="Register"></a> 
 Adds a link to a video to the Product Videos page.
 

#### Syntax
```
procedure Register(AppID: Guid; Title: Text[250]; VideoUrl: Text[2048]; Category: Enum "Video Category"; TableNum: Integer; SystemId: Guid)
```
#### Parameters
*AppID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

 The ID of the extension that registers this video.

*Title ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

 The title of the video.

*VideoUrl ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

 The link to the video.

*Category ([Enum "Video Category"]())* 

 The video category.

*TableNum ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

 The table number of the record that is the source of this video.

*SystemId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

 The system id of the record related to this video. This is
 used to raise the OnVideoPlayed event with that record once the video is
 played.

### Show (Method) <a name="Show"></a> 

 Show all videos that belong to a given category.
 

#### Syntax
```
procedure Show(Category: Enum "Video Category")
```
#### Parameters
*Category ([Enum "Video Category"]())* 

The category to filter the videos by.

### OnRegisterVideo (Event) <a name="OnRegisterVideo"></a> 
 Notifies the subscribers that they can add links to videos to the Product Videos page.

#### Syntax
```
[IntegrationEvent(true, false)]
internal procedure OnRegisterVideo()
```
### OnVideoPlayed (Event) <a name="OnVideoPlayed"></a> 
 Notifies the subscribers that they can act on the source record when a related video is played.

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnVideoPlayed(TableNum: Integer; SystemID: Guid)
```
#### Parameters
*TableNum ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table number of the source record.

*SystemID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The surrogate key of the source record.


## Product Videos (Page 1470)
This page shows all registered videos.


## Video Link (Page 1821)
This page shows the video playing in Business Central.


## Video Category (Enum 3710)
This enum is the category under which videos can be classified.

Extensions can extend this enum to add custom categories.

### Uncategorized (value: 0)


 A default category, specifying that the video is not categorized.
 

