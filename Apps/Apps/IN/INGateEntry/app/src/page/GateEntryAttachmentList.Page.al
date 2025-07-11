// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

page 18601 "Gate Entry Attachment List"
{
    Caption = 'Gate Entry Attachment List';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Gate Entry Attachment";

    layout
    {
        area(content)
        {
            repeater(List)
            {
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the type of source document for which the posted gate entry is created.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number of source document for which the posted gate entry is created.';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the type of entry that the document belongs to.';
                }
                field("Gate Entry No."; Rec."Gate Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the document number of the posted gate entry.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the Line number assigned to posted gate entry.';
                }
            }
        }
    }
}
