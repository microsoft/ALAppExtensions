// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

page 18602 "Gate Entry Comment List"
{
    Caption = 'Gate Entry Comment List';
    DataCaptionFields = "Gate Entry Type", "No.";
    Editable = false;
    PageType = List;
    SourceTable = "Gate Entry Comment Line";

    layout
    {
        area(content)
        {
            repeater(List)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the gate entry.';
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which comment is created.';
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the comment entered on gate entry.';
                }
            }
        }
    }
}
