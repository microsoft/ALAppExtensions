// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Lists the available extensions, and provides features for managing them.
/// </summary>
page 2500 "Extension Management"
{
    Caption = 'Extension Management';
    Extensible = false;
    AdditionalSearchTerms = 'app,add-in,customize,plug-in,appsource';
    ApplicationArea = All;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Details,Manage';
    RefreshOnActivate = true;
    SourceTable = "Published Application";
    SourceTableView = SORTING(Name)
                      ORDER(Ascending)
                      WHERE(Name = FILTER(<> '_Exclude_*'),
                            "Package Type" = FILTER(= Extension | Designer),
                            "Tenant Visible" = CONST(true));
    UsageCategory = Administration;
    ContextSensitiveHelpPage = 'ui-extensions';
    Permissions = tabledata "Published Application" = r;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field(Logo; Logo)
                {
                    ApplicationArea = All;
                    Caption = 'Logo';
                    ToolTip = 'Specifies the logo of the extension, such as the logo of the service provider.';
                }
                field("Is Installed"; IsInstalled)
                {
                    ApplicationArea = All;
                    Caption = 'Is Installed';
                    Style = Favorable;
                    StyleExpr = InfoStyle;
                    ToolTip = 'Specifies whether the extension is installed.';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the extension.';
                }
                field(Publisher; Publisher)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the publisher of the extension.';
                }
                field(Version; VersionDisplay)
                {
                    ApplicationArea = All;
                    Caption = 'Version';
                    ToolTip = 'Specifies the version of the extension.';
                }
                field("Published As"; "Published As")
                {
                    ApplicationArea = All;
                    Caption = 'Published As';
                    ToolTip = 'Specifies whether the extension is published as a per-tenant, development, or a global extension.';
                }

                label(Control18)
                {
                    ApplicationArea = All;
                    Enabled = IsSaaS;
                    HideValue = true;
                    ShowCaption = false;
                    Caption = '';
                    Style = Favorable;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies a spacer for ''Brick'' view mode.';
                    Visible = NOT IsOnPremDisplay;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(ActionGroup13)
            {
                Caption = 'Process';
                action(Install)
                {
                    ApplicationArea = All;
                    Caption = 'Install';
                    Enabled = ActionsEnabled AND (NOT IsInstalled);
                    Image = NewRow;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    Scope = Repeater;
                    ToolTip = 'Install the extension for the current tenant.';

                    trigger OnAction()
                    begin
                        if ExtensionInstallationImpl.RunExtensionInstallation(Rec) then
                            CurrPage.Update();
                    end;
                }
                action(Uninstall)
                {
                    ApplicationArea = All;
                    Caption = 'Uninstall';
                    Enabled = ActionsEnabled AND IsInstalled;
                    Image = RemoveLine;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    Scope = Repeater;
                    ToolTip = 'Remove the extension from the current tenant.';

                    trigger OnAction()
                    begin
                        if ExtensionInstallationImpl.RunExtensionInstallation(Rec) then
                            CurrPage.Update();
                    end;
                }
                action(Unpublish)
                {
                    ApplicationArea = All;
                    Caption = 'Unpublish';
                    Enabled = ActionsEnabled AND IsTenantExtension AND (not IsInstalled);
                    Image = RemoveLine;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    Scope = Repeater;
                    ToolTip = 'Unpublish the extension from the tenant.';

                    trigger OnAction()
                    begin
                        if ExtensionInstallationImpl.IsInstalledByPackageId("Package ID") then begin
                            Message(CannotUnpublishIfInstalledMsg, Name);
                            exit;
                        end;

                        ExtensionOperationImpl.UnpublishUninstalledPerTenantExtension("Package ID");
                    end;
                }
                action(Configure)
                {
                    ApplicationArea = All;
                    Caption = 'Configure';
                    Image = Setup;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    RunObject = Page "Extension Settings";
                    RunPageLink = "App ID" = FIELD(ID);
                    Scope = Repeater;
                    ToolTip = 'Configure the extension.';
                }
                action("Download Source")
                {
                    ApplicationArea = All;
                    Caption = 'Download Source';
                    Enabled = IsTenantExtension;
                    Image = ExportFile;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    Scope = Repeater;
                    ToolTip = 'Download the source code for the extension.';

                    trigger OnAction()
                    begin
                        ExtensionOperationImpl.DownloadExtensionSource("Package ID");
                    end;
                }
                action("Learn More")
                {
                    ApplicationArea = All;
                    Caption = 'Learn More';
                    Visible = HelpActionVisible;
                    Enabled = ActionsEnabled;
                    Image = Info;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    Scope = Repeater;
                    ToolTip = 'View information from the extension provider.';

                    trigger OnAction()
                    begin
                        HyperLink(Help);
                    end;
                }
                action(Refresh)
                {
                    ApplicationArea = All;
                    Caption = 'Refresh';
                    Image = Refresh;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Refresh the list of extensions.';

                    trigger OnAction()
                    begin
                        ActionsEnabled := false;
                        CurrPage.Update(false);
                    end;
                }
                action("Extension Marketplace")
                {
                    ApplicationArea = All;
                    Caption = 'Extension Marketplace';
                    Enabled = IsSaaS;
                    Image = NewItem;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ToolTip = 'Browse the extension marketplace for new extensions to install.';
                    Visible = NOT IsOnPremDisplay;
                    RunObject = page "Extension Marketplace";
                }
                action("Upload Extension")
                {
                    ApplicationArea = All;
                    Caption = 'Upload Extension';
                    Image = Import;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "Upload And Deploy Extension";
                    ToolTip = 'Upload an extension to your application.';
                    Visible = IsSaaS;
                }
                action("Deployment Status")
                {
                    ApplicationArea = All;
                    Caption = 'Deployment Status';
                    Image = View;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "Extension Deployment Status";
                    ToolTip = 'Check status for upload process for extensions.';
                    Visible = IsSaaS;
                }
                action(View)
                {
                    ApplicationArea = All;
                    Caption = 'View';
                    Enabled = ActionsEnabled;
                    Image = View;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    ShortCutKey = 'Return';
                    ToolTip = 'View extension details.';
                    Visible = NOT IsSaaS;

                    trigger OnAction()
                    begin
                        if ExtensionInstallationImpl.RunExtensionInstallation(Rec) then
                            CurrPage.Update();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        // Reenable page actions when record has been loaded/selected
        ActionsEnabled := true;

        DetermineExtensionConfigurations();

        VersionDisplay := GetVersionDisplayText();
        SetInfoStyleForIsInstalled();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        HelpActionVisible := StrLen(Help) > 0;
    end;

    trigger OnOpenPage()
    begin
        DetermineEnvironmentConfigurations();
        SetExtensionManagementFilter();
        if not IsInstallAllowed then
            CurrPage.Caption(SaaSCaptionTxt);

        // Temporary disable the page actions until extension is loaded/selected (OnAfterGetRecord)
        ActionsEnabled := false;

        HelpActionVisible := false;
    end;

    var
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
        ExtensionOperationImpl: Codeunit "Extension Operation Impl";
        VersionDisplay: Text;
        ActionsEnabled: Boolean;
        IsSaaS: Boolean;
        VersionFormatTxt: Label 'v. %1', Comment = 'v=version abbr, %1=Version string';
        SaaSCaptionTxt: Label 'Installed Extensions', Comment = 'The caption to display when on SaaS';
        IsTenantExtension: Boolean;
        CannotUnpublishIfInstalledMsg: Label 'The extension %1 cannot be unpublished because it is installed.', Comment = '%1 = name of extension';
        IsMarketplaceEnabled: Boolean;
        IsOnPremDisplay: Boolean;
        IsInstalled: Boolean;
        IsInstallAllowed: Boolean;
        InfoStyle: Boolean;
        [InDataSet]
        HelpActionVisible: Boolean;

    local procedure SetExtensionManagementFilter()
    begin
        // Set installed filter if we are not displaying like on-prem
        FilterGroup(2);
        if not IsInstallAllowed then
            SetRange("PerTenant Or Installed", true);
        FilterGroup(0);
    end;

    local procedure DetermineEnvironmentConfigurations()
    var
        EnvironmentInfo: Codeunit "Environment Information";
        ExtensionMarketplace: Codeunit "Extension Marketplace";
        ServerSetting: Codeunit "Server Setting";
        IsSaaSInstallAllowed: Boolean;
    begin
        IsSaaS := EnvironmentInfo.IsSaaS();
        IsSaaSInstallAllowed := ServerSetting.GetEnableSaaSExtensionInstallSetting();

        IsMarketplaceEnabled := ExtensionMarketplace.IsMarketplaceEnabled();

        // Composed configurations for the simplicity of representation
        IsOnPremDisplay := not IsMarketplaceEnabled or not IsSaaS;
        IsInstallAllowed := IsOnPremDisplay or IsSaaSInstallAllowed;
    end;

    local procedure DetermineExtensionConfigurations()
    begin
        // Determining Record and Styling Configurations
        IsInstalled := ExtensionInstallationImpl.IsInstalledByPackageId("Package ID");
        IsTenantExtension := "Published As" <> "Published As"::Global;
    end;

    local procedure GetVersionDisplayText(): Text
    begin
        exit(StrSubstNo(VersionFormatTxt, ExtensionInstallationImpl.GetVersionDisplayString(Rec)));
    end;

    local procedure SetInfoStyleForIsInstalled()
    begin
        InfoStyle := IsInstalled and IsInstallAllowed;
    end;
}

