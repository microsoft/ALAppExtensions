namespace Microsoft.API.V2;

using Microsoft.Integration.Entity;
using Microsoft.Integration.Graph;
using Microsoft.Sales.Customer;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.Sales.Document;
using System.Reflection;

page 30037 "APIV2 - Sales Quotes"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Sales Quote';
    EntitySetCaption = 'Sales Quotes';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'salesQuote';
    EntitySetName = 'salesQuotes';
    ODataKeyFields = Id;
    PageType = API;
    SourceTable = "Sales Quote Entity Buffer";
    Extensible = false;
    AboutText = 'Manages sales quote documents including customer details, quote status, pricing, addresses, and validity dates. Supports full lifecycle operations (GET, POST, PATCH, DELETE) for creating, retrieving, updating, and deleting sales quotes, enabling integration with lead management, e-commerce platforms, and automated quoting workflows. Ideal for external systems needing to automate or synchronize sales quoting processes with Business Central.';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.Id)
                {
                    Caption = 'Id';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Id));
                    end;
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("No."));
                    end;
                }
                field(externalDocumentNumber; Rec."External Document No.")
                {
                    Caption = 'External Document No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("External Document No."))
                    end;
                }
                field(documentDate; Rec."Document Date")
                {
                    Caption = 'Document Date';

                    trigger OnValidate()
                    begin
                        DocumentDateVar := Rec."Document Date";
                        DocumentDateSet := true;

                        RegisterFieldSet(Rec.FieldNo("Document Date"));
                    end;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';

                    trigger OnValidate()
                    begin
                        PostingDateVar := Rec."Posting Date";
                        PostingDateSet := true;

                        RegisterFieldSet(Rec.FieldNo("Posting Date"));
                    end;
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date';

                    trigger OnValidate()
                    begin
                        DueDateVar := Rec."Due Date";
                        DueDateSet := true;

                        RegisterFieldSet(Rec.FieldNo("Due Date"));
                    end;
                }
                field(customerId; Rec."Customer Id")
                {
                    Caption = 'Customer Id';

                    trigger OnValidate()
                    begin
                        if not SellToCustomer.GetBySystemId(Rec."Customer Id") then
                            Error(CouldNotFindSellToCustomerErr);

                        Rec."Sell-to Customer No." := SellToCustomer."No.";
                        RegisterFieldSet(Rec.FieldNo("Customer Id"));
                        RegisterFieldSet(Rec.FieldNo("Sell-to Customer No."));
                    end;
                }

                field(customerNumber; Rec."Sell-to Customer No.")
                {
                    Caption = 'Customer No.';

                    trigger OnValidate()
                    begin
                        if SellToCustomer."No." <> '' then begin
                            if SellToCustomer."No." <> Rec."Sell-to Customer No." then
                                Error(SellToCustomerValuesDontMatchErr);
                            exit;
                        end;

                        if not SellToCustomer.Get(Rec."Sell-to Customer No.") then
                            Error(CouldNotFindSellToCustomerErr);

                        Rec."Customer Id" := SellToCustomer.SystemId;
                        RegisterFieldSet(Rec.FieldNo("Customer Id"));
                        RegisterFieldSet(Rec.FieldNo("Sell-to Customer No."));
                    end;
                }
                field(customerName; Rec."Sell-to Customer Name")
                {
                    Caption = 'Customer Name';
                    Editable = false;
                }
                field(billToName; Rec."Bill-to Name")
                {
                    Caption = 'Bill-To Name';
                    Editable = false;
                }
                field(billToCustomerId; Rec."Bill-to Customer Id")
                {
                    Caption = 'Bill-To Customer Id';
                    trigger OnValidate()
                    begin
                        if not BillToCustomer.GetBySystemId(Rec."Bill-to Customer Id") then
                            Error(CouldNotFindBillToCustomerErr);

                        Rec."Bill-to Customer No." := BillToCustomer."No.";
                        RegisterFieldSet(Rec.FieldNo("Bill-to Customer Id"));
                        RegisterFieldSet(Rec.FieldNo("Bill-to Customer No."));
                    end;
                }
                field(billToCustomerNumber; Rec."Bill-to Customer No.")
                {
                    Caption = 'Bill-To Customer No.';

                    trigger OnValidate()
                    begin
                        if BillToCustomer."No." <> '' then begin
                            if BillToCustomer."No." <> Rec."Bill-to Customer No." then
                                Error(BillToCustomerValuesDontMatchErr);
                            exit;
                        end;

                        if not BillToCustomer.Get(Rec."Bill-to Customer No.") then
                            Error(CouldNotFindBillToCustomerErr);

                        Rec."Bill-to Customer Id" := BillToCustomer.SystemId;
                        RegisterFieldSet(Rec.FieldNo("Bill-to Customer Id"));
                        RegisterFieldSet(Rec.FieldNo("Bill-to Customer No."));
                    end;
                }
                field(shipToName; Rec."Ship-to Name")
                {
                    Caption = 'Ship-To Name';

                    trigger OnValidate()
                    begin
                        if xRec."Ship-to Name" <> Rec."Ship-to Name" then begin
                            Rec."Ship-to Code" := '';
                            RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
                            RegisterFieldSet(Rec.FieldNo("Ship-to Name"));
                        end;
                    end;
                }
                field(shipToContact; Rec."Ship-to Contact")
                {
                    Caption = 'Ship-To Contact';

                    trigger OnValidate()
                    begin
                        if xRec."Ship-to Contact" <> Rec."Ship-to Contact" then begin
                            Rec."Ship-to Code" := '';
                            RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
                            RegisterFieldSet(Rec.FieldNo("Ship-to Contact"));
                        end;
                    end;
                }
                field(sellToAddressLine1; Rec."Sell-to Address")
                {
                    Caption = 'Sell-to Address Line 1';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Sell-to Address"));
                    end;
                }
                field(sellToAddressLine2; Rec."Sell-to Address 2")
                {
                    Caption = 'Sell-to Address Line 2';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Sell-to Address 2"));
                    end;
                }
                field(sellToCity; Rec."Sell-to City")
                {
                    Caption = 'Sell-to City';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Sell-to City"));
                    end;
                }
                field(sellToCountry; Rec."Sell-to Country/Region Code")
                {
                    Caption = 'Sell-to Country/Region Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Sell-to Country/Region Code"));
                    end;
                }
                field(sellToState; Rec."Sell-to County")
                {
                    Caption = 'Sell-to State';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Sell-to County"));
                    end;
                }
                field(sellToPostCode; Rec."Sell-to Post Code")
                {
                    Caption = 'Sell-to Post Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Sell-to Post Code"));
                    end;
                }
                field(billToAddressLine1; Rec."Bill-To Address")
                {
                    Caption = 'Bill-to Address Line 1';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Bill-To Address"));
                    end;
                }
                field(billToAddressLine2; Rec."Bill-To Address 2")
                {
                    Caption = 'Bill-to Address Line 2';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Bill-To Address 2"));
                    end;
                }
                field(billToCity; Rec."Bill-To City")
                {
                    Caption = 'Bill-to City';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Bill-To City"));
                    end;
                }
                field(billToCountry; Rec."Bill-To Country/Region Code")
                {
                    Caption = 'Bill-to Country/Region Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Bill-To Country/Region Code"));
                    end;
                }
                field(billToState; Rec."Bill-To County")
                {
                    Caption = 'Bill-to State';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Bill-To County"));
                    end;
                }
                field(billToPostCode; Rec."Bill-To Post Code")
                {
                    Caption = 'Bill-to Post Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Bill-To Post Code"));
                    end;
                }
                field(shipToAddressLine1; Rec."Ship-to Address")
                {
                    Caption = 'Ship-to Address Line 1';

                    trigger OnValidate()
                    begin
                        Rec."Ship-to Code" := '';
                        RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
                        RegisterFieldSet(Rec.FieldNo("Ship-to Address"));
                    end;
                }
                field(shipToAddressLine2; Rec."Ship-to Address 2")
                {
                    Caption = 'Ship-to Address Line 2';

                    trigger OnValidate()
                    begin
                        Rec."Ship-to Code" := '';
                        RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
                        RegisterFieldSet(Rec.FieldNo("Ship-to Address 2"));
                    end;
                }
                field(shipToCity; Rec."Ship-to City")
                {
                    Caption = 'Ship-to City';

                    trigger OnValidate()
                    begin
                        Rec."Ship-to Code" := '';
                        RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
                        RegisterFieldSet(Rec.FieldNo("Ship-to City"));
                    end;
                }
                field(shipToCountry; Rec."Ship-to Country/Region Code")
                {
                    Caption = 'Ship-to Country/Region Code';

                    trigger OnValidate()
                    begin
                        Rec."Ship-to Code" := '';
                        RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
                        RegisterFieldSet(Rec.FieldNo("Ship-to Country/Region Code"));
                    end;
                }
                field(shipToState; Rec."Ship-to County")
                {
                    Caption = 'Ship-to State';

                    trigger OnValidate()
                    begin
                        Rec."Ship-to Code" := '';
                        RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
                        RegisterFieldSet(Rec.FieldNo("Ship-to County"));
                    end;
                }
                field(shipToPostCode; Rec."Ship-to Post Code")
                {
                    Caption = 'Ship-to Post Code';

                    trigger OnValidate()
                    begin
                        Rec."Ship-to Code" := '';
                        RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
                        RegisterFieldSet(Rec.FieldNo("Ship-to Post Code"));
                    end;
                }
                field(shortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                    Caption = 'Shortcut Dimension 1 Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Shortcut Dimension 1 Code"));
                    end;
                }
                field(shortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {
                    Caption = 'Shortcut Dimension 2 Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Shortcut Dimension 2 Code"));
                    end;
                }
                field(currencyId; Rec."Currency Id")
                {
                    Caption = 'Currency Id';

                    trigger OnValidate()
                    begin
                        if Rec."Currency Id" = BlankGUID then
                            Rec."Currency Code" := ''
                        else begin
                            if not Currency.GetBySystemId(Rec."Currency Id") then
                                Error(CurrencyIdDoesNotMatchACurrencyErr);

                            Rec."Currency Code" := Currency.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Currency Id"));
                        RegisterFieldSet(Rec.FieldNo("Currency Code"));
                    end;
                }
                field(currencyCode; CurrencyCodeTxt)
                {
                    Caption = 'Currency Code';

                    trigger OnValidate()
                    begin
                        Rec."Currency Code" :=
                          GraphMgtGeneralTools.TranslateCurrencyCodeToNAVCurrencyCode(
                            LCYCurrencyCode, COPYSTR(CurrencyCodeTxt, 1, MAXSTRLEN(LCYCurrencyCode)));

                        if Currency.Code <> '' then begin
                            if Currency.Code <> Rec."Currency Code" then
                                Error(CurrencyValuesDontMatchErr);
                            exit;
                        end;

                        if Rec."Currency Code" = '' then
                            Rec."Currency Id" := BlankGUID
                        else begin
                            if not Currency.Get(Rec."Currency Code") then
                                Error(CurrencyCodeDoesNotMatchACurrencyErr);

                            Rec."Currency Id" := Currency.SystemId;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Currency Id"));
                        RegisterFieldSet(Rec.FieldNo("Currency Code"));
                    end;
                }
                field(paymentTermsId; Rec."Payment Terms Id")
                {
                    Caption = 'Payment Terms Id';

                    trigger OnValidate()
                    begin
                        if Rec."Payment Terms Id" = BlankGUID then
                            Rec."Payment Terms Code" := ''
                        else begin
                            if not PaymentTerms.GetBySystemId(Rec."Payment Terms Id") then
                                Error(PaymentTermsIdDoesNotMatchAPaymentTermsErr);

                            Rec."Payment Terms Code" := PaymentTerms.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Payment Terms Id"));
                        RegisterFieldSet(Rec.FieldNo("Payment Terms Code"));
                    end;
                }
                field(shipmentMethodId; Rec."Shipment Method Id")
                {
                    Caption = 'Shipment Method Id';

                    trigger OnValidate()
                    begin
                        if Rec."Shipment Method Id" = BlankGUID then
                            Rec."Shipment Method Code" := ''
                        else begin
                            if not ShipmentMethod.GetBySystemId(Rec."Shipment Method Id") then
                                Error(ShipmentMethodIdDoesNotMatchAShipmentMethodErr);

                            Rec."Shipment Method Code" := ShipmentMethod.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Shipment Method Id"));
                        RegisterFieldSet(Rec.FieldNo("Shipment Method Code"));
                    end;
                }
                field(salesperson; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Salesperson Code"));
                    end;
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = field(Id), "Parent Type" = const("Sales Quote");
                }
                part(salesQuoteLines; "APIV2 - Sales Quote Lines")
                {
                    Caption = 'Lines';
                    EntityName = 'salesQuoteLine';
                    EntitySetName = 'salesQuoteLines';
                    SubPageLink = "Document Id" = field(Id);
                }
                part(pdfDocument; "APIV2 - PDF Document")
                {
                    Caption = 'PDF Document';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'pdfDocument';
                    EntitySetName = 'pdfDocument';
                    SubPageLink = "Document Id" = field(Id), "Document Type" = const("Sales Quote");
                }
                field(discountAmount; Rec."Invoice Discount Amount")
                {
                    Caption = 'Discount Amount';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Invoice Discount Amount"));
                        InvoiceDiscountAmount := Rec."Invoice Discount Amount";
                        DiscountAmountSet := true;
                    end;
                }
                field(totalAmountExcludingTax; Rec.Amount)
                {
                    Caption = 'Total Amount Excluding Tax';
                    Editable = false;
                }
                field(totalTaxAmount; Rec."Total Tax Amount")
                {
                    Caption = 'Total Tax Amount';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Total Tax Amount"));
                    end;
                }
                field(totalAmountIncludingTax; Rec."Amount Including VAT")
                {
                    Caption = 'Total Amount Including Tax';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Amount Including VAT"));
                    end;
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Status));
                    end;
                }
                field(sentDate; Rec."Quote Sent to Customer")
                {
                    Caption = 'Sent Date';
                }
                field(validUntilDate; Rec."Quote Valid Until Date")
                {
                    Caption = 'Valid Until Date';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Quote Valid Until Date"));
                    end;
                }
                field(acceptedDate; Rec."Quote Accepted Date")
                {
                    Caption = 'Accepted Date';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Quote Accepted Date"));
                    end;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
                field(phoneNumber; Rec."Sell-to Phone No.")
                {
                    Caption = 'Phone No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Sell-to Phone No."));
                    end;
                }
                field(email; Rec."Sell-to E-Mail")
                {
                    Caption = 'Email';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Sell-to E-Mail"));
                    end;
                }
                part(attachments; "APIV2 - Attachments")
                {
                    Caption = 'Attachments';
                    EntityName = 'attachment';
                    EntitySetName = 'attachments';
                    SubPageLink = "Document Id" = field(Id), "Document Type" = const("Sales Quote");
                }

                part(documentAttachments; "APIV2 - Document Attachments")
                {
                    Caption = 'Document Attachments';
                    EntityName = 'documentAttachment';
                    EntitySetName = 'documentAttachments';
                    SubPageLink = "Document Id" = field(Id), "Document Type" = const("Sales Quote");
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        GraphMgtSalesQuoteBuffer: Codeunit "Graph Mgt - Sales Quote Buffer";
    begin
        SetCalculatedFields();
        if HasWritePermission then
            GraphMgtSalesQuoteBuffer.RedistributeInvoiceDiscounts(Rec);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        GraphMgtSalesQuoteBuffer: Codeunit "Graph Mgt - Sales Quote Buffer";
    begin
        GraphMgtSalesQuoteBuffer.PropagateOnDelete(Rec);

        exit(false);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        GraphMgtSalesQuoteBuffer: Codeunit "Graph Mgt - Sales Quote Buffer";
    begin
        CheckSellToCustomerSpecified();

        GraphMgtSalesQuoteBuffer.PropagateOnInsert(Rec, TempFieldBuffer);
        SetDates();

        UpdateDiscount();

        SetCalculatedFields();

        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        GraphMgtSalesQuoteBuffer: Codeunit "Graph Mgt - Sales Quote Buffer";
    begin
        if xRec.Id <> Rec.Id then
            Error(CannotChangeIDErr);

        GraphMgtSalesQuoteBuffer.PropagateOnModify(Rec, TempFieldBuffer);
        UpdateDiscount();

        SetCalculatedFields();

        exit(false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
    end;

    trigger OnOpenPage()
    begin
        CheckPermissions();
    end;

    var
        TempFieldBuffer: Record "Field Buffer" temporary;
        SellToCustomer: Record "Customer";
        BillToCustomer: Record "Customer";
        Currency: Record "Currency";
        PaymentTerms: Record "Payment Terms";
        ShipmentMethod: Record "Shipment Method";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        LCYCurrencyCode: Code[10];
        CurrencyCodeTxt: Text;
        CouldNotFindSellToCustomerErr: Label 'The sell-to customer cannot be found.';
        CouldNotFindBillToCustomerErr: Label 'The bill-to customer cannot be found.';
        CannotChangeIDErr: Label 'The "id" cannot be changed.', Comment = 'id is a field name and should not be translated.';
        SellToCustomerNotProvidedErr: Label 'A "customerNumber" or a "customerId" must be provided.', Comment = 'customerNumber and customerId are field names and should not be translated.';
        SellToCustomerValuesDontMatchErr: Label 'The sell-to customer values do not match to a specific Customer.';
        BillToCustomerValuesDontMatchErr: Label 'The bill-to customer values do not match to a specific Customer.';
        SalesQuotePermissionsErr: Label 'You do not have permissions to read Sales Quotes.';
        CurrencyValuesDontMatchErr: Label 'The currency values do not match to a specific Currency.';
        CurrencyIdDoesNotMatchACurrencyErr: Label 'The "currencyId" does not match to a Currency.', Comment = 'currencyId is a field name and should not be translated.';
        CurrencyCodeDoesNotMatchACurrencyErr: Label 'The "currencyCode" does not match to a Currency.', Comment = 'currencyCode is a field name and should not be translated.';
        PaymentTermsIdDoesNotMatchAPaymentTermsErr: Label 'The "paymentTermsId" does not match to a Payment Terms.', Comment = 'paymentTermsId is a field name and should not be translated.';
        ShipmentMethodIdDoesNotMatchAShipmentMethodErr: Label 'The "shipmentMethodId" does not match to a Shipment Method.', Comment = 'shipmentMethodId is a field name and should not be translated.';
        DiscountAmountSet: Boolean;
        InvoiceDiscountAmount: Decimal;
        BlankGUID: Guid;
        DocumentDateSet: Boolean;
        DocumentDateVar: Date;
        PostingDateSet: Boolean;
        PostingDateVar: Date;
        DueDateSet: Boolean;
        DueDateVar: Date;
        CannotFindQuoteErr: Label 'The quote cannot be found.';
        HasWritePermission: Boolean;

    local procedure SetCalculatedFields()
    begin
        Rec.LoadFields("Currency Code");
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, Rec."Currency Code");
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(DiscountAmountSet);
        Clear(InvoiceDiscountAmount);

        TempFieldBuffer.DeleteAll();
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    var
        LastOrderNo: Integer;
    begin
        LastOrderNo := 1;
        if TempFieldBuffer.FindLast() then
            LastOrderNo := TempFieldBuffer.Order + 1;

        Clear(TempFieldBuffer);
        TempFieldBuffer.Order := LastOrderNo;
        TempFieldBuffer."Table ID" := Database::"Sales Quote Entity Buffer";
        TempFieldBuffer."Field ID" := FieldNo;
        TempFieldBuffer.Insert();
    end;

    local procedure CheckSellToCustomerSpecified()
    begin
        if (Rec."Sell-to Customer No." = '') and
           (Rec."Customer Id" = BlankGUID)
        then
            Error(SellToCustomerNotProvidedErr);
    end;

    local procedure CheckPermissions()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        if not SalesHeader.ReadPermission() then
            Error(SalesQuotePermissionsErr);

        HasWritePermission := SalesHeader.WritePermission();
    end;

    local procedure UpdateDiscount()
    var
        SalesHeader: Record "Sales Header";
        GraphMgtSalesQuoteBuffer: Codeunit "Graph Mgt - Sales Quote Buffer";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
    begin
        if not DiscountAmountSet then begin
            GraphMgtSalesQuoteBuffer.RedistributeInvoiceDiscounts(Rec);
            exit;
        end;

        SalesHeader.Get(SalesHeader."Document Type"::Quote, Rec."No.");
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, SalesHeader);
    end;

    local procedure SetDates()
    var
        GraphMgtSalesQuoteBuffer: Codeunit "Graph Mgt - Sales Quote Buffer";
    begin
        if not (DueDateSet or DocumentDateSet or PostingDateSet) then
            exit;

        TempFieldBuffer.Reset();
        TempFieldBuffer.DeleteAll();

        if DocumentDateSet then begin
            Rec."Document Date" := DocumentDateVar;
            RegisterFieldSet(Rec.FieldNo("Document Date"));
        end;

        if PostingDateSet then begin
            Rec."Posting Date" := PostingDateVar;
            RegisterFieldSet(Rec.FieldNo("Posting Date"));
        end;

        if DueDateSet then begin
            Rec."Due Date" := DueDateVar;
            RegisterFieldSet(Rec.FieldNo("Due Date"));
        end;

        GraphMgtSalesQuoteBuffer.PropagateOnModify(Rec, TempFieldBuffer);
        Rec.Find();
    end;

    local procedure GetQuote(var SalesHeader: Record "Sales Header")
    begin
        if not SalesHeader.GetBySystemId(Rec.Id) then
            Error(CannotFindQuoteErr);
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; var SalesHeader: Record "Sales Header")
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Invoice:
                ActionContext.SetObjectId(Page::"APIV2 - Sales Invoices");
            SalesHeader."Document Type"::Order:
                ActionContext.SetObjectId(Page::"APIV2 - Sales Orders");
            SalesHeader."Document Type"::Quote:
                ActionContext.SetObjectId(Page::"APIV2 - Sales Quotes");
        end;
        ActionContext.AddEntityKey(Rec.FieldNo(Id), SalesHeader.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure MakeInvoice(var ActionContext: WebServiceActionContext)
    var
        SalesHeader: Record "Sales Header";
        SalesQuoteToInvoice: Codeunit "Sales-Quote to Invoice";
    begin
        GetQuote(SalesHeader);
        SalesHeader.SETRECFILTER();
        SalesQuoteToInvoice.RUN(SalesHeader);
        SalesQuoteToInvoice.GetSalesInvoiceHeader(SalesHeader);
        SetActionResponse(ActionContext, SalesHeader);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure MakeOrder(var ActionContext: WebServiceActionContext)
    var
        SalesHeader: Record "Sales Header";
        SalesQuoteToOrder: Codeunit "Sales-Quote to Order";
    begin
        GetQuote(SalesHeader);
        SalesHeader.SETRECFILTER();
        SalesQuoteToOrder.RUN(SalesHeader);
        SalesQuoteToOrder.GetSalesOrderHeader(SalesHeader);
        SetActionResponse(ActionContext, SalesHeader);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Send(var ActionContext: WebServiceActionContext)
    var
        SalesHeader: Record "Sales Header";
        APIV2SendSalesDocument: Codeunit "APIV2 - Send Sales Document";
    begin
        GetQuote(SalesHeader);
        APIV2SendSalesDocument.SendQuote(SalesHeader);
        SetActionResponse(ActionContext, SalesHeader);
    end;
}
