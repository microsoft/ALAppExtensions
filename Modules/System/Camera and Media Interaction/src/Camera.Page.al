// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides an interface for accessing the camera on the client device.
/// </summary>
/// <example>
/// <code>
/// Camera.RunModal();
/// if Camera.HasPicture() then begin
///     Camera.GetPicture(InStream);
/// ...
/// end;
/// Clear(Camera);
/// </code>
/// </example>
page 1908 Camera
{
    Caption = 'Camera';
    Editable = false;
    LinksAllowed = false;
    PageType = Card;
    Extensible = true;

    layout
    {
        area(content)
        {
            group(TakingPicture)
            {
                Caption = 'Taking picture...';
                InstructionalText = 'Please, take a picture using your camera.';
                Visible = CameraAvailable;
            }
            group(CameraNotSupported)
            {
                Caption = 'Could not connect to camera';
                InstructionalText = 'Could not access the camera on the device. Make sure that you are using the app for Windows, Android, or iOS.';
                Visible = NOT CameraAvailable;
            }
        }
    }

    var
        CameraPageImpl: Codeunit "Camera Page Impl.";
        [RunOnClient]
        [WithEvents]
        CameraProvider: DotNet CameraProvider;
        [InDataSet]
        CameraAvailable: Boolean;


    /// <summary>
    /// When the page is open the view for taking a picture is available.
    /// After the picture is taken the view will close automatically.
    /// </summary>
    /// <remarks>You can edit the picture if <see cref="SetAllowEdit"/> with parameter true was called.</remarks>
    trigger OnOpenPage()
    begin
        CameraPageImpl.CameraInteractionOnOpenPage(CameraProvider, CameraAvailable);
    end;

    /// <summary>
    /// Checks whether the camera on the client device is available.
    /// </summary>
    /// <returns>True if the camera is available, false otherwise.</returns>
    procedure IsAvailable(): Boolean
    begin
        exit(CameraPageImpl.IsAvailable(CameraProvider));
    end;

    /// <summary>
    /// Indicates whether simple editing is allowed before the picture is stored.
    /// </summary>
    /// <param name="AllowEdit">True to enable simple editing, false otherwise.</param>
    procedure SetAllowEdit(AllowEdit: Boolean)
    begin
        CameraPageImpl.SetAllowEdit(AllowEdit);
    end;

    /// <summary>
    /// Sets the returned image file's encoding. The default is <see cref="JPEG"/>.
    /// </summary>
    /// <param name="EncodingType">The encoding to use when saving the picture.</param>
    procedure SetEncodingType(EncodingType: Enum "Image Encoding")
    begin
        CameraPageImpl.SetEncodingType(EncodingType);
    end;

    /// <summary>
    /// Sets the quality of the saved image, expressed as a number
    /// between 0 and 100, where 100 is the highest available resolution.
    /// The default is 50.
    /// </summary>
    /// <param name="Quality">The quality of the picture to be taken.</param>
    /// <error>The picture quality must be in the range from 0 to 100.</error>
    procedure SetQuality(Quality: Integer)
    begin
        CameraPageImpl.SetQuality(Quality);
    end;

    /// <summary>
    /// Gets the picture that was taken when the page was opened.
    /// An error is displayed if the function is called without opening the page first.
    /// </summary>
    /// <param name="TempBlob">The object to put the picture BLOB in.</param>
    /// <error>The picture is not available.</error>
    procedure GetPicture(var TempBlob: Codeunit "Temp Blob")
    begin
        CameraPageImpl.GetPicture(TempBlob);
    end;

    /// <summary>
    /// Checks if the picture is available and can be obtained with a <see cref="GetPicture"/> method.
    /// </summary>
    /// <remarks>
    /// The picture will not be available if the page was not opened
    /// (e. g. Camera.RunModal() function was not called) or if the dialog was canceled.
    /// </remarks>
    /// <returns>True if the picture is available, false otherwise.</returns>
    procedure HasPicture(): Boolean
    begin
        exit(CameraPageImpl.HasPicture());
    end;

    /// <summary>
    /// Gets the picture that was taken when the page was opened.
    /// An error is displayed if the function is called without opening the page first.
    /// </summary>
    /// <param name="InStream">The InStream to read the picture from.</param>
    /// <error>The picture is not available.</error>
    procedure GetPicture(InStream: Instream)
    begin
        CameraPageImpl.GetPicture(InStream);
    end;

    trigger CameraProvider::PictureAvailable(PictureName: Text; PictureFilePath: Text)
    begin
        CameraPageImpl.CameraInteractionOnPictureAvailable(PictureFilePath);
        CurrPage.Close();
    end;
}

