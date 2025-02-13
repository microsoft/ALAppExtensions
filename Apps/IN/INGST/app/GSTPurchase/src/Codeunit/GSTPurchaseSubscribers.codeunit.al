// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Purchase;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Vendor;
using Microsoft.Utilities;

codeunit 18080 "GST Purchase Subscribers"
{
    var
        GSTBaseValidation: Codeunit "GST Base Validation";
        GSTARNErr: Label 'Either GST Registration No. or ARN No. should have a value.';
        POSasVendorErr: Label 'POS as Vendor State is only applicable for Registered vendor, current vendor is %1.', Comment = '%1 = GST Vendor Type';
        ReferenceNoErr: Label 'Selected Document No does not exit for Reference Invoice No.';
        SelfInvoiceTypeErr: Label 'GST Vendor Type must be Unregistered, Registered Reverse Charge or Imports for Invoice Type : Self-Invoice.';
        InvoiceTypRegVendErr: Label 'You can select Invoice Type for Registered Vendor in Reverse Charge Transactions only.';
        NonGSTInvTypeErr: Label 'You canNot enter Non-GST Invoice Type for any GST document.';
        LocationErr: Label 'Bill To-Location and Location code must not be same.';
        ReferenceInvoiceErr: Label 'Document is attached with Reference Invoice No. Please delete attached Reference Invoice No.';
        CurrencyCodePOSErr: Label 'Currency code should be blank for POS as Vendor State, current value is %1.', Comment = '%1 = Currency Code';
        TypeErr: Label 'POS as Vendor state is only applicable for G/L Account, the current value is %1.', Comment = '%1 = Type';
        POSGSTStructErr: Label 'You can not select POS Out Of India field without GST Invoice Selection.';
        AppliesToDocErr: Label 'You must remove Applies-to Doc No. before modifying Exempted value.';
        GSTVendorTypeErr: Label 'GST Vendor Type must be %1 or %2.', Comment = '%1 = Import ; %2 = SEZ';
        NGLStructErr: Label 'You can select Non-GST Line field in transaction only for GST related structure.';
        ChargeItemErr: Label 'You cannot select %1 when GST Input Service Distribution is checked.', Comment = '%1 = Type';
        TypeISDErr: Label 'You must select %1 whose %2 is %3 when GST Input Service Distribution is checked.', Comment = '%1 = Type , %2 = GST Group Type , %3 = Service';
        SEZWboeErr: Label '%1 is applicable on for SEZ Vendors.', Comment = '%1= Without Bill Of Entry';
        AggTurnoverErr: Label 'You can change Aggregate Turnover only for Unregistered Vendor.';
        PANErr: Label 'PAN No. must be entered.';
        GSTVendTypeErr: Label 'State code should be empty,if GST Vendor Type %1.', Comment = '%1 = GST Vendor Type';
        VendGSTARNErr: Label ' Either Vendor GST Registration No. or ARN No. should have a value.';
        OrderAddGSTARNErr: Label ' Either GST Registration No. or ARN No. should have a value.';
        PANVendErr: Label 'PAN No. must be entered in Vendor.';
        GSTRegNoErr: Label 'You cannot select GST Reg. No. for selected Vendor Type.';
        IGSTAggTurnoverErr: Label 'Interstate transaction cannot be calculated against Unregistered Vendor whose aggregate turnover is more than 20 Lakhs.';
        POSasGSTGroupRevChargeErr: Label 'POS as Vendor State is not applicable for Reverse Charge';
        GSTUnregisteredNotAppErr: Label 'GST is not applicable for Unregistered Vendors.';
        SamePANErr: Label 'From position 3 to 12 in GST Registration No. should be same as it is in PAN No.';
        GSTPANErr: Label 'Please update GST Registration No. to blank in the record %1 from Order Address.', Comment = '%1 = Order Address Code';
        ShipToOptionErr: Label 'Location Code is mandatory for ship-to Custom Address';
        LengthErr: Label 'The Length of the GST Registration Nos. must be 15.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure SetPaytoVendorFields(var PurchaseHeader: Record "Purchase Header")
    begin
        SetPayToVendorFieldsForPurchase(PurchaseHeader);
    end;

    //CopyDocument 
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopyPostedPurchInvoice', '', false, false)]
    local procedure ValidatePaytoVendorFields(FromPurchInvHeader: Record "Purch. Inv. Header"; var ToPurchaseHeader: Record "Purchase Header")
    var
        PaytoVendor: Record "Vendor";
    begin
        if (FromPurchInvHeader."Buy-from Vendor No." <> FromPurchInvHeader."Pay-to Vendor No.") then
            if PaytoVendor.Get(FromPurchInvHeader."Pay-to Vendor No.") then
                PaytoVendorInfo(ToPurchaseHeader, PaytoVendor);

        ToPurchaseHeader.Validate("Order Address Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopyPurchLineFromPurchLineBuffer', '', false, false)]
    local procedure CallTaxEngineOnAfterCopyPurchLineFromPurchLineBuffer(var ToPurchLine: Record "Purchase Line"; RecalculateLines: Boolean; FromPurchLineBuf: Record "Purchase Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        if (ToPurchLine."Document Type" in [ToPurchLine."Document Type"::"Return Order", ToPurchLine."Document Type"::"Credit Memo"])
            and (FromPurchLineBuf."GST Assessable Value" <> 0) then begin
            ToPurchLine."GST Assessable Value" := 0;
            ToPurchLine."Custom Duty Amount" := 0;
            ToPurchLine.Modify(true);
        end;

        if not RecalculateLines then
            CalculateTax.CallTaxEngineOnPurchaseLine(ToPurchLine, ToPurchLine);
    end;

    // Purchase Line Jurisdiction Type
    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure OnAfterValidateLocationCodePurchase(var Rec: Record "Purchase Line")
    begin
        CheckHeaderLocation(Rec);
        UpdateGSTJurisdictionType(Rec);
    end;

    // Check Fields for Import Vendor
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostLines', '', false, false)]
    local procedure CheckBillofEntryValues(PurchHeader: Record "Purchase Header")
    begin
        if PurchHeader.Invoice then
            CheckBillOfEntry(PurchHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostLines', '', false, false)]
    local procedure CheckPOSAsVendorState(PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    var
        GSTGroup: Record "GST Group";
    begin
        if (PurchHeader."GST Vendor Type" = PurchHeader."GST Vendor Type"::Registered) and (PurchHeader."POS as Vendor State") then
            if GSTGroup.Get(PurchLine."GST Group Code") then
                if GSTGroup."Reverse Charge" then
                    Error(POSasGSTGroupRevChargeErr);
    end;

    //Check Accounting Period
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post (Yes/No)", 'OnAfterConfirmPost', '', false, false)]
    local procedure CheckAccountignPeriod(PurchaseHeader: Record "Purchase Header")
    begin
        CheckPostingDate(PurchaseHeader);
        CheckUnregisteredVendorCondition(PurchaseHeader);
    end;

    //Check Accounting Period - Post Preview
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post (Yes/No)", 'OnRunPreviewOnBeforePurchPostRun', '', false, false)]
    local procedure CheckAccountignPeriodPostPreview(PurchaseHeader: Record "Purchase Header")
    begin
        CheckPostingDate(PurchaseHeader);
        CheckUnregisteredVendorCondition(PurchaseHeader);
    end;

    //Invoice Discount Calculation
    procedure ReCalculateGST(DocumentType: Enum "Purchase Document Type"; DocumentNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
        CalculateTax: Codeunit "Calculate Tax";
    begin
        PurchaseLine.SetCurrentKey("Document Type", "Document No.", "GST Group Code");
        PurchaseLine.SetRange("Document Type", DocumentType);
        PurchaseLine.SetRange("Document No.", DocumentNo);
        PurchaseLine.SetFilter("GST Group Code", '<>%1', '');
        if PurchaseLine.FindSet() then
            repeat
                CalculateTax.CallTaxEngineOnPurchaseLine(PurchaseLine, PurchaseLine);
            until PurchaseLine.Next() = 0;
    end;

    //Purchase Quote to Order
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Quote to Order", 'OnCreatePurchHeaderOnBeforePurchOrderHeaderModify', '', false, false)]
    local procedure CopyQuoteInfotoOrder(var PurchOrderHeader: Record "Purchase Header"; PurchHeader: Record "Purchase Header")
    begin
        PurchOrderHeader."Location GST Reg. No." := PurchHeader."Location GST Reg. No.";
        PurchOrderHeader."Location State Code" := PurchHeader."Location State Code";
    end;

    //Purchase Header Validations
    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterCopyBuyFromVendorFieldsFromVendor', '', false, false)]
    local procedure CopyVendorInf(var PurchaseHeader: Record "Purchase Header"; Vendor: Record Vendor)
    begin
        VendorInfo(PurchaseHeader, Vendor);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnValidatePurchaseHeaderPayToVendorNoOnBeforeCheckDocType', '', false, false)]
    local procedure CopyPayToVendorInfo(var PurchaseHeader: Record "Purchase Header"; Vendor: Record Vendor)
    begin
        PayToVendorInfo(PurchaseHeader, Vendor);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure UpdateGstLocationCode(var Rec: Record "Purchase Header")
    begin
        GstLocationCode(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'GST Vendor Type', false, false)]
    local procedure ValidateGSTVendorType(var Rec: Record "Purchase Header")
    begin
        GSTVendorType(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateEvent', 'Order Address Code', false, false)]
    local procedure ValidateOrderAddressCode(var Rec: Record "Purchase Header")
    begin
        OrderAddressCode(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterCopyBuyFromVendorAddressFieldsFromVendor', '', false, false)]
    local procedure UpdateBuyFromGSTInfo(var PurchaseHeader: Record "Purchase Header"; BuyFromVendor: Record Vendor)
    begin
        BuyFromGSTInfo(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Invoice Type', false, false)]
    local procedure ValidateInvoiceType(var Rec: Record "Purchase Header")
    begin
        InvoiceType(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Location GST Reg. No.', false, false)]
    local procedure ValidateLocationGSTRegNo(var Rec: Record "Purchase Header")
    begin
        LocationGSTRegNo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Bill to-Location(POS)', false, false)]
    local procedure ValidateBilltoLocationPOS(var Rec: Record "Purchase Header")
    begin
        BilltoLocationPOS(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'POS as Vendor State', false, false)]
    local procedure ValidatePOSVedorState(var Rec: Record "Purchase Header")
    begin
        POSVendorState(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'POS Out Of India', false, false)]
    local procedure ValidatePOSoutIndia(var Rec: Record "Purchase Header")
    begin
        POSOutIndia(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Without Bill Of Entry', false, false)]
    local procedure ValidateWithoutBillOfEntry(var Rec: Record "Purchase Header")
    begin
        WithoutBillOfEntry(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Order Address Code', false, false)]
    local procedure AfterValidateOrderAddressCode(var Rec: Record "Purchase Header")
    begin
        AfterOrderAddressCode(Rec);
    end;

    //PurchaseLine Validations
    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'GST Group Code', false, false)]
    local procedure ValidateGSTGroupCode(var Rec: Record "Purchase Line")
    begin
        GSTGroupCode(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Exempted', false, false)]
    local procedure ValidateExempted(var Rec: Record "Purchase Line")
    begin
        Exempted(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Custom Duty Amount', false, false)]
    local procedure ValidateCustomDutyAmount(var Rec: Record "Purchase Line")
    begin
        CustomDutyAmount(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Source Document No.', false, false)]
    local procedure ValidateSourceDocumentNo(var Rec: Record "Purchase Line")
    begin
        Rec.TestField(Supplementary);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Source Document Type', false, false)]
    local procedure ValidateSourceDocumentType(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line")
    begin
        if Rec."Source Document Type" <> xRec."Source Document Type" then
            Rec."Source Document No." := '';
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'GST Assessable Value', false, false)]
    local procedure ValidateGSTAssessableValue(var Rec: Record "Purchase Line")
    begin
        GSTAssessableValue(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Non-GST Line', false, false)]
    local procedure ValidateNONGSTLine(var Rec: Record "Purchase Line")
    begin
        NONGSTLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'GST Reverse Charge', false, false)]
    local procedure ValidateGSTReverseCharge(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        GetPurcasehHeader(PurchaseHeader, Rec);
        if (xRec."GST Reverse Charge") and not (Rec."GST Reverse Charge") then
            if (PurchaseHeader."GST Vendor Type" = PurchaseHeader."GST Vendor Type"::Import) and (PurchaseHeader."Invoice Type" <> PurchaseHeader."Invoice Type"::"Self Invoice") then
                PurchaseHeader.TestField("Invoice Type", PurchaseHeader."Invoice Type"::" ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Supplementary', false, false)]
    local procedure ValidateSupplementary(var Rec: Record "Purchase Line")
    begin
        Supplementary(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignGLAccountValues', '', false, false)]
    local procedure AssignGLAccValue(var Purchline: Record "Purchase Line"; GLAccount: Record "G/L Account")
    begin
        GLAccValue(Purchline, GLAccount);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure AssignItemValue(var Purchline: Record "Purchase Line"; Item: Record Item)
    begin
        ItemValue(Purchline, Item);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignFixedAssetValues', '', false, false)]
    local procedure AssignFAValue(var Purchline: Record "Purchase Line"; FixedAsset: Record "Fixed Asset")
    begin
        FAValue(Purchline, FixedAsset);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignItemChargeValues', '', false, false)]
    local procedure AssignItemChargeValue(var Purchline: Record "Purchase Line"; ItemCharge: Record "Item Charge")
    begin
        ItemChargeValue(Purchline, ItemCharge);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignResourceValues', '', false, false)]
    local procedure AssignResourceValue(var PurchaseLine: Record "Purchase Line"; Resource: Record Resource)
    begin
        ResourceValue(PurchaseLine, Resource);
    end;

    // Vendor Subscribers
    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterValidateEvent', 'GST Registration No.', false, false)]
    local procedure ValidateVendGSTRegistrationNo(var Rec: Record Vendor)
    begin
        if Rec."Govt. Undertaking" then
            CheckGSTRegistrationLength(Rec."GST Registration No.")
        else
            vendGSTRegistrationNo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterValidateEvent', 'GST Vendor Type', false, false)]
    local procedure ValidateVendGSTVEndorType(var Rec: Record Vendor)
    begin
        if Rec."Govt. Undertaking" then
            CheckGSTRegistrationLength(Rec."GST Registration No.")
        else
            GSTVendorType(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterValidateEvent', 'Associated Enterprises', false, false)]
    local procedure ValidateAssociatedEnterprises(var Rec: Record Vendor)
    begin
        if Rec."Associated Enterprises" then
            Rec.TestField("GST Vendor Type", "GST Vendor Type"::Import);
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterValidateEvent', 'Aggregate Turnover', false, false)]
    local procedure ValidateAggregateTurnover(var Rec: Record Vendor)
    begin
        if Rec."GST Vendor Type" <> Rec."GST Vendor Type"::Unregistered then
            Error(AggTurnoverErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterValidateEvent', 'ARN No.', false, false)]
    local procedure ValidateARNNo(var Rec: Record Vendor)
    begin
        VendARNNo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterValidateEvent', 'State Code', false, false)]
    local procedure ValidateVendStateCode(var Rec: Record Vendor)
    begin
        VendStateCode(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterValidateEvent', 'P.A.N. No.', false, false)]
    local procedure ValidateVendPANNo(var Rec: Record Vendor; var xRec: Record Vendor)
    begin
        ValidateVendorPANNo(Rec);
    end;

    //Order Address Validation
    [EventSubscriber(ObjectType::Table, Database::"Order Address", 'OnAfterValidateEvent', 'State', false, false)]
    local procedure ValidateOrderaddressState(var Rec: Record "Order Address")
    begin
        OrderaddressState(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Order Address", 'OnAfterValidateEvent', 'GST Registration No.', false, false)]
    local procedure ValidateOrderAddressGSTRegistrationNo(var Rec: Record "Order Address")
    begin
        OrderAddressGSTRegistrationNo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Order Address", 'OnAfterValidateEvent', 'ARN No.', false, false)]
    local procedure ValidateOrderAssressARNNo(var Rec: Record "Order Address")
    begin
        OrderAddressARNNo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Currency Factor', false, false)]
    local procedure OnValidateCurrencyCode(var Rec: Record "Purchase Header")
    var
        GSTBaseValidation: Codeunit "GST Base Validation";
    begin
        GSTBaseValidation.CallTaxEngineOnPurchHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Order Address Code', false, false)]
    local procedure OnValidateOrderAddressCode(var Rec: Record "Purchase Header")
    var
        GSTBaseValidation: Codeunit "GST Base Validation";
    begin
        GSTBaseValidation.CallTaxEngineOnPurchHeader(Rec);
    end;

    //Blanket Order to Purchase Order
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Blanket Purch. Order to Order", 'OnBeforePurchOrderHeaderModify', '', false, false)]
    local procedure OnBeforePurchOrderHeaderModify(var PurchOrderHeader: Record "Purchase Header"; BlanketOrderPurchHeader: Record "Purchase Header")
    begin
        PurchOrderHeader."Location GST Reg. No." := BlanketOrderPurchHeader."Location GST Reg. No.";
        ValidateLocationGSTRegNo(PurchOrderHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order", 'OnAfterCalculateCurrentShippingAndPayToOption', '', false, false)]
    local procedure OnAfterCalculateCurrentShippingAndPayToOptionforOrder(var ShipToOptions: Option "Default (Company Address)",Location,"Customer Address","Custom Address"; PurchaseHeader: Record "Purchase Header")
    begin
        CalculateAsPerShipToOptionforOrder(ShipToOptions, PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Invoice", 'OnAfterCalculateCurrentShippingAndPayToOption', '', false, false)]
    local procedure OnAfterCalculateCurrentShippingAndPayToOptionforInvoice(var ShipToOptions: Option "Default (Company Address)",Location,"Custom Address"; PurchaseHeader: Record "Purchase Header")
    begin
        CalculateAsPerShipToOptionforQuoteAndInvoice(ShipToOptions, PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Quote", 'OnAfterCalculateCurrentShippingAndPayToOption', '', false, false)]
    local procedure OnAfterCalculateCurrentShippingAndPayToOptionforInvoiceforQuote(var ShipToOptions: Option "Default (Company Address)",Location,"Custom Address"; PurchaseHeader: Record "Purchase Header")
    begin
        CalculateAsPerShipToOptionforQuoteAndInvoice(ShipToOptions, PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Invoice", 'OnBeforeActionEvent', 'Preview', false, false)]
    local procedure OnBeforePreviewActionEvent(Rec: Record "Purchase Header")
    begin
        ValidateCurrentShippingToOptionForQuoteAndInvoice(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Invoice", 'OnBeforeActionEvent', 'Post', false, false)]
    local procedure OnBeforePostActionEvent(Rec: Record "Purchase Header")
    begin
        ValidateCurrentShippingToOptionForQuoteAndInvoice(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Invoice", 'OnBeforeActionEvent', 'PostAndNew', false, false)]
    local procedure OnBeforePostAndNewActionEvent(Rec: Record "Purchase Header")
    begin
        ValidateCurrentShippingToOptionForQuoteAndInvoice(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Invoice", 'OnBeforeActionEvent', 'PostAndPrint', false, false)]
    local procedure OnBeforePostAndPrintActionEvent(Rec: Record "Purchase Header")
    begin
        ValidateCurrentShippingToOptionForQuoteAndInvoice(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order", 'OnBeforeActionEvent', 'Preview', false, false)]
    local procedure OnBeforePreviewActionEventForOrder(Rec: Record "Purchase Header")
    begin
        ValidateCurrentShippingToOptionForOrder(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order", 'OnBeforeActionEvent', 'Post', false, false)]
    local procedure OnBeforePostActionEventForOrder(Rec: Record "Purchase Header")
    begin
        ValidateCurrentShippingToOptionForOrder(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order", 'OnBeforeActionEvent', 'PostAndNew', false, false)]
    local procedure OnBeforePostAndNewActionEventForOrder(Rec: Record "Purchase Header")
    begin
        ValidateCurrentShippingToOptionForOrder(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order", 'OnBeforeActionEvent', 'Post and &Print', false, false)]
    local procedure OnBeforePostAndPrintActionEventForOrder(Rec: Record "Purchase Header")
    begin
        ValidateCurrentShippingToOptionForOrder(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Quote", 'OnBeforeActionEvent', 'MakeOrder', false, false)]
    local procedure OnBeforemakeOrderActionEventForQuote(Rec: Record "Purchase Header")
    begin
        ValidateCurrentShippingToOptionForOrder(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'GST Group Code', false, false)]
    local procedure OnAfterValidateGSTGroup(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line")
    begin
        if Rec."GST Group Code" = '' then
            exit;

        CalculateTaxOnPurchase(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'GST Credit', false, false)]
    local procedure OnAfterValidateGSTCredit(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line")
    begin
        if Rec."GST Credit" = Rec."GST Credit"::" " then
            exit;

        CalculateTaxOnPurchase(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'HSN/SAC Code', false, false)]
    local procedure OnAfterValidateHSNSACCode(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line")
    begin
        if (Rec."GST Group Code" = '') and (Rec."HSN/SAC Code" = '') then
            exit;

        CalculateTaxOnPurchase(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Header", 'OnBeforCheckIfPurchaseInvoiceFullyOpen', '', false, false)]
    local procedure OnBeforCheckIfPurchaseInvoiceFullyOpen(var PurchInvHeader: Record "Purch. Inv. Header"; var FullyOpen: Boolean; var IsHandled: Boolean)
    var
        GSTStatistics: Codeunit "GST Statistics";
        GSTAmount: Decimal;
    begin
        IsHandled := true;
        GSTStatistics.GetStatisticsPostedPurchInvAmount(PurchInvHeader, GSTAmount);
        PurchInvHeader.CalcFields("Amount Including VAT", "Remaining Amount");
        FullyOpen := (PurchInvHeader."Amount Including VAT" + GSTAmount) = PurchInvHeader."Remaining Amount";
    end;

    local procedure CalculateTaxOnPurchase(PurchaseLine: Record "Purchase Line"; xPurchaseLine: Record "Purchase Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CalculateTax.CallTaxEngineOnPurchaseLine(PurchaseLine, xPurchaseLine);
    end;

    local procedure CalculateAsPerShipToOptionforQuoteAndInvoice(var ShipToOptions: Option "Default (Company Address)",Location,"Custom Address"; PurchaseHeader: Record "Purchase Header")
    var
        Location: Record Location;
    begin
        if Location.Get(PurchaseHeader."Location Code") then
            if IsShipToAddressEqualToCustomAddress(PurchaseHeader, Location) then
                ShipToOptions := ShipToOptions::"Custom Address"
            else
                ShipToOptions := ShipToOptions::Location;
    end;

    local procedure ValidateCurrentShippingToOptionForQuoteAndInvoice(PurchaseHeader: Record "Purchase Header")
    var
        Location: Record Location;
        ShipToOptions: Option "Default (Company Address)",Location,"Custom Address";
    begin
        if Location.Get(PurchaseHeader."Location Code") then begin
            if IsShipToAddressEqualToCustomAddress(PurchaseHeader, Location) then
                ShipToOptions := ShipToOptions::"Custom Address"
            else
                ShipToOptions := ShipToOptions::Location;
        end
        else
            if PurchaseHeader.ShipToAddressEqualsCompanyShipToAddress() then
                ShipToOptions := ShipToOptions::"Default (Company Address)"
            else
                ShipToOptions := ShipToOptions::"Custom Address";

        ValidateLocationCodeForShiptoCustomAddForQuoteAndInvoice(PurchaseHeader, ShipToOptions);
    end;

    local procedure ValidateCurrentShippingToOptionForOrder(PurchaseHeader: Record "Purchase Header")
    var
        Location: Record Location;
        ShipToOptions: Option "Default (Company Address)",Location,"Customer Address","Custom Address";
    begin
        if Location.Get(PurchaseHeader."Location Code") then begin
            if IsShipToAddressEqualToCustomAddress(PurchaseHeader, Location) then
                ShipToOptions := ShipToOptions::"Custom Address"
            else
                ShipToOptions := ShipToOptions::Location;
        end
        else
            if PurchaseHeader.ShipToAddressEqualsCompanyShipToAddress() then
                ShipToOptions := ShipToOptions::"Default (Company Address)"
            else
                ShipToOptions := ShipToOptions::"Custom Address";

        ValidateLocationCodeForShiptoCustomAddForOrder(PurchaseHeader, ShipToOptions);
    end;

    local procedure CalculateAsPerShipToOptionforOrder(var ShipToOptions: Option "Default (Company Address)",Location,"Customer Address","Custom Address"; PurchaseHeader: Record "Purchase Header")
    var
        Location: Record Location;
    begin
        if Location.Get(PurchaseHeader."Location Code") then
            if IsShipToAddressEqualToCustomAddress(PurchaseHeader, Location) then
                ShipToOptions := ShipToOptions::"Custom Address"
            else
                ShipToOptions := ShipToOptions::Location;
    end;

    local procedure IsShipToAddressEqualToCustomAddress(PurchaseHeader: Record "Purchase Header"; Location: Record Location): Boolean
    begin
        exit(
          (PurchaseHeader."Ship-to Address" <> Location.Address) and
          (PurchaseHeader."Ship-to Name" <> Location.Name));
    end;

    //Order Address Validation - Definition
    local procedure OrderaddressState(var OrderAddress: Record "Order Address")
    var
        Vendor: Record Vendor;
    begin
        if OrderAddress.State = '' then
            OrderAddress."GST Registration No." := '';

        Vendor.Get(OrderAddress."Vendor No.");
        if Vendor."GST Vendor Type" <> Vendor."GST Vendor Type"::Exempted then
            OrderAddress."GST Registration No." := '';

        if Vendor."GST Vendor Type" = Vendor."GST Vendor Type"::Import then
            OrderAddress.TestField(State, '')
        else
            if Vendor."GST Vendor Type" = Vendor."GST Vendor Type"::Unregistered then
                OrderAddress.TestField(State);

        if Vendor."GST Vendor Type" <> Vendor."GST Vendor Type"::Import then
            Vendor."Associated Enterprises" := false;
    end;

    local procedure OrderAddressGSTRegistrationNo(var OrderAddress: Record "Order Address")
    var
        Vendor: Record Vendor;
    begin
        OrderAddress.TestField(State);
        OrderAddress.TestField(Address);

        Vendor.Get(OrderAddress."Vendor No.");
        if Vendor."P.A.N. No." <> '' then
            GSTBaseValidation.CheckGSTRegistrationNo(OrderAddress.State, OrderAddress."GST Registration No.", Vendor."P.A.N. No.")
        else
            if OrderAddress."GST Registration No." <> '' then
                Error(PANvendErr);

        if (OrderAddress."GST Registration No." <> '') or (OrderAddress."ARN No." <> '') then
            if Vendor."GST Vendor Type" in [Vendor."GST Vendor Type"::Unregistered, Vendor."GST Vendor Type"::Import] then
                Error(GSTRegNoErr);

        if (not IsImportUnregisteredVendor(Vendor)) and (OrderAddress."ARN No." = '') then
            OrderAddress.TestField("GST Registration No.");
    end;

    local procedure OrderAddressARNNo(var OrderAddress: Record "Order Address")
    var
        Vendor: Record Vendor;
    begin
        Vendor.Get(OrderAddress."Vendor No.");
        if (not IsImportUnregisteredVendor(Vendor)) and (OrderAddress."GST Registration No." = '') then
            OrderAddress.TestField("ARN No.");
    end;

    local procedure IsImportUnregisteredVendor(Vendor: Record Vendor): Boolean
    begin
        if (Vendor."GST Vendor Type" in [Vendor."GST Vendor Type"::Import, Vendor."GST Vendor Type"::Unregistered]) then
            exit(true);
    end;

    //Purchase Header validations - Definition
    local procedure AfterOrderAddressCode(var PurchaseHeader: Record "Purchase Header")
    var
        Vendor: Record Vendor;
        DocTypeEnum: Enum "Document Type Enum";
    begin
        Vendor.Get(PurchaseHeader."Pay-to Vendor No.");
        DocTypeEnum := PurchaseHeaderDocumentType2DocumentTypeEnum(PurchaseHeader."Document Type");
        PurchaseHeader."Vendor GST Reg. No." := Vendor."GST Registration No.";
        CheckReferenceInvoiceNo(DocTypeEnum, PurchaseHeader."No.", PurchaseHeader."Buy-from Vendor No.");
        PurchaseHeader."POS Out Of India" := false;
    end;

    local procedure BuyFromGSTInfo(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseHeader."GST Order Address State" := '';
        PurchaseHeader."Order Address GST Reg. No." := '';
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                PurchaseLine."Order Address Code" := PurchaseHeader."Order Address Code";
                PurchaseLine."Buy-From GST Registration No" := PurchaseHeader."Vendor GST Reg. No.";
                PurchaseLine.Modify()
            until PurchaseLine.Next() = 0;
    end;

    local procedure OrderAddressCode(var PurchaseHeader: Record "Purchase Header")
    var
        OrderAddress: Record "Order Address";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        if PurchaseHeader."Order Address Code" <> '' then begin
            OrderAddress.Get(PurchaseHeader."Buy-from Vendor No.", PurchaseHeader."Order Address Code");
            if PurchaseHeader."GST Vendor Type" in ["GST Vendor Type"::Registered, "GST Vendor Type"::Composite, "GST Vendor Type"::SEZ, "GST Vendor Type"::Exempted] then
                if (OrderAddress."GST Registration No." = '') and (OrderAddress."ARN No." = '') then
                    Error(OrderAddGSTARNErr);

            UpdateOrderAddressValues(PurchaseHeader, OrderAddress);
            PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
            PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
            if PurchaseHeader."GST Vendor Type" = "GST Vendor Type"::Unregistered then
                PurchaseHeader.TestField("GST Order Address State");

            if PurchaseHeader."GST Vendor Type" in ["GST Vendor Type"::Registered, "GST Vendor Type"::Composite, "GST Vendor Type"::SEZ, "GST Vendor Type"::Exempted] then
                if PurchaseHeader."Vendor GST Reg. No." = '' then
                    if Vendor.Get(PurchaseHeader."Buy-from Vendor No.") and (Vendor."ARN No." = '') then
                        Error(VendGSTARNErr);

            if PurchaseLine.FindSet() then
                repeat
                    PurchaseLine."Order Address Code" := PurchaseHeader."Order Address Code";
                    PurchaseLine."Buy-From GST Registration No" := PurchaseHeader."Order Address GST Reg. No.";
                    UpdateGSTJurisdictionType(PurchaseLine);
                    PurchaseLine.Modify()
                until PurchaseLine.Next() = 0;
        end else
            UpdateBuyFromVendorState(PurchaseHeader);
    end;

    local procedure UpdateOrderAddressValues(var PurchaseHeader: Record "Purchase Header"; OrderAddress: Record "Order Address")
    begin
        PurchaseHeader."GST Order Address State" := OrderAddress.State;
        PurchaseHeader.State := OrderAddress.State;
        PurchaseHeader."Order Address GST Reg. No." := OrderAddress."GST Registration No.";
        PurchaseHeader.Modify();
    end;

    local procedure UpdateBuyFromVendorState(var PurchaseHeader: Record "Purchase Header")
    var
        Vendor: Record Vendor;
        PurchaseLine: Record "Purchase Line";
    begin
        if not Vendor.Get(PurchaseHeader."Buy-from Vendor No.") then
            exit;

        if PurchaseHeader.State = Vendor."State Code" then
            exit;

        PurchaseHeader.State := Vendor."State Code";
        PurchaseHeader.Modify();

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetFilter(Type, '<>%1', PurchaseLine.Type::" ");
        if PurchaseLine.FindSet() then
            repeat
                UpdateGSTJurisdictionType(PurchaseLine);
                PurchaseLine.Modify();
            until PurchaseLine.Next() = 0;
    end;

    local procedure GSTVendorType(var PurchaseHeader: Record "Purchase Header")
    var
        Vendor: Record Vendor;
    begin
        Vendor.Get(PurchaseHeader."Buy-from Vendor No.");
        PurchaseHeader.TestField("GST Vendor Type", Vendor."GST Vendor Type");
        if PurchaseHeader."GST Vendor Type" in ["GST Vendor Type"::Registered, "GST Vendor Type"::Composite, "GST Vendor Type"::Exempted, "GST Vendor Type"::SEZ] then
            if (Vendor."GST Registration No." = '') and (Vendor."ARN No." = '') then
                Error(GSTARNErr);

        if PurchaseHeader."POS as Vendor State" then
            if not (PurchaseHeader."GST Vendor Type" = "GST Vendor Type"::Registered) then
                Error(POSasVendorErr, PurchaseHeader."GST Vendor Type");
    end;

    local procedure InvoiceType(var PurchaseHeader: Record "Purchase Header")
    begin
        if PurchaseHeader."Invoice Type" = PurchaseHeader."Invoice Type"::"Non-GST" then
            if PurchaseHeader."GST Invoice" then
                Error(NonGSTInvTypeErr);

        if PurchaseHeader."Invoice Type" = PurchaseHeader."Invoice Type"::"Self Invoice" then
            if not (PurchaseHeader."GST Vendor Type" In [
                PurchaseHeader."GST Vendor Type"::Unregistered,
                PurchaseHeader."GST Vendor Type"::Import]) and
                not (CheckReverseChargeGSTRegistered(PurchaseHeader))
            then
                Error(SelfInvoiceTypeErr);

        CheckReverseChargeGSTRegistered(PurchaseHeader);

        if PurchaseHeader."Invoice Type" = PurchaseHeader."Invoice Type"::Supplementary then
            SetSupplementaryInLine(PurchaseHeader."Document Type", PurchaseHeader."No.", true)
        else
            SetSupplementaryInLine(PurchaseHeader."Document Type", PurchaseHeader."No.", false);

        if PurchaseHeader."Reference Invoice No." <> '' then
            if not (PurchaseHeader."Invoice Type" in [PurchaseHeader."Invoice Type"::"Debit Note", PurchaseHeader."Invoice Type"::Supplementary]) then
                Error(ReferenceNoErr);
    end;

    local procedure CheckReverseChargeGSTRegistered(var PurchaseHeader: Record "Purchase Header"): Boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if (PurchaseHeader."GST Vendor Type" = PurchaseHeader."GST Vendor Type"::Registered) and
            not (PurchaseHeader."Invoice Type" in [PurchaseHeader."Invoice Type"::" ", PurchaseHeader."Invoice Type"::"Non-GST"])
        then begin
            PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
            PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
            PurchaseLine.SetRange("GST Reverse Charge", true);
            if not PurchaseLine.IsEmpty() then
                exit(true);

            Error(InvoiceTypRegVendErr);
        end;
    end;

    local procedure SetSupplementaryInLine(DocumentType: Enum "Purchase Document Type"; DocumentNo: Code[20]; Supplementary: Boolean)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", DocumentType);
        PurchaseLine.SetRange("Document No.", DocumentNo);
        if PurchaseLine.FindSet(true, false) then
            repeat
                PurchaseLine.Supplementary := Supplementary;
                PurchaseLine.Modify(true);
            until PurchaseLine.Next() = 0;
    end;

    local procedure LocationGSTRegNo(var PurchaseHeader: Record "Purchase Header")
    var
        GSTRegistrationNos: Record "GST Registration Nos.";
        DocTypeEnum: Enum "Document Type Enum";
    begin
        PurchaseHeader.TestField(Status, PurchaseHeader.Status::Open);
        if not PurchaseHeader."POS as Vendor State" then
            if GSTRegistrationNos.Get(PurchaseHeader."Location GST Reg. No.") then begin
                PurchaseHeader."Location State Code" := GSTRegistrationNos."State Code";
                PurchaseHeader."GST Input Service Distribution" := GSTRegistrationNos."Input Service Distributor";
            end else begin
                PurchaseHeader."Location State Code" := '';
                PurchaseHeader."GST Input Service Distribution" := false;
            end;

        if PurchaseHeader."POS as Vendor State" then
            if PurchaseHeader."Order Address Code" <> '' then
                PurchaseHeader."Location State Code" := PurchaseHeader."GST Order Address State"
            else
                PurchaseHeader."Location State Code" := PurchaseHeader.State;

        DocTypeEnum := PurchaseHeaderDocumentType2DocumentTypeEnum(PurchaseHeader."Document Type");
        CheckReferenceInvoiceNo(DocTypeEnum, PurchaseHeader."No.", PurchaseHeader."Buy-from Vendor No.");
        PurchaseHeader."POS Out Of India" := false;
    end;

    local procedure CheckReferenceInvoiceNo(DocType: Enum "Document Type Enum"; DocNo: Code[20]; BuyFromVendNo: Code[20])
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
    begin
        ReferenceInvoiceNo.SetRange("Document No.", DocNo);
        ReferenceInvoiceNo.SetRange("Document Type", DocType);
        ReferenceInvoiceNo.SetRange("Source No.", BuyFromVendNo);
        ReferenceInvoiceNo.SetRange(Verified, true);
        if not ReferenceInvoiceNo.IsEmpty() then
            Error(ReferenceInvoiceErr);
    end;

    local procedure BilltoLocationPOS(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        Location: Record Location;
    begin
        if (PurchaseHeader."Bill to-Location(POS)" <> '') and (PurchaseHeader."Bill to-Location(POS)" = PurchaseHeader."Location Code") then
            Error(LocationErr);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseHeader."Bill to-Location(POS)" = '' then begin
            PurchaseHeader.TestField("Location Code");
            Location.Get(PurchaseHeader."Location Code");
        end else
            Location.Get(PurchaseHeader."Bill to-Location(POS)");

        PurchaseHeader."Location GST Reg. No." := Location."GST Registration No.";
        PurchaseHeader."Location State Code" := Location."State Code";
        PurchaseHeader."GST Input Service Distribution" := Location."GST Input Service Distributor";
        if PurchaseLine.FindSet() then
            repeat
                PurchaseLine."Bill to-Location(POS)" := PurchaseHeader."Bill to-Location(POS)";
                UpdateCurrGSTJurisdictionType(PurchaseHeader, PurchaseLine);
                PurchaseLine.Modify();
            until PurchaseLine.Next() = 0;

        if PurchaseHeader."POS as Vendor State" then
            if PurchaseHeader."Order Address Code" <> '' then
                PurchaseHeader."Location State Code" := PurchaseHeader."GST Order Address State"
            else
                PurchaseHeader."Location State Code" := PurchaseHeader.State;
    end;

    local procedure POSVendorState(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        Location: Record Location;
    begin
        if not (PurchaseHeader."GST Vendor Type" = "GST Vendor Type"::Registered) then
            Error(POSasVendorErr, PurchaseHeader."GST Vendor Type");

        if PurchaseHeader."Currency Code" <> '' then
            Error(CurrencyCodePOSErr, PurchaseHeader."Currency Code");

        PurchaseHeader.TestField("POS Out Of India", false);
        if PurchaseHeader."POS as Vendor State" then
            if PurchaseHeader."Order Address Code" <> '' then
                PurchaseHeader."Location State Code" := PurchaseHeader."GST Order Address State"
            else
                PurchaseHeader."Location State Code" := PurchaseHeader.State;

        if not PurchaseHeader."POS as Vendor State" then
            if PurchaseHeader."Location Code" = '' then begin
                PurchaseHeader."Location GST Reg. No." := '';
                PurchaseHeader."Location State Code" := '';
            end else
                if PurchaseHeader."Bill to-Location(POS)" = '' then begin
                    if Location.Get(PurchaseHeader."Location Code") then
                        PurchaseHeader."Location GST Reg. No." := Location."GST Registration No.";
                    PurchaseHeader."Location State Code" := Location."State Code";
                end else
                    if Location.Get(PurchaseHeader."Bill to-Location(POS)") then begin
                        PurchaseHeader."Location State Code" := Location."State Code";
                        PurchaseHeader."Location GST Reg. No." := Location."GST Registration No.";
                        PurchaseHeader."GST Input Service Distribution" := Location."GST Input Service Distributor";
                    end;

        if PurchaseHeader."POS as Vendor State" then begin
            PurchaseLine.Reset();
            PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
            PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
            PurchaseLine.SetFilter(PurchaseLine.Type, '<>%1', PurchaseLine.Type::"G/L Account");
            if not PurchaseLine.IsEmpty() then
                Error(TypeErr, PurchaseLine.Type);
        end;
    end;

    local procedure POSOutIndia(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        PartyType: Enum "Party Type";
        GSTCustType: Enum "GST Customer Type";
        DocTypeEnum: Enum "Document Type Enum";
    begin
        PurchaseHeader.TestField(Status, PurchaseHeader.Status::Open);
        PurchaseHeader.TestField("GST Vendor Type", "GST Vendor Type"::Registered);
        PurchaseHeader.TestField("POS as Vendor State", false);
        DocTypeEnum := PurchaseHeaderDocumentType2DocumentTypeEnum(PurchaseHeader."Document Type");
        CheckReferenceInvoiceNo(DocTypeEnum, PurchaseHeader."No.", PurchaseHeader."Buy-from Vendor No.");

        if not PurchaseHeader."GST Invoice" then
            Error(POSGSTStructErr);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.IsEmpty() then begin
            GSTBaseValidation.VerifyPOSOutOfIndia(
                PartyType::Vendor,
                PurchaseHeader."Location State Code",
                PurchaseHeader.State,
                PurchaseHeader."GST Vendor Type",
                GSTCustType::" ");
            exit;
        end;

        if PurchaseLine.findset(false, false) then
            repeat
                if PurchaseHeader."GST Order Address State" <> '' then
                    GSTBaseValidation.VerifyPOSOutOfIndia(
                        PartyType::Vendor,
                        PurchaseHeader."Location State Code",
                        PurchaseHeader."GST Order Address State",
                        PurchaseHeader."GST Vendor Type",
                        GSTCustType::" ")
                else
                    GSTBaseValidation.VerifyPOSOutOfIndia(
                        PartyType::Vendor,
                        PurchaseHeader."Location State Code",
                        PurchaseHeader.State,
                        PurchaseHeader."GST Vendor Type",
                        GSTCustType::" ");

                PurchaseLine.Validate(Quantity);
                PurchaseLine.Validate("Unit Cost");
            until PurchaseLine.Next() = 0
    end;

    local procedure WithoutBillOfEntry(var PurchaseHeader: Record "Purchase Header")
    begin
        if PurchaseHeader."GST Vendor Type" <> "GST Vendor Type"::SEZ then
            Error(SEZWboeErr, PurchaseHeader.FieldCaption("Without Bill Of Entry"));
    end;

    //PurchaseLine Validations - Definition
    local procedure GSTGroupCode(var PurchaseLine: Record "Purchase Line")
    var
        GSTGroup: Record "GST Group";
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseLine.TestStatusOpen();
        PurchaseLine.TestField("Work Tax Nature Of Deduction", '');
        PurchaseLine.TestField("Non-GST Line", false);
        PurchaseLine.Validate("GST Reverse Charge", false);

        if GSTGroup.Get(PurchaseLine."GST Group Code") then begin
            PurchaseLine."GST Group Type" := GSTGroup."GST Group Type";
            GetPurcasehHeader(PurchaseHeader, PurchaseLine);
            if (GSTGroup."Reverse Charge" = true) or (PurchaseLine."GST Group Type" = PurchaseLine."GST Group Type"::Service) then
                if PurchaseHeader."GST Vendor Type" = PurchaseHeader."GST Vendor Type"::Import then
                    PurchaseLine."GST Reverse Charge" := true;

            if PurchaseHeader."GST Vendor Type" in [
                PurchaseHeader."GST Vendor Type"::Registered,
                PurchaseHeader."GST Vendor Type"::Unregistered,
                PurchaseHeader."GST Vendor Type"::SEZ]
            then
                PurchaseLine.Validate("GST Reverse Charge", GSTGroup."Reverse Charge");

            if (PurchaseLine."GST Group Type" = "GST Group Type"::Service) or (PurchaseLine.Type = Type::"Charge (Item)") then begin
                PurchaseLine.TestField("Custom Duty Amount", 0);
                PurchaseLine.TestField("GST Assessable Value", 0);
            end;
        end;
    end;

    local procedure Exempted(var PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseLine.TestStatusOpen();
        CheckExemptedStatus(PurchaseLine);
        PurchaseLine.TestField("Quantity Received", 0);
        PurchaseLine.TestField("Return Qty. Shipped", 0);
        PurchaseLine.TestField("Quantity Invoiced", 0);
        GetPurcasehHeader(PurchaseHeader, PurchaseLine);
        if (PurchaseHeader."Applies-to Doc. No." <> '') or (PurchaseHeader."Applies-to ID" <> '') then
            Error(AppliesToDocErr);
    end;

    local procedure CustomDutyAmount(var PurchaseLine: Record "Purchase Line")
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
    begin
        GetPurcasehHeader(PurchaseHeader, PurchaseLine);
        if not PurchaseHeader."GST Invoice" then
            exit;

        if PurchaseLine."Document Type" in ["Document Type Enum"::"Credit Memo", "Document Type Enum"::"Return Order"] then
            PurchaseLine.TestField("Custom Duty Amount", 0);

        Vendor.Get(PurchaseHeader."Buy-from Vendor No.");
        if not (Vendor."GST Vendor Type" in [Vendor."GST Vendor Type"::Import, Vendor."GST Vendor Type"::SEZ]) then
            Error(GSTVendorTypeErr, Vendor."GST Vendor Type"::Import, Vendor."GST Vendor Type"::SEZ);

        if (PurchaseLine."GST Group Type" <> "GST Group Type"::Goods) or (PurchaseLine.Type = Type::"Charge (Item)") then
            PurchaseLine.TestField("Custom Duty Amount", 0);
    end;

    local procedure GSTAssessableValue(var PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record Vendor;
    begin
        GetPurcasehHeader(PurchaseHeader, PurchaseLine);
        if not PurchaseHeader."GST Invoice" then
            exit;

        if PurchaseLine."Document Type" in ["Document Type Enum"::"Credit Memo", "Document Type Enum"::"Return Order"] then
            PurchaseLine.TestField("GST Assessable Value", 0);

        Vendor.Get(PurchaseHeader."Buy-from Vendor No.");
        if not (Vendor."GST Vendor Type" in [Vendor."GST Vendor Type"::Import, Vendor."GST Vendor Type"::SEZ]) then
            Error(GSTVendorTypeErr, Vendor."GST Vendor Type"::Import, Vendor."GST Vendor Type"::SEZ);

        if (PurchaseLine."GST Group Type" <> "GST Group Type"::Goods) or (PurchaseLine.Type = Type::"Charge (Item)") then
            PurchaseLine.TestField("GST Assessable Value", 0);
    end;

    local procedure NONGSTLine(var PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseLine.TestStatusOpen();
        if PurchaseLine."Non-GST Line" then begin
            PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
            if not PurchaseHeader."GST Invoice" then
                Error(NGLStructErr);

            PurchaseLine."GST Group Code" := '';
        end;
    end;

    local procedure Supplementary(var PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        GetPurcasehHeader(PurchaseHeader, PurchaseLine);
        if not PurchaseLine.Supplementary then
            PurchaseLine."Source Document No." := '';

        if PurchaseHeader."Invoice Type" = PurchaseHeader."Invoice Type"::Supplementary then
            PurchaseLine.TestField(Supplementary)
        else
            PurchaseLine.TestField(Supplementary, false);
    end;

    local procedure VendorInfo(var PurchaseHeader: Record "Purchase Header"; Vendor: Record Vendor)
    var
        Location: Record Location;
    begin
        if PurchaseHeader."Location Code" <> '' then begin
            Location.Get(PurchaseHeader."Location Code");
            PurchaseHeader.Trading := Location."Trading Location";
        end;

        PurchaseHeader.Validate("GST Vendor Type", Vendor."GST Vendor Type");
        if PurchaseHeader."Reference Invoice No." <> '' then
            PurchaseHeader."Reference Invoice No." := '';

        PurchaseHeader."Associated Enterprises" := Vendor."Associated Enterprises";
    end;

    local procedure PaytoVendorInfo(var PurchaseHeader: Record "Purchase Header"; PayToVendor: Record Vendor)
    begin
        PurchaseHeader."Vendor GST Reg. No." := PayToVendor."GST Registration No.";
        PurchaseHeader.State := PayToVendor."State Code";
        PurchaseHeader."GST Vendor Type" := PayToVendor."GST Vendor Type";
    end;

    local procedure GstLocationCode(var PurchaseHeader: Record "Purchase Header")
    var
        DocTypeEnum: Enum "Document Type Enum";
    begin
        DocTypeEnum := PurchaseHeaderDocumentType2DocumentTypeEnum(PurchaseHeader."Document Type");
        CheckLocationCode(PurchaseHeader);
        CheckReferenceInvoiceNo(DocTypeEnum, PurchaseHeader."No.", PurchaseHeader."Buy-from Vendor No.");
    end;

    local procedure GLAccValue(var PurchaseLine: Record "Purchase Line"; GLAccount: Record "G/L Account")
    var
        GSTGroup: Record "GST Group";
    begin
        if GLAccount."GST Group Code" <> '' then
            GSTGroup.Get(GLAccount."GST Group Code");

        UpdatePurchLineForGST(GLAccount."GST Credit", GLAccount."GST Group Code", GSTGroup."GST Group Type", GLAccount."HSN/SAC Code", GLAccount.Exempted, PurchaseLine);
    end;

    local procedure ItemValue(var PurchaseLine: Record "Purchase Line"; Item: Record Item)
    var
        GSTGroup: Record "GST Group";
        PurchaseHeader: Record "Purchase Header";
    begin
        if Item."GST Group Code" <> '' then
            GSTGroup.Get(Item."GST Group Code");

        if not PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then
            exit;
        PurchaseLine.Validate("GST Vendor Type", PurchaseHeader."GST Vendor Type");

        UpdatePurchLineForGST(Item."GST Credit", Item."GST Group Code", GSTGroup."GST Group Type", Item."HSN/SAC Code", Item.Exempted, PurchaseLine);
    end;

    local procedure FAValue(var PurchaseLine: Record "Purchase Line"; FixedAsset: Record "Fixed Asset")
    var
        GSTGroup: Record "GST Group";
    begin
        if FixedAsset."GST Group Code" <> '' then
            GSTGroup.Get(FixedAsset."GST Group Code");

        UpdatePurchLineForGST(FixedAsset."GST Credit", FixedAsset."GST Group Code", GSTGroup."GST Group Type", FixedAsset."HSN/SAC Code", FixedAsset.Exempted, PurchaseLine);
    end;

    local procedure ItemChargeValue(var PurchaseLine: Record "Purchase Line"; ItemCharge: Record "Item Charge")
    var
        GSTGroup: Record "GST Group";
    begin
        if ItemCharge."GST Group Code" <> '' then
            GSTGroup.Get(ItemCharge."GST Group Code");

        UpdatePurchLineForGST(ItemCharge."GST Credit", ItemCharge."GST Group Code", GSTGroup."GST Group Type", ItemCharge."HSN/SAC Code", ItemCharge.Exempted, PurchaseLine);
    end;

    local procedure ResourceValue(var PurchaseLine: Record "Purchase Line"; Resource: Record Resource)
    var
        GSTGroup: Record "GST Group";
    begin
        if Resource."GST Group Code" <> '' then
            GSTGroup.Get(Resource."GST Group Code");

        UpdatePurchLineForGST(Resource."GST Credit", Resource."GST Group Code", GSTGroup."GST Group Type", Resource."HSN/SAC Code", Resource.Exempted, PurchaseLine);
    end;

    local procedure UpdatePurchLineForGST(
        GSTCredit: Enum "GST Credit";
        GSTGrpCode: Code[20];
        GSTGrpType: Enum "GST Group Type";
        HSNSACCode: Code[10];
        GSTExempted: Boolean;
        var PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
        GSTGroup: Record "GST Group";
    begin
        GetPurcasehHeader(PurchaseHeader, PurchaseLine);
        if (PurchaseHeader."POS as Vendor State") and not (PurchaseLine.Type = PurchaseLine.Type::"G/L Account") then
            Error(TypeErr, PurchaseLine.Type);

        PurchaseLine."GST Credit" := GSTCredit;
        PurchaseLine."GST Group Code" := GSTGrpCode;
        PurchaseLine."GST Group Type" := GSTGrpType;
        PurchaseLine.Exempted := GSTExempted;
        PurchaseLine."HSN/SAC Code" := HSNSACCode;

        UpdateGSTJurisdictionType(PurchaseLine);
        if GSTGroup.Get(PurchaseLine."GST Group Code") then
            if (GSTGroup."Reverse Charge") or (PurchaseLine."GST Group Type" = PurchaseLine."GST Group Type"::Service) then
                PurchaseLine."GST Reverse Charge" := PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::Import];

        if GSTGroup.Get(PurchaseLine."GST Group Code") and
           (PurchaseHeader."GST Vendor Type" in [
               PurchaseHeader."GST Vendor Type"::Registered,
               PurchaseHeader."GST Vendor Type"::Unregistered,
               PurchaseHeader."GST Vendor Type"::SEZ])
        then
            PurchaseLine."GST Reverse Charge" := GSTGroup."Reverse Charge";

        if (PurchaseHeader."GST Invoice") and (PurchaseHeader."GST Input Service Distribution") then begin
            if PurchaseLine.Type in [PurchaseLine.Type::"Fixed Asset", PurchaseLine.Type::"Charge (Item)", PurchaseLine.Type::Item] then
                Error(ChargeItemErr, PurchaseLine.Type);

            if (PurchaseLine."GST Group Code" <> '') and (PurchaseLine."GST Group Type" <> "GST Group Type"::Service) then
                Error(TypeISDErr, PurchaseLine.Type, PurchaseLine.FieldCaption("GST Group Type"), "GST Group Type"::Service);
        end;

        PurchaseLine."Order Address Code" := PurchaseHeader."Order Address Code";
        if PurchaseLine."Order Address Code" <> '' then
            PurchaseLine."Buy-From GST Registration No" := PurchaseHeader."Order Address GST Reg. No."
        else
            PurchaseLine."Buy-From GST Registration No" := PurchaseHeader."Vendor GST Reg. No.";

        PurchaseLine."Bill to-Location(POS)" := PurchaseHeader."Bill to-Location(POS)";
        if PurchaseLine."Bill to-Location(POS)" <> '' then
            PurchaseLine."Bill to-Location(POS)" := PurchaseHeader."Bill to-Location(POS)"
        else
            PurchaseLine."Bill to-Location(POS)" := '';

        if PurchaseHeader."GST Vendor Type" = PurchaseHeader."GST Vendor Type"::Unregistered then
            PurchaseLine."GST Reverse Charge" := true;
    end;

    local procedure CheckExemptedStatus(var PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        if PurchaseHeader."GST Vendor Type" = PurchaseHeader."GST Vendor Type"::Exempted then
            PurchaseLine.TestField(Exempted);
    end;

    local procedure CheckLocationCode(var PurchaseHeader: Record "Purchase Header")
    var
        Location: Record Location;
    begin
        if not PurchaseHeader."POS as Vendor State" then begin
            if PurchaseHeader."Location Code" = '' then begin
                PurchaseHeader."Location GST Reg. No." := '';
                PurchaseHeader."Location State Code" := '';
            end else begin
                Location.Get(PurchaseHeader."Location Code");
                PurchaseHeader."Location GST Reg. No." := Location."GST Registration No.";
                PurchaseHeader."Location State Code" := Location."State Code";
            end;

            if PurchaseHeader."Bill to-Location(POS)" <> '' then begin
                Location.Get(PurchaseHeader."Bill to-Location(POS)");
                PurchaseHeader."Location State Code" := Location."State Code";
                PurchaseHeader."Location GST Reg. No." := Location."GST Registration No.";
                PurchaseHeader."GST Input Service Distribution" := Location."GST Input Service Distributor";
            end;
        end else
            if PurchaseHeader."Order Address Code" <> '' then
                PurchaseHeader."Location State Code" := PurchaseHeader."GST Order Address State"
            else
                PurchaseHeader."Location State Code" := PurchaseHeader.State;

        if Location.Get(PurchaseHeader."Location Code") then
            PurchaseHeader."GST Input Service Distribution" := Location."GST Input Service Distributor";
    end;

    local procedure GetPurcasehHeader(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase line")
    var
        Currency: Record Currency;
    begin
        PurchaseLine.TestField("Document No.");
        if (PurchaseLine."Document Type" <> PurchaseHeader."Document Type") or (PurchaseLine."Document No." <> PurchaseHeader."No.") then begin
            if not PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then
                exit;

            if PurchaseHeader."Currency Code" = '' then
                Currency.InitRoundingPrecision()
            else begin
                PurchaseHeader.TestField("Currency Factor");
                Currency.Get(PurchaseHeader."Currency Code");
                Currency.TestField("Amount Rounding Precision");
            end;
        end;
    end;

    //Vendor Validation - Definition
    local procedure VendGSTRegistrationNo(var Vendor: Record Vendor)
    begin
        if Vendor."GST Registration No." <> '' then begin
            Vendor.TestField("State Code");
            if (Vendor."P.A.N. No." <> '') and (Vendor."P.A.N. Status" = Vendor."P.A.N. Status"::" ") then
                GSTBaseValidation.CheckGSTRegistrationNo(Vendor."State Code", Vendor."GST Registration No.", Vendor."P.A.N. No.")
            else
                if Vendor."GST Registration No." <> '' then
                    Error(PANErr);

            if Vendor."GST Vendor Type" = "GST Vendor Type"::" " then
                Vendor."GST Vendor Type" := "GST Vendor Type"::Registered
            else
                if not (Vendor."GST Vendor Type" in ["GST Vendor Type"::Registered, "GST Vendor Type"::Composite, "GST Vendor Type"::Exempted, "GST Vendor Type"::SEZ]) then
                    Vendor."GST Vendor Type" := "GST Vendor Type"::Registered
        end else
            if Vendor."ARN No." = '' then
                Vendor."GST Vendor Type" := "GST Vendor Type"::" ";
    end;

    local procedure GSTVendorType(var Vendor: Record Vendor)
    begin
        if Vendor."GST Vendor Type" = "GST Vendor Type"::" " then begin
            Vendor."GST Registration No." := '';
            exit;
        end;

        if Vendor."GST Vendor Type" in ["GST Vendor Type"::Registered, "GST Vendor Type"::Composite, "GST Vendor Type"::SEZ, "GST Vendor Type"::Exempted] then begin
            if (Vendor."GST Registration No." = '') and (Vendor."ARN No." = '') then
                Error(GSTARNErr);
        end else begin
            Vendor."GST Registration No." := '';
            Vendor."ARN No." := '';
            if Vendor."GST Vendor Type" = "GST Vendor Type"::Import then
                Vendor.TestField("State Code", '')
            else
                if Vendor."GST Vendor Type" = "GST Vendor Type"::Unregistered then
                    Vendor.TestField("State Code");

            if Vendor."GST Vendor Type" <> "GST Vendor Type"::Import then
                Vendor."Associated Enterprises" := false;
        end;

        if Vendor."GST Registration No." <> '' then begin
            Vendor.TestField("State Code");

            if (Vendor."P.A.N. No." <> '') and (Vendor."P.A.N. Status" = Vendor."P.A.N. Status"::" ") then
                GSTBaseValidation.CheckGSTRegistrationNo(Vendor."State Code", Vendor."GST Registration No.", Vendor."P.A.N. No.")
            else
                if Vendor."GST Registration No." <> '' then
                    Error(PANErr);
        end;
    end;

    local procedure VendARNNo(var Vendor: Record Vendor)
    begin
        if (Vendor."ARN No." = '') and (Vendor."GST Registration No." = '') then
            if not (Vendor."GST Vendor Type" in ["GST Vendor Type"::Import, "GST Vendor Type"::Unregistered]) then
                Vendor."GST Vendor Type" := "GST Vendor Type"::" ";

        if Vendor."GST Vendor Type" in ["GST Vendor Type"::Import, "GST Vendor Type"::Unregistered] then
            Vendor.TestField("ARN No.", '');
    end;

    local procedure VendStateCode(var Vendor: Record Vendor)
    begin
        if not (Vendor."GST Vendor Type" in ["GST Vendor Type"::Import, "GST Vendor Type"::Unregistered]) then
            Vendor.TestField("GST Registration No.", '');

        if Vendor."GST Vendor Type" = "GST Vendor Type"::Import then
            Error(GSTVendTypeErr, Vendor."GST Vendor Type");
    end;

    local procedure ValidateVendorPANNo(Vendor: Record Vendor)
    begin
        if (Vendor."GST Registration No." <> '') and (Vendor."P.A.N. No." <> CopyStr(Vendor."GST Registration No.", 3, 10)) then
            Error(SamePANErr);

        CheckGSTRegBlankInRef(Vendor);
    end;

    local procedure CheckGSTRegBlankInRef(Vendor: Record Vendor)
    var
        OrderAddress: Record "Order Address";
    begin
        OrderAddress.SetRange("Vendor No.", Vendor."No.");
        OrderAddress.SetFilter("GST Registration No.", '<>%1', '');
        if OrderAddress.FindSet() then
            repeat
                if Vendor."P.A.N. No." <> COPYSTR(OrderAddress."GST Registration No.", 3, 10) then
                    Error(GSTPANErr, OrderAddress.Code);
            until OrderAddress.Next() = 0;
    end;

    local procedure CheckBillOfEntry(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if not (PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::Import, PurchaseHeader."GST Vendor Type"::SEZ]) then
            exit;

        if not (PurchaseHeader."Document Type" in ["Document Type Enum"::Order, "Document Type Enum"::Invoice]) then
            exit;


        if PurchaseHeader."Without Bill Of Entry" then
            exit;

        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetFilter(Type, '<>%1', PurchaseLine.Type::" ");
        PurchaseLine.SetFilter("Qty. to Invoice", '<>%1', 0);
        PurchaseLine.SetRange("GST Group Type", PurchaseLine."GST Group Type"::Goods);
        PurchaseLine.SetFilter("GST Group Code", '<>%1', '');
        if PurchaseLine.FindFirst() then begin
            PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
            PurchaseHeader.TestField("Bill of Entry Date");
            PurchaseHeader.TestField("Bill of Entry No.");
            PurchaseHeader.TestField("Bill of Entry Value");
        end;
    end;

    local procedure CheckPostingDate(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        TaxTransactionValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");

        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetFilter(Type, '<>%1', PurchaseLine.Type::" ");
        if PurchaseLine.FindSet() then
            repeat
                TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
                TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
                TaxTransactionValue.SetRange("Tax Record ID", PurchaseLine.RecordId);
                TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
                if not TaxTransactionValue.IsEmpty() then
                    GSTBaseValidation.CheckGSTAccountingPeriod(PurchaseHeader."Posting Date", false);
            until PurchaseLine.Next() = 0;
    end;

    local procedure CheckUnregisteredVendorCondition(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        GSTSetup: Record "GST Setup";
        Vendor: Record Vendor;
    begin
        if PurchaseHeader."GST Vendor Type" <> PurchaseHeader."GST Vendor Type"::Unregistered then
            exit;
        CheckUnregisteredReverseCharge(PurchaseHeader);

        Vendor.Get(PurchaseHeader."Buy-from Vendor No.");
        if (Vendor."Aggregate Turnover" <> Vendor."Aggregate Turnover"::"More than 20 lakh") then
            exit;

        if not GSTSetup.Get() then
            exit;

        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetFilter(Type, '<>%1', PurchaseLine.Type::" ");
        PurchaseLine.SetRange("GST Jurisdiction Type", PurchaseLine."GST Jurisdiction Type"::Interstate);
        PurchaseLine.SetRange(PurchaseLine."GST Group Type", PurchaseLine."GST Group Type"::Service);
        if not PurchaseLine.IsEmpty() then
            Error(IGSTAggTurnoverErr);
    end;

    local procedure UpdateGSTJurisdictionType(var PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then begin
            if PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::SEZ, PurchaseHeader."GST Vendor Type"::Import] then begin
                PurchaseLine."GST Jurisdiction Type" := PurchaseLine."GST Jurisdiction Type"::Interstate;
                exit;
            end;

            if PurchaseHeader."POS Out Of India" then begin
                PurchaseLine."GST Jurisdiction Type" := PurchaseLine."GST Jurisdiction Type"::Interstate;
                exit;
            end;

            if PurchaseHeader."Location State Code" <> PurchaseHeader."State" then
                PurchaseLine."GST Jurisdiction Type" := PurchaseLine."GST Jurisdiction Type"::Interstate
            else
                if PurchaseHeader."Location State Code" = PurchaseHeader."State" then
                    PurchaseLine."GST Jurisdiction Type" := PurchaseLine."GST Jurisdiction Type"::Intrastate
                else
                    if (PurchaseHeader."Location State Code" <> '') and (PurchaseHeader."State" = '') then
                        PurchaseLine."GST Jurisdiction Type" := PurchaseLine."GST Jurisdiction Type"::Interstate;
        end;
    end;

    local procedure UpdateCurrGSTJurisdictionType(PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    begin
        if PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::SEZ, PurchaseHeader."GST Vendor Type"::Import] then begin
            PurchaseLine."GST Jurisdiction Type" := PurchaseLine."GST Jurisdiction Type"::Interstate;
            exit;
        end;

        if PurchaseHeader."POS Out Of India" then begin
            PurchaseLine."GST Jurisdiction Type" := PurchaseLine."GST Jurisdiction Type"::Interstate;
            exit;
        end;

        if PurchaseHeader."Location State Code" <> PurchaseHeader."State" then
            PurchaseLine."GST Jurisdiction Type" := PurchaseLine."GST Jurisdiction Type"::Interstate
        else
            if PurchaseHeader."Location State Code" = PurchaseHeader."State" then
                PurchaseLine."GST Jurisdiction Type" := PurchaseLine."GST Jurisdiction Type"::Intrastate
            else
                if (PurchaseHeader."Location State Code" <> '') and (PurchaseHeader."State" = '') then
                    PurchaseLine."GST Jurisdiction Type" := PurchaseLine."GST Jurisdiction Type"::Interstate;
    end;

    local procedure PurchaseHeaderDocumentType2DocumentTypeEnum(PurchaseDocumentType: Enum "Purchase Document Type"): Enum "Document Type Enum";
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Purchase Header Document Type';
    begin
        case PurchaseDocumentType of
            PurchaseDocumentType::Quote:
                exit("Document Type Enum"::Quote);
            PurchaseDocumentType::Order:
                exit("Document Type Enum"::Order);
            PurchaseDocumentType::Invoice:
                exit("Document Type Enum"::Invoice);
            PurchaseDocumentType::"Credit Memo":
                exit("Document Type Enum"::"Credit Memo");
            PurchaseDocumentType::"Blanket Order":
                exit("Document Type Enum"::"Blanket Order");
            PurchaseDocumentType::"Return Order":
                exit("Document Type Enum"::"Return Order");
            else
                Error(ConversionErr, PurchaseDocumentType);
        end;
    end;

    procedure SetHSNSACEditable(PurchaseLine: Record "Purchase Line"; var IsEditable: Boolean)
    var
        Item: Record Item;
        IsHandled: Boolean;
    begin
        IsEditable := false;
        OnBeforePurchaseLineHSNSACEditable(PurchaseLine, IsEditable, IsHandled);
        if IsHandled then
            exit;

        case
            PurchaseLine.Type of
            PurchaseLine.Type::Item:
                if Item.Get(PurchaseLine."No.") then
                    if Item.Type in [Item.Type::Inventory, Item.Type::"Non-Inventory"] then
                        IsEditable := false
                    else
                        IsEditable := true;
            PurchaseLine.Type::"Fixed Asset":
                IsEditable := false;
            else
                IsEditable := true;
        end;
    end;

    local procedure SetPayToVendorFieldsForPurchase(var PurchaseHeader: Record "Purchase Header")
    var
        PayToVendor: Record vendor;
        GSTPostingManagement: Codeunit "GST Posting Management";
    begin
        if (PurchaseHeader."Pay-to Vendor No." <> '') and (PurchaseHeader."Buy-from Vendor No." <> PurchaseHeader."Pay-to Vendor No.") then begin
            if PayToVendor.Get(PurchaseHeader."Pay-to Vendor No.") then begin
                GSTPostingManagement.SetPaytoVendorNo(PurchaseHeader."Pay-to Vendor No.");
                GSTPostingManagement.SetBuyerSellerRegNo(PayToVendor."GST Registration No.");
                GSTPostingManagement.SetBuyerSellerStateCode(PayToVendor."State Code");
            end;
        end else
            GSTPostingManagement.SetPaytoVendorNo(PurchaseHeader."Pay-to Vendor No.");
    end;

    local procedure CheckUnregisteredReverseCharge(PurchHeader: Record "Purchase Header")
    var
        PurchseLine: Record "Purchase Line";
    begin
        PurchseLine.Reset();
        PurchseLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchseLine.SetRange("Document No.", PurchHeader."No.");
        if PurchseLine.FindSet() then
            repeat
                if (PurchseLine."GST Group Code" <> '') and (not PurchseLine."GST Reverse Charge") then
                    Error(GSTUnregisteredNotAppErr);
            until PurchseLine.Next() = 0;
    end;

    procedure SetLocationCodeVisibleConditionally(var IsLocationVisible: Boolean; ShipToOptions: Option "Default (Company Address)",Location,"Customer Address","Custom Address")
    begin
        if ShipToOptions In [ShipToOptions::Location, ShipToOptions::"Custom Address"] then
            IsLocationVisible := true
        else
            IsLocationVisible := false;
    end;

    procedure SetLocationCodeVisibleForQuoteandInvoice(var IsLocationVisible: Boolean; ShipToOptions: Option "Default (Company Address)",Location,"Custom Address")
    begin
        if ShipToOptions In [ShipToOptions::Location, ShipToOptions::"Custom Address"] then
            IsLocationVisible := true
        else
            IsLocationVisible := false;
    end;

    procedure ValidateLocationCodeForShiptoCustomAddForOrder(PurchaseHeader: Record "Purchase Header"; ShipToOptions: Option "Default (Company Address)",Location,"Customer Address","Custom Address")
    begin
        if PurchaseHeader."GST Vendor Type" = PurchaseHeader."GST Vendor Type"::" " then
            exit;

        if (PurchaseHeader."Location Code" = '') and (ShipToOptions = ShipToOptions::"Custom Address") then
            Error(ShipToOptionErr);
    end;

    procedure ValidateLocationCodeForShiptoCustomAddForQuoteAndInvoice(PurchaseHeader: Record "Purchase Header"; ShipToOptions: Option "Default (Company Address)",Location,"Custom Address")
    begin
        if PurchaseHeader."GST Vendor Type" = PurchaseHeader."GST Vendor Type"::" " then
            exit;

        if (PurchaseHeader."Location Code" = '') and (ShipToOptions = ShipToOptions::"Custom Address") then
            Error(ShipToOptionErr);
    end;

    local procedure CheckHeaderLocation(PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
        IsHandled: Boolean;
    begin
        OnBeforeCheckHeaderLocation(PurchaseLine, IsHandled);
        if IsHandled then
            exit;

        if not PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then
            exit;

        if PurchaseHeader."GST Vendor Type" = PurchaseHeader."GST Vendor Type"::" " then
            exit;

        PurchaseLine.TestField("Location Code", PurchaseHeader."Location Code");
    end;

    local procedure CheckGSTRegistrationLength(RegistrationNo: Code[20])
    var
        IsHandled: Boolean;
    begin
        OnBeforeCheckGSTRegistrationNo(RegistrationNo, IsHandled);
        if IsHandled then
            exit;

        if RegistrationNo = '' then
            exit;

        if StrLen(RegistrationNo) <> 15 then
            Error(LengthErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GST Purchase Subscribers", 'OnBeforePurchaseLineHSNSACEditable', '', false, false)]
    local procedure SetGstHsnEditableforAllType(var IsEditable: Boolean; var IsHandled: Boolean)
    begin
        IsEditable := true;
        IsHandled := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePurchaseLineHSNSACEditable(PurchaseLine: Record "Purchase Line"; var IsEditable: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckHeaderLocation(PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckGSTRegistrationNo(RegistrationNo: Code[20]; var IsHandled: Boolean)
    begin
    end;
}
