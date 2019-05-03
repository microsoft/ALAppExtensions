// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

Codeunit 135033 "Password Dialog Test"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        PasswordDialogManagement: Codeunit "Password Dialog Management";
        PasswordDialogImpl: Codeunit "Password Dialog Impl.";
        PasswordDialogTest: Codeunit "Password Dialog Test";
        PasswordToUse: Text;
        MinimumPasswordLength: Integer;
        DisablePasswordConfirmation: Boolean;
        DisablePasswordValidation: Boolean;
        PasswordMissmatch: Boolean;
        ValidPassword: Label 'Some Password 2';
        InValidPassword: Label 'Some Password';
        AnotherPassword: Label 'Another Password';

    [Test]
    procedure ValidatePasswordTest();
    begin
        // [SCENARIO] The password must be at least 8 characters long and contain one capital case letter,
        // one lower case letter and one number.
        Assert.IsTrue(PasswordDialogImpl.ValidatePasswordStrength('Password1'), 'Password was expected to be valid.');
        Assert.IsFalse(PasswordDialogImpl.ValidatePasswordStrength('Password'), 'Password was expected to be invalid.');
        Assert.IsFalse(PasswordDialogImpl.ValidatePasswordStrength('Pass1'), 'Password was expected to be invalid.');
        Assert.IsFalse(PasswordDialogImpl.ValidatePasswordStrength('password1'), 'Password was expected to be invalid.');
        Assert.IsFalse(PasswordDialogImpl.ValidatePasswordStrength('PASSWORD1'), 'Password was expected to be invalid.');
        Assert.IsFalse(PasswordDialogImpl.ValidatePasswordStrength('p@ssword1'), 'Password was expected to be invalid.');
    end;

    [Test]
    procedure OverrideMinimumCharactersTest();
    begin
        // [SCENARIO] Minimum Password Length can be increased but not decreased
        BindSubscription(PasswordDialogTest);
        MinimumPasswordLength := 16;
        Assert.IsFalse(PasswordDialogImpl.ValidatePasswordStrength('Password1'), 'Password was expected to be invalid.');
        Assert.IsTrue(PasswordDialogImpl.ValidatePasswordStrength('PasswordPassword1'), 'Password was expected to be valid.');
        MinimumPasswordLength := 5;
        Assert.IsFalse(PasswordDialogImpl.ValidatePasswordStrength('Pass1'), 'Password was expected to be invalid.');
        UnbindSubscription(PasswordDialogTest);
    end;

    [Test]
    procedure OpenPasswordDialogDefaultTest();
    VAR
        Password: Text;
    begin
        // [SCENARIO] Password Confirmation and Validation are enabled and Blank password is not allowed
        DisablePasswordValidation := FALSE;
        DisablePasswordConfirmation := FALSE;
        PasswordMissmatch := FALSE;

        // [WHEN] A valid password is given.
        PasswordToUse := ValidPassword;
        Password := PasswordDialogManagement.OpenPasswordDialog4;
        // [THEN] The password is retrieved.
        Assert.AreEqual(ValidPassword, Password, 'A diferrent password was expected.');

        // [WHEN] An invalid password is given.
        PasswordToUse := InValidPassword;
        // [THEN] An error is thrown if only the password field is filled.
        AssertError PasswordDialogManagement.OpenPasswordDialog4;
        Assert.AreEqual('', Password, 'A diferrent password was expected.');

        // [WHEN] Password and Confirm Password miss match.
        // [THEN] An error is thrown.
        PasswordMissmatch := true;
        PasswordToUse := ValidPassword;
        AssertError PasswordDialogManagement.OpenPasswordDialog4;
        Assert.AreEqual('', Password, 'A diferrent password was expected.');
    end;

    [Test]
    [HandlerFunctions('PasswordDialogModalPageHandler')]
    procedure OpenPasswordDialogDisableConfirmationTest();
    VAR
        Password: Text;
    begin
        // [SCENARIO] Password dialog can be opened and Password confirmation can be disabled.

        // [WHEN] Password Confirmation and validation are disabled.
        // [THEN] An invalid password can be retrieved by only filling the password field.
        DisablePasswordValidation := true;
        DisablePasswordConfirmation := true;
        PasswordMissmatch := false;
        PasswordToUse := InValidPassword;
        Password := PasswordDialogManagement.OpenPasswordDialog(DisablePasswordValidation, DisablePasswordConfirmation, false);
        Assert.AreEqual(InValidPassword, Password, 'A diferrent password was expected.');
    end;

    [Test]
    [HandlerFunctions('PasswordDialogModalPageHandler')]
    procedure OpenPasswordDialogDisableValidationTest();
    VAR
        Password: Text;
    begin
        // [SCENARIO] Password dialog can be opened and Password Validation can be disabled.

        // [WHEN] Password Validation is disabled.
        // [THEN] An invalid password can be retrieved by filling both Password and Confirm Password fields.
        DisablePasswordValidation := true;
        DisablePasswordConfirmation := false;
        PasswordMissmatch := false;
        PasswordToUse := InValidPassword;
        Password := PasswordDialogManagement.OpenPasswordDialog(DisablePasswordValidation, DisablePasswordConfirmation, false);
        Assert.AreEqual(InValidPassword, Password, 'A diferrnt password was expected.');
    end;

    [Test]
    [HandlerFunctions('PasswordDialogModalPageHandler,ConfirmHandler')]
    procedure OpenPasswordDialogEnableBlankPasswordTest();
    VAR
        Password: Text;
    begin
        // [SCENARIO] Blank Password can be enabled.

        // [WHEN] Blank Password is not Enabled and no value has been set.
        // [THEN] An error is thrown.
        DisablePasswordValidation := false;
        DisablePasswordConfirmation := false;
        PasswordMissmatch := false;
        PasswordToUse := '';
        AssertError PasswordDialogManagement.OpenPasswordDialog(DisablePasswordValidation, DisablePasswordConfirmation, false);
        Assert.AreEqual('', Password, 'A diferrent password was expected.');

        // [WHEN] Blank Password is Enabled.
        // [THEN] A blank password is returned without an error.
        PasswordToUse := '';
        DisablePasswordValidation := false;
        DisablePasswordConfirmation := false;
        PasswordMissmatch := false;
        Password := PasswordDialogManagement.OpenPasswordDialog(DisablePasswordValidation, DisablePasswordConfirmation, true);
        Assert.AreEqual('', Password, 'Blank password was expected.');
    end;

    [Test]
    [HandlerFunctions('ChangePasswordDialogModalPageHandler')]
    procedure OpenChangePasswordDialogTest();
    var
        Password: Text;
        OldPassword: Text;
    begin
        // [SCENARIO] Open Password dialog in change password mode.

        // [WHEN] The password dialog is opened in change password mode.
        PasswordDialogManagement.OpenChangePasswordDialog(OldPassword, Password);

        // [THEN] The Old and New passwords are retrieved.
        Assert.AreEqual(InValidPassword, OldPassword, 'A diferrent password was expected.');
        Assert.AreEqual(ValidPassword, Password, 'A diferrent password was expected.')
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Password Dialog Management", 'OnSetMinPasswordLength', '', true, true)]
    procedure OnSetMinimumPAsswordLength(var MinPasswordLength: Integer);
    begin
        MinPasswordLength := MinimumPasswordLength;
    end;

    [ModalPageHandler]
    procedure PasswordDialogModalPageHandler(var PasswordDialog: TestPage "Password Dialog");
    begin
        Assert.IsFalse(PasswordDialog.OldPassword.Visible(), 'Old Password Field should not be visible');
        Assert.AreEqual(not DisablePasswordConfirmation, PasswordDialog.ConfirmPassword.Visible(), 'A different value was expected');
        PasswordDialog.Password.SetValue(PasswordToUse);
        if not DisablePasswordConfirmation then
            PasswordDialog.ConfirmPassword.SetValue(PasswordToUse);
        if PasswordMissmatch then
            PasswordDialog.ConfirmPassword.SetValue(AnotherPassword);
        PasswordDialog.OK.Invoke();
    end;

    [ModalPageHandler]
    procedure ChangePasswordDialogModalPageHandler(var PasswordDialog: TestPage "Password Dialog");
    begin
        Assert.IsTrue(PasswordDialog.OldPassword.Visible(), 'Old Password Field should not be visible.');
        Assert.IsTrue(PasswordDialog.ConfirmPassword.Visible(), 'Confirm Password Field should not be visible.');
        PasswordDialog.OldPassword.SetValue(InValidPassword);
        PasswordDialog.Password.SetValue(ValidPassword);
        PasswordDialog.ConfirmPassword.SetValue(ValidPassword);
        PasswordDialog.OK.Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean);
    begin
        Reply := true;
    end;

}

