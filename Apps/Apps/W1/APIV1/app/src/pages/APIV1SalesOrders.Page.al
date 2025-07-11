namespace Microsoft.API.V1;

using Microsoft.Integration.Entity;
using Microsoft.Sales.Customer;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.Integration.Graph;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;
using Microsoft.Utilities;
using System.Reflection;

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
                field(orderDate; Rec."Document Date")
                {
                    Caption = 'orderDate', Locked = true;

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
                field(pricesIncludeTax; Rec."Prices Including VAT")
                {
                    Caption = 'pricesIncludeTax', Locked = true;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Prices Including VAT"));
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
                field(partialShipping; PartialOrderShipping)
                {
                    Caption = 'partialShipping', Locked = true;

                    trigger OnValidate()
                    begin
                        ProcessPartialShipping();
                    end;
                }
                field(requestedDeliveryDate; Rec."Requested Delivery Date")
                {
                    Caption = 'requestedDeliveryDate', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Requested Delivery Date"));
                    end;
                }
                part(salesOrderLines; "APIV1 - Sales Order Lines")
                {
                    Caption = 'Lines', Locked = true;
                    EntityName = 'salesOrderLine';
                    EntitySetName = 'salesOrderLines';
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
                field(fullyShipped; Rec."Completely Shipped")
                {
                    Caption = 'fullyShipped', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Completely Shipped"));
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
    begin
        SetCalculatedFields();
        if HasWritePermission then
            GraphMgtSalesOrderBuffer.RedistributeInvoiceDiscounts(Rec);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        GraphMgtSalesOrderBuffer.PropagateOnDelete(Rec);

        exit(false);
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

        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if xRec.Id <> Rec.Id then
            error(CannotChangeIDErr);

        ProcessSellingPostalAddressOnModify();
        ProcessShippingPostalAddressOnModify();

        GraphMgtSalesOrderBuffer.PropagateOnModify(Rec, TempFieldBuffer);
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
        GraphMgtSalesOrderBuffer: Codeunit "Graph Mgt - Sales Order Buffer";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        APIV1SendSalesDocument: Codeunit "APIV1 - Send Sales Document";
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
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, Rec."Currency Code");
        PartialOrderShipping := (Rec."Shipping Advice" = Rec."Shipping Advice"::Partial);
    end;

    local procedure ClearCalculatedFields()
    begin
        CLEAR(SellingPostalAddressJSONText);
        CLEAR(BillingPostalAddressJSONText);
        CLEAR(ShippingPostalAddressJSONText);
        CLEAR(DiscountAmountSet);
        CLEAR(InvoiceDiscountAmount);

        PartialOrderShipping := false;
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

    local procedure CheckSellToCustomerSpecified()
    begin
        if (Rec."Sell-to Customer No." = '') and
           (Rec."Customer Id" = BlankGUID)
        then
            error(SellToCustomerNotProvidedErr);
    end;

    local procedure ProcessSellingPostalAddressOnInsert()
    var
        GraphMgtSalesOrder: Codeunit "Graph Mgt - Sales Order";
    begin
        if not SellingPostalAddressSet then
            exit;

        GraphMgtSalesOrder.ParseSellToCustomerAddressFromJSON(SellingPostalAddressJSONText, Rec);

        RegisterFieldSet(Rec.FieldNo("Sell-to Address"));
        RegisterFieldSet(Rec.FieldNo("Sell-to Address 2"));
        RegisterFieldSet(Rec.FieldNo("Sell-to City"));
        RegisterFieldSet(Rec.FieldNo("Sell-to Country/Region Code"));
        RegisterFieldSet(Rec.FieldNo("Sell-to Post Code"));
        RegisterFieldSet(Rec.FieldNo("Sell-to County"));
    end;

    local procedure ProcessSellingPostalAddressOnModify()
    var
        GraphMgtSalesOrder: Codeunit "Graph Mgt - Sales Order";
    begin
        if not SellingPostalAddressSet then
            exit;

        GraphMgtSalesOrder.ParseSellToCustomerAddressFromJSON(SellingPostalAddressJSONText, Rec);

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
        GraphMgtSalesOrder: Codeunit "Graph Mgt - Sales Order";
    begin
        if not ShippingPostalAddressSet then
            exit;

        GraphMgtSalesOrder.ParseShipToCustomerAddressFromJSON(ShippingPostalAddressJSONText, Rec);

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
        GraphMgtSalesOrder: Codeunit "Graph Mgt - Sales Order";
        Changed: Boolean;
    begin
        if not ShippingPostalAddressSet then
            exit;

        GraphMgtSalesOrder.ParseShipToCustomerAddressFromJSON(ShippingPostalAddressJSONText, Rec);

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

    local procedure ProcessPartialShipping()
    begin
        if PartialOrderShipping then
            Rec."Shipping Advice" := Rec."Shipping Advice"::Partial
        else
            Rec."Shipping Advice" := Rec."Shipping Advice"::Complete;

        RegisterFieldSet(Rec.FieldNo("Shipping Advice"));
    end;

    local procedure CheckPermissions()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
        if not SalesHeader.READPERMISSION() then
            error(SalesOrderPermissionsErr);

        HasWritePermission := SalesHeader.WRITEPERMISSION();
    end;

    local procedure UpdateDiscount()
    var
        SalesHeader: Record "Sales Header";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
    begin
        if not DiscountAmountSet then begin
            GraphMgtSalesOrderBuffer.RedistributeInvoiceDiscounts(Rec);
            exit;
        end;

        SalesHeader.GET(SalesHeader."Document Type"::Order, Rec."No.");
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, SalesHeader);
    end;

    local procedure SetDates()
    begin
        if not (DocumentDateSet or PostingDateSet) then
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

        GraphMgtSalesOrderBuffer.PropagateOnModify(Rec, TempFieldBuffer);
        Rec.FIND();
    end;

    local procedure GetOrder(var SalesHeader: Record "Sales Header")
    begin
        if not SalesHeader.GetBySystemId(Rec.Id) then
            error(CannotFindOrderErr);
    end;

    local procedure PostWithShipAndInvoice(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
        OrderNo: Code[20];
        OrderNoSeries: Code[20];
    begin
        APIV1SendSalesDocument.CheckDocumentIfNoItemsExists(SalesHeader);
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
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(PageId);
        ActionContext.AddEntityKey(Rec.FieldNo(Id), DocumentId);
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





















