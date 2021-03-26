// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Report to change the current user's login password for OnPrem scenarios.
/// </summary>
report 9810 "Change Password"
{
    ProcessingOnly = true;
    UseRequestPage = false;
    Permissions = tabledata User = r;

    dataset
    {
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    var
        User: Record User;
        PasswordDialogManagement: Codeunit "Password Dialog Management";
        Password: Text;
        OldPassword: Text;
    begin
        PasswordDialogManagement.OpenChangePasswordDialog(OldPassword, Password);
        if Password = '' then
            exit;

        User.SetFilter("User Security ID", UserSecurityId());
        if User.IsEmpty() then
            error(UserDoesNotExistErr, user.FieldCaption("User Security ID"), User."User Security ID");

        if ChangeUserPassword(OldPassword, Password) then
            Message(PasswordUpdatedMsg);
    end;

    var
        PasswordUpdatedMsg: Label 'Your Password has been updated.';
        UserDoesNotExistErr: Label 'The user with %1 %2 does not exist.', Comment = '%1 = Label User Security Id, %2 = User Security ID';
}

