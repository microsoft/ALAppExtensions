// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Peppol;

using Microsoft.Finance.VAT.Calculation;
using Microsoft.Sales.Document;
using Microsoft.Utilities;

codeunit 37354 "PEPPOL30 NO Payment" implements "PEPPOL Payment Info Provider"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        PEPPOL30: Codeunit "PEPPOL30";

    procedure GetPaymentMeansInfo(SalesHeader: Record "Sales Header"; var PaymentMeansCode: Text; var PaymentMeansListID: Text; var PaymentDueDate: Text; var PaymentChannelCode: Text; var PaymentID: Text; var PrimaryAccountNumberID: Text; var NetworkID: Text)
    var
        DocumentTools: Codeunit DocumentTools;
    begin
        PEPPOL30.GetPaymentMeansInfo(SalesHeader, PaymentMeansCode, PaymentMeansListID, PaymentDueDate, PaymentChannelCode, PaymentID, PrimaryAccountNumberID, NetworkID);
        PaymentID := DocumentTools.GetEInvoicePEPPOLPaymentID(SalesHeader);
    end;

    procedure GetPaymentMeansPayeeFinancialAcc(var PayeeFinancialAccountID: Text; var PaymentMeansSchemeID: Text; var FinancialInstitutionBranchID: Text; var FinancialInstitutionID: Text; var FinancialInstitutionSchemeID: Text; var FinancialInstitutionName: Text)
    begin
        PEPPOL30.GetPaymentMeansPayeeFinancialAcc(PayeeFinancialAccountID, PaymentMeansSchemeID, FinancialInstitutionBranchID, FinancialInstitutionID, FinancialInstitutionSchemeID, FinancialInstitutionName);
    end;

    procedure GetPaymentMeansPayeeFinancialAccBIS(SalesHeader: Record "Sales Header"; var PayeeFinancialAccountID: Text; var FinancialInstitutionBranchID: Text)
    begin
        PEPPOL30.GetPaymentMeansPayeeFinancialAccBIS(SalesHeader, PayeeFinancialAccountID, FinancialInstitutionBranchID);
    end;

    procedure GetPaymentMeansFinancialInstitutionAddr(var FinancialInstitutionStreetName: Text; var AdditionalStreetName: Text; var FinancialInstitutionCityName: Text; var FinancialInstitutionPostalZone: Text; var FinancialInstCountrySubentity: Text; var FinancialInstCountryIdCode: Text; var FinancialInstCountryListID: Text)
    begin
        PEPPOL30.GetPaymentMeansFinancialInstitutionAddr(FinancialInstitutionStreetName, AdditionalStreetName, FinancialInstitutionCityName, FinancialInstitutionPostalZone, FinancialInstCountrySubentity, FinancialInstCountryIdCode, FinancialInstCountryListID);
    end;

    procedure GetPaymentTermsInfo(SalesHeader: Record "Sales Header"; var PaymentTermsNote: Text)
    begin
        PEPPOL30.GetPaymentTermsInfo(SalesHeader, PaymentTermsNote);
    end;

    procedure GetAllowanceChargeInfoPaymentDiscount(VATAmtLine: Record "VAT Amount Line"; SalesHeader: Record "Sales Header"; var ChargeIndicator: Text; var AllowanceChargeReasonCode: Text; var AllowanceChargeListID: Text; var AllowanceChargeReason: Text; var Amount: Text; var AllowanceChargeCurrencyID: Text; var TaxCategoryID: Text; var TaxCategorySchemeID: Text; var Percent: Text; var AllowanceChargeTaxSchemeID: Text)
    begin
        PEPPOL30.GetAllowanceChargeInfoPaymentDiscount(VATAmtLine, SalesHeader, ChargeIndicator, AllowanceChargeReasonCode, AllowanceChargeListID, AllowanceChargeReason, Amount, AllowanceChargeCurrencyID, TaxCategoryID, TaxCategorySchemeID, Percent, AllowanceChargeTaxSchemeID);
    end;
}
