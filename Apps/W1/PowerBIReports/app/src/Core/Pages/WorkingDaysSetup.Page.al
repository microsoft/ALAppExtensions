// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.PowerBIReports;

page 36952 "Working Days Setup"
{
    PageType = List;
    SourceTable = "Working Day";
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'Working Days Setup';
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(WorkingDayRepeater)
            {
                field(DayNumber; Rec."Day Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the day number ranging from 0 to 6.';
                }
                field(DayName; Rec."Day Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the day name (e.g. Monday).';
                }
                field(Working; Rec.Working)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this is a working day.';
                }
            }
        }
    }
}