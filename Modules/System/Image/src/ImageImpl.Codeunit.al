// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3970 "Image Impl."
{
    Access = Internal;

    var
        TempBlob: Codeunit "Temp Blob";
        ImageCodec: DotNet ImageCodecInfo;
        WidthErr: Label 'Parameter Width must be greater than 0';
        HeightErr: Label 'Parameter Height must be greater than 0';
        XErr: Label 'Parameter X must be between 0 and image width';
        YErr: Label 'Parameter Y must be between 0 and image height';
        FormatErr: Label 'Image is not in valid format';
        ImageToLargeErr: Label 'Input image to large. Max allowed size is 5 MB';
        UnsupportedFormatErr: Label 'Format is currently not supported';
        QualityEncodeGuidTxt: Label '1d5be4b5-fa4a-452d-9cdd-5db35105e7eb', Locked = true;
        ImageCroppedTxt: Label 'Image cropped to x: %1, y: %2, width: %3, height: %4, format: %5', Locked = true;
        ImageResizeTxt: Label 'Image with width: %1, height: %2, format: %3 was resized', Locked = true;
        ImageCreatedTxt: Label 'Image created with size: %1, width: %2, height: %3, format: %4', Locked = true;
        ImageToLargeTxt: Label 'Image uploaded with size: %1', Locked = true;
        FormatTxt: Label 'Image input data is in wrong format';
        ImageCatTxt: Label 'Image Module', Locked = true;

    procedure Crop(X: Integer; Y: Integer; Width: Integer; Height: Integer)
    var
        DstRectangle: DotNet Rectangle;
        SrcRectangle: DotNet Rectangle;
        Graphics: DotNet Graphics;
        GraphicsUnit: DotNet GraphicsUnit;
        BitmapDst: DotNet Bitmap;
        Image: DotNet Image;
        InStream: InStream;
        CurrentWidth, CurrentHeight : Integer;
    begin
        CurrentWidth := GetWidth();
        CurrentHeight := GetHeight();
        Session.LogMessage('0000FLN', StrSubstNo(ImageCroppedTxt, X, Y, CurrentWidth, CurrentHeight, GetFormatAsString()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ImageCatTxt);

        if Width < 1 then
            Error(WidthErr);
        if Height < 1 then
            Error(HeightErr);

        if (X < 0) or (X > CurrentWidth) then
            Error(XErr);
        if (Y < 0) or (Y > CurrentHeight) then
            Error(YErr);

        TempBlob.CreateInStream(InStream);
        Image := Image.FromStream(InStream);

        SrcRectangle := SrcRectangle.Rectangle(X, Y, Width, Height);
        DstRectangle := DstRectangle.Rectangle(0, 0, Width, Height);
        BitmapDst := BitmapDst.Bitmap(Width, Height);
        Graphics := Graphics.FromImage(BitmapDst);

        Graphics.SmoothingMode := Graphics.SmoothingMode::AntiAlias;
        Graphics.InterpolationMode := Graphics.InterpolationMode::HighQualityBicubic;
        Graphics.PixelOffsetMode := Graphics.PixelOffsetMode::HighQuality;

        Graphics.DrawImage(Image, DstRectangle, SrcRectangle, GraphicsUnit::Pixel);
        Graphics.Dispose();

        EncodeToImage(BitmapDst);
        BitmapDst.Dispose();
    end;

    procedure Resize(Width: Integer; Height: Integer)
    var
        BitmapDst: DotNet Bitmap;
        Graphics: DotNet Graphics;
        Rectangle: DotNet Rectangle;
        Image: DotNet Image;
        InStream: InStream;
    begin
        Session.LogMessage('0000FLO', StrSubstNo(ImageResizeTxt, GetWidth(), GetHeight(), GetFormatAsString()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ImageCatTxt);

        if Width < 1 then
            Error(WidthErr);
        if Height < 1 then
            Error(HeightErr);

        TempBlob.CreateInStream(InStream);
        Image := Image.FromStream(InStream);

        Rectangle := Rectangle.Rectangle(0, 0, Width, Height);
        BitmapDst := BitmapDst.Bitmap(Width, Height);
        BitmapDst.SetResolution(Image.HorizontalResolution, Image.VerticalResolution);

        Graphics := Graphics.FromImage(BitmapDst);
        Graphics.SmoothingMode := Graphics.SmoothingMode::AntiAlias;
        Graphics.InterpolationMode := Graphics.InterpolationMode::HighQualityBicubic;
        Graphics.PixelOffsetMode := Graphics.PixelOffsetMode::HighQuality;
        Graphics.DrawImage(Image, Rectangle);
        Graphics.Dispose();

        EncodeToImage(BitmapDst);
        BitmapDst.Dispose();
    end;

    procedure ToBase64(): Text
    var
        Base64Converter: Codeunit "Base64 Convert";
        InStream: InStream;
    begin
        TempBlob.CreateInStream(InStream);
        exit(Base64Converter.ToBase64(InStream));
    end;

    procedure FromBase64(Base64Text: Text)
    var
        Base64Converter: Codeunit "Base64 Convert";
        Outstream: OutStream;
        InStream: InStream;
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        Base64Converter.FromBase64(Base64Text, OutStream);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        CreateAndVerifyImage(InStream);
    end;

    procedure FromStream(InStream: InStream)
    var
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream);
        CopyStream(OutStream, InStream);
        CreateAndVerifyImage(InStream);
    end;

    procedure GetFormat(): Enum "Image Format"
    var
        Format: DotnEt ImageFormat;
        Image: DotNet Image;
        EnumFormat: Enum "Image Format";
        InStream: InStream;
    begin
        TempBlob.CreateInStream(InStream);
        Image := Image.FromStream(InStream);

        Format := Image.RawFormat();
        if Format.Equals(Image.RawFormat.Bmp()) then
            exit(EnumFormat::Bmp);
        if Format.Equals(Image.RawFormat.Emf()) then
            exit(EnumFormat::Emf);
        if Format.Equals(Image.RawFormat.Exif()) then
            exit(EnumFormat::Exif);
        if Format.Equals(Image.RawFormat.Gif()) then
            exit(EnumFormat::Gif);
        if Format.Equals(Image.RawFormat.Icon()) then
            exit(EnumFormat::Icon);
        if Format.Equals(Image.RawFormat.Jpeg()) then
            exit(EnumFormat::Jpeg);
        if Format.Equals(Image.RawFormat.Png()) then
            exit(EnumFormat::Png);
        if Format.Equals(Image.RawFormat.Tiff()) then
            exit(EnumFormat::Tiff);
        if Format.Equals(Image.RawFormat.Wmf()) then
            exit(EnumFormat::Wmf);

        Error(UnsupportedFormatErr);
    end;

    procedure GetFormatAsString(): Text
    var
        FormatConverter: DotNet ImageFormatConverter;
        Image: DotNet Image;
        InStream: InStream;
    begin
        TempBlob.CreateInStream(InStream);
        Image := Image.FromStream(InStream);
        FormatConverter := FormatConverter.ImageFormatConverter();
        exit(FormatConverter.ConvertToString(Image.RawFormat()));
    end;

    procedure GetWidth(): Integer
    var
        Image: DotNet Image;
        InStream: InStream;
    begin
        TempBlob.CreateInStream(InStream);
        Image := Image.FromStream(InStream);
        exit(Image.Width());
    end;

    procedure GetHeight(): Integer
    var
        Image: DotNet Image;
        InStream: InStream;
    begin
        TempBlob.CreateInStream(InStream);
        Image := Image.FromStream(InStream);
        exit(Image.Height());
    end;

    procedure Save(OutStream: OutStream)
    var
        InStream: InStream;
    begin
        TempBlob.CreateInStream(InStream);
        CopyStream(OutStream, InStream);
    end;

    local procedure CreateAndVerifyImage(InStream: InStream)
    var
        Image: DotNet Image;
        Size, Width, Height : Integer;
    begin
        if TempBlob.Length() > 5000000 then begin
            Session.LogMessage('0000FMA', StrSubstNo(ImageToLargeTxt, TempBlob.Length()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ImageCatTxt);
            Clear(TempBlob);
            Error(ImageToLargeErr);
        end;

        if not CreateImage(Image, InStream) then begin
            Session.LogMessage('0000FMB', FormatTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ImageCatTxt);
            Clear(TempBlob);
            Error(FormatErr);
        end;

        SetCodec(Image, ImageCodec);

        Size := TempBlob.Length();
        Width := GetWidth();
        Height := GetHeight();
        Session.LogMessage('0000FLP', StrSubstNo(ImageCreatedTxt, Size, Width, Height, GetFormatAsString()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ImageCatTxt);

    end;

    [TryFunction]
    local procedure CreateImage(var Image: DotNet Image; InStream: InStream)
    begin
        Image := Image.FromStream(InStream);
    end;

    local procedure SetCodec(Image: DotNet Image; var LocalImageCodec: DotNet ImageCodecInfo)
    var
        Codecs: DotNet ArrayList;
        Codec: DotNet ImageCodecInfo;
    begin
        Codecs := Codec.GetImageEncoders();
        foreach Codec in Codecs do
            if Image.RawFormat.Guid() = Codec.FormatID then
                LocalImageCodec := Codec;
    end;

    local procedure EncodeToImage(Bitmap: DotNet Bitmap)
    var
        EncoderParameters: Dotnet EncoderParameters;
        EncoderParameterArray: DotNet Array;
        EncoderParameter: DotNet EncoderParameter;
        Encoder: DotNet Encoder;
        OutStream: OutStream;
    begin
        Encoder := Encoder.Encoder(QualityEncodeGuidTxt);
        EncoderParameter := EncoderParameter.EncoderParameter(Encoder, 100);

        EncoderParameterArray := EncoderParameterArray.CreateInstance(GetDotNetType(EncoderParameter), 1);
        EncoderParameterArray.SetValue(EncoderParameter, 0);

        EncoderParameters := EncoderParameters.EncoderParameters(1);
        EncoderParameters.Param := EncoderParameterArray;

        TempBlob.CreateOutStream(OutStream);
        Bitmap.Save(OutStream, ImageCodec, EncoderParameters);
    end;

}