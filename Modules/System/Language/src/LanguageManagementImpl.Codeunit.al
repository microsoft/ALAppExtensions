// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Management codeunit that exposes various functions to work with languages.
/// </summary>
codeunit 54 "Language Management Impl."
{
    Access = Internal;
    SingleInstance = true;

    var
        LanguageManagement: Codeunit "Language Management";
        LanguageNotFoundErr: Label 'The language %1 could not be found.', Comment = '%1 = LanguageId';

        /// <summary>
        /// Gets the current user's language code.
        /// The function emits the <see cref="OnGetUserLanguageCode"/> event.
        /// To change the language code returned from this function, subscribe for this event and change the passed language code.
        /// </summary>
        /// <seealso cref="OnGetUserLanguageCode"/>
        /// <returns>The language code of the user's language.</returns>
    [Scope('OnPrem')]
    procedure GetUserLanguageCode() UserLanguageCode: Code[10]
    var
        Handled: Boolean;
    begin
        LanguageManagement.OnGetUserLanguageCode(UserLanguageCode, Handled);

        if not Handled then
            UserLanguageCode := GetLanguageCodeByLanguageId(GlobalLanguage());
    end;

    /// <summary>
    /// Gets the language ID based on its code.
    /// </summary>
    /// <param name="LanguageCode">The code of the language</param>
    /// <returns>The ID for the language code that was provided for this function. If no ID is found for the language code, then it returns the ID of the current user's language.</returns>

    [Scope('OnPrem')]
    procedure GetLanguageIdByLanguageCode(LanguageCode: Code[10]): Integer
    var
        Language: Record Language;
    begin
        if LanguageCode <> '' then
            if Language.Get(LanguageCode) then
                exit(Language."Windows Language ID");

        exit(GlobalLanguage());
    end;

    /// <summary>
    /// Gets the code for a language based on its ID.
    /// </summary>
    /// <param name="LanguageId">The ID of the language.</param>
    /// <returns>The code of the language that corresponds to the ID, or an empty code if the language with the specified ID does not exist.</returns>
    [Scope('OnPrem')]
    procedure GetLanguageCodeByLanguageId(LanguageId: Integer): Code[10]
    var
        Language: Record Language;
    begin
        if LanguageId = 0 then
            exit('');

        Language.SetRange("Windows Language ID", LanguageId);
        if Language.FindFirst() then;
        exit(Language.Code);
    end;

    /// <summary>
    /// Gets the name of a language based on the language code.
    /// </summary>
    /// <param name="LanguageCode">The code of the language.</param>
    /// <returns>The name of the language corresponding to the code or empty string, if language with the specified code does not exist</returns>
    [Scope('OnPrem')]
    procedure GetWindowsLanguageNameByLanguageCode(LanguageCode: Code[10]): Text
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

    /// <summary>
    /// Gets the name of a windows language based on its ID.
    /// </summary>
    /// <param name="LanguageId">The ID of the language.</param>
    /// <returns>The name of the language that corresponds to the ID, or an empty string if a language with the specified ID does not exist.</returns>
    [Scope('OnPrem')]
    procedure GetWindowsLanguageNameByLanguageId(LanguageId: Integer): Text
    var
        WindowsLanguage: Record "Windows Language";
    begin
        if LanguageId = 0 then
            exit('');

        if WindowsLanguage.Get(LanguageId) then
            exit(WindowsLanguage.Name);

        exit('');
    end;

    /// <summary>
    /// Gets all available languages in the application.
    /// The function emits the <see cref="OnAfterGetApplicationLanguages"/> event.
    /// </summary>
    /// <seealso cref="OnAfterGetApplicationLanguages"/>
    /// <param name="TempLanguage">A temporary record to place the result in</param>
    [Scope('OnPrem')]
    procedure GetApplicationLanguages(var TempLanguage: Record "Windows Language" temporary)
    var
        Language: Record "Windows Language";
    begin
        with Language do begin
            SetRange("Localization Exist", true);
            SetRange("Globally Enabled", true);

            if FindSet() then
                repeat
                    TempLanguage := Language;
                    TempLanguage.Insert();
                until Next() = 0;
        end;

        LanguageManagement.OnAfterGetApplicationLanguages(TempLanguage);
    end;

    /// <summary>
    /// Gets the default application language ID.
    /// </summary>
    [Scope('OnPrem')]
    procedure GetDefaultApplicationLanguageId(): Integer
    begin
        exit(1033); // en-US
    end;

    /// <summary>
    /// Checks whether the provided language is a valid application language.
    /// If it isn't, the function displays an error.
    /// </summary>
    /// <param name="LanguageId">The ID of the language to validate.</param>
    [Scope('OnPrem')]
    procedure ValidateApplicationLanguageId(LanguageId: Integer)
    var
        TempLanguage: Record "Windows Language" temporary;
    begin
        GetApplicationLanguages(TempLanguage);

        with TempLanguage do begin
            SetRange("Language ID", LanguageId);
            if IsEmpty() then
                Error(LanguageNotFoundErr, LanguageId);
        end;
    end;

    /// <summary>
    /// Checks whether the provided language exists. If it doesn't, the function displays an error.
    /// </summary>
    /// <param name="LanguageId">The ID of the language to validate.</param>
    [Scope('OnPrem')]
    procedure ValidateWindowsLanguageId(LanguageId: Integer)
    var
        WindowsLanguage: Record "Windows Language";
    begin
        WindowsLanguage.SetRange("Language ID", LanguageId);
        if WindowsLanguage.IsEmpty() then
            Error(LanguageNotFoundErr, LanguageId);
    end;

    /// <summary>
    /// Opens a list of the languages that are available for the application so that the user can choose a language.
    /// </summary>
    /// <param name="LanguageId">Exit parameter that holds the chosen language ID.</param>
    [Scope('OnPrem')]
    procedure LookupApplicationLanguageId(var LanguageId: Integer)
    var
        TempLanguage: Record "Windows Language" temporary;
    begin
        GetApplicationLanguages(TempLanguage);

        with TempLanguage do begin
            SetCurrentKey(Name);
            if Get(LanguageId) then;
            if PAGE.RunModal(PAGE::"Windows Languages", TempLanguage) = ACTION::LookupOK then
                LanguageId := "Language ID";
        end;
    end;

    /// <summary>
    /// Opens a list of languages that are available for the Windows version.
    /// </summary>
    /// <param name="LanguageId">Exit parameter that holds the chosen language ID.</param>
    [Scope('OnPrem')]
    procedure LookupWindowsLanguageId(var LanguageId: Integer)
    var
        WindowsLanguage: Record "Windows Language";
    begin
        with WindowsLanguage do begin
            SetCurrentKey(Name);
            if PAGE.RunModal(PAGE::"Windows Languages", WindowsLanguage) = ACTION::LookupOK then
                LanguageId := "Language ID";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000004, 'GetApplicationLanguage', '', false, false)]
    local procedure SetApplicationLanguageId(var language: Integer)
    begin
        language := GetDefaultApplicationLanguageId();
    end;
}

