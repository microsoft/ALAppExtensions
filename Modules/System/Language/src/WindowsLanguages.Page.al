// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Page for displaying available windows languages.
/// </summary>
page 535 "Windows Languages"
{
    Extensible = false;
    Caption = 'Available Languages';
    Editable = false;
    PageType = List;
    SourceTable = "Windows Language";
    ContextSensitiveHelpPage = 'ui-change-basic-settings#language';
    Permissions = tabledata "Page Data Personalization" = r,
                  tabledata "Windows Language" = r;

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                ShowCaption = false;
                field("Language ID"; "Language ID")
                {
                    ApplicationArea = All;
                    Caption = 'ID';
                    ToolTip = 'Specifies the unique language ID for the Windows language.';
                    Visible = false;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the names of the available Windows languages.';
                }
            }
        }
    }

    actions
    {
    }
}

