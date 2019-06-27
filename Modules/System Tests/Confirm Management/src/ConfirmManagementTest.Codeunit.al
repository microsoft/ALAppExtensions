// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132509 "Confirm Management Test"
{
    EventSubscriberInstance = Manual;
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
        ConfirmManagement: Codeunit 27;
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
        ConfirmManagementTest: Codeunit 132509;
        ConfirmManagement: Codeunit 27;
        Result: Boolean;
    begin
        // [GIVEN] UI disallowed
        BindSubscription(ConfirmManagementTest);

        // [WHEN] Confirm dialog is raised with true as the default button
        Result := ConfirmManagement.GetResponseOrDefault('Some Q', true);

        // [THEN] Default response is returned
        LibraryAssert.AreEqual(true, Result, 'Default response is not returned');
        UnbindSubscription(ConfirmManagementTest);
    end;

    [Test]
    [HandlerFunctions('HandleConfirmDialogByClickingYes')]
    procedure TestGetResponseUserClicksNonDefaultButton();
    VAR
        ConfirmManagement: Codeunit 27;
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
        ConfirmManagementTest: Codeunit 132509;
        ConfirmManagement: Codeunit 27;
        Result: Boolean;
    begin
        // [GIVEN] UI disallowed
        BindSubscription(ConfirmManagementTest);

        // [WHEN] Confirm dialog is raised with true as the default button
        Result := ConfirmManagement.GetResponse('Some Q', true);

        // [THEN] FALSE should be returned
        LibraryAssert.AreEqual(false, Result, 'FALSE should have been returned');
        UnbindSubscription(ConfirmManagementTest);
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

    [EventSubscriber(ObjectType::Codeunit, 27, 'OnBeforeGuiAllowed', '', false, false)]
    local procedure OnBeforeIsGuiAllowed(var Result: Boolean; var Handled: Boolean);
    begin
        Result := false;
        Handled := true;
    end;
}

