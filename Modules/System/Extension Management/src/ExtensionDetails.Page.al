// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 2501 "Extension Details"
{
    Extensible = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = NavigatePage;
    SourceTable = "NAV App";
    SourceTableTemporary = true;

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
                    }
                    field(In_Des; AppDescription)
                    {
                        ApplicationArea = All;
                        Caption = 'Description';
                        Editable = false;
                        MultiLine = true;
                    }
                    field(In_Ver; VersionDisplay)
                    {
                        ApplicationArea = All;
                        Caption = 'Version';
                    }
                    field(In_Pub; Publisher)
                    {
                        ApplicationArea = All;
                        Caption = 'Publisher';
                    }
                    field(In_Id; AppIdDisplay)
                    {
                        ApplicationArea = All;
                        Caption = 'App ID';
                    }
                    field(In_Url; UrlLbl)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            HyperLink(Url);
                        end;
                    }
                    field(In_Help; HelpLbl)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;

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
                    Editable = false;
                    InstructionalText = 'Uninstall extension to remove added features.';
                    field(Un_Name; Name)
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                    }
                    field(Un_Des; AppDescription)
                    {
                        ApplicationArea = All;
                        Caption = 'Description';
                        Editable = false;
                        MultiLine = true;
                    }
                    field(Un_Ver; VersionDisplay)
                    {
                        ApplicationArea = All;
                        Caption = 'Version';
                    }
                    field(Un_Pub; Publisher)
                    {
                        ApplicationArea = All;
                        Caption = 'Publisher';
                    }
                    field(Un_Id; AppIdDisplay)
                    {
                        ApplicationArea = All;
                        Caption = 'App ID';
                    }
                    field(Un_Terms; TermsLbl)
                    {
                        ApplicationArea = All;
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
                        Editable = false;
                    }
                    field(Publisher; Publisher)
                    {
                        ApplicationArea = All;
                        Caption = 'Publisher';
                        Editable = false;
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
                    group(Control30)
                    {
                        ShowCaption = false;
                        Visible = Legal;
                        field(Terms; TermsLbl)
                        {
                            ApplicationArea = All;
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
                            Editable = false;
                            ShowCaption = false;
                            Visible = Legal;

                            trigger OnDrillDown()
                            begin
                                HyperLink("Privacy Statement");
                            end;
                        }
                        field(Accepted; Accepted)
                        {
                            ApplicationArea = All;
                            Caption = 'I accept the terms and conditions';
                            Visible = Legal;
                        }
                    }
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
                Enabled = Accepted;
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
                Image = Approve;
                InFooterBar = true;
                Visible = IsInstalled;

                trigger OnAction()
                begin
                    ExtensionInstallationImpl.UninstallExtensionWithConfirmDialog("Package ID");
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        NAVAppTable.SetRange("Package ID", "Package ID");
        if not NAVAppTable.FindFirst() then
            CurrPage.Close();

        SetNavAppRecord();
        SetPageConfig();
        SetLanguageConfig();
    end;

    var
        NAVAppTable: Record "NAV App";
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
        AppDescription: BigText;
        AppIdDisplay: Text;
        VersionDisplay: Text;
        LanguageName: Text;
        LanguageID: Integer;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        InstallEnabled: Boolean;
        Accepted: Boolean;
        IsInstalled: Boolean;
        Legal: Boolean;
        Step1Enabled: Boolean;
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

    local procedure SetNavAppRecord()
    var
        DescriptionStream: InStream;
    begin
        TransferFields(NAVAppTable, true);

        AppIdDisplay := LowerCase(DelChr(Format(ID), '=', '{}'));
        VersionDisplay :=
          ExtensionInstallationImpl.GetVersionDisplayString(NAVAppTable);
        NAVAppTable.CalcFields(Description);
        NAVAppTable.Description.CreateInStream(DescriptionStream, TEXTENCODING::UTF8);
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
        Accepted := not Legal;
    end;
}

