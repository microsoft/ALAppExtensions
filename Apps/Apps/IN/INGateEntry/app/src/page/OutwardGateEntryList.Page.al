// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

page 18610 "Outward Gate Entry List"
{
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    Caption = 'Outward Gate Entry List';
    CardPageID = "Outward Gate Entry";
    PageType = List;
    SourceTable = "Gate Entry Header";
    SourceTableView = sorting("Entry Type", "No.") order(ascending) where("Entry Type" = const(Outward));

    layout
    {
        area(content)
        {
            repeater(List)
            {
                Editable = false;

                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of entry that the document belongs to.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the creation date of the document.';
                }
                field("Document Time"; Rec."Document Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the creation time of the document.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location code for which the document is created.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the document.';
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the items on the document.';
                }
                field("LR/RR No."; Rec."LR/RR No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the lorry receipt number of the document.';
                }
                field("LR/RR Date"; Rec."LR/RR Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the lorry receipt date.';
                }
            }
        }
    }
}
