// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument.Processing.Import.Purchase;

page 6182 "E-Doc. Readable Purchase Doc."
{
    ApplicationArea = Basic, Suite;
    Caption = 'Received purchase document data';
    SourceTable = "E-Document Purchase Header";
    SourceTableTemporary = true;
    Editable = false;
    Extensible = false;
    DataCaptionExpression = DataCaption;

    layout
    {
        area(Content)
        {
            group(Header)
            {
                field("Sales Invoice No."; Rec."Sales Invoice No.")
                {
                    Caption = 'Sales Invoice No.';
                    ToolTip = 'Specifies the sales invoice number.';
                }
                field("Vendor Company Name"; Rec."Vendor Company Name")
                {
                    Caption = 'Vendor Company Name';
                    ToolTip = 'Specifies the name of the vendor company.';
                }
                field("Vendor Contact Name"; Rec."Vendor Contact Name")
                {
                    Caption = 'Vendor Contact Name';
                    ToolTip = 'Specifies the vendor contact name.';
                }
                field("Vendor Address"; Rec."Vendor Address")
                {
                    Caption = 'Vendor Address';
                    ToolTip = 'Specifies the address of the vendor company.';
                    Importance = Additional;
                }
                field("Vendor Address Recipient"; Rec."Vendor Address Recipient")
                {
                    Caption = 'Vendor Address Recipient';
                    ToolTip = 'Specifies the recipient of the vendor address.';
                    Importance = Additional;
                }
                field("Vendor VAT Id"; Rec."Vendor VAT Id")
                {
                    Caption = 'Vendor VAT Id';
                    ToolTip = 'Specifies the vendor VAT ID.';
                    Importance = Additional;
                }
                field("Vendor GLN"; Rec."Vendor GLN")
                {
                    Caption = 'Vendor Global Location Number';
                    ToolTip = 'Specifies the vendor global location number.';
                    Importance = Additional;
                }
                field("Vendor External Id"; Rec."Vendor External Id")
                {
                    Caption = 'Vendor External Id';
                    ToolTip = 'Specifies the vendor external ID.';
                    Importance = Additional;
                }
                field("Remittance Address"; Rec."Remittance Address")
                {
                    Caption = 'Remittance Address';
                    ToolTip = 'Specifies the remittance address.';
                    Importance = Additional;
                }
                field("Remittance Address Recipient"; Rec."Remittance Address Recipient")
                {
                    Caption = 'Remittance Address Recipient';
                    ToolTip = 'Specifies the recipient of the remittance address.';
                    Importance = Additional;
                }
                field("Service Address"; Rec."Service Address")
                {
                    Caption = 'Service Address';
                    ToolTip = 'Specifies the service address.';
                    Importance = Additional;
                }
                field("Service Address Recipient"; Rec."Service Address Recipient")
                {
                    Caption = 'Service Address Recipient';
                    ToolTip = 'Specifies the recipient of the service address.';
                    Importance = Additional;
                }
                field("Payment Terms"; Rec."Payment Terms")
                {
                    Caption = 'Payment Terms';
                    ToolTip = 'Specifies the payment terms.';
                    Importance = Additional;
                }
                field("Amount Due"; Rec."Amount Due")
                {
                    Caption = 'Amount Due';
                    ToolTip = 'Specifies the amount due.';
                }
                field("Previous Unpaid Balance"; Rec."Previous Unpaid Balance")
                {
                    Caption = 'Previous Unpaid Balance';
                    ToolTip = 'Specifies the previous unpaid balance.';
                    Importance = Additional;
                }
                field("Service Start Date"; Rec."Service Start Date")
                {
                    Caption = 'Service Start Date';
                    ToolTip = 'Specifies the service start date.';
                    Importance = Additional;
                }
                field("Service End Date"; Rec."Service End Date")
                {
                    Caption = 'Service End Date';
                    ToolTip = 'Specifies the service end date.';
                    Importance = Additional;
                }
                field("Customer GLN"; Rec."Customer GLN")
                {
                    Caption = 'Customer Global Location Number';
                    ToolTip = 'Specifies the customer global location number.';
                    Importance = Additional;
                }
                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    Caption = 'Purchase Order No.';
                    ToolTip = 'Specifies the purchase order number.';
                }
                field("Invoice Date"; Rec."Invoice Date")
                {
                    Caption = 'Invoice Date';
                    ToolTip = 'Specifies the invoice date.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    Caption = 'Due Date';
                    ToolTip = 'Specifies the due date.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    Caption = 'Document Date';
                    ToolTip = 'Specifies the document date.';
                    Importance = Additional;
                }
                field("Customer VAT Id"; Rec."Customer VAT Id")
                {
                    Caption = 'Customer VAT Id';
                    ToolTip = 'Specifies the customer VAT ID.';
                }
                field("Customer Company Name"; Rec."Customer Company Name")
                {
                    Caption = 'Customer Company Name';
                    ToolTip = 'Specifies the name of the customer company.';
                }
                field("Customer Company Id"; Rec."Customer Company Id")
                {
                    Caption = 'Customer Company Id';
                    ToolTip = 'Specifies the ID of the customer company.';
                    Importance = Additional;
                }
                field("Customer Address"; Rec."Customer Address")
                {
                    Caption = 'Customer Address';
                    ToolTip = 'Specifies the address of the customer company.';
                    Importance = Additional;
                }
                field("Customer Address Recipient"; Rec."Customer Address Recipient")
                {
                    Caption = 'Customer Address Recipient';
                    ToolTip = 'Specifies the recipient of the customer address.';
                    Importance = Additional;
                }
                field("Billing Address"; Rec."Billing Address")
                {
                    Caption = 'Billing Address';
                    ToolTip = 'Specifies the billing address.';
                    Importance = Additional;
                }
                field("Billing Address Recipient"; Rec."Billing Address Recipient")
                {
                    Caption = 'Billing Address Recipient';
                    ToolTip = 'Specifies the recipient of the billing address.';
                    Importance = Additional;
                }
                field("Shipping Address"; Rec."Shipping Address")
                {
                    Caption = 'Shipping Address';
                    ToolTip = 'Specifies the shipping address.';
                    Importance = Additional;
                }
                field("Shipping Address Recipient"; Rec."Shipping Address Recipient")
                {
                    Caption = 'Shipping Address Recipient';
                    ToolTip = 'Specifies the recipient of the shipping address.';
                    Importance = Additional;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                    ToolTip = 'Specifies the currency code.';
                }
                field("Sub Total"; Rec."Sub Total")
                {
                    Caption = 'Sub Total';
                    ToolTip = 'Specifies the sub total.';
                }
                field("Total Discount"; Rec."Total Discount")
                {
                    Caption = 'Total Discount';
                    ToolTip = 'Specifies the total discount.';
                }
                field("Total VAT"; Rec."Total VAT")
                {
                    Caption = 'Total VAT';
                    ToolTip = 'Specifies the total VAT.';
                }
                field(Total; Rec.Total)
                {
                    Caption = 'Total';
                    ToolTip = 'Specifies the total.';
                }
            }
            part("Lines"; "E-Doc. Read. Purch. Lines")
            {
                SubPageLink = "E-Document Entry No." = field("E-Document Entry No.");
                Caption = 'Lines';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DataCaption := 'Extracted Data - Purchase Document ' + Format(Rec."E-Document Entry No.");
    end;

    trigger OnOpenPage()
    begin
        if Rec."E-Document Entry No." = 0 then
            Error('');
    end;

    internal procedure SetBuffer(var EDocumentPurchaseHeader: Record "E-Document Purchase Header" temporary; var EDocumentPurchaseLine: Record "E-Document Purchase Line" temporary)
    begin
        Clear(Rec);
        Rec := EDocumentPurchaseHeader;
        Rec.Insert();
        CurrPage.Lines.Page.SetBuffer(EDocumentPurchaseLine);
    end;

    var
        DataCaption: Text;
}