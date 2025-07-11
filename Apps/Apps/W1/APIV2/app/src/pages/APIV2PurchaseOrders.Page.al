namespace Microsoft.API.V2;

using Microsoft.Integration.Entity;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.Integration.Graph;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.Utilities;
using System.Reflection;

page 30066 "APIV2 - Purchase Orders"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Purchase Order';
    EntitySetCaption = 'Purchase Orders';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'purchaseOrder';
    EntitySetName = 'purchaseOrders';
    ODataKeyFields = Id;
    PageType = API;
    SourceTable = "Purchase Order Entity Buffer";
    Extensible = false;

    layout
    {
        area(Content)
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
                field(orderDate; Rec."Document Date")
                {
                    Caption = 'Order Date';

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
                field(vendorId; Rec."Vendor Id")
                {
                    Caption = 'Vendor Id';

                    trigger OnValidate()
                    begin
                        if not BuyFromVendor.GetBySystemId(Rec."Vendor Id") then
                            Error(CouldNotFindBuyFromVendorErr);

                        Rec."Buy-from Vendor No." := BuyFromVendor."No.";
                        RegisterFieldSet(Rec.FieldNo("Vendor Id"));
                        RegisterFieldSet(Rec.FieldNo("Buy-from Vendor No."));
                    end;
                }
                field(vendorNumber; Rec."Buy-from Vendor No.")
                {
                    Caption = 'Vendor No.';

                    trigger OnValidate()
                    begin
                        if BuyFromVendor."No." <> '' then begin
                            if BuyFromVendor."No." <> Rec."Buy-from Vendor No." then
                                Error(BuyFromVendorValuesDontMatchErr);
                            exit;
                        end;

                        if not BuyFromVendor.Get(Rec."Buy-from Vendor No.") then
                            Error(CouldNotFindBuyFromVendorErr);

                        Rec."Vendor Id" := BuyFromVendor.SystemId;
                        RegisterFieldSet(Rec.FieldNo("Vendor Id"));
                        RegisterFieldSet(Rec.FieldNo("Buy-from Vendor No."));
                    end;
                }
                field(vendorName; Rec."Buy-from Vendor Name")
                {
                    Caption = 'Vendor Name';
                    Editable = false;
                }
                field(payToName; Rec."Pay-to Name")
                {
                    Caption = 'Pay-to Name';
                    Editable = false;
                }
                field(payToVendorId; Rec."Pay-to Vendor Id")
                {
                    Caption = 'Pay-to Vendor Id';

                    trigger OnValidate()
                    begin
                        if not PayToVendor.GetBySystemId(Rec."Pay-to Vendor Id") then
                            Error(CouldNotFindPayToVendorErr);

                        Rec."Pay-to Vendor No." := PayToVendor."No.";
                        RegisterFieldSet(Rec.FieldNo("Pay-to Vendor Id"));
                        RegisterFieldSet(Rec.FieldNo("Pay-to Vendor No."));
                    end;
                }
                field(payToVendorNumber; Rec."Pay-to Vendor No.")
                {
                    Caption = 'Pay-to Vendor No.';

                    trigger OnValidate()
                    begin
                        if PayToVendor."No." <> '' then begin
                            if PayToVendor."No." <> Rec."Pay-to Vendor No." then
                                Error(PayToVendorValuesDontMatchErr);
                            exit;
                        end;

                        if not PayToVendor.Get(Rec."Pay-to Vendor No.") then
                            Error(CouldNotFindPayToVendorErr);

                        Rec."Pay-to Vendor Id" := PayToVendor.SystemId;
                        RegisterFieldSet(Rec.FieldNo("Pay-to Vendor Id"));
                        RegisterFieldSet(Rec.FieldNo("Pay-to Vendor No."));
                    end;
                }
                field(shipToName; Rec."Ship-to Name")
                {
                    Caption = 'Ship-to Name';

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
                    Caption = 'Ship-to Contact';

                    trigger OnValidate()
                    begin
                        if xRec."Ship-to Contact" <> Rec."Ship-to Contact" then begin
                            Rec."Ship-to Code" := '';
                            RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
                            RegisterFieldSet(Rec.FieldNo("Ship-to Contact"));
                        end;
                    end;
                }
                field(buyFromAddressLine1; Rec."Buy-from Address")
                {
                    Caption = 'Buy-from Address Line 1';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Buy-from Address"));
                    end;
                }
                field(buyFromAddressLine2; Rec."Buy-from Address 2")
                {
                    Caption = 'Buy-from Address Line 2';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Buy-from Address 2"));
                    end;
                }
                field(buyFromCity; Rec."Buy-from City")
                {
                    Caption = 'Buy-from City';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Buy-from City"));
                    end;
                }
                field(buyFromCountry; Rec."Buy-from Country/Region Code")
                {
                    Caption = 'Buy-from Country/Region Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Buy-from Country/Region Code"));
                    end;
                }
                field(buyFromState; Rec."Buy-from County")
                {
                    Caption = 'Buy-from State';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Buy-from County"));
                    end;
                }
                field(buyFromPostCode; Rec."Buy-from Post Code")
                {
                    Caption = 'Buy-from Post Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Buy-from Post Code"));
                    end;
                }
                field(payToAddressLine1; Rec."Pay-to Address")
                {
                    Caption = 'Pay-to Address Line 1';
                    Editable = false;
                }
                field(payToAddressLine2; Rec."Pay-to Address 2")
                {
                    Caption = 'Pay-to Address Line 2';
                    Editable = false;
                }
                field(payToCity; Rec."Pay-to City")
                {
                    Caption = 'Pay-to City';
                    Editable = false;
                }
                field(payToCountry; Rec."Pay-to Country/Region Code")
                {
                    Caption = 'Pay-to Country/Region Code';
                    Editable = false;
                }
                field(payToState; Rec."Pay-to County")
                {
                    Caption = 'Pay-to State';
                    Editable = false;
                }
                field(payToPostCode; Rec."Pay-to Post Code")
                {
                    Caption = 'Pay-to Post Code';
                    Editable = false;
                }
                field(shipToAddressLine1; Rec."Ship-to Address")
                {
                    Caption = 'Ship-to Address Line 1';

                    trigger OnValidate()
                    begin
                        Rec."Ship-to Code" := '';
                        RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
                        RegisterFieldSet(Rec.FieldNo("Ship-to Address"));
                    end;
                }
                field(shipToAddressLine2; Rec."Ship-to Address 2")
                {
                    Caption = 'Ship-to Address Line 2';

                    trigger OnValidate()
                    begin
                        Rec."Ship-to Code" := '';
                        RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
                        RegisterFieldSet(Rec.FieldNo("Ship-to Address 2"));
                    end;
                }
                field(shipToCity; Rec."Ship-to City")
                {
                    Caption = 'Ship-to City';

                    trigger OnValidate()
                    begin
                        Rec."Ship-to Code" := '';
                        RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
                        RegisterFieldSet(Rec.FieldNo("Ship-to City"));
                    end;
                }
                field(shipToCountry; Rec."Ship-to Country/Region Code")
                {
                    Caption = 'Ship-to Country/Region Code';

                    trigger OnValidate()
                    begin
                        Rec."Ship-to Code" := '';
                        RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
                        RegisterFieldSet(Rec.FieldNo("Ship-to Country/Region Code"));
                    end;
                }
                field(shipToState; Rec."Ship-to County")
                {
                    Caption = 'Ship-to State';

                    trigger OnValidate()
                    begin
                        Rec."Ship-to Code" := '';
                        RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
                        RegisterFieldSet(Rec.FieldNo("Ship-to County"));
                    end;
                }
                field(shipToPostCode; Rec."Ship-to Post Code")
                {
                    Caption = 'Ship-to Post Code';

                    trigger OnValidate()
                    begin
                        Rec."Ship-to Code" := '';
                        RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
                        RegisterFieldSet(Rec.FieldNo("Ship-to Post Code"));
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
                field(pricesIncludeTax; Rec."Prices Including VAT")
                {
                    Caption = 'Prices Include Tax';

                    trigger OnValidate()
                    var
                        PurchaseLine: Record "Purchase Line";
                    begin
                        if Rec."Prices Including VAT" then begin
                            PurchaseLine.SetRange("Document No.", Rec."No.");
                            PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                            if PurchaseLine.FindFirst() then
                                if PurchaseLine."VAT Calculation Type" = PurchaseLine."VAT Calculation Type"::"Sales Tax" then
                                    Error(CannotEnablePricesIncludeTaxErr);
                        end;
                        RegisterFieldSet(Rec.FieldNo("Prices Including VAT"));
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
                field(purchaser; Rec."Purchaser Code")
                {
                    Caption = 'Purchaser';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Purchaser Code"));
                    end;
                }
                field(requestedReceiptDate; Rec."Requested Receipt Date")
                {
                    Caption = 'Requested Receipt Date';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Requested Receipt Date"));
                    end;
                }
                part(purchaseOrderLines; "APIV2 - Purchase Order Lines")
                {
                    Caption = 'Lines';
                    EntityName = 'purchaseOrderLine';
                    EntitySetName = 'purchaseOrderLines';
                    SubPageLink = "Document Id" = field(Id);
                }
                field(discountAmount; Rec."Invoice Discount Amount")
                {
                    Caption = 'Discount Amount';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Invoice Discount Amount"));
                        InvoiceDiscountAmount := Rec."Invoice Discount Amount";
                        DiscountAmountSet := true;
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
                field(fullyReceived; Rec."Completely Received")
                {
                    Caption = 'Fully Received';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Completely Received"));
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
                part(attachments; "APIV2 - Attachments")
                {
                    Caption = 'Attachments';
                    EntityName = 'attachment';
                    EntitySetName = 'attachments';
                    SubPageLink = "Document Id" = field(Id), "Document Type" = const("Purchase Order");
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = field(Id), "Parent Type" = const("Purchase Order");
                }
                part(documentAttachments; "APIV2 - Document Attachments")
                {
                    Caption = 'Document Attachments';
                    EntityName = 'documentAttachment';
                    EntitySetName = 'documentAttachments';
                    SubPageLink = "Document Id" = field(Id), "Document Type" = const("Purchase Order");
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
            GraphMgtPurchOrderBuffer.RedistributeInvoiceDiscounts(Rec);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        GraphMgtPurchOrderBuffer.PropagateOnDelete(Rec);

        exit(false);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        CheckBuyFromVendorSpecified();

        GraphMgtPurchOrderBuffer.PropagateOnInsert(Rec, TempFieldBuffer);
        SetDates();

        UpdateDiscount();

        SetCalculatedFields();

        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if xRec.Id <> Rec.Id then
            Error(CannotChangeIDErr);

        GraphMgtPurchOrderBuffer.PropagateOnModify(Rec, TempFieldBuffer);
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
        BuyFromVendor: Record "Vendor";
        PayToVendor: Record "Vendor";
        Currency: Record "Currency";
        PaymentTerms: Record "Payment Terms";
        ShipmentMethod: Record "Shipment Method";
        GraphMgtPurchOrderBuffer: Codeunit "Graph Mgt - Purch Order Buffer";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        LCYCurrencyCode: Code[10];
        CurrencyCodeTxt: Text;
        CannotChangeIDErr: Label 'The "id" cannot be changed.', Comment = 'id is a field name and should not be translated.';
        BuyFromVendorNotProvidedErr: Label 'A "vendorNumber" or a "vendorId" must be provided.', Comment = 'vendorNumber and vendorId are field names and should not be translated.';
        BuyFromVendorValuesDontMatchErr: Label 'The buy-from vendor values do not match to a specific Vendor.';
        PayToVendorValuesDontMatchErr: Label 'The pay-to vendor values do not match to a specific Vendor.';
        CouldNotFindBuyFromVendorErr: Label 'The buy-from vendor cannot be found.';
        CouldNotFindPayToVendorErr: Label 'The pay-to vendor cannot be found.';
        PurchaseOrderPermissionsErr: Label 'You do not have permissions to read Purchase Orders.';
        CurrencyValuesDontMatchErr: Label 'The currency values do not match to a specific Currency.';
        CurrencyIdDoesNotMatchACurrencyErr: Label 'The "currencyId" does not match to a Currency.', Comment = 'currencyId is a field name and should not be translated.';
        CurrencyCodeDoesNotMatchACurrencyErr: Label 'The "currencyCode" does not match to a Currency.', Comment = 'currencyCode is a field name and should not be translated.';
        CannotEnablePricesIncludeTaxErr: Label 'The "pricesIncludeTax" cannot be set to true if VAT Calculation Type is Sales Tax.', Comment = 'pricesIncludeTax is a field name and should not be translated.';
        PaymentTermsIdDoesNotMatchAPaymentTermsErr: Label 'The "paymentTermsId" does not match to a Payment Terms.', Comment = 'paymentTermsId is a field name and should not be translated.';
        ShipmentMethodIdDoesNotMatchAShipmentMethodErr: Label 'The "shipmentMethodId" does not match to a Shipment Method.', Comment = 'shipmentMethodId is a field name and should not be translated.';
        CannotFindOrderErr: Label 'The order cannot be found.';
        DiscountAmountSet: Boolean;
        InvoiceDiscountAmount: Decimal;
        BlankGUID: Guid;
        DocumentDateSet: Boolean;
        DocumentDateVar: Date;
        PostingDateSet: Boolean;
        PostingDateVar: Date;
        HasWritePermission: Boolean;

    local procedure SetCalculatedFields()
    begin
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, Rec."Currency Code");
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
        TempFieldBuffer."Table ID" := Database::"Purchase Order Entity Buffer";
        TempFieldBuffer."Field ID" := FieldNo;
        TempFieldBuffer.Insert();
    end;

    local procedure CheckBuyFromVendorSpecified()
    begin
        if (Rec."Buy-from Vendor No." = '') and
           (Rec."Vendor Id" = BlankGUID)
        then
            Error(BuyFromVendorNotProvidedErr);
    end;

    local procedure CheckPermissions()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        if not PurchaseHeader.ReadPermission() then
            Error(PurchaseOrderPermissionsErr);

        HasWritePermission := PurchaseHeader.WritePermission();
    end;

    local procedure UpdateDiscount()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchCalcDiscByType: Codeunit "Purch - Calc Disc. By Type";
    begin
        if not DiscountAmountSet then begin
            GraphMgtPurchOrderBuffer.RedistributeInvoiceDiscounts(Rec);
            exit;
        end;

        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, Rec."No.");
        PurchCalcDiscByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, PurchaseHeader);
    end;

    local procedure SetDates()
    begin
        if not (DocumentDateSet or PostingDateSet) then
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

        GraphMgtPurchOrderBuffer.PropagateOnModify(Rec, TempFieldBuffer);
        Rec.Find();
    end;

    local procedure GetOrder(var PurchaseHeader: Record "Purchase Header")
    begin
        if not PurchaseHeader.GetBySystemId(Rec.Id) then
            Error(CannotFindOrderErr);
    end;

    local procedure PostInvoice(var PurchaseHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header"): Boolean
    var
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
        OrderNo: Code[20];
        OrderNoSeries: Code[20];
    begin
        LinesInstructionMgt.PurchaseCheckAllLinesHaveQuantityAssigned(PurchaseHeader);
        OrderNo := PurchaseHeader."No.";
        OrderNoSeries := PurchaseHeader."No. Series";
        PurchaseHeader.Receive := true;
        PurchaseHeader.Invoice := true;
        PurchaseHeader.SendToPosting(Codeunit::"Purch.-Post");
        Commit(); // Purch.-Post does not always commit latest purchase invoice header
        PurchInvHeader.SetCurrentKey("Order No.");
        PurchInvHeader.SetRange("Order No.", OrderNo);
        PurchInvHeader.SetRange("Order No. Series", OrderNoSeries);
        PurchInvHeader.SetRange("Pre-Assigned No.", '');
        exit(PurchInvHeader.FindFirst());
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; DocumentId: Guid; ObjectId: Integer; ResultCode: WebServiceActionResultCode)
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(ObjectId);
        ActionContext.AddEntityKey(Rec.FieldNo(Id), DocumentId);
        ActionContext.SetResultCode(ResultCode);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure ReceiveAndInvoice(var ActionContext: WebServiceActionContext)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
        Invoiced: Boolean;
    begin
        GetOrder(PurchaseHeader);
        Invoiced := PostInvoice(PurchaseHeader, PurchInvHeader);
        if Invoiced then
            SetActionResponse(ActionContext, PurchInvAggregator.GetPurchaseInvoiceHeaderId(PurchInvHeader), Page::"APIV2 - Purchase Invoices", WebServiceActionResultCode::Deleted)
        else
            SetActionResponse(ActionContext, PurchaseHeader.SystemId, Page::"APIV2 - Purchase Orders", WebServiceActionResultCode::Updated);
    end;
}
