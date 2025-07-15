// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Analytics;

page 5687 "Analytics Module Setup"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'Analytics Module Setup';
    SourceTable = "Analytics Module Setup";
    Extensible = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group("Setup Data")
            {
                field("Starting Date"; Rec."Starting Date")
                {
                    ToolTip = 'Specifies the starting date for generating analytics demo data. The module generates data for the past six months from this date. By default, the starting date is set to today''s date and going back six months.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InitRecord();
    end;
}
