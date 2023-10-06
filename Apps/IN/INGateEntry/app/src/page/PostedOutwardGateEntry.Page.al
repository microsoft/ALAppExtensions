// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

page 18617 "Posted Outward Gate Entry"
{
    Caption = 'Posted Gate Entry - Outward';
    Editable = false;
    PageType = Document;
    SourceTable = "Posted Gate Entry Header";
    SourceTableView = sorting("Entry Type", "No.") order(ascending) where("Entry Type" = const(Outward));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the document number of the posted document.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location code of the posted document.';
                }
                field("Station From/To"; Rec."Station From/To")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Station To';
                    ToolTip = 'Specifies the station for which the posted document was created.';
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
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the creation date of the posted document.';
                }
                field("Posting Time"; Rec."Posting Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the creation time of the posted document.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the posted document.';
                }
                field("Document Time"; Rec."Document Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting time of the posted document.';
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
                field("Vehicle No."; Rec."Vehicle No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vehicle number.';
                }
                field("Gate Entry No."; Rec."Gate Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posted gate entry number.';
                }
            }
            part(PostedGateEntryOutwardSubform; "Posted Outward Gate SubForm")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Entry Type" = field("Entry Type"), "Gate Entry No." = field("No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Gate Entry")
            {
                Caption = '&Gate Entry';
                Image = InwardEntry;

                action(List)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'List';
                    Image = OpportunitiesList;
                    RunObject = Page "Posted Outward Gate Entry List";
                    ShortCutKey = 'Shift+Ctrl+L';
                    ToolTip = 'View Posted Outward Gate Entry List.';
                }
            }
        }
    }
}
