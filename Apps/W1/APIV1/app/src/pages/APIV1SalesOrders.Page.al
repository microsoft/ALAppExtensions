page 20028 "APIV1 - Sales Orders"
{
    APIVersion = 'v1.0';
    Caption = 'salesOrders', Locked = true;
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'salesOrder';
    EntitySetName = 'salesOrders';
    ODataKeyFields = Id;
    PageType = API;
    SourceTable = "Sales Order Entity Buffer";
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
                field(orderDate; "Document Date")
                {
                    Caption = 'orderDate', Locked = true;

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
                    Editable = false;

                    trigger OnValidate()
                    begin
                        Error(BillingPostalAddressIsReadOnlyErr);
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
                field(pricesIncludeTax; "Prices Including VAT")
                {
                    Caption = 'pricesIncludeTax', Locked = true;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Prices Including VAT"));
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
                field(partialShipping; PartialOrderShipping)
                {
                    Caption = 'partialShipping', Locked = true;

                    trigger OnValidate()
                    begin
                        ProcessPartialShipping();
                    end;
                }
                field(requestedDeliveryDate; "Requested Delivery Date")
                {
                    Caption = 'requestedDeliveryDate', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Requested Delivery Date"));
                    end;
                }
                part(salesOrderLines; "APIV1 - Sales Order Lines")
                {
                    Caption = 'Lines', Locked = true;
                    EntityName = 'salesOrderLine';
                    EntitySetName = 'salesOrderLines';
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
                field(discountAppliedBeforeTax; "Discount Applied Before Tax")
                {
                    Caption = 'discountAppliedBeforeTax', Locked = true;
                    Editable = false;
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
                field(fullyShipped; "Completely Shipped")
                {
                    Caption = 'fullyShipped', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Completely Shipped"));
                    end;
                }
                field(status; Status)
                {
                    Caption = 'status', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the status of the Sales Invoice (cancelled, paid, on hold, created).';
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
    begin
        SetCalculatedFields();
        if HasWritePermission then
            GraphMgtSalesOrderBuffer.RedistributeInvoiceDiscounts(Rec);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        GraphMgtSalesOrderBuffer.PropagateOnDelete(Rec);

        EXIT(FALSE);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        CheckSellToCustomerSpecified();
        ProcessSellingPostalAddressOnInsert();
        ProcessShippingPostalAddressOnInsert();

        GraphMgtSalesOrderBuffer.PropagateOnInsert(Rec, TempFieldBuffer);
        SetDates();

        UpdateDiscount();

        SetCalculatedFields();

        EXIT(FALSE);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        IF xRec.Id <> Id THEN
            ERROR(CannotChangeIDErr);

        ProcessSellingPostalAddressOnModify();
        ProcessShippingPostalAddressOnModify();

        GraphMgtSalesOrderBuffer.PropagateOnModify(Rec, TempFieldBuffer);
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
        GraphMgtSalesOrderBuffer: Codeunit "Graph Mgt - Sales Order Buffer";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        LCYCurrencyCode: Code[10];
        CurrencyCodeTxt: Text;
        SellingPostalAddressJSONText: Text;
        BillingPostalAddressJSONText: Text;
        ShippingPostalAddressJSONText: Text;
        SellingPostalAddressSet: Boolean;
        ShippingPostalAddressSet: Boolean;
        CannotChangeIDErr: Label 'The id cannot be changed.', Locked = true;
        SellToCustomerNotProvidedErr: Label 'A customerNumber or a customerId must be provided.', Locked = true;
        SellToCustomerValuesDontMatchErr: Label 'The sell-to customer values do not match to a specific Customer.', Locked = true;
        BillToCustomerValuesDontMatchErr: Label 'The bill-to customer values do not match to a specific Customer.', Locked = true;
        CouldNotFindSellToCustomerErr: Label 'The sell-to customer cannot be found.', Locked = true;
        CouldNotFindBillToCustomerErr: Label 'The bill-to customer cannot be found.', Locked = true;
        PartialOrderShipping: Boolean;
        SalesOrderPermissionsErr: Label 'You do not have permissions to read Sales Orders.';
        CurrencyValuesDontMatchErr: Label 'The currency values do not match to a specific Currency.', Locked = true;
        CurrencyIdDoesNotMatchACurrencyErr: Label 'The "currencyId" does not match to a Currency.', Locked = true;
        CurrencyCodeDoesNotMatchACurrencyErr: Label 'The "currencyCode" does not match to a Currency.', Locked = true;
        PaymentTermsIdDoesNotMatchAPaymentTermsErr: Label 'The "paymentTermsId" does not match to a Payment Terms.', Locked = true;
        ShipmentMethodIdDoesNotMatchAShipmentMethodErr: Label 'The "shipmentMethodId" does not match to a Shipment Method.', Locked = true;
        BillingPostalAddressIsReadOnlyErr: Label 'The "billingPotalAddress" is read-only.', Locked = true;
        CannotFindOrderErr: Label 'The order cannot be found.', Locked = true;
        DiscountAmountSet: Boolean;
        InvoiceDiscountAmount: Decimal;
        BlankGUID: Guid;
        DocumentDateSet: Boolean;
        DocumentDateVar: Date;
        PostingDateSet: Boolean;
        PostingDateVar: Date;
        HasWritePermission: Boolean;

    local procedure SetCalculatedFields()
    var
        GraphMgtSalesOrder: Codeunit "Graph Mgt - Sales Order";
    begin
        SellingPostalAddressJSONText := GraphMgtSalesOrder.SellToCustomerAddressToJSON(Rec);
        BillingPostalAddressJSONText := GraphMgtSalesOrder.BillToCustomerAddressToJSON(Rec);
        ShippingPostalAddressJSONText := GraphMgtSalesOrder.ShipToCustomerAddressToJSON(Rec);
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, "Currency Code");
        PartialOrderShipping := ("Shipping Advice" = "Shipping Advice"::Partial);
    end;

    local procedure ClearCalculatedFields()
    begin
        CLEAR(SellingPostalAddressJSONText);
        CLEAR(BillingPostalAddressJSONText);
        CLEAR(ShippingPostalAddressJSONText);
        CLEAR(DiscountAmountSet);
        CLEAR(InvoiceDiscountAmount);

        PartialOrderShipping := FALSE;
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
        TempFieldBuffer."Table ID" := DATABASE::"Sales Invoice Entity Aggregate";
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
        GraphMgtSalesOrder: Codeunit "Graph Mgt - Sales Order";
    begin
        IF NOT SellingPostalAddressSet THEN
            EXIT;

        GraphMgtSalesOrder.ParseSellToCustomerAddressFromJSON(SellingPostalAddressJSONText, Rec);

        RegisterFieldSet(FIELDNO("Sell-to Address"));
        RegisterFieldSet(FIELDNO("Sell-to Address 2"));
        RegisterFieldSet(FIELDNO("Sell-to City"));
        RegisterFieldSet(FIELDNO("Sell-to Country/Region Code"));
        RegisterFieldSet(FIELDNO("Sell-to Post Code"));
        RegisterFieldSet(FIELDNO("Sell-to County"));
    end;

    local procedure ProcessSellingPostalAddressOnModify()
    var
        GraphMgtSalesOrder: Codeunit "Graph Mgt - Sales Order";
    begin
        IF NOT SellingPostalAddressSet THEN
            EXIT;

        GraphMgtSalesOrder.ParseSellToCustomerAddressFromJSON(SellingPostalAddressJSONText, Rec);

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

    local procedure ProcessShippingPostalAddressOnInsert()
    var
        GraphMgtSalesOrder: Codeunit "Graph Mgt - Sales Order";
    begin
        if not ShippingPostalAddressSet then
            exit;

        GraphMgtSalesOrder.ParseShipToCustomerAddressFromJSON(ShippingPostalAddressJSONText, Rec);

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
        GraphMgtSalesOrder: Codeunit "Graph Mgt - Sales Order";
        Changed: Boolean;
    begin
        if not ShippingPostalAddressSet then
            exit;

        GraphMgtSalesOrder.ParseShipToCustomerAddressFromJSON(ShippingPostalAddressJSONText, Rec);

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

    local procedure ProcessPartialShipping()
    begin
        IF PartialOrderShipping THEN
            "Shipping Advice" := "Shipping Advice"::Partial
        ELSE
            "Shipping Advice" := "Shipping Advice"::Complete;

        RegisterFieldSet(FIELDNO("Shipping Advice"));
    end;

    local procedure CheckPermissions()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
        IF NOT SalesHeader.READPERMISSION() THEN
            ERROR(SalesOrderPermissionsErr);

        HasWritePermission := SalesHeader.WRITEPERMISSION();
    end;

    local procedure UpdateDiscount()
    var
        SalesHeader: Record "Sales Header";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
    begin
        IF NOT DiscountAmountSet THEN BEGIN
            GraphMgtSalesOrderBuffer.RedistributeInvoiceDiscounts(Rec);
            EXIT;
        END;

        SalesHeader.GET(SalesHeader."Document Type"::Order, "No.");
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, SalesHeader);
    end;

    local procedure SetDates()
    begin
        IF NOT (DocumentDateSet OR PostingDateSet) THEN
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

        GraphMgtSalesOrderBuffer.PropagateOnModify(Rec, TempFieldBuffer);
        FIND();
    end;

    local procedure GetOrder(var SalesHeader: Record "Sales Header")
    begin
        IF NOT SalesHeader.GetBySystemId(Id) THEN
            ERROR(CannotFindOrderErr);
    end;

    local procedure PostWithShipAndInvoice(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        DummyO365SalesDocument: Record "O365 Sales Document";
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
        O365SendResendInvoice: Codeunit "O365 Send + Resend Invoice";
        OrderNo: Code[20];
        OrderNoSeries: Code[20];
    begin
        O365SendResendInvoice.CheckDocumentIfNoItemsExists(SalesHeader, FALSE, DummyO365SalesDocument);
        LinesInstructionMgt.SalesCheckAllLinesHaveQuantityAssigned(SalesHeader);
        OrderNo := SalesHeader."No.";
        OrderNoSeries := SalesHeader."No. Series";
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesHeader.SendToPosting(CODEUNIT::"Sales-Post");
        SalesInvoiceHeader.SetCurrentKey("Order No.");
        SalesInvoiceHeader.SetRange("Pre-Assigned No. Series", '');
        SalesInvoiceHeader.SetRange("Order No. Series", OrderNoSeries);
        SalesInvoiceHeader.SetRange("Order No.", OrderNo);
        SalesInvoiceHeader.FindFirst();
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
    procedure ShipAndInvoice(var ActionContext: WebServiceActionContext)
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        GetOrder(SalesHeader);
        PostWithShipAndInvoice(SalesHeader, SalesInvoiceHeader);
        SetActionResponse(ActionContext, Page::"APIV1 - Sales Invoices", SalesInvoiceAggregator.GetSalesInvoiceHeaderId(SalesInvoiceHeader));
    end;
}




















