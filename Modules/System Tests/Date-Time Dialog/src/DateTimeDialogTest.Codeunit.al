// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134684 "Date-Time Dialog Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    [HandlerFunctions('DateTimeDialogHandler')]
    procedure TestDateTimeDialog()
    var
        DateTimeDialog: Page "Date-Time Dialog";
    begin
        // [GIVEN] DateTimeDialog is initialized with an arbitrary value.
        DateTimeDialog.SetDateTime(CreateDateTime(22221212D, 121200T));

        // [WHEN] The page is run.
        DateTimeDialog.RunModal();

        // [THEN] The value was changed in the handler.
        Assert.AreEqual(Format(CreateDateTime(00110101D, 010100T)), Format(DateTimeDialog.GetDateTime()), '');
    end;

    [Test]
    [HandlerFunctions('DateTimeDialogHandlerBlankDateTime')]
    procedure TestDateTimeDialogBlankDateTime()
    var
        DateTimeDialog: Page "Date-Time Dialog";
    begin
        // [GIVEN] DateTimeDialog is initialized with the blank value.
        DateTimeDialog.SetDateTime(0DT);

        // [WHEN] The page is run.
        DateTimeDialog.RunModal();

        // [THEN] The value was changed in the handler.
        Assert.AreEqual(Format(CreateDateTime(00110101D, 010100T)), Format(DateTimeDialog.GetDateTime()), '');
    end;

    [Test]
    [HandlerFunctions('DateDialogHandler')]
    procedure TestDateDialog()
    var
        DateTimeDialog: Page "Date-Time Dialog";
    begin
        // [GIVEN] DateTimeDialog is initialized with an arbitrary value.
        DateTimeDialog.UseDateOnly();
        DateTimeDialog.SetDate(22221212D);

        // [WHEN] The page is run.
        DateTimeDialog.RunModal();

        // [THEN] The value was changed in the handler.
        Assert.AreEqual(Format(00110101D), Format(DateTimeDialog.GetDate()), '');
    end;

    [Test]
    [HandlerFunctions('DateDialogHandlerBlankDate')]
    procedure TestDateDialogBlankDate()
    var
        DateTimeDialog: Page "Date-Time Dialog";
    begin
        // [GIVEN] DateTimeDialog is initialized with the blank value.
        DateTimeDialog.UseDateOnly();
        DateTimeDialog.SetDate(0D);

        // [WHEN] The page is run.
        DateTimeDialog.RunModal();

        // [THEN] The value was changed in the handler.
        Assert.AreEqual(Format(00110101D), Format(DateTimeDialog.GetDate()), '');
    end;

    [ModalPageHandler]
    procedure DateDialogHandler(var DateTimeDialog: TestPage "Date-Time Dialog")
    begin
        // Validate initial values.
        Assert.AreEqual(22221212D, DateTimeDialog.Date.AsDate(), '');

        // Assign new values.
        DateTimeDialog.Date.Value := Format(00110101D);

        DateTimeDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure DateDialogHandlerBlankDate(var DateTimeDialog: TestPage "Date-Time Dialog")
    begin
        // Validate initial values.
        Assert.AreEqual(0D, DateTimeDialog.Date.AsDate(), '');

        // Assign new values.
        DateTimeDialog.Date.Value := Format(00110101D);

        DateTimeDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure DateTimeDialogHandler(var DateTimeDialog: TestPage "Date-Time Dialog")
    begin
        // Validate initial values.
        Assert.AreEqual(22221212D, DateTimeDialog.Date.AsDate(), '');
        Assert.AreEqual(121200T, DateTimeDialog.Time.AsTime(), '');

        // Assign new values.
        DateTimeDialog.Date.Value := Format(00110101D);
        DateTimeDialog.Time.Value := Format(010100T);

        DateTimeDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure DateTimeDialogHandlerBlankDateTime(var DateTimeDialog: TestPage "Date-Time Dialog")
    begin
        // Validate initial values.
        Assert.AreEqual(0D, DateTimeDialog.Date.AsDate(), '');
        Assert.AreEqual(0T, DateTimeDialog.Time.AsTime(), '');

        // Assign new values.
        DateTimeDialog.Date.Value := Format(00110101D);
        Assert.AreEqual(Format(000000T), DateTimeDialog.Time.Value(), '');
        DateTimeDialog.Time.Value := Format(010100T);

        DateTimeDialog.OK().Invoke();
    end;
}

