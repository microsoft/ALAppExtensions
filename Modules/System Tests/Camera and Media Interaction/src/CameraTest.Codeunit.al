// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Device;

using System.Device;
using System.TestLibraries.Device;
using System.Text;
using System.TestLibraries.Utilities;

codeunit 135011 "Camera Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    [Scope('OnPrem')]
    procedure IsCameraAvailableTest()
    var
        Camera: Codeunit Camera;
        CameraTestLibrary: Codeunit "Camera Test Library";
    begin
        // [When] Camera test library subscribers are bound.
        BindSubscription(CameraTestLibrary);

        // [Then] The return value of IsAvailable method is 'true'.
        Assert.IsTrue(Camera.IsAvailable(), 'The camera should be available during testing.');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('CameraPageHandler')]
    procedure GetPictureTest()
    var
        Camera: Codeunit Camera;
        CameraTestLibrary: Codeunit "Camera Test Library";
        Base64Convert: Codeunit "Base64 Convert";
        PictureInStream: InStream;
        PictureName: Text;
        WasGettingThePictureSuccessful: Boolean;
    begin
        // [Given] Camera test library subscribers are bound.
        BindSubscription(CameraTestLibrary);

        // [When] GetPicture is invoked on the camera object.
        WasGettingThePictureSuccessful := Camera.GetPicture(PictureInStream, PictureName);

        // [Then] The mock picture was retrieved successfully.
        Assert.IsTrue(WasGettingThePictureSuccessful, 'Getting a picture from camera should always be successful in tests.');

        // [Then] The name of the picture includes the current date in the format <Day,2>_<Month,2>_<Year4>.
        // Note: the actual name will also include the current time,
        /// but not checking for it as the current second can potentially change during the test execution.
        Assert.IsTrue(PictureName.Contains(Format(CurrentDateTime(), 0, '<Day,2>_<Month,2>_<Year4>')), 'The picture name should include the current date.');

        // [Then] The picture has extension *.jpeg.
        Assert.IsTrue(PictureName.EndsWith('.jpeg'), 'The picture was expected to have extension *.jpeg.');

        // [Then] The InStream object contains the original picture.
        Assert.AreEqual(CameraTestLibrary.GetSmallJpeg(), Base64Convert.ToBase64(PictureInStream), 'The mock picture was expected.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetPictureWithQualityErrorTest()
    var
        Camera: Codeunit Camera;
        CameraTestLibrary: Codeunit "Camera Test Library";
        PictureInStream: InStream;
        PictureName: Text;
        Quality: Integer;
    begin
        // [Given] Camera test library subscribers are bound.
        BindSubscription(CameraTestLibrary);

        // [GIVEN] Invalid Quality
        Quality := 200;

        // [When] GetPicture is invoked on the camera object.
        ClearLastError();
        asserterror Camera.GetPicture(Quality, PictureInStream, PictureName);

        // [Then] An error is shown about an invalid value for the quality
        Assert.ExpectedError('The picture quality must be in the range from 0 to 100.');
    end;

    [ModalPageHandler]
    procedure CameraPageHandler(var CameraPage: TestPage Camera)
    begin
        // Do nothing
    end;
}
