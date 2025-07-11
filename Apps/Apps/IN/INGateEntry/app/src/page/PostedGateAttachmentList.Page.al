// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

page 18612 "Posted Gate Attachment List"
{
    Caption = 'Posted Gate Attachment List';
    Editable = false;
    PageType = List;
    SourceTable = "Posted Gate Entry Attachment";

    layout
    {
        area(content)
        {
            repeater(List)
            {
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
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of entry that the posted document belongs to.';
                }
                field("Gate Entry No."; Rec."Gate Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the posted gate entry.';
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the receipt number of the posted gate entry.';
                }
            }
        }
    }
}
