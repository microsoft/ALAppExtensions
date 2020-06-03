// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides an interface for installing extensions from AppSource.
/// </summary>
page 2510 "Marketplace Extn Deployment"
{
    Extensible = false;
    Caption = 'Extension Installation';
    PageType = NavigatePage;
    ContextSensitiveHelpPage = 'ui-extensions';

    layout
    {
        area(content)
        {
            group(General)
            {
            }
            label("Choose Language")
            {
                ApplicationArea = All;
                Caption = 'Choose Language';
                Style = StandardAccent;
                StyleExpr = TRUE;
            }
            field(Language; LanguageName)
            {
                ApplicationArea = All;
                Caption = 'Language';
                ToolTip = 'Choose the language of the extension.';
                Editable = false;

                trigger OnAssistEdit()
                var
                    Language: Codeunit Language;
                begin
                    Language.LookupApplicationLanguageId(LanguageID);
                    LanguageName := Language.GetWindowsLanguageName(LanguageID);
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Install)
            {
                ApplicationArea = All;
                Image = CarryOutActionMessage;
                Caption = 'Install';
                ToolTip = 'Install the extension.';
                InFooterBar = true;

                trigger OnAction()
                begin
                    InstallSelected := true;

                    CurrPage.Close();
                    exit;
                end;
            }
        }
    }


    internal procedure GetLanguageId(): Integer
    begin
        exit(LanguageID);
    end;

    internal procedure GetInstalledSelected(): Boolean
    begin
        exit(InstallSelected);
    end;


    trigger OnInit()
    var
        LanguageManagement: Codeunit Language;
    begin
        LanguageID := GlobalLanguage();
        LanguageName := LanguageManagement.GetWindowsLanguageName(LanguageID);
        clear(InstallSelected);
    end;

    var
        LanguageName: Text;
        LanguageID: Integer;
        InstallSelected: Boolean;
}

