// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 130043 "Language Management Test"
{
    // Tests for Language Management codeunit

    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        LanguageManagement: Codeunit "Language Management";
        IsInitialized: Boolean;

    [Test]
    [Scope('OnPrem')]
    procedure GetUserLanguageCodeRaisesEvent()
    var
        LanguageManagementTest: Codeunit "Language Management Test";
        LanguageCode: Code[10];
    begin
        // [Given] A typical language setup. A event subscriber for OnGetUserLanguageCode is present.
        Init();
        BINDSUBSCRIPTION(LanguageManagementTest);

        // [When] Getting the current user's language code
        LanguageCode := LanguageManagement.GetUserLanguageCode();

        // [Then] The event OnGetUserLanguageCode is called and language code is as set
        Assert.AreEqual('RANDOM', LanguageCode, 'Wrong language code.');

        UNBINDSUBSCRIPTION(LanguageManagementTest);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetUserLanguageCodeReturnGlobalLanguage()
    var
        LanguageCode: Code[10];
    begin
        // [Given] A typical language setup. No event subscriber for OnGetUserLanguageCode is present. Global language is set to Bulgarian
        Init();
        GlobalLanguage(1026); // bg-BG

        // [When] Getting the current user's language code
        LanguageCode := LanguageManagement.GetUserLanguageCode();

        // [Then] The correct language code is returned.
        Assert.AreEqual('BG', LanguageCode, 'Wrong language code.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageIdByLanguageCodeEmptyCode()
    var
        LanguageId: Integer;
    begin
        // [Given] A typical language setup
        Init();

        // [When] Getting language id by an empty code
        LanguageId := LanguageManagement.GetLanguageIdByLanguageCode('');

        // [Then] The id of the current language is returned
        Assert.AreEqual(GlobalLanguage(), LanguageId, 'Wrong language id.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageIdByLanguageCodeInvalidCode()
    var
        LanguageId: Integer;
    begin
        // [Given] A typical language setup
        Init();

        // [When] Getting language id by an invalid code
        LanguageId := LanguageManagement.GetLanguageIdByLanguageCode('INVALID');

        // [Then] The id of the current language is returned
        Assert.AreEqual(GlobalLanguage(), LanguageId, 'Wrong language id.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageIdByLanguageCodeValidCode()
    var
        LanguageId: Integer;
    begin
        // [Given] A typical language setup
        Init();

        // [When] Getting language id by a valid code
        LanguageId := LanguageManagement.GetLanguageIdByLanguageCode('FR');

        // [Then] The id of the correct language is returned
        Assert.AreEqual(1036, LanguageId, 'Wrong language id.'); // fr-FR
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageCodeByLanguageIdZeroIdTest()
    var
        LanguageCode: Code[10];
    begin
        // [Given] A typical language setup
        Init();

        // [When] Getting language code by id which is 0
        LanguageCode := LanguageManagement.GetLanguageCodeByLanguageId(0);

        // [Then] Empty code is returned
        Assert.AreEqual('', LanguageCode, 'Language code should be empty when language id is 0.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageCodeByLanguageIdInvalidId()
    var
        LanguageCode: Code[10];
    begin
        // [Given] A typical language setup
        Init();

        // [When] Getting language id by an invalid id
        LanguageCode := LanguageManagement.GetLanguageCodeByLanguageId(-42);

        // [Then] Empty code is returned
        Assert.AreEqual('', LanguageCode, 'Language code should be empty when language id is invalid.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageCodeByLanguageIdValidId()
    var
        LanguageCode: Code[10];
    begin
        // [Given] A typical language setup
        Init();

        // [When] Getting language id by a valid id
        LanguageCode := LanguageManagement.GetLanguageCodeByLanguageId(1026); // bg-BG

        // [Then] Empty code is returned
        Assert.AreEqual('BG', LanguageCode, 'Wrong language code.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageNameByLanguageCodeEmptyCode()
    var
        LanguageName: Text;
    begin
        // [Given] A typical language setup
        Init();

        // [When] Getting language name by an empty code
        LanguageName := LanguageManagement.GetWindowsLanguageNameByLanguageCode('');

        // [Then] Empty name is returned
        Assert.AreEqual('', LanguageName, 'Language name is supposed to be empty when provided empty language code.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageNameByLanguageCodInvalidCode()
    var
        LanguageName: Text;
    begin
        // [Given] A typical language setup
        Init();

        // [When] Getting language name by an invalid code
        LanguageName := LanguageManagement.GetWindowsLanguageNameByLanguageCode('INVALID');

        // [Then] Empty name is returned
        Assert.AreEqual('', LanguageName, 'Language name is supposed to be empty when provided invalid language code.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageNameByLanguageCodValidCode()
    var
        LanguageName: Text;
    begin
        // [Given] A typical language setup
        Init();

        // [When] Getting language name by a valid code
        LanguageName := LanguageManagement.GetWindowsLanguageNameByLanguageCode('BG');

        // [Then] Empty name is returned
        Assert.AreEqual('Bulgarian (Bulgaria)', LanguageName, 'Wrong language name.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageNameByLanguageIdZeroId()
    var
        LanguageName: Text;
    begin
        // [Given] A typical language setup
        Init();

        // [When] Getting language name by an id which is 0
        LanguageName := LanguageManagement.GetWindowsLanguageNameByLanguageId(0);

        // [Then] Empty name is returned
        Assert.AreEqual('', LanguageName, 'Language name is supposed to be empty when provided an id that''s 0.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageNameByLanguageIdInvalidId()
    var
        LanguageName: Text;
    begin
        // [Given] A typical language setup
        Init();

        // [When] Getting language name by an invalid id
        LanguageName := LanguageManagement.GetWindowsLanguageNameByLanguageId(-88);

        // [Then] Empty name is returned
        Assert.AreEqual('', LanguageName, 'Language name is supposed to be empty when provided an ivalid id.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetLanguageNameByLanguageIdValidId()
    var
        LanguageName: Text;
    begin
        // [Given] A typical language setup
        Init();

        // [When] Getting language name by a valid id
        LanguageName := LanguageManagement.GetWindowsLanguageNameByLanguageId(1036); // fr-FR

        // [Then] Empty name is returned
        Assert.AreEqual('French (France)', LanguageName, 'Wrong language name.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetDefaultApplicationLanguageId()
    begin
        Assert.AreEqual(1033, LanguageManagement.GetDefaultApplicationLanguageId(), 'Wrong default application id'); // en-US
    end;

    [Test]
    procedure ValidateApplicationLanguageIdInvalidId()
    begin
        // [Given] A typical language setup
        Init();

        // [When] Validating an invalid language id
        ASSERTERROR LanguageManagement.ValidateApplicationLanguageId(-1);

        // [Then] An error occurs
        Assert.ExpectedError('The language -1 could not be found.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ValidateApplicationLanguageIdValidId()
    begin
        // [Given] A typical language setup, no errors so far
        Init();
        ClearLastError();

        // [When] Validating a valid language id
        LanguageManagement.ValidateApplicationLanguageId(2057); // en-GB

        // [Then] No errors occur
        Assert.AreEqual('', GetLastErrorCode(), 'No error should occur.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ValidateWindowsLanguageIdInvalidId()
    begin
        // [Given] A typical language setup
        Init();

        // [When] Validating an invalid language id
        ASSERTERROR LanguageManagement.ValidateWindowsLanguageId(-12);

        // [Then] An error occurs
        Assert.ExpectedError('The language -12 could not be found.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ValidateWindowsLanguageIdValidId()
    begin
        // [Given] A typical language setup
        Init();

        // [When] Validating a valid language id
        LanguageManagement.ValidateWindowsLanguageId(2057); // en-GB

        // [Then] No errors occur
    end;

    [Test]
    [HandlerFunctions('ApplicationLanguageCancelHandler')]
    [Scope('OnPrem')]
    procedure LookupApplicationLanguageIdOnCancel()
    var
        LanguageId: Integer;
    begin
        // [Given] A typical language setup and no preselected language
        Init();
        LanguageId := 0; // invalid language ID

        // [When] Looking up application language ID and "Cancel" is pressed
        LanguageManagement.LookupApplicationLanguageId(LanguageId);

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
        // [Given] A typical language setup and preselected language
        Init();
        LanguageId := 1033; // en-US

        // [When] Looking up application language ID and "Ok" is pressed
        LanguageManagement.LookupApplicationLanguageId(LanguageId);

        // [Then] The right language should be selected.
        Assert.AreEqual(2057, LanguageId, 'Wrong selected language.');
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ApplicationLanguageCancelHandler(var WindowsLanguages: TestPage "Windows Languages")
    begin
        Assert.AreEqual(0, WindowsLanguages."Language ID".AsInteger(), 'No language should be preselected.');

        WindowsLanguages.Cancel().Invoke();
    end;

    [ModalPageHandler]
    procedure ApplicationLanguageOkHandler(var WindowsLanguages: TestPage "Windows Languages")
    begin
        Assert.AreEqual(1033, WindowsLanguages."Language ID".AsInteger(), 'Wrong preselected language.');

        WindowsLanguages.GOTOKEY(2057); // en-GB
        WindowsLanguages.OK().Invoke();
    end;

    [EventSubscriber(ObjectType::Codeunit, 43, 'OnGetUserLanguageCode', '', true, true)]
    local procedure VerifyOnGetUserLanguageCodeEventCalled(var UserLanguageCode: Code[10]; var Handled: Boolean)
    begin
        UserLanguageCode := 'RANDOM';
        Handled := true;
    end;

    local procedure Init()
    var
        Language: Record Language;
    begin
        if IsInitialized then
            EXIT;

        Language.DeleteAll();

        Language.Init();
        Language.Validate(Code, 'GB');
        Language.Validate("Windows Language ID", 2057); // en-GB
        Language.Validate(Name, 'English GB');
        Language.Insert();

        Language.Init();
        Language.Validate(Code, 'US');
        Language.Validate("Windows Language ID", 1033); // en-US
        Language.Validate(Name, 'English US');
        Language.Insert();

        Language.Init();
        Language.Validate(Code, 'FR');
        Language.Validate("Windows Language ID", 1036); // fr-FR
        Language.Validate(Name, 'French');
        Language.Insert();

        Language.Init();
        Language.Validate(Code, 'BG');
        Language.Validate("Windows Language ID", 1026); // bg-BG
        Language.Validate(Name, 'Bulgarian');
        Language.Insert();

        IsInitialized := true;
    end;
}

