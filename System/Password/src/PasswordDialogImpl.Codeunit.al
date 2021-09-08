// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9811 "Password Dialog Impl."
{
    Access = Internal;

    var
        PasswordMismatchErr: Label 'The passwords that you entered do not match.';
        PasswordTooSimpleErr: Label 'The password that you entered does not meet the minimum requirements. It must be at least %1 characters long and contain at least one uppercase letter, one lowercase letter, one number and one special character. It must not have a sequence of 3 or more ascending, descending or repeating characters.', Comment = '%1: The minimum number of characters required in the password';
        ConfirmBlankPasswordQst: Label 'Do you want to exit without entering a password?';

    procedure ValidatePasswordStrength(Password: Text)
    var
        PasswordHandler: Codeunit "Password Handler";
    begin
        if not PasswordHandler.IsPasswordStrong(Password) then
            Error(PasswordTooSimpleErr, PasswordHandler.GetPasswordMinLength());
    end;

    procedure OpenPasswordDialog(DisablePasswordValidation: Boolean; DisablePasswordConfirmation: Boolean): Text
    var
        PasswordDialog: Page "Password Dialog";
    begin
        if DisablePasswordValidation then
            PasswordDialog.DisablePasswordValidation();
        if DisablePasswordConfirmation then
            PasswordDialog.DisablePasswordConfirmation();
        if PasswordDialog.RunModal() = ACTION::OK then
            exit(PasswordDialog.GetPasswordValue());
        exit('');
    end;

    procedure OpenChangePasswordDialog(var OldPassword: Text; var Password: Text)
    var
        PasswordDialog: Page "Password Dialog";
    begin
        PasswordDialog.EnableChangePassword();
        if PasswordDialog.RunModal() = ACTION::OK then begin
            Password := PasswordDialog.GetPasswordValue();
            OldPassword := PasswordDialog.GetOldPasswordValue();
        end;
    end;

    procedure ValidatePassword(RequiresPasswordConfirmation: Boolean; ValidatePassword: Boolean; Password: Text; ConfirmPassword: Text): Boolean
    begin
        if RequiresPasswordConfirmation and (Password <> ConfirmPassword) then
            Error(PasswordMismatchErr);

        if ValidatePassword then
            ValidatePasswordStrength(Password);
        if Password = '' then
            if not Confirm(ConfirmBlankPasswordQst) then
                exit(false);
        exit(true);
    end;
}

