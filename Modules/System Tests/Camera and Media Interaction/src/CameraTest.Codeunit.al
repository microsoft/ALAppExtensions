// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
        // [When] Camera test library subscribers are binded.
        BindSubscription(CameraTestLibrary);

        // [Then] The return value of IsAvailabale method is 'true'.
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
        // [Given] Camera test library subscribers are binded.
        BindSubscription(CameraTestLibrary);

        // [When] GetPicture is invoked on the camera object.
        WasGettingThePictureSuccessful := Camera.GetPicture(PictureInStream, PictureName);

        // [Then] The mock picture was retrieved successfuly.
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

#if not CLEAN20
    [Test]
    [Scope('OnPrem')]
    procedure AddPictureErrorsTest()
    var
        TableWithMedia: Record "Table With Media";
        Camera: Codeunit Camera;
        CameraTestLibrary: Codeunit "Camera Test Library";
        NonRecordVariable: Text;
        ArbitraryFildNo: Integer;
    begin
        // [Given] Camera test library subscribers are binded.
        BindSubscription(CameraTestLibrary);
        ArbitraryFildNo := 123;

        // [When] AddPicture is invoked with the first parameter that is not a record.
        ClearLastError();
        asserterror Camera.AddPicture(NonRecordVariable, ArbitraryFildNo);
        // [Then] An error is shown about not being able to convert types.
        Assert.ExpectedError('Unable to convert from Microsoft.Dynamics.Nav.Runtime.NavText');

        // [When] AddPicture is invoked with the first parameter of type 'Record', but non-existent field number.
        ClearLastError();
        asserterror Camera.AddPicture(TableWithMedia, ArbitraryFildNo);
        // [Then] The error is: 'Non-existent field'.
        Assert.ExpectedError('The supplied field number ''123'' cannot be found in the ''Table With Media'' table.');

        // [When] AddPicture is invoked with the first parameter of type 'Record', existent field number,
        // but the field is not of the type 'Media'.
        ClearLastError();
        asserterror Camera.AddPicture(TableWithMedia, TableWithMedia.FieldNo("Primary Key"));
        // [Then] The error is: 'The provided field must be of type ''Media''.'.
        Assert.ExpectedError('The field type');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('CameraPageHandler')]
    procedure AddPictureSuccessfullyMediaTest()
    var
        TableWithMedia: Record "Table With Media";
        Camera: Codeunit Camera;
        CameraTestLibrary: Codeunit "Camera Test Library";
        Base64Conver: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        PictureOutStream: OutStream;
        PictureInStream: InStream;
        WasAddingThePictureSuccessful: Boolean;
    begin
        // [Given] Camera test library subscribers are binded.
        BindSubscription(CameraTestLibrary);

        // [When] AddPicture is invoked with all the correct parameters.
        TableWithMedia."Primary Key" := 1;
        WasAddingThePictureSuccessful := Camera.AddPicture(TableWithMedia, TableWithMedia.FieldNo(Media));

        // [Then] The mock picture was added successfuly.
        Assert.IsTrue(WasAddingThePictureSuccessful, 'Adding a picture from camera should always be successful in tests.');

        // [Then] The Media field has value.
        TableWithMedia.Find(); // it's impossible to pass Variant as a reference, so we need to find the reocrd.
        Assert.IsTrue(TableWithMedia.Media.HasValue, 'The Media field should have its content filled.');

        // [Then] The new record contains the mock picture.
        TempBlob.CreateOutStream(PictureOutStream);
        TableWithMedia.Media.ExportStream(PictureOutStream);
        TempBlob.CreateInStream(PictureInStream);
        Assert.AreEqual(CameraTestLibrary.GetSmallJpeg(), Base64Conver.ToBase64(PictureInStream), 'The mock picture was expected.');

        // [Then] The new record is inserted into the database.
        TableWithMedia.Reset();
        Assert.AreEqual(1, TableWithMedia.Count(), 'Exactly one record was expected to be in the database.');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('CameraPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AddPictureSuccessfullyMediaSetTest()
    var
        TableWithMedia: Record "Table With Media";
        Camera: Codeunit Camera;
        CameraTestLibrary: Codeunit "Camera Test Library";
        Base64Convert: Codeunit "Base64 Convert";
        FileInStream: InStream;
        ImageFile: File;
        WasAddingThePictureSuccessful: Boolean;
    begin
        // [Given] Camera test library subscribers are binded.
        BindSubscription(CameraTestLibrary);

        // [When] AddPicture is invoked with all the correct parameters.
        TableWithMedia."Primary Key" := 1;
        WasAddingThePictureSuccessful := Camera.AddPicture(TableWithMedia, TableWithMedia.FieldNo(MediaSetField));

        // [Then] The mock picture was added successfuly.
        Assert.IsTrue(WasAddingThePictureSuccessful, 'Adding a picture from camera should always be successful in tests.');

        // [Then] The MediaSet field has value.
        TableWithMedia.Find(); // it's impossible to pass Variant as a reference, so we need to find the reocrd.
        Assert.AreEqual(1, TableWithMedia.MediaSetField.Count(), 'The MediaSet field should have one Media object in it.');

        // Get the value in the MediaSet through a file
        TableWithMedia.MediaSetField.ExportFile('test.jpg');
        ImageFile.Open('test-1.jpg');
        ImageFile.CreateInStream(FileInStream);

        // [Then] The content of the MediaSet is as expected
        Assert.AreEqual(CameraTestLibrary.GetSmallJpeg(), Base64Convert.ToBase64(FileInStream), 'The mock picture was expected.');

        // [Then] The new record is inserted into the database.
        TableWithMedia.Reset();
        Assert.AreEqual(1, TableWithMedia.Count(), 'Exactly one record was expected to be in the database.');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('CameraPageHandler,ConfirmDialogHandlerYes')]
    procedure AddPictureAndOverridePreviousMediaTest()
    var
        TableWithMedia: Record "Table With Media";
        Camera: Codeunit Camera;
        CameraTestLibrary: Codeunit "Camera Test Library";
        WasAddingThePictureSuccessful: Boolean;
    begin
        // [Given] Camera test library subscribers are binded.
        BindSubscription(CameraTestLibrary);

        // [Given] AddPicture is invoked with all the correct parameters for the first time.
        TableWithMedia."Primary Key" := 1;
        Camera.AddPicture(TableWithMedia, TableWithMedia.FieldNo(Media));
        TableWithMedia.Find(); // it's impossible to pass Variant as a reference, so we need to find the reocrd.

        // [When] AddPicture is invoked for the second time on the same record.
        // [Then] A confirm dialog is displayed whether the user wants to override the existing picture.
        // Anwer 'yes' (handled by ConfirmDialogHandlerYes). 
        WasAddingThePictureSuccessful := Camera.AddPicture(TableWithMedia, TableWithMedia.FieldNo(Media));

        // [Then] The mock picture was added successfuly (for the second time).
        Assert.IsTrue(WasAddingThePictureSuccessful, 'Adding a picture for the record that already has Media should succeed if the user chose to override the picture.');

        // [Then] The record is modified, not inserted into the database.
        TableWithMedia.Reset();
        Assert.AreEqual(1, TableWithMedia.Count(), 'Exactly one record was expected to be in the database.');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('CameraPageHandler,ConfirmDialogHandlerNo')]
    procedure AddPictureAndNotOverridePreviousMediaTest()
    var
        TableWithMedia: Record "Table With Media";
        Camera: Codeunit Camera;
        CameraTestLibrary: Codeunit "Camera Test Library";
        WasAddingThePictureSuccessful: Boolean;
    begin
        // [Given] Camera test library subscribers are binded.
        BindSubscription(CameraTestLibrary);

        // [Given] AddPicture is invoked with all the correct parameters for the first time.
        TableWithMedia."Primary Key" := 1;
        Camera.AddPicture(TableWithMedia, TableWithMedia.FieldNo(Media));
        TableWithMedia.Find(); // it's impossible to pass Variant as a reference, so we need to find the reocrd.

        // [When] AddPicture is invoked for the second time on the same record.
        // [Then] A confirm dialog is displayed whether the user wants to override the existing picture.
        // Anwer 'no' (handled by ConfirmDialogHandlerNo). 
        WasAddingThePictureSuccessful := Camera.AddPicture(TableWithMedia, TableWithMedia.FieldNo(Media));

        // [Then] The mock picture was added successfuly (for the second time).
        Assert.IsFalse(WasAddingThePictureSuccessful, 'Adding a picture for the record that already has Media should fail if the user chose to not override the picture.');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('CameraPageHandler,ConfirmDialogHandlerYes')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AddPictureAndOverridePreviousMediaSetTest()
    var
        TableWithMedia: Record "Table With Media";
        Camera: Codeunit Camera;
        CameraTestLibrary: Codeunit "Camera Test Library";
        Base64Convert: Codeunit "Base64 Convert";
        FileInStream: InStream;
        ImageFile: File;
        WasAddingThePictureSuccessful: Boolean;
    begin
        // [Given] Camera test library subscribers are binded.
        BindSubscription(CameraTestLibrary);

        // [When] AddPicture is invoked with all the correct parameters.
        TableWithMedia."Primary Key" := 1;
        WasAddingThePictureSuccessful := Camera.AddPicture(TableWithMedia, TableWithMedia.FieldNo(MediaSetField));

        // [Then] The mock picture was added successfuly.
        Assert.IsTrue(WasAddingThePictureSuccessful, 'Adding a picture from camera should always be successful in tests.');

        // [Then] The MediaSet field has value.
        TableWithMedia.Find(); // it's impossible to pass Variant as a reference, so we need to find the reocrd.
        Assert.AreEqual(1, TableWithMedia.MediaSetField.Count(), 'The MediaSet field should have one Media object in it.');

        // [Then] The new record is inserted into the database.
        TableWithMedia.Reset();
        Assert.AreEqual(1, TableWithMedia.Count(), 'Exactly one record was expected to be in the database.');

        // [When] AddPicture is invoked for the second time on the same MediaSet field
        WasAddingThePictureSuccessful := Camera.AddPicture(TableWithMedia, TableWithMedia.FieldNo(MediaSetField));

        // [Then] The mock picture was added successfuly.
        Assert.IsTrue(WasAddingThePictureSuccessful, 'Adding a picture from camera for the second time should be successful.');

        // [Then] The MediaSet field has a single Media.
        TableWithMedia.Find(); // it's impossible to pass Variant as a reference, so we need to find the reocrd.
        Assert.AreEqual(1, TableWithMedia.MediaSetField.Count(), 'The MediaSet field should still have one Media object in it.');

        // Get the value in the MediaSet through a file
        TableWithMedia.MediaSetField.ExportFile('test.jpg');
        ImageFile.Open('test-1.jpg');
        ImageFile.CreateInStream(FileInStream);

        // [Then] The content of the MediaSet is as expected
        Assert.AreEqual(CameraTestLibrary.GetSmallJpeg(), Base64Convert.ToBase64(FileInStream), 'The mock picture was expected.');

        // [Then] No new record was added in the database.
        TableWithMedia.Reset();
        Assert.AreEqual(1, TableWithMedia.Count(), 'Exactly one record was expected to be in the database.');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('CameraPageHandler,ConfirmDialogHandlerNo')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AddPictureAndNotOverridePreviousMediaSetTest()
    var
        TableWithMedia: Record "Table With Media";
        Camera: Codeunit Camera;
        CameraTestLibrary: Codeunit "Camera Test Library";
        WasAddingThePictureSuccessful: Boolean;
    begin
        // [Given] Camera test library subscribers are binded.
        BindSubscription(CameraTestLibrary);

        // [When] AddPicture is invoked with all the correct parameters.
        TableWithMedia."Primary Key" := 1;
        WasAddingThePictureSuccessful := Camera.AddPicture(TableWithMedia, TableWithMedia.FieldNo(MediaSetField));

        // [Then] The mock picture was added successfuly.
        Assert.IsTrue(WasAddingThePictureSuccessful, 'Adding a picture from camera should always be successful in tests.');

        // [Then] The MediaSet field has value.
        TableWithMedia.Find(); // it's impossible to pass Variant as a reference, so we need to find the reocrd.
        Assert.AreEqual(1, TableWithMedia.MediaSetField.Count(), 'The MediaSet field should have one Media object in it.');

        // [Then] The new record is inserted into the database.
        TableWithMedia.Reset();
        Assert.AreEqual(1, TableWithMedia.Count(), 'Exactly one record was expected to be in the database.');

        // [When] AddPicture is invoked for the second time on the same MediaSet field
        WasAddingThePictureSuccessful := Camera.AddPicture(TableWithMedia, TableWithMedia.FieldNo(MediaSetField));

        // [Then] The mock picture was added successfuly.
        Assert.IsFalse(WasAddingThePictureSuccessful, 'Adding a picture for the record that already has MediaSet should fail if the user chose to not override the picture.');

        // [Then] The MediaSet field still has value.
        TableWithMedia.Find(); // it's impossible to pass Variant as a reference, so we need to find the reocrd.
        Assert.AreEqual(1, TableWithMedia.MediaSetField.Count(), 'The MediaSet field should still have one Media object in it.');

        // [Then] No new record was added in the database.
        TableWithMedia.Reset();
        Assert.AreEqual(1, TableWithMedia.Count(), 'Exactly one record was expected to be in the database.');
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmDialogHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmDialogHandlerNo(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;
#endif

    [ModalPageHandler]
    procedure CameraPageHandler(var CameraPage: TestPage Camera)
    begin
        // Do nothing
    end;
}

