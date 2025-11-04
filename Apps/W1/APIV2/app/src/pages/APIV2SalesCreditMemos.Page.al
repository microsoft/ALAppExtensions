namespace Microsoft.API.V2;

using Microsoft.Integration.Entity;
using Microsoft.Sales.History;
using Microsoft.Sales.Customer;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.Integration.Graph;
using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;
using Microsoft.Utilities;
using System.Reflection;

page 30038 "APIV2 - Sales Credit Memos"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Sales Credit Memo';
    EntitySetCaption = 'Sales Credit Memos';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'salesCreditMemo';
    EntitySetName = 'salesCreditMemos';
    ODataKeyFields = Id;
    PageType = API;
    SourceTable = "Sales Cr. Memo Entity Buffer";
    Extensible = false;
    AboutText = 'Manages sales credit memo documents, exposing customer details, billing and shipping addresses, financial amounts, tax information, status, and related invoice references. Supports full lifecycle operations (GET, POST, PATCH, DELETE) for automating returns, customer refunds, and integration with external financial or ERP systems to ensure accurate accounts receivable and credit processing.';

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
                field(creditMemoDate; Rec."Document Date")
                {
                    Caption = 'Credit Memo Date';

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
                field(billToAddressLine1; Rec."Bill-to Address")
                {
                    Caption = 'Bill-to Address Line 1';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Bill-to Address"));
                    end;
                }
                field(billToAddressLine2; Rec."Bill-to Address 2")
                {
                    Caption = 'Bill-to Address Line 2';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Bill-to Address 2"));
                    end;
                }
                field(billToCity; Rec."Bill-to City")
                {
                    Caption = 'Bill-to City';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Bill-to City"));
                    end;
                }
                field(billToCountry; Rec."Bill-to Country/Region Code")
                {
                    Caption = 'Bill-to Country/Region Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Bill-to Country/Region Code"));
                    end;
                }
                field(billToState; Rec."Bill-to County")
                {
                    Caption = 'Bill-to State';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Bill-to County"));
                    end;
                }
                field(billToPostCode; Rec."Bill-to Post Code")
                {
                    Caption = 'Bill-to Post Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Bill-to Post Code"));
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
                field(pricesIncludeTax; Rec."Prices Including VAT")
                {
                    Caption = 'Prices Include Tax';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Prices Including VAT"));
                    end;
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = field(Id), "Parent Type" = const("Sales Credit Memo");
                }
                part(salesCreditMemoLines; "APIV2 - Sales Credit Mem Lines")
                {
                    Caption = 'Lines';
                    EntityName = 'salesCreditMemoLine';
                    EntitySetName = 'salesCreditMemoLines';
                    SubPageLink = "Document Id" = field(Id);
                }
                part(pdfDocument; "APIV2 - PDF Document")
                {
                    Caption = 'PDF Document';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'pdfDocument';
                    EntitySetName = 'pdfDocument';
                    SubPageLink = "Document Id" = field(Id), "Document Type" = const("Sales Credit Memo");
                }
                field(discountAmount; Rec."Invoice Discount Amount")
                {
                    Caption = 'discountAmount';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Invoice Discount Amount"));
                        DiscountAmountSet := true;
                        InvoiceDiscountAmount := Rec."Invoice Discount Amount";
                    end;
                }
                field(discountAppliedBeforeTax; Rec."Discount Applied Before Tax")
                {
                    Caption = 'Discount Applied Before Tax';
                    Editable = false;
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
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
                field(invoiceId; SalesInvoiceId)
                {
                    Caption = 'InvoiceId';

                    trigger OnValidate()
                    var
                        SalesInvoiceHeader: Record "Sales Invoice Header";
                        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
                        EmptyGuid: Guid;
                    begin
                        if SalesInvoiceId = EmptyGuid then begin
                            Rec."Applies-to Doc. Type" := Rec."Applies-to Doc. Type"::" ";
                            Clear(Rec."Applies-to Doc. No.");
                            Clear(InvoiceNo);
                            RegisterFieldSet(Rec.FieldNo("Applies-to Doc. Type"));
                            RegisterFieldSet(Rec.FieldNo("Applies-to Doc. No."));
                            exit;
                        end;

                        if not SalesInvoiceAggregator.GetSalesInvoiceHeaderFromId(SalesInvoiceId, SalesInvoiceHeader) then
                            Error(InvoiceIdDoesNotMatchAnInvoiceErr);

                        Rec."Applies-to Doc. Type" := Rec."Applies-to Doc. Type"::Invoice;
                        Rec."Applies-to Doc. No." := SalesInvoiceHeader."No.";
                        InvoiceNo := Rec."Applies-to Doc. No.";
                        RegisterFieldSet(Rec.FieldNo("Applies-to Doc. Type"));
                        RegisterFieldSet(Rec.FieldNo("Applies-to Doc. No."));
                    end;
                }
                field(invoiceNumber; Rec."Applies-to Doc. No.")
                {
                    Caption = 'Invoice No.';

                    trigger OnValidate()
                    begin
                        if InvoiceNo <> '' then begin
                            if Rec."Applies-to Doc. No." <> InvoiceNo then
                                Error(InvoiceValuesDontMatchErr);
                            exit;
                        end;

                        Rec."Applies-to Doc. Type" := Rec."Applies-to Doc. Type"::Invoice;

                        RegisterFieldSet(Rec.FieldNo("Applies-to Doc. Type"));
                        RegisterFieldSet(Rec.FieldNo("Applies-to Doc. No."));
                    end;
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

                field(customerReturnReasonId; Rec."Reason Code Id")
                {
                    Caption = 'Customer Return Reason Id';

                    trigger OnValidate()
                    begin
                        if Rec."Reason Code Id" = BlankGUID then
                            Rec."Reason Code" := ''
                        else begin
                            if not ReasonCode.GetBySystemId(Rec."Reason Code Id") then
                                Error(ReasonCodeIdDoesNotMatchAReasonCodeErr);

                            Rec."Reason Code" := ReasonCode.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Reason Code Id"));
                        RegisterFieldSet(Rec.FieldNo("Reason Code"));
                    end;
                }
                part(attachments; "APIV2 - Attachments")
                {
                    Caption = 'Attachments';
                    EntityName = 'attachment';
                    EntitySetName = 'attachments';
                    SubPageLink = "Document Id" = field(Id), "Document Type" = const("Sales Credit Memo");
                }
                part(documentAttachments; "APIV2 - Document Attachments")
                {
                    Caption = 'Document Attachments';
                    EntityName = 'documentAttachment';
                    EntitySetName = 'documentAttachments';
                    SubPageLink = "Document Id" = field(Id), "Document Type" = const("Sales Credit Memo");
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

        GraphMgtSalCrMemoBuf.PropagateOnInsert(Rec, TempFieldBuffer);
        SetDates();

        UpdateDiscount();

        SetCalculatedFields();

        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if xRec.Id <> Rec.Id then
            Error(CannotChangeIDErr);

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
        ReasonCode: Record "Reason Code";
        GraphMgtSalCrMemoBuf: Codeunit "Graph Mgt - Sal. Cr. Memo Buf.";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        LCYCurrencyCode: Code[10];
        CurrencyCodeTxt: Text;
        CannotChangeIDErr: Label 'The "id" cannot be changed.', Comment = 'id is a field name and should not be translated.';
        CouldNotFindSellToCustomerErr: Label 'The sell-to customer cannot be found.';
        CouldNotFindBillToCustomerErr: Label 'The bill-to customer cannot be found.';
        SellToCustomerNotProvidedErr: Label 'A "customerNumber" or a "customerId" must be provided.', Comment = 'customerNumber and customerId are field names and should not be translated.';
        SellToCustomerValuesDontMatchErr: Label 'The sell-to customer values do not match to a specific Customer.';
        BillToCustomerValuesDontMatchErr: Label 'The bill-to customer values do not match to a specific Customer.';
        PermissionFilterFormatTxt: Label '<>%1&<>%2', Locked = true;
        PermissionCrMemoFilterformatTxt: Label '<>%1&<>%2&<>%3&<>%4', Locked = true;
        DiscountAmountSet: Boolean;
        InvoiceDiscountAmount: Decimal;
        SalesInvoiceId: Guid;
        InvoiceNo: Code[20];
        InvoiceValuesDontMatchErr: Label 'The "invoiceId" and "invoiceNumber" do not match to a specific Invoice.', Comment = 'invoiceId and invoiceNumber are field names and should not be translated.';
        InvoiceIdDoesNotMatchAnInvoiceErr: Label 'The "invoiceId" does not match to an Invoice.', Comment = 'invoiceId is a field name and should not be translated.';
        CurrencyValuesDontMatchErr: Label 'The currency values do not match to a specific Currency.';
        CurrencyIdDoesNotMatchACurrencyErr: Label 'The "currencyId" does not match to a Currency.', Comment = 'currencyId is a field name and should not be translated.';
        CurrencyCodeDoesNotMatchACurrencyErr: Label 'The "currencyCode" does not match to a Currency.', Comment = 'currencyCode is a field name and should not be translated.';
        PaymentTermsIdDoesNotMatchAPaymentTermsErr: Label 'The "paymentTermsId" does not match to a Payment Terms.', Comment = 'paymentTermsId is a field name and should not be translated.';
        ShipmentMethodIdDoesNotMatchAShipmentMethodErr: Label 'The "shipmentMethodId" does not match to a Shipment Method.', Comment = 'shipmentMethodId is a field name and should not be translated.';
        PostedCreditMemoActionErr: Label 'The action can be applied to a posted credit memo only.';
        DraftCreditMemoActionErr: Label 'The action can be applied to a draft credit memo only.';
        CannotFindCreditMemoErr: Label 'The credit memo cannot be found.';
        CancelingCreditMemoFailedInvoiceCreatedAndPostedErr: Label 'Canceling the credit memo failed because of the following error: \\%1\\An invoice is posted.', Comment = '%1 - arbitrary text (an error message)';
        CancelingCreditMemoFailedInvoiceCreatedButNotPostedErr: Label 'Canceling the credit memo failed because of the following error: \\%1\\An invoice is created but not posted.', Comment = '%1 - arbitrary text (an error message)';
        CancelingCreditMemoFailedNothingCreatedErr: Label 'Canceling the credit memo failed because of the following error: \\%1.', Comment = '%1 - arbitrary text (an error message)';
        AlreadyCancelledErr: Label 'The credit memo cannot be cancelled because it has already been canceled.';
        NoLineErr: Label 'Please add at least one line item to the credit memo.';
        ReasonCodeIdDoesNotMatchAReasonCodeErr: Label 'The "customerReturnReasonId" does not match to a Reason Code.', Comment = 'customerReturnReasonCodeId is a field name and should not be translated.';
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
        Rec.LoadFields("Applies-to Doc. Type", "Currency Code");
        SetInvoiceId();
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, Rec."Currency Code");
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(SalesInvoiceId);
        Clear(InvoiceNo);
        Clear(InvoiceDiscountAmount);
        Clear(DiscountAmountSet);
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
        TempFieldBuffer."Table ID" := Database::"Sales Cr. Memo Entity Buffer";
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

    local procedure SetInvoiceId()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        Clear(SalesInvoiceId);

        if Rec."Applies-to Doc. No." = '' then
            exit;

        if SalesInvoiceHeader.Get(Rec."Applies-to Doc. No.") then
            SalesInvoiceId := SalesInvoiceAggregator.GetSalesInvoiceHeaderId(SalesInvoiceHeader);
    end;

    local procedure SetPemissionsFilters()
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        FilterText: Text;
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
        if not SalesHeader.ReadPermission() then
            FilterText := StrSubstNo(PermissionFilterFormatTxt, Rec.Status::Draft, Rec.Status::"In Review");

        if not SalesCrMemoHeader.ReadPermission() then begin
            if FilterText <> '' then
                FilterText += '&';
            FilterText +=
              StrSubstNo(
                PermissionCrMemoFilterformatTxt, Rec.Status::Canceled, Rec.Status::Corrective,
                Rec.Status::Open, Rec.Status::Paid);
        end;

        if FilterText <> '' then begin
            Rec.FilterGroup(2);
            Rec.SetFilter(Status, FilterText);
            Rec.FilterGroup(0);
        end;

        HasWritePermissionForDraft := SalesHeader.WritePermission();
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

        SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", Rec."No.");
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, SalesHeader);
    end;

    local procedure SetDates()
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

        GraphMgtSalCrMemoBuf.PropagateOnModify(Rec, TempFieldBuffer);
        Rec.Find();
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
            Error(NoLineErr);
        LinesInstructionMgt.SalesCheckAllLinesHaveQuantityAssigned(SalesHeader);
        PreAssignedNo := SalesHeader."No.";
        SalesHeader.SendToPosting(Codeunit::"Sales-Post");
        SalesCrMemoHeader.SETCURRENTKEY("Pre-Assigned No.");
        SalesCrMemoHeader.SetRange("Pre-Assigned No.", PreAssignedNo);
        SalesCrMemoHeader.FindFirst();
    end;

    local procedure CancelCreditMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
    begin
        GetPostedCreditMemo(SalesCrMemoHeader);
        CheckCreditMemoCanBeCancelled(SalesCrMemoHeader);
        if not Codeunit.Run(Codeunit::"Cancel Posted Sales Cr. Memo", SalesCrMemoHeader) then begin
            SalesInvoiceHeader.SetRange("Applies-to Doc. No.", SalesCrMemoHeader."No.");
            if not SalesInvoiceHeader.IsEmpty() then
                Error(CancelingCreditMemoFailedInvoiceCreatedAndPostedErr, GetLastErrorText());
            SalesHeader.SetRange("Applies-to Doc. No.", SalesCrMemoHeader."No.");
            if not SalesHeader.IsEmpty() then
                Error(CancelingCreditMemoFailedInvoiceCreatedButNotPostedErr, GetLastErrorText());
            Error(CancelingCreditMemoFailedNothingCreatedErr, GetLastErrorText());
        end;
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; ParamInvoiceId: Guid)
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Sales Credit Memos");
        ActionContext.AddEntityKey(Rec.FieldNo(Id), ParamInvoiceId);
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
        APIV2SendSalesDocument: Codeunit "APIV2 - Send Sales Document";
    begin
        GetDraftCreditMemo(SalesHeader);
        PostCreditMemo(SalesHeader, SalesCrMemoHeader);
        Commit();
        APIV2SendSalesDocument.SendCreditMemo(SalesCrMemoHeader);
        SetActionResponse(ActionContext, GraphMgtSalCrMemoBuf.GetSalesCrMemoHeaderId(SalesCrMemoHeader));
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Send(var ActionContext: WebServiceActionContext)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        APIV2SendSalesDocument: Codeunit "APIV2 - Send Sales Document";
    begin
        GetPostedCreditMemo(SalesCrMemoHeader);
        APIV2SendSalesDocument.SendCreditMemo(SalesCrMemoHeader);
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
        APIV2SendSalesDocument: Codeunit "APIV2 - Send Sales Document";
    begin
        GetPostedCreditMemo(SalesCrMemoHeader);
        CancelCreditMemo(SalesCrMemoHeader);
        APIV2SendSalesDocument.SendCreditMemo(SalesCrMemoHeader);
        SetActionResponse(ActionContext, GraphMgtSalCrMemoBuf.GetSalesCrMemoHeaderId(SalesCrMemoHeader));
    end;
}