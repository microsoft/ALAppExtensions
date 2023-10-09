// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

page 18615 "Posted Inward Gate Entry List"
{
    ApplicationArea = Basic, Suite;
    UsageCategory = History;
    Caption = 'Posted Inward Gate Entry List';
    CardPageID = "Posted Inward Gate Entry";
    PageType = List;
    SourceTable = "Posted Gate Entry Header";
    SourceTableView = sorting("Entry Type", "No.") order(ascending) where("Entry Type" = filter(Inward));

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
                    ToolTip = 'Specifies the type of entry of the posted document.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the posted document.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the creation date of the posted document.';
                }
                field("Document Time"; Rec."Document Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the creation time of the posted document.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location code of the posted document.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the posted document.';
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the items on the document.';
                }
                field("LR/RR No."; Rec."LR/RR No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the lorry receipt number of the posted document.';
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
