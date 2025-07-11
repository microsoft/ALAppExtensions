// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ServicesTransfer;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

page 18358 "Service Transfer Order"
{
    Caption = 'Service Transfer Order';
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Document,Posting,GST';
    RefreshOnActivate = true;
    SourceTable = "Service Transfer Header";
    UsageCategory = Documents;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(FactBoxes)
        {
            part("Tax Information"; "Tax Information Factbox")
            {
                ApplicationArea = All;
                Provider = "Shipment Lines";
                SubPageLink = "Table ID Filter" = const(18351),
                    "Document No. Filter" = field("Document No."),
                    "Line No. Filter" = field("Line No.");
            }
        }
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Transfer-from Code"; Rec."Transfer-from Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the location that services are transferred from.';
                }
                field("Ship Control Account"; Rec."Ship Control Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the shipment control account.';
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Shipment date of the service transfer order.';
                }
                field("Transfer-to Code"; Rec."Transfer-to Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the location that services are transferred to.';
                }
                field("Receive Control Account"; Rec."Receive Control Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the receive control account.';
                }
                field("Receipt Date"; Rec."Receipt Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the receipt date of the service transfer order.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for global dimension 1, which is one of two global dimension codes that you can setup in general ledger setup window.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for global dimension 2, which is one of two global dimension codes that you can setup in general ledger setup window.';
                }
                field("External Doc No."; Rec."External Doc No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the external document number.';
                }
                field("Assigned User ID"; Rec."Assigned User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the user who is responsible for the document.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the transfer order is open or has been released. ';
                }
            }
            part("Shipment Lines"; "Service Transfer Ship Subform")
            {
                Caption = 'Shipment Lines';
                SubPageLink = "Document No." = FIELD("No.");
                ApplicationArea = Basic, Suite;
            }
            part("Receive Lines"; "Service Transfer Rcpt. Subform")
            {
                Caption = 'Receive Lines';
                SubPageLink = "Document No." = FIELD("No.");
                ApplicationArea = Basic, Suite;
            }
            group("Transfer-from")
            {
                Caption = 'Transfer-from';
                field("Transfer-from Name"; Rec."Transfer-from Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the sender at the location that the services are transferred from.';
                }
                field("Transfer-from Name 2"; Rec."Transfer-from Name 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name 2 of the sender at the location that the services are transferred from.';
                }
                field("Transfer-from Address"; Rec."Transfer-from Address")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the address of the location that the services are transferred from.';
                }
                field("Transfer-from Address 2"; Rec."Transfer-from Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the address 2 of the location that the services are transferred from.';
                }
                field("Transfer-from Post Code"; Rec."Transfer-from Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the post code of the location that the services are transferred from.';
                }
                field("Transfer-from City"; Rec."Transfer-from City")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the city of the location that the services are transferred from.';
                }
                field("Transfer-from State"; Rec."Transfer-from State")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the state of the location that the services are transferred from.';
                }
            }
            group("Transfer-to")
            {
                Caption = 'Transfer-to';
                field("Transfer-to Name"; Rec."Transfer-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the recipient at the location that the services are transferred to.';
                }
                field("Transfer-to Name 2"; Rec."Transfer-to Name 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name 2 of the recipient at the location that the services are transferred to.';
                }
                field("Transfer-to Address"; Rec."Transfer-to Address")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the address of the location that the services are transferred to.';
                }
                field("Transfer-to Address 2"; Rec."Transfer-to Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the address 2 of the location that the services are transferred to.';
                }
                field("Transfer-to Post Code"; Rec."Transfer-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the post code of the location that the services are transferred to.';
                }
                field("Transfer-to City"; Rec."Transfer-to City")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the city of the location that the services are transferred to.';
                }
                field("Transfer-to State"; Rec."Transfer-to State")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the state of the location that the services are transferred to.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Order)
            {
                Caption = 'Order';
                Image = "Order";
                action(Dimensions)
                {
                    AccessByPermission = TableData "Dimension" = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'Dimensions (Shift+Ctrl+D)';

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim();
                        CurrPage.SAVERECORD();
                    end;
                }
            }
            group(Documents)
            {
                Caption = 'Documents';
                Image = Documents;
                action("S&hipments")
                {
                    Caption = 'S&hipments';
                    ApplicationArea = Basic, Suite;
                    Image = Shipment;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Posted Serv. Trans. Shipments";
                    RunPageLink = "Service Transfer Order No." = FIELD("No.");
                    ToolTip = 'View a list of posted service transfer shipments for the order.';
                }
                action("Re&ceipts")
                {
                    Caption = 'Re&ceipts';
                    ApplicationArea = Basic, Suite;
                    Image = PostedReceipts;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Posted Serv. Trans. Receipts";
                    RunPageLink = "Service Transfer Order No." = FIELD("No.");
                    ToolTip = 'View a list of posted service transfer receipts for the order.';
                }
            }
        }
        area(processing)
        {
            group("P&osting")
            {
                Caption = 'P&osting';
                action(Post)
                {
                    Caption = 'Post';
                    Ellipsis = true;
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ApplicationArea = Basic, Suite;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books. (F9)';

                    trigger OnAction()
                    begin
                        Codeunit.Run(Codeunit::"Service Transfer Post", Rec);
                    end;
                }
                action(Preview)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Preview Posting';
                    Image = ViewPostedOrder;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ShortCutKey = 'Ctrl+Alt+F9';
                    ToolTip = 'Review the different types of entries that will be created when you post the document or journal.';

                    trigger OnAction()
                    var
                        ServTransferPost: Codeunit "Service Transfer Post";
                    begin
                        ServTransferPost.PreviewDocument(Rec);
                    end;
                }
            }
        }
    }
}

