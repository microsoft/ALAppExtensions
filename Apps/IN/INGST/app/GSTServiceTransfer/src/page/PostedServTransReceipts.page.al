// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ServicesTransfer;

using Microsoft.Finance.Dimension;

page 18353 "Posted Serv. Trans. Receipts"
{
    Caption = 'Posted Serv. Trans. Receipts';
    CardPageID = "Posted Serv. Transfer Reciept";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Service Transfer Rcpt. Header";
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posted number assigned to document.';
                }
                field("Service Transfer Order No."; Rec."Service Transfer Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of service transfer orders from which transfer receipt is created.';
                }
                field("Transfer-from State"; Rec."Transfer-from State")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the state code used in from location for which transfer receipt is created.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for global dimension 2, which is one of two global dimension codes that you can setup in general ledger setup window.';
                }
                field("Ship Control Account"; Rec."Ship Control Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies general ledger account number which will be used for ship control.';
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the shipment date of the posted transaction.';
                }
                field("Receipt Date"; Rec."Receipt Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the receipt date of the posted transaction.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction status of the transfer receipt. For example, Shipped/Received.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for global dimension 1, which is one of two global dimension codes that you can setup in general ledger setup window.';
                }
            }
        }
        area(factboxes)
        {
            systempart(RecordLinks; Links)
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Basic, Suite;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Receipt")
            {
                Caption = '&Receipt';
                Image = Shipment;
                action(Dimensions)
                {
                    AccessByPermission = TableData "Dimension" = R;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ApplicationArea = Dimensions;
                    ToolTip = 'Dimensions (Shift+Ctrl+D)';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                    end;
                }
            }
        }
        area(processing)
        {
            action("&Navigate")
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Find all entries and documents that exist for the document number and posting date on the selected entry or document.';

                trigger OnAction()
                begin
                    Rec.Navigate();
                end;
            }
        }
    }
}

