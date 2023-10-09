// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

/// <summary>
/// Lists of all scenarios assigned to an account.
/// </summary>
page 70003 "File Scenarios FactBox"
{
    PageType = ListPart;
    Extensible = false;
    SourceTable = "File Scenario";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    ShowFilter = false;
    LinksAllowed = false;
    Permissions = tabledata "File Scenario" = r;

    layout
    {
        area(Content)
        {
            repeater(ScenariosByFile)
            {
                field(Name; Format(Rec.Scenario))
                {
                    ApplicationArea = All;
                    ToolTip = 'The file scenario.';
                    Caption = 'File scenario';
                    Editable = false;
                }
            }
        }
    }
}