page 30012 "APIV2 - Sales Invoices"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Sales Invoice';
    EntitySetCaption = 'Sales Invoices';
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
                field(id; Id)
                {
                    Caption = 'Id';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Id));
                    end;
                }
                field(number; "No.")
                {
                    Caption = 'No.';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("No."));
                    end;
                }
                field(externalDocumentNumber; "External Document No.")
                {
                    Caption = 'External Document No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("External Document No."));
                    end;
                }
                field(invoiceDate; "Document Date")
                {
                    Caption = 'Invoice Date';

                    trigger OnValidate()
                    begin
                        DocumentDateVar := "Document Date";
                        DocumentDateSet := true;

                        RegisterFieldSet(FieldNo("Document Date"));
                    end;
                }
                field(postingDate; "Posting Date")
                {
                    Caption = 'Posting Date';

                    trigger OnValidate()
                    begin
                        PostingDateVar := "Posting Date";
                        PostingDateSet := true;

                        RegisterFieldSet(FieldNo("Posting Date"));
                    end;
                }
                field(dueDate; "Due Date")
                {
                    Caption = 'Due Date';

                    trigger OnValidate()
                    begin
                        DueDateVar := "Due Date";
                        DueDateSet := true;

                        RegisterFieldSet(FieldNo("Due Date"));
                    end;
                }
                field(customerPurchaseOrderReference; "Your Reference")
                {
                    Caption = 'Customer Purchase Order Reference',;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Your Reference"));
                    end;
                }
                field(customerId; "Customer Id")
                {
                    Caption = 'Customer Id';

                    trigger OnValidate()
                    var
                        O365SalesInvoiceMgmt: Codeunit "O365 Sales Invoice Mgmt";
                    begin
                        if not SellToCustomer.GetBySystemId("Customer Id") then
                            Error(CouldNotFindSellToCustomerErr);

                        O365SalesInvoiceMgmt.EnforceCustomerTemplateIntegrity(SellToCustomer);

                        "Sell-to Customer No." := SellToCustomer."No.";
                        RegisterFieldSet(FieldNo("Customer Id"));
                        RegisterFieldSet(FieldNo("Sell-to Customer No."));
                    end;
                }

                field(customerNumber; "Sell-to Customer No.")
                {
                    Caption = 'Customer No.';

                    trigger OnValidate()
                    var
                        O365SalesInvoiceMgmt: Codeunit "O365 Sales Invoice Mgmt";
                    begin
                        if SellToCustomer."No." <> '' then begin
                            if SellToCustomer."No." <> "Sell-to Customer No." then
                                Error(SellToCustomerValuesDontMatchErr);
                            exit;
                        end;

                        if not SellToCustomer.Get("Sell-to Customer No.") then
                            Error(CouldNotFindSellToCustomerErr);

                        O365SalesInvoiceMgmt.EnforceCustomerTemplateIntegrity(SellToCustomer);

                        "Customer Id" := SellToCustomer.SystemId;
                        RegisterFieldSet(FieldNo("Customer Id"));
                        RegisterFieldSet(FieldNo("Sell-to Customer No."));
                    end;
                }
                field(customerName; "Sell-to Customer Name")
                {
                    Caption = 'Customer Name';
                    Editable = false;
                }
                field(billToName; "Bill-to Name")
                {
                    Caption = 'Bill-To Name';
                    Editable = false;
                }
                field(billToCustomerId; "Bill-to Customer Id")
                {
                    Caption = 'Bill-To Customer Id';

                    trigger OnValidate()
                    var
                        O365SalesInvoiceMgmt: Codeunit "O365 Sales Invoice Mgmt";
                    begin
                        if not BillToCustomer.GetBySystemId("Bill-to Customer Id") then
                            Error(CouldNotFindBillToCustomerErr);

                        O365SalesInvoiceMgmt.EnforceCustomerTemplateIntegrity(BillToCustomer);

                        "Bill-to Customer No." := BillToCustomer."No.";
                        RegisterFieldSet(FieldNo("Bill-to Customer Id"));
                        RegisterFieldSet(FieldNo("Bill-to Customer No."));
                    end;
                }
                field(billToCustomerNumber; "Bill-to Customer No.")
                {
                    Caption = 'Bill-To Customer No.';

                    trigger OnValidate()
                    var
                        O365SalesInvoiceMgmt: Codeunit "O365 Sales Invoice Mgmt";
                    begin
                        if BillToCustomer."No." <> '' then begin
                            if BillToCustomer."No." <> "Bill-to Customer No." then
                                Error(BillToCustomerValuesDontMatchErr);
                            exit;
                        end;

                        if not BillToCustomer.Get("Bill-to Customer No.") then
                            Error(CouldNotFindBillToCustomerErr);

                        O365SalesInvoiceMgmt.EnforceCustomerTemplateIntegrity(BillToCustomer);

                        "Bill-to Customer Id" := BillToCustomer.SystemId;
                        RegisterFieldSet(FieldNo("Bill-to Customer Id"));
                        RegisterFieldSet(FieldNo("Bill-to Customer No."));
                    end;
                }
                field(shipToName; "Ship-to Name")
                {
                    Caption = 'Ship-to Name';

                    trigger OnValidate()
                    begin
                        if xRec."Ship-to Name" <> "Ship-to Name" then begin
                            "Ship-to Code" := '';
                            RegisterFieldSet(FieldNo("Ship-to Code"));
                            RegisterFieldSet(FieldNo("Ship-to Name"));
                        end;
                    end;
                }
                field(shipToContact; "Ship-to Contact")
                {
                    Caption = 'Ship-to Contact';

                    trigger OnValidate()
                    begin
                        if xRec."Ship-to Contact" <> "Ship-to Contact" then begin
                            "Ship-to Code" := '';
                            RegisterFieldSet(FieldNo("Ship-to Code"));
                            RegisterFieldSet(FieldNo("Ship-to Contact"));
                        end;
                    end;
                }
                field(sellToAddressLine1; "Sell-to Address")
                {
                    Caption = 'Sell-to Address Line 1';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Sell-to Address"));
                    end;
                }
                field(sellToAddressLine2; "Sell-to Address 2")
                {
                    Caption = 'Sell-to Address Line 2';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Sell-to Address 2"));
                    end;
                }
                field(sellToCity; "Sell-to City")
                {
                    Caption = 'Sell-to City';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Sell-to City"));
                    end;
                }
                field(sellToCountry; "Sell-to Country/Region Code")
                {
                    Caption = 'Sell-to Country/Region Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Sell-to Country/Region Code"));
                    end;
                }
                field(sellToState; "Sell-to County")
                {
                    Caption = 'Sell-to State';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Sell-to County"));
                    end;
                }
                field(sellToPostCode; "Sell-to Post Code")
                {
                    Caption = 'Sell-to Post Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Sell-to Post Code"));
                    end;
                }
                field(billToAddressLine1; "Bill-To Address")
                {
                    Caption = 'Bill-to Address Line 1';
                    Editable = false;
                }
                field(billToAddressLine2; "Bill-To Address 2")
                {
                    Caption = 'Bill-to Address Line 2';
                    Editable = false;
                }
                field(billToCity; "Bill-To City")
                {
                    Caption = 'Bill-to City';
                    Editable = false;
                }
                field(billToCountry; "Bill-To Country/Region Code")
                {
                    Caption = 'Bill-to Country/Region Code';
                    Editable = false;
                }
                field(billToState; "Bill-To County")
                {
                    Caption = 'Bill-to State';
                    Editable = false;
                }
                field(billToPostCode; "Bill-To Post Code")
                {
                    Caption = 'Bill-to Post Code';
                    Editable = false;
                }
                field(shipToAddressLine1; "Ship-to Address")
                {
                    Caption = 'Ship-to Address Line 1';

                    trigger OnValidate()
                    begin
                        "Ship-to Code" := '';
                        RegisterFieldSet(FieldNo("Ship-to Code"));
                        RegisterFieldSet(FieldNo("Ship-to Address"));
                    end;
                }
                field(shipToAddressLine2; "Ship-to Address 2")
                {
                    Caption = 'Ship-to Address Line 2';

                    trigger OnValidate()
                    begin
                        "Ship-to Code" := '';
                        RegisterFieldSet(FieldNo("Ship-to Code"));
                        RegisterFieldSet(FieldNo("Ship-to Address 2"));
                    end;
                }
                field(shipToCity; "Ship-to City")
                {
                    Caption = 'Ship-to City';

                    trigger OnValidate()
                    begin
                        "Ship-to Code" := '';
                        RegisterFieldSet(FieldNo("Ship-to Code"));
                        RegisterFieldSet(FieldNo("Ship-to City"));
                    end;
                }
                field(shipToCountry; "Ship-to Country/Region Code")
                {
                    Caption = 'Ship-to Country/Region Code';

                    trigger OnValidate()
                    begin
                        "Ship-to Code" := '';
                        RegisterFieldSet(FieldNo("Ship-to Code"));
                        RegisterFieldSet(FieldNo("Ship-to Country/Region Code"));
                    end;
                }
                field(shipToState; "Ship-to County")
                {
                    Caption = 'Ship-to State';

                    trigger OnValidate()
                    begin
                        "Ship-to Code" := '';
                        RegisterFieldSet(FieldNo("Ship-to Code"));
                        RegisterFieldSet(FieldNo("Ship-to County"));
                    end;
                }
                field(shipToPostCode; "Ship-to Post Code")
                {
                    Caption = 'Ship-to Post Code';

                    trigger OnValidate()
                    begin
                        "Ship-to Code" := '';
                        RegisterFieldSet(FieldNo("Ship-to Code"));
                        RegisterFieldSet(FieldNo("Ship-to Post Code"));
                    end;
                }
                field(currencyId; "Currency Id")
                {
                    Caption = 'Currency Id';

                    trigger OnValidate()
                    begin
                        if "Currency Id" = BlankGUID then
                            "Currency Code" := ''
                        else begin
                            if not Currency.GetBySystemId("Currency Id") then
                                Error(CurrencyIdDoesNotMatchACurrencyErr);

                            "Currency Code" := Currency.Code;
                        end;

                        RegisterFieldSet(FieldNo("Currency Id"));
                        RegisterFieldSet(FieldNo("Currency Code"));
                    end;
                }
                field(shortcutDimension1Code; "Shortcut Dimension 1 Code")
                {
                    Caption = 'Shortcut Dimension 1 Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Shortcut Dimension 1 Code"));
                    end;
                }
                field(shortcutDimension2Code; "Shortcut Dimension 2 Code")
                {
                    Caption = 'Shortcut Dimension 2 Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Shortcut Dimension 2 Code"));
                    end;
                }
                field(currencyCode; CurrencyCodeTxt)
                {
                    Caption = 'Currency Code';

                    trigger OnValidate()
                    begin
                        "Currency Code" :=
                          GraphMgtGeneralTools.TranslateCurrencyCodeToNAVCurrencyCode(
                            LCYCurrencyCode, COPYSTR(CurrencyCodeTxt, 1, MAXSTRLEN(LCYCurrencyCode)));

                        if Currency.Code <> '' then begin
                            if Currency.Code <> "Currency Code" then
                                Error(CurrencyValuesDontMatchErr);
                            exit;
                        end;

                        if "Currency Code" = '' then
                            "Currency Id" := BlankGUID
                        else begin
                            if not Currency.Get("Currency Code") then
                                Error(CurrencyCodeDoesNotMatchACurrencyErr);

                            "Currency Id" := Currency.SystemId;
                        end;

                        RegisterFieldSet(FieldNo("Currency Id"));
                        RegisterFieldSet(FieldNo("Currency Code"));
                    end;
                }
                field(orderId; "Order Id")
                {
                    Caption = 'Order Id';
                    Editable = false;
                }
                field(orderNumber; "Order No.")
                {
                    Caption = 'Order No.';
                    Editable = false;
                }
                field(paymentTermsId; "Payment Terms Id")
                {
                    Caption = 'Payment Terms Id';

                    trigger OnValidate()
                    begin
                        if "Payment Terms Id" = BlankGUID then
                            "Payment Terms Code" := ''
                        else begin
                            if not PaymentTerms.GetBySystemId("Payment Terms Id") then
                                Error(PaymentTermsIdDoesNotMatchAPaymentTermsErr);

                            "Payment Terms Code" := PaymentTerms.Code;
                        end;

                        RegisterFieldSet(FieldNo("Payment Terms Id"));
                        RegisterFieldSet(FieldNo("Payment Terms Code"));
                    end;
                }
                field(shipmentMethodId; "Shipment Method Id")
                {
                    Caption = 'Shipment Method Id';

                    trigger OnValidate()
                    begin
                        if "Shipment Method Id" = BlankGUID then
                            "Shipment Method Code" := ''
                        else begin
                            if not ShipmentMethod.GetBySystemId("Shipment Method Id") then
                                Error(ShipmentMethodIdDoesNotMatchAShipmentMethodErr);

                            "Shipment Method Code" := ShipmentMethod.Code;
                        end;

                        RegisterFieldSet(FieldNo("Shipment Method Id"));
                        RegisterFieldSet(FieldNo("Shipment Method Code"));
                    end;
                }
                field(salesperson; "Salesperson Code")
                {
                    Caption = 'Salesperson';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Salesperson Code"));
                    end;
                }
                field(pricesIncludeTax; "Prices Including VAT")
                {
                    Caption = 'Prices Include Tax';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Prices Including VAT"));
                    end;
                }

                field(remainingAmount; RemainingAmountVar)
                {
                    Caption = 'Remaining Amount';
                    Editable = false;
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = Field(Id), "Parent Type" = const("Sales Invoice");
                }
                part(salesInvoiceLines; "APIV2 - Sales Invoice Lines")
                {
                    Caption = 'Lines';
                    EntityName = 'salesInvoiceLine';
                    EntitySetName = 'salesInvoiceLines';
                    SubPageLink = "Document Id" = Field(Id);
                }
                part(pdfDocument; "APIV2 - PDF Document")
                {
                    Caption = 'PDF Document';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'pdfDocument';
                    EntitySetName = 'pdfDocument';
                    SubPageLink = "Document Id" = Field(Id), "Document Type" = const("Sales Invoice");
                }
                field(discountAmount; "Invoice Discount Amount")
                {
                    Caption = 'Discount Amount';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Invoice Discount Amount"));
                        InvoiceDiscountAmount := "Invoice Discount Amount";
                        DiscountAmountSet := true;
                    end;
                }
                field(discountAppliedBeforeTax; "Discount Applied Before Tax")
                {
                    Caption = 'Discount Applied Before Tax';
                    Editable = false;
                }
                field(totalAmountExcludingTax; Amount)
                {
                    Caption = 'Total Amount Excluding Tax';
                    Editable = false;
                }
                field(totalTaxAmount; "Total Tax Amount")
                {
                    Caption = 'Total Tax Amount';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Total Tax Amount"));
                    end;
                }
                field(totalAmountIncludingTax; "Amount Including VAT")
                {
                    Caption = 'Total Amount Including Tax';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Amount Including VAT"));
                    end;
                }
                field(status; Status)
                {
                    Caption = 'Status';
                    Editable = false;
                }
                field(lastModifiedDateTime; SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
                field(phoneNumber; "Sell-to Phone No.")
                {
                    Caption = 'Phone No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Sell-to Phone No."));
                    end;
                }
                field(email; "Sell-to E-Mail")
                {
                    Caption = 'Email';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Sell-to E-Mail"));
                    end;
                }
                part(attachments; "APIV2 - Attachments")
                {
                    Caption = 'Attachments';
                    EntityName = 'attachment';
                    EntitySetName = 'attachments';
                    SubPageLink = "Document Id" = Field(Id), "Document Type" = const("Sales Invoice");
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
        if not Posted then
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
        if xRec.Id <> Id then
            Error(CannotChangeIDErr);

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
        CannotChangeIDErr: Label 'The id cannot be changed.';
        LCYCurrencyCode: Code[10];
        CurrencyCodeTxt: Text;
        SellToCustomerNotProvidedErr: Label 'A "customerNumber" or a "customerId" must be provided.', Comment = 'customerNumber and customerId are field names and should not be translated.';
        SellToCustomerValuesDontMatchErr: Label 'The sell-to customer values do not match to a specific Customer.';
        BillToCustomerValuesDontMatchErr: Label 'The bill-to customer values do not match to a specific Customer.';
        CouldNotFindSellToCustomerErr: Label 'The sell-to customer cannot be found.';
        CouldNotFindBillToCustomerErr: Label 'The bill-to customer cannot be found.';
        CurrencyValuesDontMatchErr: Label 'The currency values do not match to a specific Currency.';
        CurrencyIdDoesNotMatchACurrencyErr: Label 'The "currencyId" does not match to a Currency.', Comment = 'currencyId is a field name and should not be translated.';
        CurrencyCodeDoesNotMatchACurrencyErr: Label 'The "currencyCode" does not match to a Currency.', Comment = 'currencyCode is a field name and should not be translated.';
        BlankGUID: Guid;
        PaymentTermsIdDoesNotMatchAPaymentTermsErr: Label 'The "paymentTermsId" does not match to a Payment Terms.', Comment = 'paymentTermsId is a field name and should not be translated.';
        ShipmentMethodIdDoesNotMatchAShipmentMethodErr: Label 'The "shipmentMethodId" does not match to a Shipment Method.', Comment = 'shipmentMethodId is a field name and should not be translated.';
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
        PostedInvoiceActionErr: Label 'The action can be applied to a posted invoice only.';
        DraftInvoiceActionErr: Label 'The action can be applied to a draft invoice only.';
        CannotFindInvoiceErr: Label 'The invoice cannot be found.';
        CancelingInvoiceFailedCreditMemoCreatedAndPostedErr: Label 'Canceling the invoice failed because of the following error: \\%1\\A credit memo is posted.';
        CancelingInvoiceFailedCreditMemoCreatedButNotPostedErr: Label 'Canceling the invoice failed because of the following error: \\%1\\A credit memo is created but not posted.';
        CancelingInvoiceFailedNothingCreatedErr: Label 'Canceling the invoice failed because of the following error: \\%1.';
        EmptyEmailErr: Label 'The send-to email is empty. Specify email either for the customer or for the invoice in email preview.';
        AlreadyCanceledErr: Label 'The invoice cannot be canceled because it has already been canceled.';
        InvoiceClosedErr: Label 'The invoice is closed. The corrective credit memo will not be applied to the invoice.';
        InvoicePartiallyPaidErr: Label 'The invoice is partially paid or credited. The corrective credit memo may not be fully closed by the invoice.';
        HasWritePermissionForDraft: Boolean;

    local procedure SetCalculatedFields()
    begin
        GetRemainingAmount();
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, "Currency Code");
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(InvoiceDiscountAmount);
        Clear(DiscountAmountSet);
        Clear(RemainingAmountVar);
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
        TempFieldBuffer."Table ID" := Database::"Sales Invoice Entity Aggregate";
        TempFieldBuffer."Field ID" := FieldNo;
        TempFieldBuffer.Insert();
    end;

    local procedure GetRemainingAmount();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        RemainingAmountVar := "Amount Including VAT";
        if Posted then
            if (Status = Status::Canceled) then begin
                RemainingAmountVar := 0;
                exit;
            end else
                if SalesInvoiceHeader.Get("No.") then
                    RemainingAmountVar := SalesInvoiceHeader.GetRemainingAmount();
    end;

    local procedure CheckSellToCustomerSpecified()
    begin
        if ("Sell-to Customer No." = '') and
           ("Customer Id" = BlankGUID)
        then
            Error(SellToCustomerNotProvidedErr);
    end;

    local procedure SetPermissionFilters()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        FilterText: Text;
    begin
        // Filtering out test documents
        SalesHeader.SetRange(IsTest, false);

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        if not SalesHeader.ReadPermission() then
            FilterText :=
              StrSubstNo(PermissionFilterFormatTxt, Status::Draft, Status::"In Review");

        if not SalesInvoiceHeader.ReadPermission() then begin
            if FilterText <> '' then
                FilterText += '&';
            FilterText +=
              StrSubstNo(
                PermissionInvoiceFilterformatTxt, Status::Canceled, Status::Corrective,
                Status::Open, Status::Paid);
        end;

        if FilterText <> '' then begin
            FilterGroup(2);
            SetFilter(Status, FilterText);
            FilterGroup(0);
        end;

        HasWritePermissionForDraft := SalesHeader.WritePermission();
    end;

    local procedure UpdateDiscount()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
    begin
        if Posted then
            exit;

        if not DiscountAmountSet then begin
            SalesInvoiceAggregator.RedistributeInvoiceDiscounts(Rec);
            exit;
        end;

        SalesHeader.Get("Document Type"::Invoice, "No.");
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, SalesHeader);
    end;

    local procedure SetDates()
    var
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        if not (DueDateSet or DocumentDateSet or PostingDateSet) then
            exit;

        TempFieldBuffer.Reset();
        TempFieldBuffer.DeleteAll();

        if DocumentDateSet then begin
            "Document Date" := DocumentDateVar;
            RegisterFieldSet(FieldNo("Document Date"));
        end;

        if PostingDateSet then begin
            "Posting Date" := PostingDateVar;
            RegisterFieldSet(FieldNo("Posting Date"));
        end;

        if DueDateSet then begin
            "Due Date" := DueDateVar;
            RegisterFieldSet(FieldNo("Due Date"));
        end;

        SalesInvoiceAggregator.PropagateOnModify(Rec, TempFieldBuffer);
        Find();
    end;

    local procedure GetPostedInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        if not Posted then
            Error(PostedInvoiceActionErr);

        if not SalesInvoiceAggregator.GetSalesInvoiceHeaderFromId(Id, SalesInvoiceHeader) then
            Error(CannotFindInvoiceErr);
    end;

    local procedure GetDraftInvoice(var SalesHeader: Record "Sales Header")
    begin
        if Posted then
            Error(DraftInvoiceActionErr);

        SalesHeader.SetRange(SystemId, Id);
        if not SalesHeader.FindFirst() then
            Error(CannotFindInvoiceErr);

        SalesHeader.SetRange(SystemId);
    end;

    local procedure CheckSendToEmailAddress(DocumentNo: Code[20])
    begin
        if GetSendToEmailAddress(DocumentNo) = '' then
            Error(EmptyEmailErr);
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
        if not Customer.Get("Sell-to Customer No.") then
            exit('');
        exit(Customer."E-Mail");
    end;

    local procedure GetDocumentEmailAddress(DocumentNo: Code[20]): Text[250]
    var
        EmailParameter: Record "Email Parameter";
    begin
        if not EmailParameter.Get(DocumentNo, "Document Type", EmailParameter."Parameter Type"::Address) then
            exit('');
        exit(EmailParameter."Parameter Value");
    end;

    local procedure CheckInvoiceCanBeCanceled(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
    begin
        if IsInvoiceCanceled() then
            Error(AlreadyCanceledErr);
        CorrectPostedSalesInvoice.TestCorrectInvoiceIsAllowed(SalesInvoiceHeader, true);
    end;

    local procedure IsInvoiceCanceled(): Boolean
    begin
        exit(Status = Status::Canceled);
    end;

    local procedure PostInvoice(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        DummyO365SalesDocument: Record "O365 Sales Document";
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
        O365SendResendInvoice: Codeunit "O365 Send + Resend Invoice";
        PreAssignedNo: Code[20];
    begin
        O365SendResendInvoice.CheckDocumentIfNoItemsExists(SalesHeader, false, DummyO365SalesDocument);
        LinesInstructionMgt.SalesCheckAllLinesHaveQuantityAssigned(SalesHeader);
        PreAssignedNo := SalesHeader."No.";
        SalesHeader.SendToPosting(Codeunit::"Sales-Post");
        SalesInvoiceHeader.SETCURRENTKEY("Pre-Assigned No.");
        SalesInvoiceHeader.SetRange("Pre-Assigned No.", PreAssignedNo);
        SalesInvoiceHeader.FindFirst();
    end;

    local procedure SendPostedInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        O365SetupEmail.CheckMailSetup();
        CheckSendToEmailAddress(SalesInvoiceHeader."No.");

        SalesInvoiceHeader.SETRECFILTER();
        SalesInvoiceHeader.EmailRecords(false);
    end;

    local procedure SendDraftInvoice(var SalesHeader: Record "Sales Header")
    var
        DummyO365SalesDocument: Record "O365 Sales Document";
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
        O365SendResendInvoice: Codeunit "O365 Send + Resend Invoice";
    begin
        O365SendResendInvoice.CheckDocumentIfNoItemsExists(SalesHeader, false, DummyO365SalesDocument);
        LinesInstructionMgt.SalesCheckAllLinesHaveQuantityAssigned(SalesHeader);
        O365SetupEmail.CheckMailSetup();
        CheckSendToEmailAddress(SalesHeader."No.");

        SalesHeader.SETRECFILTER();
        SalesHeader.EmailRecords(false);
    end;

    local procedure SendCanceledInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        O365SetupEmail.CheckMailSetup();
        CheckSendToEmailAddress(SalesInvoiceHeader."No.");

        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"O365 Sales Cancel Invoice";
        JobQueueEntry."Maximum No. of Attempts to Run" := 3;
        JobQueueEntry."Record ID to Process" := SalesInvoiceHeader.RecordId();
        Codeunit.RUN(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
    end;

    local procedure CancelInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
    begin
        GetPostedInvoice(SalesInvoiceHeader);
        CheckInvoiceCanBeCanceled(SalesInvoiceHeader);
        if not Codeunit.RUN(Codeunit::"Correct Posted Sales Invoice", SalesInvoiceHeader) then begin
            SalesCrMemoHeader.SetRange("Applies-to Doc. No.", SalesInvoiceHeader."No.");
            if Not SalesCrMemoHeader.IsEmpty() then
                Error(CancelingInvoiceFailedCreditMemoCreatedAndPostedErr, GETLASTERRORTEXT());
            SalesHeader.SetRange("Applies-to Doc. No.", SalesInvoiceHeader."No.");
            if Not SalesHeader.IsEmpty() then
                Error(CancelingInvoiceFailedCreditMemoCreatedButNotPostedErr, GETLASTERRORTEXT());
            Error(CancelingInvoiceFailedNothingCreatedErr, GETLASTERRORTEXT());
        end;
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; InvoiceId: Guid)
    var
    begin
        SetActionResponse(ActionContext, Page::"APIV2 - Sales Invoices", InvoiceId);
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; PageId: Integer; DocumentId: Guid)
    var
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(PageId);
        ActionContext.AddEntityKey(FieldNo(Id), DocumentId);
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
        Commit();
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
        if Posted then begin
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
        SalesInvoiceHeader.SETRECFILTER();
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
        SetActionResponse(ActionContext, Page::"APIV2 - Sales Credit Memos", SalesHeader.SystemId);
    end;
}