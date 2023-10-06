// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Apps;

using System.Environment;

/// <summary>
/// Lists the extension which have data but are not installed, and provides the ability to delete their data.
/// </summary>
page 2514 "Delete Orphaned Extension Data"
{
    Caption = 'Delete Orphaned Extension Data';
    AdditionalSearchTerms = 'app,add-in,plug-in,appsource';
    ApplicationArea = All;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "Extension Database Snapshot";
    SourceTableView = sorting(Name)
                      order(ascending)
                      where("Status" = filter('<> Installed'));
    UsageCategory = Administration;
    ContextSensitiveHelpPage = 'ui-extensions';
    Permissions = tabledata "Extension Database Snapshot" = r;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the extension.';
                }
                field(Publisher; Rec.Publisher)
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
                field("Stale"; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    ToolTip = 'Specifies the status of the extension.';
                }
                field("Published As"; Rec."Published As")
                {
                    ApplicationArea = All;
                    Caption = 'Published As';
                    ToolTip = 'Specifies whether the extension is published as a per-tenant, development, or a global extension.';
                }

                label(Spacer)
                {
                    ApplicationArea = All;
                    Enabled = IsSaaS;
                    HideValue = true;
                    ShowCaption = false;
                    Caption = '';
                    Style = Favorable;
                    StyleExpr = true;
                    ToolTip = 'Specifies a spacer for ''Brick'' view mode.';
                    Visible = not IsOnPremDisplay;
                }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(PromptedDelete; DeleteData)
            {
            }
        }

        area(processing)
        {
            group(ActionGroup13)
            {
                Caption = 'Process';
                action(DeleteData)
                {
                    ApplicationArea = All;
                    Caption = 'Delete Data';
                    Image = Delete;
                    Scope = Repeater;
                    ToolTip = 'Delete the data from this extension.';

                    trigger OnAction()
                    var
                        FilterCache: Text;
                    begin
                        if ExtensionInstallationImpl.RunOrphanDeletion(rec) then begin
                            Message(StrSubstNo(ClearExtensionSchemaOrphanMsg, Rec.Name));
                            FilterCache := Rec.GetView();
                            Clear(Rec);
                            Rec.SetView(FilterCache);
                            Rec.SetFilter(Rec.Status, '<>Installed');
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        VersionDisplay := GetVersionDisplayText();
    end;

    trigger OnOpenPage()
    begin
        CurrPage.Update(false);
        DetermineEnvironmentConfigurations();
    end;

    var
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
        VersionDisplay: Text;
        IsSaaS: Boolean;
        VersionFormatTxt: Label 'v. %1', Comment = 'v=version abbr, %1=Version string';
        ClearExtensionSchemaOrphanMsg: Label 'The %1 extension data was deleted.', Comment = '%1=The extension which data was deleted';
        IsMarketplaceEnabled: Boolean;
        IsOnPremDisplay: Boolean;

    local procedure DetermineEnvironmentConfigurations()
    var
        EnvironmentInformation: Codeunit "Environment Information";
        ExtensionMarketplace: Codeunit "Extension Marketplace";
    begin
        IsSaaS := EnvironmentInformation.IsSaaS();

        IsMarketplaceEnabled := ExtensionMarketplace.IsMarketplaceEnabled();

        // Composed configurations for the simplicity of representation
        IsOnPremDisplay := not IsMarketplaceEnabled or not IsSaaS;
    end;

    local procedure GetVersionDisplayText(): Text
    begin
        // Getting the version display text and adding a '- NotInstalled' if in SaaS for PerTenant extensions
        exit(StrSubstNo(VersionFormatTxt, Rec."Schema Version"));
    end;
}


