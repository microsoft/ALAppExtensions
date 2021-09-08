// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Displays details about the selected extension, and offers features for installing and uninstalling it.
/// </summary>
page 2501 "Extension Details"
{
    Extensible = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = NavigatePage;
    SourceTable = "Published Application";
    SourceTableTemporary = true;
    ContextSensitiveHelpPage = 'ui-extensions';
    Permissions = tabledata "Published Application" = r,
                  tabledata "Windows Language" = r;

    layout
    {
        area(content)
        {
            group("Install NAV Extension")
            {
                Caption = 'Install Extension';
                Editable = false;
                Visible = Step1Enabled;
                group(InstallGroup)
                {
                    Caption = 'Install Extension';
                    Editable = false;
                    InstructionalText = 'Extensions add new capabilities that extend and enhance functionality.';
                    field(In_Name; Name)
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        ToolTip = 'Specifies the name of the extension.';
                    }
                    field(In_Des; AppDescription)
                    {
                        ApplicationArea = All;
                        Caption = 'Description';
                        Editable = false;
                        MultiLine = true;
                        ToolTip = 'Specifies the description of the extension.';
                    }
                    field(In_Ver; VersionDisplay)
                    {
                        ApplicationArea = All;
                        Caption = 'Version';
                        ToolTip = 'Specifies the version of the extension.';
                    }
                    field(In_Pub; Publisher)
                    {
                        ApplicationArea = All;
                        Caption = 'Publisher';
                        ToolTip = 'Specifies the publisher of the extension.';
                    }
                    field(In_Id; AppIdDisplay)
                    {
                        ApplicationArea = All;
                        Caption = 'App ID';
                        ToolTip = 'Specifies the app ID of the extension.';
                    }
                    field(In_PublishedAs; "Published As")
                    {
                        ApplicationArea = All;
                        Caption = 'Published As';
                        Editable = false;
                        ToolTip = 'Specifies whether the extension is published as a per-tenant, development, or a global extension.';
                    }
                    field(In_Url; UrlLbl)
                    {
                        ApplicationArea = All;
                        Caption = 'Website';
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'Open a website for more information about the extension.';

                        trigger OnDrillDown()
                        begin
                            HyperLink(Url);
                        end;
                    }
                    field(In_Help; HelpLbl)
                    {
                        ApplicationArea = All;
                        Caption = 'Help';
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'Get help with using the extension.';

                        trigger OnDrillDown()
                        begin
                            HyperLink(Help);
                        end;
                    }
                }
            }
            group("Uninstall NAV Extension")
            {
                Caption = 'Uninstall Extension';
                Visible = IsInstalled;
                group(UninstallGroup)
                {
                    Caption = 'Uninstall Extension';
                    InstructionalText = 'Uninstall extension to remove added features.';
                    field(Un_Name; Name)
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        Editable = false;
                        ToolTip = 'Specifies the name of the extension.';
                    }
                    field(Un_Des; AppDescription)
                    {
                        ApplicationArea = All;
                        Caption = 'Description';
                        ToolTip = 'Specifies the description of the extension.';
                        Editable = false;
                        MultiLine = true;
                    }
                    field(Un_Ver; VersionDisplay)
                    {
                        ApplicationArea = All;
                        Caption = 'Version';
                        ToolTip = 'Specifies the version of the extension.';
                        Editable = false;
                    }
                    field(Un_Pub; Publisher)
                    {
                        ApplicationArea = All;
                        Caption = 'Publisher';
                        ToolTip = 'Specifies the publisher of the extension.';
                        Editable = false;
                    }
                    field(Un_Id; AppIdDisplay)
                    {
                        ApplicationArea = All;
                        Caption = 'App ID';
                        ToolTip = 'Specifies the app ID of the extension.';
                        Editable = false;
                    }
                    field(Un_PublishedAs; "Published As")
                    {
                        ApplicationArea = All;
                        Caption = 'Published As';
                        Editable = false;
                        ToolTip = 'Specifies whether the extension is published as a per-tenant, development, or a global extension.';
                    }
                    field(Un_ClearSchema; ClearSchema)
                    {
                        ApplicationArea = All;
                        Caption = 'Delete Extension Data';
                        Editable = true;
                        ToolTip = 'Specifies if the tables that contain data owned by this extension should be deleted on uninstall. This action cannot be undone.';

                        trigger OnValidate()
                        begin
                            ExtensionInstallationImpl.GetClearExtensionSchemaConfirmation("Package ID", ClearSchema);
                        end;
                    }
                    field(Un_Terms; TermsLbl)
                    {
                        ApplicationArea = All;
                        Caption = 'Terms and Conditions';
                        ToolTip = 'View the terms and conditions for the extension.';
                        Editable = false;
                        ShowCaption = false;
                        Visible = Legal;

                        trigger OnDrillDown()
                        var
                            EnvironmentInfo: Codeunit "Environment Information";
                        begin
                            if EnvironmentInfo.IsSaaS() then
                                if EULA = OnPremEULALbl then
                                    EULA := SaaSEULALbl;
                            HyperLink(EULA);
                        end;
                    }
                    field(Un_Privacy; PrivacyLbl)
                    {
                        ApplicationArea = All;
                        Caption = 'Privacy Statement';
                        ToolTip = 'View the privacy statement for the extension.';
                        Editable = false;
                        ShowCaption = false;
                        Visible = Legal;

                        trigger OnDrillDown()
                        var
                            EnvironmentInfo: Codeunit "Environment Information";
                        begin
                            if EnvironmentInfo.IsSaaS() then
                                if "Privacy Statement" = OnPremPrivacyLbl then
                                    "Privacy Statement" := SaaSPrivacyLbl;
                            HyperLink("Privacy Statement");
                        end;
                    }
                    field(Un_Url; UrlLbl)
                    {
                        ApplicationArea = All;
                        Caption = 'Website';
                        ToolTip = 'Opens the extension''s website.';
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            HyperLink(Url);
                        end;
                    }
                    field(Un_Help; HelpLbl)
                    {
                        ApplicationArea = All;
                        Caption = 'Help';
                        ToolTip = 'Get help with using the extension.';
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            HyperLink(Help);
                        end;
                    }
                }
            }
            group(Installation)
            {
                Caption = 'Installation';
                Visible = BackEnabled;
                group("Review Extension Information before installation")
                {
                    Caption = 'Review Extension Information before installation';
                    field(Name; Name)
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        ToolTip = 'Specifies the name of the extension.';
                        Editable = false;
                    }
                    field(Publisher; Publisher)
                    {
                        ApplicationArea = All;
                        Caption = 'Publisher';
                        ToolTip = 'Specifies the publisher of the extension.';
                        Editable = false;
                    }
                    field(Language; LanguageName)
                    {
                        ApplicationArea = All;
                        Caption = 'Language';
                        ToolTip = 'Specifies the language of the extension.';
                        Editable = false;

                        trigger OnAssistEdit()
                        var
                            Language: Codeunit Language;
                        begin
                            Language.LookupApplicationLanguageId(LanguageID);
                            LanguageName := Language.GetWindowsLanguageName(LanguageID);
                        end;
                    }
                    group(Control30)
                    {
                        ShowCaption = false;
                        Visible = Legal;
                        field(Terms; TermsLbl)
                        {
                            ApplicationArea = All;
                            Caption = 'Terms and Conditions';
                            ToolTip = 'View the terms and conditions for the extension.';
                            Editable = false;
                            ShowCaption = false;
                            Visible = Legal;

                            trigger OnDrillDown()
                            begin
                                HyperLink(EULA);
                            end;
                        }
                        field(Privacy; PrivacyLbl)
                        {
                            ApplicationArea = All;
                            Caption = 'Privacy Statement';
                            ToolTip = 'View the privacy statement for the extension.';
                            Editable = false;
                            ShowCaption = false;
                            Visible = Legal;

                            trigger OnDrillDown()
                            begin
                                HyperLink("Privacy Statement");
                            end;
                        }
                        field(Accepted; IsAccepted)
                        {
                            ApplicationArea = All;
                            Caption = 'I accept the terms and conditions';
                            ToolTip = 'Acceptance of terms and conditions.';
                            Visible = Legal;
                        }
                    }
                }
            }
            group(Links)
            {
                Caption = 'Application operation best practices links';
                ShowCaption = false;
                Visible = true;
                field(BestPractices; 'Read more about the best practices for installing and publishing extensions')
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Editable = false;
                    ToolTip = 'Read more about the best practices for installing and publishing extensions.';

                    trigger OnDrillDown()
                    var
                        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
                    begin
                        Hyperlink(ExtensionInstallationImpl.GetInstallationBestPracticesURL());
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Back)
            {
                ApplicationArea = All;
                Caption = 'Back';
                ToolTip = 'Back';
                Image = PreviousRecord;
                InFooterBar = true;
                Visible = BackEnabled;

                trigger OnAction()
                begin
                    BackEnabled := false;
                    NextEnabled := true;
                    Step1Enabled := true;
                    InstallEnabled := false;
                end;
            }
            action(Next)
            {
                ApplicationArea = All;
                Caption = 'Next';
                ToolTip = 'Next';
                Image = NextRecord;
                InFooterBar = true;
                Visible = NextEnabled;

                trigger OnAction()
                begin
                    BackEnabled := true;
                    NextEnabled := false;
                    Step1Enabled := false;
                    InstallEnabled := true;
                end;
            }
            action(Install)
            {
                ApplicationArea = All;
                Caption = 'Install';
                ToolTip = 'Install';
                Enabled = IsAccepted;
                Image = Approve;
                InFooterBar = true;
                Visible = InstallEnabled AND (not IsInstalled);

                trigger OnAction()
                begin
                    ExtensionInstallationImpl.InstallExtensionWithConfirmDialog("Package ID", LanguageID);
                    CurrPage.Close();
                end;
            }
            action(Uninstall)
            {
                ApplicationArea = All;
                Caption = 'Uninstall';
                ToolTip = 'Uninstall';
                Image = Approve;
                InFooterBar = true;
                Visible = IsInstalled;

                trigger OnAction()
                begin
                    ExtensionInstallationImpl.UninstallExtensionWithConfirmDialog("Package ID", false, ClearSchema);
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        PublishedApplication.SetRange("Package ID", "Package ID");
        PublishedApplication.SetRange("Tenant Visible", true);

        if not PublishedApplication.FindFirst() then
            CurrPage.Close();

        SetPublishedAppRecord();
        SetPageConfig();
        SetLanguageConfig();
    end;

    var
        PublishedApplication: Record "Published Application";
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
        AppDescription: BigText;
        AppIdDisplay: Text;
        VersionDisplay: Text;
        LanguageName: Text;
        LanguageID: Integer;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        InstallEnabled: Boolean;
        IsAccepted: Boolean;
        IsInstalled: Boolean;
        Legal: Boolean;
        Step1Enabled: Boolean;
        ClearSchema: Boolean;
        InstallationPageCaptionMsg: Label 'Extension Installation', Comment = 'Caption for when extension needs to be installed';
        UninstallationPageCaptionMsg: Label 'Extension Uninstallation', Comment = 'Caption for when extension needs to be uninstalled';
        TermsLbl: Label 'Terms and Conditions';
        PrivacyLbl: Label 'Privacy Statement', Comment = 'Label for privacy statement link';
        UrlLbl: Label 'Website';
        HelpLbl: Label 'Help';
        SaaSEULALbl: Label ' https://go.microsoft.com/fwlink/?linkid=834880', Locked = true;
        SaaSPrivacyLbl: Label 'https://go.microsoft.com/fwlink/?linkid=834881', Locked = true;
        OnPremEULALbl: Label 'https://go.microsoft.com/fwlink/?linkid=2009120', Locked = true;
        OnPremPrivacyLbl: Label 'https://go.microsoft.com/fwlink/?LinkId=724009', Locked = true;

    local procedure SetPublishedAppRecord()
    var
        DescriptionStream: InStream;
    begin
        TransferFields(PublishedApplication, true);

        AppIdDisplay := LowerCase(DelChr(Format(ID), '=', '{}'));
        VersionDisplay :=
          ExtensionInstallationImpl.GetVersionDisplayString(PublishedApplication);
        PublishedApplication.CalcFields(Description);
        PublishedApplication.Description.CreateInStream(DescriptionStream, TEXTENCODING::UTF8);
        AppDescription.Read(DescriptionStream);

        Insert();
    end;

    local procedure SetLanguageConfig()
    var
        WinLanguagesTable: Record "Windows Language";
    begin
        LanguageID := GlobalLanguage();
        WinLanguagesTable.SetRange("Language ID", LanguageID);
        if WinLanguagesTable.FindFirst() then
            LanguageName := WinLanguagesTable.Name;
    end;

    local procedure SetPageConfig()
    begin
        IsInstalled := ExtensionInstallationImpl.IsInstalledByPackageId("Package ID");
        if IsInstalled then begin
            CurrPage.Caption(UninstallationPageCaptionMsg);
            NextEnabled := false;
            Step1Enabled := false;
        end else begin
            CurrPage.Caption(InstallationPageCaptionMsg);
            NextEnabled := true;
            Step1Enabled := true;
        end;

        // Any legal info to display
        Legal := ((StrLen("Privacy Statement") <> 0) or (StrLen(EULA) <> 0));

        // Auto accept if no legal info
        IsAccepted := not Legal;
    end;
}

