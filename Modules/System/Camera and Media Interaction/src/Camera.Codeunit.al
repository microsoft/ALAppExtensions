// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides the functions for getting the data from a camera on the client device.
/// </summary>
codeunit 1907 Camera
{
    Access = Public;

    var
        CameraImpl: Codeunit "Camera Impl.";

    /// <summary>
    /// Takes a picture from a camera on the client device and returns the data in the InStream.
    /// </summary>
    /// <param name="PictureInStream">An InStream object that will hold the image in case taking a picture was successful.</param>
    /// <param name="PictureName">A generated name for the taken picture. It will include the current date and time (for example, "Picture_05_03_2020_12_49_23.jpeg").</param>
    /// <returns>True if the camera is available, the user took a picture and decided to use it, false otherwise.</returns>
    procedure GetPicture(PictureInStream: InStream; var PictureName: Text): Boolean
    begin
        exit(CameraImpl.GetPicture(PictureInStream, PictureName));
    end;

#if not CLEAN20
    /// <summary>
    /// Adds a picture from the camera to the field of type 'Media'or 'MediaSet' on the provided record. 
    /// </summary>
    /// <remarks>
    /// If the record already has its Media/MediaSet field populated, the user will be shown a prompt whether they want to replace the existing image or not.
    /// </remarks>
    /// <remarks>
    /// If the record variable has the primary key fields populated, and the corresponding record exists in the database,
    /// then the record will be modified, otherwise a new record will be inserted.
    /// </remarks>
    /// <param name="RecordVariant">The record to which to add the picture to.</param>
    /// <param name="FieldNo">The number of the field to write the image to. Must be of type 'Media' or 'MediaSet'.</param>
    /// <error>The provided variant is not of type record.</error>
    /// <error>Unsupported field type</error>
    /// <returns>True if the camera is available, the user took a picture and decided to use it, false otherwise.</returns>
    [Obsolete('This function does not populate the Media/MediaSet record correctly. Use GetPicture instead.', '20.0')]
    procedure AddPicture(RecordVariant: Variant; FieldNo: Integer): Boolean
    begin
        exit(CameraImpl.AddPicture(RecordVariant, FieldNo));
    end;
#endif

    /// <summary>
    /// Checks whether the camera on the client device is available.
    /// </summary>
    /// <returns>True if the camera is available, false otherwise.</returns>
    procedure IsAvailable(): Boolean
    begin
        exit(CameraImpl.IsAvailable());
    end;
}