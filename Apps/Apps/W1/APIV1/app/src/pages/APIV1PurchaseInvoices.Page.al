namespace Microsoft.API.V1;

using Microsoft.Integration.Entity;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.Currency;
using Microsoft.Integration.Graph;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.Utilities;
using System.Reflection;

page 20042 "APIV1 - Purchase Invoices"
{
    APIVersion = 'v1.0';
    Caption = 'purchaseInvoices', Locked = true;
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'purchaseInvoice';
    EntitySetName = 'purchaseInvoices';
    ODataKeyFields = Id;
    PageType = API;
    SourceTable = "Purch. Inv. Entity Aggregate";
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
                field(invoiceDate; Rec."Document Date")
                {
                    Caption = 'invoiceDate', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Document Date"));
                        WORKDATE(Rec."Document Date"); // TODO: replicate page logic and set other dates appropriately
                    end;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'postingDate', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Posting Date"));
                    end;
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'dueDate', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Due Date"));
                    end;
                }
                field(vendorInvoiceNumber; Rec."Vendor Invoice No.")
                {
                    Caption = 'vendorInvoiceNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Vendor Invoice No."));
                    end;
                }
                field(vendorId; Rec."Vendor Id")
                {
                    Caption = 'vendorId', Locked = true;

                    trigger OnValidate()
                    begin
                        if not BuyFromVendor.GetBySystemId(Rec."Vendor Id") then
                            error(CouldNotFindBuyFromVendorErr);

                        Rec."Buy-from Vendor No." := BuyFromVendor."No.";
                        RegisterFieldSet(Rec.FieldNo("Vendor Id"));
                        RegisterFieldSet(Rec.FieldNo("Buy-from Vendor No."));
                    end;
                }
                field(vendorNumber; Rec."Buy-from Vendor No.")
                {
                    Caption = 'vendorNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        if BuyFromVendor."No." <> '' then
                            exit;

                        if not BuyFromVendor.GET(Rec."Buy-from Vendor No.") then
                            error(CouldNotFindBuyFromVendorErr);

                        Rec."Vendor Id" := BuyFromVendor.SystemId;
                        RegisterFieldSet(Rec.FieldNo("Vendor Id"));
                        RegisterFieldSet(Rec.FieldNo("Buy-from Vendor No."));
                    end;
                }
                field(vendorName; Rec."Buy-from Vendor Name")
                {
                    Caption = 'vendorName', Locked = true;
                    Editable = false;
                }
                field(payToName; Rec."Pay-to Name")
                {
                    Caption = 'payToName', Locked = true;
                    Editable = false;
                }
                field(payToContact; Rec."Pay-to Contact")
                {
                    Caption = 'payToContact', Locked = true;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        if xRec."Pay-to Contact" <> Rec."Pay-to Contact" then
                            RegisterFieldSet(Rec.FieldNo("Pay-to Contact"));
                    end;
                }
                field(payToVendorId; Rec."Pay-to Vendor Id")
                {
                    Caption = 'payToVendorId', Locked = true;

                    trigger OnValidate()
                    begin
                        if not PayToVendor.GetBySystemId(Rec."Pay-to Vendor Id") then
                            error(CouldNotFindPayToVendorErr);

                        Rec."Pay-to Vendor No." := PayToVendor."No.";
                        RegisterFieldSet(Rec.FieldNo("Pay-to Vendor Id"));
                        RegisterFieldSet(Rec.FieldNo("Pay-to Vendor No."));
                    end;
                }
                field(payToVendorNumber; Rec."Pay-to Vendor No.")
                {
                    Caption = 'payToVendorNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        if PayToVendor."No." <> '' then
                            exit;

                        if not PayToVendor.GET(Rec."Pay-to Vendor No.") then
                            error(CouldNotFindPayToVendorErr);

                        Rec."Pay-to Vendor Id" := PayToVendor.SystemId;
                        RegisterFieldSet(Rec.FieldNo("Pay-to Vendor Id"));
                        RegisterFieldSet(Rec.FieldNo("Pay-to Vendor No."));
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
                field(buyFromAddress; BuyFromPostalAddressJSONText)
                {
                    Caption = 'buyFromAddress', Locked = true;
#pragma warning disable AL0667
                    ODataEDMType = 'POSTALADDRESS';
#pragma warning restore
                    ToolTip = 'Specifies the buy-from address of the Purchase Invoice.';

                    trigger OnValidate()
                    begin
                        BuyFromPostalAddressSet := true;
                    end;
                }
                field(payToAddress; PayToPostalAddressJSONText)
                {
                    Caption = 'payToAddress', Locked = true;
#pragma warning disable AL0667
                    ODataEDMType = 'POSTALADDRESS';
#pragma warning restore
                    ToolTip = 'Specifies the pay-to address of the Purchase Invoice.';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        Error(PayToAddressIsReadOnlyErr);
                    end;
                }
                field(shipToAddress; ShipToPostalAddressJSONText)
                {
                    Caption = 'shipToAddress', Locked = true;
#pragma warning disable AL0667
                    ODataEDMType = 'POSTALADDRESS';
#pragma warning restore
                    ToolTip = 'Specifies the ship-to address of the Purchase Invoice.';

                    trigger OnValidate()
                    begin
                        ShipToPostalAddressSet := true;
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

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Prices Including VAT"));
                    end;
                }
                part(purchaseInvoiceLines; "APIV1 - Purchase Invoice Lines")
                {
                    Caption = 'Lines', Locked = true;
                    EntityName = 'purchaseInvoiceLine';
                    EntitySetName = 'purchaseInvoiceLines';
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
                field(discountAppliedBeforeTax; Rec."Discount Applied Before Tax")
                {
                    Caption = 'discountAppliedBeforeTax', Locked = true;
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

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Total Tax Amount"));
                    end;
                }
                field(totalAmountIncludingTax; Rec."Amount Including VAT")
                {
                    Caption = 'totalAmountIncludingTax', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Amount Including VAT"));
                    end;
                }
                field(status; Rec.Status)
                {
                    Caption = 'status', Locked = true;
                    Editable = false;
                }
                field(lastModifiedDateTime; Rec."Last Modified Date Time")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
    begin
        SetCalculatedFields();
        if HasWritePermission then
            PurchInvAggregator.RedistributeInvoiceDiscounts(Rec);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
    begin
        PurchInvAggregator.PropagateOnDelete(Rec);

        exit(false);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
    begin
        CheckBuyFromVendor();
        ProcessBuyFromPostalAddressOnInsert();
        ProcessShipToPostalAddressOnInsert();

        PurchInvAggregator.PropagateOnInsert(Rec, TempFieldBuffer);
        UpdateDiscount();

        SetCalculatedFields();

        PurchInvAggregator.RedistributeInvoiceDiscounts(Rec);

        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
    begin
        if xRec.Id <> Rec.Id then
            error(CannotChangeIDErr);

        ProcessBuyFromPostalAddressOnModify();
        ProcessShipToPostalAddressOnModify();

        PurchInvAggregator.PropagateOnModify(Rec, TempFieldBuffer);
        UpdateDiscount();

        SetCalculatedFields();

        PurchInvAggregator.RedistributeInvoiceDiscounts(Rec);

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
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        LCYCurrencyCode: Code[10];
        CurrencyCodeTxt: Text;
        BuyFromPostalAddressJSONText: Text;
        PayToPostalAddressJSONText: Text;
        ShipToPostalAddressJSONText: Text;
        BuyFromPostalAddressSet: Boolean;
        ShipToPostalAddressSet: Boolean;
        CannotChangeIDErr: Label 'The id cannot be changed.', Locked = true;
        BuyFromVendorNotProvidedErr: Label 'A vendorNumber or a vendorID must be provided.', Locked = true;
        CouldNotFindBuyFromVendorErr: Label 'The vendor cannot be found.', Locked = true;
        CouldNotFindPayToVendorErr: Label 'The pay-to vendor cannot be found.', Locked = true;
        CurrencyValuesDontMatchErr: Label 'The currency values do not match to a specific Currency.', Locked = true;
        CurrencyIdDoesNotMatchACurrencyErr: Label 'The "currencyId" does not match to a Currency.', Locked = true;
        CurrencyCodeDoesNotMatchACurrencyErr: Label 'The "currencyCode" does not match to a Currency.', Locked = true;
        BlankGUID: Guid;
        DraftInvoiceActionErr: Label 'The action can be applied to a draft invoice only.', Locked = true;
        CannotFindInvoiceErr: Label 'The invoice cannot be found.', Locked = true;
        DiscountAmountSet: Boolean;
        InvoiceDiscountAmount: Decimal;
        HasWritePermission: Boolean;
        PurchaseInvoicePermissionsErr: Label 'You do not have permissions to read Purchase Invoices.', Locked = true;
        PayToAddressIsReadOnlyErr: Label 'The "payToAddress" is read-only.', Locked = true;

    local procedure SetCalculatedFields()
    var
        GraphMgtPurchaseInvoice: Codeunit "Graph Mgt - Purchase Invoice";
    begin
        BuyFromPostalAddressJSONText := GraphMgtPurchaseInvoice.BuyFromVendorAddressToJSON(Rec);
        PayToPostalAddressJSONText := GraphMgtPurchaseInvoice.PayToVendorAddressToJSON(Rec);
        ShipToPostalAddressJSONText := GraphMgtPurchaseInvoice.ShipToVendorAddressToJSON(Rec);

        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, Rec."Currency Code");
    end;

    local procedure UpdateDiscount()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
        PurchCalcDiscByType: Codeunit "Purch - Calc Disc. By Type";
    begin
        if Rec.Posted then
            exit;

        if not DiscountAmountSet then begin
            PurchInvAggregator.RedistributeInvoiceDiscounts(Rec);
            exit;
        end;

        PurchaseHeader.GET(Rec."Document Type"::Invoice, Rec."No.");
        PurchCalcDiscByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, PurchaseHeader);
    end;

    local procedure ClearCalculatedFields()
    begin
        CLEAR(BuyFromPostalAddressJSONText);
        CLEAR(PayToPostalAddressJSONText);
        CLEAR(ShipToPostalAddressJSONText);
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
        TempFieldBuffer."Table ID" := DATABASE::"Purch. Inv. Entity Aggregate";
        TempFieldBuffer."Field ID" := FieldNo;
        TempFieldBuffer.insert();
    end;

    local procedure CheckBuyFromVendor()
    begin
        if (Rec."Buy-from Vendor No." = '') and
           (Rec."Vendor Id" = BlankGUID)
        then
            error(BuyFromVendorNotProvidedErr);
    end;

    local procedure CheckPermissions()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::Invoice);
        if not PurchaseHeader.READPERMISSION() then
            error(PurchaseInvoicePermissionsErr);

        HasWritePermission := PurchaseHeader.WRITEPERMISSION();
    end;

    local procedure ProcessBuyFromPostalAddressOnInsert()
    var
        GraphMgtPurchaseInvoice: Codeunit "Graph Mgt - Purchase Invoice";
    begin
        if not BuyFromPostalAddressSet then
            exit;

        GraphMgtPurchaseInvoice.ParseBuyFromVendorAddressFromJSON(BuyFromPostalAddressJSONText, Rec);

        RegisterFieldSet(Rec.FieldNo("Buy-from Address"));
        RegisterFieldSet(Rec.FieldNo("Buy-from Address 2"));
        RegisterFieldSet(Rec.FieldNo("Buy-from City"));
        RegisterFieldSet(Rec.FieldNo("Buy-from Country/Region Code"));
        RegisterFieldSet(Rec.FieldNo("Buy-from Post Code"));
        RegisterFieldSet(Rec.FieldNo("Buy-from County"));
    end;

    local procedure ProcessBuyFromPostalAddressOnModify()
    var
        GraphMgtPurchaseInvoice: Codeunit "Graph Mgt - Purchase Invoice";
    begin
        if not BuyFromPostalAddressSet then
            exit;

        GraphMgtPurchaseInvoice.ParseBuyFromVendorAddressFromJSON(BuyFromPostalAddressJSONText, Rec);

        if xRec."Buy-from Address" <> Rec."Buy-from Address" then
            RegisterFieldSet(Rec.FieldNo("Buy-from Address"));

        if xRec."Buy-from Address 2" <> Rec."Buy-from Address 2" then
            RegisterFieldSet(Rec.FieldNo("Buy-from Address 2"));

        if xRec."Buy-from City" <> Rec."Buy-from City" then
            RegisterFieldSet(Rec.FieldNo("Buy-from City"));

        if xRec."Buy-from Country/Region Code" <> Rec."Buy-from Country/Region Code" then
            RegisterFieldSet(Rec.FieldNo("Buy-from Country/Region Code"));

        if xRec."Buy-from Post Code" <> Rec."Buy-from Post Code" then
            RegisterFieldSet(Rec.FieldNo("Buy-from Post Code"));

        if xRec."Buy-from County" <> Rec."Buy-from County" then
            RegisterFieldSet(Rec.FieldNo("Buy-from County"));
    end;

    local procedure ProcessShipToPostalAddressOnInsert()
    var
        GraphMgtPurchaseInvoice: Codeunit "Graph Mgt - Purchase Invoice";
    begin
        if not ShipToPostalAddressSet then
            exit;

        GraphMgtPurchaseInvoice.ParseShipToVendorAddressFromJSON(ShipToPostalAddressJSONText, Rec);

        Rec."Ship-to Code" := '';
        RegisterFieldSet(Rec.FieldNo("Ship-to Address"));
        RegisterFieldSet(Rec.FieldNo("Ship-to Address 2"));
        RegisterFieldSet(Rec.FieldNo("Ship-to City"));
        RegisterFieldSet(Rec.FieldNo("Ship-to Country/Region Code"));
        RegisterFieldSet(Rec.FieldNo("Ship-to Post Code"));
        RegisterFieldSet(Rec.FieldNo("Ship-to County"));
        RegisterFieldSet(Rec.FieldNo("Ship-to Code"));
    end;

    local procedure ProcessShipToPostalAddressOnModify()
    var
        GraphMgtPurchaseInvoice: Codeunit "Graph Mgt - Purchase Invoice";
        Changed: Boolean;
    begin
        if not ShipToPostalAddressSet then
            exit;

        GraphMgtPurchaseInvoice.ParseShipToVendorAddressFromJSON(ShipToPostalAddressJSONText, Rec);

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

    local procedure GetDraftInvoice(var PurchaseHeader: Record "Purchase Header")
    begin
        if Rec.Posted then
            error(DraftInvoiceActionErr);

        if not PurchaseHeader.GetBySystemId(Rec.Id) then
            error(CannotFindInvoiceErr);
    end;

    local procedure PostInvoice(var PurchaseHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header")
    var
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
        PreAssignedNo: Code[20];
    begin
        LinesInstructionMgt.PurchaseCheckAllLinesHaveQuantityAssigned(PurchaseHeader);
        PreAssignedNo := PurchaseHeader."No.";
        PurchaseHeader.SendToPosting(CODEUNIT::"Purch.-Post");
        PurchInvHeader.SETCURRENTKEY("Pre-Assigned No.");
        PurchInvHeader.SETRANGE("Pre-Assigned No.", PreAssignedNo);
        PurchInvHeader.FINDFIRST();
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; InvoiceId: Guid)
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV1 - Purchase Invoices");
        ActionContext.AddEntityKey(Rec.FieldNo(Id), InvoiceId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Post(var ActionContext: WebServiceActionContext)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
    begin
        GetDraftInvoice(PurchaseHeader);
        PostInvoice(PurchaseHeader, PurchInvHeader);
        SetActionResponse(ActionContext, PurchInvAggregator.GetPurchaseInvoiceHeaderId(PurchInvHeader));
    end;
}
