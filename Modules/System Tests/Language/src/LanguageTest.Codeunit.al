// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Tests for Language codeunit
/// </summary>
codeunit 130043 "Language Test"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        Language: Codeunit Language;
        PermissionsMock: Codeunit "Permissions Mock";
        IsInitialized: Boolean;
        LanguageNotFoundErr: Label 'The language %1 could not be found.', Locked = true;

    [Test]
    [Scope('OnPrem')]
    procedure GetUserLanguageCodeRaisesEvent()
    var
        LanguageTest: Codeunit "Language Test";
        LanguageCode: Code[10];
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup. A event subscriber for OnGetUserLanguageCode is present.
        Init();
        BindSubscription(LanguageTest);

        // [When] Get the current user's language code.
        LanguageCode := Language.GetUserLanguageCode();

        // [Then] The event OnGetUserLanguageCode is called and language code is as set. 
        // See VerifyOnGetUserLanguageCodeEventCalled subscriber.
        Assert.AreEqual('RANDOM', LanguageCode, 'Wrong language code.');

        UnbindSubscription(LanguageTest);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetUserLanguageCodeReturnGlobalLanguage()
    var
        LanguageCode: Code[10];
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup. No event subscriber for OnGetUserLanguageCode is present. 
        // Global language is set to Bulgarian
        Init();
        GlobalLanguage(1026); // bg-BG

        // [When] Get the current user's language code
        LanguageCode := Language.GetUserLanguageCode();

        // [Then] The correct language code is returned.
        Assert.AreEqual('BG', LanguageCode, 'Wrong language code.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageIdOrDefaultEmptyCode()
    var
        LanguageId: Integer;
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup
        Init();

        // [When] Get language ID by an empty code
        LanguageId := Language.GetLanguageIdOrDefault('');

        // [Then] The ID of the current language is returned
        Assert.AreEqual(GlobalLanguage(), LanguageId, 'Wrong language ID.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageIdOrDefaultInvalidCode()
    var
        LanguageId: Integer;
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup
        Init();

        // [When] Get language ID by an invalid code
        LanguageId := Language.GetLanguageIdOrDefault('INVALID');

        // [Then] The ID of the current language is returned
        Assert.AreEqual(GlobalLanguage(), LanguageId, 'Wrong language ID.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageIdOrDefaultValidCode()
    var
        LanguageId: Integer;
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup
        Init();

        // [When] Get language ID by a valid code
        LanguageId := Language.GetLanguageIdOrDefault('FR');

        // [Then] The the correct language ID is returned
        Assert.AreEqual(1036, LanguageId, 'Wrong language ID.'); // fr-FR
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageIdEmptyCode()
    var
        LanguageId: Integer;
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup
        Init();

        // [When] Get language ID by an empty code
        LanguageId := Language.GetLanguageId('');

        // [Then] 0 is returned
        Assert.AreEqual(0, LanguageId, 'Wrong language ID.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageIdInvalidCode()
    var
        LanguageId: Integer;
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup
        Init();

        // [When] Get language ID by an invalid code
        LanguageId := Language.GetLanguageId('INVALID');

        // [Then] 0 is returned
        Assert.AreEqual(0, LanguageId, 'Wrong language ID.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageIdValidCode()
    var
        LanguageId: Integer;
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup
        Init();

        // [When] Get language ID by a valid code
        LanguageId := Language.GetLanguageId('FR');

        // [Then] The ID of the correct language is returned
        Assert.AreEqual(1036, LanguageId, 'Wrong language ID.'); // fr-FR
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageCodeZeroIdTest()
    var
        LanguageCode: Code[10];
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup
        Init();

        // [When] Get language code by ID which is 0
        LanguageCode := Language.GetLanguageCode(0);

        // [Then] Empty code is returned
        Assert.AreEqual('', LanguageCode, 'Language code should be empty when language ID is 0.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageCodeInvalidId()
    var
        LanguageCode: Code[10];
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup
        Init();

        // [When] Get language code by an invalid ID
        LanguageCode := Language.GetLanguageCode(-42);

        // [Then] Empty code is returned
        Assert.AreEqual('', LanguageCode, 'Language code should be empty when language ID is invalid.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageCodeValidId()
    var
        LanguageCode: Code[10];
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup
        Init();

        // [When] Get language code by a valid ID
        LanguageCode := Language.GetLanguageCode(1026); // bg-BG

        // [Then] the correct language code is returned
        Assert.AreEqual('BG', LanguageCode, 'Wrong language code.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageNameByLanguageCodeEmptyCode()
    var
        LanguageName: Text;
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup
        Init();

        // [When] Get language name by an empty code
        LanguageName := Language.GetWindowsLanguageName('');

        // [Then] Empty name is returned
        Assert.AreEqual('', LanguageName, 'Language name is supposed to be empty when provided empty language code.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageNameByLanguageCodInvalidCode()
    var
        LanguageName: Text;
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup
        Init();

        // [When] Get language name by an invalid code
        LanguageName := Language.GetWindowsLanguageName('INVALID');

        // [Then] Empty name is returned
        Assert.AreEqual('', LanguageName, 'Language name is supposed to be empty when provided invalid language code.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageNameByLanguageCodValidCode()
    var
        LanguageName: Text;
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup
        Init();

        // [When] Get language name by a valid code
        LanguageName := Language.GetWindowsLanguageName('BG');

        // [Then] The correct language name is returned
        Assert.AreEqual('Bulgarian (Bulgaria)', LanguageName, 'Wrong language name.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageNameByLanguageIdZeroId()
    var
        LanguageName: Text;
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup
        Init();

        // [When] Get language name by an ID which is 0
        LanguageName := Language.GetWindowsLanguageName(0);

        // [Then] Empty name is returned
        Assert.AreEqual('', LanguageName, 'Language name is supposed to be empty when provided an id that''s 0.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageNameByLanguageIdInvalidId()
    var
        LanguageName: Text;
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup
        Init();

        // [When] Get language name by an invalid ID
        LanguageName := Language.GetWindowsLanguageName(-88);

        // [Then] Empty name is returned
        Assert.AreEqual('', LanguageName, 'Language name is supposed to be empty when provided an ivalid id.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageNameByLanguageIdValidId()
    var
        LanguageName: Text;
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup
        Init();

        // [When] Get language name by a valid ID
        LanguageName := Language.GetWindowsLanguageName(1036); // fr-FR

        // [Then] The correct language name is returned
        Assert.AreEqual('French (France)', LanguageName, 'Wrong language name.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetDefaultApplicationLanguageId()
    begin
        PermissionsMock.Set('Language Edit');
        Assert.AreEqual(1033, Language.GetDefaultApplicationLanguageId(), 'Wrong default application id'); // en-US
    end;

    [Test]
    procedure ValidateApplicationLanguageIdInvalidId()
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup
        Init();

        // [When] Validating an invalid language ID
        asserterror Language.ValidateApplicationLanguageId(-1);

        // [Then] An error occurs
        Assert.ExpectedError(StrSubstNo(LanguageNotFoundErr, -1));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ValidateApplicationLanguageIdValidId()
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup, no errors so far
        Init();
        ClearLastError();

        // [When] Validating a valid language ID
        Language.ValidateApplicationLanguageId(2057); // en-GB

        // [Then] No errors occur
        Assert.AreEqual('', GetLastErrorCode(), 'No error should occur.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ValidateWindowsLanguageIdInvalidId()
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup
        Init();

        // [When] Validating an invalid language ID
        asserterror Language.ValidateWindowsLanguageId(-12);

        // [Then] An error occurs
        Assert.ExpectedError(StrSubstNo(LanguageNotFoundErr, -12));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ValidateWindowsLanguageIdValidId()
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup
        Init();
        ClearLastError();

        // [When] Validating a valid language ID
        Language.ValidateWindowsLanguageId(2057); // en-GB

        // [Then] No errors occur
        Assert.AreEqual('', GetLastErrorCode(), 'No error should occur.');
    end;

    [Test]
    [HandlerFunctions('ApplicationLanguageCancelHandler')]
    [Scope('OnPrem')]
    procedure LookupApplicationLanguageIdOnCancel()
    var
        LanguageId: Integer;
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup and no preselected language
        Init();
        LanguageId := 0; // invalid language ID

        // [When] Looking up application language ID and "Cancel" is pressed
        Language.LookupApplicationLanguageId(LanguageId);

        // [Then] No language should be selected.
        Assert.AreEqual(0, LanguageId, 'No language should be selected');
    end;

    [Test]
    [HandlerFunctions('ApplicationLanguageOkHandler')]
    [Scope('OnPrem')]
    procedure LookupApplicationLanguageIdSelectLanguage()
    var
        LanguageId: Integer;
    begin
        PermissionsMock.Set('Language Edit');
        // [Given] A typical language setup and preselected language
        Init();
        LanguageId := 1033; // en-US

        // [When] Looking up application language ID and a language is selected
        Language.LookupApplicationLanguageId(LanguageId);

        // [Then] The correct language ID is returned.
        Assert.AreEqual(2057, LanguageId, 'Wrong selected language.');
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ApplicationLanguageCancelHandler(var WindowsLanguages: TestPage "Windows Languages")
    begin
        WindowsLanguages.Cancel().Invoke();
    end;

    [ModalPageHandler]
    procedure ApplicationLanguageOkHandler(var WindowsLanguages: TestPage "Windows Languages")
    begin
        WindowsLanguages.GOTOKEY(2057); // en-GB
        WindowsLanguages.OK().Invoke();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Language", 'OnGetUserLanguageCode', '', true, true)]
    local procedure VerifyOnGetUserLanguageCodeEventCalled(var UserLanguageCode: Code[10]; var Handled: Boolean)
    begin
        UserLanguageCode := 'RANDOM';
        Handled := true;
    end;

    local procedure Init()
    var
        LanguageLocal: Record Language;
    begin
        if IsInitialized then
            EXIT;

        LanguageLocal.DeleteAll();

        LanguageLocal.Init();
        LanguageLocal.Validate(Code, 'GB');
        LanguageLocal.Validate("Windows Language ID", 2057); // en-GB
        LanguageLocal.Validate(Name, 'English GB');
        LanguageLocal.Insert();

        LanguageLocal.Init();
        LanguageLocal.Validate(Code, 'US');
        LanguageLocal.Validate("Windows Language ID", 1033); // en-US
        LanguageLocal.Validate(Name, 'English US');
        LanguageLocal.Insert();

        LanguageLocal.Init();
        LanguageLocal.Validate(Code, 'FR');
        LanguageLocal.Validate("Windows Language ID", 1036); // fr-FR
        LanguageLocal.Validate(Name, 'French');
        LanguageLocal.Insert();

        LanguageLocal.Init();
        LanguageLocal.Validate(Code, 'BG');
        LanguageLocal.Validate("Windows Language ID", 1026); // bg-BG
        LanguageLocal.Validate(Name, 'Bulgarian');
        LanguageLocal.Insert();

        IsInitialized := true;
    end;
}

