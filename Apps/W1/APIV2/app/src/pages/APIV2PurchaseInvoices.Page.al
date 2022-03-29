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
                field(invoiceDate; "Document Date")
                {
                    Caption = 'Invoice Date';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Document Date"));
                        WORKDATE("Document Date"); // TODO: replicate page logic and set other dates appropriately
                    end;
                }
                field(postingDate; "Posting Date")
                {
                    Caption = 'Posting Date';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Posting Date"));
                    end;
                }
                field(dueDate; "Due Date")
                {
                    Caption = 'Due Date';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Due Date"));
                    end;
                }
                field(vendorInvoiceNumber; "Vendor Invoice No.")
                {
                    Caption = 'Vendor Invoice No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Vendor Invoice No."));
                    end;
                }
                field(vendorId; "Vendor Id")
                {
                    Caption = 'Vendor Id';

                    trigger OnValidate()
                    begin
                        if not BuyFromVendor.GetBySystemId("Vendor Id") then
                            Error(CouldNotFindBuyFromVendorErr);

                        "Buy-from Vendor No." := BuyFromVendor."No.";
                        RegisterFieldSet(FieldNo("Vendor Id"));
                        RegisterFieldSet(FieldNo("Buy-from Vendor No."));
                    end;
                }
                field(vendorNumber; "Buy-from Vendor No.")
                {
                    Caption = 'Vendor No.';

                    trigger OnValidate()
                    begin
                        if BuyFromVendor."No." <> '' then
                            exit;

                        if not BuyFromVendor.Get("Buy-from Vendor No.") then
                            Error(CouldNotFindBuyFromVendorErr);

                        "Vendor Id" := BuyFromVendor.SystemId;
                        RegisterFieldSet(FieldNo("Vendor Id"));
                        RegisterFieldSet(FieldNo("Buy-from Vendor No."));
                    end;
                }
                field(vendorName; "Buy-from Vendor Name")
                {
                    Caption = 'Vendor Name';
                    Editable = false;
                }
                field(payToName; "Pay-to Name")
                {
                    Caption = 'Pay-To Name';
                    Editable = false;
                }
                field(payToContact; "Pay-to Contact")
                {
                    Caption = 'Pay-To Contact';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        if xRec."Pay-to Contact" <> "Pay-to Contact" then
                            RegisterFieldSet(FieldNo("Pay-to Contact"));
                    end;
                }
                field(payToVendorId; "Pay-to Vendor Id")
                {
                    Caption = 'Pay-To Vendor Id';

                    trigger OnValidate()
                    begin
                        if not PayToVendor.GetBySystemId("Pay-to Vendor Id") then
                            Error(CouldNotFindPayToVendorErr);

                        "Pay-to Vendor No." := PayToVendor."No.";
                        RegisterFieldSet(FieldNo("Pay-to Vendor Id"));
                        RegisterFieldSet(FieldNo("Pay-to Vendor No."));
                    end;
                }
                field(payToVendorNumber; "Pay-to Vendor No.")
                {
                    Caption = 'Pay-To Vendor No.';

                    trigger OnValidate()
                    begin
                        if PayToVendor."No." <> '' then
                            exit;

                        if not PayToVendor.Get("Pay-to Vendor No.") then
                            Error(CouldNotFindPayToVendorErr);

                        "Pay-to Vendor Id" := PayToVendor.SystemId;
                        RegisterFieldSet(FieldNo("Pay-to Vendor Id"));
                        RegisterFieldSet(FieldNo("Pay-to Vendor No."));
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
                field(buyFromAddressLine1; "Buy-from Address")
                {
                    Caption = 'Buy-from Address Line 1';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Buy-from Address"));
                    end;
                }
                field(buyFromAddressLine2; "Buy-from Address 2")
                {
                    Caption = 'Buy-from Address Line 2';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Buy-from Address 2"));
                    end;
                }
                field(buyFromCity; "Buy-from City")
                {
                    Caption = 'Buy-from City';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Buy-from City"));
                    end;
                }
                field(buyFromCountry; "Buy-from Country/Region Code")
                {
                    Caption = 'Buy-from Country/Region Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Buy-from Country/Region Code"));
                    end;
                }
                field(buyFromState; "Buy-from County")
                {
                    Caption = 'Buy-from State';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Buy-from County"));
                    end;
                }
                field(buyFromPostCode; "Buy-from Post Code")
                {
                    Caption = 'Buy-from Post Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Buy-from Post Code"));
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
                field(payToAddressLine1; "Pay-to Address")
                {
                    Caption = 'Pay To Address Line 1';
                    Editable = false;
                }
                field(payToAddressLine2; "Pay-to Address 2")
                {
                    Caption = 'Pay To Address Line 2';
                    Editable = false;
                }
                field(payToCity; "Pay-to City")
                {
                    Caption = 'Pay To City';
                    Editable = false;
                }
                field(payToCountry; "Pay-to Country/Region Code")
                {
                    Caption = 'Pay To Country/Region Code';
                    Editable = false;
                }
                field(payToState; "Pay-to County")
                {
                    Caption = 'Pay To State';
                    Editable = false;
                }
                field(payToPostCode; "Pay-to Post Code")
                {
                    Caption = 'Pay To Post Code';
                    Editable = false;
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
                field(pricesIncludeTax; "Prices Including VAT")
                {
                    Caption = 'Prices Include Tax';

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
                    SubPageLink = "Parent Id" = Field(Id), "Parent Type" = const("Purchase Invoice");
                }
                part(purchaseInvoiceLines; "APIV2 - Purchase Invoice Lines")
                {
                    Caption = 'Lines';
                    EntityName = 'purchaseInvoiceLine';
                    EntitySetName = 'purchaseInvoiceLines';
                    SubPageLink = "Document Id" = Field(Id);
                }
                part(pdfDocument; "APIV2 - PDF Document")
                {
                    Caption = 'PDF Document';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'pdfDocument';
                    EntitySetName = 'pdfDocument';
                    SubPageLink = "Document Id" = Field(Id), "Document Type" = const("Purchase Invoice");
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
                }
                part(attachments; "APIV2 - Attachments")
                {
                    Caption = 'Attachments';
                    EntityName = 'attachment';
                    EntitySetName = 'attachments';
                    SubPageLink = "Document Id" = Field(Id), "Document Type" = const("Purchase Invoice");
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
        if xRec.Id <> Id then
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
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, "Currency Code");
    end;

    local procedure UpdateDiscount()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
        PurchCalcDiscByType: Codeunit "Purch - Calc Disc. By Type";
    begin
        if Posted then
            exit;

        if not DiscountAmountSet then begin
            PurchInvAggregator.RedistributeInvoiceDiscounts(Rec);
            exit;
        end;

        PurchaseHeader.Get("Document Type"::Invoice, "No.");
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
        if ("Buy-from Vendor No." = '') and
           ("Vendor Id" = BlankGUID)
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
        if Posted then
            Error(DraftInvoiceActionErr);

        if not PurchaseHeader.GetBySystemId(Id) then
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
    var
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Purchase Invoices");
        ActionContext.AddEntityKey(FieldNo(Id), InvoiceId);
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