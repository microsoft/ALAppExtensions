// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Peppol;

using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.UOM;
using Microsoft.Sales.Document;

codeunit 37350 "PEPPOL30 NA" implements "PEPPOL Line Info Provider", "PEPPOL Tax Info Provider"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        PEPPOL30: Codeunit "PEPPOL30";
        UoMforPieceINUNECERec20ListIDTxt: Label 'C62', Locked = true;
        VATTxt: Label 'VAT', Locked = true;
        NoUnitOfMeasureErr: Label 'The %1 %2 contains lines on which the %3 field is empty.', Comment = '%1: document type, %2: document no, %3 Unit of Measure Code';

    // ===== PEPPOL Line Info Provider - Delegated methods =====

    procedure GetLineGeneralInfo(SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; var InvoiceLineID: Text; var InvoiceLineNote: Text; var InvoicedQuantity: Text; var InvoiceLineExtensionAmount: Text; var LineExtensionAmountCurrencyID: Text; var InvoiceLineAccountingCost: Text)
    begin
        PEPPOL30.GetLineGeneralInfo(SalesLine, SalesHeader, InvoiceLineID, InvoiceLineNote, InvoicedQuantity, InvoiceLineExtensionAmount, LineExtensionAmountCurrencyID, InvoiceLineAccountingCost);
    end;

    procedure GetLineInvoicePeriodInfo(var InvLineInvoicePeriodStartDate: Text; var InvLineInvoicePeriodEndDate: Text)
    begin
        PEPPOL30.GetLineInvoicePeriodInfo(InvLineInvoicePeriodStartDate, InvLineInvoicePeriodEndDate);
    end;

    procedure GetLineDeliveryInfo(var InvoiceLineActualDeliveryDate: Text; var InvoiceLineDeliveryID: Text; var InvoiceLineDeliveryIDSchemeID: Text)
    begin
        PEPPOL30.GetLineDeliveryInfo(InvoiceLineActualDeliveryDate, InvoiceLineDeliveryID, InvoiceLineDeliveryIDSchemeID);
    end;

    procedure GetLineDeliveryPostalAddr(var InvoiceLineDeliveryStreetName: Text; var InvLineDeliveryAddStreetName: Text; var InvoiceLineDeliveryCityName: Text; var InvoiceLineDeliveryPostalZone: Text; var InvLnDeliveryCountrySubentity: Text; var InvLnDeliveryCountryIdCode: Text; var InvLineDeliveryCountryListID: Text)
    begin
        PEPPOL30.GetLineDeliveryPostalAddr(InvoiceLineDeliveryStreetName, InvLineDeliveryAddStreetName, InvoiceLineDeliveryCityName, InvoiceLineDeliveryPostalZone, InvLnDeliveryCountrySubentity, InvLnDeliveryCountryIdCode, InvLineDeliveryCountryListID);
    end;

    procedure GetLineAllowanceChargeInfo(SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; var InvLnAllowanceChargeIndicator: Text; var InvLnAllowanceChargeReason: Text; var InvLnAllowanceChargeAmount: Text; var InvLnAllowanceChargeAmtCurrID: Text)
    begin
        PEPPOL30.GetLineAllowanceChargeInfo(SalesLine, SalesHeader, InvLnAllowanceChargeIndicator, InvLnAllowanceChargeReason, InvLnAllowanceChargeAmount, InvLnAllowanceChargeAmtCurrID);
    end;

    procedure GetLineTaxTotal(SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; var InvoiceLineTaxAmount: Text; var currencyID: Text)
    begin
        PEPPOL30.GetLineTaxTotal(SalesLine, SalesHeader, InvoiceLineTaxAmount, currencyID);
    end;

    procedure GetLineItemInfo(SalesLine: Record "Sales Line"; var Description: Text; var Name: Text; var SellersItemIdentificationID: Text; var StandardItemIdentificationID: Text; var StdItemIdIDSchemeID: Text; var OriginCountryIdCode: Text; var OriginCountryIdCodeListID: Text)
    begin
        PEPPOL30.GetLineItemInfo(SalesLine, Description, Name, SellersItemIdentificationID, StandardItemIdentificationID, StdItemIdIDSchemeID, OriginCountryIdCode, OriginCountryIdCodeListID);
    end;

    procedure GetLineItemCommodityClassificationInfo(var CommodityCode: Text; var CommodityCodeListID: Text; var ItemClassificationCode: Text; var ItemClassificationCodeListID: Text)
    begin
        PEPPOL30.GetLineItemCommodityClassificationInfo(CommodityCode, CommodityCodeListID, ItemClassificationCode, ItemClassificationCodeListID);
    end;

    procedure GetLineAdditionalItemPropertyInfo(SalesLine: Record "Sales Line"; var AdditionalItemPropertyName: Text; var AdditionalItemPropertyValue: Text)
    begin
        PEPPOL30.GetLineAdditionalItemPropertyInfo(SalesLine, AdditionalItemPropertyName, AdditionalItemPropertyValue);
    end;

    procedure GetLinePriceInfo(SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; var InvoiceLinePriceAmount: Text; var InvLinePriceAmountCurrencyID: Text; var BaseQuantity: Text; var UnitCode: Text)
    begin
        PEPPOL30.GetLinePriceInfo(SalesLine, SalesHeader, InvoiceLinePriceAmount, InvLinePriceAmountCurrencyID, BaseQuantity, UnitCode);
    end;

    procedure GetLinePriceAllowanceChargeInfo(var PriceChargeIndicator: Text; var PriceAllowanceChargeAmount: Text; var PriceAllowanceAmountCurrencyID: Text; var PriceAllowanceChargeBaseAmount: Text; var PriceAllowChargeBaseAmtCurrID: Text)
    begin
        PEPPOL30.GetLinePriceAllowanceChargeInfo(PriceChargeIndicator, PriceAllowanceChargeAmount, PriceAllowanceAmountCurrencyID, PriceAllowanceChargeBaseAmount, PriceAllowChargeBaseAmtCurrID);
    end;

    // ===== PEPPOL Line Info Provider - NA-specific methods =====

    /// <summary>
    /// NA uses C62 (UNECE Rec 20 code for 'one') instead of W1's EA ('each') as the default unit of measure for pieces.
    /// </summary>
    procedure GetLineUnitCodeInfo(SalesLine: Record "Sales Line"; var UnitCode: Text; var UnitCodeListID: Text)
    var
        UOM: Record "Unit of Measure";
    begin
        UnitCode := '';
        UnitCodeListID := 'UNECERec20';

        if SalesLine.Quantity = 0 then begin
            UnitCode := UoMforPieceINUNECERec20ListIDTxt;
            exit;
        end;

        case SalesLine.Type of
            SalesLine.Type::Item, SalesLine.Type::Resource:
                if UOM.Get(SalesLine."Unit of Measure Code") then
                    UnitCode := UOM."International Standard Code"
                else
                    Error(NoUnitOfMeasureErr, SalesLine."Document Type", SalesLine."Document No.", SalesLine.FieldCaption("Unit of Measure Code"));
            SalesLine.Type::"G/L Account", SalesLine.Type::"Fixed Asset", SalesLine.Type::"Charge (Item)":
                if UOM.Get(SalesLine."Unit of Measure Code") then
                    UnitCode := UOM."International Standard Code"
                else
                    UnitCode := UoMforPieceINUNECERec20ListIDTxt;
        end;
    end;

    /// <summary>
    /// NA does not fall back to tax category 'E' (exempt) when VATPostingSetup has no Tax Category.
    /// Instead it leaves the ClassifiedTaxCategoryID as-is and always sets the tax percent from the sales line.
    /// </summary>
    procedure GetLineItemClassifiedTaxCategory(SalesLine: Record "Sales Line"; var ClassifiedTaxCategoryID: Text; var ItemSchemeID: Text; var InvoiceLineTaxPercent: Text; var ClassifiedTaxCategorySchemeID: Text)
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if VATPostingSetup.Get(SalesLine."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group") then
            ClassifiedTaxCategoryID := VATPostingSetup."Tax Category";

        ItemSchemeID := '';
        InvoiceLineTaxPercent := Format(SalesLine."VAT %", 0, 9);
        ClassifiedTaxCategorySchemeID := VATTxt;
    end;

    /// <summary>
    /// BIS variant: same as GetLineItemClassifiedTaxCategory but clears percent for outside-scope VAT.
    /// </summary>
    procedure GetLineItemClassifiedTaxCategoryBIS(SalesLine: Record "Sales Line"; var ClassifiedTaxCategoryID: Text; var ItemSchemeID: Text; var InvoiceLineTaxPercent: Text; var ClassifiedTaxCategorySchemeID: Text)
    begin
        GetLineItemClassifiedTaxCategory(
          SalesLine, ClassifiedTaxCategoryID, ItemSchemeID, InvoiceLineTaxPercent, ClassifiedTaxCategorySchemeID);
        if PEPPOL30.IsOutsideScopeVATCategory(CopyStr(ClassifiedTaxCategoryID, 1, 10)) then
            InvoiceLineTaxPercent := '';
    end;

    // ===== PEPPOL Tax Info Provider - Delegated methods =====

    procedure GetAllowanceChargeInfo(VATAmtLine: Record "VAT Amount Line"; SalesHeader: Record "Sales Header"; var ChargeIndicator: Text; var AllowanceChargeReasonCode: Text; var AllowanceChargeListID: Text; var AllowanceChargeReason: Text; var Amount: Text; var AllowanceChargeCurrencyID: Text; var TaxCategoryID: Text; var TaxCategorySchemeID: Text; var Percent: Text; var AllowanceChargeTaxSchemeID: Text)
    begin
        PEPPOL30.GetAllowanceChargeInfo(VATAmtLine, SalesHeader, ChargeIndicator, AllowanceChargeReasonCode, AllowanceChargeListID, AllowanceChargeReason, Amount, AllowanceChargeCurrencyID, TaxCategoryID, TaxCategorySchemeID, Percent, AllowanceChargeTaxSchemeID);
    end;

    procedure GetAllowanceChargeInfoBIS(VATAmtLine: Record "VAT Amount Line"; SalesHeader: Record "Sales Header"; var ChargeIndicator: Text; var AllowanceChargeReasonCode: Text; var AllowanceChargeListID: Text; var AllowanceChargeReason: Text; var Amount: Text; var AllowanceChargeCurrencyID: Text; var TaxCategoryID: Text; var TaxCategorySchemeID: Text; var Percent: Text; var AllowanceChargeTaxSchemeID: Text)
    begin
        PEPPOL30.GetAllowanceChargeInfoBIS(VATAmtLine, SalesHeader, ChargeIndicator, AllowanceChargeReasonCode, AllowanceChargeListID, AllowanceChargeReason, Amount, AllowanceChargeCurrencyID, TaxCategoryID, TaxCategorySchemeID, Percent, AllowanceChargeTaxSchemeID);
    end;

    procedure GetTaxExchangeRateInfo(SalesHeader: Record "Sales Header"; var SourceCurrencyCode: Text; var SourceCurrencyCodeListID: Text; var TargetCurrencyCode: Text; var TargetCurrencyCodeListID: Text; var CalculationRate: Text; var MathematicOperatorCode: Text; var Date: Text)
    begin
        PEPPOL30.GetTaxExchangeRateInfo(SalesHeader, SourceCurrencyCode, SourceCurrencyCodeListID, TargetCurrencyCode, TargetCurrencyCodeListID, CalculationRate, MathematicOperatorCode, Date);
    end;

    procedure GetTaxTotalInfo(SalesHeader: Record "Sales Header"; var VATAmtLine: Record "VAT Amount Line"; var TaxAmount: Text; var TaxTotalCurrencyID: Text)
    begin
        PEPPOL30.GetTaxTotalInfo(SalesHeader, VATAmtLine, TaxAmount, TaxTotalCurrencyID);
    end;

    procedure GetTaxSubtotalInfo(VATAmtLine: Record "VAT Amount Line"; SalesHeader: Record "Sales Header"; var TaxableAmount: Text; var TaxAmountCurrencyID: Text; var SubtotalTaxAmount: Text; var TaxSubtotalCurrencyID: Text; var TransactionCurrencyTaxAmount: Text; var TransCurrTaxAmtCurrencyID: Text; var TaxTotalTaxCategoryID: Text; var schemeID: Text; var TaxCategoryPercent: Text; var TaxTotalTaxSchemeID: Text)
    begin
        PEPPOL30.GetTaxSubtotalInfo(VATAmtLine, SalesHeader, TaxableAmount, TaxAmountCurrencyID, SubtotalTaxAmount, TaxSubtotalCurrencyID, TransactionCurrencyTaxAmount, TransCurrTaxAmtCurrencyID, TaxTotalTaxCategoryID, schemeID, TaxCategoryPercent, TaxTotalTaxSchemeID);
    end;

    procedure GetTaxTotalInfoLCY(SalesHeader: Record "Sales Header"; var TaxAmount: Text; var TaxCurrencyID: Text; var TaxTotalCurrencyID: Text)
    begin
        PEPPOL30.GetTaxTotalInfoLCY(SalesHeader, TaxAmount, TaxCurrencyID, TaxTotalCurrencyID);
    end;

    procedure GetTaxCategories(SalesLine: Record "Sales Line"; var VATProductPostingGroupCategory: Record "VAT Product Posting Group")
    begin
        PEPPOL30.GetTaxCategories(SalesLine, VATProductPostingGroupCategory);
    end;

    procedure GetTaxExemptionReason(var VATProductPostingGroupCategory: Record "VAT Product Posting Group"; var TaxExemptionReasonTxt: Text; TaxCategoryID: Text)
    begin
        PEPPOL30.GetTaxExemptionReason(VATProductPostingGroupCategory, TaxExemptionReasonTxt, TaxCategoryID);
    end;

    procedure IsZeroVatCategory(TaxCategory: Code[10]): Boolean
    begin
        exit(PEPPOL30.IsZeroVatCategory(TaxCategory));
    end;

    procedure IsStandardVATCategory(TaxCategory: Code[10]): Boolean
    begin
        exit(PEPPOL30.IsStandardVATCategory(TaxCategory));
    end;

    procedure IsOutsideScopeVATCategory(TaxCategory: Code[10]): Boolean
    begin
        exit(PEPPOL30.IsOutsideScopeVATCategory(TaxCategory));
    end;

    // ===== PEPPOL Tax Info Provider - NA-specific method =====

    /// <summary>
    /// NA additionally copies Tax Area Code from the sales line to the VAT Amount Line.
    /// </summary>
    procedure GetTaxTotals(SalesLine: Record "Sales Line"; var VATAmtLine: Record "VAT Amount Line")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not VATPostingSetup.Get(SalesLine."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group") then
            VATPostingSetup.Init();
        VATAmtLine.Init();
        VATAmtLine."VAT Identifier" := Format(SalesLine."VAT %");
        VATAmtLine."VAT Calculation Type" := SalesLine."VAT Calculation Type";
        VATAmtLine."Tax Group Code" := SalesLine."Tax Group Code";
        VATAmtLine."Tax Area Code" := SalesLine."Tax Area Code";
        VATAmtLine."Tax Category" := VATPostingSetup."Tax Category";
        VATAmtLine."VAT %" := SalesLine."VAT %";
        VATAmtLine."VAT Base" := SalesLine.Amount;
        VATAmtLine."Amount Including VAT" := SalesLine."Amount Including VAT";
        if SalesLine."Allow Invoice Disc." then
            VATAmtLine."Inv. Disc. Base Amount" := SalesLine."Line Amount";
        VATAmtLine."Invoice Discount Amount" := SalesLine."Inv. Discount Amount";
        VATAmtLine."Pmt. Discount Amount" += SalesLine."Pmt. Discount Amount";

        if VATAmtLine.InsertLine() then begin
            VATAmtLine."Line Amount" += SalesLine."Line Amount";
            VATAmtLine.Modify();
        end;
    end;
}
