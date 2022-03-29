// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides an interface for accessing the media on the client device.
/// </summary>
/// <example>
/// <code>
/// MediaUpload.RunModal();
/// if MediaUpload.HasMedia() then begin
///     MediaUpload.GetMedia(InStream);
/// ...
/// end;
/// Clear(MediaUpload);
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
        MediaUploadPageImpl: Codeunit "Media Upload Page Impl.";
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
        MediaUploadPageImpl.MediaInteractionOnOpenPage(CameraProvider, MediaUploadAvailable);
    end;

    /// <summary>
    /// Checks whether media upload on the client device is available.
    /// </summary>
    /// <returns>True if the media upload is available, false otherwise.</returns>
    procedure IsAvailable(): Boolean
    begin
        exit(MediaUploadPageImpl.IsAvailable(CameraProvider));
    end;

    /// <summary>
    /// Sets the type of media to select from.
    /// </summary>
    /// <param name="MediaType">The type of media to upload.</param>
    procedure SetMediaType(MediaType: Enum "Media Type")
    begin
        MediaUploadPageImpl.SetMediaType(MediaType);
    end;

    /// <summary>
    /// Sets the media source to Saved Photo Album. The default media source is Photo Library.
    /// </summary>
    /// <remarks>Has no effect on Android.</remarks>
    /// <param name="UploadFromSavedPhotoAlbum">Whether to upload media from Saved Photo Album.</param>
    procedure SetUploadFromSavedPhotoAlbum(UploadFromSavedPhotoAlbum: Boolean)
    begin
        MediaUploadPageImpl.SetUploadFromSavedPhotoAlbum(UploadFromSavedPhotoAlbum);
    end;

    /// <summary>
    /// Gets the picture or video that was chosen when the page was opened.
    /// An error is displayed if the function is called without opening the page first.
    /// </summary>
    /// <param name="TempBlob">The object to put the picture BLOB in.</param>
    /// <error>The picture is not available.</error>
    procedure GetMedia(var TempBlob: Codeunit "Temp Blob")
    begin
        MediaUploadPageImpl.GetMedia(TempBlob);
    end;

    /// <summary>
    /// Checks if the media is available and can be obtained with a <see cref="GetMedia"/> method.
    /// </summary>
    /// <remarks>
    /// The media will not be available if the page was not opened
    /// (e. g. MediaUpload.RunModal() function was not called) or if the dialog was canceled.
    /// </remarks>
    /// <returns>True if the media is available, false otherwise.</returns>
    procedure HasMedia(): Boolean
    begin
        exit(MediaUploadPageImpl.HasMedia());
    end;

    /// <summary>
    /// Gets the picture or video that was chosen when the page was opened.
    /// An error is thrown if the function is called without opening the page first.
    /// </summary>
    /// <param name="InStream">The InStream to read the picture from.</param>
    /// <error>The picture is not available.</error>
    procedure GetMedia(InStream: Instream)
    begin
        MediaUploadPageImpl.GetMedia(InStream);
    end;

    trigger CameraProvider::PictureAvailable(FileName: Text; FilePath: Text)
    begin
        MediaUploadPageImpl.MediaInteractionOnPictureAvailable(FilePath);
        CurrPage.Close();
    end;

}