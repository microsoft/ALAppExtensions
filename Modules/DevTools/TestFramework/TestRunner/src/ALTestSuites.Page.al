// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 130450 "AL Test Suites"
{
    PageType = List;
    SaveValues = true;
    SourceTable = "AL Test Suite";
    Permissions = TableData "AL Test Suite" = rimd, TableData "Test Method Line" = rimd;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the test suite.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the description of the test suite.';
                }
                field("Tests to Execute"; Rec."Tests to Execute")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of tests to execute.';
                }
                field(Failures; Rec.Failures)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the number fo failures.';
                }
                field("Tests not Executed"; Rec."Tests not Executed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of tests not executed.';
                }
            }
        }
    }

    actions
    {
    }
}

