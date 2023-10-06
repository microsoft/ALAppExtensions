namespace Microsoft.API.V1;

using Microsoft.Integration.Entity;
using Microsoft.Sales.Customer;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.Integration.Graph;
using Microsoft.Sales.History;
using Microsoft.Sales.Document;
using System.Threading;
using System.Email;
using Microsoft.Sales.Posting;
using Microsoft.Utilities;

page 20012 "APIV1 - Sales Invoices"
{
    APIVersion = 'v1.0';
    Caption = 'salesInvoices', Locked = true;
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'salesInvoice';
    EntitySetName = 'salesInvoices';
    ODataKeyFields = Id;
    PageType = API;
    SourceTable = "Sales Invoice Entity Aggregate";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.Id)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Id));
                    end;
                }
                field(number; Rec."No.")
                {
                    Caption = 'number', Locked = true;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("No."));
                    end;
                }
                field(externalDocumentNumber; Rec."External Document No.")
                {
                    Caption = 'externalDocumentNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("External Document No."));
                    end;
                }
                field(invoiceDate; Rec."Document Date")
                {
                    Caption = 'invoiceDate', Locked = true;

                    trigger OnValidate()
                    begin
                        DocumentDateVar := Rec."Document Date";
                        DocumentDateSet := true;

                        RegisterFieldSet(Rec.FieldNo("Document Date"));
                    end;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'postingDate', Locked = true;

                    trigger OnValidate()
                    begin
                        PostingDateVar := Rec."Posting Date";
                        PostingDateSet := true;

                        RegisterFieldSet(Rec.FieldNo("Posting Date"));
                    end;
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'dueDate', Locked = true;

                    trigger OnValidate()
                    begin
                        DueDateVar := Rec."Due Date";
                        DueDateSet := true;

                        RegisterFieldSet(Rec.FieldNo("Due Date"));
                    end;
                }
                field(customerPurchaseOrderReference; Rec."Your Reference")
                {
                    Caption = 'customerPurchaseOrderReference', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Your Reference"));
                    end;
                }
                field(customerId; Rec."Customer Id")
                {
                    Caption = 'customerId', Locked = true;

                    trigger OnValidate()
                    begin
                        if not SellToCustomer.GetBySystemId(Rec."Customer Id") then
                            error(CouldNotFindSellToCustomerErr);

                        Rec."Sell-to Customer No." := SellToCustomer."No.";
                        RegisterFieldSet(Rec.FieldNo("Customer Id"));
                        RegisterFieldSet(Rec.FieldNo("Sell-to Customer No."));
                    end;
                }
                field(contactId; Rec."Contact Graph Id")
                {
                    Caption = 'contactId', Locked = true;
                }
                field(customerNumber; Rec."Sell-to Customer No.")
                {
                    Caption = 'customerNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        if SellToCustomer."No." <> '' then begin
                            if SellToCustomer."No." <> Rec."Sell-to Customer No." then
                                error(SellToCustomerValuesDontMatchErr);
                            exit;
                        end;

                        if not SellToCustomer.GET(Rec."Sell-to Customer No.") then
                            error(CouldNotFindSellToCustomerErr);

                        Rec."Customer Id" := SellToCustomer.SystemId;
                        RegisterFieldSet(Rec.FieldNo("Customer Id"));
                        RegisterFieldSet(Rec.FieldNo("Sell-to Customer No."));
                    end;
                }
                field(customerName; Rec."Sell-to Customer Name")
                {
                    Caption = 'customerName', Locked = true;
                    Editable = false;
                }
                field(billToName; Rec."Bill-to Name")
                {
                    Caption = 'billToName', Locked = true;
                    Editable = false;
                }
                field(billToCustomerId; Rec."Bill-to Customer Id")
                {
                    Caption = 'billToCustomerId', Locked = true;

                    trigger OnValidate()
                    begin
                        if not BillToCustomer.GetBySystemId(Rec."Bill-to Customer Id") then
                            error(CouldNotFindBillToCustomerErr);

                        Rec."Bill-to Customer No." := BillToCustomer."No.";
                        RegisterFieldSet(Rec.FieldNo("Bill-to Customer Id"));
                        RegisterFieldSet(Rec.FieldNo("Bill-to Customer No."));
                    end;
                }
                field(billToCustomerNumber; Rec."Bill-to Customer No.")
                {
                    Caption = 'billToCustomerNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        if BillToCustomer."No." <> '' then begin
                            if BillToCustomer."No." <> Rec."Bill-to Customer No." then
                                error(BillToCustomerValuesDontMatchErr);
                            exit;
                        end;

                        if not BillToCustomer.GET(Rec."Bill-to Customer No.") then
                            error(CouldNotFindBillToCustomerErr);

                        Rec."Bill-to Customer Id" := BillToCustomer.SystemId;
                        RegisterFieldSet(Rec.FieldNo("Bill-to Customer Id"));
                        RegisterFieldSet(Rec.FieldNo("Bill-to Customer No."));
                    end;
                }
                field(shipToName; Rec."Ship-to Name")
                {
                    Caption = 'shipToName', Locked = true;

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
                    Caption = 'shipToContact', Locked = true;

                    trigger OnValidate()
                    begin
                        if xRec."Ship-to Contact" <> Rec."Ship-to Contact" then begin
                            Rec."Ship-to Code" := '';
                            RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
                            RegisterFieldSet(Rec.FieldNo("Ship-to Contact"));
                        end;
                    end;
                }
                field(sellingPostalAddress; SellingPostalAddressJSONText)
                {
                    Caption = 'sellingPostalAddress', Locked = true;
#pragma warning disable AL0667
                    ODataEDMType = 'POSTALADDRESS';
#pragma warning restore
                    ToolTip = 'Specifies the selling address of the Sales Invoice.';

                    trigger OnValidate()
                    begin
                        SellingPostalAddressSet := true;
                    end;
                }
                field(billingPostalAddress; BillingPostalAddressJSONText)
                {
                    Caption = 'billingPostalAddress', Locked = true;
#pragma warning disable AL0667
                    ODataEDMType = 'POSTALADDRESS';
#pragma warning restore
                    ToolTip = 'Specifies the billing address of the Sales Invoice.';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        Error(BillingPostalAddressIsReadOnlyErr);
                    end;
                }
                field(shippingPostalAddress; ShippingPostalAddressJSONText)
                {
                    Caption = 'shippingPostalAddress', Locked = true;
#pragma warning disable AL0667
                    ODataEDMType = 'POSTALADDRESS';
#pragma warning restore
                    ToolTip = 'Specifies the shipping address of the Sales Invoice.';

                    trigger OnValidate()
                    begin
                        ShippingPostalAddressSet := true;
                    end;
                }
                field(currencyId; Rec."Currency Id")
                {
                    Caption = 'currencyId', Locked = true;

                    trigger OnValidate()
                    begin
                        if Rec."Currency Id" = BlankGUID then
                            Rec."Currency Code" := ''
                        else begin
                            if not Currency.GetBySystemId(Rec."Currency Id") then
                                error(CurrencyIdDoesNotMatchACurrencyErr);

                            Rec."Currency Code" := Currency.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Currency Id"));
                        RegisterFieldSet(Rec.FieldNo("Currency Code"));
                    end;
                }
                field(currencyCode; CurrencyCodeTxt)
                {
                    Caption = 'currencyCode', Locked = true;

                    trigger OnValidate()
                    begin
                        Rec."Currency Code" :=
                          GraphMgtGeneralTools.TranslateCurrencyCodeToNAVCurrencyCode(
                            LCYCurrencyCode, COPYSTR(CurrencyCodeTxt, 1, MAXSTRLEN(LCYCurrencyCode)));

                        if Currency.Code <> '' then begin
                            if Currency.Code <> Rec."Currency Code" then
                                error(CurrencyValuesDontMatchErr);
                            exit;
                        end;

                        if Rec."Currency Code" = '' then
                            Rec."Currency Id" := BlankGUID
                        else begin
                            if not Currency.GET(Rec."Currency Code") then
                                error(CurrencyCodeDoesNotMatchACurrencyErr);

                            Rec."Currency Id" := Currency.SystemId;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Currency Id"));
                        RegisterFieldSet(Rec.FieldNo("Currency Code"));
                    end;
                }
                field(orderId; Rec."Order Id")
                {
                    Caption = 'orderId', Locked = true;
                    Editable = false;
                }
                field(orderNumber; Rec."Order No.")
                {
                    Caption = 'orderNumber', Locked = true;
                    Editable = false;
                }
                field(paymentTermsId; Rec."Payment Terms Id")
                {
                    Caption = 'paymentTermsId', Locked = true;

                    trigger OnValidate()
                    begin
                        if Rec."Payment Terms Id" = BlankGUID then
                            Rec."Payment Terms Code" := ''
                        else begin
                            if not PaymentTerms.GetBySystemId(Rec."Payment Terms Id") then
                                error(PaymentTermsIdDoesNotMatchAPaymentTermsErr);

                            Rec."Payment Terms Code" := PaymentTerms.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Payment Terms Id"));
                        RegisterFieldSet(Rec.FieldNo("Payment Terms Code"));
                    end;
                }
                field(shipmentMethodId; Rec."Shipment Method Id")
                {
                    Caption = 'shipmentMethodId', Locked = true;

                    trigger OnValidate()
                    begin
                        if Rec."Shipment Method Id" = BlankGUID then
                            Rec."Shipment Method Code" := ''
                        else begin
                            if not ShipmentMethod.GetBySystemId(Rec."Shipment Method Id") then
                                error(ShipmentMethodIdDoesNotMatchAShipmentMethodErr);

                            Rec."Shipment Method Code" := ShipmentMethod.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Shipment Method Id"));
                        RegisterFieldSet(Rec.FieldNo("Shipment Method Code"));
                    end;
                }
                field(salesperson; Rec."Salesperson Code")
                {
                    Caption = 'salesperson', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Salesperson Code"));
                    end;
                }
                field(pricesIncludeTax; Rec."Prices Including VAT")
                {
                    Caption = 'pricesIncludeTax', Locked = true;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Prices Including VAT"));
                    end;
                }

                field(remainingAmount; RemainingAmountVar)
                {
                    Caption = 'remainingAmount', Locked = true;
                    Editable = false;
                }
                part(salesInvoiceLines; "APIV1 - Sales Invoice Lines")
                {
                    Caption = 'Lines', Locked = true;
                    EntityName = 'salesInvoiceLine';
                    EntitySetName = 'salesInvoiceLines';
                    SubPageLink = "Document Id" = field(Id);
                }
                part(pdfDocument; "APIV1 - PDF Document")
                {
                    Caption = 'PDF Document', Locked = true;
                    EntityName = 'pdfDocument';
                    EntitySetName = 'pdfDocument';
                    SubPageLink = "Document Id" = field(Id);
                }
                field(discountAmount; Rec."Invoice Discount Amount")
                {
                    Caption = 'discountAmount', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Invoice Discount Amount"));
                        InvoiceDiscountAmount := Rec."Invoice Discount Amount";
                        DiscountAmountSet := true;
                    end;
                }
                field(discountAppliedBeforeTax; Rec."Discount Applied Before Tax")
                {
                    Caption = 'discountAppliedBeforeTax', Locked = true;
                    Editable = false;
                }
                field(totalAmountExcludingTax; Rec.Amount)
                {
                    Caption = 'totalAmountExcludingTax', Locked = true;
                    Editable = false;
                }
                field(totalTaxAmount; Rec."Total Tax Amount")
                {
                    Caption = 'totalTaxAmount', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the total tax amount for the sales invoice.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Total Tax Amount"));
                    end;
                }
                field(totalAmountIncludingTax; Rec."Amount Including VAT")
                {
                    Caption = 'totalAmountIncludingTax', Locked = true;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Amount Including VAT"));
                    end;
                }
                field(status; Rec.Status)
                {
                    Caption = 'status', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the status of the Sales Invoice (cancelled, paid, on hold, created).';
                }
                field(lastModifiedDateTime; Rec."Last Modified Date Time")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                    Editable = false;
                }
                field(phoneNumber; Rec."Sell-to Phone No.")
                {
                    Caption = 'phoneNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Sell-to Phone No."));
                    end;
                }
                field(email; Rec."Sell-to E-Mail")
                {
                    Caption = 'email', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Sell-to E-Mail"));
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        if not Rec.Posted then
            if HasWritePermissionForDraft then
                SalesInvoiceAggregator.RedistributeInvoiceDiscounts(Rec);
        SetCalculatedFields();
    end;

    trigger OnDeleteRecord(): Boolean
    var
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        SalesInvoiceAggregator.PropagateOnDelete(Rec);

        exit(false);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        CheckSellToCustomerSpecified();
        ProcessSellingPostalAddressOnInsert();
        ProcessShippingPostalAddressOnInsert();

        SalesInvoiceAggregator.PropagateOnInsert(Rec, TempFieldBuffer);
        SetDates();

        UpdateDiscount();

        SetCalculatedFields();

        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        if xRec.Id <> Rec.Id then
            error(CannotChangeIDErr);

        ProcessSellingPostalAddressOnModify();
        ProcessShippingPostalAddressOnModify();

        SalesInvoiceAggregator.PropagateOnModify(Rec, TempFieldBuffer);
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
        SetPermissionFilters();
    end;

    var
        TempFieldBuffer: Record 8450 temporary;
        SellToCustomer: Record "Customer";
        BillToCustomer: Record "Customer";
        Currency: Record "Currency";
        PaymentTerms: Record "Payment Terms";
        ShipmentMethod: Record "Shipment Method";
        O365SetupEmail: Codeunit "O365 Setup Email";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        APIV1SendSalesDocument: Codeunit "APIV1 - Send Sales Document";
        CannotChangeIDErr: Label 'The id cannot be changed.', Locked = true;
        LCYCurrencyCode: Code[10];
        CurrencyCodeTxt: Text;
        SellingPostalAddressJSONText: Text;
        BillingPostalAddressJSONText: Text;
        ShippingPostalAddressJSONText: Text;
        SellingPostalAddressSet: Boolean;
        ShippingPostalAddressSet: Boolean;
        SellToCustomerNotProvidedErr: Label 'A customerNumber or a customerId must be provided.', Locked = true;
        SellToCustomerValuesDontMatchErr: Label 'The sell-to customer values do not match to a specific Customer.', Locked = true;
        BillToCustomerValuesDontMatchErr: Label 'The bill-to customer values do not match to a specific Customer.', Locked = true;
        CouldNotFindSellToCustomerErr: Label 'The sell-to customer cannot be found.', Locked = true;
        CouldNotFindBillToCustomerErr: Label 'The bill-to customer cannot be found.', Locked = true;
        CurrencyValuesDontMatchErr: Label 'The currency values do not match to a specific Currency.', Locked = true;
        CurrencyIdDoesNotMatchACurrencyErr: Label 'The "currencyId" does not match to a Currency.', Locked = true;
        CurrencyCodeDoesNotMatchACurrencyErr: Label 'The "currencyCode" does not match to a Currency.', Locked = true;
        BlankGUID: Guid;
        PaymentTermsIdDoesNotMatchAPaymentTermsErr: Label 'The "paymentTermsId" does not match to a Payment Terms.', Locked = true;
        ShipmentMethodIdDoesNotMatchAShipmentMethodErr: Label 'The "shipmentMethodId" does not match to a Shipment Method.', Locked = true;
        PermissionFilterFormatTxt: Label '<>%1&<>%2', Locked = true;
        PermissionInvoiceFilterformatTxt: Label '<>%1&<>%2&<>%3&<>%4', Locked = true;
        DiscountAmountSet: Boolean;
        InvoiceDiscountAmount: Decimal;
        RemainingAmountVar: Decimal;
        DocumentDateSet: Boolean;
        DocumentDateVar: Date;
        PostingDateSet: Boolean;
        PostingDateVar: Date;
        DueDateSet: Boolean;
        DueDateVar: Date;
        PostedInvoiceActionErr: Label 'The action can be applied to a posted invoice only.', Locked = true;
        DraftInvoiceActionErr: Label 'The action can be applied to a draft invoice only.', Locked = true;
        CannotFindInvoiceErr: Label 'The invoice cannot be found.', Locked = true;
        CancelingInvoiceFailedCreditMemoCreatedAndPostedErr: Label 'Canceling the invoice failed because of the following error: \\%1\\A credit memo is posted.', Locked = true;
        CancelingInvoiceFailedCreditMemoCreatedButNotPostedErr: Label 'Canceling the invoice failed because of the following error: \\%1\\A credit memo is created but not posted.', Locked = true;
        CancelingInvoiceFailedNothingCreatedErr: Label 'Canceling the invoice failed because of the following error: \\%1.', Locked = true;
        EmptyEmailErr: Label 'The send-to email is empty. Specify email either for the customer or for the invoice in email preview.', Locked = true;
        AlreadyCanceledErr: Label 'The invoice cannot be canceled because it has already been canceled.', Locked = true;
        BillingPostalAddressIsReadOnlyErr: Label 'The "billingPotalAddress" is read-only.', Locked = true;
        InvoiceClosedErr: Label 'The invoice is closed. The corrective credit memo will not be applied to the invoice.', Locked = true;
        InvoicePartiallyPaidErr: Label 'The invoice is partially paid or credited. The corrective credit memo may not be fully closed by the invoice.', Locked = true;
        HasWritePermissionForDraft: Boolean;

    local procedure SetCalculatedFields()
    var
        GraphMgtSalesInvoice: Codeunit "Graph Mgt - Sales Invoice";
    begin
        SellingPostalAddressJSONText := GraphMgtSalesInvoice.SellToCustomerAddressToJSON(Rec);
        BillingPostalAddressJSONText := GraphMgtSalesInvoice.BillToCustomerAddressToJSON(Rec);
        ShippingPostalAddressJSONText := GraphMgtSalesInvoice.ShipToCustomerAddressToJSON(Rec);

        GetRemainingAmount();
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, Rec."Currency Code");
    end;

    local procedure ClearCalculatedFields()
    begin
        CLEAR(SellingPostalAddressJSONText);
        CLEAR(BillingPostalAddressJSONText);
        CLEAR(ShippingPostalAddressJSONText);
        CLEAR(InvoiceDiscountAmount);
        CLEAR(DiscountAmountSet);
        CLEAR(RemainingAmountVar);
        TempFieldBuffer.DELETEALL();
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    var
        LastOrderNo: Integer;
    begin
        LastOrderNo := 1;
        if TempFieldBuffer.FINDLAST() then
            LastOrderNo := TempFieldBuffer.Order + 1;

        CLEAR(TempFieldBuffer);
        TempFieldBuffer.Order := LastOrderNo;
        TempFieldBuffer."Table ID" := DATABASE::"Sales Invoice Entity Aggregate";
        TempFieldBuffer."Field ID" := FieldNo;
        TempFieldBuffer.insert();
    end;

    local procedure GetRemainingAmount();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        RemainingAmountVar := Rec."Amount Including VAT";
        if Rec.Posted then
            if (Rec.Status = Rec.Status::Canceled) then begin
                RemainingAmountVar := 0;
                exit;
            end else
                if SalesInvoiceHeader.GET(Rec."No.") then
                    RemainingAmountVar := SalesInvoiceHeader.GetRemainingAmount();
    end;

    local procedure CheckSellToCustomerSpecified()
    begin
        if (Rec."Sell-to Customer No." = '') and
           (Rec."Customer Id" = BlankGUID)
        then
            error(SellToCustomerNotProvidedErr);
    end;

    local procedure ProcessSellingPostalAddressOnInsert()
    var
        GraphMgtSalesInvoice: Codeunit "Graph Mgt - Sales Invoice";
    begin
        if not SellingPostalAddressSet then
            exit;

        GraphMgtSalesInvoice.ParseSellToCustomerAddressFromJSON(SellingPostalAddressJSONText, Rec);

        RegisterFieldSet(Rec.FieldNo("Sell-to Address"));
        RegisterFieldSet(Rec.FieldNo("Sell-to Address 2"));
        RegisterFieldSet(Rec.FieldNo("Sell-to City"));
        RegisterFieldSet(Rec.FieldNo("Sell-to Country/Region Code"));
        RegisterFieldSet(Rec.FieldNo("Sell-to Post Code"));
        RegisterFieldSet(Rec.FieldNo("Sell-to County"));
    end;

    local procedure ProcessSellingPostalAddressOnModify()
    var
        GraphMgtSalesInvoice: Codeunit "Graph Mgt - Sales Invoice";
    begin
        if not SellingPostalAddressSet then
            exit;

        GraphMgtSalesInvoice.ParseSellToCustomerAddressFromJSON(SellingPostalAddressJSONText, Rec);

        if xRec."Sell-to Address" <> Rec."Sell-to Address" then
            RegisterFieldSet(Rec.FieldNo("Sell-to Address"));

        if xRec."Sell-to Address 2" <> Rec."Sell-to Address 2" then
            RegisterFieldSet(Rec.FieldNo("Sell-to Address 2"));

        if xRec."Sell-to City" <> Rec."Sell-to City" then
            RegisterFieldSet(Rec.FieldNo("Sell-to City"));

        if xRec."Sell-to Country/Region Code" <> Rec."Sell-to Country/Region Code" then
            RegisterFieldSet(Rec.FieldNo("Sell-to Country/Region Code"));

        if xRec."Sell-to Post Code" <> Rec."Sell-to Post Code" then
            RegisterFieldSet(Rec.FieldNo("Sell-to Post Code"));

        if xRec."Sell-to County" <> Rec."Sell-to County" then
            RegisterFieldSet(Rec.FieldNo("Sell-to County"));
    end;

    local procedure ProcessShippingPostalAddressOnInsert()
    var
        GraphMgtSalesInvoice: Codeunit "Graph Mgt - Sales Invoice";
    begin
        if not ShippingPostalAddressSet then
            exit;

        GraphMgtSalesInvoice.ParseShipToCustomerAddressFromJSON(ShippingPostalAddressJSONText, Rec);

        Rec."Ship-to Code" := '';
        RegisterFieldSet(Rec.FieldNo("Ship-to Address"));
        RegisterFieldSet(Rec.FieldNo("Ship-to Address 2"));
        RegisterFieldSet(Rec.FieldNo("Ship-to City"));
        RegisterFieldSet(Rec.FieldNo("Ship-to Country/Region Code"));
        RegisterFieldSet(Rec.FieldNo("Ship-to Post Code"));
        RegisterFieldSet(Rec.FieldNo("Ship-to County"));
        RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
    end;

    local procedure ProcessShippingPostalAddressOnModify()
    var
        GraphMgtSalesInvoice: Codeunit "Graph Mgt - Sales Invoice";
        Changed: Boolean;
    begin
        if not ShippingPostalAddressSet then
            exit;

        GraphMgtSalesInvoice.ParseShipToCustomerAddressFromJSON(ShippingPostalAddressJSONText, Rec);

        if xRec."Ship-to Address" <> Rec."Ship-to Address" then begin
            RegisterFieldSet(Rec.FieldNo("Ship-to Address"));
            Changed := true;
        end;

        if xRec."Ship-to Address 2" <> Rec."Ship-to Address 2" then begin
            RegisterFieldSet(Rec.FieldNo("Ship-to Address 2"));
            Changed := true;
        end;

        if xRec."Ship-to City" <> Rec."Ship-to City" then begin
            RegisterFieldSet(Rec.FieldNo("Ship-to City"));
            Changed := true;
        end;

        if xRec."Ship-to Country/Region Code" <> Rec."Ship-to Country/Region Code" then begin
            RegisterFieldSet(Rec.FieldNo("Ship-to Country/Region Code"));
            Changed := true;
        end;

        if xRec."Ship-to Post Code" <> Rec."Ship-to Post Code" then begin
            RegisterFieldSet(Rec.FieldNo("Ship-to Post Code"));
            Changed := true;
        end;

        if xRec."Ship-to County" <> Rec."Ship-to County" then begin
            RegisterFieldSet(Rec.FieldNo("Ship-to County"));
            Changed := true;
        end;

        if Changed then begin
            Rec."Ship-to Code" := '';
            RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
        end;
    end;

    local procedure SetPermissionFilters()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        FilterText: Text;
    begin
        // Filtering out test documents
        SalesHeader.SETRANGE(IsTest, false);

        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        if not SalesHeader.READPERMISSION() then
            FilterText :=
              STRSUBSTNO(PermissionFilterFormatTxt, Rec.Status::Draft, Rec.Status::"In Review");

        if not SalesInvoiceHeader.READPERMISSION() then begin
            if FilterText <> '' then
                FilterText += '&';
            FilterText +=
              STRSUBSTNO(
                PermissionInvoiceFilterformatTxt, Rec.Status::Canceled, Rec.Status::Corrective,
                Rec.Status::Open, Rec.Status::Paid);
        end;

        if FilterText <> '' then begin
            Rec.filterGROUP(2);
            Rec.SETfilter(Status, FilterText);
            Rec.filterGROUP(0);
        end;

        HasWritePermissionForDraft := SalesHeader.WRITEPERMISSION();
    end;

    local procedure UpdateDiscount()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
    begin
        if Rec.Posted then
            exit;

        if not DiscountAmountSet then begin
            SalesInvoiceAggregator.RedistributeInvoiceDiscounts(Rec);
            exit;
        end;

        SalesHeader.GET(Rec."Document Type"::Invoice, Rec."No.");
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, SalesHeader);
    end;

    local procedure SetDates()
    var
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        if not (DueDateSet or DocumentDateSet or PostingDateSet) then
            exit;

        TempFieldBuffer.RESET();
        TempFieldBuffer.DELETEALL();

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

        SalesInvoiceAggregator.PropagateOnModify(Rec, TempFieldBuffer);
        Rec.FIND();
    end;

    local procedure GetPostedInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        if not Rec.Posted then
            error(PostedInvoiceActionErr);

        if not SalesInvoiceAggregator.GetSalesInvoiceHeaderFromId(Rec.Id, SalesInvoiceHeader) then
            Error(CannotFindInvoiceErr);
    end;

    local procedure GetDraftInvoice(var SalesHeader: Record "Sales Header")
    begin
        if Rec.Posted then
            error(DraftInvoiceActionErr);

        SalesHeader.SETRANGE(SystemId, Rec.Id);
        if not SalesHeader.FINDFIRST() then
            error(CannotFindInvoiceErr);

        SalesHeader.SETRANGE(SystemId);
    end;

    local procedure CheckSendToEmailAddress(DocumentNo: Code[20])
    begin
        if GetSendToEmailAddress(DocumentNo) = '' then
            error(EmptyEmailErr);
    end;

    local procedure GetSendToEmailAddress(DocumentNo: Code[20]): Text[250]
    var
        EmailAddress: Text[250];
    begin
        EmailAddress := GetDocumentEmailAddress(DocumentNo);
        if EmailAddress <> '' then
            exit(EmailAddress);
        EmailAddress := GetCustomerEmailAddress();
        exit(EmailAddress);
    end;

    local procedure GetCustomerEmailAddress(): Text[250]
    var
        Customer: Record Customer;
    begin
        if not Customer.GET(Rec."Sell-to Customer No.") then
            exit('');
        exit(Customer."E-Mail");
    end;

    local procedure GetDocumentEmailAddress(DocumentNo: Code[20]): Text[250]
    var
        EmailParameter: Record "Email Parameter";
    begin
        if not EmailParameter.GET(DocumentNo, Rec."Document Type", EmailParameter."Parameter Type"::Address) then
            exit('');
        exit(EmailParameter."Parameter Value");
    end;

    local procedure CheckInvoiceCanBeCanceled(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
    begin
        if IsInvoiceCanceled() then
            error(AlreadyCanceledErr);
        CorrectPostedSalesInvoice.TestCorrectInvoiceIsAllowed(SalesInvoiceHeader, true);
    end;

    local procedure IsInvoiceCanceled(): Boolean
    begin
        exit(Rec.Status = Rec.Status::Canceled);
    end;

    local procedure PostInvoice(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
        PreAssignedNo: Code[20];
    begin
        APIV1SendSalesDocument.CheckDocumentIfNoItemsExists(SalesHeader);
        LinesInstructionMgt.SalesCheckAllLinesHaveQuantityAssigned(SalesHeader);
        PreAssignedNo := SalesHeader."No.";
        SalesHeader.SendToPosting(CODEUNIT::"Sales-Post");
        SalesInvoiceHeader.SETCURRENTKEY("Pre-Assigned No.");
        SalesInvoiceHeader.SETRANGE("Pre-Assigned No.", PreAssignedNo);
        SalesInvoiceHeader.FINDFIRST();
    end;

    local procedure SendPostedInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        O365SetupEmail.CheckMailSetup();
        CheckSendToEmailAddress(SalesInvoiceHeader."No.");

        SalesInvoiceHeader.SETRECfilter();
        SalesInvoiceHeader.EmailRecords(false);
    end;

    local procedure SendDraftInvoice(var SalesHeader: Record "Sales Header")
    var
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
    begin
        APIV1SendSalesDocument.CheckDocumentIfNoItemsExists(SalesHeader);
        LinesInstructionMgt.SalesCheckAllLinesHaveQuantityAssigned(SalesHeader);
        O365SetupEmail.CheckMailSetup();
        CheckSendToEmailAddress(SalesHeader."No.");

        SalesHeader.SETRECfilter();
        SalesHeader.EmailRecords(false);
    end;

    local procedure SendCanceledInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        O365SetupEmail.CheckMailSetup();
        CheckSendToEmailAddress(SalesInvoiceHeader."No.");

        JobQueueEntry.INIT();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := CODEUNIT::"O365 Sales Cancel Invoice";
        JobQueueEntry."Maximum No. of Attempts to Run" := 3;
        JobQueueEntry."Record ID to Process" := SalesInvoiceHeader.RECORDID();
        CODEUNIT.RUN(CODEUNIT::"Job Queue - Enqueue", JobQueueEntry);
    end;

    local procedure CancelInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
    begin
        GetPostedInvoice(SalesInvoiceHeader);
        CheckInvoiceCanBeCanceled(SalesInvoiceHeader);
        if not CODEUNIT.RUN(CODEUNIT::"Correct Posted Sales Invoice", SalesInvoiceHeader) then begin
            SalesCrMemoHeader.SETRANGE("Applies-to Doc. No.", SalesInvoiceHeader."No.");
            if not SalesCrMemoHeader.IsEmpty() then
                error(CancelingInvoiceFailedCreditMemoCreatedAndPostedErr, GETLASTerrorTEXT());
            SalesHeader.SETRANGE("Applies-to Doc. No.", SalesInvoiceHeader."No.");
            if not SalesHeader.IsEmpty() then
                error(CancelingInvoiceFailedCreditMemoCreatedButNotPostedErr, GETLASTerrorTEXT());
            error(CancelingInvoiceFailedNothingCreatedErr, GETLASTerrorTEXT());
        end;
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; InvoiceId: Guid)
    var
    begin
        SetActionResponse(ActionContext, Page::"APIV1 - Sales Invoices", InvoiceId);
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; PageId: Integer; DocumentId: Guid)
    var
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(PageId);
        ActionContext.AddEntityKey(Rec.FieldNo(Id), DocumentId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Post(var ActionContext: WebServiceActionContext)
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        GetDraftInvoice(SalesHeader);
        PostInvoice(SalesHeader, SalesInvoiceHeader);
        SetActionResponse(ActionContext, SalesInvoiceAggregator.GetSalesInvoiceHeaderId(SalesInvoiceHeader));
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure PostAndSend(var ActionContext: WebServiceActionContext)
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        GetDraftInvoice(SalesHeader);
        PostInvoice(SalesHeader, SalesInvoiceHeader);
        COMMIT();
        SendPostedInvoice(SalesInvoiceHeader);
        SetActionResponse(ActionContext, SalesInvoiceAggregator.GetSalesInvoiceHeaderId(SalesInvoiceHeader));
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Send(var ActionContext: WebServiceActionContext)
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        if Rec.Posted then begin
            GetPostedInvoice(SalesInvoiceHeader);
            if IsInvoiceCanceled() then
                SendCanceledInvoice(SalesInvoiceHeader)
            else
                SendPostedInvoice(SalesInvoiceHeader);
            SetActionResponse(ActionContext, SalesInvoiceAggregator.GetSalesInvoiceHeaderId(SalesInvoiceHeader));
            exit;
        end;
        GetDraftInvoice(SalesHeader);
        SendDraftInvoice(SalesHeader);
        SetActionResponse(ActionContext, SalesHeader.SystemId);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Cancel(var ActionContext: WebServiceActionContext)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        GetPostedInvoice(SalesInvoiceHeader);
        CancelInvoice(SalesInvoiceHeader);
        SetActionResponse(ActionContext, SalesInvoiceAggregator.GetSalesInvoiceHeaderId(SalesInvoiceHeader));
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure CancelAndSend(var ActionContext: WebServiceActionContext)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        GetPostedInvoice(SalesInvoiceHeader);
        CancelInvoice(SalesInvoiceHeader);
        SendCanceledInvoice(SalesInvoiceHeader);
        SetActionResponse(ActionContext, SalesInvoiceAggregator.GetSalesInvoiceHeaderId(SalesInvoiceHeader));
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure MakeCorrectiveCreditMemo(var ActionContext: WebServiceActionContext)
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
    begin
        GetPostedInvoice(SalesInvoiceHeader);
        SalesInvoiceHeader.CalcFields("Amount Including VAT", "Remaining Amount", Closed);
        if SalesInvoiceHeader."Amount Including VAT" <> SalesInvoiceHeader."Remaining Amount" then
            if SalesInvoiceHeader.Closed then
                Error(InvoiceClosedErr)
            else
                Error(InvoicePartiallyPaidErr);
        SalesInvoiceHeader.SETRECfilter();
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
        SetActionResponse(ActionContext, Page::"APIV1 - Sales Credit Memos", SalesHeader.SystemId);
    end;
}
