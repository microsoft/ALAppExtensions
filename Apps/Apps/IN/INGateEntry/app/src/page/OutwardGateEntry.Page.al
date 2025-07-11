// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

page 18608 "Outward Gate Entry"
{
    Caption = 'Outward Gate Entry';
    PageType = Document;
    SourceTable = "Gate Entry Header";
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
                    ToolTip = 'Specifies the document number.';


                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location code for which the document is created.';
                }
                field("Station From/To"; Rec."Station From/To")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Station To';
                    ToolTip = 'Specifies the station for which the document is created.';
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
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the document.';
                }
                field("Posting Time"; Rec."Posting Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting time of the document.';
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
                field("Vehicle No."; Rec."Vehicle No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vehicle number.';
                }
            }
            part(OutwardGateEntrySubform; "Outward Gate Entry SubForm")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Entry Type" = field("Entry Type"), "Gate Entry No." = field("No.");
                SubPageView = sorting("Entry Type", "Gate Entry No.", "Line No.");
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
                    RunObject = Page "Service Entity Types";
                    ShortCutKey = 'Shift+Ctrl+L';
                    ToolTip = 'List of service entry types that can be assigned to the document.';
                }
            }
        }
        area(processing)
        {
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action("Po&st")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Po&st';
                    Image = Post;
                    RunObject = Codeunit "Gate Entry- Post (Yes/No)";
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company book(F9).';
                }
            }
        }
    }
}
