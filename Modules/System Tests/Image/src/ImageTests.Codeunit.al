// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135135 "Image Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Image: Codeunit Image;
        Assert: Codeunit "Library Assert";
        Base64Convert: Codeunit "Base64 Convert";
        ImageAsBase64Txt: Label 'iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAIAAAACUFjqAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAOSURBVChTYxgFJAMGBgABNgABY8OiGAAAAABJRU5ErkJggg==';
        ImageInvalidTxt: Label 'CjwvZz4KPC9zdmc+Cg==';

    [Test]
    procedure CreateImageFromStreamTest()
    var
        ImageBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
    begin
        // [Given] A Base64 encoded image convert it to a stream
        ImageBlob.CreateOutStream(OutStream);
        Base64Convert.FromBase64(ImageAsBase64Txt, OutStream);
        ImageBlob.CreateInStream(InStream);

        // [When] Reads valid stream data
        ClearLastError();
        Image.FromStream(InStream);

        // [Then] verify no error occurred
        Assert.AreEqual('', GetLastErrorText(), 'No error should have occurred');
    end;

    [Test]
    procedure CreateImageFromBase64Test()
    begin
        // [Given] base64 encoded data create image 
        ClearLastError();
        Image.FromBase64(ImageAsBase64Txt);

        // [Then] verify no error occurred
        Assert.AreEqual('', GetLastErrorText(), 'No error should have occurred');
    end;

    [Test]
    procedure FailToCreateImageTest()
    var
        ImageBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
    begin
        // [Given] A invalid image convert it to a stream. 
        ImageBlob.CreateOutStream(OutStream);
        OutStream.Write(ImageInvalidTxt);
        ImageBlob.CreateInStream(InStream);

        // [Then] Read stream and fail as image data is invalid
        asserterror Image.FromStream(InStream);
        Assert.ExpectedError('Image is not in valid format');
    end;

    [Test]
    procedure FailToCreateBase64ImageTest()
    begin
        // [Given] bad base64 encoded data, fail to create image 
        asserterror Image.FromBase64(ImageInvalidTxt);
        Assert.ExpectedError('Image is not in valid format');
    end;

    [Test]
    procedure ConvertToBase64Test()
    var
        Base64Text: Text;
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [When] decode image back to base64 without any errors
        // Note: The encoding is not the same each time, and that is why we dont compare it to the input
        ClearLastError();
        Base64Text := Image.ToBase64();

        // [Then] verify no error occurred
        Assert.AreEqual('', GetLastErrorText(), 'No error should have occurred');
    end;

    [Test]
    procedure GetFormatTest()
    var
        Format: Enum "Image Format";
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [Then] verify format
        Assert.AreEqual(Format::Png, Image.GetFormat(), 'Format failed');
    end;

    [Test]
    procedure GetFormatAsTextTest()
    var
        FormatText: Text;
    begin
        // [Given] base64 encoded data, create image
        FormatText := 'Png';
        Image.FromBase64(ImageAsBase64Txt);

        // [Then] verify string formatted format
        Assert.AreEqual(FormatText, Image.GetFormatAsText(), 'Format failed');
    end;

    [Test]
    procedure GetDimensionsTest()
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [Then] verify dimensions
        Assert.AreEqual(10, Image.GetWidth(), 'Incorrect width');
        Assert.AreEqual(10, Image.GetHeight(), 'Incorrect height');
    end;

    [Test]
    procedure ResizeTest()
    var
        TempBlob: Codeunit "Temp Blob";
        Format: Enum "Image Format";
        OutStream: OutStream;
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [When] resizing image
        Image.Resize(5, 5);

        // [Then] verify dimensions and format
        Assert.AreEqual(5, Image.GetWidth(), 'Incorrect width');
        Assert.AreEqual(5, Image.GetHeight(), 'Incorrect height');
        Assert.AreEqual(Format::Png, Image.GetFormat(), 'Format failed');

        // [Then] save to stream
        TempBlob.CreateOutStream(OutStream);
        Image.Save(OutStream);
        Assert.AreNotEqual(0, TempBlob.Length(), 'Image was not saved');
    end;

    [Test]
    procedure InvalidResizeTest()
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [Then] Fail to do invalid resizing 
        asserterror Image.Resize(-1, 5);
        Assert.ExpectedError('Parameter Width must be greater than 0');
    end;

    [Test]
    procedure CropTest()
    var
        TempBlob: Codeunit "Temp Blob";
        Format: Enum "Image Format";
        OutStream: OutStream;
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [When] cropping image
        Image.Crop(5, 5, 5, 5);

        // [Then] verify dimensions and format
        Assert.AreEqual(5, Image.GetWidth(), 'Incorrect width');
        Assert.AreEqual(5, Image.GetHeight(), 'Incorrect height');
        Assert.AreEqual(Format::Png, Image.GetFormat(), 'Format failed');

        // [Then] save to stream
        TempBlob.CreateOutStream(OutStream);
        Image.Save(OutStream);
        Assert.AreNotEqual(0, TempBlob.Length(), 'Image was not saved');
    end;

    [Test]
    procedure InvalidCropTest()
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [Then] fail cropping image with invalid parameters
        asserterror Image.Crop(0, 0, 0, 0);
        Assert.ExpectedError('Parameter Width must be greater than 0');
    end;

}