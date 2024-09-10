// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Sales.Customer;
using Microsoft.Finance.Currency;
using Microsoft.Service.History;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.Integration.Graph;
using Microsoft.Service.Document;
using Microsoft.API.V2;

page 6614 "FS Posted Service Invoice API"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Posted Service Invoice';
    EntitySetCaption = 'Posted Service Invoices';
    EntityName = 'postedServiceInvoice';
    EntitySetName = 'postedServiceInvoices';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Service Invoice Header";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(externalDocumentNumber; Rec."External Document No.")
                {
                    Caption = 'External Document No.';
                }
                field(invoiceDate; Rec."Document Date")
                {
                    Caption = 'Invoice Date';
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date';
                }
                field(customerPurchaseOrderReference; Rec."Your Reference")
                {
                    Caption = 'Customer Purchase Order Reference',;
                }
                field(customerId; SellToCustomer.SystemId)
                {
                    Caption = 'Customer Id';
                }
                field(customerNumber; Rec."Customer No.")
                {
                    Caption = 'Customer No.';
                }
                field(customerName; Rec.Name)
                {
                    Caption = 'Customer Name';
                    Editable = false;
                }
                field(billToName; Rec."Bill-to Name")
                {
                    Caption = 'Bill-To Name';
                    Editable = false;
                }
                field(billToCustomerId; BillToCustomer.SystemId)
                {
                    Caption = 'Bill-To Customer Id';
                }
                field(billToCustomerNumber; Rec."Bill-to Customer No.")
                {
                    Caption = 'Bill-To Customer No.';
                }
                field(shipToName; Rec."Ship-to Name")
                {
                    Caption = 'Ship-to Name';
                }
                field(shipToContact; Rec."Ship-to Contact")
                {
                    Caption = 'Ship-to Contact';
                }
                field(sellToAddressLine1; Rec.Address)
                {
                    Caption = 'Sell-to Address Line 1';
                }
                field(sellToAddressLine2; Rec."Address 2")
                {
                    Caption = 'Sell-to Address Line 2';
                }
                field(sellToCity; Rec.City)
                {
                    Caption = 'Sell-to City';
                }
                field(sellToCountry; Rec."Country/Region Code")
                {
                    Caption = 'Sell-to Country/Region Code';
                }
                field(sellToState; Rec.County)
                {
                    Caption = 'Sell-to State';
                }
                field(sellToPostCode; Rec."Post Code")
                {
                    Caption = 'Sell-to Post Code';
                }
                field(billToAddressLine1; Rec."Bill-To Address")
                {
                    Caption = 'Bill-to Address Line 1';
                    Editable = false;
                }
                field(billToAddressLine2; Rec."Bill-To Address 2")
                {
                    Caption = 'Bill-to Address Line 2';
                    Editable = false;
                }
                field(billToCity; Rec."Bill-To City")
                {
                    Caption = 'Bill-to City';
                    Editable = false;
                }
                field(billToCountry; Rec."Bill-To Country/Region Code")
                {
                    Caption = 'Bill-to Country/Region Code';
                    Editable = false;
                }
                field(billToState; Rec."Bill-To County")
                {
                    Caption = 'Bill-to State';
                    Editable = false;
                }
                field(billToPostCode; Rec."Bill-To Post Code")
                {
                    Caption = 'Bill-to Post Code';
                    Editable = false;
                }
                field(shipToAddressLine1; Rec."Ship-to Address")
                {
                    Caption = 'Ship-to Address Line 1';
                }
                field(shipToAddressLine2; Rec."Ship-to Address 2")
                {
                    Caption = 'Ship-to Address Line 2';
                }
                field(shipToCity; Rec."Ship-to City")
                {
                    Caption = 'Ship-to City';
                }
                field(shipToCountry; Rec."Ship-to Country/Region Code")
                {
                    Caption = 'Ship-to Country/Region Code';
                }
                field(shipToState; Rec."Ship-to County")
                {
                    Caption = 'Ship-to State';
                }
                field(shipToPostCode; Rec."Ship-to Post Code")
                {
                    Caption = 'Ship-to Post Code';
                }
                field(currencyId; Currency.SystemId)
                {
                    Caption = 'Currency Id';
                }
                field(shortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                    Caption = 'Shortcut Dimension 1 Code';
                }
                field(shortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {
                    Caption = 'Shortcut Dimension 2 Code';
                }
                field(currencyCode; CurrencyCode)
                {
                    Caption = 'Currency Code';
                }
                field(orderId; ServiceOrder.SystemId)
                {
                    Caption = 'Order Id';
                    Editable = false;
                }
                field(orderNumber; Rec."Order No.")
                {
                    Caption = 'Order No.';
                    Editable = false;
                }
                field(paymentTermsId; PaymentTerms.SystemId)
                {
                    Caption = 'Payment Terms Id';
                }
                field(shipmentMethodId; ShipmentMethod.SystemId)
                {
                    Caption = 'Shipment Method Id';
                }
                field(salesperson; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson';
                }
                field(pricesIncludeTax; Rec."Prices Including VAT")
                {
                    Caption = 'Prices Include Tax';
                    Editable = false;
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = field(SystemId);
                }
                part(postedServiceInvoiceLines; "FS Posted Serv. Inv. Lines API")
                {
                    Caption = 'Lines';
                    EntityName = 'postedServiceInvoiceLine';
                    EntitySetName = 'postedServiceInvoiceLines';
                    SubPageLink = "Document No." = field("No.");
                }
                part(pdfDocument; "APIV2 - PDF Document")
                {
                    Caption = 'PDF Document';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'pdfDocument';
                    EntitySetName = 'pdfDocument';
                    SubPageLink = "Document Id" = field(SystemId);
                }
                field(totalAmountExcludingTax; Rec.Amount)
                {
                    Caption = 'Total Amount Excluding Tax';
                    Editable = false;
                }
                field(totalAmountIncludingTax; Rec."Amount Including VAT")
                {
                    Caption = 'Total Amount Including Tax';
                    Editable = false;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
                field(phoneNumber; Rec."Phone No.")
                {
                    Caption = 'Phone No.';
                }
                field(email; Rec."E-Mail")
                {
                    Caption = 'Email';
                }
                part(attachments; "APIV2 - Attachments")
                {
                    Caption = 'Attachments';
                    EntityName = 'attachment';
                    EntitySetName = 'attachments';
                    SubPageLink = "Document Id" = field(SystemId);
                }
                part(documentAttachments; "APIV2 - Document Attachments")
                {
                    Caption = 'Document Attachments';
                    EntityName = 'documentAttachment';
                    EntitySetName = 'documentAttachments';
                    SubPageLink = "Document Id" = field(SystemId);
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        if not SellToCustomer.Get(Rec."Customer No.") then
            Clear(SellToCustomer);
        if not BillToCustomer.Get(Rec."Bill-to Customer No.") then
            Clear(BillToCustomer);
        CurrencyCode := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(CachedCurrencyCode, Rec."Currency Code");
        if not Currency.Get(CurrencyCode) then
            Clear(Currency);
        if not ServiceOrder.Get(ServiceOrder."Document Type"::Order, Rec."Order No.") then
            Clear(ServiceOrder);
        if not PaymentTerms.Get(Rec."Payment Terms Code") then
            Clear(PaymentTerms);
        if not ShipmentMethod.Get(Rec."Shipment Method Code") then
            Clear(ShipmentMethod);
    end;

    var
        SellToCustomer: Record "Customer";
        BillToCustomer: Record "Customer";
        Currency: Record "Currency";
        ServiceOrder: Record "Service Header";
        PaymentTerms: Record "Payment Terms";
        ShipmentMethod: Record "Shipment Method";
        CurrencyCode: Code[10];
        CachedCurrencyCode: Code[10];
}