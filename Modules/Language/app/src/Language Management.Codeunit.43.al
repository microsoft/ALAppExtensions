// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 43 "Language Management"
{
    // <summary>
    // Management codeunit that exposes various functions to work with languages.
    // </summary>

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        LanguageManagementImpl: Codeunit "Language Management Impl.";

    procedure GetUserLanguageCode(): Code[10]
    begin
        // <summary>
        // Gets the current user's language code.
        // The function emits the <see cref="OnGetUserLanguageCode"/> event.
        // To change the language code returned from this function, subscribe for this event and change the passed language code.
        // </summary>
        // <seealso cref="OnGetUserLanguageCode"/>
        // <returns>The language code of the user's language.</returns>

        exit(LanguageManagementImpl.GetUserLanguageCode);
    end;

    procedure GetLanguageIdByLanguageCode(LanguageCode: Code[10]): Integer
    begin
        // <summary>
        // Gets the language ID based on its code.
        // </summary>
        // <param name="LanguageCode">The code of the language</param>
        // <returns>The ID for the language code that was provided for this function. If no ID is found for the language code, then it returns the ID of the current user's language.</returns>

        exit(LanguageManagementImpl.GetLanguageIdByLanguageCode(LanguageCode));
    end;

    procedure GetLanguageCodeByLanguageId(LanguageId: Integer): Code[10]
    begin
        // <summary>
        // Gets the code for a language based on its ID.
        // </summary>
        // <param name="LanguageId">The ID of the language.</param>
        // <returns>The code of the language that corresponds to the ID, or an empty code if the language with the specified ID does not exist.</returns>

        exit(LanguageManagementImpl.GetLanguageCodeByLanguageId(LanguageId));
    end;

    procedure GetWindowsLanguageNameByLanguageCode(LanguageCode: Code[10]): Text
    begin
        // <summary>
        // Gets the name of a language based on the language code.
        // </summary>
        // <param name="LanguageCode">The code of the language.</param>
        // <returns>The name of the language corresponding to the code or empty string, if language with the specified code does not exist</returns>

        exit(LanguageManagementImpl.GetWindowsLanguageNameByLanguageCode(LanguageCode));
    end;

    procedure GetWindowsLanguageNameByLanguageId(LanguageId: Integer): Text
    begin
        // <summary>
        // Gets the name of a windows language based on its ID.
        // </summary>
        // <param name="LanguageId">The ID of the language.</param>
        // <returns>The name of the language that corresponds to the ID, or an empty string if a language with the specified ID does not exist.</returns>

        exit(LanguageManagementImpl.GetWindowsLanguageNameByLanguageId(LanguageId));
    end;

    procedure GetApplicationLanguages(var TempLanguage: Record "Windows Language" temporary)
    begin
        // <summary>
        // Gets all available languages in the application.
        // The function emits the <see cref="OnAfterGetApplicationLanguages"/> event.
        // </summary>
        // <seealso cref="OnAfterGetApplicationLanguages"/>
        // <param name="TempLanguage">A temporary record to place the result in</param>

        LanguageManagementImpl.GetApplicationLanguages(TempLanguage);
    end;

    procedure GetDefaultApplicationLanguageId(): Integer
    begin
        // <summary>
        // Gets the default application language ID.
        // </summary>

        exit(LanguageManagementImpl.GetDefaultApplicationLanguageId);
    end;

    procedure ValidateApplicationLanguageId(LanguageId: Integer)
    begin
        // <summary>
        // Checks whether the provided language is a valid application language.
        // If it isn't, the function displays an error.
        // </summary>
        // <param name="LanguageId">The ID of the language to validate.</param>

        LanguageManagementImpl.ValidateApplicationLanguageId(LanguageId);
    end;

    procedure ValidateWindowsLanguageId(LanguageId: Integer)
    begin
        // <summary>
        // Checks whether the provided language exists. If it doesn't, the function displays an error.
        // </summary>
        // <param name="LanguageId">The ID of the language to validate.</param>

        LanguageManagementImpl.ValidateWindowsLanguageId(LanguageId);
    end;

    procedure LookupApplicationLanguageId(var LanguageId: Integer)
    begin
        // <summary>
        // Opens a list of the languages that are available for the application so that the user can choose a language.
        // </summary>
        // <param name="LanguageId">Exit parameter that holds the chosen language ID.</param>

        LanguageManagementImpl.LookupApplicationLanguageId(LanguageId);
    end;

    procedure LookupWindowsLanguageId(var LanguageId: Integer)
    begin
        // <summary>
        // Opens a list of languages that are available for the Windows version.
        // </summary>
        // <param name="LanguageId">Exit parameter that holds the chosen language ID.</param>

        LanguageManagementImpl.LookupWindowsLanguageId(LanguageId);
    end;

    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    procedure OnGetUserLanguageCode(var UserLanguageCode: Code[10];var Handled: Boolean)
    begin
        // <summary>
        // Integration event, emitted from <see cref="GetUserLanguageCode"/>.
        // Subscribe to this event to change the default behavior by changing the provided parameter(s).
        // </summary>
        // <seealso cref="GetUserLanguageCode"/>
        // <param name="UserLanguageId">Exit parameter that holds the user language ID.</param>
        // <param name="IsHandled">To change the default behavior of the function that emits the event, set this parameter to true.</param>
    end;

    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    procedure OnAfterGetApplicationLanguages(var TempLanguage: Record "Windows Language" temporary)
    begin
        // <summary>
        // Integration event, emitted from <see cref="GetApplicationLanguages"/>.
        // Subscribe to this event to modify the list of application languages.
        // </summary>
        // <seealso cref="GetApplicationLanguages"/>
        // <param name="TempLanguage">Temporary record that contains the available application languages.</param>
    end;
}

