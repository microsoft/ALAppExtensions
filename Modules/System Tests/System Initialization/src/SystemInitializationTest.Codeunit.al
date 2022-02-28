// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 130045 "System Initialization Test"
{
    // Tests for the System Initialization codeunit

    Subtype = Test;

    [Test]
    [HandlerFunctions('PasswordDialogModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestPasswordDialogCanBeOpenedAfterSystemInitialization()
    var
        CompanyTriggers: Codeunit "Company Triggers";
        PasswordDialog: Codeunit "Password Dialog Management";
        PermissionsMock: Codeunit "Permissions Mock";
        OldPassword: Text;
        NewPassword: Text;
    begin
        PermissionsMock.Set('System Init Exec');
        // [WHEN] Calling CompanyTriggers.OnCompanyOpen()
#if not CLEAN20
#pragma warning disable AL0432
#endif
        CompanyTriggers.OnCompanyOpen();
#if not CLEAN20
#pragma warning restore AL0432
#endif

        // [THEN] Calling PasswordDialog.OpenChangePasswordDialog should NOT results in an error
        PasswordDialog.OpenChangePasswordDialog(OldPassword, NewPassword);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure PasswordDialogModalPageHandler(var PasswordDialog: Page "Password Dialog"; var Response: Action)
    begin
        Response := ACTION::OK;
    end;
}
