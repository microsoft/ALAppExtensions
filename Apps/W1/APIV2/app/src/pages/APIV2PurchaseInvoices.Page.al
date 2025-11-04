namespace Microsoft.API.V2;

using Microsoft.Integration.Entity;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.Currency;
using Microsoft.Integration.Graph;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.Utilities;
using System.Reflection;

page 30042 "APIV2 - Purchase Invoices"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Purchase Invoice';
    EntitySetCaption = 'Purchase Invoices';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'purchaseInvoice';
    EntitySetName = 'purchaseInvoices';
    ODataKeyFields = Id;
    PageType = API;
    SourceTable = "Purch. Inv. Entity Aggregate";
    Extensible = false;
    AboutText = 'Manages purchase invoice documents including vendor details, invoice amounts, due dates, payment terms, addresses, and status. Supports full CRUD operations for automating accounts payable, integrating procurement workflows, and enabling financial reporting between Business Central and external systems. Ideal for synchronizing invoice lifecycle data with ERP, procurement, and financial platforms.';

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
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Posting Date"));
                    end;
                }
                field(invoiceDate; Rec."Document Date")
                {
                    Caption = 'Invoice Date';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Document Date"));
                        WorkDate(Rec."Document Date");
                    end;
                }

                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Due Date"));
                    end;
                }
                field(vendorInvoiceNumber; Rec."Vendor Invoice No.")
                {
                    Caption = 'Vendor Invoice No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Vendor Invoice No."));
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
                        if BuyFromVendor."No." <> '' then
                            exit;

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
                    Caption = 'Pay-To Name';
                    Editable = false;
                }
                field(payToContact; Rec."Pay-to Contact")
                {
                    Caption = 'Pay-To Contact';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        if xRec."Pay-to Contact" <> Rec."Pay-to Contact" then
                            RegisterFieldSet(Rec.FieldNo("Pay-to Contact"));
                    end;
                }
                field(payToVendorId; Rec."Pay-to Vendor Id")
                {
                    Caption = 'Pay-To Vendor Id';

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
                    Caption = 'Pay-To Vendor No.';

                    trigger OnValidate()
                    begin
                        if PayToVendor."No." <> '' then
                            exit;

                        if not PayToVendor.Get(Rec."Pay-to Vendor No.") then
                            Error(CouldNotFindPayToVendorErr);

                        Rec."Pay-to Vendor Id" := PayToVendor.SystemId;
                        RegisterFieldSet(Rec.FieldNo("Pay-to Vendor Id"));
                        RegisterFieldSet(Rec.FieldNo("Pay-to Vendor No."));
                    end;
                }
                field(shipToName; Rec."Ship-to Name")
                {
                    Caption = 'Ship-To Name';

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
                    Caption = 'Ship-To Contact';

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
                field(payToAddressLine1; Rec."Pay-to Address")
                {
                    Caption = 'Pay To Address Line 1';
                    Editable = false;
                }
                field(payToAddressLine2; Rec."Pay-to Address 2")
                {
                    Caption = 'Pay To Address Line 2';
                    Editable = false;
                }
                field(payToCity; Rec."Pay-to City")
                {
                    Caption = 'Pay To City';
                    Editable = false;
                }
                field(payToCountry; Rec."Pay-to Country/Region Code")
                {
                    Caption = 'Pay To Country/Region Code';
                    Editable = false;
                }
                field(payToState; Rec."Pay-to County")
                {
                    Caption = 'Pay To State';
                    Editable = false;
                }
                field(payToPostCode; Rec."Pay-to Post Code")
                {
                    Caption = 'Pay To Post Code';
                    Editable = false;
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
                field(orderId; Rec."Order Id")
                {
                    Caption = 'Order Id';
                    Editable = false;
                }
                field(orderNumber; Rec."Order No.")
                {
                    Caption = 'Order No.';
                    Editable = false;
                }
                field(purchaser; Rec."Purchaser Code")
                {
                    Caption = 'Purchaser';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Purchaser Code"));
                    end;
                }
                field(pricesIncludeTax; Rec."Prices Including VAT")
                {
                    Caption = 'Prices Include Tax';

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
                    SubPageLink = "Parent Id" = field(Id), "Parent Type" = const("Purchase Invoice");
                }
                part(purchaseInvoiceLines; "APIV2 - Purchase Invoice Lines")
                {
                    Caption = 'Lines';
                    EntityName = 'purchaseInvoiceLine';
                    EntitySetName = 'purchaseInvoiceLines';
                    SubPageLink = "Document Id" = field(Id);
                }
                part(pdfDocument; "APIV2 - PDF Document")
                {
                    Caption = 'PDF Document';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'pdfDocument';
                    EntitySetName = 'pdfDocument';
                    SubPageLink = "Document Id" = field(Id), "Document Type" = const("Purchase Invoice");
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
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                    Editable = false;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
                part(attachments; "APIV2 - Attachments")
                {
                    Caption = 'Attachments';
                    EntityName = 'attachment';
                    EntitySetName = 'attachments';
                    SubPageLink = "Document Id" = field(Id), "Document Type" = const("Purchase Invoice");
                }
                part(documentAttachments; "APIV2 - Document Attachments")
                {
                    Caption = 'Document Attachments';
                    EntityName = 'documentAttachment';
                    EntitySetName = 'documentAttachments';
                    SubPageLink = "Document Id" = field(Id), "Document Type" = const("Purchase Invoice");
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
            Error(CannotChangeIDErr);

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
        CannotChangeIDErr: Label 'The "id" cannot be changed.', Comment = 'id is a field name and should not be translated.';
        BuyFromVendorNotProvidedErr: Label 'A "vendorNumber" or a "vendorID" must be provided.', Comment = 'vendorNumber and vendorID are field names and should not be translated.';
        CouldNotFindBuyFromVendorErr: Label 'The vendor cannot be found.';
        CouldNotFindPayToVendorErr: Label 'The pay-to vendor cannot be found.';
        CurrencyValuesDontMatchErr: Label 'The currency values do not match to a specific Currency.';
        CurrencyIdDoesNotMatchACurrencyErr: Label 'The "currencyId" does not match to a Currency.', Comment = 'currencyId is a field name and should not be translated.';
        CurrencyCodeDoesNotMatchACurrencyErr: Label 'The "currencyCode" does not match to a Currency.', Comment = 'currencyCode is a field name and should not be translated.';
        BlankGUID: Guid;
        DraftInvoiceActionErr: Label 'The action can be applied to a draft invoice only.';
        CannotFindInvoiceErr: Label 'The invoice cannot be found.';
        DiscountAmountSet: Boolean;
        InvoiceDiscountAmount: Decimal;
        HasWritePermission: Boolean;
        PurchaseInvoicePermissionsErr: Label 'You do not have permissions to read Purchase Invoices.';

    local procedure SetCalculatedFields()
    begin
        Rec.LoadFields("Currency Code");
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

        PurchaseHeader.Get(Rec."Document Type"::Invoice, Rec."No.");
        PurchCalcDiscByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, PurchaseHeader);
    end;

    local procedure ClearCalculatedFields()
    begin
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
        TempFieldBuffer."Table ID" := Database::"Purch. Inv. Entity Aggregate";
        TempFieldBuffer."Field ID" := FieldNo;
        TempFieldBuffer.Insert();
    end;

    local procedure CheckBuyFromVendor()
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
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
        if not PurchaseHeader.ReadPermission() then
            Error(PurchaseInvoicePermissionsErr);

        HasWritePermission := PurchaseHeader.WritePermission();
    end;

    local procedure GetDraftInvoice(var PurchaseHeader: Record "Purchase Header")
    begin
        if Rec.Posted then
            Error(DraftInvoiceActionErr);

        if not PurchaseHeader.GetBySystemId(Rec.Id) then
            Error(CannotFindInvoiceErr);
    end;

    local procedure PostInvoice(var PurchaseHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header")
    var
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
        PreAssignedNo: Code[20];
    begin
        LinesInstructionMgt.PurchaseCheckAllLinesHaveQuantityAssigned(PurchaseHeader);
        PreAssignedNo := PurchaseHeader."No.";
        PurchaseHeader.SendToPosting(Codeunit::"Purch.-Post");
        PurchInvHeader.SETCURRENTKEY("Pre-Assigned No.");
        PurchInvHeader.SetRange("Pre-Assigned No.", PreAssignedNo);
        PurchInvHeader.FindFirst();
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; InvoiceId: Guid)
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Purchase Invoices");
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