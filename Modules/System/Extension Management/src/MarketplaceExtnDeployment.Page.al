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
                Caption = 'Choose language';
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
#if not CLEAN21
            group(links)
            {
                ShowCaption = false;
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '21.0';
                ObsoleteReason = 'Not relevant anymore';

                field(BestPractices; 'Read more about the best practices for installing and publishing extensions')
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Read more about the best practices for installing and publishing extensions.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '21.0';
                    ObsoleteReason = 'Not relevant anymore';

                    trigger OnDrillDown()
                    var
                        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
                    begin
                        Hyperlink(ExtensionInstallationImpl.GetInstallationBestPracticesURL());
                    end;
                }
            }
#endif
            group(Info)
            {
                ShowCaption = false;

                field(ActiveUsers; ActiveUsersLbl)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Editable = false;
                    Style = Strong;
                    ToolTip = 'There might be other users working in the system.';
                }
                field(Warning; WarningLbl)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Editable = false;
                    ToolTip = 'Installing extensions during business hours will disrupt other users.';
                }
                field(RefreshInfo; RefreshInfoLbl)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Editable = false;
                    ToolTip = 'After installation, your session will refresh, and you can set up your extension.';
                }

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
                Image = Approve;
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

    internal procedure SetAppID(ID: Guid)
    begin
        AppID := ID;
    end;

    trigger OnInit()
    var
        LanguageManagement: Codeunit Language;
    begin
        LanguageID := GlobalLanguage();
        LanguageName := LanguageManagement.GetWindowsLanguageName(LanguageID);
        clear(InstallSelected);
    end;

    trigger OnOpenPage()
    var
        DataOutOfGeoAppImpl: Codeunit "Data Out Of Geo. App Impl.";
    begin
        DataOutOfGeoAppImpl.CheckAndFireNotification(AppID);
    end;

    var
        LanguageName: Text;
        LanguageID: Integer;
        InstallSelected: Boolean;
        AppID: Guid;
        ActiveUsersLbl: Label 'Note: There might be other users working in the system.';
        WarningLbl: Label 'Installing extensions during business hours will disrupt other users.';
        RefreshInfoLbl: Label 'After installation, your session will refresh, and you can set up your extension.';
}