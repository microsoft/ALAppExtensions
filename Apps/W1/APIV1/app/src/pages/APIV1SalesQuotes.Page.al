page 20037 "APIV1 - Sales Quotes"
{
    APIVersion = 'v1.0';
    Caption = 'salesQuotes', Locked = true;
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
                    Caption = 'id', Locked = true;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Id));
                    end;
                }
                field(number; "No.")
                {
                    Caption = 'number', Locked = true;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("No."));
                    end;
                }
                field(externalDocumentNumber; "External Document No.")
                {
                    Caption = 'externalDocumentNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("External Document No."))
                    end;
                }
                field(documentDate; "Document Date")
                {
                    Caption = 'documentDate', Locked = true;

                    trigger OnValidate()
                    begin
                        DocumentDateVar := "Document Date";
                        DocumentDateSet := TRUE;

                        RegisterFieldSet(FIELDNO("Document Date"));
                    end;
                }
                field(postingDate; "Posting Date")
                {
                    Caption = 'postingDate', Locked = true;

                    trigger OnValidate()
                    begin
                        PostingDateVar := "Posting Date";
                        PostingDateSet := TRUE;

                        RegisterFieldSet(FIELDNO("Posting Date"));
                    end;
                }
                field(dueDate; "Due Date")
                {
                    Caption = 'dueDate', Locked = true;

                    trigger OnValidate()
                    begin
                        DueDateVar := "Due Date";
                        DueDateSet := TRUE;

                        RegisterFieldSet(FIELDNO("Due Date"));
                    end;
                }
                field(customerId; "Customer Id")
                {
                    Caption = 'customerId', Locked = true;

                    trigger OnValidate()
                    var
                        O365SalesInvoiceMgmt: Codeunit "O365 Sales Invoice Mgmt";
                    begin
                        IF NOT SellToCustomer.GetBySystemId("Customer Id") THEN
                            ERROR(CouldNotFindSellToCustomerErr);

                        O365SalesInvoiceMgmt.EnforceCustomerTemplateIntegrity(SellToCustomer);

                        "Sell-to Customer No." := SellToCustomer."No.";
                        RegisterFieldSet(FIELDNO("Customer Id"));
                        RegisterFieldSet(FIELDNO("Sell-to Customer No."));
                    end;
                }
                field(contactId; "Contact Graph Id")
                {
                    Caption = 'contactId', Locked = true;
                }
                field(customerNumber; "Sell-to Customer No.")
                {
                    Caption = 'customerNumber', Locked = true;

                    trigger OnValidate()
                    var
                        O365SalesInvoiceMgmt: Codeunit "O365 Sales Invoice Mgmt";
                    begin
                        IF SellToCustomer."No." <> '' THEN BEGIN
                            IF SellToCustomer."No." <> "Sell-to Customer No." THEN
                                ERROR(SellToCustomerValuesDontMatchErr);
                            EXIT;
                        END;

                        IF NOT SellToCustomer.GET("Sell-to Customer No.") THEN
                            ERROR(CouldNotFindSellToCustomerErr);

                        O365SalesInvoiceMgmt.EnforceCustomerTemplateIntegrity(SellToCustomer);

                        "Customer Id" := SellToCustomer.SystemId;
                        RegisterFieldSet(FIELDNO("Customer Id"));
                        RegisterFieldSet(FIELDNO("Sell-to Customer No."));
                    end;
                }
                field(customerName; "Sell-to Customer Name")
                {
                    Caption = 'customerName', Locked = true;
                    Editable = false;
                }
                field(billToName; "Bill-to Name")
                {
                    Caption = 'billToName', Locked = true;
                    Editable = false;
                }
                field(billToCustomerId; "Bill-to Customer Id")
                {
                    Caption = 'billToCustomerId', Locked = true;

                    trigger OnValidate()
                    var
                        O365SalesInvoiceMgmt: Codeunit "O365 Sales Invoice Mgmt";
                    begin
                        IF NOT BillToCustomer.GetBySystemId("Bill-to Customer Id") THEN
                            ERROR(CouldNotFindBillToCustomerErr);

                        O365SalesInvoiceMgmt.EnforceCustomerTemplateIntegrity(BillToCustomer);

                        "Bill-to Customer No." := BillToCustomer."No.";
                        RegisterFieldSet(FIELDNO("Bill-to Customer Id"));
                        RegisterFieldSet(FIELDNO("Bill-to Customer No."));
                    end;
                }
                field(billToCustomerNumber; "Bill-to Customer No.")
                {
                    Caption = 'billToCustomerNumber', Locked = true;

                    trigger OnValidate()
                    var
                        O365SalesInvoiceMgmt: Codeunit "O365 Sales Invoice Mgmt";
                    begin
                        IF BillToCustomer."No." <> '' THEN BEGIN
                            IF BillToCustomer."No." <> "Bill-to Customer No." THEN
                                ERROR(BillToCustomerValuesDontMatchErr);
                            EXIT;
                        END;

                        IF NOT BillToCustomer.GET("Bill-to Customer No.") THEN
                            ERROR(CouldNotFindBillToCustomerErr);

                        O365SalesInvoiceMgmt.EnforceCustomerTemplateIntegrity(BillToCustomer);

                        "Bill-to Customer Id" := BillToCustomer.SystemId;
                        RegisterFieldSet(FIELDNO("Bill-to Customer Id"));
                        RegisterFieldSet(FIELDNO("Bill-to Customer No."));
                    end;
                }
                field(shipToName; "Ship-to Name")
                {
                    Caption = 'shipToName', Locked = true;

                    trigger OnValidate()
                    begin
                        if xRec."Ship-to Name" <> "Ship-to Name" then begin
                            "Ship-to Code" := '';
                            RegisterFieldSet(FIELDNO("Ship-to Code"));
                            RegisterFieldSet(FIELDNO("Ship-to Name"));
                        end;
                    end;
                }
                field(shipToContact; "Ship-to Contact")
                {
                    Caption = 'shipToContact', Locked = true;

                    trigger OnValidate()
                    begin
                        if xRec."Ship-to Contact" <> "Ship-to Contact" then begin
                            "Ship-to Code" := '';
                            RegisterFieldSet(FIELDNO("Ship-to Code"));
                            RegisterFieldSet(FIELDNO("Ship-to Contact"));
                        end;
                    end;
                }
                field(sellingPostalAddress; SellingPostalAddressJSONText)
                {
                    Caption = 'sellingPostalAddress', Locked = true;
                    ODataEDMType = 'POSTALADDRESS';
                    ToolTip = 'Specifies the selling address of the Sales Invoice.';

                    trigger OnValidate()
                    begin
                        SellingPostalAddressSet := TRUE;
                    end;
                }
                field(billingPostalAddress; BillingPostalAddressJSONText)
                {
                    Caption = 'billingPostalAddress', Locked = true;
                    ODataEDMType = 'POSTALADDRESS';
                    ToolTip = 'Specifies the billing address of the Sales Invoice.';

                    trigger OnValidate()
                    begin
                        BillingPostalAddressSet := TRUE;
                    end;
                }
                field(shippingPostalAddress; ShippingPostalAddressJSONText)
                {
                    Caption = 'shippingPostalAddress', Locked = true;
                    ODataEDMType = 'POSTALADDRESS';
                    ToolTip = 'Specifies the shipping address of the Sales Invoice.';

                    trigger OnValidate()
                    begin
                        ShippingPostalAddressSet := TRUE;
                    end;
                }
                field(currencyId; "Currency Id")
                {
                    Caption = 'currencyId', Locked = true;

                    trigger OnValidate()
                    begin
                        IF "Currency Id" = BlankGUID THEN
                            "Currency Code" := ''
                        ELSE BEGIN
                            IF NOT Currency.GetBySystemId("Currency Id") THEN
                                ERROR(CurrencyIdDoesNotMatchACurrencyErr);

                            "Currency Code" := Currency.Code;
                        END;

                        RegisterFieldSet(FIELDNO("Currency Id"));
                        RegisterFieldSet(FIELDNO("Currency Code"));
                    end;
                }
                field(currencyCode; CurrencyCodeTxt)
                {
                    Caption = 'currencyCode', Locked = true;

                    trigger OnValidate()
                    begin
                        "Currency Code" :=
                          GraphMgtGeneralTools.TranslateCurrencyCodeToNAVCurrencyCode(
                            LCYCurrencyCode, COPYSTR(CurrencyCodeTxt, 1, MAXSTRLEN(LCYCurrencyCode)));

                        IF Currency.Code <> '' THEN BEGIN
                            IF Currency.Code <> "Currency Code" THEN
                                ERROR(CurrencyValuesDontMatchErr);
                            EXIT;
                        END;

                        IF "Currency Code" = '' THEN
                            "Currency Id" := BlankGUID
                        ELSE BEGIN
                            IF NOT Currency.GET("Currency Code") THEN
                                ERROR(CurrencyCodeDoesNotMatchACurrencyErr);

                            "Currency Id" := Currency.SystemId;
                        END;

                        RegisterFieldSet(FIELDNO("Currency Id"));
                        RegisterFieldSet(FIELDNO("Currency Code"));
                    end;
                }
                field(paymentTermsId; "Payment Terms Id")
                {
                    Caption = 'paymentTermsId', Locked = true;

                    trigger OnValidate()
                    begin
                        IF "Payment Terms Id" = BlankGUID THEN
                            "Payment Terms Code" := ''
                        ELSE BEGIN
                            IF NOT PaymentTerms.GetBySystemId("Payment Terms Id") THEN
                                ERROR(PaymentTermsIdDoesNotMatchAPaymentTermsErr);

                            "Payment Terms Code" := PaymentTerms.Code;
                        END;

                        RegisterFieldSet(FIELDNO("Payment Terms Id"));
                        RegisterFieldSet(FIELDNO("Payment Terms Code"));
                    end;
                }
                field(shipmentMethodId; "Shipment Method Id")
                {
                    Caption = 'shipmentMethodId', Locked = true;

                    trigger OnValidate()
                    begin
                        IF "Shipment Method Id" = BlankGUID THEN
                            "Shipment Method Code" := ''
                        ELSE BEGIN
                            IF NOT ShipmentMethod.GetBySystemId("Shipment Method Id") THEN
                                ERROR(ShipmentMethodIdDoesNotMatchAShipmentMethodErr);

                            "Shipment Method Code" := ShipmentMethod.Code;
                        END;

                        RegisterFieldSet(FIELDNO("Shipment Method Id"));
                        RegisterFieldSet(FIELDNO("Shipment Method Code"));
                    end;
                }
                field(salesperson; "Salesperson Code")
                {
                    Caption = 'salesperson', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Salesperson Code"));
                    end;
                }
                part(salesQuoteLines; "APIV1 - Sales Quote Lines")
                {
                    Caption = 'Lines', Locked = true;
                    EntityName = 'salesQuoteLine';
                    EntitySetName = 'salesQuoteLines';
                    SubPageLink = "Document Id" = FIELD(Id);
                }
                part(pdfDocument; "APIV1 - PDF Document")
                {
                    Caption = 'PDF Document', Locked = true;
                    EntityName = 'pdfDocument';
                    EntitySetName = 'pdfDocument';
                    SubPageLink = "Document Id" = FIELD(Id);
                }
                field(discountAmount; "Invoice Discount Amount")
                {
                    Caption = 'discountAmount', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Invoice Discount Amount"));
                        InvoiceDiscountAmount := "Invoice Discount Amount";
                        DiscountAmountSet := TRUE;
                    end;
                }
                field(totalAmountExcludingTax; Amount)
                {
                    Caption = 'totalAmountExcludingTax', Locked = true;
                    Editable = false;
                }
                field(totalTaxAmount; "Total Tax Amount")
                {
                    Caption = 'totalTaxAmount', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the total tax amount for the sales invoice.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Total Tax Amount"));
                    end;
                }
                field(totalAmountIncludingTax; "Amount Including VAT")
                {
                    Caption = 'totalAmountIncludingTax', Locked = true;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Amount Including VAT"));
                    end;
                }
                field(status; Status)
                {
                    Caption = 'status', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the status of the Sales Quote (Draft,Sent,Accepted).';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Status));
                    end;
                }
                field(sentDate; "Quote Sent to Customer")
                {
                    Caption = 'sentDate', Locked = true;
                }
                field(validUntilDate; "Quote Valid Until Date")
                {
                    Caption = 'validUntilDate', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Quote Valid Until Date"));
                    end;
                }
                field(acceptedDate; "Quote Accepted Date")
                {
                    Caption = 'acceptedDate', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Quote Accepted Date"));
                    end;
                }
                field(lastModifiedDateTime; "Last Modified Date Time")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                    Editable = false;
                }
                field(phoneNumber; "Sell-to Phone No.")
                {
                    Caption = 'phoneNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Sell-to Phone No."));
                    end;
                }
                field(email; "Sell-to E-Mail")
                {
                    Caption = 'email', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Sell-to E-Mail"));
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

        EXIT(FALSE);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        GraphMgtSalesQuoteBuffer: Codeunit "Graph Mgt - Sales Quote Buffer";
    begin
        CheckSellToCustomerSpecified();
        ProcessSellingPostalAddressOnInsert();
        ProcessBillingPostalAddressOnInsert();
        ProcessShippingPostalAddressOnInsert();

        GraphMgtSalesQuoteBuffer.PropagateOnInsert(Rec, TempFieldBuffer);
        SetDates();

        UpdateDiscount();

        SetCalculatedFields();

        EXIT(FALSE);
    end;

    trigger OnModifyRecord(): Boolean
    var
        GraphMgtSalesQuoteBuffer: Codeunit "Graph Mgt - Sales Quote Buffer";
    begin
        IF xRec.Id <> Id THEN
            ERROR(CannotChangeIDErr);

        ProcessSellingPostalAddressOnModify();
        ProcessBillingPostalAddressOnModify();
        ProcessShippingPostalAddressOnModify();

        GraphMgtSalesQuoteBuffer.PropagateOnModify(Rec, TempFieldBuffer);
        UpdateDiscount();

        SetCalculatedFields();

        EXIT(FALSE);
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
        SellingPostalAddressJSONText: Text;
        BillingPostalAddressJSONText: Text;
        ShippingPostalAddressJSONText: Text;
        CurrencyCodeTxt: Text;
        SellingPostalAddressSet: Boolean;
        BillingPostalAddressSet: Boolean;
        ShippingPostalAddressSet: Boolean;
        CouldNotFindSellToCustomerErr: Label 'The sell-to customer cannot be found.', Locked = true;
        CouldNotFindBillToCustomerErr: Label 'The bill-to customer cannot be found.', Locked = true;
        CannotChangeIDErr: Label 'The id cannot be changed.', Locked = true;
        SellToCustomerNotProvidedErr: Label 'A customerNumber or a customerId must be provided.', Locked = true;
        SellToCustomerValuesDontMatchErr: Label 'The sell-to customer values do not match to a specific Customer.', Locked = true;
        BillToCustomerValuesDontMatchErr: Label 'The bill-to customer values do not match to a specific Customer.', Locked = true;
        SalesQuotePermissionsErr: Label 'You do not have permissions to read Sales Quotes.';
        CurrencyValuesDontMatchErr: Label 'The currency values do not match to a specific Currency.', Locked = true;
        CurrencyIdDoesNotMatchACurrencyErr: Label 'The "currencyId" does not match to a Currency.', Locked = true;
        CurrencyCodeDoesNotMatchACurrencyErr: Label 'The "currencyCode" does not match to a Currency.', Locked = true;
        PaymentTermsIdDoesNotMatchAPaymentTermsErr: Label 'The "paymentTermsId" does not match to a Payment Terms.', Locked = true;
        ShipmentMethodIdDoesNotMatchAShipmentMethodErr: Label 'The "shipmentMethodId" does not match to a Shipment Method.', Locked = true;
        DiscountAmountSet: Boolean;
        InvoiceDiscountAmount: Decimal;
        BlankGUID: Guid;
        DocumentDateSet: Boolean;
        DocumentDateVar: Date;
        PostingDateSet: Boolean;
        PostingDateVar: Date;
        DueDateSet: Boolean;
        DueDateVar: Date;
        CannotFindQuoteErr: Label 'The quote cannot be found.', Locked = true;
        HasWritePermission: Boolean;

    local procedure SetCalculatedFields()
    var
        GraphMgtSalesQuote: Codeunit "Graph Mgt - Sales Quote";
    begin
        SellingPostalAddressJSONText := GraphMgtSalesQuote.SellToCustomerAddressToJSON(Rec);
        BillingPostalAddressJSONText := GraphMgtSalesQuote.BillToCustomerAddressToJSON(Rec);
        ShippingPostalAddressJSONText := GraphMgtSalesQuote.ShipToCustomerAddressToJSON(Rec);
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, "Currency Code");
    end;

    local procedure ClearCalculatedFields()
    begin
        CLEAR(SellingPostalAddressJSONText);
        CLEAR(BillingPostalAddressJSONText);
        CLEAR(ShippingPostalAddressJSONText);
        CLEAR(DiscountAmountSet);
        CLEAR(InvoiceDiscountAmount);

        TempFieldBuffer.DELETEALL();
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    var
        LastOrderNo: Integer;
    begin
        LastOrderNo := 1;
        IF TempFieldBuffer.FINDLAST() THEN
            LastOrderNo := TempFieldBuffer.Order + 1;

        CLEAR(TempFieldBuffer);
        TempFieldBuffer.Order := LastOrderNo;
        TempFieldBuffer."Table ID" := DATABASE::"Sales Quote Entity Buffer";
        TempFieldBuffer."Field ID" := FieldNo;
        TempFieldBuffer.INSERT();
    end;

    local procedure CheckSellToCustomerSpecified()
    begin
        IF ("Sell-to Customer No." = '') AND
           ("Customer Id" = BlankGUID)
        THEN
            ERROR(SellToCustomerNotProvidedErr);
    end;

    local procedure ProcessSellingPostalAddressOnInsert()
    var
        GraphMgtSalesQuote: Codeunit "Graph Mgt - Sales Quote";
    begin
        IF NOT SellingPostalAddressSet THEN
            EXIT;

        GraphMgtSalesQuote.ParseSellToCustomerAddressFromJSON(SellingPostalAddressJSONText, Rec);

        RegisterFieldSet(FIELDNO("Sell-to Address"));
        RegisterFieldSet(FIELDNO("Sell-to Address 2"));
        RegisterFieldSet(FIELDNO("Sell-to City"));
        RegisterFieldSet(FIELDNO("Sell-to Country/Region Code"));
        RegisterFieldSet(FIELDNO("Sell-to Post Code"));
        RegisterFieldSet(FIELDNO("Sell-to County"));
    end;

    local procedure ProcessSellingPostalAddressOnModify()
    var
        GraphMgtSalesQuote: Codeunit "Graph Mgt - Sales Quote";
    begin
        IF NOT SellingPostalAddressSet THEN
            EXIT;

        GraphMgtSalesQuote.ParseSellToCustomerAddressFromJSON(SellingPostalAddressJSONText, Rec);

        IF xRec."Sell-to Address" <> "Sell-to Address" THEN
            RegisterFieldSet(FIELDNO("Sell-to Address"));

        IF xRec."Sell-to Address 2" <> "Sell-to Address 2" THEN
            RegisterFieldSet(FIELDNO("Sell-to Address 2"));

        IF xRec."Sell-to City" <> "Sell-to City" THEN
            RegisterFieldSet(FIELDNO("Sell-to City"));

        IF xRec."Sell-to Country/Region Code" <> "Sell-to Country/Region Code" THEN
            RegisterFieldSet(FIELDNO("Sell-to Country/Region Code"));

        IF xRec."Sell-to Post Code" <> "Sell-to Post Code" THEN
            RegisterFieldSet(FIELDNO("Sell-to Post Code"));

        IF xRec."Sell-to County" <> "Sell-to County" THEN
            RegisterFieldSet(FIELDNO("Sell-to County"));
    end;

    local procedure ProcessBillingPostalAddressOnInsert()
    var
        GraphMgtSalesQuote: Codeunit "Graph Mgt - Sales Quote";
    begin
        IF NOT BillingPostalAddressSet THEN
            EXIT;

        GraphMgtSalesQuote.ParseBillToCustomerAddressFromJSON(BillingPostalAddressJSONText, Rec);

        RegisterFieldSet(FIELDNO("Bill-to Address"));
        RegisterFieldSet(FIELDNO("Bill-to Address 2"));
        RegisterFieldSet(FIELDNO("Bill-to City"));
        RegisterFieldSet(FIELDNO("Bill-to Country/Region Code"));
        RegisterFieldSet(FIELDNO("Bill-to Post Code"));
        RegisterFieldSet(FIELDNO("Bill-to County"));
    end;

    local procedure ProcessBillingPostalAddressOnModify()
    var
        GraphMgtSalesQuote: Codeunit "Graph Mgt - Sales Quote";
    begin
        IF NOT BillingPostalAddressSet THEN
            EXIT;

        GraphMgtSalesQuote.ParseBillToCustomerAddressFromJSON(BillingPostalAddressJSONText, Rec);

        IF xRec."Bill-to Address" <> "Bill-to Address" THEN
            RegisterFieldSet(FIELDNO("Bill-to Address"));

        IF xRec."Bill-to Address 2" <> "Bill-to Address 2" THEN
            RegisterFieldSet(FIELDNO("Bill-to Address 2"));

        IF xRec."Bill-to City" <> "Bill-to City" THEN
            RegisterFieldSet(FIELDNO("Bill-to City"));

        IF xRec."Bill-to Country/Region Code" <> "Bill-to Country/Region Code" THEN
            RegisterFieldSet(FIELDNO("Bill-to Country/Region Code"));

        IF xRec."Bill-to Post Code" <> "Bill-to Post Code" THEN
            RegisterFieldSet(FIELDNO("Bill-to Post Code"));

        IF xRec."Bill-to County" <> "Bill-to County" THEN
            RegisterFieldSet(FIELDNO("Bill-to County"));
    end;

    local procedure ProcessShippingPostalAddressOnInsert()
    var
        GraphMgtSalesQuote: Codeunit "Graph Mgt - Sales Quote";
    begin
        if not ShippingPostalAddressSet then
            exit;

        GraphMgtSalesQuote.ParseShipToCustomerAddressFromJSON(ShippingPostalAddressJSONText, Rec);

        "Ship-to Code" := '';
        RegisterFieldSet(FIELDNO("Ship-to Address"));
        RegisterFieldSet(FIELDNO("Ship-to Address 2"));
        RegisterFieldSet(FIELDNO("Ship-to City"));
        RegisterFieldSet(FIELDNO("Ship-to Country/Region Code"));
        RegisterFieldSet(FIELDNO("Ship-to Post Code"));
        RegisterFieldSet(FIELDNO("Ship-to County"));
        RegisterFieldSet(FIELDNO("Ship-to Code"));
    end;

    local procedure ProcessShippingPostalAddressOnModify()
    var
        GraphMgtSalesQuote: Codeunit "Graph Mgt - Sales Quote";
        Changed: Boolean;
    begin
        if not ShippingPostalAddressSet then
            exit;

        GraphMgtSalesQuote.ParseShipToCustomerAddressFromJSON(ShippingPostalAddressJSONText, Rec);

        if xRec."Ship-to Address" <> "Ship-to Address" then begin
            RegisterFieldSet(FIELDNO("Ship-to Address"));
            Changed := true;
        end;

        if xRec."Ship-to Address 2" <> "Ship-to Address 2" then begin
            RegisterFieldSet(FIELDNO("Ship-to Address 2"));
            Changed := true;
        end;

        if xRec."Ship-to City" <> "Ship-to City" then begin
            RegisterFieldSet(FIELDNO("Ship-to City"));
            Changed := true;
        end;

        if xRec."Ship-to Country/Region Code" <> "Ship-to Country/Region Code" then begin
            RegisterFieldSet(FIELDNO("Ship-to Country/Region Code"));
            Changed := true;
        end;

        if xRec."Ship-to Post Code" <> "Ship-to Post Code" then begin
            RegisterFieldSet(FIELDNO("Ship-to Post Code"));
            Changed := true;
        end;

        if xRec."Ship-to County" <> "Ship-to County" then begin
            RegisterFieldSet(FIELDNO("Ship-to County"));
            Changed := true;
        end;

        if Changed then begin
            "Ship-to Code" := '';
            RegisterFieldSet(FIELDNO("Ship-to Code"));
        end;
    end;

    local procedure CheckPermissions()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Quote);
        IF NOT SalesHeader.READPERMISSION() THEN
            ERROR(SalesQuotePermissionsErr);

        HasWritePermission := SalesHeader.WRITEPERMISSION();
    end;

    local procedure UpdateDiscount()
    var
        SalesHeader: Record "Sales Header";
        GraphMgtSalesQuoteBuffer: Codeunit "Graph Mgt - Sales Quote Buffer";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
    begin
        IF NOT DiscountAmountSet THEN BEGIN
            GraphMgtSalesQuoteBuffer.RedistributeInvoiceDiscounts(Rec);
            EXIT;
        END;

        SalesHeader.GET(SalesHeader."Document Type"::Quote, "No.");
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, SalesHeader);
    end;

    local procedure SetDates()
    var
        GraphMgtSalesQuoteBuffer: Codeunit "Graph Mgt - Sales Quote Buffer";
    begin
        IF NOT (DueDateSet OR DocumentDateSet OR PostingDateSet) THEN
            EXIT;

        TempFieldBuffer.RESET();
        TempFieldBuffer.DELETEALL();

        IF DocumentDateSet THEN BEGIN
            "Document Date" := DocumentDateVar;
            RegisterFieldSet(FIELDNO("Document Date"));
        END;

        IF PostingDateSet THEN BEGIN
            "Posting Date" := PostingDateVar;
            RegisterFieldSet(FIELDNO("Posting Date"));
        END;

        IF DueDateSet THEN BEGIN
            "Due Date" := DueDateVar;
            RegisterFieldSet(FIELDNO("Due Date"));
        END;

        GraphMgtSalesQuoteBuffer.PropagateOnModify(Rec, TempFieldBuffer);
        FIND();
    end;

    local procedure GetQuote(var SalesHeader: Record "Sales Header")
    begin
        IF NOT SalesHeader.GetBySystemId(Id) THEN
            ERROR(CannotFindQuoteErr);
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; var SalesHeader: Record "Sales Header")
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Invoice:
                ActionContext.SetObjectId(Page::"APIV1 - Sales Invoices");
            SalesHeader."Document Type"::Order:
                ActionContext.SetObjectId(Page::"APIV1 - Sales Orders");
            SalesHeader."Document Type"::Quote:
                ActionContext.SetObjectId(Page::"APIV1 - Sales Quotes");
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
        APIV1SendSalesDocument: Codeunit "APIV1 - Send Sales Document";
    begin
        GetQuote(SalesHeader);
        APIV1SendSalesDocument.SendQuote(SalesHeader);
        SetActionResponse(ActionContext, SalesHeader);
    end;
}
