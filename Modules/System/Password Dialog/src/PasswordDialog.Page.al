// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 9810 "Password Dialog"
{
    Extensible = false;
    Caption = 'Enter Password';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field(OldPassword; OldPassword)
            {
                ApplicationArea = All;
                Caption = 'Old Password';
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the current password, before the user defines a new one.';
                Visible = ShowOldPassword;
            }
            field(Password; Password)
            {
                ApplicationArea = All;
                Caption = 'Password';
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the password for this task. The password must consist of 8 or more characters, at least one uppercase letter, one lowercase letter, and one number.';

                trigger OnValidate()
                begin
                    if RequiresPasswordValidation then
                        PasswordDialogImpl.ValidatePasswordStrength(Password);
                end;
            }
            field(ConfirmPassword; ConfirmPassword)
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
        RequiresPasswordValidation := true;
        RequiresPasswordConfirmation := true;
    end;

    trigger OnOpenPage()
    begin
        ValidPassword := false;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::OK then begin
            ValidPassword := PasswordDialogImpl.ValidatePassword(
                RequiresPasswordConfirmation,
                RequiresPasswordValidation,
                Password,
                ConfirmPassword);
            exit(ValidPassword);
        end;
    end;

    var
        PasswordDialogImpl: Codeunit "Password Dialog Impl.";
        PasswordMismatchErr: Label 'The passwords that you entered do not match.';
        [InDataSet]
        Password: Text;
        [InDataSet]
        ConfirmPassword: Text;
        [InDataSet]
        OldPassword: Text;
        ShowOldPassword: Boolean;
        ValidPassword: Boolean;
        RequiresPasswordValidation: Boolean;
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
    procedure DisablePasswordValidation()
    begin
        RequiresPasswordValidation := false;
    end;

    [Scope('OnPrem')]
    procedure DisablePasswordConfirmation()
    begin
        RequiresPasswordConfirmation := false;
    end;
}

