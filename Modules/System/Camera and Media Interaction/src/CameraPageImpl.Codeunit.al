// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1908 "Camera Page Impl."
{
    Access = Internal;

    var
        FileHelper: Codeunit "File Helper";
        FileTempBlob: Codeunit "Temp Blob";
        CameraOptions: DotNet CameraOptions;
        AreCameraOptionsInitialized: Boolean;
        QualityOutOfRangeErr: Label 'The picture quality must be in the range from 0 to 100.';
        NoPictureWasTakenErr: Label 'No picture was taken.';

    procedure CameraInteractionOnOpenPage(var CameraProvider: DotNet CameraProvider; var CameraAvailable: Boolean)
    var
        HandledByTest: Boolean;
        PictureFilePath: Text;
    begin
        OnBeforeCameraInitialize(HandledByTest, PictureFilePath);
        if HandledByTest then begin
            CameraInteractionOnPictureAvailable(PictureFilePath);
            exit;
        end;

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
    var
        IsCameraAvailable: Boolean;
    begin
        IsCameraAvailable := CameraProvider.IsAvailable();
        OnIsCameraAvailable(IsCameraAvailable);
        exit(IsCameraAvailable);
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
        if not FileHelper.GetFile(TempBlob) then
            Error(NoPictureWasTakenErr);
    end;

    procedure HasPicture(): Boolean
    begin
        exit(FileHelper.FileExists());
    end;

    procedure GetPicture(InStream: InStream)
    begin
        GetPicture(FileTempBlob);
        FileTempBlob.CreateInStream(InStream);
    end;

    procedure CameraInteractionOnPictureAvailable(FilePath: Text)
    begin
        FileHelper.SetPath(FilePath);
    end;

    [InternalEvent(false)]
    procedure OnBeforeCameraInitialize(var Handled: Boolean; var PictureFilePath: Text)
    begin
        // Used for testing
    end;

    [InternalEvent(false)]
    procedure OnIsCameraAvailable(var IsAvailable: Boolean)
    begin
        // Used for testing
    end;
}

