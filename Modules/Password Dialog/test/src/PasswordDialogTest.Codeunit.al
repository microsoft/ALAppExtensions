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
    [HandlerFunctions('PasswordDialogModalPageHandler')]
    procedure TestValidPassword();
    var
        Password: Text;
    begin
        // [SCENARIO] A valid password must be at least 8 characters long and contain one capital case letter,
        // one lower case letter and one number.
        PasswordToUse := 'Password1';
        Password := PasswordDialogManagement.OpenPasswordDialog3();
        Assert.AreEqual('Password1', Password, 'A different Passwword was expected');
    end;

    [Test]
    [HandlerFunctions('PasswordDialogModalPageHandler')]
    procedure TestPasswordWithoutNumericCharacter();
    var
        Password: Text;
    begin
        // [SCENARIO] A password without a numeric character cannot be entered.
        PasswordToUse := 'Password';
        asserterror PasswordDialogManagement.OpenPasswordDialog3();
    end;

    [Test]
    [HandlerFunctions('PasswordDialogModalPageHandler')]
    procedure TestPasswordWithoutCapitalCaseCharacter();
    var
        Password: Text;
    begin
        // [SCENARIO] A password without a capital case character cannot be entered.
        PasswordToUse := 'password1';
        asserterror PasswordDialogManagement.OpenPasswordDialog3();

        PasswordToUse := 'p@ssword1';
        asserterror PasswordDialogManagement.OpenPasswordDialog3();
    end;

    [Test]
    [HandlerFunctions('PasswordDialogModalPageHandler')]
    procedure TestPasswordWithoutLowerCaseCharacter();
    var
        Password: Text;
    begin
        // [SCENARIO] A password without a lower case character cannot be entered.
        PasswordToUse := 'PASSWORD1';
        asserterror PasswordDialogManagement.OpenPasswordDialog3();
    end;

    [Test]
    [HandlerFunctions('PasswordDialogModalPageHandler')]
    procedure TestShortPassword();
    var
        Password: Text;
    begin
        // [SCENARIO] A password with length less than 8 characters cannot be entered.
        PasswordToUse := 'Pass1';
        asserterror PasswordDialogManagement.OpenPasswordDialog3();
    end;

    [Test]
    [HandlerFunctions('PasswordDialogModalPageHandler')]
    procedure IncreaseMinimumCharactersTest();
    var
        Password: Text;
    begin
        // [SCENARIO] Minimum Password Length can be increased
        if BindSubscription(PasswordDialogTest) then;

        MinimumPasswordLength := 16;
        PasswordToUse := 'Password1';
        asserterror PasswordDialogManagement.OpenPasswordDialog3();

        PasswordToUse := 'PasswordPassword1';
        Password := PasswordDialogManagement.OpenPasswordDialog3();
        Assert.AreEqual('PasswordPassword1', Password, 'A different Passwword was expected');

        if UnbindSubscription(PasswordDialogTest) then;
    end;

    [Test]
    [HandlerFunctions('PasswordDialogModalPageHandler')]
    procedure DecreaseMinimumCharactersTest();
    var
        Password: Text;
    begin
        // [SCENARIO] Minimum Password Length can not be decreased
        if BindSubscription(PasswordDialogTest) then;
        MinimumPasswordLength := 5;
        PasswordToUse := 'Pass1';
        asserterror PasswordDialogManagement.OpenPasswordDialog3();

        if UnbindSubscription(PasswordDialogTest) then;
    end;

    [Test]
    [HandlerFunctions('PasswordDialogModalPageHandler')]
    procedure OpenPasswordDialogDefaultTest();
    var
        Password: Text;
    begin
        // [SCENARIO] Password Confirmation and Validation are enabled and Blank password is not allowed
        DisablePasswordValidation := false;
        DisablePasswordConfirmation := false;
        PasswordMissmatch := false;

        // [WHEN] A valid password is given.
        PasswordToUse := ValidPassword;
        Password := PasswordDialogManagement.OpenPasswordDialog3();
        // [THEN] The password is retrieved.
        Assert.AreEqual(ValidPassword, Password, 'A diferrent password was expected.');

        // [WHEN] An invalid password is given.
        PasswordToUse := InValidPassword;
        // [THEN] An error is thrown if only the password field is filled.
        asserterror PasswordDialogManagement.OpenPasswordDialog3();

        // [WHEN] Password and Confirm Password miss match.
        // [THEN] An error is thrown.
        PasswordMissmatch := true;
        PasswordToUse := ValidPassword;
        asserterror PasswordDialogManagement.OpenPasswordDialog3();
    END;

    [Test]
    [HandlerFunctions('PasswordDialogModalPageHandler')]
    procedure OpenPasswordDialogDisableConfirmationTest();
    var
        Password: Text;
    begin
        // [SCENARIO] Password dialog can be opened and Password confirmation can be disabled.

        // [WHEN] Password Confirmation and validation are disabled.
        // [THEN] An invalid password can be retrieved by only filling the password field.
        DisablePasswordValidation := true;
        DisablePasswordConfirmation := true;
        PasswordMissmatch := false;
        PasswordToUse := InValidPassword;
        Password := PasswordDialogManagement.OpenPasswordDialog(DisablePasswordValidation, DisablePasswordConfirmation);
        Assert.AreEqual(InValidPassword, Password, 'A diferrent password was expected.');
    end;

    [Test]
    [HandlerFunctions('PasswordDialogModalPageHandler,ConfirmHandler')]
    procedure OpenPasswordDialogDisableValidationTest();
    var
        Password: Text;
    begin
        // [SCENARIO] Password dialog can be opened and Password Validation can be disabled.

        // [WHEN] Password Validation is disabled.
        // [THEN] An invalid password can be retrieved by filling both Password and Confirm Password fields.
        DisablePasswordValidation := true;
        DisablePasswordConfirmation := false;
        PasswordMissmatch := false;
        PasswordToUse := InValidPassword;
        Password := PasswordDialogManagement.OpenPasswordDialog(DisablePasswordValidation, DisablePasswordConfirmation);
        Assert.AreEqual(InValidPassword, Password, 'A diferrnt password was expected.');

        // [THEN] An empty password can be entered
        PasswordToUse := '';
        Password := PasswordDialogManagement.OpenPasswordDialog(DisablePasswordValidation, DisablePasswordConfirmation);
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
        PasswordDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ChangePasswordDialogModalPageHandler(var PasswordDialog: TestPage "Password Dialog");
    begin
        Assert.IsTrue(PasswordDialog.OldPassword.Visible(), 'Old Password Field should not be visible.');
        Assert.IsTrue(PasswordDialog.ConfirmPassword.Visible(), 'Confirm Password Field should not be visible.');
        PasswordDialog.OldPassword.SetValue(InValidPassword);
        PasswordDialog.Password.SetValue(ValidPassword);
        PasswordDialog.ConfirmPassword.SetValue(ValidPassword);
        PasswordDialog.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean);
    begin
        Reply := true;
    end;

}

