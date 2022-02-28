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
                        RegisterFieldSet(FieldNo("External Document No."))
                    end;
                }
                field(creditMemoDate; "Document Date")
                {
                    Caption = 'Credit Memo Date';

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
                field(billToAddressLine1; "Bill-to Address")
                {
                    Caption = 'Bill-to Address Line 1';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Bill-to Address"));
                    end;
                }
                field(billToAddressLine2; "Bill-to Address 2")
                {
                    Caption = 'Bill-to Address Line 2';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Bill-to Address 2"));
                    end;
                }
                field(billToCity; "Bill-to City")
                {
                    Caption = 'Bill-to City';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Bill-to City"));
                    end;
                }
                field(billToCountry; "Bill-to Country/Region Code")
                {
                    Caption = 'Bill-to Country/Region Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Bill-to Country/Region Code"));
                    end;
                }
                field(billToState; "Bill-to County")
                {
                    Caption = 'Bill-to State';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Bill-to County"));
                    end;
                }
                field(billToPostCode; "Bill-to Post Code")
                {
                    Caption = 'Bill-to Post Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Bill-to Post Code"));
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
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = Field(Id), "Parent Type" = const("Sales Credit Memo");
                }
                part(salesCreditMemoLines; "APIV2 - Sales Credit Mem Lines")
                {
                    Caption = 'Lines';
                    EntityName = 'salesCreditMemoLine';
                    EntitySetName = 'salesCreditMemoLines';
                    SubPageLink = "Document Id" = Field(Id);
                }
                part(pdfDocument; "APIV2 - PDF Document")
                {
                    Caption = 'PDF Document';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'pdfDocument';
                    EntitySetName = 'pdfDocument';
                    SubPageLink = "Document Id" = Field(Id), "Document Type" = const("Sales Credit Memo");
                }
                field(discountAmount; "Invoice Discount Amount")
                {
                    Caption = 'discountAmount';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Invoice Discount Amount"));
                        DiscountAmountSet := true;
                        InvoiceDiscountAmount := "Invoice Discount Amount";
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
                            "Applies-to Doc. Type" := "Applies-to Doc. Type"::" ";
                            Clear("Applies-to Doc. No.");
                            Clear(InvoiceNo);
                            RegisterFieldSet(FieldNo("Applies-to Doc. Type"));
                            RegisterFieldSet(FieldNo("Applies-to Doc. No."));
                            exit;
                        end;

                        if not SalesInvoiceAggregator.GetSalesInvoiceHeaderFromId(SalesInvoiceId, SalesInvoiceHeader) then
                            Error(InvoiceIdDoesNotMatchAnInvoiceErr);

                        "Applies-to Doc. Type" := "Applies-to Doc. Type"::Invoice;
                        "Applies-to Doc. No." := SalesInvoiceHeader."No.";
                        InvoiceNo := "Applies-to Doc. No.";
                        RegisterFieldSet(FieldNo("Applies-to Doc. Type"));
                        RegisterFieldSet(FieldNo("Applies-to Doc. No."));
                    end;
                }
                field(invoiceNumber; "Applies-to Doc. No.")
                {
                    Caption = 'Invoice No.';

                    trigger OnValidate()
                    begin
                        if InvoiceNo <> '' then begin
                            if "Applies-to Doc. No." <> InvoiceNo then
                                Error(InvoiceValuesDontMatchErr);
                            exit;
                        end;

                        "Applies-to Doc. Type" := "Applies-to Doc. Type"::Invoice;

                        RegisterFieldSet(FieldNo("Applies-to Doc. Type"));
                        RegisterFieldSet(FieldNo("Applies-to Doc. No."));
                    end;
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

                field(customerReturnReasonId; "Reason Code Id")
                {
                    Caption = 'Customer Return Reason Id';

                    trigger OnValidate()
                    begin
                        if "Reason Code Id" = BlankGUID then
                            "Reason Code" := ''
                        else begin
                            if not ReasonCode.GetBySystemId("Reason Code Id") then
                                Error(ReasonCodeIdDoesNotMatchAReasonCodeErr);

                            "Reason Code" := ReasonCode.Code;
                        end;

                        RegisterFieldSet(FieldNo("Reason Code Id"));
                        RegisterFieldSet(FieldNo("Reason Code"));
                    end;
                }
                part(attachments; "APIV2 - Attachments")
                {
                    Caption = 'Attachments';
                    EntityName = 'attachment';
                    EntitySetName = 'attachments';
                    SubPageLink = "Document Id" = Field(Id), "Document Type" = const("Sales Credit Memo");
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
        if not Posted then
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
        if xRec.Id <> Id then
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
        CancelingCreditMemoFailedInvoiceCreatedAndPostedErr: Label 'Canceling the credit memo failed because of the following error: \\%1\\An invoice is posted.';
        CancelingCreditMemoFailedInvoiceCreatedButNotPostedErr: Label 'Canceling the credit memo failed because of the following error: \\%1\\An invoice is created but not posted.';
        CancelingCreditMemoFailedNothingCreatedErr: Label 'Canceling the credit memo failed because of the following error: \\%1.';
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
        SetInvoiceId();
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, "Currency Code");
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
        if ("Sell-to Customer No." = '') and
           ("Customer Id" = BlankGUID)
        then
            Error(SellToCustomerNotProvidedErr);
    end;

    local procedure SetInvoiceId()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        Clear(SalesInvoiceId);

        if "Applies-to Doc. No." = '' then
            exit;

        if SalesInvoiceHeader.Get("Applies-to Doc. No.") then
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
            FilterText := StrSubstNo(PermissionFilterFormatTxt, Status::Draft, Status::"In Review");

        if not SalesCrMemoHeader.ReadPermission() then begin
            if FilterText <> '' then
                FilterText += '&';
            FilterText +=
              StrSubstNo(
                PermissionCrMemoFilterformatTxt, Status::Canceled, Status::Corrective,
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
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
    begin
        if not DiscountAmountSet then begin
            GraphMgtSalCrMemoBuf.RedistributeCreditMemoDiscounts(Rec);
            exit;
        end;

        SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", "No.");
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, SalesHeader);
    end;

    local procedure SetDates()
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

        GraphMgtSalCrMemoBuf.PropagateOnModify(Rec, TempFieldBuffer);
        Find();
    end;

    local procedure GetPostedCreditMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        if not Posted then
            Error(PostedCreditMemoActionErr);

        if not GraphMgtSalCrMemoBuf.GetSalesCrMemoHeaderFromId(Id, SalesCrMemoHeader) then
            Error(CannotFindCreditMemoErr);
    end;

    local procedure GetDraftCreditMemo(var SalesHeader: Record "Sales Header")
    begin
        if Posted then
            Error(DraftCreditMemoActionErr);

        if not SalesHeader.GetBySystemId(Id) then
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
        exit(Status = Status::Canceled);
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

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; InvoiceId: Guid)
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Sales Credit Memos");
        ActionContext.AddEntityKey(FieldNo(Id), InvoiceId);
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