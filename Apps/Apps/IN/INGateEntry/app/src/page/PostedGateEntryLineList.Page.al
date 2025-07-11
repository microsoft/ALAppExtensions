// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

page 18613 "Posted Gate Entry Line List"
{
    Caption = 'Posted Gate Entry Line List';
    Editable = false;
    PageType = List;
    SourceTable = "Posted Gate Entry Line";
    InsertAllowed = false;
    ModifyAllowed = false;
    layout
    {
        area(content)
        {
            repeater(List)
            {
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of entry that the document belongs to.';
                }
                field("Gate Entry No."; Rec."Gate Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the posted gate entry.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Line number assigned to posted gate entry.';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of source document for which the posted gate entry is created.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of source document for which the posted gate entry is created.';
                }
                field("Source Name"; Rec."Source Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of customer/vendor for which the document is created.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the posted gate entry document.';
                }
                field("Challan No."; Rec."Challan No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the challan number.';
                }
                field("Challan Date"; Rec."Challan Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the challan date.';
                }
            }
        }
    }
}
