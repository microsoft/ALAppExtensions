// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Page for displaying application languages.
/// </summary>
page 9 Languages
{
    Caption = 'Languages';
    AdditionalSearchTerms = 'multilanguage';
    ApplicationArea = All;
    PageType = List;
    SourceTable = Language;
    UsageCategory = Administration;
    ContextSensitiveHelpPage = 'ui-change-basic-settings#language';

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for a language.';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the language.';
                }
                field("Windows Language ID"; "Windows Language ID")
                {
                    ApplicationArea = All;
                    LookupPageID = "Windows Languages";
                    ToolTip = 'Specifies the ID of the Windows language associated with the language code you have set up in this line.';
                }
                field("Windows Language Name"; "Windows Language Name")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    ToolTip = 'Specifies if you enter an ID in the Windows Language ID field.';
                }
            }
        }
    }

    actions
    {
    }
}

