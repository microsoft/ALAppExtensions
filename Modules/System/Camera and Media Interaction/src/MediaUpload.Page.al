// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides an interface for accessing the media on the client device.
/// </summary>
/// <example>
/// <code>
/// MediaInteraction.RunModal();
/// MediaInteraction.GetMedia(InStream);
/// </code>
/// </example>
page 1909 "Media Upload"
{
    Caption = 'Media Upload';
    Editable = false;
    LinksAllowed = false;
    PageType = Card;
    Extensible = true;

    layout
    {
        area(content)
        {
            group(UploadingMedia)
            {
                Caption = 'Uploading picture / video...';
                InstructionalText = 'Please, upload media from your device.';
                Visible = MediaUploadAvailable;
            }
            group(UploadingNotSupported)
            {
                Caption = 'Could not acess the media.';
                InstructionalText = 'Could not access the media on the device. Make sure that you are using the app for Windows, Android, or iOS.';
                Visible = NOT MediaUploadAvailable;
            }
        }
    }

    var
        MediaInteractionImpl: Codeunit "Media Upload Impl.";
        [RunOnClient]
        [WithEvents]
        CameraProvider: DotNet CameraProvider;
        [InDataSet]
        MediaUploadAvailable: Boolean;

    /// <summary>
    /// When the page is opened, the view for selecting a media file will appear.
    /// After the picture or video is chosen the page will automatically close..
    /// </summary>
    trigger OnOpenPage()
    begin
        MediaInteractionImpl.MediaInteractionOnOpenPage(CameraProvider, MediaUploadAvailable);
    end;

    /// <summary>
    /// Checks whether media upload on the client device is available.
    /// </summary>
    /// <returns>True if the media upload is available, false otherwise.</returns>
    procedure IsAvailable(): Boolean
    begin
        exit(MediaInteractionImpl.IsAvailable(CameraProvider));
    end;

    /// <summary>
    /// Sets the type of media to select from.
    /// </summary>
    /// <param name="MediaType">The type of media to upload.</param>
    procedure SetMediaType(MediaType: Enum "Media Type")
    begin
        MediaInteractionImpl.SetMediaType(MediaType);
    end;

    /// <summary>
    /// Sets the media source to Saved Photo Album. The default media source is Photo Library.
    /// </summary>
    /// <remarks>Has no effect on Android.</remarks>
    /// <param name="UploadFromSavedPhotoAlbum">Whether to upload media from Saved Photo Album.</param>
    procedure SetUploadFromSavedPhotoAlbum(UploadFromSavedPhotoAlbum: Boolean)
    begin
        MediaInteractionImpl.SetUploadFromSavedPhotoAlbum(UploadFromSavedPhotoAlbum);
    end;

    /// <summary>
    /// Gets the picture or video that was chosen when the page was opened.
    /// An error is displayed if the function is called without opening the page first.
    /// </summary>
    /// <param name="TempBlob">The object to put the picture BLOB in.</param>
    /// <error>The picture is not available.</error>
    procedure GetMedia(var TempBlob: Codeunit "Temp Blob")
    begin
        MediaInteractionImpl.GetMedia(TempBlob);
    end;

    /// <summary>
    /// Gets the picture or video that was chosen when the page was opened.
    /// An error is thrown if the function is called without opening the page first.
    /// </summary>
    /// <param name="Stream">The InStream to read the picture from.</param>
    /// <error>The picture is not available.</error>
    procedure GetMedia(Stream: Instream)
    begin
        MediaInteractionImpl.GetMedia(Stream);
    end;

    trigger CameraProvider::PictureAvailable(FileName: Text; FilePath: Text)
    begin
        MediaInteractionImpl.MediaInteractionOnPictureAvailable(FilePath);
        CurrPage.Close();
    end;

}