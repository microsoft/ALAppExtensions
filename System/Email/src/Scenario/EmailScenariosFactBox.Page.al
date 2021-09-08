// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Lists of all scenarios assigned to an account.
/// </summary>
page 8895 "Email Scenarios FactBox"
{
    PageType = ListPart;
    Extensible = false;
    SourceTable = "Email Scenario";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    ShowFilter = false;
    LinksAllowed = false;
    Permissions = tabledata "Email Scenario" = r;

    layout
    {
        area(Content)
        {
            repeater(ScenariosByEmail)
            {
                field(Name; Format(Rec.Scenario))
                {
                    ApplicationArea = All;
                    ToolTip = 'The email scenario.';
                    Caption = 'Email scenario';
                    Editable = false;
                }
            }
        }
    }
}