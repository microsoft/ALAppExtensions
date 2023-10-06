// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Apps;

/// <summary>
/// Displays the extension logo.
/// </summary>
page 2506 "Extension Logo Part"
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
    SourceTableView = where("Package Type" = filter(= Extension | Designer),
                            "Tenant Visible" = const(true));
    ContextSensitiveHelpPage = 'ui-extensions';
    Permissions = tabledata "Published Application" = r;

    layout
    {
        area(content)
        {
            group(Control4)
            {
                ShowCaption = false;
                group(Control3)
                {
                    ShowCaption = false;
                    field(Logo; Rec.Logo)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the logo of the extension, such as the logo of the service provider.';
                    }
                }
            }
        }
    }

    actions
    {
    }
}


