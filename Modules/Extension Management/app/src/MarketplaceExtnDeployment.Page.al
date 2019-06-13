// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 2510 "Marketplace Extn Deployment"
{
    Caption = 'Extension Installation';
    PageType = NavigatePage;
    SourceTable = "NAV App";

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
            field(Language;LanguageName)
            {
                ApplicationArea = All;
                Caption = 'Language';
                Editable = false;

                trigger OnAssistEdit()
                var
                    LanguageManagement: Codeunit "Language Management";
                begin
                    LanguageManagement.LookupApplicationLanguageId(LanguageID);
                    LanguageName := LanguageManagement.GetWindowsLanguageNameByLanguageId(LanguageID);
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
                Caption = 'Install';
                InFooterBar = true;

                trigger OnAction()
                begin
                    ExtensionMarketplaceImpl.InstallMarketplaceExtension(ID,LanguageID);

                    CurrPage.Close();
                    exit;
                end;
            }
        }
    }

    trigger OnInit()
    var
        LanguageManagement: Codeunit "Language Management";
    begin
        LanguageID := GlobalLanguage();
        LanguageName := LanguageManagement.GetWindowsLanguageNameByLanguageId(LanguageID);
    end;

    var
        ExtensionMarketplaceImpl: Codeunit "Extension Marketplace";
        LanguageName: Text;
        LanguageID: Integer;
}

