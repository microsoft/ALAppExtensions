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
                field(documentDate; "Document Date")
                {
                    Caption = 'Document Date';

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
                field(shipToName; "Ship-to Name")
                {
                    Caption = 'Ship-To Name';

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
                    Caption = 'Ship-To Contact';

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

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Bill-To Address"));
                    end;
                }
                field(billToAddressLine2; "Bill-To Address 2")
                {
                    Caption = 'Bill-to Address Line 2';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Bill-To Address 2"));
                    end;
                }
                field(billToCity; "Bill-To City")
                {
                    Caption = 'Bill-to City';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Bill-To City"));
                    end;
                }
                field(billToCountry; "Bill-To Country/Region Code")
                {
                    Caption = 'Bill-to Country/Region Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Bill-To Country/Region Code"));
                    end;
                }
                field(billToState; "Bill-To County")
                {
                    Caption = 'Bill-to State';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Bill-To County"));
                    end;
                }
                field(billToPostCode; "Bill-To Post Code")
                {
                    Caption = 'Bill-to Post Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Bill-To Post Code"));
                    end;
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
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = Field(Id), "Parent Type" = const("Sales Quote");
                }
                part(salesQuoteLines; "APIV2 - Sales Quote Lines")
                {
                    Caption = 'Lines';
                    EntityName = 'salesQuoteLine';
                    EntitySetName = 'salesQuoteLines';
                    SubPageLink = "Document Id" = Field(Id);
                }
                part(pdfDocument; "APIV2 - PDF Document")
                {
                    Caption = 'PDF Document';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'pdfDocument';
                    EntitySetName = 'pdfDocument';
                    SubPageLink = "Document Id" = Field(Id), "Document Type" = const("Sales Quote");
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

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Status));
                    end;
                }
                field(sentDate; "Quote Sent to Customer")
                {
                    Caption = 'Sent Date';
                }
                field(validUntilDate; "Quote Valid Until Date")
                {
                    Caption = 'Valid Until Date';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Quote Valid Until Date"));
                    end;
                }
                field(acceptedDate; "Quote Accepted Date")
                {
                    Caption = 'Accepted Date';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Quote Accepted Date"));
                    end;
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
                    SubPageLink = "Document Id" = Field(Id), "Document Type" = const("Sales Quote");
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
        if xRec.Id <> Id then
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
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, "Currency Code");
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
        if ("Sell-to Customer No." = '') and
           ("Customer Id" = BlankGUID)
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

        SalesHeader.Get(SalesHeader."Document Type"::Quote, "No.");
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

        GraphMgtSalesQuoteBuffer.PropagateOnModify(Rec, TempFieldBuffer);
        Find();
    end;

    local procedure GetQuote(var SalesHeader: Record "Sales Header")
    begin
        if not SalesHeader.GetBySystemId(Id) then
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
        ActionContext.AddEntityKey(FieldNo(Id), SalesHeader.SystemId);
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
