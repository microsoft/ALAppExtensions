// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Utilities;

using System.Text;
using System.Utilities;
using System.TestLibraries.Utilities;

codeunit 135135 "Image Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        Base64Convert: Codeunit "Base64 Convert";
        ImageNotInitializedErr: Label 'The image could not be loaded';
        ImageAsBase64Txt: Label 'iVBORw0KGgoAAAANSUhEUgAAAAoAAAAFCAYAAAB8ZH1oAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAhSURBVBhXYwCC/0RirILYMIIDAtjYUIzCwYexCqJhhv8AD/M3yc4WsFgAAAAASUVORK5CYII=', Locked = true;
        RotatedImageAsBase64Txt: Label 'iVBORw0KGgoAAAANSUhEUgAAAAUAAAAKCAYAAAB8OZQwAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAdSURBVBhXYwCC/1gwqYIggCGIhvEIUqgdgRn+AwCbbDfJSYc2FAAAAABJRU5ErkJggq5CYII=', Locked = true;
        ImageAsBase64ClearTxt: Label 'iVBORw0KGgoAAAANSUhEUgAAAAoAAAAFCAYAAAB8ZH1oAAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAAOwgAADsIBFShKgAAAABRJREFUGFdj+M/A8J8YPPgVMvwHAOUMY51Bb2wGAAAAAElFTkSuQmCCCqJhhv8AD/M3yc4WsFgAAAAASUVORK5CYII=', Locked = true;
        ImageInvalidTxt: Label 'CjwvZz4KPC9zdmc+Cg==';

    [Test]
    procedure CreateImageFromStreamTest()
    var
        Image: Codeunit Image;
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
    var
        Image: Codeunit Image;
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
        Image: Codeunit Image;
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
    var
        Image: Codeunit Image;
    begin
        // [Given] bad base64 encoded data, fail to create image 
        asserterror Image.FromBase64(ImageInvalidTxt);
        Assert.ExpectedError('Image is not in valid format');
    end;

    [Test]
    procedure ConvertToBase64Test()
    var
        Image: Codeunit Image;
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
        Image: Codeunit Image;
        Format: Enum "Image Format";
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [Then] verify format
        Assert.AreEqual(Format::Png, Image.GetFormat(), 'Format failed');
    end;

    [Test]
    procedure SetFormatTest()
    var
        Image: Codeunit Image;
        Format: Enum "Image Format";
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [When] change the format to Jpeg without any errors
        Image.SetFormat(Format::Jpeg);

        // [Then] verify format
        Assert.AreEqual(Format::Jpeg, Image.GetFormat(), 'Changing format failed');
    end;

    [Test]
    procedure GetFormatAsTextTest()
    var
        Image: Codeunit Image;
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
    var
        Image: Codeunit Image;
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [Then] verify dimensions
        Assert.AreEqual(10, Image.GetWidth(), 'Incorrect width');
        Assert.AreEqual(5, Image.GetHeight(), 'Incorrect height');
    end;

    [Test]
    procedure ClearTest()
    var
        Image: Codeunit Image;
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        CurrentWidth, CurrentHeight : Integer;
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);
        CurrentWidth := Image.GetWidth();
        CurrentHeight := Image.GetHeight();

        // [When] clearing image
        Image.Clear(255, 0, 0);

        // [Then] verify image
        Assert.AreEqual(CurrentWidth, Image.GetWidth(), 'Incorrect width');
        Assert.AreEqual(CurrentHeight, Image.GetHeight(), 'Incorrect height');
        Assert.AreEqual(ImageAsBase64ClearTxt, Image.ToBase64(), 'Clear failed');

        // [Then] save to stream
        TempBlob.CreateOutStream(OutStream);
        Image.Save(OutStream);
        Assert.AreNotEqual(0, TempBlob.Length(), 'Image was not saved');
    end;

    [Test]
    procedure InvalidClearTest()
    var
        Image: Codeunit Image;
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [Then] Fail to do invalid resizing 
        asserterror Image.Clear(-1, 0, 0);
        Assert.ExpectedError('The Red parameter must be between 0 and 255');
    end;

    [Test]
    procedure ResizeTest()
    var
        Image: Codeunit Image;
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
    var
        Image: Codeunit Image;
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [Then] Fail to do invalid resizing 
        asserterror Image.Resize(-1, 5);
        Assert.ExpectedError('Parameter Width must be greater than 0');
    end;

    [Test]
    procedure RotateFlipTest()
    var
        Image: Codeunit Image;
        TempBlob: Codeunit "Temp Blob";
        RotateFlipType: Enum "Rotate Flip Type";
        OutStream: OutStream;
        CurrentWidth, CurrentHeight : Integer;
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);
        CurrentWidth := Image.GetWidth();
        CurrentHeight := Image.GetHeight();

        // [When] rotate image 90 degrees
        Image.RotateFlip(RotateFlipType::Rotate90FlipNone);

        // [Then] verify image
        Assert.AreEqual(CurrentHeight, Image.GetWidth(), 'The width after rotating should be equal to the height before rotating');
        Assert.AreEqual(CurrentWidth, Image.GetHeight(), 'The height after rotating should be equal to the width before rotating');
        Assert.AreEqual(RotatedImageAsBase64Txt, Image.ToBase64(), 'Image Base64 does not match');

        // [Then] save to stream
        TempBlob.CreateOutStream(OutStream);
        Image.Save(OutStream);
        Assert.AreNotEqual(0, TempBlob.Length(), 'Image was not saved');
    end;

    [Test]
    procedure RotateFlip360Test()
    var
        Image: Codeunit Image;
        TempBlob: Codeunit "Temp Blob";
        RotateFlipType: Enum "Rotate Flip Type";
        OutStream: OutStream;
        CurrentWidth, CurrentHeight : Integer;
        OriginalImageBase64Txt, RotatedImageBase64Txt : Text;
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // Rotate image first to set the encoding right
        OriginalImageBase64Txt := Image.ToBase64();
        CurrentWidth := Image.GetWidth();
        CurrentHeight := Image.GetHeight();

        // [When] rotate image 360 degrees more
        Image.RotateFlip(RotateFlipType::Rotate90FlipNone);
        Image.RotateFlip(RotateFlipType::Rotate90FlipNone);
        Image.RotateFlip(RotateFlipType::Rotate90FlipNone);
        Image.RotateFlip(RotateFlipType::Rotate90FlipNone);

        RotatedImageBase64Txt := Image.ToBase64();

        // [Then] verify image
        Assert.AreEqual(CurrentWidth, Image.GetWidth(), 'The width should not have changed');
        Assert.AreEqual(CurrentHeight, Image.GetHeight(), 'The height should not have changed');
        Assert.AreEqual(OriginalImageBase64Txt, RotatedImageBase64Txt, 'The image should not have changed after rotating 360 degrees');

        // [Then] save to stream
        TempBlob.CreateOutStream(OutStream);
        Image.Save(OutStream);
        Assert.AreNotEqual(0, TempBlob.Length(), 'Image was not saved');
    end;

    [Test]
    procedure CropTest()
    var
        Image: Codeunit Image;
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
    var
        Image: Codeunit Image;
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [Then] fail cropping image with invalid parameters
        asserterror Image.Crop(0, 0, 0, 0);
        Assert.ExpectedError('Parameter Width must be greater than 0');
    end;

    [Test]
    procedure ImageNotInitializedTest()
    var
        Image: Codeunit Image;
        TempBlob: Codeunit "Temp Blob";
        ImageOutStream: OutStream;
    begin
        // [Scenario] Errors occur when working with an image that has not been initialized.

        // [Given] Image is not initialized

        // [Then] An error occurs when getting the image width
        asserterror Image.GetWidth();
        Assert.ExpectedError(ImageNotInitializedErr);

        // [Then] An error occurs when getting the image height
        asserterror Image.GetHeight();
        Assert.ExpectedError(ImageNotInitializedErr);

        // [Then] An error occurs when getting the image format
        asserterror Image.GetFormat();
        Assert.ExpectedError(ImageNotInitializedErr);

        // [Then] An error occurs when getting the image format as text
        asserterror Image.GetFormatAsText();
        Assert.ExpectedError(ImageNotInitializedErr);

        // [Then] An error occurs when croping the image
        asserterror Image.Crop(1, 1, 1, 1);
        Assert.ExpectedError(ImageNotInitializedErr);

        // [Then] An error occurs when resizing the image
        asserterror Image.Resize(1, 1);
        Assert.ExpectedError(ImageNotInitializedErr);

        // [Then] An error occurs when rotating the image
        asserterror Image.RotateFlip(Enum::"Rotate Flip Type"::Rotate270FlipNone);
        Assert.ExpectedError(ImageNotInitializedErr);

        // [Then] The stream is empty when the image is saved
        TempBlob.CreateOutStream(ImageOutStream);
        Image.Save(ImageOutStream);
        Assert.IsFalse(TempBlob.HasValue(), 'Image should be empty');
    end;

    [Test]
    procedure CheckRotateFlipTypeForNoneRotatedImage()
    var
        Image: Codeunit Image;
        NoneRotatedImageAsBase64Txt: Label '/9j/4AAQSkZJRgABAQEA3ADcAAD/4QAiRXhpZgAASUkqAAgAAAABABIBAwABAAAAAQAAAAAAAAD/4gJgSUNDX1BST0ZJTEUAAQEAAAJQbGNtcwQwAABtbnRyUkdCIFhZWiAH3wAFAAsADAATACZhY3NwQVBQTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA9tYAAQAAAADTLWxjbXMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAtkZXNjAAABCAAAADhjcHJ0AAABQAAAAE53dHB0AAABkAAAABRjaGFkAAABpAAAACxyWFlaAAAB0AAAABRiWFlaAAAB5AAAABRnWFlaAAAB+AAAABRyVFJDAAACDAAAACBnVFJDAAACDAAAACBiVFJDAAACDAAAACBjaHJtAAACLAAAACRtbHVjAAAAAAAAAAEAAAAMZW5VUwAAABwAAAAcAHMAUgBHAEIAIABiAHUAaQBsAHQALQBpAG4AAG1sdWMAAAAAAAAAAQAAAAxlblVTAAAAMgAAABwATgBvACAAYwBvAHAAeQByAGkAZwBoAHQALAAgAHUAcwBlACAAZgByAGUAZQBsAHkAAAAAWFlaIAAAAAAAAPbWAAEAAAAA0y1zZjMyAAAAAAABDEoAAAXj///zKgAAB5sAAP2H///7ov///aMAAAPYAADAlFhZWiAAAAAAAABvlAAAOO4AAAOQWFlaIAAAAAAAACSdAAAPgwAAtr5YWVogAAAAAAAAYqUAALeQAAAY3nBhcmEAAAAAAAMAAAACZmYAAPKnAAANWQAAE9AAAApbY2hybQAAAAAAAwAAAACj1wAAVHsAAEzNAACZmgAAJmYAAA9c/9sAQwAGBAUGBQQGBgUGBwcGCAoQCgoJCQoUDg8MEBcUGBgXFBYWGh0lHxobIxwWFiAsICMmJykqKRkfLTAtKDAlKCko/8AACwgAUAAwAQERAP/EABYAAQEBAAAAAAAAAAAAAAAAAAAJCP/EABQQAQAAAAAAAAAAAAAAAAAAAAD/2gAIAQEAAD8AyoAAAAKqAJViqgCVYCqglWAqoJViqgCVYqoAlWKqAJViqgD/2Q==', Locked = true; //image taken from https://magnushoff.com/articles/jpeg-orientation/
    begin
        // [Scenario] Check Rotate Flip Type for none rotated image

        // [Given] base64 encoded data, create image
        Image.FromBase64(NoneRotatedImageAsBase64Txt);

        // [Then] verify image rotate flip type
        Assert.AreEqual("Rotate Flip Type"::RotateNoneFlipNone, Image.GetRotateFlipType(), 'Getting Rotation Type failed');
    end;

    [Test]
    procedure CheckRotateFlipTypeFor90DegreesRotatedImage()
    var
        Image: Codeunit Image;
        Rotated90AsBase64Txt: Label '/9j/4AAQSkZJRgABAQEA3ADcAAD/4QAiRXhpZgAASUkqAAgAAAABABIBAwABAAAABgAAAAAAAAD/2wBDAAYFBAQFBgYFBgYKCAYHBwoJCQoKEBQXEAwPDhQdGhYWFBcYGBYcIxsaHyUmIyAsIBYZKSopJy0wLR8lMCgpKCj/wAALCAAwAFABAREA/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/9oACAEBAAA/APlSiv1Uooooooor8q6K/VSiiiiiiivyror9VKK/Kuiv1Uooor8q6K/VSivyror9VKKKK/Kuiiiiiiiiiiiiiiiiiiiv/9k=', Locked = true; //image taken from https://magnushoff.com/articles/jpeg-orientation/
    begin
        // [Scenario] Check Rotate Flip Type for 90 degrees rotated image

        // [Given] base64 encoded data rotated 90 degrees, create image
        Image.FromBase64(Rotated90AsBase64Txt);

        // [Then] verify image rotate flip type
        Assert.AreEqual("Rotate Flip Type"::Rotate90FlipNone, Image.GetRotateFlipType(), 'Getting Rotation Type failed');
    end;

    [Test]
    procedure CheckRotateFlipTypeFor180DegreesRotatedImage()
    var
        Image: Codeunit Image;
        Rotated180AsBase64Txt: Label '/9j/4AAQSkZJRgABAQEA3ADcAAD/4QAiRXhpZgAASUkqAAgAAAABABIBAwABAAAAAwAAAAAAAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/wAALCABQADABAREA/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/9oACAEBAAA/APqmiiivyror9VKKKK/Kuiv1Uooor8q6K/VSiiivyror9VKK/Kuiiiv1Uor8q6KKK/VSiiivyror9VKKKK/Kuiiiiiiiiiiiiiv/2Q==', Locked = true; //image taken from https://magnushoff.com/articles/jpeg-orientation/
    begin
        // [Scenario] Check Rotate Flip Type for 180 degrees rotated image

        // [Given] base64 encoded data rotated 180 degrees, create image
        Image.FromBase64(Rotated180AsBase64Txt);

        // [Then] verify image rotate flip type
        Assert.AreEqual("Rotate Flip Type"::Rotate180FlipNone, Image.GetRotateFlipType(), 'Getting Rotation Type failed');
    end;

    [Test]
    procedure CheckRotateFlipTypeFor270DegreesRotatedImage()
    var
        Image: Codeunit Image;
        Rotated270AsBase64Txt: Label '/9j/4AAQSkZJRgABAQEA3ADcAAD/4QAiRXhpZgAASUkqAAgAAAABABIBAwABAAAACAAAAAAAAAD/2wBDAAYFBAQFBgYFBgYKCAYHBwoJCQoKEBQXEAwPDhQdGhYWFBcYGBYcIxsaHyUmIyAsIBYZKSopJy0wLR8lMCgpKCj/wAALCAAwAFABAREA/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/9oACAEBAAA/APlSiiiiiiiiiiiiiiiiiiiv1Uooor8q6K/VSivyror9VKKKK/Kuiv1Uor8q6K/VSiiiiiiivyror9VKKKKKKKK/Kuiv/9k=', Locked = true; //image taken from https://magnushoff.com/articles/jpeg-orientation/
    begin
        // [Scenario] Check Rotate Flip Type for 270 degrees rotated image

        // [Given] base64 encoded data rotated 270 degrees, create image
        Image.FromBase64(Rotated270AsBase64Txt);

        // [Then] verify image rotate flip type
        Assert.AreEqual("Rotate Flip Type"::Rotate270FlipNone, Image.GetRotateFlipType(), 'Getting Rotation Type failed');
    end;

    [Test]
    procedure CheckRotateFlipTypeForHorizontalFlippedImage()
    var
        Image: Codeunit Image;
        FlippedAsBase64Txt: Label '/9j/4AAQSkZJRgABAQEA3ADcAAD/4QAiRXhpZgAASUkqAAgAAAABABIBAwABAAAAAgAAAAAAAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/wAALCABQADABAREA/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/9oACAEBAAA/APlSiiiiiiiiiiiv1Uooor8q6K/VSiiivyror9VKK/Kuiiiv1Uor8q6KKK/VSiiivyror9VKKKK/Kuiv1Uooor8q6K/VSiiivyror//Z', Locked = true; //image taken from https://magnushoff.com/articles/jpeg-orientation/
    begin
        // [Scenario] Check Rotate Flip Type for horizontal flipped image

        // [Given] base64 encoded data flipped, create image
        Image.FromBase64(FlippedAsBase64Txt);

        // [Then] verify image rotate flip type
        Assert.AreEqual("Rotate Flip Type"::RotateNoneFlipX, Image.GetRotateFlipType(), 'Getting Rotation Type failed');
    end;

    [Test]
    procedure CheckRotateFlipTypeForHorizontalFlippedAnd90DegreesRotatedImage()
    var
        Image: Codeunit Image;
        FlippedAndRotated90AsBase64Txt: Label '/9j/4AAQSkZJRgABAQEA3ADcAAD/4QAiRXhpZgAASUkqAAgAAAABABIBAwABAAAABQAAAAAAAAD/2wBDAAYFBAQFBgYFBgYKCAYHBwoJCQoKEBQXEAwPDhQdGhYWFBcYGBYcIxsaHyUmIyAsIBYZKSopJy0wLR8lMCgpKCj/wAALCAAwAFABAREA/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/9oACAEBAAA/APlSiiiiiiiiiiiiiiiiiiiiiv1Uor8q6K/VSiiivyror9VKK/Kuiv1Uooor8q6K/VSiiiiiiivyror9VKKKKKKKK//Z', Locked = true; //image taken from https://magnushoff.com/articles/jpeg-orientation/
    begin
        // [Scenario] Check Rotate Flip Type for horizontal flipped and 90 degrees rotated image

        // [Given] base64 encoded data flipped and rotated 90 degrees, create image
        Image.FromBase64(FlippedAndRotated90AsBase64Txt);

        // [Then] verify image rotate flip type
        Assert.AreEqual("Rotate Flip Type"::Rotate90FlipX, Image.GetRotateFlipType(), 'Getting Rotation Type failed');
    end;

    [Test]
    procedure CheckRotateFlipTypeForHorizontalFlippedAnd180DegreesRotatedImage()
    var
        Image: Codeunit Image;
        FlippedAndRotated180AsBase64Txt: Label '/9j/4AAQSkZJRgABAQEA3ADcAAD/4QAiRXhpZgAASUkqAAgAAAABABIBAwABAAAABAAAAAAAAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/wAALCABQADABAREA/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/9oACAEBAAA/APlSiv1Uooor8q6K/VSiiivyror9VKKKK/Kuiv1Uooor8q6KKK/VSivyrooor9VKK/Kuiv1Uooor8q6K/VSiiivyrooooooooooor//Z', Locked = true; //image taken from https://magnushoff.com/articles/jpeg-orientation/
    begin
        // [Scenario] Check Rotate Flip Type for horizontal flipped and 180 degrees rotated image

        // [Given] base64 encoded data flipped and rotated 180 degrees, create image
        Image.FromBase64(FlippedAndRotated180AsBase64Txt);

        // [Then] verify image rotate flip type
        Assert.AreEqual("Rotate Flip Type"::Rotate180FlipX, Image.GetRotateFlipType(), 'Getting Rotation Type failed');
    end;

    [Test]
    procedure CheckRotateFlipTypeForHorizontalFlippedAnd270DegreesRotatedImage()
    var
        Image: Codeunit Image;
        FlippedAndRotated270AsBase64Txt: Label '/9j/4AAQSkZJRgABAQEA3ADcAAD/4QAiRXhpZgAASUkqAAgAAAABABIBAwABAAAABwAAAAAAAAD/2wBDAAYFBAQFBgYFBgYKCAYHBwoJCQoKEBQXEAwPDhQdGhYWFBcYGBYcIxsaHyUmIyAsIBYZKSopJy0wLR8lMCgpKCj/wAALCAAwAFABAREA/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/9oACAEBAAA/APqmiiiiiiivyror9VKKKKKKKK/Kuiv1Uooor8q6K/VSivyror9VKKKK/Kuiv1Uor8q6KKKKKKKKKKKKKKKKKKKKK//Z', Locked = true; //image taken from https://magnushoff.com/articles/jpeg-orientation/
    begin
        // [Scenario] Check Rotate Flip Type for horizontal flipped and 270 degrees rotated image

        // [Given] base64 encoded data flipped and rotated 270 degrees, create image
        Image.FromBase64(FlippedAndRotated270AsBase64Txt);

        // [Then] verify image rotate flip type
        Assert.AreEqual("Rotate Flip Type"::Rotate270FlipX, Image.GetRotateFlipType(), 'Getting Rotation Type failed');
    end;
}