// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132509 "Confirm Management Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";

    trigger OnRun()
    begin
        // [MODULE] [Confirm Management]
    end;

    [Test]
    [HandlerFunctions('HandleConfirmDialogByClickingNo')]
    procedure TestGetResponseOrDefaultUserClicksDefaultButton();
    VAR
        ConfirmManagement: Codeunit "Confirm Management";
        Result: Boolean;
    begin
        // [WHEN] User clicks FALSE when Confirm dialog is raised with FALSE as the default button
        Result := ConfirmManagement.GetResponseOrDefault('Some Q', FALSE);

        // [THEN] Default response is returned
        LibraryAssert.AreEqual(FALSE, Result, 'Default response is not returned');
    end;

    [Test]
    procedure TestGetResponseOrDefaultWhenGuiNotAllowed();
    VAR
        ConfirmTestLibrary: Codeunit "Confirm Test Library";
        ConfirmManagement: Codeunit "Confirm Management";
        Result: Boolean;
    begin
        // [GIVEN] UI disallowed
        ConfirmTestLibrary.SetGuiAllowed(false);
        BindSubscription(ConfirmTestLibrary);

        // [WHEN] Confirm dialog is raised with true as the default button
        Result := ConfirmManagement.GetResponseOrDefault('Some Q', true);

        // [THEN] Default response is returned
        LibraryAssert.AreEqual(true, Result, 'Default response is not returned');
    end;

    [Test]
    [HandlerFunctions('HandleConfirmDialogByClickingYes')]
    procedure TestGetResponseUserClicksNonDefaultButton();
    VAR
        ConfirmManagement: Codeunit "Confirm Management";
        Result: Boolean;
    begin
        // [WHEN] User clicks true when Confirm dialog is raised with FALSE as the default button
        Result := ConfirmManagement.GetResponse('Some Q', FALSE);

        // [THEN] User response is returned
        LibraryAssert.AreEqual(true, Result, 'User response is not returned');
    end;

    [Test]
    procedure TestGetResponseWhenGuiNotAllowed();
    VAR
        ConfirmTestLibrary: Codeunit "Confirm Test Library";
        ConfirmManagement: Codeunit "Confirm Management";
        Result: Boolean;
    begin
        // [GIVEN] UI disallowed
        ConfirmTestLibrary.SetGuiAllowed(false);
        BindSubscription(ConfirmTestLibrary);

        // [WHEN] Confirm dialog is raised with true as the default button
        Result := ConfirmManagement.GetResponse('Some Q', true);

        // [THEN] FALSE should be returned
        LibraryAssert.AreEqual(false, Result, 'FALSE should have been returned');
    end;

    [ConfirmHandler]
    procedure HandleConfirmDialogByClickingYes(Question: Text[1024]; var Reply: Boolean);
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    procedure HandleConfirmDialogByClickingNo(Question: Text[1024]; var Reply: Boolean);
    begin
        Reply := false;
    end;
}

