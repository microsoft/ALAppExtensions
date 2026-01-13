namespace Microsoft.API.V2;

using Microsoft.Integration.Entity;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.Integration.Graph;
using Microsoft.Upgrade;
using System.Upgrade;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using Microsoft.Utilities;
using System.Reflection;

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
    AboutText = 'Manages purchase credit memo documents, exposing vendor details, transaction amounts, addresses, currency, payment terms, and status. Supports full lifecycle operations (GET, POST, PATCH, DELETE) for automating supplier returns, vendor refunds, and accounts payable adjustments in external procurement and finance integrations. Enables seamless synchronization of credit memo data between Business Central and third-party systems.';

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
                field(creditMemoDate; Rec."Document Date")
                {
                    Caption = 'Credit Memo Date';

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
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date';

                    trigger OnValidate()
                    begin
                        DueDateVar := Rec."Due Date";
                        DueDateSet := true;

                        RegisterFieldSet(Rec.FieldNo("Due Date"));
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
                field(vendorCreditMemoNumber; Rec."Vendor Cr. Memo No.")
                {
                    Caption = 'Vendor Credit Memo No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Vendor Cr. Memo No."));
                    end;
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
                field(payToName; Rec."Pay-to Name")
                {
                    Caption = 'Pay-to Name';
                    Editable = false;
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

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Pay-to Address"));
                    end;
                }
                field(payToAddressLine2; Rec."Pay-to Address 2")
                {
                    Caption = 'Pay-to Address Line 2';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Pay-to Address 2"));
                    end;
                }
                field(payToCity; Rec."Pay-to City")
                {
                    Caption = 'Pay-to City';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Pay-to City"));
                    end;
                }
                field(payToCountry; Rec."Pay-to Country/Region Code")
                {
                    Caption = 'Pay-to Country/Region Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Pay-to Country/Region Code"));
                    end;
                }
                field(payToState; Rec."Pay-to County")
                {
                    Caption = 'Pay-to State';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Pay-to County"));
                    end;
                }
                field(payToPostCode; Rec."Pay-to Post Code")
                {
                    Caption = 'Pay-to Post Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Pay-to Post Code"));
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
                        if Rec."Currency Id" = EmptyGuid then
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
                            Rec."Currency Id" := EmptyGuid
                        else begin
                            if not Currency.Get(Rec."Currency Code") then
                                Error(CurrencyCodeDoesNotMatchACurrencyErr);

                            Rec."Currency Id" := Currency.SystemId;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Currency Id"));
                        RegisterFieldSet(Rec.FieldNo("Currency Code"));
                    end;
                }
                field(paymentTermsId; Rec."Payment Terms Id")
                {
                    Caption = 'Payment Terms Id';

                    trigger OnValidate()
                    begin
                        if Rec."Payment Terms Id" = EmptyGuid then
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
                        if Rec."Shipment Method Id" = EmptyGuid then
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
                field(pricesIncludeTax; Rec."Prices Including VAT")
                {
                    Caption = 'Prices Include Tax';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Prices Including VAT"));
                    end;
                }
                field(discountAmount; Rec."Invoice Discount Amount")
                {
                    Caption = 'discountAmount';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Invoice Discount Amount"));
                        DiscountAmountSet := true;
                        PurchaseInvoiceDiscountAmount := Rec."Invoice Discount Amount";
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
                            Rec."Applies-to Doc. Type" := Rec."Applies-to Doc. Type"::" ";
                            Clear(Rec."Applies-to Doc. No.");
                            Clear(PurchaseInvoiceNo);
                            RegisterFieldSet(Rec.FieldNo("Applies-to Doc. Type"));
                            RegisterFieldSet(Rec.FieldNo("Applies-to Doc. No."));
                            exit;
                        end;

                        if not PurchInvAggregator.GetPurchaseInvoiceHeaderFromId(PurchaseInvoiceId, PurchInvHeader) then
                            Error(InvoiceIdDoesNotMatchAnInvoiceErr);

                        Rec."Applies-to Doc. Type" := Rec."Applies-to Doc. Type"::Invoice;
                        Rec."Applies-to Doc. No." := PurchInvHeader."No.";
                        PurchaseInvoiceNo := Rec."Applies-to Doc. No.";
                        RegisterFieldSet(Rec.FieldNo("Applies-to Doc. Type"));
                        RegisterFieldSet(Rec.FieldNo("Applies-to Doc. No."));
                    end;
                }
                field(invoiceNumber; Rec."Applies-to Doc. No.")
                {
                    Caption = 'Invoice No.';

                    trigger OnValidate()
                    begin
                        if PurchaseInvoiceNo <> '' then begin
                            if Rec."Applies-to Doc. No." <> PurchaseInvoiceNo then
                                Error(InvoiceValuesDontMatchErr);
                            exit;
                        end;

                        Rec."Applies-to Doc. Type" := Rec."Applies-to Doc. Type"::Invoice;

                        RegisterFieldSet(Rec.FieldNo("Applies-to Doc. Type"));
                        RegisterFieldSet(Rec.FieldNo("Applies-to Doc. No."));
                    end;
                }
                field(vendorReturnReasonId; Rec."Reason Code Id")
                {
                    Caption = 'Vendor Return Reason Id';

                    trigger OnValidate()
                    begin
                        if Rec."Reason Code Id" = EmptyGuid then
                            Rec."Reason Code" := ''
                        else begin
                            if not ReasonCode.GetBySystemId(Rec."Reason Code Id") then
                                Error(ReasonCodeIdDoesNotMatchAReasonCodeErr);

                            Rec."Reason Code" := ReasonCode.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Reason Code Id"));
                        RegisterFieldSet(Rec.FieldNo("Reason Code"));
                    end;
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = field(Id), "Parent Type" = const("Purchase Credit Memo");
                }
                part(purchaseCreditMemoLines; "APIV2 - Purch. Cr. Memo Lines")
                {
                    Caption = 'Lines';
                    EntityName = 'purchaseCreditMemoLine';
                    EntitySetName = 'purchaseCreditMemoLines';
                    SubPageLink = "Document Id" = field(Id);
                }
                part(pdfDocument; "APIV2 - PDF Document")
                {
                    Caption = 'PDF Document';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'pdfDocument';
                    EntitySetName = 'pdfDocument';
                    SubPageLink = "Document Id" = field(Id), "Document Type" = const("Purchase Credit Memo");
                }
                part(attachments; "APIV2 - Attachments")
                {
                    Caption = 'Attachments';
                    EntityName = 'attachment';
                    EntitySetName = 'attachments';
                    SubPageLink = "Document Id" = field(Id), "Document Type" = const("Purchase Credit Memo");
                }
                part(documentAttachments; "APIV2 - Document Attachments")
                {
                    Caption = 'Document Attachments';
                    EntityName = 'documentAttachment';
                    EntitySetName = 'documentAttachments';
                    SubPageLink = "Document Id" = field(Id), "Document Type" = const("Purchase Credit Memo");
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
        if not Rec.Posted then
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
        if xRec.Id <> Rec.Id then
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
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, Rec."Currency Code");
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
        if (Rec."Buy-from Vendor No." = '') and
           (Rec."Vendor Id" = EmptyGuid)
        then
            Error(BuyFromVendorNotProvidedErr);
    end;

    local procedure SetInvoiceId()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
    begin
        Clear(PurchaseInvoiceId);

        if Rec."Applies-to Doc. No." = '' then
            exit;

        if PurchInvHeader.Get(Rec."Applies-to Doc. No.") then
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
            FilterText := StrSubstNo(PermissionFilterFormatTxt, Rec.Status::Draft, Rec.Status::"In Review");

        if not PurchCrMemoHdr.ReadPermission() then begin
            if FilterText <> '' then
                FilterText += '&';
            FilterText +=
              StrSubstNo(
                PermissionCrMemoFilterformatTxt, Rec.Status::Canceled, Rec.Status::Corrective,
                Rec.Status::Open, Rec.Status::Paid);
        end;

        if FilterText <> '' then begin
            Rec.FilterGroup(2);
            Rec.SetFilter(Status, FilterText);
            Rec.FilterGroup(0);
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

        PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", Rec."No.");
        PurchCalcDiscountByType.ApplyInvDiscBasedOnAmt(PurchaseInvoiceDiscountAmount, PurchaseHeader);
    end;

    local procedure SetDates()
    begin
        if not (DueDateSet or DocumentDateSet or PostingDateSet) then
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

        if DueDateSet then begin
            Rec."Due Date" := DueDateVar;
            RegisterFieldSet(Rec.FieldNo("Due Date"));
        end;

        GraphMgtPurchCrMemo.PropagateOnModify(Rec, TempFieldBuffer);
        Rec.Find();
    end;

    local procedure GetPostedCreditMemo(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    begin
        if not Rec.Posted then
            Error(PostedCreditMemoActionErr);

        if not GraphMgtPurchCrMemo.GetPurchaseCrMemoHeaderFromId(Rec.Id, PurchCrMemoHdr) then
            Error(CannotFindCreditMemoErr);
    end;

    local procedure GetDraftCreditMemo(var PurchaseHeader: Record "Purchase Header")
    begin
        if Rec.Posted then
            Error(DraftCreditMemoActionErr);

        if not PurchaseHeader.GetBySystemId(Rec.Id) then
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
        exit(Rec.Status = Rec.Status::Canceled);
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
        ActionContext.AddEntityKey(Rec.FieldNo(Id), ParamInvoiceId);
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