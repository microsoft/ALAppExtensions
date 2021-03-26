// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Displays information about the extension.
/// </summary>
page 2504 "Extension Details Part"
{
    Extensible = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = CardPart;
    PopulateAllFields = true;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "Published Application";
    SourceTableView = WHERE("Package Type" = FILTER(= Extension | Designer),
                    "Tenant Visible" = CONST(true));
    ContextSensitiveHelpPage = 'ui-extensions';
    Permissions = tabledata "Published Application" = r;

    layout
    {
        area(content)
        {
            group(Control8)
            {
                ShowCaption = false;
                group(Control2)
                {
                    ShowCaption = false;
                    field(Logo; Logo)
                    {
                        ApplicationArea = All;
                        Caption = 'Logo';
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'Specifies the logo of the extension, such as the logo of the service provider.';
                    }
                }
            }
            group(Control4)
            {
                ShowCaption = false;
                group(Control9)
                {
                    ShowCaption = false;
                    field(Name; Name)
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        MultiLine = true;
                        ToolTip = 'Specifies the name of the extension.';
                    }
                    field(Publisher; Publisher)
                    {
                        ApplicationArea = All;
                        Caption = 'Publisher';
                        MultiLine = true;
                        ToolTip = 'Specifies the person or company that created the extension.';
                    }
                    field(Version; VersionDisplay)
                    {
                        ApplicationArea = All;
                        Caption = 'Version';
                        ToolTip = 'Specifies the version of the extension.';
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        VersionDisplay :=
          ExtensionInstallationImpl.GetVersionDisplayString(Rec);
    end;

    var
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
        VersionDisplay: Text;
}

