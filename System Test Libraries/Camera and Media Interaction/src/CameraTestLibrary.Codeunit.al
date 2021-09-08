// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135101 "Camera Test Library"
{
    EventSubscriberInstance = Manual;

    var
        Base64Convert: Codeunit "Base64 Convert";
        FileNameTok: Label 'Image.jpeg';

    /// <summary>
    /// Save a mock picture on the server instead of accessing an actual camera.
    /// </summary>
    /// <param name="Handled">Signals whether taking the picture was handled by the subsciber.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Camera Page Impl.", 'OnBeforeCameraInitialize', '', false, false)]
    local procedure OnBeforeCameraInitialize(var Handled: Boolean; var PictureFilePath: Text)
    var
        MockPictureFile: File;
        OutStr: OutStream;
    begin
        Handled := true;
        PictureFilePath := FileNameTok;
        MockPictureFile.Create(FileNameTok);
        MockPictureFile.CreateOutStream(OutStr);
        Base64Convert.FromBase64(GetSmallJpeg(), OutStr);
        MockPictureFile.Close();
    end;

    /// <summary>
    /// Indicate that the camera is available when test is in progress.
    /// </summary>
    /// <param name="IsAvailable">Signals whether the camera is vailable.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Camera Page Impl.", 'OnIsCameraAvailable', '', false, false)]
    local procedure OnIsCameraAvailable(var IsAvailable: Boolean)
    begin
        IsAvailable := true;
    end;

    procedure GetSmallJpeg(): Text
    begin
        exit(
            '/9j/4AAQSkZJRgABAQEAAAAAAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////2wBDAf///////////////////////////////' +
            '///////////////////////////////////////////////////////wAARCAAXACkDASIAAhEBAxEB/8QAFgABAQEAAAAAAAAAAAAAAAAAAAEC/8QAFhABAQEAAAAAAAAAAAAAAAAAABEB/8QAFgEBAQEAAA' +
            'AAAAAAAAAAAAAAAAEC/8QAFREBAQAAAAAAAAAAAAAAAAAAABH/2gAMAwEAAhEDEQA/AKi0WolFpShSlwuAwAyoAAAD/9k=');
    end;
}