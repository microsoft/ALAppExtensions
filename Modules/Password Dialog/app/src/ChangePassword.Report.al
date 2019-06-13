// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

report 9810 "Change Password"
{
    ApplicationArea = All;
    ProcessingOnly = true;
    UsageCategory = Tasks;
    UseRequestPage = false;

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
        PasswordDialogManagement.OpenChangePasswordDialog(OldPassword,Password);
        if Password = '' then
          exit;

        User.FilterGroup(99);
        User.SetFilter("User Security ID",UserSecurityId());
        User.FindFirst();
        if ChangeUserPassword(OldPassword,Password) then
          Message(PasswordUpdatedMsg);
    end;

    var
        PasswordUpdatedMsg: Label 'Your Password has been updated.';
}

