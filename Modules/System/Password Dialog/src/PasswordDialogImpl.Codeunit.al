// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9811 "Password Dialog Impl."
{
    Access = Internal;

    var
        PasswordMismatchErr: Label 'The passwords that you entered do not match.';
        PasswordTooSimpleErr: Label 'The password that you entered does not meet the minimum requirements. It must be at least %1 characters long and contain at least one uppercase letter, one lowercase letter, and one number.', Comment = '%1: The minimum number of charracters required in the password';
        ConfirmBlankPasswordQst: Label 'Do you want to exit without entering a password?';

    [Scope('OnPrem')]
    procedure ValidatePasswordStrength(Password: Text)
    var
        PasswordDialogManagement: Codeunit "Password Dialog Management";
        i: Integer;
        PasswordLen: Integer;
        HasUpper: Boolean;
        HasLower: Boolean;
        HasNumeric: Boolean;
        MinPasswordLength: Integer;
    begin
        PasswordLen := StrLen(Password);

        PasswordDialogManagement.OnSetMinPasswordLength(MinPasswordLength);
        if MinPasswordLength < 8 then
            MinPasswordLength := 8;
        if PasswordLen < MinPasswordLength then
            Error(PasswordTooSimpleErr, MinPasswordLength);

        for i := 1 to StrLen(Password) do begin
            case Password[i] of
                'A' .. 'Z':
                    HasUpper := true;
                'a' .. 'z':
                    HasLower := true;
                '0' .. '9':
                    HasNumeric := true;
            end;

            if HasUpper and HasLower and HasNumeric then
                exit;
        end;

        Error(PasswordTooSimpleErr, MinPasswordLength);
    end;

    [Scope('OnPrem')]
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

    [Scope('OnPrem')]
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

    [Scope('OnPrem')]
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

