// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9810 "Password Dialog Management"
{

    trigger OnRun()
    begin
    end;

    var
        PasswordDialogImpl: Codeunit "Password Dialog Impl.";

    procedure OpenPasswordDialog(DisablePasswordValidation: Boolean;DisablePasswordConfirmation: Boolean;EnableBlankPassword: Boolean): Text
    begin
        // <summary>
        // Opens a dialog for the user to enter a password and returns the typed password if there is no validation error,
        // otherwise an empty text is returned.
        // </summary>
        // <param name="DisablePasswordValidation">Disables the checks for the password validity. Default value is false.</param>
        // <param name="DisablePasswordConfirmation">If set to true the new password is only needed once. Default value is false.</param>
        // <param name="EnableBlankPassword">If set to true the new password can be blank. Default value is false.</param>
        // <returns>The typed password, or empty text if the password validations fail.</returns>
        exit(PasswordDialogImpl.OpenPasswordDialog(DisablePasswordValidation,DisablePasswordConfirmation,EnableBlankPassword));
    end;

    procedure OpenPasswordDialog2(DisablePasswordValidation: Boolean;DisablePasswordConfirmation: Boolean): Text
    begin
        // <summary>
        // Opens a dialog for the user to enter a password and returns the typed password if there is no validation error,
        // otherwise an empty text is returned.
        // </summary>
        // <param name="DisablePasswordValidation">Disables the checks for the password validity. Default value is false.</param>
        // <param name="DisablePasswordConfirmation">If set to true the new password is only needed once. Default value is false.</param>
        // <returns>The typed password, or empty text if the password validations fail.</returns>
        exit(PasswordDialogImpl.OpenPasswordDialog(DisablePasswordValidation,DisablePasswordConfirmation,false));
    end;

    procedure OpenPasswordDialog3(DisablePasswordValidation: Boolean): Text
    begin
        // <summary>
        // Opens a dialog for the user to enter a password and returns the typed password if there is no validation error,
        // otherwise an empty text is returned.
        // </summary>
        // <param name="DisablePasswordValidation">Disables the checks for the password validity. Default value is false.</param>
        // <returns>The typed password, or empty text if the password validations fail.</returns>
        exit(PasswordDialogImpl.OpenPasswordDialog(DisablePasswordValidation,false,false));
    end;

    procedure OpenPasswordDialog4(): Text
    begin
        // <summary>
        // Opens a dialog for the user to enter a password and returns the typed password if there is no validation error,
        // otherwise an empty text is returned.
        // </summary>
        // <param name="DisablePasswordValidation">Disables the checks for the password validity.</param>
        // <param name="DisablePasswordConfirmation">If set to true the new password is only needed once.</param>
        // <param name="EnableBlankPassword">If set to true the new password can be blank.</param>
        // <returns>The typed password, or empty text if the password validations fail.</returns>
        exit(PasswordDialogImpl.OpenPasswordDialog(false,false,false));
    end;

    procedure OpenChangePasswordDialog(var OldPassword: Text;var Password: Text)
    begin
        // <summary>
        // Opens a dialog for the user to change a password and returns the old and new typed passwords if there is no validation error,
        // otherwise an empty text are returned.
        // </summary>
        // <param name="OldPassword">Out parameter, the old password user typed on the dialog.</param>
        // <param name="Password">Out parameter, the new password user typed on the dialog.</param>
        PasswordDialogImpl.OpenChangePasswordDialog(OldPassword,Password);
    end;

    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    procedure OnSetMinPasswordLength(var MinPasswordLength: Integer)
    begin
        // <summary>
        // Event to override the Minimum number of characters in the password.
        // The Minimum length can only be increased not decreased. Default value is 8 characters long.
        // </summary>
        // <param name="MinPasswordLength">The number of characters to be set as minimum requirement.</param>
    end;
}

