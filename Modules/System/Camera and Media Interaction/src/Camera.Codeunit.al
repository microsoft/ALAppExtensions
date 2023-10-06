// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Device;

/// <summary>
/// Provides the functions for getting the data from a camera on the client device.
/// </summary>
codeunit 1907 Camera
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        CameraImpl: Codeunit "Camera Impl.";

    /// <summary>
    /// Takes a picture from a camera on the client device and returns the data in the InStream.
    /// </summary>
    /// <param name="PictureInStream">An InStream object that will hold the image in case taking a picture was successful.</param>
    /// <param name="PictureName">A generated name for the taken picture. It will include the current date and time (for example, "Picture_05_03_2020_12_49_23.jpeg").</param>
    /// <returns>True if the camera is available, the user took a picture and decided to use it, false otherwise.</returns>
    procedure GetPicture(PictureInStream: InStream; var PictureName: Text): Boolean
    var
        Quality: Decimal;
    begin
        Quality := 100; // 100%
        exit(CameraImpl.GetPicture(Quality, PictureInStream, PictureName));
    end;

    /// <summary>
    /// Takes a picture from a camera on the client device and returns the data in the InStream.
    /// </summary>
    /// <param name="Quality">Sets the quality of the saved image, expressed as a number between 0 and 100, where 100 is the highest available resolution.</param>
    /// <param name="PictureInStream">An InStream object that will hold the image in case taking a picture was successful.</param>
    /// <param name="PictureName">A generated name for the taken picture. It will include the current date and time (for example, "Picture_05_03_2020_12_49_23.jpeg").</param>
    /// <returns>True if the camera is available, the user took a picture and decided to use it, false otherwise.</returns>    
    /// <error>The picture quality must be in the range from 0 to 100.</error>
    procedure GetPicture(Quality: Integer; PictureInStream: InStream; var PictureName: Text): Boolean
    begin
        exit(CameraImpl.GetPicture(Quality, PictureInStream, PictureName));
    end;

    /// <summary>
    /// Checks whether the camera on the client device is available.
    /// </summary>
    /// <returns>True if the camera is available, false otherwise.</returns>
    procedure IsAvailable(): Boolean
    begin
        exit(CameraImpl.IsAvailable());
    end;
}