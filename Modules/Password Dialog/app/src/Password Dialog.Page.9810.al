// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 9810 "Password Dialog"
{
    Caption = 'Enter Password';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field(OldPassword;OldPassword)
            {
                ApplicationArea = All;
                Caption = 'Old Password';
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the current password, before the user defines a new one.';
                Visible = ShowOldPassword;
            }
            field(Password;Password)
            {
                ApplicationArea = All;
                Caption = 'Password';
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the password for this task. The password must consist of 8 or more characters, at least one uppercase letter, one lowercase letter, and one number.';

                trigger OnValidate()
                begin
                    if ValidatePassword and not PasswordDialogImpl.ValidatePasswordStrength(Password) then
                      Error(PasswordTooSimpleErr);
                end;
            }
            field(ConfirmPassword;ConfirmPassword)
            {
                ApplicationArea = All;
                Caption = 'Confirm Password';
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the password repeated.';
                Visible = RequiresPasswordConfirmation;

                trigger OnValidate()
                begin
                    if RequiresPasswordConfirmation and (Password <> ConfirmPassword) then
                      Error(PasswordMismatchErr);
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        ValidatePassword := true;
        RequiresPasswordConfirmation := true;
    end;

    trigger OnOpenPage()
    begin
        ValidPassword := false;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        ValidPassword := false;
        if CloseAction = ACTION::OK then
          ValidPassword := PasswordDialogImpl.ValidatePassword(
              RequiresPasswordConfirmation,IsBlankPasswordEnabled,ValidatePassword,Password,ConfirmPassword);
    end;

    var
        PasswordMismatchErr: Label 'The passwords that you entered do not match.';
        PasswordTooSimpleErr: Label 'The password that you entered does not meet the minimum requirements. It must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one number.';
        PasswordDialogImpl: Codeunit "Password Dialog Impl.";
        [InDataSet]
        Password: Text;
        [InDataSet]
        ConfirmPassword: Text;
        [InDataSet]
        OldPassword: Text;
        ShowOldPassword: Boolean;
        ValidPassword: Boolean;
        IsBlankPasswordEnabled: Boolean;
        ValidatePassword: Boolean;
        RequiresPasswordConfirmation: Boolean;

    [Scope('OnPrem')]
    procedure GetPasswordValue(): Text
    begin
        if ValidPassword then
          exit(Password);

        exit('');
    end;

    [Scope('OnPrem')]
    procedure GetOldPasswordValue(): Text
    begin
        if ValidPassword then
          exit(OldPassword);

        exit('');
    end;

    [Scope('OnPrem')]
    procedure EnableChangePassword()
    begin
        ShowOldPassword := true;
    end;

    [Scope('OnPrem')]
    procedure EnableBlankPassword()
    begin
        IsBlankPasswordEnabled := true;
        ValidatePassword := false;
    end;

    [Scope('OnPrem')]
    procedure DisablePasswordValidation()
    begin
        ValidatePassword := false;
    end;

    [Scope('OnPrem')]
    procedure DisablePasswordConfirmation()
    begin
        RequiresPasswordConfirmation := false;
    end;
}

