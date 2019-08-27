// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 2510 "Marketplace Extn Deployment"
{
    Extensible = false;
    Caption = 'Extension Installation';
    PageType = NavigatePage;

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
        Language: Codeunit Language;
    begin
        LanguageID := GlobalLanguage();
        LanguageName := Language.GetWindowsLanguageName(LanguageID);
        clear(InstallSelected);
    end;

    var
        ExtensionMarketplaceImpl: Codeunit "Extension Marketplace";
        LanguageName: Text;
        LanguageID: Integer;
        InstallSelected: Boolean;
}

