// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Purchases.Document;

pageextension 11517 "Swiss QR-Bill Purchase Order" extends "Purchase Order"
{
    layout
    {
        modify("Payment Reference")
        {
            Editable = not "Swiss QR-Bill";
        }

        addafter(Prepayment)
        {
            group("Swiss QR-Bill Tab")
            {
                Caption = 'QR-Bill';
                Visible = "Swiss QR-Bill";

                field("Swiss QR-Bill IBAN"; "Swiss QR-Bill IBAN")
                {
                    ApplicationArea = All;
                    Caption = 'IBAN/QR-IBAN';
                    ToolTip = 'Specifies the IBAN or QR-IBAN account of the QR-Bill vendor.';

                    trigger OnDrillDown()
                    var
                        IncomingDoc: Codeunit "Swiss QR-Bill Incoming Doc";
                    begin
                        IncomingDoc.DrillDownVendorIBAN("Swiss QR-Bill IBAN");
                    end;
                }
                field("Swiss QR-Bill Amount"; "Swiss QR-Bill Amount")
                {
                    ApplicationArea = All;
                    Editable = Rec."Swiss QR-Bill Has Zero Amount";
                    Importance = Promoted;
                    ToolTip = 'Specifies the total amount including VAT of the QR-Bill.';
                }
                field("Swiss QR-Bill Currency"; "Swiss QR-Bill Currency")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the currency code of the QR-Bill.';
                }
                field("Swiss QR-Bill Unstr. Message"; "Swiss QR-Bill Unstr. Message")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the unstructured message of the QR-Bill.';
                }
                field("Swiss QR-Bill Bill Info"; "Swiss QR-Bill Bill Info")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the billing information of the QR-Bill.';

                    trigger OnDrillDown()
                    var
                        BillingInfo: Codeunit "Swiss QR-Bill Billing Info";
                    begin
                        BillingInfo.DrillDownBillingInfo("Swiss QR-Bill Bill Info");
                    end;
                }
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            group("Swiss QR-Bill")
            {
                Caption = 'QR-Bill';

                action("Swiss QR-Bill Scan")
                {
                    Caption = 'Scan QR-Bill';
                    ToolTip = 'Update the invoice from the scanning of QR-bill with an input scanner, or from manual (copy/paste) of the decoded QR-Code text value into a field.';
                    ApplicationArea = All;
                    Image = Import;
                    PromotedCategory = Process;
                    Promoted = true;
                    ShortcutKey = 'Alt+S';

                    trigger OnAction()
                    begin
                        SwissQRBillPurchases.UpdatePurchDocFromQRCode(Rec, false);
                    end;
                }
                action("Swiss QR-Bill Import")
                {
                    Caption = 'Import Scanned QR-Bill File';
                    ToolTip = 'Update the invoice by importing a scanned QR-bill that is saved as a text file.';
                    ApplicationArea = All;
                    Image = Import;
                    PromotedCategory = Process;
                    Promoted = true;
                    ShortcutKey = 'Alt+I';

                    trigger OnAction()
                    begin
                        SwissQRBillPurchases.UpdatePurchDocFromQRCode(Rec, true);
                    end;
                }
                action("Swiss QR-Bill Void")
                {
                    Caption = 'Void the imported QR-Bill';
                    ToolTip = 'Clear and unlink imported QR-Bill.';
                    ApplicationArea = All;
                    Image = VoidCheck;
                    Visible = "Swiss QR-Bill";
                    PromotedCategory = Process;
                    Promoted = true;

                    trigger OnAction()
                    begin
                        SwissQRBillPurchases.VoidPurchDocQRBill(Rec);
                    end;
                }
            }
        }
    }

    var
        SwissQRBillPurchases: Codeunit "Swiss QR-Bill Purchases";
}
