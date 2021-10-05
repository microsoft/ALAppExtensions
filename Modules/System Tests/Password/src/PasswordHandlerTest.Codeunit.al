// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132578 "Password Handler Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        InsufficientPassLngthErr: Label 'The password must contain at least %1 characters.', Comment = '%1 = the number of characters';
        PasswordIsNotStrongErr: Label 'The generated password must be strong.';
        PasswordIsStrongErr: Label 'The generated password must not be strong.';


    [Test]
    [Scope('OnPrem')]
    procedure TestGenerateShortPassword()
    var
        PasswordHandler: Codeunit "Password Handler";
        Password: Text;
        Length: Integer;
    begin
        // [SCENARIO] An eight character long strong password can be generated.
        PermissionsMock.Set('Password Exec');

        // [GIVEN] The length of the password is set to eight.
        Length := 8;

        // [WHEN] The password is generated.
        Password := PasswordHandler.GeneratePassword(Length);

        // [THEN] The length of the generated password is correct.
        Assert.AreEqual(Length, StrLen(Password), 'The generated password has incorrect length.');

        // [THEN] The password is strong.
        Assert.IsTrue(PasswordHandler.IsPasswordStrong(Password), PasswordIsNotStrongErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGeneratingLongPassword()
    var
        PasswordHandler: Codeunit "Password Handler";
        Password: Text;
        Length: Integer;
    begin
        // [SCENARIO] A one hundred character long strong password can be generated.
        PermissionsMock.Set('Password Exec');

        // [GIVEN] The length of the password is set to one hundred.
        Length := 100;

        // [WHEN] The password is generated.
        Password := PasswordHandler.GeneratePassword(Length);

        // [THEN] The length of the generated password is correct.
        Assert.AreEqual(Length, StrLen(Password), 'The generated password has incorrect length.');

        // [THEN] The password is strong.
        Assert.IsTrue(PasswordHandler.IsPasswordStrong(Password), PasswordIsNotStrongErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGeneratedPasswordIsTooShort()
    var
        PasswordHandler: Codeunit "Password Handler";
        Length: Integer;
    begin
        // [SCENARIO] A password with less than eight characters cannot be generated.
        PermissionsMock.Set('Password Exec');

        // [GIVEN] The length of the password is set to seven.
        Length := 7;

        // [WHEN] The password is generated.
        asserterror PasswordHandler.GeneratePassword(Length);
        Assert.ExpectedError('The password must contain at least 8 characters.');

        // [THEN] The error: 'The password must contain at least 8 characters.' is thrown.
        Assert.ExpectedError(StrSubstNo(InsufficientPassLngthErr, 8));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGeneratedPasswordIsTooShortIncreasedLength()
    var
        PasswordHandlerTest: Codeunit "Password Handler Test";
        PasswordHandler: Codeunit "Password Handler";
        Length: Integer;
    begin
        // [SCENARIO] If the minimum length of the password is set to sixteen in the event,
        // a password with less than sixteen characters cannot be generated.
        PermissionsMock.Set('Password Exec');

        // [GIVEN] The subsciber is bound to the event.        
        BindSubscription(PasswordHandlerTest);

        // [GIVEN] The length of the password is set to fifteen.
        Length := 15;

        // [WHEN] The password is generated.
        asserterror PasswordHandler.GeneratePassword(Length);
        Assert.ExpectedError('The password must contain at least 16 characters.');

        // [THEN] The error: 'The password must contain at least 16 characters.' is thrown.
        Assert.ExpectedError(StrSubstNo(InsufficientPassLngthErr, 16));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestVerifyStrongPasswordTooShort()
    var
        PasswordHandler: Codeunit "Password Handler";
        Password: Text;
    begin
        // [SCENARIO] A password with less than eight characters is not considered to be strong.
        PermissionsMock.Set('Password Exec');

        // [GIVEN] A password that is less than eight characters long.
        Password := 'Pass1@';

        // [THEN] The password is not considered to be strong.
        Assert.IsFalse(PasswordHandler.IsPasswordStrong(Password), PasswordIsStrongErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestVerifyStrongPasswordTooShortIncreasedLength()
    var
        PasswordHandlerTest: Codeunit "Password Handler Test";
        PasswordHandler: Codeunit "Password Handler";
        Password: Text;
    begin
        // [SCENARIO] If the minimum length of the password is set to sixteen in the event,
        // a password with less than sixteen characters is not considered to be strong.
        PermissionsMock.Set('Password Exec');

        // [GIVEN] A fifteen character long strong password is generated.
        Password := PasswordHandler.GeneratePassword(15);

        // [WHEN] The subsciber is bound to the event.        
        BindSubscription(PasswordHandlerTest);

        // [THEN] The password is not considered to be strong anymore.
        Assert.IsFalse(PasswordHandler.IsPasswordStrong(Password), PasswordIsStrongErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestVerifyStrongPasswordAllCharacterSets()
    var
        PasswordHandler: Codeunit "Password Handler";
        Password: Text;
    begin
        // [SCENARIO] A strong passord must contain characters from all the character sets:
        // uppercase, lowercase, digits, special characters.
        PermissionsMock.Set('Password Exec');

        // [GIVEN] A password without any uppercase characters.
        Password := 'password1@';
        // [THEN] The password is not considered to be strong.
        Assert.IsFalse(PasswordHandler.IsPasswordStrong(Password), 'Password must contain uppercase characters.');

        // [GIVEN] A password without any lowercase characters.
        Password := 'PASSWORD1@';
        // [THEN] The password is not considered to be strong.
        Assert.IsFalse(PasswordHandler.IsPasswordStrong(Password), 'Password must contain lowercase characters.');

        // [GIVEN] A password without any digigts.
        Password := 'Password@';
        // [THEN] The password is not considered to be strong.
        Assert.IsFalse(PasswordHandler.IsPasswordStrong(Password), 'Password must contain digits.');

        // [GIVEN] A password without any special characters.
        Password := 'Password1';
        // [THEN] The password is not considered to be strong.
        Assert.IsFalse(PasswordHandler.IsPasswordStrong(Password), 'Password must contain special characters.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestVerifyStrongPasswordSequences()
    var
        PasswordHandler: Codeunit "Password Handler";
        Password: Text;
        NoSequencesMsg: Text;
    begin
        // [SCENARIO] A strong passord must not contain sequences of characters.
        // For example, 123, aaa, CBD.
        PermissionsMock.Set('Password Exec');

        NoSequencesMsg := 'Password must contain sequences of 3 or more characters that are the same or consecutive.';

        // [GIVEN] A password with a '123' sequence.
        Password := 'Password@123';
        // [THEN] The password is not considered to be strong.
        Assert.IsFalse(PasswordHandler.IsPasswordStrong(Password), NoSequencesMsg);

        // [GIVEN] A password with an 'ooo' sequence.
        Password := 'Passwooord1@';
        // [THEN] The password is not considered to be strong.
        Assert.IsFalse(PasswordHandler.IsPasswordStrong(Password), NoSequencesMsg);

        // [GIVEN] A password with a 'ZYX' sequence.
        Password := 'ZYX_Password1@';
        // [THEN] The password is not considered to be strong.
        Assert.IsFalse(PasswordHandler.IsPasswordStrong(Password), NoSequencesMsg);

        // [GIVEN] A password with a '@AB' substring.
        Password := 'Password1@AB';
        // [THEN] The password is considered to be strong.
        Assert.IsTrue(PasswordHandler.IsPasswordStrong(Password), 'Character sets must not be mixed when determining a sequence.');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Password Dialog Management", 'OnSetMinPasswordLength', '', false, false)]
    procedure OnSetMinPasswordLength(var MinPasswordLength: Integer)
    VAR
    begin
        // Increase the minimum length of the password.
        MinPasswordLength := 16;
    end;
}