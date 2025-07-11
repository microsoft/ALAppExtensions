namespace Microsoft.API.V1;

using Microsoft.Integration.Entity;
using Microsoft.Sales.History;
using Microsoft.Sales.Customer;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.Integration.Graph;
using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;
using Microsoft.Utilities;
using System.Reflection;

page 20038 "APIV1 - Sales Credit Memos"
{
    APIVersion = 'v1.0';
    Caption = 'salesCreditMemos', Locked = true;
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'salesCreditMemo';
    EntitySetName = 'salesCreditMemos';
    ODataKeyFields = Id;
    PageType = API;
    SourceTable = "Sales Cr. Memo Entity Buffer";
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
                        RegisterFieldSet(Rec.FieldNo("External Document No."))
                    end;
                }
                field(creditMemoDate; Rec."Document Date")
                {
                    Caption = 'creditMemoDate', Locked = true;

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
                    ToolTip = 'Specifies the billing address of the Sales Credit Memo.';

                    trigger OnValidate()
                    begin
                        BillingPostalAddressSet := true;
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
                part(salesCreditMemoLines; "APIV1 - Sales Credit Mem Lines")
                {
                    Caption = 'Lines', Locked = true;
                    EntityName = 'salesCreditMemoLine';
                    EntitySetName = 'salesCreditMemoLines';
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
                        DiscountAmountSet := true;
                        InvoiceDiscountAmount := Rec."Invoice Discount Amount";
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
                    ToolTip = 'Specifies the total tax amount for the sales credit memo.';

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
                    ToolTip = 'Specifies the status of the Sales Credit Memo (cancelled, paid, on hold, created).';
                }
                field(lastModifiedDateTime; Rec."Last Modified Date Time")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                    Editable = false;
                }
                field(invoiceId; SalesInvoiceId)
                {
                    Caption = 'invoiceId', Locked = true;

                    trigger OnValidate()
                    var
                        SalesInvoiceHeader: Record "Sales Invoice Header";
                        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
                        EmptyGuid: Guid;
                    begin
                        if SalesInvoiceId = EmptyGuid then begin
                            Rec."Applies-to Doc. Type" := Rec."Applies-to Doc. Type"::" ";
                            CLEAR(Rec."Applies-to Doc. No.");
                            CLEAR(InvoiceNo);
                            RegisterFieldSet(Rec.FieldNo("Applies-to Doc. Type"));
                            RegisterFieldSet(Rec.FieldNo("Applies-to Doc. No."));
                            exit;
                        end;

                        if not SalesInvoiceAggregator.GetSalesInvoiceHeaderFromId(SalesInvoiceId, SalesInvoiceHeader) then
                            error(InvoiceIdDoesNotMatchAnInvoiceErr);

                        Rec."Applies-to Doc. Type" := Rec."Applies-to Doc. Type"::Invoice;
                        Rec."Applies-to Doc. No." := SalesInvoiceHeader."No.";
                        InvoiceNo := Rec."Applies-to Doc. No.";
                        RegisterFieldSet(Rec.FieldNo("Applies-to Doc. Type"));
                        RegisterFieldSet(Rec.FieldNo("Applies-to Doc. No."));
                    end;
                }
                field(invoiceNumber; Rec."Applies-to Doc. No.")
                {
                    Caption = 'invoiceNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        if InvoiceNo <> '' then begin
                            if Rec."Applies-to Doc. No." <> InvoiceNo then
                                error(InvoiceValuesDontMatchErr);
                            exit;
                        end;

                        Rec."Applies-to Doc. Type" := Rec."Applies-to Doc. Type"::Invoice;

                        RegisterFieldSet(Rec.FieldNo("Applies-to Doc. Type"));
                        RegisterFieldSet(Rec.FieldNo("Applies-to Doc. No."));
                    end;
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
    begin
        SetCalculatedFields();
        if not Rec.Posted then
            if HasWritePermissionForDraft then
                GraphMgtSalCrMemoBuf.RedistributeCreditMemoDiscounts(Rec);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        GraphMgtSalCrMemoBuf.PropagateOnDelete(Rec);

        exit(false);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        CheckSellToCustomerSpecified();
        ProcessSellingPostalAddressOnInsert();
        ProcessBillingPostalAddressOnInsert();

        GraphMgtSalCrMemoBuf.PropagateOnInsert(Rec, TempFieldBuffer);
        SetDates();

        UpdateDiscount();

        SetCalculatedFields();

        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if xRec.Id <> Rec.Id then
            error(CannotChangeIDErr);

        ProcessSellingPostalAddressOnModify();
        ProcessBillingPostalAddressOnModify();

        GraphMgtSalCrMemoBuf.PropagateOnModify(Rec, TempFieldBuffer);
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
        SetPemissionsFilters();
    end;

    var
        TempFieldBuffer: Record "Field Buffer" temporary;
        SellToCustomer: Record "Customer";
        BillToCustomer: Record "Customer";
        Currency: Record "Currency";
        PaymentTerms: Record "Payment Terms";
        ShipmentMethod: Record "Shipment Method";
        GraphMgtSalesCreditMemo: Codeunit "Graph Mgt - Sales Credit Memo";
        GraphMgtSalCrMemoBuf: Codeunit "Graph Mgt - Sal. Cr. Memo Buf.";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        LCYCurrencyCode: Code[10];
        CurrencyCodeTxt: Text;
        SellingPostalAddressJSONText: Text;
        BillingPostalAddressJSONText: Text;
        SellingPostalAddressSet: Boolean;
        BillingPostalAddressSet: Boolean;
        CannotChangeIDErr: Label 'The id cannot be changed.', Locked = true;
        CouldNotFindSellToCustomerErr: Label 'The sell-to customer cannot be found.', Locked = true;
        CouldNotFindBillToCustomerErr: Label 'The bill-to customer cannot be found.', Locked = true;
        SellToCustomerNotProvidedErr: Label 'A customerNumber or a customerId must be provided.', Locked = true;
        SellToCustomerValuesDontMatchErr: Label 'The sell-to customer values do not match to a specific Customer.', Locked = true;
        BillToCustomerValuesDontMatchErr: Label 'The bill-to customer values do not match to a specific Customer.', Locked = true;
        PermissionFilterFormatTxt: Label '<>%1&<>%2', Locked = true;
        PermissionCrMemoFilterformatTxt: Label '<>%1&<>%2&<>%3&<>%4', Locked = true;
        DiscountAmountSet: Boolean;
        InvoiceDiscountAmount: Decimal;
        SalesInvoiceId: Guid;
        InvoiceNo: Code[20];
        InvoiceValuesDontMatchErr: Label 'The invoiceId and invoiceNumber do not match to a specific Invoice.', Locked = true;
        InvoiceIdDoesNotMatchAnInvoiceErr: Label 'The invoiceId does not match to an Invoice.', Locked = true;
        CurrencyValuesDontMatchErr: Label 'The currency values do not match to a specific Currency.', Locked = true;
        CurrencyIdDoesNotMatchACurrencyErr: Label 'The "currencyId" does not match to a Currency.', Locked = true;
        CurrencyCodeDoesNotMatchACurrencyErr: Label 'The "currencyCode" does not match to a Currency.', Locked = true;
        PaymentTermsIdDoesNotMatchAPaymentTermsErr: Label 'The "paymentTermsId" does not match to a Payment Terms.', Locked = true;
        ShipmentMethodIdDoesNotMatchAShipmentMethodErr: Label 'The "shipmentMethodId" does not match to a Shipment Method.', Locked = true;
        PostedCreditMemoActionErr: Label 'The action can be applied to a posted credit memo only.', Locked = true;
        DraftCreditMemoActionErr: Label 'The action can be applied to a draft credit memo only.', Locked = true;
        CannotFindCreditMemoErr: Label 'The credit memo cannot be found.', Locked = true;
        CancelingCreditMemoFailedInvoiceCreatedAndPostedErr: Label 'Canceling the credit memo failed because of the following error: \\%1\\An invoice is posted.', Locked = true;
        CancelingCreditMemoFailedInvoiceCreatedButNotPostedErr: Label 'Canceling the credit memo failed because of the following error: \\%1\\An invoice is created but not posted.', Locked = true;
        CancelingCreditMemoFailedNothingCreatedErr: Label 'Canceling the credit memo failed because of the following error: \\%1.', Locked = true;
        AlreadyCancelledErr: Label 'The credit memo cannot be cancelled because it has already been canceled.', Locked = true;
        NoLineErr: Label 'Please add at least one line item to the credit memo.', Locked = true;
        BlankGUID: Guid;
        DocumentDateSet: Boolean;
        DocumentDateVar: Date;
        PostingDateSet: Boolean;
        PostingDateVar: Date;
        DueDateSet: Boolean;
        DueDateVar: Date;
        HasWritePermissionForDraft: Boolean;

    local procedure SetCalculatedFields()
    begin
        SetInvoiceId();
        SellingPostalAddressJSONText := GraphMgtSalesCreditMemo.SellToCustomerAddressToJSON(Rec);
        BillingPostalAddressJSONText := GraphMgtSalesCreditMemo.BillToCustomerAddressToJSON(Rec);
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, Rec."Currency Code");
    end;

    local procedure ClearCalculatedFields()
    begin
        CLEAR(SalesInvoiceId);
        CLEAR(InvoiceNo);
        CLEAR(SellingPostalAddressJSONText);
        CLEAR(BillingPostalAddressJSONText);
        CLEAR(InvoiceDiscountAmount);
        CLEAR(DiscountAmountSet);
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
        TempFieldBuffer."Table ID" := DATABASE::"Sales Cr. Memo Entity Buffer";
        TempFieldBuffer."Field ID" := FieldNo;
        TempFieldBuffer.insert();
    end;

    local procedure ProcessSellingPostalAddressOnInsert()
    begin
        if not SellingPostalAddressSet then
            exit;

        GraphMgtSalesCreditMemo.ParseSellToCustomerAddressFromJSON(SellingPostalAddressJSONText, Rec);

        RegisterFieldSet(Rec.FieldNo("Sell-to Address"));
        RegisterFieldSet(Rec.FieldNo("Sell-to Address 2"));
        RegisterFieldSet(Rec.FieldNo("Sell-to City"));
        RegisterFieldSet(Rec.FieldNo("Sell-to Country/Region Code"));
        RegisterFieldSet(Rec.FieldNo("Sell-to Post Code"));
        RegisterFieldSet(Rec.FieldNo("Sell-to County"));
    end;

    local procedure ProcessSellingPostalAddressOnModify()
    begin
        if not SellingPostalAddressSet then
            exit;

        GraphMgtSalesCreditMemo.ParseSellToCustomerAddressFromJSON(SellingPostalAddressJSONText, Rec);

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

    local procedure ProcessBillingPostalAddressOnInsert()
    begin
        if not BillingPostalAddressSet then
            exit;

        GraphMgtSalesCreditMemo.ParseBillToCustomerAddressFromJSON(BillingPostalAddressJSONText, Rec);

        RegisterFieldSet(Rec.FieldNo("Bill-to Address"));
        RegisterFieldSet(Rec.FieldNo("Bill-to Address 2"));
        RegisterFieldSet(Rec.FieldNo("Bill-to City"));
        RegisterFieldSet(Rec.FieldNo("Bill-to Country/Region Code"));
        RegisterFieldSet(Rec.FieldNo("Bill-to Post Code"));
        RegisterFieldSet(Rec.FieldNo("Bill-to County"));
    end;

    local procedure ProcessBillingPostalAddressOnModify()
    begin
        if not BillingPostalAddressSet then
            exit;

        GraphMgtSalesCreditMemo.ParseBillToCustomerAddressFromJSON(BillingPostalAddressJSONText, Rec);

        if xRec."Bill-to Address" <> Rec."Bill-to Address" then
            RegisterFieldSet(Rec.FieldNo("Bill-to Address"));

        if xRec."Bill-to Address 2" <> Rec."Bill-to Address 2" then
            RegisterFieldSet(Rec.FieldNo("Bill-to Address 2"));

        if xRec."Bill-to City" <> Rec."Bill-to City" then
            RegisterFieldSet(Rec.FieldNo("Bill-to City"));

        if xRec."Bill-to Country/Region Code" <> Rec."Bill-to Country/Region Code" then
            RegisterFieldSet(Rec.FieldNo("Bill-to Country/Region Code"));

        if xRec."Bill-to Post Code" <> Rec."Bill-to Post Code" then
            RegisterFieldSet(Rec.FieldNo("Bill-to Post Code"));

        if xRec."Bill-to County" <> Rec."Bill-to County" then
            RegisterFieldSet(Rec.FieldNo("Bill-to County"));
    end;

    local procedure CheckSellToCustomerSpecified()
    begin
        if (Rec."Sell-to Customer No." = '') and
           (Rec."Customer Id" = BlankGUID)
        then
            error(SellToCustomerNotProvidedErr);
    end;

    local procedure SetInvoiceId()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        CLEAR(SalesInvoiceId);

        if Rec."Applies-to Doc. No." = '' then
            exit;

        if SalesInvoiceHeader.GET(Rec."Applies-to Doc. No.") then
            SalesInvoiceId := SalesInvoiceAggregator.GetSalesInvoiceHeaderId(SalesInvoiceHeader);
    end;

    local procedure SetPemissionsFilters()
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        FilterText: Text;
    begin
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::"Credit Memo");
        if not SalesHeader.READPERMISSION() then
            FilterText := STRSUBSTNO(PermissionFilterFormatTxt, Rec.Status::Draft, Rec.Status::"In Review");

        if not SalesCrMemoHeader.READPERMISSION() then begin
            if FilterText <> '' then
                FilterText += '&';
            FilterText +=
              STRSUBSTNO(
                PermissionCrMemoFilterformatTxt, Rec.Status::Canceled, Rec.Status::Corrective,
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
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
    begin
        if not DiscountAmountSet then begin
            GraphMgtSalCrMemoBuf.RedistributeCreditMemoDiscounts(Rec);
            exit;
        end;

        SalesHeader.GET(SalesHeader."Document Type"::"Credit Memo", Rec."No.");
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, SalesHeader);
    end;

    local procedure SetDates()
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

        GraphMgtSalCrMemoBuf.PropagateOnModify(Rec, TempFieldBuffer);
        Rec.FIND();
    end;

    local procedure GetPostedCreditMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        if not Rec.Posted then
            Error(PostedCreditMemoActionErr);

        if not GraphMgtSalCrMemoBuf.GetSalesCrMemoHeaderFromId(Rec.Id, SalesCrMemoHeader) then
            Error(CannotFindCreditMemoErr);
    end;

    local procedure GetDraftCreditMemo(var SalesHeader: Record "Sales Header")
    begin
        if Rec.Posted then
            Error(DraftCreditMemoActionErr);

        if not SalesHeader.GetBySystemId(Rec.Id) then
            Error(CannotFindCreditMemoErr);
    end;

    local procedure CheckCreditMemoCanBeCancelled(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        CancelPostedSalesCrMemo: Codeunit "Cancel Posted Sales Cr. Memo";
    begin
        if IsCreditMemoCancelled() then
            Error(AlreadyCancelledErr);
        CancelPostedSalesCrMemo.TestCorrectCrMemoIsAllowed(SalesCrMemoHeader);
    end;

    local procedure IsCreditMemoCancelled(): Boolean
    begin
        exit(Rec.Status = Rec.Status::Canceled);
    end;

    local procedure PostCreditMemo(var SalesHeader: Record "Sales Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
        PreAssignedNo: Code[20];
    begin
        if not SalesHeader.SalesLinesExist() then
            error(NoLineErr);
        LinesInstructionMgt.SalesCheckAllLinesHaveQuantityAssigned(SalesHeader);
        PreAssignedNo := SalesHeader."No.";
        SalesHeader.SendToPosting(CODEUNIT::"Sales-Post");
        SalesCrMemoHeader.SETCURRENTKEY("Pre-Assigned No.");
        SalesCrMemoHeader.SETRANGE("Pre-Assigned No.", PreAssignedNo);
        SalesCrMemoHeader.FINDFIRST();
    end;

    local procedure CancelCreditMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
    begin
        GetPostedCreditMemo(SalesCrMemoHeader);
        CheckCreditMemoCanBeCancelled(SalesCrMemoHeader);
        if not CODEUNIT.Run(CODEUNIT::"Cancel Posted Sales Cr. Memo", SalesCrMemoHeader) then begin
            SalesInvoiceHeader.SetRange("Applies-to Doc. No.", SalesCrMemoHeader."No.");
            if not SalesInvoiceHeader.IsEmpty() then
                Error(CancelingCreditMemoFailedInvoiceCreatedAndPostedErr, GetLastErrorText());
            SalesHeader.SetRange("Applies-to Doc. No.", SalesCrMemoHeader."No.");
            if not SalesHeader.IsEmpty() then
                Error(CancelingCreditMemoFailedInvoiceCreatedButNotPostedErr, GetLastErrorText());
            Error(CancelingCreditMemoFailedNothingCreatedErr, GetLastErrorText());
        end;
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; InvoiceIdentifier: Guid)
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV1 - Sales Credit Memos");
        ActionContext.AddEntityKey(Rec.FieldNo(Id), InvoiceIdentifier);
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Post(var ActionContext: WebServiceActionContext)
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        GetDraftCreditMemo(SalesHeader);
        PostCreditMemo(SalesHeader, SalesCrMemoHeader);
        SetActionResponse(ActionContext, GraphMgtSalCrMemoBuf.GetSalesCrMemoHeaderId(SalesCrMemoHeader));
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure PostAndSend(var ActionContext: WebServiceActionContext)
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        APIV1SendSalesDocument: Codeunit "APIV1 - Send Sales Document";
    begin
        GetDraftCreditMemo(SalesHeader);
        PostCreditMemo(SalesHeader, SalesCrMemoHeader);
        Commit();
        APIV1SendSalesDocument.SendCreditMemo(SalesCrMemoHeader);
        SetActionResponse(ActionContext, GraphMgtSalCrMemoBuf.GetSalesCrMemoHeaderId(SalesCrMemoHeader));
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Send(var ActionContext: WebServiceActionContext)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        APIV1SendSalesDocument: Codeunit "APIV1 - Send Sales Document";
    begin
        GetPostedCreditMemo(SalesCrMemoHeader);
        APIV1SendSalesDocument.SendCreditMemo(SalesCrMemoHeader);
        SetActionResponse(ActionContext, GraphMgtSalCrMemoBuf.GetSalesCrMemoHeaderId(SalesCrMemoHeader));
        exit;
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Cancel(var ActionContext: WebServiceActionContext)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        GetPostedCreditMemo(SalesCrMemoHeader);
        CancelCreditMemo(SalesCrMemoHeader);
        SetActionResponse(ActionContext, GraphMgtSalCrMemoBuf.GetSalesCrMemoHeaderId(SalesCrMemoHeader));
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure CancelAndSend(var ActionContext: WebServiceActionContext)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        APIV1SendSalesDocument: Codeunit "APIV1 - Send Sales Document";
    begin
        GetPostedCreditMemo(SalesCrMemoHeader);
        CancelCreditMemo(SalesCrMemoHeader);
        APIV1SendSalesDocument.SendCreditMemo(SalesCrMemoHeader);
        SetActionResponse(ActionContext, GraphMgtSalCrMemoBuf.GetSalesCrMemoHeaderId(SalesCrMemoHeader));
    end;
}
