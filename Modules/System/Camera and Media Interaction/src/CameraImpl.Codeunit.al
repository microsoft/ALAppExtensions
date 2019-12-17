// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1908 "Camera Impl."
{
    Access = Internal;

    var
        FileHelper: Codeunit "File Helper";
        CameraOptions: DotNet CameraOptions;
        AreCameraOptionsInitialized: Boolean;
        QualityOutOfRangeErr: Label 'The picture quality must be in the range from 0 to 100.';


    procedure CameraInteractionOnOpenPage(var CameraProvider: DotNet CameraProvider; var CameraAvailable: Boolean)
    begin
        CameraAvailable := IsAvailable(CameraProvider);
        if not CameraAvailable then
            exit;

        InitializeCameraOptions();
        CameraProvider := CameraProvider.Create();
        CameraProvider.RequestPictureAsync(CameraOptions);
    end;

    local procedure InitializeCameraOptions()
    begin
        if AreCameraOptionsInitialized then
            exit;
        CameraOptions := CameraOptions.CameraOptions();
        AreCameraOptionsInitialized := true;
    end;

    procedure IsAvailable(CameraProvider: DotNet CameraProvider): Boolean
    begin
        exit(CameraProvider.IsAvailable());
    end;

    procedure SetAllowEdit(AllowEdit: Boolean)
    begin
        InitializeCameraOptions();
        CameraOptions.AllowEdit := AllowEdit;
    end;

    procedure SetEncodingType(EncodingType: Enum "Image Encoding")
    begin
        InitializeCameraOptions();
        case EncodingType of
            Enum::"Image Encoding"::JPEG:
                CameraOptions.EncodingType := 'JPEG';
            Enum::"Image Encoding"::PNG:
                CameraOptions.EncodingType := 'PNG';
        end;
    end;

    procedure SetQuality(Quality: Integer)
    begin
        if (Quality < 0) or (Quality > 100) then
            Error(QualityOutOfRangeErr);

        InitializeCameraOptions();
        CameraOptions.Quality := Quality;
    end;

    procedure GetPicture(var TempBlob: Codeunit "Temp Blob")
    begin
        FileHelper.GetFile(TempBlob);
    end;

    procedure GetPicture(Stream: InStream)
    begin
        FileHelper.GetFile(Stream);
    end;

    procedure CameraInteractionOnPictureAvailable(FilePath: Text)
    begin
        FileHelper.SetPath(FilePath);
    end;
}

