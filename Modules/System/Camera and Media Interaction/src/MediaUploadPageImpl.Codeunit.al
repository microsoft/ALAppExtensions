// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1909 "Media Upload Page Impl."
{
    Access = Internal;

    var
        FileHelper: Codeunit "File Helper";
        FileTempBlob: Codeunit "Temp Blob";
        CameraOptions: DotNet CameraOptions;
        AreCameraOptionsInitialized: Boolean;
        NoMediaWasSelectedErr: Label 'No media was selected.';

    procedure MediaInteractionOnOpenPage(var CameraProvider: DotNet CameraProvider; var MediaUploadAvailable: Boolean)
    begin
        MediaUploadAvailable := IsAvailable(CameraProvider);
        if not MediaUploadAvailable then
            exit;

        InitializeCameraOptions();
        CameraProvider := CameraProvider.Create();
        CameraProvider.RequestPictureAsync(CameraOptions);
    end;

    procedure IsAvailable(CameraProvider: DotNet CameraProvider): Boolean
    begin
        exit(CameraProvider.IsAvailable());
    end;

    local procedure InitializeCameraOptions()
    begin
        if AreCameraOptionsInitialized then
            exit;
        CameraOptions := CameraOptions.CameraOptions();
        CameraOptions.SourceType := 'PhotoLibrary';
        AreCameraOptionsInitialized := true;
    end;

    procedure SetMediaType(MediaType: Enum "Media Type")
    begin
        InitializeCameraOptions();

        case MediaType of
            Enum::"Media Type"::"All Media":
                CameraOptions.MediaType := 'AllMedia';
            Enum::"Media Type"::Picture:
                CameraOptions.MediaType := 'Picture';
            Enum::"Media Type"::Video:
                CameraOptions.MediaType := 'Video';
        end;
    end;

    procedure SetUploadFromSavedPhotoAlbum(UploadFromSavedPhotoAlbum: Boolean)
    begin
        InitializeCameraOptions();

        if (UploadFromSavedPhotoAlbum) then
            CameraOptions.SourceType := 'SavedPhotoAlbum'
        else
            CameraOptions.SourceType := 'PhotoLibrary';
    end;

    procedure GetMedia(var TempBlob: Codeunit "Temp Blob")
    begin
        if not FileHelper.GetFile(TempBlob) then
            Error(NoMediaWasSelectedErr);
    end;

    procedure GetMedia(InStream: InStream)
    begin
        GetMedia(FileTempBlob);
        FileTempBlob.CreateInStream(InStream);
    end;

    procedure HasMedia(): Boolean
    begin
        exit(FileHelper.FileExists());
    end;

    procedure MediaInteractionOnPictureAvailable(FilePath: Text)
    begin
        FileHelper.SetPath(FilePath);
    end;
}

