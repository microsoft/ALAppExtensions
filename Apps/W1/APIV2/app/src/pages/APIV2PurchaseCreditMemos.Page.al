page 30083 "APIV2 - Purchase Credit Memos"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Purchase Credit Memo';
    EntitySetCaption = 'Purchase Credit Memos';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'purchaseCreditMemo';
    EntitySetName = 'purchaseCreditMemos';
    ODataKeyFields = Id;
    PageType = API;
    SourceTable = "Purch. Cr. Memo Entity Buffer";
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
                        if BuyFromVendor."No." <> '' then begin
                            if BuyFromVendor."No." <> "Buy-from Vendor No." then
                                Error(BuyFromVendorValuesDontMatchErr);
                            exit;
                        end;

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
                field(payToVendorId; "Pay-to Vendor Id")
                {
                    Caption = 'Pay-to Vendor Id';

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
                    Caption = 'Pay-to Vendor No.';

                    trigger OnValidate()
                    begin
                        if PayToVendor."No." <> '' then begin
                            if PayToVendor."No." <> "Pay-to Vendor No." then
                                Error(PayToVendorValuesDontMatchErr);
                            exit;
                        end;

                        if not PayToVendor.Get("Pay-to Vendor No.") then
                            Error(CouldNotFindPayToVendorErr);

                        "Pay-to Vendor Id" := PayToVendor.SystemId;
                        RegisterFieldSet(FieldNo("Pay-to Vendor Id"));
                        RegisterFieldSet(FieldNo("Pay-to Vendor No."));
                    end;
                }
                field(payToName; "Pay-to Name")
                {
                    Caption = 'Pay-to Name';
                    Editable = false;
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
                field(payToAddressLine1; "Pay-to Address")
                {
                    Caption = 'Pay-to Address Line 1';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Pay-to Address"));
                    end;
                }
                field(payToAddressLine2; "Pay-to Address 2")
                {
                    Caption = 'Pay-to Address Line 2';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Pay-to Address 2"));
                    end;
                }
                field(payToCity; "Pay-to City")
                {
                    Caption = 'Pay-to City';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Pay-to City"));
                    end;
                }
                field(payToCountry; "Pay-to Country/Region Code")
                {
                    Caption = 'Pay-to Country/Region Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Pay-to Country/Region Code"));
                    end;
                }
                field(payToState; "Pay-to County")
                {
                    Caption = 'Pay-to State';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Pay-to County"));
                    end;
                }
                field(payToPostCode; "Pay-to Post Code")
                {
                    Caption = 'Pay-to Post Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Pay-to Post Code"));
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
                        if "Currency Id" = EmptyGuid then
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
                            "Currency Id" := EmptyGuid
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
                        if "Payment Terms Id" = EmptyGuid then
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
                        if "Shipment Method Id" = EmptyGuid then
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
                field(purchaser; "Purchaser Code")
                {
                    Caption = 'Purchaser';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Purchaser Code"));
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
                field(discountAmount; "Invoice Discount Amount")
                {
                    Caption = 'discountAmount';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Invoice Discount Amount"));
                        DiscountAmountSet := true;
                        PurchaseInvoiceDiscountAmount := "Invoice Discount Amount";
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
                field(invoiceId; PurchaseInvoiceId)
                {
                    Caption = 'Invoice Id';

                    trigger OnValidate()
                    var
                        PurchInvHeader: Record "Purch. Inv. Header";
                        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
                    begin
                        if PurchaseInvoiceId = EmptyGuid then begin
                            "Applies-to Doc. Type" := "Applies-to Doc. Type"::" ";
                            Clear("Applies-to Doc. No.");
                            Clear(PurchaseInvoiceNo);
                            RegisterFieldSet(FieldNo("Applies-to Doc. Type"));
                            RegisterFieldSet(FieldNo("Applies-to Doc. No."));
                            exit;
                        end;

                        if not PurchInvAggregator.GetPurchaseInvoiceHeaderFromId(PurchaseInvoiceId, PurchInvHeader) then
                            Error(InvoiceIdDoesNotMatchAnInvoiceErr);

                        "Applies-to Doc. Type" := "Applies-to Doc. Type"::Invoice;
                        "Applies-to Doc. No." := PurchInvHeader."No.";
                        PurchaseInvoiceNo := "Applies-to Doc. No.";
                        RegisterFieldSet(FieldNo("Applies-to Doc. Type"));
                        RegisterFieldSet(FieldNo("Applies-to Doc. No."));
                    end;
                }
                field(invoiceNumber; "Applies-to Doc. No.")
                {
                    Caption = 'Invoice No.';

                    trigger OnValidate()
                    begin
                        if PurchaseInvoiceNo <> '' then begin
                            if "Applies-to Doc. No." <> PurchaseInvoiceNo then
                                Error(InvoiceValuesDontMatchErr);
                            exit;
                        end;

                        "Applies-to Doc. Type" := "Applies-to Doc. Type"::Invoice;

                        RegisterFieldSet(FieldNo("Applies-to Doc. Type"));
                        RegisterFieldSet(FieldNo("Applies-to Doc. No."));
                    end;
                }
                field(vendorReturnReasonId; "Reason Code Id")
                {
                    Caption = 'Vendor Return Reason Id';

                    trigger OnValidate()
                    begin
                        if "Reason Code Id" = EmptyGuid then
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
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = Field(Id), "Parent Type" = const("Purchase Credit Memo");
                }
                part(purchaseCreditMemoLines; "APIV2 - Purch. Cr. Memo Lines")
                {
                    Caption = 'Lines';
                    EntityName = 'purchaseCreditMemoLine';
                    EntitySetName = 'purchaseCreditMemoLines';
                    SubPageLink = "Document Id" = Field(Id);
                }
                part(pdfDocument; "APIV2 - PDF Document")
                {
                    Caption = 'PDF Document';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'pdfDocument';
                    EntitySetName = 'pdfDocument';
                    SubPageLink = "Document Id" = Field(Id), "Document Type" = const("Purchase Credit Memo");
                }
                part(attachments; "APIV2 - Attachments")
                {
                    Caption = 'Attachments';
                    EntityName = 'attachment';
                    EntitySetName = 'attachments';
                    SubPageLink = "Document Id" = Field(Id), "Document Type" = const("Purchase Credit Memo");
                }
                part(documentAttachments; "APIV2 - Document Attachments")
                {
                    Caption = 'Document Attachments';
                    EntityName = 'documentAttachment';
                    EntitySetName = 'documentAttachments';
                    SubPageLink = "Document Id" = Field(Id), "Document Type" = const("Purchase Credit Memo");
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
                GraphMgtPurchCrMemo.RedistributeCreditMemoDiscounts(Rec);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        GraphMgtPurchCrMemo.PropagateOnDelete(Rec);
        exit(false);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        CheckBuyFromVendorSpecified();
        GraphMgtPurchCrMemo.PropagateOnInsert(Rec, TempFieldBuffer);
        SetDates();
        UpdateDiscount();
        SetCalculatedFields();
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if xRec.Id <> Id then
            Error(CannotChangeIDErr);

        GraphMgtPurchCrMemo.PropagateOnModify(Rec, TempFieldBuffer);
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
        CheckDataUpgrade();
        SetPermissionsFilters();
    end;

    var
        TempFieldBuffer: Record "Field Buffer" temporary;
        BuyFromVendor: Record Vendor;
        PayToVendor: Record Vendor;
        Currency: Record "Currency";
        PaymentTerms: Record "Payment Terms";
        ShipmentMethod: Record "Shipment Method";
        ReasonCode: Record "Reason Code";
        GraphMgtPurchCrMemo: Codeunit "Graph Mgt - Purch. Cr. Memo";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        LCYCurrencyCode: Code[10];
        CurrencyCodeTxt: Text;
        CannotChangeIDErr: Label 'The "id" cannot be changed.', Comment = 'id is a field name and should not be translated.';
        CouldNotFindBuyFromVendorErr: Label 'The buy-from vendor cannot be found.';
        CouldNotFindPayToVendorErr: Label 'The pay-to vendor cannot be found.';
        BuyFromVendorNotProvidedErr: Label 'A "vendorNumber" or a "vendorId" must be provided.', Comment = 'vendorNumber and vendorId are field names and should not be translated.';
        BuyFromVendorValuesDontMatchErr: Label 'The buy-from vendor values do not match to a Vendor.';
        PayToVendorValuesDontMatchErr: Label 'The pay-to vendor values do not match to a Vendor.';
        PermissionFilterFormatTxt: Label '<>%1&<>%2', Locked = true;
        PermissionCrMemoFilterformatTxt: Label '<>%1&<>%2&<>%3&<>%4', Locked = true;
        DiscountAmountSet: Boolean;
        PurchaseInvoiceDiscountAmount: Decimal;
        PurchaseInvoiceId: Guid;
        EmptyGuid: Guid;
        PurchaseInvoiceNo: Code[20];
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
        CancelingCreditMemoFailedInvoiceCreatedAndPostedErr: Label 'Canceling the credit memo failed because of the following error: \\%1\\An invoice is posted.', Comment = '%1 - arbitrary text (an error message)';
        CancelingCreditMemoFailedInvoiceCreatedButNotPostedErr: Label 'Canceling the credit memo failed because of the following error: \\%1\\An invoice is created but not posted.', Comment = '%1 - arbitrary text (an error message)';
        CancelingCreditMemoFailedNothingCreatedErr: Label 'Canceling the credit memo failed because of the following error: \\%1.', Comment = '%1 - arbitrary text (an error message)';
        AlreadyCancelledErr: Label 'The credit memo cannot be cancelled because it has already been canceled.';
        NoLineErr: Label 'Please add at least one line item to the credit memo.';
        ReasonCodeIdDoesNotMatchAReasonCodeErr: Label 'The "vendorReturnReasonId" does not match to a Reason Code.', Comment = 'vendorReturnReasonId is a field name and should not be translated.';
        UpgradeTagDoesNotExistErr: Label 'You must run the data upgrade for this API page before using it. You can run the data upgrade by navigating to API Data Upgrade page and scheduling upgrade for Purchase Credit Memos.';
        DocumentDateSet: Boolean;
        DocumentDateVar: Date;
        PostingDateSet: Boolean;
        PostingDateVar: Date;
        DueDateSet: Boolean;
        DueDateVar: Date;
        HasWritePermissionForDraft: Boolean;

    local procedure SetCalculatedFields()
    begin
        Rec.LoadFields("Applies-to Doc. Type", "Currency Code");
        SetInvoiceId();
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, "Currency Code");
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(PurchaseInvoiceId);
        Clear(PurchaseInvoiceNo);
        Clear(PurchaseInvoiceDiscountAmount);
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
        TempFieldBuffer."Table ID" := Database::"Purch. Cr. Memo Entity Buffer";
        TempFieldBuffer."Field ID" := FieldNo;
        TempFieldBuffer.Insert();
    end;

    local procedure CheckBuyFromVendorSpecified()
    begin
        if ("Buy-from Vendor No." = '') and
           ("Vendor Id" = EmptyGuid)
        then
            Error(BuyFromVendorNotProvidedErr);
    end;

    local procedure SetInvoiceId()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
    begin
        Clear(PurchaseInvoiceId);

        if "Applies-to Doc. No." = '' then
            exit;

        if PurchInvHeader.Get("Applies-to Doc. No.") then
            PurchaseInvoiceId := PurchInvAggregator.GetPurchaseInvoiceHeaderId(PurchInvHeader);
    end;

    local procedure CheckDataUpgrade()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetPurchaseCreditMemoUpgradeTag()) then
            Error(UpgradeTagDoesNotExistErr);
    end;

    local procedure SetPermissionsFilters()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        FilterText: Text;
    begin
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
        if not PurchaseHeader.ReadPermission() then
            FilterText := StrSubstNo(PermissionFilterFormatTxt, Status::Draft, Status::"In Review");

        if not PurchCrMemoHdr.ReadPermission() then begin
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

        HasWritePermissionForDraft := PurchaseHeader.WritePermission();
    end;

    local procedure UpdateDiscount()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchCalcDiscountByType: Codeunit "Purch - Calc Disc. By Type";
    begin
        if not DiscountAmountSet then begin
            GraphMgtPurchCrMemo.RedistributeCreditMemoDiscounts(Rec);
            exit;
        end;

        PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", "No.");
        PurchCalcDiscountByType.ApplyInvDiscBasedOnAmt(PurchaseInvoiceDiscountAmount, PurchaseHeader);
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

        GraphMgtPurchCrMemo.PropagateOnModify(Rec, TempFieldBuffer);
        Find();
    end;

    local procedure GetPostedCreditMemo(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    begin
        if not Posted then
            Error(PostedCreditMemoActionErr);

        if not GraphMgtPurchCrMemo.GetPurchaseCrMemoHeaderFromId(Id, PurchCrMemoHdr) then
            Error(CannotFindCreditMemoErr);
    end;

    local procedure GetDraftCreditMemo(var PurchaseHeader: Record "Purchase Header")
    begin
        if Posted then
            Error(DraftCreditMemoActionErr);

        if not PurchaseHeader.GetBySystemId(Id) then
            Error(CannotFindCreditMemoErr);
    end;

    local procedure CheckCreditMemoCanBeCancelled(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    var
        CancelPostedPurchCrMemo: Codeunit "Cancel Posted Purch. Cr. Memo";
    begin
        if IsCreditMemoCancelled() then
            Error(AlreadyCancelledErr);
        CancelPostedPurchCrMemo.TestCorrectCrMemoIsAllowed(PurchCrMemoHdr);
    end;

    local procedure IsCreditMemoCancelled(): Boolean
    begin
        exit(Status = Status::Canceled);
    end;

    local procedure PostCreditMemo(var PurchaseHeader: Record "Purchase Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    var
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
        PreAssignedNo: Code[20];
    begin
        if not PurchaseHeader.PurchLinesExist() then
            Error(NoLineErr);
        LinesInstructionMgt.PurchaseCheckAllLinesHaveQuantityAssigned(PurchaseHeader);
        PreAssignedNo := PurchaseHeader."No.";
        PurchaseHeader.SendToPosting(Codeunit::"Purch.-Post");
        PurchCrMemoHdr.SetCurrentKey("Pre-Assigned No.");
        PurchCrMemoHdr.SetRange("Pre-Assigned No.", PreAssignedNo);
        PurchCrMemoHdr.FindFirst();
    end;

    local procedure CancelCreditMemo(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseHeader: Record "Purchase Header";
    begin
        GetPostedCreditMemo(PurchCrMemoHdr);
        CheckCreditMemoCanBeCancelled(PurchCrMemoHdr);
        if not Codeunit.Run(Codeunit::"Cancel Posted Purch. Cr. Memo", PurchCrMemoHdr) then begin
            PurchInvHeader.SetRange("Applies-to Doc. No.", PurchCrMemoHdr."No.");
            if not PurchInvHeader.IsEmpty() then
                Error(CancelingCreditMemoFailedInvoiceCreatedAndPostedErr, GetLastErrorText());
            PurchaseHeader.SetRange("Applies-to Doc. No.", PurchCrMemoHdr."No.");
            if not PurchaseHeader.IsEmpty() then
                Error(CancelingCreditMemoFailedInvoiceCreatedButNotPostedErr, GetLastErrorText());
            Error(CancelingCreditMemoFailedNothingCreatedErr, GetLastErrorText());
        end;
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; ParamInvoiceId: Guid)
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Purchase Credit Memos");
        ActionContext.AddEntityKey(FieldNo(Id), ParamInvoiceId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Post(var ActionContext: WebServiceActionContext)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        GetDraftCreditMemo(PurchaseHeader);
        PostCreditMemo(PurchaseHeader, PurchCrMemoHdr);
        SetActionResponse(ActionContext, GraphMgtPurchCrMemo.GetPurchaseCrMemoHeaderId(PurchCrMemoHdr));
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Cancel(var ActionContext: WebServiceActionContext)
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        GetPostedCreditMemo(PurchCrMemoHdr);
        CancelCreditMemo(PurchCrMemoHdr);
        SetActionResponse(ActionContext, GraphMgtPurchCrMemo.GetPurchaseCrMemoHeaderId(PurchCrMemoHdr));
    end;
}