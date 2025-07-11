namespace Microsoft.API.V1;

using Microsoft.Integration.Entity;
using Microsoft.Integration.Graph;
using Microsoft.Sales.Customer;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.Sales.Document;
using System.Reflection;

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
                field(documentDate; Rec."Document Date")
                {
                    Caption = 'documentDate', Locked = true;

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

                    trigger OnValidate()
                    begin
                        BillingPostalAddressSet := true;
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
                part(salesQuoteLines; "APIV1 - Sales Quote Lines")
                {
                    Caption = 'Lines', Locked = true;
                    EntityName = 'salesQuoteLine';
                    EntitySetName = 'salesQuoteLines';
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
                    ToolTip = 'Specifies the status of the Sales Quote (Draft,Sent,Accepted).';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Status));
                    end;
                }
                field(sentDate; Rec."Quote Sent to Customer")
                {
                    Caption = 'sentDate', Locked = true;
                }
                field(validUntilDate; Rec."Quote Valid Until Date")
                {
                    Caption = 'validUntilDate', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Quote Valid Until Date"));
                    end;
                }
                field(acceptedDate; Rec."Quote Accepted Date")
                {
                    Caption = 'acceptedDate', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Quote Accepted Date"));
                    end;
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
        ProcessSellingPostalAddressOnInsert();
        ProcessBillingPostalAddressOnInsert();
        ProcessShippingPostalAddressOnInsert();

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
            error(CannotChangeIDErr);

        ProcessSellingPostalAddressOnModify();
        ProcessBillingPostalAddressOnModify();
        ProcessShippingPostalAddressOnModify();

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
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, Rec."Currency Code");
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
        if TempFieldBuffer.FINDLAST() then
            LastOrderNo := TempFieldBuffer.Order + 1;

        CLEAR(TempFieldBuffer);
        TempFieldBuffer.Order := LastOrderNo;
        TempFieldBuffer."Table ID" := DATABASE::"Sales Quote Entity Buffer";
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
        GraphMgtSalesQuote: Codeunit "Graph Mgt - Sales Quote";
    begin
        if not SellingPostalAddressSet then
            exit;

        GraphMgtSalesQuote.ParseSellToCustomerAddressFromJSON(SellingPostalAddressJSONText, Rec);

        RegisterFieldSet(Rec.FieldNo("Sell-to Address"));
        RegisterFieldSet(Rec.FieldNo("Sell-to Address 2"));
        RegisterFieldSet(Rec.FieldNo("Sell-to City"));
        RegisterFieldSet(Rec.FieldNo("Sell-to Country/Region Code"));
        RegisterFieldSet(Rec.FieldNo("Sell-to Post Code"));
        RegisterFieldSet(Rec.FieldNo("Sell-to County"));
    end;

    local procedure ProcessSellingPostalAddressOnModify()
    var
        GraphMgtSalesQuote: Codeunit "Graph Mgt - Sales Quote";
    begin
        if not SellingPostalAddressSet then
            exit;

        GraphMgtSalesQuote.ParseSellToCustomerAddressFromJSON(SellingPostalAddressJSONText, Rec);

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
    var
        GraphMgtSalesQuote: Codeunit "Graph Mgt - Sales Quote";
    begin
        if not BillingPostalAddressSet then
            exit;

        GraphMgtSalesQuote.ParseBillToCustomerAddressFromJSON(BillingPostalAddressJSONText, Rec);

        RegisterFieldSet(Rec.FieldNo("Bill-to Address"));
        RegisterFieldSet(Rec.FieldNo("Bill-to Address 2"));
        RegisterFieldSet(Rec.FieldNo("Bill-to City"));
        RegisterFieldSet(Rec.FieldNo("Bill-to Country/Region Code"));
        RegisterFieldSet(Rec.FieldNo("Bill-to Post Code"));
        RegisterFieldSet(Rec.FieldNo("Bill-to County"));
    end;

    local procedure ProcessBillingPostalAddressOnModify()
    var
        GraphMgtSalesQuote: Codeunit "Graph Mgt - Sales Quote";
    begin
        if not BillingPostalAddressSet then
            exit;

        GraphMgtSalesQuote.ParseBillToCustomerAddressFromJSON(BillingPostalAddressJSONText, Rec);

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

    local procedure ProcessShippingPostalAddressOnInsert()
    var
        GraphMgtSalesQuote: Codeunit "Graph Mgt - Sales Quote";
    begin
        if not ShippingPostalAddressSet then
            exit;

        GraphMgtSalesQuote.ParseShipToCustomerAddressFromJSON(ShippingPostalAddressJSONText, Rec);

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
        GraphMgtSalesQuote: Codeunit "Graph Mgt - Sales Quote";
        Changed: Boolean;
    begin
        if not ShippingPostalAddressSet then
            exit;

        GraphMgtSalesQuote.ParseShipToCustomerAddressFromJSON(ShippingPostalAddressJSONText, Rec);

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

    local procedure CheckPermissions()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Quote);
        if not SalesHeader.READPERMISSION() then
            error(SalesQuotePermissionsErr);

        HasWritePermission := SalesHeader.WRITEPERMISSION();
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

        SalesHeader.GET(SalesHeader."Document Type"::Quote, Rec."No.");
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, SalesHeader);
    end;

    local procedure SetDates()
    var
        GraphMgtSalesQuoteBuffer: Codeunit "Graph Mgt - Sales Quote Buffer";
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

        GraphMgtSalesQuoteBuffer.PropagateOnModify(Rec, TempFieldBuffer);
        Rec.FIND();
    end;

    local procedure GetQuote(var SalesHeader: Record "Sales Header")
    begin
        if not SalesHeader.GetBySystemId(Rec.Id) then
            error(CannotFindQuoteErr);
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
        SalesHeader.SETRECfilter();
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
        SalesHeader.SETRECfilter();
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

