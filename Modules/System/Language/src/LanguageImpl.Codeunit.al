// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 54 "Language Impl."
{
    Access = Internal;
    SingleInstance = true;

    var
        LanguageNotFoundErr: Label 'The language %1 could not be found.', Comment = '%1 = Language ID';

    procedure GetUserLanguageCode() UserLanguageCode: Code[10]
    var
        Language: Codeunit Language;
        Handled: Boolean;
    begin
        Language.OnGetUserLanguageCode(UserLanguageCode, Handled);

        if not Handled then
            UserLanguageCode := GetLanguageCode(GlobalLanguage());
    end;

    procedure GetLanguageIdOrDefault(LanguageCode: Code[10]): Integer;
    var
        LanguageId: Integer;
    begin
        LanguageId := GetLanguageId(LanguageCode);

        if LanguageId = 0 then
            LanguageId := GlobalLanguage();

        exit(LanguageId);
    end;

    procedure GetLanguageId(LanguageCode: Code[10]): Integer
    var
        Language: Record Language;
    begin
        if LanguageCode <> '' then
            if Language.Get(LanguageCode) then
                exit(Language."Windows Language ID");

        exit(0);
    end;

    procedure GetLanguageCode(LanguageId: Integer): Code[10]
    var
        Language: Record Language;
    begin
        if LanguageId = 0 then
            exit('');

        Language.SetRange("Windows Language ID", LanguageId);
        if Language.FindFirst() then;

        exit(Language.Code);
    end;

    procedure GetWindowsLanguageName(LanguageCode: Code[10]): Text
    var
        Language: Record Language;
    begin
        if LanguageCode = '' then
            exit('');

        Language.SetAutoCalcFields("Windows Language Name");
        if Language.Get(LanguageCode) then
            exit(Language."Windows Language Name");

        exit('');
    end;

    procedure GetWindowsLanguageName(LanguageId: Integer): Text
    var
        WindowsLanguage: Record "Windows Language";
    begin
        if LanguageId = 0 then
            exit('');

        if WindowsLanguage.Get(LanguageId) then
            exit(WindowsLanguage.Name);

        exit('');
    end;

    procedure GetApplicationLanguages(var TempLanguage: Record "Windows Language" temporary)
    var
        WindowsLanguage: Record "Windows Language";
    begin
        WindowsLanguage.SetRange("Localization Exist", true);
        WindowsLanguage.SetRange("Globally Enabled", true);

        if WindowsLanguage.FindSet() then
            repeat
                TempLanguage := WindowsLanguage;
                TempLanguage.Insert();
            until WindowsLanguage.Next() = 0;
    end;

    procedure GetDefaultApplicationLanguageId(): Integer
    begin
        exit(1033); // en-US
    end;

    procedure ValidateApplicationLanguageId(LanguageId: Integer)
    var
        TempLanguage: Record "Windows Language" temporary;
    begin
        GetApplicationLanguages(TempLanguage);

        TempLanguage.SetRange("Language ID", LanguageId);

        if TempLanguage.IsEmpty() then
            Error(LanguageNotFoundErr, LanguageId);
    end;

    procedure ValidateWindowsLanguageId(LanguageId: Integer)
    var
        WindowsLanguage: Record "Windows Language";
    begin
        WindowsLanguage.SetRange("Language ID", LanguageId);

        if WindowsLanguage.IsEmpty() then
            Error(LanguageNotFoundErr, LanguageId);
    end;

    procedure LookupApplicationLanguageId(var LanguageId: Integer)
    var
        TempLanguage: Record "Windows Language" temporary;
    begin
        GetApplicationLanguages(TempLanguage);

        TempLanguage.SetCurrentKey(Name);

        if TempLanguage.Get(LanguageId) then;

        if PAGE.RunModal(PAGE::"Windows Languages", TempLanguage) = ACTION::LookupOK then
            LanguageId := TempLanguage."Language ID";
    end;

    procedure LookupWindowsLanguageId(var LanguageId: Integer)
    var
        WindowsLanguage: Record "Windows Language";
    begin
        WindowsLanguage.SetCurrentKey(Name);

        if PAGE.RunModal(PAGE::"Windows Languages", WindowsLanguage) = ACTION::LookupOK then
            LanguageId := WindowsLanguage."Language ID";
    end;

    procedure GetParentLanguageId(LanguageId: Integer) ParentLanguageId: Integer
    begin
        if TryGetParentLanguageId(LanguageId, ParentLanguageId) then
            exit(ParentLanguageId);

        exit(LanguageId);
    end;

    [TryFunction]
    local procedure TryGetParentLanguageId(LanguageId: Integer; var ParentLanguageId: Integer)
    var
        CultureInfo: DotNet CultureInfo;
    begin
        ParentLanguageId := CultureInfo.CultureInfo(LanguageId).Parent().LCID();
    end;

    procedure SetPreferredLanguageID(UserSecID: Guid; NewLanguageID: Integer)
    var
        UserPersonalization: Record "User Personalization";
    begin
        if not UserPersonalization.Get(UserSecID) then
            exit;

        // Only lock the table if there is a change
        if UserPersonalization."Language ID" = NewLanguageId then
            exit; // No changes required

        UserPersonalization.LockTable();
        UserPersonalization.Get(UserSecID);
        UserPersonalization.Validate("Language ID", NewLanguageId);
        UserPersonalization.Validate("Locale ID", NewLanguageId);
        UserPersonalization.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000004, 'GetApplicationLanguage', '', false, false)]
    local procedure SetApplicationLanguageId(var language: Integer)
    begin
        language := GetDefaultApplicationLanguageId();
    end;
}

