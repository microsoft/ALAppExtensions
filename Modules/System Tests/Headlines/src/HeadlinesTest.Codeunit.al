// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139481 "Headlines Test"
{
    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] [Role Center Headlines]
    end;

    var
        Headlines: Codeunit "Headlines";
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        Text50Txt: Label '12345678901234567890123456789012345678901234567890', Locked = true;
        Text75Txt: Label '123456789012345678901234567890123456789012345678901234567890123456789012345', Locked = true;
        NoonGreetingTxt: Label 'Hi, %1!', Comment = 'Displayed between 12:00 and 13:59. %1 is the user name.';
        SimpleNoonGreetingTxt: Label 'Hi!', Comment = 'Displayed between 12:00 and 13:59.';

    [Test]
    procedure TestEmphasize()
    begin
        // [FEATURE] [Emphasize Text]
        PermissionsMock.Set('Headlines Read');
        // [WHEN] Empahsize is called with an empty text
        // [THEN] It returns an empty string
        Assert.AreEqual('', Headlines.Emphasize(''), 'Empty emphasize should be empty.');

        // [WHEN] Empahsize is called with some text
        // [THEN] It adds emphasize around the text
        Assert.AreEqual('<emphasize>Text</emphasize>', Headlines.Emphasize('Text'), 'Wrong emphasize.');
    end;

    [Test]
    procedure TestGetHeadlineText()
    var
        Result: Text;
    begin
        // [FEATURE] [Headline Text]
        PermissionsMock.Set('Headlines Read');

        // [WHEN] GetHeadlineText is called with no text at all
        // [THEN] It returns false
        Assert.IsFalse(Headlines.GetHeadlineText('', '', Result), 'Expected empty headline text creation to return false');

        // [WHEN] GetHeadlineText is called with no qualifier but with a valid payload
        // [THEN] It returns true and the result only contains the payload
        Assert.IsTrue(
          Headlines.GetHeadlineText('', 'My Payload', Result), 'Expected valid headline creation to work when no qualifier');
        Assert.AreEqual('<payload>My Payload</payload>', Result, 'Wrong headline text with only payload.');

        // [WHEN] GetHeadlineText is called with a qualifier but no payload
        // [THEN] It returns false
        Assert.IsFalse(
          Headlines.GetHeadlineText('My Qualifier', '', Result),
          'Expected invalid headline creation to return false with empty payload');

        // [WHEN] GetHeadlineText is called with valid auqlifier and payload
        // [THEN] It returns true and the result contains the qualifier and the payload
        Assert.IsTrue(
          Headlines.GetHeadlineText('My Qualifier', 'My Payload', Result),
          'Expected valid headline creation to work with short qualifier and payload');
        Assert.AreEqual(
          '<qualifier>My Qualifier</qualifier><payload>My Payload</payload>', Result,
          'Wrong headline text with short payload and qualifier.');

        // [WHEN] GetHeadlineText is called with long qualifier and payload
        // [THEN] It returns true and the result contains both
        Assert.IsTrue(
          Headlines.GetHeadlineText(Text50Txt, Text75Txt, Result),
          'Expected valid headline creation to work with long qualidier and payload');
        Assert.AreEqual(
          StrSubstNo('<qualifier>%1</qualifier><payload>%2</payload>', Text50Txt, Text75Txt), Result,
          'Wrong headline text with payload and qualifier.');

        // [WHEN] GetHeadlineText is called with extra long payload but is still short enough when we remove the emphasize
        // [THEN] It returns true and the result contains the long payload
        Assert.IsTrue(
          Headlines.GetHeadlineText(
            Text50Txt, Text75Txt + '<emphasize></emphasize><emphasize></emphasize><emphasize></emphasize>', Result),
          'Expected valid headline creation to work with long payload but emphasize');
        Assert.AreEqual(
          StrSubstNo('<qualifier>%1</qualifier><payload>%2%3</payload>',
            Text50Txt, Text75Txt, '<emphasize></emphasize><emphasize></emphasize><emphasize></emphasize>'), Result,
          'Wrong headline with long payload containing emphasize and long qualifier.');

        // [WHEN] GetHeadlineText is called with too long qualifier
        // [THEN] It returns false
        Assert.IsFalse(Headlines.GetHeadlineText(Text50Txt + ' ', Text75Txt, Result),
          'Expected creation with too long text not to work.');

        // [WHEN] GetHeadlineText is called with too long payload
        // [THEN] It returns false
        Assert.IsFalse(Headlines.GetHeadlineText(Text50Txt, Text75Txt + ' ', Result),
          'Expected creation with too long text not to work.');
        Assert.IsFalse(Headlines.GetHeadlineText(Text50Txt, Text75Txt + ' <emphasize></emphasize>', Result),
          'Expected creation with too long text not to work.');
    end;

    [Test]
    procedure TestTruncate()
    begin
        // [FEATURE] [Truncate]
        PermissionsMock.Set('Headlines Read');

        // [WHEN] Truncate is called with negative negative or 0 length
        // [THEN] It returns an empty string
        Assert.AreEqual('', Headlines.Truncate('the text', -1), 'Invalid result with negative length');
        Assert.AreEqual('', Headlines.Truncate('the text', 0), 'Invalid result with 0 length');

        // [WHEN] Truncate can't add '...'
        // [THEN] It truncates the text
        Assert.AreEqual('the', Headlines.Truncate('the text', 3), 'Invalid result with 3 length');

        // [WHEN] Truncate can add '...'
        // [THEN] It truncates the text correclty
        Assert.AreEqual('t...', Headlines.Truncate('the text', 4), 'Invalid result with 4 length');
        Assert.AreEqual('12345...', Headlines.Truncate('123456789', 8), 'Invalid result with text to truncate');

        // [WHEN] There is no need to truncate
        // [THEN] The text is returned intact
        Assert.AreEqual('123456789', Headlines.Truncate('123456789', 9), 'Invalid result with equal length');
        Assert.AreEqual('123456789', Headlines.Truncate('123456789', 10), 'Invalid result with short enough text');
    end;

    [Test]
    procedure TestGetUserGreeting()
    var
        HeadlinesImpl: Codeunit "Headlines Impl.";
        GreetingText: Text;
        NoonTime: Time;
    begin
        // [FEATURE] [User Greeting]
        PermissionsMock.Set('Headlines Read');

        NoonTime := 120000T;
        // [WHEN] The username contains only whitespace characters
        GreetingText := HeadlinesImpl.GetUserGreetingTextInternal(' ', NoonTime);
        // [THEN] The simple greeting is displayed
        Assert.AreEqual(SimpleNoonGreetingTxt, GreetingText, 'Expected whitespace username to return simple greeting.');

        // [WHEN] The username is empty
        GreetingText := HeadlinesImpl.GetUserGreetingTextInternal('', NoonTime);
        // [THEN] The simple greeting is displayed
        Assert.AreEqual(SimpleNoonGreetingTxt, GreetingText, 'Expected empty username to return simple greeting.');

        // [WHEN] The username contains text
        GreetingText := HeadlinesImpl.GetUserGreetingTextInternal('John Doe', NoonTime);
        // [THEN] The complex greeting is displayed
        Assert.AreEqual(StrSubstNo(NoonGreetingTxt, 'John Doe'), GreetingText, 'Expected normal username to return more complex greeting.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestShouldUserGreetingBeVisible()
    var
        UserLoginTestLibrary: Codeunit "User Login Test Library";
    begin
        // [FEATURE] [User Greeting]
        UserLoginTestLibrary.DeleteAllLoginInformation(UserSecurityId());

        // [WHEN] The user has logged in less than 10 minutes ago
        UserLoginTestLibrary.InsertUserLogin(UserSecurityId(), 0D, CurrentDateTime() - (9 * 60 * 1000), 0DT);

        PermissionsMock.Set('Headlines Read');

        // [THEN] User greeting should be shown
        Assert.IsTrue(Headlines.ShouldUserGreetingBeVisible(), 'User logged in within 9 minutes from now.');

        // [WHEN] The user has logged in more than 10 minutes ago
        PermissionsMock.Stop();
        UserLoginTestLibrary.UpdateUserLogin(UserSecurityId(), 0D, CurrentDateTime() - (11 * 60 * 1000), 0DT);
        PermissionsMock.Start();
        PermissionsMock.Set('Headlines Read');

        // [THEN] No greeting should be shown
        Assert.IsFalse(Headlines.ShouldUserGreetingBeVisible(), 'User logged in at least 11 minutes minutes ago.');
    end;
}

