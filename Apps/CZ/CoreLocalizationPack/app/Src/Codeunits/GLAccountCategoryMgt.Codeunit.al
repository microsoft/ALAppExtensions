// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Account;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

codeunit 31036 "G/L Account Category Mgt. CZL"
{
    var
        A_ReceivablesfromSubscribedCapitalTxt: Label 'A. Receivables from Subscribed Capital';
        B_FixedAssestsTxt: Label 'B. Fixed Assets';
        BI_IntangibleFixedAssetsTxt: Label 'B.I. Intangible Fixed Assests';
        BI1_IntangibleResultsofResearchandDevelopmentTxt: Label 'B.I.1. Intangible Results of Research and Development';
        BI2_ValuableRightsTxt: Label 'B.I.2. Valuable Rights';
        BI21_SoftwareTxt: Label 'B.I.2.1. Software';
        BI22_OtherValuableRightsTxt: Label 'B.I.2.2. Other Valuable Rights';
        BI3_GoodwillTxt: Label 'B.I.3. Goodwill';
        BI4_OtherIntangibleFixedAssetsTxt: Label 'B.I.4. Other Intangible Fixed Assets';
        BI5_AdvancePaymentsforIntangFAandIntangFAinProgressTxt: Label 'B.I.5. Advance Payments for Intang. FA and Intang. FA in Progress';
        BI51_AdvancePaymentsforIntangibleFixedAssetsTxt: Label 'B.I.5.1. Advance Payments for Intangible Fixed Assets';
        BI52_IntangibleFixedAssestsinProgressTxt: Label 'B.I.5.2. Intangible Fixed Assests in Progress';
        BII_TangibleFixedAssetsTxt: Label 'B.II. Tangible Fixed Assets';
        BII1_LandsandBuildingsTxt: Label 'B.II.1. Lands and Buildings';
        BII11_LandsTxt: Label 'B.II.1.1. Lands';
        BII12_BuildingsTxt: Label 'B.II.1.2. Buildings';
        BII2_FixedMovablesandtheCollectionsofFixedMovablesTxt: Label 'B.II.2. Fixed Movables and the Collections of Fixed Movables';
        BII3_ValuationAdjustmenttoAcquiredAssetsTxt: Label 'B.II.3. Valuation Adjustment to Acquired Assets';
        BII4_OtherTangibleFixedAssetsTxt: Label 'B.II.4. Other Tangible Fixed Assets';
        BII41_PerennialCropsTxt: Label 'B.II.4.1. Perennial Crops';
        BII42_FullgrownAnimalsandGroupsThereofTxt: Label 'B.II.4.2. Full-grown Animals and Groups Thereof';
        BII43_OtherTangibleFixedAssetsTxt: Label 'B.II.4.3. Other Tangible Fixed Assets';
        BII5_AdvancePaymentsforTangFAandTangFAinProgressTxt: Label 'B.II.5. Advance Payments for Tang. FA and Tang. FA in Progress';
        BII51_AdvancePaymentsforTangibleFixedAssetsTxt: Label 'B.II.5.1. Advance Payments for Tangible Fixed Assets';
        BII52_TangibleFixedAssetsinProgressTxt: Label 'B.II.5.2. Tangible Fixed Assets in Progress';
        BIII_LongtermFinancialAssetsTxt: Label 'B.III. Long-term Financial Assets';
        BIII1_SharesControlledorControllingEntityTxt: Label 'B.III.1. Shares - Controlled or Controlling Entity';
        BIII2_LoansandCreditsControlledorControllingPersonTxt: Label 'B.III.2. Loans and Credits - Controlled or Controlling Person';
        BIII3_SharesSignificantInfluenceTxt: Label 'B.III.3. Shares - Significant Influence';
        BIII4_LoansandCreditsSignificantInfluenceTxt: Label 'B.III.4. Loans and Credits - Significant Influence';
        BIII5_OtherLongtermSercuritiesandSharesTxt: Label 'B.III.5. Other Long-term Securities and Shares';
        BIII6_LoansandCreditsOthersTxt: Label 'B.III.6. Loans and Credits - Others';
        BIII7_OtherLongtermFinancialAssetsTxt: Label 'B.III.7. Other Long-term Financial Assets';
        BIII71_AnotherLongtermFinancialAssetsTxt: Label 'B.III.7.1. Another Long-term Financial Assets';
        BIII72_AdvancePaymentsforLongtermFinancialAssetsTxt: Label 'B.III.7.2. Advance Payments for Long-term Financial Assets';
        C_CurrentAssetsTxt: Label 'C. Current Assets';
        CI_InventoryTxt: Label 'C.I. Inventory';
        CI1_MaterialTxt: Label 'C.I.1. Material';
        CI2_WorkinProgressandSemiFinishedGoodsTxt: Label 'C.I.2. Work in Progress and Semi-finished Goods';
        CI3_FinishedProductsandGoodsTxt: Label 'C.I.3. Finished Products and Goods';
        CI31_FinishedProductsTxt: Label 'C.I.3.1. Finished Products';
        CI32_GoodsTxt: Label 'C.I.3.2. Goods';
        CI4_YoungandOtherAnimalsandGroupsThereofTxt: Label 'C.I.4. Young and Other Animals and Groups Thereof';
        CI5_AdvancedPaymentsforInventoryTxt: Label 'C.I.5. Advanced Payments for Inventory';
        CII_ReceivablesTxt: Label 'C.II. Receivables';
        CII1_LongtermReceivablesTxt: Label 'C.II.1. Long-term Receivables';
        CII11_TradeReceivablesTxt: Label 'C.II.1.1. Trade Receivables';
        CII12_ReceivablesControlledorControllingEntityTxt: Label 'C.II.1.2. Receivables - Controlled or Controlling Entity';
        CII13_ReceivablesSignificantInfluenceTxt: Label 'C.II.1.3. Receivables - Significant Influence';
        CII14_DeferredTaxReceivablesTxt: Label 'C.II.1.4. Deferred Tax Receivables';
        CII15_ReceivablesOthersTxt: Label 'C.II.1.5. Receivables - Others';
        CII151_ReceivablesfromEquityHoldersTxt: Label 'C.II.1.5.1. Receivables from Equity Holders';
        CII152_LongtermAdvancedPaymentsTxt: Label 'C.II.1.5.2. Long-term Advanced Payments';
        CII153_EstimatedReceivablesTxt: Label 'C.II.1.5.3. Estimated Receivables';
        CII154_OtherReceivablesTxt: Label 'C.II.1.5.4. Other Receivables';
        CII2_ShorttermReceivablesTxt: Label 'C.II.2. Short-term Receivables';
        CII21_TradeReceivablesTxt: Label 'C.II.2.1. Trade Receivables';
        CII22_ReceivablesControlledorControllingEntityTxt: Label 'C.II.2.2. Receivables - Controlled or Controlling Entity';
        CII23_ReceivablesSignificantInfluenceTxt: Label 'C.II.2.3. Receivables - Significant Influence';
        CII24_ReceivablesOthersTxt: Label 'C.II.2.4. Receivables - Others';
        CII241_ReceivablesfromEquityHoldersTxt: Label 'C.II.2.4.1. Receivables from Equity Holders';
        CII242_SocialSecurityandHealthInsuranceTxt: Label 'C.II.2.4.2. Social Security and Health Insurance';
        CII243_StateTaxReveiablesTxt: Label 'C.II.2.4.3. State - Tax Reveiables';
        CII244_ShorttermAdvancedPaymentsTxt: Label 'C.II.2.4.4. Short-term Advanced Payments';
        CII245_EstimatedReceivablesTxt: Label 'C.II.2.4.5. Estimated Receivables';
        CII246_OtherReceivablesTxt: Label 'C.II.2.4.6. Other Receivables';
        CII3_AccruedAssetsTxt: Label 'C.II.3. Accrued Assets';
        CII31_PrepaidExpensesTxt: Label 'C.II.3.1. Prepaid Expenses';
        CII32_ComplexPrepaidExpensesTxt: Label 'C.II.3.2. Complex Prepaid Expenses';
        CII33_AccruedIncomesTxt: Label 'C.II.3.3. Accrued Incomes';
        CIII_ShorttermFinancialAssetsTxt: Label 'C.III. Short-term Financial Assets';
        CIII1_SharesControlledorControllingEntityTxt: Label 'C.III.1. Shares - Controlled or Controlling Entity';
        CIII2_OtherShorttermFinancialAssetsTxt: Label 'C.III.2. Other Short-term Financial Assets';
        CIV_FundsTxt: Label 'C.IV. Funds';
        CIV1_CashTxt: Label 'C.IV.1. Cash';
        CIV2_BankAccountsTxt: Label 'C.IV.2. Bank Accounts';
        D_AccruedAssetsTxt: Label 'D. Accrued Assets';
        D1_PrepaidExpensesTxt: Label 'D.1. Prepaid Expenses';
        D2_ComplexPrepaidExpensesTxt: Label 'D.2. Complex Prepaid Expenses';
        D3_AccruedIncomesTxt: Label 'D.3. Accrued Incomes';
        A_EquityTxt: Label 'A. Equity';
        AI_RegisteredCapitalTxt: Label 'A.I. Registered Capital';
        AI1_RegisteredCapitalTxt: Label 'A.I.1. Registered Capital';
        AI2_CompanysOwnSharesTxt: Label 'A.I.2. Company''s Own Shares (-)';
        AI3_ChangesofRegisteredCapitalTxt: Label 'A.I.3. Changes of Registered Capital';
        AII_CapitalSurplusandCapitalFundsTxt: Label 'A.II. Capital Surplus and Capital Funds';
        AII1_CapitalSurplusTxt: Label 'A.II.1. Capital Surplus';
        AII2_CapitalFundsTxt: Label 'A.II.2. Capital Funds';
        AII21_OtherCapitalFundsTxt: Label 'A.II.2.1. Other Capital Funds';
        AII22_GainsandLossesfromRevaluationffAssestsandLiabilitiesTxt: Label 'A.II.2.2. Gains and Losses from Revaluation of Assests and Liabilities (+/-)';
        AII23_GainsandLossesfromRevalinCourseofTransofBusCorpTxt: Label 'A.II.2.3. Gains and Losses from Reval. in Course of Trans. of Bus. Corp. (+/-)';
        AII24_DiffResultingfromTransformationsofBusinessCorporationsTxt: Label 'A.II.2.4. Diff. Resulting from Transformations of Business Corporations (+/-)';
        AII25_DifffromtheValuationintheCourseofTransofBusCorpTxt: Label 'A.II.2.5. Diff. from the Valuation in the Course of Trans. of Bus. Corp. (+/-)';
        AIII_FundsfromProfitTxt: Label 'A.III. Funds from Profit';
        AIII1_OtherReserveFundsTxt: Label 'A.III.1. Other Reserve Funds';
        AIII2_StatutoryandOtherFundsTxt: Label 'A.III.2. Statutory and Other Funds';
        AIV_NetProfitorLossfromPreviousYearsTxt: Label 'A.IV. Net Profit or Loss from Previous Years (+/-)';
        AIV1_RetainedEarningsfromPreviousYearsTxt: Label 'A.IV.1. Retained Earnings from Previous Years';
        AIV2_AccumulatedLossesfromPreviousYearsTxt: Label 'A.IV.2. Accumulated Losses from Previous Years (-)';
        AIV3_OtherNetProfitorLossfromPreviousYearsTxt: Label 'A.IV.3. Other Net Profit from Previous Years (+/-)';
        AV_NetProfitorLossfortheCurrentPeriodTxt: Label 'A.V. Net Profit or Loss for the Current Period';
        AVI_DecidedabouttheAdvancePaymentsofProfitShareTxt: Label 'A.VI. Decided about the Advance Payments of Profit Share (-)';
        BC_LiabilitiesExternalResourcesTxt: Label 'B. + C. Liabilities (External Resources)';
        B_ProvisionsTxt: Label 'B. Provisions';
        B1_ProvisionforPensionandSimilarPayablesTxt: Label 'B.1. Provision for Pension and Similar Payables';
        B2_IncomeTaxProvisionTxt: Label 'B.2. Income Tax Provision';
        B3_ProvisionsunderSpecialLegislationTxt: Label 'B.3. Provisions under Special Legislation';
        B4_OtherProvisionsTxt: Label 'B.4. Other Provisions';
        C_PayablesTxt: Label 'C. Payables';
        CI_LongtermPayablesTxt: Label 'C.I. Long-term Payables';
        CI1_BondsIssuedTxt: Label 'C.I.1. Bonds Issued';
        CI11_ExchangeableBondsTxt: Label 'C.I.1.1. Exchangeable Bonds';
        CI12_OtherBondsTxt: Label 'C.I.1.2. Other Bonds';
        CI2_PayablestoCreditInstitutionsTxt: Label 'C.I.2. Payables to Credit Institutions';
        CI3_LongtermAdvancePaymentsReceivedTxt: Label 'C.I.3. Long-term Advance Payments Received';
        CI4_TradePayablesTxt: Label 'C.I.4. Trade Payables';
        CI5_LongtermBillsofExchangetobePaidTxt: Label 'C.I.5. Long-term Bills of Exchange to be Paid';
        CI6_PayablesControlledorControllingEntityTxt: Label 'C.I.6. Payables - Controlled or Controlling Entity';
        CI7_PayablesSignificantInfluenceTxt: Label 'C.I.7. Payables - Significant Influence';
        CI8_DeferredTaxLiabilityTxt: Label 'C.I.8. Deferred Tax Liability';
        CI9_PayablesOthersTxt: Label 'C.I.9. Payables - Others';
        CI91_PayablestoEquityHoldersTxt: Label 'C.I.9.1. Payables to Equity Holders';
        CI92_EstimatedPayablesTxt: Label 'C.I.9.2. Estimated Payables';
        CI93_OtherLiabilitiesTxt: Label 'C.I.9.3. Other Liabilities';
        CII_ShorttermPayablesTxt: Label 'C.II. Short-term Payables';
        CII1_BondsIssuedTxt: Label 'C.II.1. Bonds Issued';
        CII11_ExchangeableBondsTxt: Label 'C.II.1.1. Exchangeable Bonds';
        CII12_OtherBondsTxt: Label 'C.II.1.2. Other Bonds';
        CII2_PayablestoCreditInstitutionsTxt: Label 'C.II.2. Payables to Credit Institutions';
        CII3_ShorttermAdvancePaymentsReceivedTxt: Label 'C.II.3. Short-term Advance Payments Received';
        CII4_TradePayablesTxt: Label 'C.II.4. Trade Payables';
        CII5_ShorttermBillsofExchangetobePaidTxt: Label 'C.II.5. Short-term Bills of Exchange to be Paid';
        CII6_PayablesControlledorControllingEntityTxt: Label 'C.II.6. Payables - Controlled or Controlling Entity';
        CII7_PayablesSignificantInfluenceTxt: Label 'C.II.7. Payables - Significant Influence';
        CII8_PayablesOthersTxt: Label 'C.II.8. Payables - Others';
        CII81_PayablestoEquityHoldersTxt: Label 'C.II.8.1. Payables to Equity Holders';
        CII82_ShorttermFinancialAssistanceTxt: Label 'C.II.8.2. Short-term Financial Assistance';
        CII83_PayrollPayablesTxt: Label 'C.II.8.3. Payroll Payables';
        CII84_PayablesSocialSecurityandHealthInsuranceTxt: Label 'C.II.8.4. Payables - Social Security and Health Insurance';
        CII85_StateTaxLiabilitiesandGrantsTxt: Label 'C.II.8.5. State - Tax Liabilities and Grants';
        CII86_EstimatedPayablesTxt: Label 'C.II.8.6. Estimated Payables';
        CII87_AnotherPayablesTxt: Label 'C.II.8.7. Another Payables';
        CIII_AccruedLiabilitiesTxt: Label 'C.III. Accrued Liabilities';
        CIII1_AccruedExpensesTxt: Label 'C.III.1. Accrued Expenses';
        CIII2_DeferredRevenuesTxt: Label 'C.III.2. Deferred Revenues';
        D_AccruedLiabilitiesTxt: Label 'D. Accrued Liabilities';
        D1_AccruedExpensesTxt: Label 'D.1. Accrued Expenses';
        D2_DeferredRevenuesTxt: Label 'D.2. Deferred Revenues';
        IncomeStatementTxt: Label 'Income Statement';
        I_RevenuesfromOwnProductsandServicesTxt: Label 'I. Revenues from Own Products and Services';
        II_RevenuesfromMerchandiseTxt: Label 'II. Revenues from Merchandise';
        A_ConsumptionforProductsTxt: Label 'A. Consumption for Products';
        A1_CostsofGoodsSoldTxt: Label 'A.1. Costs of Goods Sold';
        A2_MaterialandEnergyConsumptionTxt: Label 'A.2. Material and Energy Consumption';
        A3_ServicesTxt: Label 'A.3. Services';
        B_ChangesinInventoryofOwnProductsTxt: Label 'B. Changes in Inventory of Own Products (+/-)';
        C_CapitalizationTxt: Label 'C. Capitalization (-)';
        D_PersonalCostsTxt: Label 'D. Personal Costs';
        D1_WagesandSalariesTxt: Label 'D.1. Wages and Salaries';
        D2_SocialSecurityandHealthInsuranceCostsandOtherCostsTxt: Label 'D.2. Social Security and Health Insurance Costs and Other Costs';
        D21_SocialSecurityandHealthInsuranceTxt: Label 'D.2.1. Social Security and Health Insurance';
        D22_OtherCostsTxt: Label 'D.2.2. Other Costs';
        E_OperatingPartAdjustmentsTxt: Label 'E. Operating Part Adjustments';
        E1_IntangibleandTangibleFixedAssestsAdjustmentsTxt: Label 'E.1. Intangible and Tangible Fixed Assets Adjustments';
        E11_IntangibleandTangibleFixedAssetsAdjustmentsPermanentTxt: Label 'E.1.1. Intangible and Tangible Fixed Assets Adjustments - Permanent';
        E12_IntangibleandTangibleFixedAssetsAdjustmentsTemporaryTxt: Label 'E.1.2. Intangible and Tangible Fixed Assets Adjustments - Temporary';
        E2_InventoriesAdjustmentsTxt: Label 'E.2. Inventories Adjustments';
        E3_ReceivablesAdjustmentsTxt: Label 'E.3. Receivables Adjustments';
        III_OtherOperatingRevenuesTxt: Label 'III. Other Operating Revenues';
        III1_RevenuesfromSalesofFixedAssetsTxt: Label 'III.1. Revenues from Sales of Fixed Assets';
        III2_RevenuesfromSalesofMaterialTxt: Label 'III.2. Revenues from Sales of Material';
        III3_AnotherOperatingRevenuesTxt: Label 'III.3. Another Operating Revenues';
        F_OtherOperatingCostsTxt: Label 'F. Other Operating Costs';
        F1_NetBookValueofFixedAssetsSoldTxt: Label 'F.1. Net Book Value of Fixed Assets Sold';
        F2_NetBookValueofMaterialSoldTxt: Label 'F.2. Net Book Value of Material Sold';
        F3_TaxesandFeesinOperatingPartTxt: Label 'F.3. Taxes and Fees in Operating Part';
        F4_ProvisionsinOperatingPartandComplexPrepaidExpensesTxt: Label 'F.4. Provisions in Operating Part and Complex Prepaid Expenses';
        F5_OtherOperatingCostsTxt: Label 'F.5. Other Operating Costs';
        OperatingProfitTxt: Label '* Operating Profit/Loss (+/-)';
        IV_RevenuesfromLongtermFinancialAssestsSharesTxt: Label 'IV. Revenues from Long-term Financial Assests - Shares';
        IV1_RevenuesfromSharesControlledorControllingEntityTxt: Label 'IV.1. Revenues from Shares - Controlled or Controlling Entity';
        IV2_OtherRevenuesfromSharesTxt: Label 'IV.2. Other Revenues from Shares';
        G_CostsofSharesSoldTxt: Label 'G. Costs of Shares Sold';
        V_RevenuesfromOtherLongtermFinancialAssetsTxt: Label 'V. Revenues from Other Long-term Financial Assets';
        V1_RevenuesfromOtherLongtermFinancialAssetsControlledorControllingTxt: Label 'V.1. Revenues from Other Long-term Financial Assets - Controlled or Controlling';
        V2_OtherRevenuesfromOtherLongtermFinancialAssetsTxt: Label 'V.2. Other Revenues from Other Long-term Financial Assets';
        H_CostsRelatedtoOtherLongtermFinancialAssetsTxt: Label 'H. Costs Related to Other Long-term Financial Assets';
        VI_InterestRevenuesandSimilarRevenuesTxt: Label 'VI. Interest Revenues and Similar Revenues';
        VI1_InterestRevenuesandSimilarRevenuesControlledorControllingEntityTxt: Label 'VI.1. Interest Revenues and Similar Revenues - Controlled or Controlling Entity';
        VI2_OtherInterestRevenuesandSimilarRevenuesTxt: Label 'VI.2. Other Interest Revenues and Similar Revenues';
        I_AdjustmentsandProvisionsinFinancialPartTxt: Label 'I. Adjustments and Provisions in Financial Part';
        J_InterestCostsandSimilarCostsTxt: Label 'J. Interest Costs and Similar Costs';
        J1_InterestCostsandSimilarCostsControlledorControllingEntityTxt: Label 'J.1. Interest Costs and Similar Costs - Controlled or Controlling Entity';
        J2_OtherInterestCostsandSimilarCostsTxt: Label 'J.2. Other Interest Costs and Similar Costs';
        VII_OtherFinancialRevenuesTxt: Label 'VII. Other Financial Revenues';
        K_OtherFinancialCostsTxt: Label 'K. Other Financial Costs';
        ProfitLossfromFinancialOperationsTxt: Label '* Profit/Loss from Financial Operations (+/-)';
        ProfitLossbeforeTaxTxt: Label '** Profit/Loss before Tax (+/-)';
        L_IncomeTaxTxt: Label 'L. Income Tax';
        L1_IncomeTaxDueTxt: Label 'L.1. Income Tax - Due';
        L2_IncomeTaxDeferredTxt: Label 'L.2. Income Tax - Deferred (+/-)';
        ProfitLossafterTaxTxt: Label '** Profit/Loss after Tax (+/-)';
        M_TransferofShareinProfittoEquityHoldersTxt: Label 'M. Transfer of Share in Profit to Equity Holders (+/-)';
        ProfitLossofAccountingPeriodTxt: Label '*** Profit/Loss of Accounting Period (+/-)';
        NetTurnoverofAccountingPeriodTxt: Label '* Net Turnover of Accounting Period';
        TwoPlaceholdersTok: Label '%1|%2', Locked = true;
        ThreePlaceholdersTok: Label '%1|%2|%3', Locked = true;
        FourPlaceholdersTok: Label '%1|%2|%3|%4', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"G/L Account Category Mgt.", 'OnBeforeInitializeAccountCategories', '', false, false)]
    local procedure InitializeAccountCategories(var IsHandled: Boolean)
    var
        GLAccountCategory: Record "G/L Account Category";
        GLAccount: Record "G/L Account";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        CategoryID: array[6] of Integer;
    begin
        if IsHandled then
            exit;

        GLAccount.SetFilter("Account Subcategory Entry No.", '<>0');
        if not GLAccount.IsEmpty() then
            if not GLAccountCategory.IsEmpty() then
                exit;

        GLAccount.ModifyAll("Account Subcategory Entry No.", 0);
        GLAccountCategory.DeleteAll();
        CategoryID[1] := GLAccountCategoryMgt.AddCategory(0, 0, GLAccountCategory."Account Category"::Assets, '', true, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Assets, A_ReceivablesfromSubscribedCapitalTxt, false,
                GLAccountCategory."Additional Report Definition"::"Financing Activities");
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Assets, B_FixedAssestsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Assets, BI_IntangibleFixedAssetsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, BI1_IntangibleResultsofResearchandDevelopmentTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, BI2_ValuableRightsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, BI21_SoftwareTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, BI22_OtherValuableRightsTxt, false, 0);
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, BI3_GoodwillTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, BI4_OtherIntangibleFixedAssetsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, BI5_AdvancePaymentsforIntangFAandIntangFAinProgressTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, BI51_AdvancePaymentsforIntangibleFixedAssetsTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, BI52_IntangibleFixedAssestsinProgressTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Assets, BII_TangibleFixedAssetsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, BII1_LandsAndBuildingsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, BII11_LandsTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, BII12_BuildingsTxt, false, 0);
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, BII2_FixedMovablesandtheCollectionsofFixedMovablesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, BII3_ValuationAdjustmenttoAcquiredAssetsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, BII4_OtherTangibleFixedAssetsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, BII41_PerennialCropsTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, BII42_FullgrownAnimalsandGroupsThereofTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, BII43_OtherTangibleFixedAssetsTxt, false, 0);
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, BII5_AdvancePaymentsforTangFAandTangFAinProgressTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, BII51_AdvancePaymentsForTangibleFixedAssetsTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, BII52_TangibleFixedAssetsinProgressTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Assets, BIII_LongtermFinancialAssetsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, BIII1_SharesControlledorControllingEntityTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, BIII2_LoansandCreditsControlledorControllingPersonTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, BIII3_SharesSignificantInfluenceTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, BIII4_LoansandCreditsSignificantInfluenceTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, BIII5_OtherLongtermSercuritiesandSharesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, BIII6_LoansandCreditsOthersTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, BIII7_OtherLongtermFinancialAssetsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, BIII71_AnotherLongtermFinancialAssetsTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, BIII72_AdvancePaymentsForLongtermFinancialAssetsTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Assets, C_CurrentAssetsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Investing Activities");
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Assets, CI_InventoryTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, CI1_MaterialTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, CI2_WorkinProgressandSemiFinishedGoodsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, CI3_FinishedProductsandGoodsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, CI31_FinishedProductsTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, CI32_GoodsTxt, false, 0);
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, CI4_YoungandOtherAnimalsandGroupsThereofTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, CI5_AdvancedPaymentsforInventoryTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Assets, CII_ReceivablesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, CII1_LongtermReceivablesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, CII11_TradeReceivablesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, CII12_ReceivablesControlledorControllingEntityTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, CII13_ReceivablesSignificantInfluenceTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, CII14_DeferredTaxReceivablesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, CII15_ReceivablesOthersTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Assets, CII151_ReceivablesfromEquityHoldersTxt, false, 0);
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Assets, CII152_LongtermAdvancedPaymentsTxt, false, 0);
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Assets, CII153_EstimatedReceivablesTxt, false, 0);
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Assets, CII154_OtherReceivablesTxt, false, 0);
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, CII2_ShorttermReceivablesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, CII21_TradeReceivablesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, CII22_ReceivablesControlledorControllingEntityTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, CII23_ReceivablesSignificantInfluenceTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, CII24_ReceivablesOthersTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Assets, CII241_ReceivablesfromEquityHoldersTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Assets, CII242_SocialSecurityandHealthInsuranceTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Assets, CII243_StateTaxReveiablesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Assets, CII244_ShorttermAdvancedPaymentsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Assets, CII245_EstimatedReceivablesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Assets, CII246_OtherReceivablesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, CII3_AccruedAssetsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, CII31_PrepaidExpensesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, CII32_ComplexPrepaidExpensesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Assets, CII33_AccruedIncomesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Assets, CIII_ShorttermFinancialAssetsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Financing Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, CIII1_SharesControlledorControllingEntityTxt, false,
                GLAccountCategory."Additional Report Definition"::"Financing Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, CIII2_OtherShorttermFinancialAssetsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Financing Activities");
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Assets, CIV_FundsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Cash Accounts");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, CIV1_CashTxt, false,
                GLAccountCategory."Additional Report Definition"::"Cash Accounts");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Assets, CIV2_BankAccountsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Cash Accounts");
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Assets, D_AccruedAssetsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Assets, D1_PrepaidExpensesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Assets, D2_ComplexPrepaidExpensesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Assets, D3_AccruedIncomesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[1] :=
            GLAccountCategoryMgt.AddCategory(0, 0, GLAccountCategory."Account Category"::Liabilities, '', true, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Liabilities, A_EquityTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Liabilities, AI_RegisteredCapitalTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Liabilities, AI1_RegisteredCapitalTxt, false, 0);
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Liabilities, AI2_CompanysOwnSharesTxt, false, 0);
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Liabilities, AI3_ChangesofRegisteredCapitalTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Liabilities, AII_CapitalSurplusandCapitalFundsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Liabilities, AII1_CapitalSurplusTxt, false, 0);
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Liabilities, AII2_CapitalFundsTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, AII21_OtherCapitalFundsTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, AII22_GainsandLossesfromRevaluationffAssestsandLiabilitiesTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, AII23_GainsandLossesfromRevalinCourseofTransofBusCorpTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, AII24_DiffResultingfromTransformationsofBusinessCorporationsTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, AII25_DifffromtheValuationintheCourseofTransofBusCorpTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Liabilities, AIII_FundsfromProfitTxt, false,
                GLAccountCategory."Additional Report Definition"::"Retained Earnings");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Liabilities, AIII1_OtherReserveFundsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Retained Earnings");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Liabilities, AIII2_StatutoryAndOtherFundsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Retained Earnings");
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Liabilities, AIV_NetProfitorLossfromPreviousYearsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Retained Earnings");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Liabilities, AIV1_RetainedEarningsfromPreviousYearsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Retained Earnings");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Liabilities, AIV2_AccumulatedLossesfromPreviousYearsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Retained Earnings");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Liabilities, AIV3_OtherNetProfitorLossfromPreviousYearsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Retained Earnings");
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Liabilities, AV_NetProfitorLossfortheCurrentPeriodTxt, false,
                GLAccountCategory."Additional Report Definition"::"Retained Earnings");
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Liabilities, AVI_DecidedabouttheAdvancePaymentsofProfitShareTxt, false,
                GLAccountCategory."Additional Report Definition"::"Distribution to Shareholders");
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Liabilities, BC_LiabilitiesExternalResourcesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Liabilities, B_ProvisionsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Liabilities, B1_ProvisionforPensionandSimilarPayablesTxt, false, 0);
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Liabilities, B2_IncomeTaxProvisionTxt, false, 0);
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Liabilities, B3_ProvisionsunderSpecialLegislationTxt, false, 0);
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Liabilities, B4_OtherProvisionsTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Liabilities, C_PayablesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Liabilities, CI_LongtermPayablesTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CI1_BondsIssuedTxt, false, 0);
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Liabilities, CI11_ExchangeableBondsTxt, false, 0);
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Liabilities, CI12_OtherBondsTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CI2_PayablestoCreditInstitutionsTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CI3_LongtermAdvancePaymentsReceivedTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CI4_TradePayablesTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CI5_LongtermBillsofExchangetobePaidTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CI6_PayablesControlledorControllingEntityTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CI7_PayablesSignificantInfluenceTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CI8_DeferredTaxLiabilityTxt, false, 0);
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CI9_PayablesOthersTxt, false, 0);
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Liabilities, CI91_PayablestoEquityHoldersTxt, false, 0);
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Liabilities, CI92_EstimatedPayablesTxt, false, 0);
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Liabilities, CI93_OtherLiabilitiesTxt, false, 0);
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Liabilities, CII_ShorttermPayablesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CII1_BondsIssuedTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Liabilities, CII11_ExchangeableBondsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Financing Activities");
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Liabilities, CII12_OtherBondsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Financing Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CII2_PayablestoCreditInstitutionsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Financing Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CII3_ShorttermAdvancePaymentsReceivedTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CII4_TradePayablesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CII5_ShorttermBillsofExchangetobePaidTxt, false,
                GLAccountCategory."Additional Report Definition"::"Financing Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CII6_PayablesControlledorControllingEntityTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CII7_PayablesSignificantInfluenceTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CII8_PayablesOthersTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Liabilities, CII81_PayablestoEquityHoldersTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Liabilities, CII82_ShorttermFinancialAssistanceTxt, false,
                GLAccountCategory."Additional Report Definition"::"Financing Activities");
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Liabilities, CII83_PayrollPayablesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Liabilities, CII84_PayablesSocialSecurityandHealthInsuranceTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Liabilities, CII85_StateTaxLiabilitiesAndGrantsTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Liabilities, CII86_EstimatedPayablesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[6] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[5], GLAccountCategory."Account Category"::Liabilities, CII87_AnotherPayablesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Liabilities, CIII_AccruedLiabilitiesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CIII1_AccruedExpensesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[5] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[4], GLAccountCategory."Account Category"::Liabilities, CIII2_DeferredRevenuesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Liabilities, D_AccruedLiabilitiesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Liabilities, D1_AccruedExpensesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Liabilities, D2_DeferredRevenuesTxt, false,
                GLAccountCategory."Additional Report Definition"::"Operating Activities");
        CategoryID[1] :=
            GLAccountCategoryMgt.AddCategory(0, 0, 0, IncomeStatementTxt, true, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Income, I_RevenuesfromOwnProductsandServicesTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Income, II_RevenuesfromMerchandiseTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, A_ConsumptionforProductsTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Expense, A1_CostsofGoodsSoldTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Expense, A2_MaterialAndEnergyConsumptionTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Expense, A3_ServicesTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, B_ChangesinInventoryofOwnProductsTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, C_CapitalizationTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, D_PersonalCostsTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Expense, D1_WagesandSalariesTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Expense, D2_SocialSecurityandHealthInsuranceCostsandOtherCostsTxt, false, 0);
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Expense, D21_SocialSecurityandHealthInsuranceTxt, false, 0);
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Expense, D22_OtherCostsTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, E_OperatingPartAdjustmentsTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Expense, E1_IntangibleandTangibleFixedAssestsAdjustmentsTxt, false, 0);
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Expense, E11_IntangibleandTangibleFixedAssetsAdjustmentsPermanentTxt, false, 0);
        CategoryID[4] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[3], GLAccountCategory."Account Category"::Expense, E12_IntangibleandTangibleFixedAssetsAdjustmentsTemporaryTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Expense, E2_InventoriesAdjustmentsTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Expense, E3_ReceivablesAdjustmentsTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Income, III_OtherOperatingRevenuesTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Income, III1_RevenuesfromSalesofFixedAssetsTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Income, III2_RevenuesfromSalesofMaterialTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Income, III3_AnotherOperatingRevenuesTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, F_OtherOperatingCostsTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Expense, F1_NetBookValueOfFixedAssetsSoldTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Expense, F2_NetBookValueofMaterialSoldTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Expense, F3_TaxesandFeesinOperatingPartTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Expense, F4_ProvisionsinOperatingPartandComplexPrepaidExpensesTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Expense, F5_OtherOperatingCostsTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, OperatingProfitTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Income, IV_RevenuesFromLongtermFinancialAssestsSharesTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Income, IV1_RevenuesfromSharesControlledorControllingEntityTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Income, IV2_OtherRevenuesFromSharesTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, G_CostsofSharesSoldTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Income, V_RevenuesFromOtherLongtermFinancialAssetsTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Income, V1_RevenuesfromOtherLongtermFinancialAssetsControlledorControllingTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Income, V2_OtherRevenuesFromOtherLongtermFinancialAssetsTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, H_CostsRelatedToOtherLongtermFinancialAssetsTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Income, VI_InterestRevenuesandSimilarRevenuesTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Income, VI1_InterestRevenuesandSimilarRevenuesControlledorControllingEntityTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Income, VI2_OtherInterestRevenuesandSimilarRevenuesTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, I_AdjustmentsandProvisionsinFinancialPartTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, J_InterestCostsandSimilarCostsTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Expense, J1_InterestCostsandSimilarCostsControlledorControllingEntityTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Expense, J2_OtherInterestCostsandSimilarCostsTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Income, VII_OtherFinancialRevenuesTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, K_OtherFinancialCostsTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, ProfitLossfromFinancialOperationsTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, ProfitLossbeforeTaxTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, L_IncomeTaxTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Expense, L1_IncomeTaxDueTxt, false, 0);
        CategoryID[3] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[2], GLAccountCategory."Account Category"::Expense, L2_IncomeTaxDeferredTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, ProfitLossafterTaxTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, M_TransferofShareinProfittoEquityHoldersTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, ProfitLossofAccountingPeriodTxt, false, 0);
        CategoryID[2] :=
            GLAccountCategoryMgt.AddCategory(0, CategoryID[1], GLAccountCategory."Account Category"::Expense, NetTurnoverofAccountingPeriodTxt, false, 0);

        IsHandled := true;
    end;

    procedure GetBI21Software(): Text
    begin
        exit(BI21_SoftwareTxt);
    end;

    procedure GetBII12Buildings(): Text
    begin
        exit(BII12_BuildingsTxt);
    end;

    procedure GetBII2FixedMovablesAndtheCollectionsOfFixedMovables(): Text
    begin
        exit(BII2_FixedMovablesandtheCollectionsofFixedMovablesTxt);
    end;

    procedure GetBI52IntangibleFixedAssestsInProgress(): Text
    begin
        exit(BI52_IntangibleFixedAssestsinProgressTxt);
    end;

    procedure GetBII52TangibleFixedAssetsInProgress(): Text
    begin
        exit(BII52_TangibleFixedAssetsinProgressTxt);
    end;

    procedure GetCI1Material(): Text
    begin
        exit(CI1_MaterialTxt);
    end;

    procedure GetCI2WorkinProgressAndSemiFinishedGoods(): Text
    begin
        exit(CI2_WorkinProgressandSemiFinishedGoodsTxt);
    end;

    procedure GetCI31FinishedProducts(): Text
    begin
        exit(CI31_FinishedProductsTxt);
    end;

    procedure GetCI32Goods(): Text
    begin
        exit(CI32_GoodsTxt);
    end;

    procedure GetCIV1Cash(): Text
    begin
        exit(CIV1_CashTxt);
    end;

    procedure GetCIV2BankAccounts(): Text
    begin
        exit(CIV2_BankAccountsTxt);
    end;

    procedure GetCII2PayablesToCreditInstitutions(): Text
    begin
        exit(CII2_PayablestoCreditInstitutionsTxt);
    end;

    procedure GetCIII2OtherShorttermFinancialAssets(): Text
    begin
        exit(CIII2_OtherShorttermFinancialAssetsTxt);
    end;

    procedure GetCII21TradeReceivables(): Text
    begin
        exit(CII21_TradeReceivablesTxt);
    end;

    procedure GetCII244ShorttermAdvancedPayments(): Text
    begin
        exit(CII244_ShorttermAdvancedPaymentsTxt);
    end;

    procedure GetCII4TradePayables(): Text
    begin
        exit(CII4_TradePayablesTxt);
    end;

    procedure GetCII3ShorttermAdvancePaymentsReceived(): Text
    begin
        exit(CII3_ShorttermAdvancePaymentsReceivedTxt);
    end;

    procedure GetCII83PayrollPayables(): Text
    begin
        exit(CII83_PayrollPayablesTxt);
    end;

    procedure GetCII84PayablesSocialSecurityAndHealthInsurance(): Text
    begin
        exit(CII84_PayablesSocialSecurityandHealthInsuranceTxt);
    end;

    procedure GetCII85StateTaxLiabilitiesAndGrants(): Text
    begin
        exit(CII85_StateTaxLiabilitiesAndGrantsTxt);
    end;

    procedure GetCII245EstimatedReceivables(): Text
    begin
        exit(CII245_EstimatedReceivablesTxt);
    end;

    procedure GetCII86EstimatedPayables(): Text
    begin
        exit(CII86_EstimatedPayablesTxt);
    end;

    procedure GetCII246OtherReceivables(): Text
    begin
        exit(CII246_OtherReceivablesTxt);
    end;

    procedure GetAI1RegisteredCapital(): Text
    begin
        exit(AI1_RegisteredCapitalTxt);
    end;

    procedure GetAIII1OtherReserveFunds(): Text
    begin
        exit(AIII1_OtherReserveFundsTxt);
    end;

    procedure GetAIV1RetainedEarningsFromPreviousYears(): Text
    begin
        exit(AIV1_RetainedEarningsfromPreviousYearsTxt);
    end;

    procedure GetCI2PayablesToCreditInstitutions(): Text
    begin
        exit(CI2_PayablestoCreditInstitutionsTxt);
    end;

    procedure GetA2MaterialAndEnergyConsumption(): Text
    begin
        exit(A2_MaterialAndEnergyConsumptionTxt);
    end;

    procedure GetA1CostsOfGoodsSold(): Text
    begin
        exit(A1_CostsofGoodsSoldTxt);
    end;

    procedure GetA3Services(): Text
    begin
        exit(A3_ServicesTxt);
    end;

    procedure GetD1WagesAndSalaries(): Text
    begin
        exit(D1_WagesandSalariesTxt);
    end;

    procedure GetD21SocialSecurityandHealthInsurance(): Text
    begin
        exit(D21_SocialSecurityandHealthInsuranceTxt);
    end;

    procedure GetD22OtherCosts(): Text
    begin
        exit(D22_OtherCostsTxt);
    end;

    procedure GetF3TaxesAndFeesInOperatingPart(): Text
    begin
        exit(F3_TaxesandFeesinOperatingPartTxt);
    end;

    procedure GetF1NetBookValueOfFixedAssetsSold(): Text
    begin
        exit(F1_NetBookValueOfFixedAssetsSoldTxt);
    end;

    procedure GetF2NetBookValueofMaterialSold(): Text
    begin
        exit(F2_NetBookValueofMaterialSoldTxt);
    end;

    procedure GetF5OtherOperatingCosts(): Text
    begin
        exit(F5_OtherOperatingCostsTxt);
    end;

    procedure GetE11IntangibleandTangibleFixedAssetsAdjustmentsPermanent(): Text
    begin
        exit(E11_IntangibleandTangibleFixedAssetsAdjustmentsPermanentTxt);
    end;

    procedure GetF4ProvisionsinOperatingPartandComplexPrepaidExpenses(): Text
    begin
        exit(F4_ProvisionsinOperatingPartandComplexPrepaidExpensesTxt);
    end;

    procedure GetE3ReceivablesAdjustments(): Text
    begin
        exit(E3_ReceivablesAdjustmentsTxt);
    end;

    procedure GetE12IntangibleAndTangibleFixedAssetsAdjustmentsTemporary(): Text
    begin
        exit(E12_IntangibleandTangibleFixedAssetsAdjustmentsTemporaryTxt);
    end;

    procedure GetJ2OtherInterestCostsAndSimilarCosts(): Text
    begin
        exit(J2_OtherInterestCostsandSimilarCostsTxt);
    end;

    procedure GetKOtherFinancialCosts(): Text
    begin
        exit(K_OtherFinancialCostsTxt);
    end;

    procedure GetIAdjustmentsandProvisionsInFinancialPart(): Text
    begin
        exit(I_AdjustmentsandProvisionsinFinancialPartTxt);
    end;

    procedure GetBChangesInInventoryOfOwnProducts(): Text
    begin
        exit(B_ChangesinInventoryofOwnProductsTxt);
    end;

    procedure GetCCapitalization(): Text
    begin
        exit(C_CapitalizationTxt);
    end;

    procedure GetL1IncomeTaxDue(): Text
    begin
        exit(L1_IncomeTaxDueTxt);
    end;

    procedure GetL2IncomeTaxDeferred(): Text
    begin
        exit(L2_IncomeTaxDeferredTxt);
    end;

    procedure GetIRevenuesFromOwnProductsAndServices(): Text
    begin
        exit(I_RevenuesfromOwnProductsandServicesTxt);
    end;

    procedure GetIIRevenuesFromMerchandise(): Text
    begin
        exit(II_RevenuesfromMerchandiseTxt);
    end;

    procedure GetIII1RevenuesFromSalesOfFixedAssets(): Text
    begin
        exit(III1_RevenuesfromSalesofFixedAssetsTxt);
    end;

    procedure GetIII2RevenuesOfMaterialSold(): Text
    begin
        exit(III2_RevenuesfromSalesofMaterialTxt);
    end;

    procedure GetIII3AnotherOperatingRevenues(): Text
    begin
        exit(III3_AnotherOperatingRevenuesTxt);
    end;

    procedure GetVI2OtherInterestRevenuesAndSimilarRevenues(): Text
    begin
        exit(VI2_OtherInterestRevenuesandSimilarRevenuesTxt);
    end;

    procedure GetVIIOtherFinancialRevenues(): Text
    begin
        exit(VII_OtherFinancialRevenuesTxt);
    end;

    procedure GetV1RevenuesFromOtherLongtermFinancialAssetsControlledOrControlling(): Text
    begin
        exit(V1_RevenuesfromOtherLongtermFinancialAssetsControlledorControllingTxt);
    end;

    procedure GetD1PrepaidExpenses(): Text
    begin
        exit(D1_PrepaidExpensesTxt);
    end;

    procedure GetD2ComplexPrepaidExpenses(): Text
    begin
        exit(D2_ComplexPrepaidExpensesTxt);
    end;

    procedure GetD3AccruedIncomes(): Text
    begin
        exit(D3_AccruedIncomesTxt);
    end;

    procedure GetD1AccruedExpenses(): Text
    begin
        exit(D1_AccruedExpensesTxt);
    end;

    procedure GetD2DeferredRevenues(): Text
    begin
        exit(D2_DeferredRevenuesTxt);
    end;

    procedure GetBI1IntangibleResultsofResearchandDevelopment(): Text
    begin
        exit(BI1_IntangibleResultsofResearchandDevelopmentTxt);
    end;

    procedure GetBI22OtherValuableRights(): Text
    begin
        exit(BI22_OtherValuableRightsTxt);
    end;

    procedure GetBI3Goodwill(): Text
    begin
        exit(BI3_GoodwillTxt);
    end;

    procedure GetBI4OtherIntangibleFixedAssets(): Text
    begin
        exit(BI4_OtherIntangibleFixedAssetsTxt);
    end;

    procedure GetBII11Lands(): Text
    begin
        exit(BII11_LandsTxt);
    end;

    procedure GetB2IncomeTaxProvision(): Text
    begin
        exit(B2_IncomeTaxProvisionTxt);
    end;

    procedure GetB4OtherProvisions(): Text
    begin
        exit(B4_OtherProvisionsTxt);
    end;

    procedure GetCI3LongtermAdvancePaymentsReceived(): Text
    begin
        exit(CI3_LongtermAdvancePaymentsReceivedTxt);
    end;

    local procedure SetAccountSubcategory(TableNo: Integer; FieldNo: Integer; var AccountSubcategory: Text)
    var
        DummyCustomerPostingGroup: Record "Customer Posting Group";
        DummyGeneralPostingSetup: Record "General Posting Setup";
        DummyInventoryPostingSetup: Record "Inventory Posting Setup";
        DummyVendorPostingGroup: Record "Vendor Posting Group";
    begin
        case TableNo of
            Database::"General Posting Setup":
                case FieldNo of
                    DummyGeneralPostingSetup.FieldNo("Sales Account"):
                        AccountSubcategory := StrSubstNo(FourPlaceholdersTok,
                                GetIRevenuesFromOwnProductsAndServices(),
                                GetIIRevenuesFromMerchandise(),
                                GetIII1RevenuesFromSalesOfFixedAssets(),
                                GetIII2RevenuesOfMaterialSold());
                    DummyGeneralPostingSetup.FieldNo("Sales Line Disc. Account"),
                    DummyGeneralPostingSetup.FieldNo("Sales Inv. Disc. Account"):
                        AccountSubcategory := GetIII3AnotherOperatingRevenues();
                    DummyGeneralPostingSetup.FieldNo("COGS Account"),
                    DummyGeneralPostingSetup.FieldNo("COGS Account (Interim)"):
                        AccountSubcategory := StrSubstNo(TwoPlaceholdersTok, GetA1CostsOfGoodsSold(), GetF2NetBookValueofMaterialSold());
                    DummyGeneralPostingSetup.FieldNo("Invt. Accrual Acc. (Interim)"):
                        AccountSubcategory := GetCI32Goods();
                end;
            Database::"Customer Posting Group":
                case FieldNo of
                    DummyCustomerPostingGroup.FieldNo("Receivables Account"):
                        AccountSubcategory := GetCII21TradeReceivables();
                    DummyCustomerPostingGroup.FieldNo("Service Charge Acc."):
                        AccountSubcategory := GetVIIOtherFinancialRevenues();
                    DummyCustomerPostingGroup.FieldNo("Payment Tolerance Credit Acc."):
                        AccountSubcategory := '';
                end;
            Database::"Vendor Posting Group":
                case FieldNo of
                    DummyVendorPostingGroup.FieldNo("Payables Account"):
                        AccountSubcategory := GetCII4TradePayables();
                    DummyVendorPostingGroup.FieldNo("Service Charge Acc."):
                        AccountSubcategory := GetKOtherFinancialCosts();
                    DummyVendorPostingGroup.FieldNo("Payment Tolerance Debit Acc."):
                        AccountSubcategory := '';
                    DummyVendorPostingGroup.FieldNo("Payment Tolerance Credit Acc."):
                        AccountSubcategory := '';
                end;
            Database::"Inventory Posting Setup":
                case FieldNo of
                    DummyInventoryPostingSetup.FieldNo("Inventory Account"),
                    DummyInventoryPostingSetup.FieldNo("Inventory Account (Interim)"):
                        AccountSubcategory := StrSubstNo(ThreePlaceholdersTok,
                                GetCI1Material(),
                                GetCI31FinishedProducts(),
                                GetCI32Goods());
                end;
        end;
    end;

    local procedure SetAccountCategory(TableNo: Integer; FieldNo: Integer; var AccountCategory: Option)
    var
        DummyGeneralPostingSetup: Record "General Posting Setup";
        DummyVendorPostingGroup: Record "Vendor Posting Group";
        GLAccountCategory: Record "G/L Account Category";
    begin
        case TableNo of
            Database::"General Posting Setup":
                case FieldNo of
                    DummyGeneralPostingSetup.FieldNo("COGS Account"),
                    DummyGeneralPostingSetup.FieldNo("COGS Account (Interim)"):
                        AccountCategory := GLAccountCategory."Account Category"::Expense;
                    DummyGeneralPostingSetup.FieldNo("Invt. Accrual Acc. (Interim)"):
                        AccountCategory := GLAccountCategory."Account Category"::Assets;
                end;
            Database::"Vendor Posting Group":
                case FieldNo of
                    DummyVendorPostingGroup.FieldNo("Service Charge Acc."):
                        AccountCategory := GLAccountCategory."Account Category"::Expense;
                end;
        end;
    end;

    local procedure IsLookupWithoutCategory(TableNo: Integer; FieldNo: Integer): Boolean
    var
        DummyGeneralPostingSetup: Record "General Posting Setup";
    begin
        case TableNo of
            Database::"General Posting Setup":
                exit(
                    (FieldNo = DummyGeneralPostingSetup.FieldNo("Purch. Account")) or
                    (FieldNo = DummyGeneralPostingSetup.FieldNo("Purch. Line Disc. Account")) or
                    (FieldNo = DummyGeneralPostingSetup.FieldNo("Purch. Inv. Disc. Account")) or
                    (FieldNo = DummyGeneralPostingSetup.FieldNo("Inventory Adjmt. Account")));
        end;

        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"G/L Account Category Mgt.", 'OnBeforeLookupGLAccount', '', false, false)]
    local procedure LookupGLAccount(TableNo: Integer; FieldNo: Integer; var AccountNo: Code[20]; var AccountCategory: Option; var AccountSubcategoryFilter: Text; var IsHandled: Boolean)
    var
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
    begin
        if IsHandled then
            exit;

        if IsLookupWithoutCategory(TableNo, FieldNo) then begin
            GLAccountCategoryMgt.LookupGLAccountWithoutCategory(AccountNo);
            IsHandled := true;
            exit;
        end;

        SetAccountCategory(TableNo, FieldNo, AccountCategory);
        SetAccountSubcategory(TableNo, FieldNo, AccountSubcategoryFilter);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"G/L Account Category Mgt.", 'OnBeforeCheckGLAccount', '', false, false)]
    local procedure CheckGLAccount(TableNo: Integer; FieldNo: Integer; var AccountCategory: Option; var AccountSubcategory: Text; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        SetAccountCategory(TableNo, FieldNo, AccountCategory);
        SetAccountSubcategory(TableNo, FieldNo, AccountSubcategory);
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account Category", 'OnBeforeUpdatePresentationOrder', '', false, false)]
    local procedure UpdatePresentationOrder(var GLAccountCategory: Record "G/L Account Category"; var IsHandled: Boolean)
    var
        ParentGLAccountCategory: Record "G/L Account Category";
        PresentationOrder: Text;
    begin
        if IsHandled then
            exit;
        if GLAccountCategory."Entry No." = 0 then
            exit;
        ParentGLAccountCategory := GLAccountCategory;
        if GLAccountCategory."Sibling Sequence No." = 0 then
            GLAccountCategory."Sibling Sequence No." := GLAccountCategory."Entry No." * 10000 mod 2000000000;
        GLAccountCategory.Indentation := 0;
        PresentationOrder := Format(1000000 + GLAccountCategory."Sibling Sequence No.");
        while ParentGLAccountCategory."Parent Entry No." <> 0 do begin
            GLAccountCategory.Indentation += 1;
            ParentGLAccountCategory.Get(ParentGLAccountCategory."Parent Entry No.");
            PresentationOrder := Format(1000000 + ParentGLAccountCategory."Sibling Sequence No.") + PresentationOrder;
        end;
        case GLAccountCategory."Account Category" of
            GLAccountCategory."Account Category"::Assets:
                PresentationOrder := '0' + PresentationOrder;
            GLAccountCategory."Account Category"::Liabilities:
                PresentationOrder := '1' + PresentationOrder;
            else
                PresentationOrder := '2' + PresentationOrder;
        end;
        GLAccountCategory."Presentation Order" := CopyStr(PresentationOrder, 1, MaxStrLen(GLAccountCategory."Presentation Order"));
        GLAccountCategory.Modify();
        IsHandled := true;
    end;
}
