// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.Enums;

codeunit 31182 "Create G/L Account CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        AddGLAccountforCZ();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create G/L Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyGLAccountsOnAfterAddGLAccountsForLocalization()
    begin
        ModifyGLAccountForW1();
        ModifyGLAccountForCZ();
    end;

    local procedure AddGLAccountForCZ()
    var
        GLAccountCategory: Record "G/L Account Category";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateVATPostingGroupsCZ: Codeunit "Create VAT Posting Groups CZ";
        GLAccountCategoryMgtCZL: Codeunit "G/L Account Category Mgt. CZL";
        GLAccountIndent: Codeunit "G/L Account-Indent";
        SubCategory: Text[80];
    begin
        ContosoGLAccount.SetOverwriteData(true);

        #region Fixed Assets
        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FixedAssets(), CreateGLAccount.FixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        #region Fixed Assets - Intangible Fixed Assets
        ContosoGLAccount.InsertGLAccount(IntangibleFixedAssets(), IntangibleFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetBI1IntangibleResultsofResearchandDevelopment(), 80);
        ContosoGLAccount.InsertGLAccount(Intangibleresultsofresearchanddevelopment(), IntangibleresultsofresearchanddevelopmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetBI21Software(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Software(), CreateGLAccount.SoftwareName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetBI22OtherValuableRights(), 80);
        ContosoGLAccount.InsertGLAccount(Valuablerights(), ValuablerightsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetBI3Goodwill(), 80);
        ContosoGLAccount.InsertGLAccount(Goodwill(), GoodwillName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetBI4OtherIntangibleFixedAssets(), 80);
        ContosoGLAccount.InsertGLAccount(Otherintangiblefixedassets(), OtherintangiblefixedassetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(IntangibleFixedAssetsTotal(), IntangibleFixedAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Intangiblefixedassets() + '..' + Intangiblefixedassetstotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Fixed Assets - Tangible Fixed Assets
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TangibleFixedAssets(), CreateGLAccount.TangibleFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetBII12Buildings(), 80);
        ContosoGLAccount.InsertGLAccount(Buildings(), BuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), false, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetBII2FixedMovablesAndtheCollectionsOfFixedMovables(), 80);
        ContosoGLAccount.InsertGLAccount(Machinestoolsequipment(), MachinestoolsequipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Vehicles(), CreateGLAccount.VehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TangibleFixedAssetsTotal(), CreateGLAccount.TangibleFixedAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.TangibleFixedAssets() + '..' + CreateGLAccount.TangibleFixedAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Fixed Assets - Tangible Fixed Assets Nondeductible
        ContosoGLAccount.InsertGLAccount(Tangiblefixedassetsnondeductible(), TangiblefixedassetsnondeductibleName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetBII11Lands(), 80);
        ContosoGLAccount.InsertGLAccount(Lands(), LandsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(Tangiblefixedassetsnondeductibletotal(), TangiblefixedassetsnondeductibletotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Tangiblefixedassetsnondeductible() + '..' + TangiblefixedassetsnondeductibleTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Fixed Assets - Acquisition of Fixed Assets
        ContosoGLAccount.InsertGLAccount(Acquisitionoffixedassets(), AcquisitionoffixedassetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetBI52IntangibleFixedAssestsInProgress(), 80);
        ContosoGLAccount.InsertGLAccount(Acquisitionofintangiblefixedassets(), AcquisitionofintangiblefixedassetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetBII52TangibleFixedAssetsInProgress(), 80);
        ContosoGLAccount.InsertGLAccount(Acquisitionoftangiblefixedassets(), AcquisitionoftangiblefixedassetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(AcquisitionOfMachinery(), AcquisitionOfMachineryName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(AcquisitionOfVehicles(), AcquisitionOfVehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(Acquisitionoffixedassetstotal(), AcquisitionoffixedassetstotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Acquisitionoffixedassets() + '..' + Acquisitionoffixedassetstotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Fixed Assets - Accumulated Depreciation to Intangible Fixed Assets
        ContosoGLAccount.InsertGLAccount(Accumulateddepreciationtointangiblefixedassets(), AccumulateddepreciationtointangiblefixedassetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetBI1IntangibleResultsofResearchandDevelopment(), 80);
        ContosoGLAccount.InsertGLAccount(Accumulateddepreciationtointangibleresultsofresearchanddevelopment(), AccumulateddepreciationtointangibleresultsofresearchanddevelopmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetBI21Software(), 80);
        ContosoGLAccount.InsertGLAccount(Accumulateddepreciationtosoftware(), AccumulateddepreciationtosoftwareName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetBI22OtherValuableRights(), 80);
        ContosoGLAccount.InsertGLAccount(Accumulateddepreciationtovaluablerights(), AccumulateddepreciationtovaluablerightsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetBI3Goodwill(), 80);
        ContosoGLAccount.InsertGLAccount(Accumulateddepreciationtogoodwill(), AccumulateddepreciationtogoodwillName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetBI4OtherIntangibleFixedAssets(), 80);
        ContosoGLAccount.InsertGLAccount(Accumulateddepreciationtootherintangiblefixedassets(), AccumulateddepreciationtootherintangiblefixedassetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(Accumulateddepreciationtointangiblefixedassetstotal(), AccumulateddepreciationtointangiblefixedassetstotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Accumulateddepreciationtointangiblefixedassets() + '..' + Accumulateddepreciationtointangiblefixedassetstotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Fixed Assets - Accumulated Depreciation to Tangible Fixed Assets
        ContosoGLAccount.InsertGLAccount(AccumulatedDepreciationToTangibleFixedAssets(), AccumulatedDepreciationToTangibleFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetBII12Buildings(), 80);
        ContosoGLAccount.InsertGLAccount(AccumulatedDepreciationToBuildings(), AccumulatedDepreciationToBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetBII2FixedMovablesAndtheCollectionsOfFixedMovables(), 80);
        ContosoGLAccount.InsertGLAccount(AccumulatedDepreciationToMachinery(), AccumulatedDepreciationToMachineryName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccumulatedDepreciationToVehicles(), AccumulatedDepreciationToVehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(AccumulatedDepreciationToTangibleFixedAssetsTotal(), AccumulatedDepreciationToTangibleFixedAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, AccumulatedDepreciationToTangibleFixedAssets() + '..' + AccumulatedDepreciationToTangibleFixedAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FixedAssetsTotal(), CreateGLAccount.FixedAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.FixedAssets() + '..' + CreateGLAccount.FixedAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Inventory
        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Inventory(), CreateGLAccount.InventoryName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        #region Inventory - Material
        SubCategory := Format(GLAccountCategoryMgtCZL.GetCI1Material(), 80);
        ContosoGLAccount.InsertGLAccount(Material(), MaterialName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(AcquisitionOfMaterial(), AcquisitionOfMaterialName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21S(), false, false, false);
        ContosoGLAccount.InsertGLAccount(MaterialInStockInterim(), MaterialInStockInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(MaterialInStock(), MaterialInStockName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVarianceRawmat(), PurchaseVarianceRawmatName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(MaterialTotal(), MaterialTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Material() + '..' + MaterialTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Inventory - Inventory of Own Production
        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(InventoryOfOwnProduction(), InventoryOfOwnProductionName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        #region Inventory - Inventory of Own Production - Work in Progress
        SubCategory := Format(GLAccountCategoryMgtCZL.GetCI2WorkinProgressAndSemiFinishedGoods(), 80);
        ContosoGLAccount.InsertGLAccount(WorkInProgressBegin(), WorkInProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(WorkInProgress(), WorkInProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(WorkInProgressTotal(), WorkInProgressTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, WorkInProgress() + '..' + WorkInProgressTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Inventory - Inventory of Own Production - Finished Products
        SubCategory := Format(GLAccountCategoryMgtCZL.GetCI31FinishedProducts(), 80);
        ContosoGLAccount.InsertGLAccount(FinishedProductsBegin(), FinishedProductsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(FinishedProductsInterim(), FinishedProductsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FinishedProducts(), FinishedProductsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(FinishedProductsTotal(), FinishedProductsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, FinishedProducts() + '..' + FinishedProductsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        ContosoGLAccount.InsertGLAccount(InventoryOfOwnProductionTotal(), InventoryOfOwnProductionTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, InventoryOfOwnProduction() + '..' + InventoryOfOwnProductionTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Inventory - Goods
        SubCategory := Format(GLAccountCategoryMgtCZL.GetCI32Goods(), 80);
        ContosoGLAccount.InsertGLAccount(Goods(), GoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        #region Inventory - Goods - Acquisition of Goods
        ContosoGLAccount.InsertGLAccount(AcquisitionOfGoodsBegin(), AcquisitionOfGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(AcquisitionOfGoods(), AcquisitionOfGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), false, false, false);
        ContosoGLAccount.InsertGLAccount(DirectCostAppliedRetail(), DirectCostAppliedRetailName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), false, false, false);
        ContosoGLAccount.InsertGLAccount(AcquisitionRetail(), AcquisitionRetailName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), false, false, false);
        ContosoGLAccount.InsertGLAccount(AcquisitionRetailInterim(), AcquisitionRetailInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AcquisitionRawMaterialDomestic(), AcquisitionRawMaterialDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21S(), false, false, false);
        ContosoGLAccount.InsertGLAccount(AcquisitionRawMaterialEu(), AcquisitionRawMaterialEuName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroupsCZ.VAT21S(), false, false, false);
        ContosoGLAccount.InsertGLAccount(AcquisitionRawMaterialExport(), AcquisitionRawMaterialExportName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Export(), CreateVATPostingGroupsCZ.VAT21S(), false, false, false);
        ContosoGLAccount.InsertGLAccount(AcquisitionRawMaterial(), AcquisitionRawMaterialName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AcquisitionRawMaterialInterim(), AcquisitionRawMaterialInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(AcquisitionOfGoodsTotal(), AcquisitionOfGoodsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, AcquisitionOfGoodsBegin() + '..' + AcquisitionOfGoodsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Inventory - Goods - Goods in Stock
        ContosoGLAccount.InsertGLAccount(GoodsInStock(), GoodsInStockName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(GoodsInRetail(), GoodsInRetailName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GoodsInRetailInterim(), GoodsInRetailInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVarianceRetail(), PurchaseVarianceRetailName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(GoodsInStockTotal(), GoodsInStockTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, GoodsInStockTotal() + '..' + GoodsInStockTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        ContosoGLAccount.InsertGLAccount(GoodsTotal(), GoodsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Goods() + '..' + GoodsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InventoryTotal(), CreateGLAccount.InventoryTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Inventory() + '..' + CreateGLAccount.InventoryTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Current Financial Assets
        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(CurrentFinancialAssets(), CurrentFinancialAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        #region Current Financial Assets - Cash
        SubCategory := Format(GLAccountCategoryMgtCZL.GetCIV1Cash(), 80);
        ContosoGLAccount.InsertGLAccount(CashBegin(), CreateGLAccount.CashName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(CashDeskLm(), CashDeskLmName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(CashTotal(), CashTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CashBegin() + '..' + CashTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Current Financial Assets - Bank Accounts
        SubCategory := Format(GLAccountCategoryMgtCZL.GetCIV2BankAccounts(), 80);
        ContosoGLAccount.InsertGLAccount(BankAccounts(), BankAccountsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(BankAccountKB(), BankAccountKBName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BankAccountEUR(), BankAccountEURName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(BankAccountsTotal(), BankAccountsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, BankAccounts() + '..' + BankAccountsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        SubCategory := Format(GLAccountCategoryMgtCZL.GetCII2PayablesToCreditInstitutions(), 80);
        ContosoGLAccount.InsertGLAccount(ShortTermBankLoans(), ShortTermBankLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetCIII2OtherShorttermFinancialAssets(), 80);
        ContosoGLAccount.InsertGLAccount(ShortTermSecurities(), ShortTermSecuritiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetCIV1Cash(), 80);
        ContosoGLAccount.InsertGLAccount(CashTransfer(), CashTransferName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetCIV2BankAccounts(), 80);
        ContosoGLAccount.InsertGLAccount(Unidentifiedpayments(), UnidentifiedpaymentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(CurrentFinancialAssetsTotal(), CurrentFinancialAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CurrentFinancialAssets() + '..' + CurrentFinancialAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Netting Relationships
        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(NettingRelationships(), NettingRelationshipsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        #region Netting Relationships - Receivables
        ContosoGLAccount.InsertGLAccount(Receivables(), ReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetCII21TradeReceivables(), 80);
        ContosoGLAccount.InsertGLAccount(DomesticCustomersReceivables(), DomesticCustomersReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ForeignCustomersOutsideEUReceivables(), ForeignCustomersOutsideEUReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CustomersIntercompany(), CustomersIntercompanyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EUCustomersReceivables(), EUCustomersReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ReceivablesFromBusinessRelationFees(), ReceivablesFromBusinessRelationFeesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherReceivables(), OtherReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetCII244ShorttermAdvancedPayments(), 80);
        ContosoGLAccount.InsertGLAccount(PurchaseAdvancesDomestic(), PurchaseAdvancesDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseAdvancesForeign(), PurchaseAdvancesForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseAdvancesEU(), PurchaseAdvancesEUName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(ReceivablesTotal(), ReceivablesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Receivables() + '..' + ReceivablesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Netting Relationships - Payables
        SubCategory := Format(GLAccountCategory."Account Category"::Liabilities, 80);
        ContosoGLAccount.InsertGLAccount(Payables(), PayablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetCII4TradePayables(), 80);
        ContosoGLAccount.InsertGLAccount(DomesticVendorsPayables(), DomesticVendorsPayablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ForeignVendorsOutsideEUPayables(), ForeignVendorsOutsideEUPayablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VendorsIntercompany(), VendorsIntercompanyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EUVendorsPayables(), EUVendorsPayablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherPayables(), OtherPayablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetCII3ShorttermAdvancePaymentsReceived(), 80);
        ContosoGLAccount.InsertGLAccount(SalesAdvancesDomestic(), SalesAdvancesDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesAdvancesForeign(), SalesAdvancesForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesAdvancesEU(), SalesAdvancesEUName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Liabilities, 80);
        ContosoGLAccount.InsertGLAccount(PayablesTotal(), PayablesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Payables() + '..' + PayablesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Netting Relationships - Employee and Institutions Settlement
        SubCategory := Format(GLAccountCategory."Account Category"::Liabilities, 80);
        ContosoGLAccount.InsertGLAccount(EmployeesAndInstitutionsSettlement(), EmployeesAndInstitutionsSettlementName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetCII83PayrollPayables(), 80);
        ContosoGLAccount.InsertGLAccount(Employees(), EmployeesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PayablesToEmployees(), PayablesToEmployeesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetCII84PayablesSocialSecurityAndHealthInsurance(), 80);
        ContosoGLAccount.InsertGLAccount(SocialInstitutionsSettlement(), SocialInstitutionsSettlementName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HealthInstitutionsSettlement(), HealthInstitutionsSettlementName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Liabilities, 80);
        ContosoGLAccount.InsertGLAccount(EmployeesAndInstitutionsSettlementTotal(), EmployeesAndInstitutionsSettlementTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, EmployeesAndInstitutionsSettlement() + '..' + EmployeesAndInstitutionsSettlementTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Netting Relationships - Income Tax
        SubCategory := Format(GLAccountCategoryMgtCZL.GetCII85StateTaxLiabilitiesAndGrants(), 80);
        ContosoGLAccount.InsertGLAccount(IncomeTaxBegin(), IncomeTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(IncomeTax(), IncomeTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        ContosoGLAccount.InsertGLAccount(IncomeTaxTotal(), IncomeTaxTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, IncomeTaxBegin() + '..' + IncomeTaxTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        ContosoGLAccount.InsertGLAccount(IncomeTaxOnEmployment(), IncomeTaxOnEmploymentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        #region Netting Relationships - VAT
        ContosoGLAccount.InsertGLAccount(VAT(), VATName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(InputVAT12(), InputVAT12Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InputVAT21(), InputVAT21Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OutputVAT12(), OutputVAT12Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OutputVAT21(), OutputVAT21Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ReverseChargeVAT12(), ReverseChargeVAT12Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ReverseChargeVAT21(), ReverseChargeVAT21Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancesVAT12(), AdvancesVAT12Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancesVAT21(), AdvancesVAT21Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PostponedVATPurchase(), PostponedVATPurchaseName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VATSettlement(), VATSettlementName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        ContosoGLAccount.InsertGLAccount(VATTotal(), VATTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, VAT() + '..' + VATTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        ContosoGLAccount.InsertGLAccount(OtherTaxesAndFees(), OthertaxesandfeesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PostponedVAT(), PostponedVATName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        #region Netting Relationships - Temporary Accounts of Assets and Liabilities
        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(Temporaryaccountsofassetsandliabilities(), TemporaryaccountsofassetsandliabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetD1PrepaidExpenses(), 80);
        ContosoGLAccount.InsertGLAccount(PrepaidExpenses(), PrepaidExpensesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetD2ComplexPrepaidExpenses(), 80);
        ContosoGLAccount.InsertGLAccount(Complexprepaidexpenses(), ComplexprepaidexpensesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetD1AccruedExpenses(), 80);
        ContosoGLAccount.InsertGLAccount(AccruedExpenses(), AccruedExpensesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetD2DeferredRevenues(), 80);
        ContosoGLAccount.InsertGLAccount(DeferredRevenues(), DeferredRevenuesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetD3AccruedIncomes(), 80);
        ContosoGLAccount.InsertGLAccount(Accruedincomes(), AccruedincomesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetCII245EstimatedReceivables(), 80);
        ContosoGLAccount.InsertGLAccount(AccruedRevenueItems(), AccruedRevenueItemsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetCII86EstimatedPayables(), 80);
        ContosoGLAccount.InsertGLAccount(Accruals(), AccrualsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(Temporaryaccountsofassetsandliabilitiestotal(), TemporaryaccountsofassetsandliabilitiestotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Temporaryaccountsofassetsandliabilities() + '..' + Temporaryaccountsofassetsandliabilitiestotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        SubCategory := Format(GLAccountCategoryMgtCZL.GetCII246OtherReceivables(), 80);
        ContosoGLAccount.InsertGLAccount(Internalsettlement(), InternalsettlementName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(NettingRelationshipsTotal(), NettingRelationshipsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, NettingRelationships() + '..' + NettingRelationshipsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Equity and Long Term Payables
        SubCategory := Format(GLAccountCategory."Account Category"::Liabilities, 80);
        ContosoGLAccount.InsertGLAccount(EquityAndLongTermPayables(), EquityAndLongTermPayablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetAI1RegisteredCapital(), 80);
        ContosoGLAccount.InsertGLAccount(RegisteredCapitalAndCapitalFunds(), RegisteredCapitalAndCapitalFundsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetAIII1OtherReserveFunds(), 80);
        ContosoGLAccount.InsertGLAccount(Statutoryreserve(), StatutoryreserveName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetAIV1RetainedEarningsFromPreviousYears(), 80);
        ContosoGLAccount.InsertGLAccount(ProfitLossPreviousYears(), ProfitLossPreviousYearsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Resultofcurrentyear(), ResultofcurrentyearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetB2IncomeTaxProvision(), 80);
        ContosoGLAccount.InsertGLAccount(Incometaxprovisions(), IncometaxprovisionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetB4OtherProvisions(), 80);
        ContosoGLAccount.InsertGLAccount(Otherprovisions(), OtherprovisionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetCI2PayablesToCreditInstitutions(), 80);
        ContosoGLAccount.InsertGLAccount(MediumTermBankLoans(), MediumTermBankLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LongTermBankLoans(), LongTermBankLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgtCZL.GetCI3LongtermAdvancePaymentsReceived(), 80);
        ContosoGLAccount.InsertGLAccount(OtherLongTermPayables(), OtherLongTermPayablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Liabilities, 80);
        ContosoGLAccount.InsertGLAccount(EquityAndLongTermPayablesTotal(), EquityAndLongTermPayablesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, EquityAndLongTermPayables() + '..' + EquityAndLongTermPayablesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Expenses
        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(Expenses(), ExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        #region Expenses - Consumption of Material
        SubCategory := Format(GLAccountCategoryMgtCZL.GetA2MaterialAndEnergyConsumption(), 80);
        ContosoGLAccount.InsertGLAccount(ConsumptionOfMaterialBegin(), ConsumptionOfMaterialName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(ConsumptionOfMaterial(), ConsumptionOfMaterialName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21S(), true, false, false);
        ContosoGLAccount.InsertGLAccount(Fuel(), FuelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(ComputersConsumableMaterial(), ComputersConsumableMaterialName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(OverheadAppliedRetail(), OverheadAppliedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(ConsumptionOfMaterialTotal(), ConsumptionOfMaterialTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, ConsumptionOfMaterialBegin() + '..' + ConsumptionOfMaterialTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Expenses - Electricity
        ContosoGLAccount.InsertGLAccount(ElectricityBegin(), ElectricityName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(Electricity(), ElectricityName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);

        ContosoGLAccount.InsertGLAccount(ElectricityTotal(), ElectricityTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, ElectricityBegin() + '..' + ElectricityTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Expenses - Non-Storable Supplies
        ContosoGLAccount.InsertGLAccount(NonstorablesuppliesBegin(), NonstorablesuppliesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(Nonstorablesupplies(), NonstorablesuppliesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);

        ContosoGLAccount.InsertGLAccount(NonstorablesuppliesTotal(), NonstorablesuppliesTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, NonstorablesuppliesBegin() + '..' + NonstorablesuppliesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Expenses - COGS
        SubCategory := Format(GLAccountCategoryMgtCZL.GetA1CostsOfGoodsSold(), 80);
        ContosoGLAccount.InsertGLAccount(COGS(), COGSName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(COGSRetail(), COGSRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(COGSRetailInterim(), COGSRetailInterimName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(COGSOthers(), COGSOthersName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(COGSOthersInterim(), COGSOthersInterimName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobCorrection(), JobCorrectionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(COGSTotal(), COGSTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, COGS() + '..' + COGSTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Expenses - Services
        SubCategory := Format(GLAccountCategoryMgtCZL.GetA3Services(), 80);
        ContosoGLAccount.InsertGLAccount(Services(), ServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RepairsandMaintenance(), CreateGLAccount.RepairsandMaintenanceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(OverheadAppliedCap(), OverheadAppliedCapName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVarianceCap(), PurchaseVarianceCapName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), false, false, false);
        ContosoGLAccount.InsertGLAccount(TravelExpenses(), TravelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        ContosoGLAccount.InsertGLAccount(ServicesTotal(), ServicesTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Services() + '..' + ServicesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        ContosoGLAccount.InsertGLAccount(RepresentationCosts(), RepresentationCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.NOVAT(), true, false, false);

        #region Expenses - Other Services
        ContosoGLAccount.InsertGLAccount(OtherServicesBegin(), OtherServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(Cleaning(), CleaningName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(PhoneCharge(), PhoneChargeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(Postage(), PostageName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(Advertisement(), AdvertisementName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherServices(), OtherServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);

        ContosoGLAccount.InsertGLAccount(OtherServicesTotal(), OtherServicesTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherServicesBegin() + '..' + OtherServicesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Expenses - Personal Expenses
        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(PersonalExpenses(), PersonalExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetD1WagesAndSalaries(), 80);
        ContosoGLAccount.InsertGLAccount(SalariesAndWages(), SalariesAndWagesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Incomefromemploymentcompanions(), IncomefromemploymentcompanionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Remunerationtomembersofcompanymanagement(), RemunerationtomembersofcompanymanagementName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetD21SocialSecurityandHealthInsurance(), 80);
        ContosoGLAccount.InsertGLAccount(SocialInsurance(), SocialInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HealthInsurance(), HealthInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherSocialInsurance(), OtherSocialInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Individualsocialcostforbusinessman(), IndividualsocialcostforbusinessmanName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetD22OtherCosts(), 80);
        ContosoGLAccount.InsertGLAccount(StatutorySocialCost(), StatutorySocialCostName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othersocialcosts(), OthersocialcostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othernontaxsocialcosts(), OthernontaxsocialcostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(PersonalExpensesTotal(), PersonalExpensesTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, PersonalExpenses() + '..' + PersonalExpensesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Expenses - Other Taxes and Fees
        SubCategory := Format(GLAccountCategoryMgtCZL.GetF3TaxesAndFeesInOperatingPart(), 80);
        ContosoGLAccount.InsertGLAccount(OthertaxesandfeesBegin(), OthertaxesandfeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(Roadtax(), RoadtaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Propertytax(), PropertytaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othertaxesandfees(), OthertaxesandfeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(Othernotaxtaxesandfees(), OthernotaxtaxesandfeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);

        ContosoGLAccount.InsertGLAccount(OthertaxesandfeesTotal(), OthertaxesandfeesTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, OthertaxesandfeesBegin() + '..' + OthertaxesandfeesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Expenses - Other Operating Expenses
        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(OtheroperatingexpensesBegin(), OtheroperatingexpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetF1NetBookValueOfFixedAssetsSold(), 80);
        ContosoGLAccount.InsertGLAccount(Netbookvalueoffixedassetssold(), NetbookvalueoffixedassetssoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetF2NetBookValueofMaterialSold(), 80);
        ContosoGLAccount.InsertGLAccount(CostofmaterialsoldInterim(), CostofmaterialsoldInterimName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Costofmaterialsold(), CostofmaterialsoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetF5OtherOperatingCosts(), 80);
        ContosoGLAccount.InsertGLAccount(Presents(), PresentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ContractualPenaltiesAndInterests(), ContractualPenaltiesAndInterestsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(PaymentsTolerance(), PaymentsToleranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherPenaltiesAndInterests(), OtherPenaltiesAndInterestsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(Receivablewriteoff(), ReceivablewriteoffName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Otheroperatingexpenses(), OtheroperatingexpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(Shortagesanddamagefromoperact(), ShortagesanddamagefromoperactName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(OtheroperatingexpensesTotal(), OtheroperatingexpensesTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtheroperatingexpensesBegin() + '..' + OtheroperatingexpensesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Expenses - Depreciation and Reserves
        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(Depreciationandreserves(), DepreciationandreservesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        #region Expenses - Depreciation and Reserves - Depreciation
        SubCategory := Format(GLAccountCategoryMgtCZL.GetE11IntangibleandTangibleFixedAssetsAdjustmentsPermanent(), 80);
        ContosoGLAccount.InsertGLAccount(Depreciation(), DepreciationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(DepreciationOfBuildings(), DepreciationOfBuildingsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationOfMachinesAndTools(), DepreciationOfMachinesAndToolsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationOfVehicles(), DepreciationOfVehiclesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciationofpatents(), DepreciationofpatentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciationofsoftware(), DepreciationofsoftwareName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciationofgoodwill(), DepreciationofgoodwillName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciationofotherintangiblefixedassets(), DepreciationofotherintangiblefixedassetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(NetBookValueOfFixedAssetsDisposed(), NetBookValueOfFixedAssetsDisposedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(DepreciationTotal(), DepreciationTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Depreciation() + '..' + DepreciationTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        SubCategory := Format(GLAccountCategoryMgtCZL.GetF4ProvisionsinOperatingPartandComplexPrepaidExpenses(), 80);
        ContosoGLAccount.InsertGLAccount(Creatandsettlofreservesaccordtospecregul(), CreatandsettlofreservesaccordtospecregulName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Creationandsettlementofothersreserves(), CreationandsettlementofothersreservesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetE3ReceivablesAdjustments(), 80);
        ContosoGLAccount.InsertGLAccount(Creationandsettlementlegaladjustments(), CreationandsettlementlegaladjustmentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetE12IntangibleAndTangibleFixedAssetsAdjustmentsTemporary(), 80);
        ContosoGLAccount.InsertGLAccount(Creationandsettlementadjustmentstooperactivities(), CreationandsettlementadjustmentstooperactivitiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(DepreciationandreservesTotal(), DepreciationandreservesTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Depreciationandreserves() + '..' + DepreciationandreservesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Expenses - Financial Expenses
        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(FinancialExpenses(), FinancialExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetJ2OtherInterestCostsAndSimilarCosts(), 80);
        ContosoGLAccount.InsertGLAccount(Interest(), InterestName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetKOtherFinancialCosts(), 80);
        ContosoGLAccount.InsertGLAccount(ExchangeLossesRealized(), ExchangeLossesRealizedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ExchangeLossesUnrealized(), ExchangeLossesUnrealizedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Expensesrelatedtofinancialassets(), ExpensesrelatedtofinancialassetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Otherfinancialexpenses(), OtherfinancialexpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);

        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(FinancialExpensesTotal(), FinancialExpensesTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, FinancialExpenses() + '..' + FinancialExpensesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Expenses - Reserves and Adj. from Fin. Activities
        SubCategory := Format(GLAccountCategoryMgtCZL.GetIAdjustmentsandProvisionsInFinancialPart(), 80);
        ContosoGLAccount.InsertGLAccount(Reservesandadjfromfinactivities(), ReservesandadjfromfinactivitiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(Creationandsettlementoffinancialreserves(), CreationandsettlementoffinancialreservesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Creationandsettlementadjustments(), CreationandsettlementadjustmentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        ContosoGLAccount.InsertGLAccount(ReservesandadjfromfinactivitiesTotal(), ReservesandadjfromfinactivitiesTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Reservesandadjfromfinactivities() + '..' + ReservesandadjfromfinactivitiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Expenses - Change in Inventory of Own Production and Activation
        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(Changeininventoryofownproductionandactivation(), ChangeininventoryofownproductionandactivationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetBChangesInInventoryOfOwnProducts(), 80);
        ContosoGLAccount.InsertGLAccount(ChangeinWIP(), ChangeinWIPName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CapacityVariance(), CapacityVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Varianceofoverheadcost(), VarianceofoverheadcostName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SubcontractedVariance(), SubcontractedVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Changeinsemifinishedproducts(), ChangeinsemifinishedproductsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Changeinfinishedproducts(), ChangeinfinishedproductsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Changeofanimals(), ChangeofanimalsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetCCapitalization(), 80);
        ContosoGLAccount.InsertGLAccount(Activationofgoodsandmaterial(), ActivationofgoodsandmaterialName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Activationofinternalservices(), ActivationofinternalservicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Activationofintangiblefixedassets(), ActivationofintangiblefixedassetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Activationoftangiblefixedassets(), ActivationoftangiblefixedassetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(ChangeininventoryofownproductionandactivationTotal(), ChangeininventoryofownproductionandactivationTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Changeininventoryofownproductionandactivation() + '..' + ChangeininventoryofownproductionandactivationTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        SubCategory := Format(GLAccountCategoryMgtCZL.GetL1IncomeTaxDue(), 80);
        ContosoGLAccount.InsertGLAccount(Incometaxonordinaryactivitiespayable(), IncometaxonordinaryactivitiespayableName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetL2IncomeTaxDeferred(), 80);
        ContosoGLAccount.InsertGLAccount(Incometaxonordinaryactivitiesdeferred(), IncometaxonordinaryactivitiesdeferredName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(ExpensesTotal(), ExpensesTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Expenses() + '..' + ExpensesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Revenues
        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(Revenues(), RevenuesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetIRevenuesFromOwnProductsAndServices(), 80);
        ContosoGLAccount.InsertGLAccount(SalesProductsDomestic(), SalesProductsDomesticName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesProductsEU(), SalesProductsEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesProductsExport(), SalesProductsExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesServicesDomestic(), SalesServicesDomesticName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesServicesEU(), SalesServicesEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesServicesExport(), SalesServicesExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(PrepaidHardwareContracts(), PrepaidHardwareContractsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT12I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(PrepaidSoftwareContracts(), PrepaidSoftwareContractsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT12I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(ServiceContractSale(), ServiceContractSaleName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT12I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesJobs(), SalesJobsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);

        #region Revenues - Sales Goods
        SubCategory := Format(GLAccountCategoryMgtCZL.GetIIRevenuesFromMerchandise(), 80);
        ContosoGLAccount.InsertGLAccount(SalesGoods(), SalesGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(SalesGoodsDomestic(), SalesGoodsDomesticName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21S(), true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesGoodsEU(), SalesGoodsEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVATPostingGroupsCZ.VAT21S(), true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesGoodsExport(), SalesGoodsExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateVATPostingGroupsCZ.VAT21S(), true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesGoodsOther(), SalesGoodsOtherName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);

        ContosoGLAccount.InsertGLAccount(SalesGoodsTotal(), SalesGoodsTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, SalesGoods() + '..' + SalesGoodsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Revenues - Other Operating Income
        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(OtherOperatingIncomeBegin(), OtherOperatingIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetIII1RevenuesFromSalesOfFixedAssets(), 80);
        ContosoGLAccount.InsertGLAccount(SalesFixedAssets(), SalesFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetIII2RevenuesOfMaterialSold(), 80);
        ContosoGLAccount.InsertGLAccount(Salesmaterial(), SalesmaterialName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21S(), true, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetIII3AnotherOperatingRevenues(), 80);
        ContosoGLAccount.InsertGLAccount(ContractualPenaltiesAndInterests(), ContractualPenaltiesAndInterestsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(Discounts(), DiscountsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(Rounding(), RoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);
        ContosoGLAccount.InsertGLAccount(PaymentsTolerance(), PaymentsToleranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherOperatingIncome(), OtherOperatingIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);

        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(OtherOperatingIncomeTotal(), OtherOperatingIncomeTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherOperatingIncome() + '..' + OtherOperatingIncomeTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Revenues - Financial Revenues
        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(FinancialRevenues(), FinancialRevenuesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetVI2OtherInterestRevenuesAndSimilarRevenues(), 80);
        ContosoGLAccount.InsertGLAccount(InterestReceived(), InterestReceivedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetVIIOtherFinancialRevenues(), 80);
        ContosoGLAccount.InsertGLAccount(ExchangeGainsRealized(), ExchangeGainsRealizedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ExchangeGainsUnrealized(), ExchangeGainsUnrealizedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Revenuesfromshorttermfinancialassets(), RevenuesfromshorttermfinancialassetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Otherfinancialrevenues(), OtherfinancialrevenuesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), true, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetV1RevenuesFromOtherLongtermFinancialAssetsControlledOrControlling(), 80);
        ContosoGLAccount.InsertGLAccount(Revenuesfromlongtermfinancialassets(), RevenuesfromlongtermfinancialassetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(FinancialRevenuesTotal(), FinancialRevenuesTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, FinancialRevenues() + '..' + FinancialRevenuesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        #region Revenues - Transfer Accounts
        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(Transferaccounts(), TransferaccountsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetIII3AnotherOperatingRevenues(), 80);
        ContosoGLAccount.InsertGLAccount(Transferofoperatingrevenues(), TransferofoperatingrevenuesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgtCZL.GetVIIOtherFinancialRevenues(), 80);
        ContosoGLAccount.InsertGLAccount(Transferoffinancialrevenues(), TransferoffinancialrevenuesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(TransferaccountsTotal(), TransferaccountsTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Transferaccounts() + '..' + TransferaccountsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        SubCategory := '';
        ContosoGLAccount.InsertGLAccount(RevenuesTotal(), RevenuesTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Revenues() + '..' + RevenuesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        ContosoGLAccount.InsertGLAccount(OpeningBalanceSheetAccount(), OpeningBalanceSheetAccountName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ClosingBalanceSheetAccount(), ClosingBalanceSheetAccountName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ProfitAndLossAccount(), ProfitAndLossAccountName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        #region Revenues - Sub-Balance Sheet Accounts
        ContosoGLAccount.InsertGLAccount(SubBalanceSheetAccounts(), SubBalanceSheetAccountsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        #region Revenues - Sub-Balance Sheet Accounts - Rent of Fixed Assets
        ContosoGLAccount.InsertGLAccount(RentOfFixedAssets(), RentOfFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(Computers(), ComputersName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        ContosoGLAccount.InsertGLAccount(RentOfFixedAssetsTotal(), RentOfFixedAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, RentOfFixedAssets() + '..' + RentOfFixedAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        ContosoGLAccount.InsertGLAccount(BalancingAccount(), BalancingAccountName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(SubBalanceSheetAccountsTotal(), SubBalanceSheetAccountsTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, SubBalanceSheetAccounts() + '..' + SubBalanceSheetAccountsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        #endregion

        ContosoGLAccount.SetOverwriteData(false);
        GLAccountIndent.Indent();
    end;

    local procedure ModifyGLAccountForCZ()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsName(), '001000');
        ContosoGLAccount.AddAccountForLocalization(IntangiblefixedassetsName(), '010000');
        ContosoGLAccount.AddAccountForLocalization(IntangibleresultsofresearchanddevelopmentName(), '012100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SoftwareName(), '013100');
        ContosoGLAccount.AddAccountForLocalization(ValuablerightsName(), '014100');
        ContosoGLAccount.AddAccountForLocalization(GoodwillName(), '015100');
        ContosoGLAccount.AddAccountForLocalization(OtherintangiblefixedassetsName(), '019100');
        ContosoGLAccount.AddAccountForLocalization(IntangiblefixedassetstotalName(), '019999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsName(), '020000');
        ContosoGLAccount.AddAccountForLocalization(BuildingsName(), '021100');
        ContosoGLAccount.AddAccountForLocalization(MachinestoolsequipmentName(), '022100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '022300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsTotalName(), '029999');
        ContosoGLAccount.AddAccountForLocalization(TangiblefixedassetsnondeductibleName(), '030000');
        ContosoGLAccount.AddAccountForLocalization(LandsName(), '031100');
        ContosoGLAccount.AddAccountForLocalization(TangiblefixedassetsnondeductibleTotalName(), '039999');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionoffixedassetsName(), '040000');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionofintangiblefixedassetsName(), '041100');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionoftangiblefixedassetsName(), '042100');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionOfMachineryName(), '042200');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionOfVehiclesName(), '042300');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionoffixedassetstotalName(), '049999');
        ContosoGLAccount.AddAccountForLocalization(AccumulateddepreciationtointangiblefixedassetsName(), '070000');
        ContosoGLAccount.AddAccountForLocalization(AccumulateddepreciationtointangibleresultsofresearchanddevelopmentName(), '072100');
        ContosoGLAccount.AddAccountForLocalization(AccumulateddepreciationtosoftwareName(), '073100');
        ContosoGLAccount.AddAccountForLocalization(AccumulateddepreciationtovaluablerightsName(), '074100');
        ContosoGLAccount.AddAccountForLocalization(AccumulateddepreciationtogoodwillName(), '075100');
        ContosoGLAccount.AddAccountForLocalization(AccumulateddepreciationtootherintangiblefixedassetsName(), '079100');
        ContosoGLAccount.AddAccountForLocalization(AccumulateddepreciationtointangiblefixedassetstotalName(), '079999');
        ContosoGLAccount.AddAccountForLocalization(AccumulatedDepreciationToTangibleFixedAssetsName(), '080000');
        ContosoGLAccount.AddAccountForLocalization(AccumulatedDepreciationToBuildingsName(), '081100');
        ContosoGLAccount.AddAccountForLocalization(AccumulatedDepreciationToMachineryName(), '082100');
        ContosoGLAccount.AddAccountForLocalization(AccumulatedDepreciationToVehiclesName(), '082300');
        ContosoGLAccount.AddAccountForLocalization(AccumulatedDepreciationToTangibleFixedAssetsTotalName(), '089999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsTotalName(), '099999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryName(), '100000');
        ContosoGLAccount.AddAccountForLocalization(MaterialName(), '110000');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionOfMaterialName(), '111100');
        ContosoGLAccount.AddAccountForLocalization(MaterialInStockInterimName(), '112050');
        ContosoGLAccount.AddAccountForLocalization(MaterialInStockName(), '112100');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVarianceRawmatName(), '112200');
        ContosoGLAccount.AddAccountForLocalization(MaterialTotalName(), '119999');
        ContosoGLAccount.AddAccountForLocalization(InventoryOfOwnProductionName(), '120000');
        ContosoGLAccount.AddAccountForLocalization(WorkInProgressBeginName(), '121000');
        ContosoGLAccount.AddAccountForLocalization(WorkInProgressName(), '121100');
        ContosoGLAccount.AddAccountForLocalization(WorkInProgressTotalName(), '121999');
        ContosoGLAccount.AddAccountForLocalization(FinishedProductsBeginName(), '123000');
        ContosoGLAccount.AddAccountForLocalization(FinishedProductsInterimName(), '123050');
        ContosoGLAccount.AddAccountForLocalization(FinishedProductsName(), '123100');
        ContosoGLAccount.AddAccountForLocalization(FinishedProductsTotalName(), '123999');
        ContosoGLAccount.AddAccountForLocalization(InventoryOfOwnProductionTotalName(), '129999');
        ContosoGLAccount.AddAccountForLocalization(GoodsName(), '130000');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionOfGoodsBeginName(), '131000');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionOfGoodsName(), '131050');
        ContosoGLAccount.AddAccountForLocalization(DirectCostAppliedRetailName(), '131350');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionRetailName(), '131450');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionRetailInterimName(), '131455');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionRawMaterialDomesticName(), '131500');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionRawMaterialEuName(), '131600');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionRawMaterialExportName(), '131700');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionRawMaterialName(), '131950');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionRawMaterialInterimName(), '131955');
        ContosoGLAccount.AddAccountForLocalization(AcquisitionOfGoodsTotalName(), '131999');
        ContosoGLAccount.AddAccountForLocalization(GoodsInStockName(), '132000');
        ContosoGLAccount.AddAccountForLocalization(GoodsInRetailName(), '132100');
        ContosoGLAccount.AddAccountForLocalization(GoodsInRetailInterimName(), '132110');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVarianceRetailName(), '132200');
        ContosoGLAccount.AddAccountForLocalization(GoodsInStockTotalName(), '132999');
        ContosoGLAccount.AddAccountForLocalization(GoodsTotalName(), '139999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryTotalName(), '199999');
        ContosoGLAccount.AddAccountForLocalization(CurrentFinancialAssetsName(), '200000');
        ContosoGLAccount.AddAccountForLocalization(CashBeginName(), '210000');
        ContosoGLAccount.AddAccountForLocalization(CashDeskLmName(), '211100');
        ContosoGLAccount.AddAccountForLocalization(CashTotalName(), '219999');
        ContosoGLAccount.AddAccountForLocalization(BankAccountsName(), '220000');
        ContosoGLAccount.AddAccountForLocalization(BankAccountKBName(), '221100');
        ContosoGLAccount.AddAccountForLocalization(BankAccountEURName(), '221200');
        ContosoGLAccount.AddAccountForLocalization(BankAccountsTotalName(), '229999');
        ContosoGLAccount.AddAccountForLocalization(ShortTermBankLoansName(), '231100');
        ContosoGLAccount.AddAccountForLocalization(ShortTermSecuritiesName(), '251100');
        ContosoGLAccount.AddAccountForLocalization(CashtransferName(), '261100');
        ContosoGLAccount.AddAccountForLocalization(UnidentifiedpaymentsName(), '261900');
        ContosoGLAccount.AddAccountForLocalization(CurrentFinancialAssetsTotalName(), '299999');
        ContosoGLAccount.AddAccountForLocalization(NettingRelationshipsName(), '300000');
        ContosoGLAccount.AddAccountForLocalization(ReceivablesName(), '310000');
        ContosoGLAccount.AddAccountForLocalization(DomesticCustomersReceivablesName(), '311100');
        ContosoGLAccount.AddAccountForLocalization(ForeignCustomersOutsideEUReceivablesName(), '311200');
        ContosoGLAccount.AddAccountForLocalization(CustomersIntercompanyName(), '311250');
        ContosoGLAccount.AddAccountForLocalization(EUCustomersReceivablesName(), '311300');
        ContosoGLAccount.AddAccountForLocalization(ReceivablesFromBusinessRelationFeesName(), '311900');
        ContosoGLAccount.AddAccountForLocalization(PurchaseAdvancesDomesticName(), '314100');
        ContosoGLAccount.AddAccountForLocalization(PurchaseAdvancesForeignName(), '314200');
        ContosoGLAccount.AddAccountForLocalization(PurchaseAdvancesEUName(), '314300');
        ContosoGLAccount.AddAccountForLocalization(OtherReceivablesName(), '315100');
        ContosoGLAccount.AddAccountForLocalization(ReceivablesTotalName(), '319999');
        ContosoGLAccount.AddAccountForLocalization(PayablesName(), '320000');
        ContosoGLAccount.AddAccountForLocalization(DomesticVendorsPayablesName(), '321100');
        ContosoGLAccount.AddAccountForLocalization(ForeignVendorsOutsideEUPayablesName(), '321200');
        ContosoGLAccount.AddAccountForLocalization(VendorsIntercompanyName(), '321250');
        ContosoGLAccount.AddAccountForLocalization(EUVendorsPayablesName(), '321300');
        ContosoGLAccount.AddAccountForLocalization(SalesAdvancesDomesticName(), '324100');
        ContosoGLAccount.AddAccountForLocalization(SalesAdvancesForeignName(), '324200');
        ContosoGLAccount.AddAccountForLocalization(SalesAdvancesEUName(), '324300');
        ContosoGLAccount.AddAccountForLocalization(OtherpayablesName(), '325100');
        ContosoGLAccount.AddAccountForLocalization(PayablesTotalName(), '329999');
        ContosoGLAccount.AddAccountForLocalization(EmployeesAndInstitutionsSettlementName(), '330000');
        ContosoGLAccount.AddAccountForLocalization(EmployeesName(), '331100');
        ContosoGLAccount.AddAccountForLocalization(PayablesToEmployeesName(), '333100');
        ContosoGLAccount.AddAccountForLocalization(SocialInstitutionsSettlementName(), '336100');
        ContosoGLAccount.AddAccountForLocalization(HealthInstitutionsSettlementName(), '336200');
        ContosoGLAccount.AddAccountForLocalization(EmployeesAndInstitutionsSettlementTotalName(), '339999');
        ContosoGLAccount.AddAccountForLocalization(IncomeTaxBeginName(), '341000');
        ContosoGLAccount.AddAccountForLocalization(IncomeTaxName(), '341100');
        ContosoGLAccount.AddAccountForLocalization(IncomeTaxTotalName(), '341999');
        ContosoGLAccount.AddAccountForLocalization(IncomeTaxOnEmploymentName(), '342100');
        ContosoGLAccount.AddAccountForLocalization(VATName(), '343000');
        ContosoGLAccount.AddAccountForLocalization(InputVAT12Name(), '343112');
        ContosoGLAccount.AddAccountForLocalization(InputVAT21Name(), '343121');
        ContosoGLAccount.AddAccountForLocalization(OutputVAT12Name(), '343512');
        ContosoGLAccount.AddAccountForLocalization(OutputVAT21Name(), '343521');
        ContosoGLAccount.AddAccountForLocalization(ReverseChargeVAT12Name(), '343612');
        ContosoGLAccount.AddAccountForLocalization(ReverseChargeVAT21Name(), '343621');
        ContosoGLAccount.AddAccountForLocalization(AdvancesVAT12Name(), '343812');
        ContosoGLAccount.AddAccountForLocalization(AdvancesVAT21Name(), '343821');
        ContosoGLAccount.AddAccountForLocalization(PostponedVATPurchaseName(), '343880');
        ContosoGLAccount.AddAccountForLocalization(VATSettlementName(), '343900');
        ContosoGLAccount.AddAccountForLocalization(VATTotalName(), '343999');
        ContosoGLAccount.AddAccountForLocalization(OthertaxesandfeesName(), '345100');
        ContosoGLAccount.AddAccountForLocalization(PostponedVATName(), '371100');
        ContosoGLAccount.AddAccountForLocalization(TemporaryaccountsofassetsandliabilitiesName(), '380000');
        ContosoGLAccount.AddAccountForLocalization(PrepaidExpensesName(), '381100');
        ContosoGLAccount.AddAccountForLocalization(ComplexPrepaidExpensesName(), '382100');
        ContosoGLAccount.AddAccountForLocalization(AccruedExpensesName(), '383100');
        ContosoGLAccount.AddAccountForLocalization(DeferredRevenuesName(), '384100');
        ContosoGLAccount.AddAccountForLocalization(AccruedIncomesName(), '385100');
        ContosoGLAccount.AddAccountForLocalization(AccruedRevenueItemsName(), '388100');
        ContosoGLAccount.AddAccountForLocalization(AccrualsName(), '389100');
        ContosoGLAccount.AddAccountForLocalization(TemporaryaccountsofassetsandliabilitiestotalName(), '389999');
        ContosoGLAccount.AddAccountForLocalization(InternalsettlementName(), '395100');
        ContosoGLAccount.AddAccountForLocalization(NettingRelationshipsTotalName(), '399999');
        ContosoGLAccount.AddAccountForLocalization(EquityAndLongTermPayablesName(), '400000');
        ContosoGLAccount.AddAccountForLocalization(RegisteredCapitalAndCapitalFundsName(), '411100');
        ContosoGLAccount.AddAccountForLocalization(StatutoryreserveName(), '421100');
        ContosoGLAccount.AddAccountForLocalization(ProfitLossPreviousYearsName(), '428100');
        ContosoGLAccount.AddAccountForLocalization(ResultofcurrentyearName(), '431100');
        ContosoGLAccount.AddAccountForLocalization(IncometaxprovisionsName(), '453100');
        ContosoGLAccount.AddAccountForLocalization(OtherprovisionsName(), '459100');
        ContosoGLAccount.AddAccountForLocalization(MediumTermBankLoansName(), '461100');
        ContosoGLAccount.AddAccountForLocalization(LongTermBankLoansName(), '461200');
        ContosoGLAccount.AddAccountForLocalization(OtherlongtermpayablesName(), '479100');
        ContosoGLAccount.AddAccountForLocalization(EquityAndLongTermPayablesTotalName(), '499999');
        ContosoGLAccount.AddAccountForLocalization(ExpensesName(), '500000');
        ContosoGLAccount.AddAccountForLocalization(ConsumptionOfMaterialBeginName(), '501000');
        ContosoGLAccount.AddAccountForLocalization(ConsumptionOfMaterialName(), '501100');
        ContosoGLAccount.AddAccountForLocalization(FuelName(), '501200');
        ContosoGLAccount.AddAccountForLocalization(ComputersConsumableMaterialName(), '501300');
        ContosoGLAccount.AddAccountForLocalization(OverheadAppliedRetailName(), '501990');
        ContosoGLAccount.AddAccountForLocalization(ConsumptionOfMaterialTotalName(), '501999');
        ContosoGLAccount.AddAccountForLocalization(ElectricityBeginName(), '502000');
        ContosoGLAccount.AddAccountForLocalization(ElectricityName(), '502100');
        ContosoGLAccount.AddAccountForLocalization(ElectricityTotalName(), '502999');
        ContosoGLAccount.AddAccountForLocalization(NonstorablesuppliesBeginName(), '503000');
        ContosoGLAccount.AddAccountForLocalization(NonstorablesuppliesName(), '503100');
        ContosoGLAccount.AddAccountForLocalization(NonstorablesuppliesTotalName(), '503999');
        ContosoGLAccount.AddAccountForLocalization(COGSName(), '504000');
        ContosoGLAccount.AddAccountForLocalization(COGSRetailName(), '504110');
        ContosoGLAccount.AddAccountForLocalization(COGSRetailInterimName(), '504115');
        ContosoGLAccount.AddAccountForLocalization(COGSOthersName(), '504700');
        ContosoGLAccount.AddAccountForLocalization(COGSOthersInterimName(), '504710');
        ContosoGLAccount.AddAccountForLocalization(JobCorrectionName(), '504900');
        ContosoGLAccount.AddAccountForLocalization(COGSTotalName(), '504999');
        ContosoGLAccount.AddAccountForLocalization(ServicesName(), '510000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceName(), '511100');
        ContosoGLAccount.AddAccountForLocalization(OverheadAppliedCapName(), '511200');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVarianceCapName(), '511300');
        ContosoGLAccount.AddAccountForLocalization(TravelExpensesName(), '512100');
        ContosoGLAccount.AddAccountForLocalization(ServicesTotalName(), '512999');
        ContosoGLAccount.AddAccountForLocalization(RepresentationCostsName(), '513100');
        ContosoGLAccount.AddAccountForLocalization(OtherServicesBeginName(), '518000');
        ContosoGLAccount.AddAccountForLocalization(CleaningName(), '518100');
        ContosoGLAccount.AddAccountForLocalization(PhoneChargeName(), '518210');
        ContosoGLAccount.AddAccountForLocalization(PostageName(), '518220');
        ContosoGLAccount.AddAccountForLocalization(AdvertisementName(), '518300');
        ContosoGLAccount.AddAccountForLocalization(OtherServicesName(), '518900');
        ContosoGLAccount.AddAccountForLocalization(OtherServicesTotalName(), '518999');
        ContosoGLAccount.AddAccountForLocalization(PersonalExpensesName(), '520000');
        ContosoGLAccount.AddAccountForLocalization(SalariesAndWagesName(), '521100');
        ContosoGLAccount.AddAccountForLocalization(IncomefromemploymentcompanionsName(), '522100');
        ContosoGLAccount.AddAccountForLocalization(RemunerationtomembersofcompanymanagementName(), '523100');
        ContosoGLAccount.AddAccountForLocalization(SocialInsuranceName(), '524100');
        ContosoGLAccount.AddAccountForLocalization(HealthInsuranceName(), '524200');
        ContosoGLAccount.AddAccountForLocalization(OtherSocialInsuranceName(), '525100');
        ContosoGLAccount.AddAccountForLocalization(IndividualsocialcostforbusinessmanName(), '526100');
        ContosoGLAccount.AddAccountForLocalization(StatutorysocialcostName(), '527100');
        ContosoGLAccount.AddAccountForLocalization(OthersocialcostsName(), '528100');
        ContosoGLAccount.AddAccountForLocalization(OthernontaxsocialcostsName(), '528900');
        ContosoGLAccount.AddAccountForLocalization(PersonalExpensesTotalName(), '529999');
        ContosoGLAccount.AddAccountForLocalization(OthertaxesandfeesBeginName(), '530000');
        ContosoGLAccount.AddAccountForLocalization(RoadtaxName(), '531100');
        ContosoGLAccount.AddAccountForLocalization(PropertytaxName(), '532100');
        ContosoGLAccount.AddAccountForLocalization(OthertaxesandfeesName(), '538100');
        ContosoGLAccount.AddAccountForLocalization(OthernotaxtaxesandfeesName(), '538900');
        ContosoGLAccount.AddAccountForLocalization(OthertaxesandfeesTotalName(), '539999');
        ContosoGLAccount.AddAccountForLocalization(OtheroperatingexpensesBeginName(), '540000');
        ContosoGLAccount.AddAccountForLocalization(NetbookvalueoffixedassetssoldName(), '541100');
        ContosoGLAccount.AddAccountForLocalization(CostofmaterialsoldInterimName(), '542050');
        ContosoGLAccount.AddAccountForLocalization(CostofmaterialsoldName(), '542100');
        ContosoGLAccount.AddAccountForLocalization(PresentsName(), '543100');
        ContosoGLAccount.AddAccountForLocalization(ContractualPenaltiesAndInterestsName(), '544100');
        ContosoGLAccount.AddAccountForLocalization(PaymentsToleranceName(), '544300');
        ContosoGLAccount.AddAccountForLocalization(OtherPenaltiesAndInterestsName(), '545100');
        ContosoGLAccount.AddAccountForLocalization(ReceivablewriteoffName(), '546100');
        ContosoGLAccount.AddAccountForLocalization(OtheroperatingexpensesName(), '548100');
        ContosoGLAccount.AddAccountForLocalization(ShortagesanddamagefromoperactName(), '549100');
        ContosoGLAccount.AddAccountForLocalization(OtheroperatingexpensesTotalName(), '549999');
        ContosoGLAccount.AddAccountForLocalization(DepreciationandreservesName(), '550000');
        ContosoGLAccount.AddAccountForLocalization(DepreciationName(), '551000');
        ContosoGLAccount.AddAccountForLocalization(DepreciationOfBuildingsName(), '551100');
        ContosoGLAccount.AddAccountForLocalization(DepreciationOfMachinesAndToolsName(), '551200');
        ContosoGLAccount.AddAccountForLocalization(DepreciationOfVehiclesName(), '551300');
        ContosoGLAccount.AddAccountForLocalization(DepreciationofpatentsName(), '551400');
        ContosoGLAccount.AddAccountForLocalization(DepreciationofsoftwareName(), '551500');
        ContosoGLAccount.AddAccountForLocalization(DepreciationofgoodwillName(), '551600');
        ContosoGLAccount.AddAccountForLocalization(DepreciationofotherintangiblefixedassetsName(), '551700');
        ContosoGLAccount.AddAccountForLocalization(NetBookValueOfFixedAssetsDisposedName(), '551900');
        ContosoGLAccount.AddAccountForLocalization(DepreciationTotalName(), '551999');
        ContosoGLAccount.AddAccountForLocalization(CreatandsettlofreservesaccordtospecregulName(), '552100');
        ContosoGLAccount.AddAccountForLocalization(CreationandsettlementofothersreservesName(), '554100');
        ContosoGLAccount.AddAccountForLocalization(CreationandsettlementlegaladjustmentsName(), '558100');
        ContosoGLAccount.AddAccountForLocalization(CreationandsettlementadjustmentstooperactivitiesName(), '559100');
        ContosoGLAccount.AddAccountForLocalization(DepreciationandreservestotalName(), '559999');
        ContosoGLAccount.AddAccountForLocalization(FinancialExpensesName(), '560000');
        ContosoGLAccount.AddAccountForLocalization(InterestName(), '562100');
        ContosoGLAccount.AddAccountForLocalization(ExchangeLossesRealizedName(), '563100');
        ContosoGLAccount.AddAccountForLocalization(ExchangeLossesUnrealizedName(), '563200');
        ContosoGLAccount.AddAccountForLocalization(ExpensesrelatedtofinancialassetsName(), '566100');
        ContosoGLAccount.AddAccountForLocalization(OtherfinancialexpensesName(), '568100');
        ContosoGLAccount.AddAccountForLocalization(FinancialExpensesTotalName(), '569999');
        ContosoGLAccount.AddAccountForLocalization(ReservesandadjfromfinactivitiesName(), '570000');
        ContosoGLAccount.AddAccountForLocalization(CreationandsettlementoffinancialreservesName(), '574100');
        ContosoGLAccount.AddAccountForLocalization(CreationandsettlementadjustmentsName(), '579100');
        ContosoGLAccount.AddAccountForLocalization(ReservesandadjfromfinactivitiestotalName(), '579999');
        ContosoGLAccount.AddAccountForLocalization(ChangeininventoryofownproductionandactivationName(), '580000');
        ContosoGLAccount.AddAccountForLocalization(ChangeinWIPName(), '581100');
        ContosoGLAccount.AddAccountForLocalization(CapacityVarianceName(), '581200');
        ContosoGLAccount.AddAccountForLocalization(VarianceofoverheadcostName(), '581300');
        ContosoGLAccount.AddAccountForLocalization(SubcontractedVarianceName(), '581400');
        ContosoGLAccount.AddAccountForLocalization(ChangeinsemifinishedproductsName(), '582100');
        ContosoGLAccount.AddAccountForLocalization(ChangeinfinishedproductsName(), '583100');
        ContosoGLAccount.AddAccountForLocalization(ChangeofanimalsName(), '584100');
        ContosoGLAccount.AddAccountForLocalization(ActivationofgoodsandmaterialName(), '585100');
        ContosoGLAccount.AddAccountForLocalization(ActivationofinternalservicesName(), '586100');
        ContosoGLAccount.AddAccountForLocalization(ActivationofintangiblefixedassetsName(), '587100');
        ContosoGLAccount.AddAccountForLocalization(ActivationoftangiblefixedassetsName(), '588100');
        ContosoGLAccount.AddAccountForLocalization(ChangeininventoryofownproductionandactivationtotalName(), '589999');
        ContosoGLAccount.AddAccountForLocalization(IncometaxonordinaryactivitiespayableName(), '591100');
        ContosoGLAccount.AddAccountForLocalization(IncometaxonordinaryactivitiesdeferredName(), '592100');
        ContosoGLAccount.AddAccountForLocalization(ExpensesTotalName(), '599999');
        ContosoGLAccount.AddAccountForLocalization(RevenuesName(), '600000');
        ContosoGLAccount.AddAccountForLocalization(SalesProductsDomesticName(), '601020');
        ContosoGLAccount.AddAccountForLocalization(SalesProductsEUName(), '601030');
        ContosoGLAccount.AddAccountForLocalization(SalesProductsExportName(), '601040');
        ContosoGLAccount.AddAccountForLocalization(SalesServicesDomesticName(), '602110');
        ContosoGLAccount.AddAccountForLocalization(SalesServicesEUName(), '602120');
        ContosoGLAccount.AddAccountForLocalization(SalesServicesExportName(), '602130');
        ContosoGLAccount.AddAccountForLocalization(PrepaidHardwareContractsName(), '602220');
        ContosoGLAccount.AddAccountForLocalization(PrepaidSoftwareContractsName(), '602230');
        ContosoGLAccount.AddAccountForLocalization(ServiceContractSaleName(), '602320');
        ContosoGLAccount.AddAccountForLocalization(SalesJobsName(), '602500');
        ContosoGLAccount.AddAccountForLocalization(SalesGoodsName(), '604000');
        ContosoGLAccount.AddAccountForLocalization(SalesGoodsDomesticName(), '604110');
        ContosoGLAccount.AddAccountForLocalization(SalesGoodsEUName(), '604120');
        ContosoGLAccount.AddAccountForLocalization(SalesGoodsExportName(), '604130');
        ContosoGLAccount.AddAccountForLocalization(SalesGoodsOtherName(), '604900');
        ContosoGLAccount.AddAccountForLocalization(SalesGoodsTotalName(), '604999');
        ContosoGLAccount.AddAccountForLocalization(OtherOperatingIncomeBeginName(), '640000');
        ContosoGLAccount.AddAccountForLocalization(SalesFixedAssetsName(), '641100');
        ContosoGLAccount.AddAccountForLocalization(SalesmaterialName(), '642100');
        ContosoGLAccount.AddAccountForLocalization(ContractualPenaltiesAndInterestsName(), '644100');
        ContosoGLAccount.AddAccountForLocalization(DiscountsName(), '644110');
        ContosoGLAccount.AddAccountForLocalization(RoundingName(), '644200');
        ContosoGLAccount.AddAccountForLocalization(PaymentsToleranceName(), '644300');
        ContosoGLAccount.AddAccountForLocalization(OtherOperatingIncomeName(), '648100');
        ContosoGLAccount.AddAccountForLocalization(OtherOperatingIncomeTotalName(), '649999');
        ContosoGLAccount.AddAccountForLocalization(FinancialRevenuesName(), '660000');
        ContosoGLAccount.AddAccountForLocalization(InterestReceivedName(), '662100');
        ContosoGLAccount.AddAccountForLocalization(ExchangeGainsRealizedName(), '663100');
        ContosoGLAccount.AddAccountForLocalization(ExchangeGainsUnrealizedName(), '663200');
        ContosoGLAccount.AddAccountForLocalization(RevenuesfromlongtermfinancialassetsName(), '665100');
        ContosoGLAccount.AddAccountForLocalization(RevenuesfromshorttermfinancialassetsName(), '666100');
        ContosoGLAccount.AddAccountForLocalization(OtherfinancialrevenuesName(), '668100');
        ContosoGLAccount.AddAccountForLocalization(FinancialRevenuesTotalName(), '669999');
        ContosoGLAccount.AddAccountForLocalization(TransferaccountsName(), '690000');
        ContosoGLAccount.AddAccountForLocalization(TransferofoperatingrevenuesName(), '697100');
        ContosoGLAccount.AddAccountForLocalization(TransferoffinancialrevenuesName(), '698100');
        ContosoGLAccount.AddAccountForLocalization(TransferaccountstotalName(), '699990');
        ContosoGLAccount.AddAccountForLocalization(RevenuesTotalName(), '699999');
        ContosoGLAccount.AddAccountForLocalization(OpeningBalanceSheetAccountName(), '701000');
        ContosoGLAccount.AddAccountForLocalization(ClosingBalanceSheetAccountName(), '702000');
        ContosoGLAccount.AddAccountForLocalization(ProfitAndLossAccountName(), '710000');
        ContosoGLAccount.AddAccountForLocalization(SubBalanceSheetAccountsName(), '750005');
        ContosoGLAccount.AddAccountForLocalization(RentOfFixedAssetsName(), '750010');
        ContosoGLAccount.AddAccountForLocalization(ComputersName(), '750100');
        ContosoGLAccount.AddAccountForLocalization(RentOfFixedAssetsTotalName(), '750995');
        ContosoGLAccount.AddAccountForLocalization(BalancingAccountName(), '790000');
        ContosoGLAccount.AddAccountForLocalization(SubBalanceSheetAccountsTotalName(), '799999');
    end;

    local procedure ModifyGLAccountForW1()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BalanceSheetName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDeprOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResaleSoldInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMatSoldInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PrimoInventoryName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWIPName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoicedJobSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPSalesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedJobCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPCostsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWIPTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersDomesticName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersForeignName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedInterestName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherReceivablesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVATName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BondsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankLCYName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankCurrenciesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GiroAccountName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesAndEquityName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.StockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CapitalStockName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetainedEarningsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomefortheYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalStockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeferredTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermBankLoansName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShorttermLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevolvingCreditName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT0Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsDomesticName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsForeignName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VATName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT25EUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT10EUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FuelTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NaturalGasTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CoalTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CO2TaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WaterTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VATPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VATTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelrelatedItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WithholdingTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SupplementaryTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EmployeesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelrelatedItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DividendsfortheFiscalYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShorttermLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherAccruedExpensesAndDeferredIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesAndEquityName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncomeStatementName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevenueName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofJobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOtherJobExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofJobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultingFeesDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FeesandChargesRecDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscountGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalRevenueName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRetailSoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMaterialsSoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResourcesUsedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostofResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BuildingMaintenanceExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CleaningName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityandHeatingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalBldgMaintExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdministrativeExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OfficeSuppliesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PhoneandFaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PostageName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAdministrativeExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SoftwareName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultantServicesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SellingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdvertisingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EntertainmentandPRName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TravelName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSellingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehicleExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GasolineandMotorOilName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RegistrationFeesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceExpenseName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalVehicleExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashDiscrepanciesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BadDebtExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LegalandAccountingServicesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MiscellaneousName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalOperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WagesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalariesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetirementPlanContributionsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationofFixedAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GainsandLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalFixedAssetDepreciationName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherCostsofOperationsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetOperatingIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonBankBalancesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargesfromCustomersName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsReceivedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtDiscReceivedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoiceRoundingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ApplicationRoundingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceReceivedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolReceivedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonRevolvingCreditName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonBankLoansName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageInterestName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargestoVendorsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtDiscGrantedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolGrantedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFXGainsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFXLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFXGainsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFXLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NIBEFOREEXTRITEMSTAXESName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeBeforeTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeName(), '');
    end;

    procedure BuildingsName(): Text[100]
    begin
        exit(BuildingsLbl);
    end;

    procedure Buildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BuildingsName()));
    end;

    procedure MachinestoolsequipmentName(): Text[100]
    begin
        exit(MachinestoolsequipmentLbl);
    end;

    procedure Machinestoolsequipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MachinestoolsequipmentName()));
    end;

    procedure AcquisitionOfIntangibleFixedAssetsName(): Text[100]
    begin
        exit(AcquisitionOfIntangibleFixedAssetsLbl);
    end;

    procedure AcquisitionOfIntangibleFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionOfIntangibleFixedAssetsName()));
    end;

    procedure AcquisitionOfTangibleFixedAssetsName(): Text[100]
    begin
        exit(AcquisitionOfTangibleFixedAssetsLbl);
    end;

    procedure AcquisitionOfTangibleFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionOfTangibleFixedAssetsName()));
    end;

    procedure AcquisitionOfMachineryName(): Text[100]
    begin
        exit(AcquisitionOfMachineryLbl);
    end;

    procedure AcquisitionOfMachinery(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionOfMachineryName()));
    end;

    procedure AcquisitionOfVehiclesName(): Text[100]
    begin
        exit(AcquisitionOfVehiclesLbl);
    end;

    procedure AcquisitionOfVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionOfVehiclesName()));
    end;

    procedure AccumulatedDepreciationToTangibleFixedAssetsName(): Text[100]
    begin
        exit(AccumulatedDepreciationToTangibleFixedAssetsLbl);
    end;

    procedure AccumulatedDepreciationToTangibleFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulatedDepreciationToTangibleFixedAssetsName()));
    end;

    procedure AccumulatedDepreciationToBuildingsName(): Text[100]
    begin
        exit(AccumulatedDepreciationToBuildingsLbl);
    end;

    procedure AccumulatedDepreciationToBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulatedDepreciationToBuildingsName()));
    end;

    procedure AccumulatedDepreciationToMachineryName(): Text[100]
    begin
        exit(AccumulatedDepreciationToMachineryLbl);
    end;

    procedure AccumulatedDepreciationToMachinery(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulatedDepreciationToMachineryName()));
    end;

    procedure AccumulatedDepreciationToVehiclesName(): Text[100]
    begin
        exit(AccumulatedDepreciationToVehiclesLbl);
    end;

    procedure AccumulatedDepreciationToVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulatedDepreciationToVehiclesName()));
    end;

    procedure AccumulatedDepreciationToTangibleFixedAssetsTotalName(): Text[100]
    begin
        exit(AccumulatedDepreciationToTangibleFixedAssetsTotalLbl);
    end;

    procedure AccumulatedDepreciationToTangibleFixedAssetsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulatedDepreciationToTangibleFixedAssetsTotalName()));
    end;

    procedure AcquisitionOfMaterialName(): Text[100]
    begin
        exit(AcquisitionOfMaterialLbl);
    end;

    procedure AcquisitionOfMaterial(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionOfMaterialName()));
    end;

    procedure MaterialName(): Text[100]
    begin
        exit(MaterialLbl);
    end;

    procedure Material(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaterialName()));
    end;

    procedure MaterialTotalName(): Text[100]
    begin
        exit(MaterialTotalLbl);
    end;

    procedure MaterialTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaterialTotalName()));
    end;

    procedure MaterialInStockInterimName(): Text[100]
    begin
        exit(MaterialInStockInterimLbl);
    end;

    procedure MaterialInStockInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaterialInStockInterimName()));
    end;

    procedure MaterialInStockName(): Text[100]
    begin
        exit(MaterialInStockLbl);
    end;

    procedure MaterialInStock(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaterialInStockName()));
    end;

    procedure WorkInProgressBeginName(): Text[100]
    begin
        exit(WorkInProgressBeginLbl);
    end;

    procedure WorkInProgressBegin(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WorkInProgressBeginName()));
    end;

    procedure WorkInProgressName(): Text[100]
    begin
        exit(WorkInProgressLbl);
    end;

    procedure WorkInProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WorkInProgressName()));
    end;

    procedure WorkInProgressTotalName(): Text[100]
    begin
        exit(WorkInProgressTotalLbl);
    end;

    procedure WorkInProgressTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WorkInProgressTotalName()));
    end;

    procedure FinishedProductsInterimName(): Text[100]
    begin
        exit(FinishedProductsInterimLbl);
    end;

    procedure FinishedProductsInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinishedProductsInterimName()));
    end;

    procedure FinishedProductsName(): Text[100]
    begin
        exit(FinishedProductsLbl);
    end;

    procedure FinishedProducts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinishedProductsName()));
    end;

    procedure FinishedProductsBeginName(): Text[100]
    begin
        exit(FinishedProductsBeginLbl);
    end;

    procedure FinishedProductsBegin(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinishedProductsBeginName()));
    end;

    procedure FinishedProductsTotalName(): Text[100]
    begin
        exit(FinishedProductsTotalLbl);
    end;

    procedure FinishedProductsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinishedProductsTotalName()));
    end;

    procedure AcquisitionoffixedassetsName(): Text[100]
    begin
        exit(AcquisitionoffixedassetsLbl);
    end;

    procedure Acquisitionoffixedassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Acquisitionoffixedassetsname()));
    end;

    procedure AcquisitionoffixedassetstotalName(): Text[100]
    begin
        exit(AcquisitionoffixedassetstotalLbl);
    end;

    procedure Acquisitionoffixedassetstotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Acquisitionoffixedassetstotalname()));
    end;

    procedure AcquisitionOfGoodsBeginName(): Text[100]
    begin
        exit(AcquisitionOfGoodsBeginLbl);
    end;

    procedure AcquisitionOfGoodsBegin(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionOfGoodsBeginName()));
    end;

    procedure AcquisitionOfGoodsName(): Text[100]
    begin
        exit(AcquisitionOfGoodsLbl);
    end;

    procedure AcquisitionOfGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionOfGoodsName()));
    end;

    procedure AcquisitionRetailName(): Text[100]
    begin
        exit(AcquisitionRetailLbl);
    end;

    procedure AcquisitionRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionRetailName()));
    end;

    procedure AcquisitionRetailInterimName(): Text[100]
    begin
        exit(AcquisitionRetailInterimLbl);
    end;

    procedure AcquisitionRetailInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionRetailInterimName()));
    end;

    procedure AcquisitionRawMaterialInterimName(): Text[100]
    begin
        exit(AcquisitionRawMaterialInterimLbl);
    end;

    procedure AcquisitionRawMaterialInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionRawMaterialInterimName()));
    end;

    procedure AcquisitionRawMaterialDomesticName(): Text[100]
    begin
        exit(AcquisitionRawMaterialDomesticLbl);
    end;

    procedure AcquisitionRawMaterialDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionRawMaterialDomesticName()));
    end;

    procedure AcquisitionRawMaterialEuName(): Text[100]
    begin
        exit(AcquisitionRawMaterialEuLbl);
    end;

    procedure AcquisitionRawMaterialEu(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionRawMaterialEuName()));
    end;

    procedure AcquisitionRawMaterialExportName(): Text[100]
    begin
        exit(AcquisitionRawMaterialExportLbl);
    end;

    procedure AcquisitionRawMaterialExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionRawMaterialExportName()));
    end;

    procedure AcquisitionRawMaterialName(): Text[100]
    begin
        exit(AcquisitionRawMaterialLbl);
    end;

    procedure AcquisitionRawMaterial(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionRawMaterialName()));
    end;

    procedure AcquisitionOfGoodsTotalName(): Text[100]
    begin
        exit(AcquisitionOfGoodsTotalLbl);
    end;

    procedure AcquisitionOfGoodsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionOfGoodsTotalName()));
    end;

    procedure GoodsInStockName(): Text[100]
    begin
        exit(GoodsInStockLbl);
    end;

    procedure GoodsInStock(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsInStockName()));
    end;

    procedure GoodsInRetailName(): Text[100]
    begin
        exit(GoodsInRetailLbl);
    end;

    procedure GoodsInRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsInRetailName()));
    end;

    procedure GoodsInRetailInterimName(): Text[100]
    begin
        exit(GoodsInRetailInterimLbl);
    end;

    procedure GoodsInRetailInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsInRetailInterimName()));
    end;

    procedure GoodsInStockTotalName(): Text[100]
    begin
        exit(GoodsInStockTotalLbl);
    end;

    procedure GoodsInStockTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsInStockTotalName()));
    end;

    procedure CashDeskLmName(): Text[100]
    begin
        exit(CashDeskLmLbl);
    end;

    procedure CashDeskLm(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CashDeskLmName()));
    end;

    procedure BankAccountsName(): Text[100]
    begin
        exit(BankAccountsLbl);
    end;

    procedure BankAccounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankAccountsName()));
    end;

    procedure BankAccountsTotalName(): Text[100]
    begin
        exit(BankAccountsTotalLbl);
    end;

    procedure BankAccountsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankAccountsTotalName()));
    end;

    procedure BankAccountEURName(): Text[100]
    begin
        exit(BankAccountEURLbl);
    end;

    procedure BankAccountEUR(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankAccountEURName()));
    end;

    procedure BankAccountKBName(): Text[100]
    begin
        exit(BankAccountKBLbl);
    end;

    procedure BankAccountKB(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankAccountKBName()));
    end;

    procedure ShortTermBankLoansName(): Text[100]
    begin
        exit(ShortTermBankLoansLbl);
    end;

    procedure ShortTermBankLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShortTermBankLoansName()));
    end;

    procedure ShortTermSecuritiesName(): Text[100]
    begin
        exit(ShortTermSecuritiesLbl);
    end;

    procedure ShortTermSecurities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShortTermSecuritiesName()));
    end;

    procedure CashtransferName(): Text[100]
    begin
        exit(CashtransferLbl);
    end;

    procedure Cashtransfer(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CashtransferName()));
    end;

    procedure CashBeginName(): Text[100]
    begin
        exit(CashBeginLbl);
    end;

    procedure CashBegin(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CashBeginName()));
    end;

    procedure CashTotalName(): Text[100]
    begin
        exit(CashTotalLbl);
    end;

    procedure CashTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CashTotalName()));
    end;

    procedure ReceivablesName(): Text[100]
    begin
        exit(ReceivablesLbl);
    end;

    procedure Receivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReceivablesName()));
    end;

    procedure DomesticCustomersReceivablesName(): Text[100]
    begin
        exit(DomesticCustomersReceivablesLbl);
    end;

    procedure DomesticCustomersReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DomesticCustomersReceivablesName()));
    end;

    procedure ForeignCustomersOutsideEUReceivablesName(): Text[100]
    begin
        exit(ForeignCustomersOutsideEUReceivablesLbl);
    end;

    procedure ForeignCustomersOutsideEUReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ForeignCustomersOutsideEUReceivablesName()));
    end;

    procedure EUCustomersReceivablesName(): Text[100]
    begin
        exit(EUCustomersReceivablesLbl);
    end;

    procedure EUCustomersReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EUCustomersReceivablesName()));
    end;

    procedure ReceivablesFromBusinessRelationFeesName(): Text[100]
    begin
        exit(ReceivablesFromBusinessRelationFeesLbl);
    end;

    procedure ReceivablesFromBusinessRelationFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReceivablesFromBusinessRelationFeesName()));
    end;

    procedure PurchaseAdvancesDomesticName(): Text[100]
    begin
        exit(PurchaseAdvancesDomesticLbl);
    end;

    procedure PurchaseAdvancesDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseAdvancesDomesticName()));
    end;

    procedure PurchaseAdvancesForeignName(): Text[100]
    begin
        exit(PurchaseAdvancesForeignLbl);
    end;

    procedure PurchaseAdvancesForeign(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseAdvancesForeignName()));
    end;

    procedure PurchaseAdvancesEUName(): Text[100]
    begin
        exit(PurchaseAdvancesEULbl);
    end;

    procedure PurchaseAdvancesEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseAdvancesEUName()));
    end;

    procedure OtherReceivablesName(): Text[100]
    begin
        exit(OtherReceivablesLbl);
    end;

    procedure OtherReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherReceivablesName()));
    end;

    procedure ReceivablesTotalName(): Text[100]
    begin
        exit(ReceivablesTotalLbl);
    end;

    procedure ReceivablesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReceivablesTotalName()));
    end;

    procedure PayablesName(): Text[100]
    begin
        exit(PayablesLbl);
    end;

    procedure Payables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayablesName()));
    end;

    procedure DomesticVendorsPayablesName(): Text[100]
    begin
        exit(DomesticVendorsPayablesLbl);
    end;

    procedure DomesticVendorsPayables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DomesticVendorsPayablesName()));
    end;

    procedure ForeignVendorsOutsideEUPayablesName(): Text[100]
    begin
        exit(ForeignVendorsOutsideEUPayablesLbl);
    end;

    procedure ForeignVendorsOutsideEUPayables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ForeignVendorsOutsideEUPayablesName()));
    end;

    procedure EUVendorsPayablesName(): Text[100]
    begin
        exit(EUVendorsPayablesLbl);
    end;

    procedure EUVendorsPayables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EUVendorsPayablesName()));
    end;

    procedure SalesAdvancesDomesticName(): Text[100]
    begin
        exit(SalesAdvancesDomesticLbl);
    end;

    procedure SalesAdvancesDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesAdvancesDomesticName()));
    end;

    procedure SalesAdvancesForeignName(): Text[100]
    begin
        exit(SalesAdvancesForeignLbl);
    end;

    procedure SalesAdvancesForeign(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesAdvancesForeignName()));
    end;

    procedure SalesAdvancesEUName(): Text[100]
    begin
        exit(SalesAdvancesEULbl);
    end;

    procedure SalesAdvancesEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesAdvancesEUName()));
    end;

    procedure OtherPayablesName(): Text[100]
    begin
        exit(OtherPayablesLbl);
    end;

    procedure OtherPayables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherPayablesName()));
    end;

    procedure PayablesTotalName(): Text[100]
    begin
        exit(PayablesTotalLbl);
    end;

    procedure PayablesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayablesTotalName()));
    end;

    procedure EmployeesAndInstitutionsSettlementName(): Text[100]
    begin
        exit(EmployeesAndInstitutionsSettlementLbl);
    end;

    procedure EmployeesAndInstitutionsSettlement(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmployeesAndInstitutionsSettlementName()));
    end;

    procedure EmployeesName(): Text[100]
    begin
        exit(EmployeesLbl);
    end;

    procedure Employees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmployeesName()));
    end;

    procedure PayablesToEmployeesName(): Text[100]
    begin
        exit(PayablesToEmployeesLbl);
    end;

    procedure PayablesToEmployees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayablesToEmployeesName()));
    end;

    procedure SocialInstitutionsSettlementName(): Text[100]
    begin
        exit(SocialInstitutionsSettlementLbl);
    end;

    procedure SocialInstitutionsSettlement(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SocialInstitutionsSettlementName()));
    end;

    procedure HealthInstitutionsSettlementName(): Text[100]
    begin
        exit(HealthInstitutionsSettlementLbl);
    end;

    procedure HealthInstitutionsSettlement(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HealthInstitutionsSettlementName()));
    end;

    procedure EmployeesAndInstitutionsSettlementTotalName(): Text[100]
    begin
        exit(EmployeesAndInstitutionsSettlementTotalLbl);
    end;

    procedure EmployeesAndInstitutionsSettlementTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmployeesAndInstitutionsSettlementTotalName()));
    end;

    procedure SocialInsuranceName(): Text[100]
    begin
        exit(SocialInsuranceLbl);
    end;

    procedure SocialInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SocialInsuranceName()));
    end;

    procedure HealthInsuranceName(): Text[100]
    begin
        exit(HealthInsuranceLbl);
    end;

    procedure HealthInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HealthInsuranceName()));
    end;

    procedure IncomeTaxBeginName(): Text[100]
    begin
        exit(IncomeTaxBeginLbl);
    end;

    procedure IncomeTaxBegin(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeTaxBeginName()));
    end;

    procedure IncomeTaxName(): Text[100]
    begin
        exit(IncomeTaxLbl);
    end;

    procedure IncomeTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeTaxName()));
    end;

    procedure IncomeTaxTotalName(): Text[100]
    begin
        exit(IncomeTaxTotalLbl);
    end;

    procedure IncomeTaxTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeTaxTotalName()));
    end;

    procedure IncomeTaxOnEmploymentName(): Text[100]
    begin
        exit(IncomeTaxOnEmploymentLbl);
    end;

    procedure IncomeTaxOnEmployment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeTaxOnEmploymentName()));
    end;

    procedure VATName(): Text[100]
    begin
        exit(VATLbl);
    end;

    procedure VAT(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VATName()));
    end;

    procedure VATSettlementName(): Text[100]
    begin
        exit(VATSettlementLbl);
    end;

    procedure VATSettlement(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VATSettlementName()));
    end;

    procedure VATTotalName(): Text[100]
    begin
        exit(VATTotalLbl);
    end;

    procedure VATTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VATTotalName()));
    end;

    procedure PostponedVatName(): Text[100]
    begin
        exit(PostponedVatLbl);
    end;

    procedure PostponedVat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PostponedVatName()));
    end;

    procedure AccruedRevenueItemsName(): Text[100]
    begin
        exit(AccruedRevenueItemsLbl);
    end;

    procedure AccruedRevenueItems(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedRevenueItemsName()));
    end;

    procedure AccrualsName(): Text[100]
    begin
        exit(AccrualsLbl);
    end;

    procedure Accruals(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccrualsName()));
    end;

    procedure InternalSettlementName(): Text[100]
    begin
        exit(InternalSettlementLbl);
    end;

    procedure InternalSettlement(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InternalSettlementName()));
    end;

    procedure EquityAndLongTermPayablesName(): Text[100]
    begin
        exit(EquityAndLongTermPayablesLbl);
    end;

    procedure EquityAndLongTermPayables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquityAndLongTermPayablesName()));
    end;

    procedure RegisteredCapitalAndCapitalFundsName(): Text[100]
    begin
        exit(RegisteredCapitalAndCapitalFundsLbl);
    end;

    procedure RegisteredCapitalAndCapitalFunds(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RegisteredCapitalAndCapitalFundsName()));
    end;

    procedure StatutoryReserveName(): Text[100]
    begin
        exit(StatutoryReserveLbl);
    end;

    procedure StatutoryReserve(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StatutoryReserveName()));
    end;

    procedure ProfitLossPreviousYearsName(): Text[100]
    begin
        exit(ProfitLossPreviousYearsLbl);
    end;

    procedure ProfitLossPreviousYears(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProfitLossPreviousYearsName()));
    end;

    procedure ResultOfCurrentYearName(): Text[100]
    begin
        exit(ResultOfCurrentYearLbl);
    end;

    procedure ResultOfCurrentYear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResultOfCurrentYearName()));
    end;

    procedure MediumTermBankLoansName(): Text[100]
    begin
        exit(MediumTermBankLoansLbl);
    end;

    procedure MediumTermBankLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MediumTermBankLoansName()));
    end;

    procedure LongTermBankLoansName(): Text[100]
    begin
        exit(LongTermBankLoansLbl);
    end;

    procedure LongTermBankLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LongTermBankLoansName()));
    end;

    procedure EquityAndLongTermPayablesTotalName(): Text[100]
    begin
        exit(EquityAndLongTermPayablesTotalLbl);
    end;

    procedure EquityAndLongTermPayablesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquityAndLongTermPayablesTotalName()));
    end;

    procedure ExpensesName(): Text[100]
    begin
        exit(ExpensesLbl);
    end;

    procedure Expenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExpensesName()));
    end;

    procedure ConsumptionOfMaterialBeginName(): Text[100]
    begin
        exit(ConsumptionOfMaterialBeginLbl);
    end;

    procedure ConsumptionOfMaterialBegin(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsumptionOfMaterialBeginName()));
    end;

    procedure ConsumptionOfMaterialName(): Text[100]
    begin
        exit(ConsumptionOfMaterialLbl);
    end;

    procedure ConsumptionOfMaterial(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsumptionOfMaterialName()));
    end;

    procedure ComputersConsumableMaterialName(): Text[100]
    begin
        exit(ComputersConsumableMaterialLbl);
    end;

    procedure ComputersConsumableMaterial(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ComputersConsumableMaterialName()));
    end;

    procedure ConsumptionOfMaterialTotalName(): Text[100]
    begin
        exit(ConsumptionOfMaterialTotalLbl);
    end;

    procedure ConsumptionOfMaterialTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsumptionOfMaterialTotalName()));
    end;

    procedure ElectricityBeginName(): Text[100]
    begin
        exit(ElectricityBeginLbl);
    end;

    procedure ElectricityBegin(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ElectricityBeginName()));
    end;

    procedure ElectricityName(): Text[100]
    begin
        exit(ElectricityLbl);
    end;

    procedure Electricity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ElectricityName()));
    end;

    procedure ElectricityTotalName(): Text[100]
    begin
        exit(ElectricityTotalLbl);
    end;

    procedure ElectricityTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ElectricityTotalName()));
    end;

    procedure NonStorableSuppliesBeginName(): Text[100]
    begin
        exit(NonStorableSuppliesBeginLbl);
    end;

    procedure NonStorableSuppliesBegin(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NonStorableSuppliesBeginName()));
    end;

    procedure NonStorableSuppliesName(): Text[100]
    begin
        exit(NonStorableSuppliesLbl);
    end;

    procedure NonStorableSupplies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NonStorableSuppliesName()));
    end;

    procedure NonStorableSuppliesTotalName(): Text[100]
    begin
        exit(NonStorableSuppliesTotalLbl);
    end;

    procedure NonStorableSuppliesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NonStorableSuppliesTotalName()));
    end;

    procedure FuelName(): Text[100]
    begin
        exit(FuelLbl);
    end;

    procedure Fuel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FuelName()));
    end;

    procedure COGSName(): Text[100]
    begin
        exit(COGSLbl);
    end;

    procedure COGS(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(COGSName()));
    end;

    procedure COGSRetailName(): Text[100]
    begin
        exit(COGSRetailLbl);
    end;

    procedure COGSRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(COGSRetailName()));
    end;

    procedure COGSRetailInterimName(): Text[100]
    begin
        exit(COGSRetailInterimLbl);
    end;

    procedure COGSRetailInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(COGSRetailInterimName()));
    end;

    procedure COGSOthersName(): Text[100]
    begin
        exit(COGSOthersLbl);
    end;

    procedure COGSOthers(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(COGSOthersName()));
    end;

    procedure COGSOthersInterimName(): Text[100]
    begin
        exit(COGSOthersInterimLbl);
    end;

    procedure COGSOthersInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(COGSOthersInterimName()));
    end;

    procedure COGSTotalName(): Text[100]
    begin
        exit(COGSTotalLbl);
    end;

    procedure COGSTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(COGSTotalName()));
    end;

    procedure JobCorrectionName(): Text[100]
    begin
        exit(JobCorrectionLbl);
    end;

    procedure JobCorrection(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCorrectionName()));
    end;

    procedure ServicesName(): Text[100]
    begin
        exit(ServicesLbl);
    end;

    procedure Services(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ServicesName()));
    end;

    procedure ServicesTotalName(): Text[100]
    begin
        exit(ServicesTotalLbl);
    end;

    procedure ServicesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ServicesTotalName()));
    end;

    procedure RepresentationCostsName(): Text[100]
    begin
        exit(RepresentationCostsLbl);
    end;

    procedure RepresentationCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RepresentationCostsName()));
    end;

    procedure CleaningName(): Text[100]
    begin
        exit(CleaningLbl);
    end;

    procedure Cleaning(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CleaningName()));
    end;

    procedure PhoneChargeName(): Text[100]
    begin
        exit(PhoneChargeLbl);
    end;

    procedure PhoneCharge(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PhoneChargeName()));
    end;

    procedure PostageName(): Text[100]
    begin
        exit(PostageLbl);
    end;

    procedure Postage(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PostageName()));
    end;

    procedure AdvertisementName(): Text[100]
    begin
        exit(AdvertisementLbl);
    end;

    procedure Advertisement(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvertisementName()));
    end;

    procedure OtherServicesBeginName(): Text[100]
    begin
        exit(OtherServicesBeginLbl);
    end;

    procedure OtherServicesBegin(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherServicesBeginName()));
    end;

    procedure OtherServicesName(): Text[100]
    begin
        exit(OtherServicesLbl);
    end;

    procedure OtherServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherServicesName()));
    end;

    procedure OtherServicesTotalName(): Text[100]
    begin
        exit(OtherServicesTotalLbl);
    end;

    procedure OtherServicesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherServicesTotalName()));
    end;

    procedure PersonalExpensesName(): Text[100]
    begin
        exit(PersonalExpensesLbl);
    end;

    procedure PersonalExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PersonalExpensesName()));
    end;

    procedure SalariesAndWagesName(): Text[100]
    begin
        exit(SalariesAndWagesLbl);
    end;

    procedure SalariesAndWages(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalariesAndWagesName()));
    end;

    procedure TravelExpensesName(): Text[100]
    begin
        exit(TravelExpensesLbl);
    end;

    procedure TravelExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TravelExpensesName()));
    end;

    procedure PersonalExpensesTotalName(): Text[100]
    begin
        exit(PersonalExpensesTotalLbl);
    end;

    procedure PersonalExpensesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PersonalExpensesTotalName()));
    end;

    procedure NetBookValueOfFixedAssetsSoldName(): Text[100]
    begin
        exit(NetBookValueOfFixedAssetsSoldLbl);
    end;

    procedure NetBookValueOfFixedAssetsSold(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NetBookValueOfFixedAssetsSoldName()));
    end;

    procedure ContractualPenaltiesAndInterestsName(): Text[100]
    begin
        exit(ContractualPenaltiesAndInterestsLbl);
    end;

    procedure ContractualPenaltiesAndInterests(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ContractualPenaltiesAndInterestsName()));
    end;

    procedure PaymentsToleranceName(): Text[100]
    begin
        exit(PaymentsToleranceLbl);
    end;

    procedure PaymentsTolerance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymentsToleranceName()));
    end;

    procedure OtherOperatingExpensesTotalName(): Text[100]
    begin
        exit(OtherOperatingExpensesTotalLbl);
    end;

    procedure OtherOperatingExpensesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherOperatingExpensesTotalName()));
    end;

    procedure DepreciationName(): Text[100]
    begin
        exit(DepreciationLbl);
    end;

    procedure Depreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationName()));
    end;

    procedure DepreciationOfBuildingsName(): Text[100]
    begin
        exit(DepreciationOfBuildingsLbl);
    end;

    procedure DepreciationOfBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationOfBuildingsName()));
    end;

    procedure DepreciationOfMachinesAndToolsName(): Text[100]
    begin
        exit(DepreciationOfMachinesAndToolsLbl);
    end;

    procedure DepreciationOfMachinesAndTools(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationOfMachinesAndToolsName()));
    end;

    procedure DepreciationOfVehiclesName(): Text[100]
    begin
        exit(DepreciationOfVehiclesLbl);
    end;

    procedure DepreciationOfVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationOfVehiclesName()));
    end;

    procedure NetBookValueOfFixedAssetsDisposedName(): Text[100]
    begin
        exit(NetBookValueOfFixedAssetsDisposedLbl);
    end;

    procedure NetBookValueOfFixedAssetsDisposed(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NetBookValueOfFixedAssetsDisposedName()));
    end;

    procedure DepreciationTotalName(): Text[100]
    begin
        exit(DepreciationTotalLbl);
    end;

    procedure DepreciationTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationTotalName()));
    end;

    procedure InterestName(): Text[100]
    begin
        exit(InterestLbl);
    end;

    procedure Interest(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterestName()));
    end;

    procedure ExchangeLossesRealizedName(): Text[100]
    begin
        exit(ExchangeLossesRealizedLbl);
    end;

    procedure ExchangeLossesRealized(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExchangeLossesRealizedName()));
    end;

    procedure ExchangeLossesUnrealizedName(): Text[100]
    begin
        exit(ExchangeLossesUnrealizedLbl);
    end;

    procedure ExchangeLossesUnrealized(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExchangeLossesUnrealizedName()));
    end;

    procedure ExpensesTotalName(): Text[100]
    begin
        exit(ExpensesTotalLbl);
    end;

    procedure ExpensesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExpensesTotalName()));
    end;

    procedure RevenuesName(): Text[100]
    begin
        exit(RevenuesLbl);
    end;

    procedure Revenues(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenuesName()));
    end;

    procedure SalesProductsDomesticName(): Text[100]
    begin
        exit(SalesProductsDomesticLbl);
    end;

    procedure SalesProductsDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesProductsDomesticName()));
    end;

    procedure SalesProductsEUName(): Text[100]
    begin
        exit(SalesProductsEULbl);
    end;

    procedure SalesProductsEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesProductsEUName()));
    end;

    procedure SalesProductsExportName(): Text[100]
    begin
        exit(SalesProductsExportLbl);
    end;

    procedure SalesProductsExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesProductsExportName()));
    end;

    procedure SalesServicesDomesticName(): Text[100]
    begin
        exit(SalesServicesDomesticLbl);
    end;

    procedure SalesServicesDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesServicesDomesticName()));
    end;

    procedure SalesServicesEUName(): Text[100]
    begin
        exit(SalesServicesEULbl);
    end;

    procedure SalesServicesEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesServicesEUName()));
    end;

    procedure SalesServicesExportName(): Text[100]
    begin
        exit(SalesServicesExportLbl);
    end;

    procedure SalesServicesExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesServicesExportName()));
    end;

    procedure SalesGoodsName(): Text[100]
    begin
        exit(SalesGoodsLbl);
    end;

    procedure SalesGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesGoodsName()));
    end;

    procedure SalesGoodsDomesticName(): Text[100]
    begin
        exit(SalesGoodsDomesticLbl);
    end;

    procedure SalesGoodsDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesGoodsDomesticName()));
    end;

    procedure SalesGoodsEUName(): Text[100]
    begin
        exit(SalesGoodsEULbl);
    end;

    procedure SalesGoodsEu(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesGoodsEUName()));
    end;

    procedure SalesGoodsExportName(): Text[100]
    begin
        exit(SalesGoodsExportLbl);
    end;

    procedure SalesGoodsExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesGoodsExportName()));
    end;

    procedure SalesGoodsOtherName(): Text[100]
    begin
        exit(SalesGoodsOtherLbl);
    end;

    procedure SalesGoodsOther(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesGoodsOtherName()));
    end;

    procedure SalesGoodsTotalName(): Text[100]
    begin
        exit(SalesGoodsTotalLbl);
    end;

    procedure SalesGoodsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesGoodsTotalName()));
    end;

    procedure OtherOperatingIncomeBeginName(): Text[100]
    begin
        exit(OtherOperatingIncomeBeginLbl);
    end;

    procedure OtherOperatingIncomeBegin(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherOperatingIncomeBeginName()));
    end;

    procedure OtherOperatingIncomeName(): Text[100]
    begin
        exit(OtherOperatingIncomeLbl);
    end;

    procedure OtherOperatingIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherOperatingIncomeName()));
    end;

    procedure SalesFixedAssetsName(): Text[100]
    begin
        exit(SalesFixedAssetsLbl);
    end;

    procedure SalesFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesFixedAssetsName()));
    end;

    procedure DiscountsName(): Text[100]
    begin
        exit(DiscountsLbl);
    end;

    procedure Discounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DiscountsName()));
    end;

    procedure RoundingName(): Text[100]
    begin
        exit(RoundingLbl);
    end;

    procedure Rounding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RoundingName()));
    end;

    procedure OtherOperatingIncomeTotalName(): Text[100]
    begin
        exit(OtherOperatingIncomeTotalLbl);
    end;

    procedure OtherOperatingIncomeTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherOperatingIncomeTotalName()));
    end;

    procedure FinancialRevenuesName(): Text[100]
    begin
        exit(FinancialRevenuesLbl);
    end;

    procedure FinancialRevenues(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialRevenuesName()));
    end;

    procedure InterestReceivedName(): Text[100]
    begin
        exit(InterestReceivedLbl);
    end;

    procedure InterestReceived(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterestReceivedName()));
    end;

    procedure ExchangeGainsRealizedName(): Text[100]
    begin
        exit(ExchangeGainsRealizedLbl);
    end;

    procedure ExchangeGainsRealized(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExchangeGainsRealizedName()));
    end;

    procedure ExchangeGainsUnrealizedName(): Text[100]
    begin
        exit(ExchangeGainsUnrealizedLbl);
    end;

    procedure ExchangeGainsUnrealized(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExchangeGainsUnrealizedName()));
    end;

    procedure RevenuesTotalName(): Text[100]
    begin
        exit(RevenuesTotalLbl);
    end;

    procedure RevenuesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenuesTotalName()));
    end;

    procedure SubBalanceSheetAccountsName(): Text[100]
    begin
        exit(SubBalanceSheetAccountsLbl);
    end;

    procedure SubBalanceSheetAccounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SubBalanceSheetAccountsName()));
    end;

    procedure RentOfFixedAssetsName(): Text[100]
    begin
        exit(RentOfFixedAssetsLbl);
    end;

    procedure RentOfFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentOfFixedAssetsName()));
    end;

    procedure ComputersName(): Text[100]
    begin
        exit(ComputersLbl);
    end;

    procedure Computers(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ComputersName()));
    end;

    procedure RentOfFixedAssetsTotalName(): Text[100]
    begin
        exit(RentOfFixedAssetsTotalLbl);
    end;

    procedure RentOfFixedAssetsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentOfFixedAssetsTotalName()));
    end;

    procedure BalancingAccountName(): Text[100]
    begin
        exit(BalancingAccountLbl);
    end;

    procedure BalancingAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BalancingAccountName()));
    end;

    procedure SubBalanceSheetAccountsTotalName(): Text[100]
    begin
        exit(SubBalanceSheetAccountsTotalLbl);
    end;

    procedure SubBalanceSheetAccountsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SubBalanceSheetAccountsTotalName()));
    end;

    procedure IncomefromemploymentcompanionsName(): Text[100]
    begin
        exit(IncomefromemploymentcompanionsLbl);
    end;

    procedure Incomefromemploymentcompanions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomefromemploymentcompanionsName()));
    end;

    procedure RemunerationtomembersofcompanymanagementName(): Text[100]
    begin
        exit(RemunerationtomembersofcompanymanagementLbl);
    end;

    procedure Remunerationtomembersofcompanymanagement(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RemunerationtomembersofcompanymanagementName()));
    end;

    procedure OtherSocialInsuranceName(): Text[100]
    begin
        exit(OtherSocialInsuranceLbl);
    end;

    procedure OtherSocialInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherSocialInsuranceName()));
    end;

    procedure IndividualsocialcostforbusinessmanName(): Text[100]
    begin
        exit(IndividualsocialcostforbusinessmanLbl);
    end;

    procedure Individualsocialcostforbusinessman(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IndividualsocialcostforbusinessmanName()));
    end;

    procedure StatutorysocialcostName(): Text[100]
    begin
        exit(StatutorysocialcostLbl);
    end;

    procedure Statutorysocialcost(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StatutorysocialcostName()));
    end;

    procedure OthersocialcostsName(): Text[100]
    begin
        exit(OthersocialcostsLbl);
    end;

    procedure Othersocialcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthersocialcostsName()));
    end;

    procedure OthernontaxsocialcostsName(): Text[100]
    begin
        exit(OthernontaxsocialcostsLbl);
    end;

    procedure Othernontaxsocialcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthernontaxsocialcostsName()));
    end;

    procedure OthertaxesandfeesBeginName(): Text[100]
    begin
        exit(OthertaxesandfeesBeginLbl);
    end;

    procedure OthertaxesandfeesBegin(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthertaxesandfeesBeginName()));
    end;

    procedure OthertaxesandfeesName(): Text[100]
    begin
        exit(OthertaxesandfeesLbl);
    end;

    procedure Othertaxesandfees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthertaxesandfeesName()));
    end;

    procedure RoadtaxName(): Text[100]
    begin
        exit(RoadtaxLbl);
    end;

    procedure Roadtax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RoadtaxName()));
    end;

    procedure PropertytaxName(): Text[100]
    begin
        exit(PropertytaxLbl);
    end;

    procedure Propertytax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PropertytaxName()));
    end;

    procedure OthernotaxtaxesandfeesName(): Text[100]
    begin
        exit(OthernotaxtaxesandfeesLbl);
    end;

    procedure Othernotaxtaxesandfees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthernotaxtaxesandfeesName()));
    end;

    procedure OthertaxesandfeestotalName(): Text[100]
    begin
        exit(OthertaxesandfeestotalLbl);
    end;

    procedure Othertaxesandfeestotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthertaxesandfeestotalName()));
    end;

    procedure CostofmaterialsoldInterimName(): Text[100]
    begin
        exit(CostofmaterialsoldInterimLbl);
    end;

    procedure CostofmaterialsoldInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofmaterialsoldInterimName()));
    end;

    procedure CostofmaterialsoldName(): Text[100]
    begin
        exit(CostofmaterialsoldLbl);
    end;

    procedure Costofmaterialsold(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofmaterialsoldName()));
    end;

    procedure PresentsName(): Text[100]
    begin
        exit(PresentsLbl);
    end;

    procedure Presents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PresentsName()));
    end;

    procedure OtherpenaltiesandinterestsName(): Text[100]
    begin
        exit(OtherpenaltiesandinterestsLbl);
    end;

    procedure Otherpenaltiesandinterests(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherpenaltiesandinterestsName()));
    end;

    procedure ReceivablewriteoffName(): Text[100]
    begin
        exit(ReceivablewriteoffLbl);
    end;

    procedure Receivablewriteoff(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReceivablewriteoffName()));
    end;

    procedure OtheroperatingexpensesBeginName(): Text[100]
    begin
        exit(OtheroperatingexpensesBeginLbl);
    end;

    procedure OtheroperatingexpensesBegin(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtheroperatingexpensesBeginName()));
    end;

    procedure OtheroperatingexpensesName(): Text[100]
    begin
        exit(OtheroperatingexpensesLbl);
    end;

    procedure Otheroperatingexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtheroperatingexpensesName()));
    end;

    procedure ShortagesanddamagefromoperactName(): Text[100]
    begin
        exit(ShortagesanddamagefromoperactLbl);
    end;

    procedure Shortagesanddamagefromoperact(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShortagesanddamagefromoperactName()));
    end;

    procedure DepreciationandreservesName(): Text[100]
    begin
        exit(DepreciationandreservesLbl);
    end;

    procedure Depreciationandreserves(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationandreservesName()));
    end;

    procedure CreatandsettlofreservesaccordtospecregulName(): Text[100]
    begin
        exit(CreatandsettlofreservesaccordtospecregulLbl);
    end;

    procedure Creatandsettlofreservesaccordtospecregul(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CreatandsettlofreservesaccordtospecregulName()));
    end;

    procedure CreationandsettlementofothersreservesName(): Text[100]
    begin
        exit(CreationandsettlementofothersreservesLbl);
    end;

    procedure Creationandsettlementofothersreserves(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CreationandsettlementofothersreservesName()));
    end;

    procedure CreationandsettlementlegaladjustmentsName(): Text[100]
    begin
        exit(CreationandsettlementlegaladjustmentsLbl);
    end;

    procedure Creationandsettlementlegaladjustments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CreationandsettlementlegaladjustmentsName()));
    end;

    procedure CreationandsettlementadjustmentstooperactivitiesName(): Text[100]
    begin
        exit(CreationandsettlementadjustmentstooperactivitiesLbl);
    end;

    procedure Creationandsettlementadjustmentstooperactivities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CreationandsettlementadjustmentstooperactivitiesName()));
    end;

    procedure DepreciationandreservestotalName(): Text[100]
    begin
        exit(DepreciationandreservestotalLbl);
    end;

    procedure Depreciationandreservestotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationandreservestotalName()));
    end;

    procedure FinancialexpensesName(): Text[100]
    begin
        exit(FinancialexpensesLbl);
    end;

    procedure Financialexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialexpensesName()));
    end;

    procedure ExpensesrelatedtofinancialassetsName(): Text[100]
    begin
        exit(ExpensesrelatedtofinancialassetsLbl);
    end;

    procedure Expensesrelatedtofinancialassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExpensesrelatedtofinancialassetsName()));
    end;

    procedure OtherfinancialrevenuesName(): Text[100]
    begin
        exit(OtherfinancialrevenuesLbl);
    end;

    procedure Otherfinancialrevenues(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherfinancialrevenuesName()));
    end;

    procedure OtherfinancialexpensesName(): Text[100]
    begin
        exit(OtherfinancialexpensesLbl);
    end;

    procedure Otherfinancialexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherfinancialexpensesName()));
    end;

    procedure FinancialexpensestotalName(): Text[100]
    begin
        exit(FinancialexpensestotalLbl);
    end;

    procedure Financialexpensestotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialexpensestotalName()));
    end;

    procedure ReservesandadjfromfinactivitiesName(): Text[100]
    begin
        exit(ReservesandadjfromfinactivitiesLbl);
    end;

    procedure Reservesandadjfromfinactivities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReservesandadjfromfinactivitiesName()));
    end;

    procedure CreationandsettlementoffinancialreservesName(): Text[100]
    begin
        exit(CreationandsettlementoffinancialreservesLbl);
    end;

    procedure Creationandsettlementoffinancialreserves(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CreationandsettlementoffinancialreservesName()));
    end;

    procedure CreationandsettlementadjustmentsName(): Text[100]
    begin
        exit(CreationandsettlementadjustmentsLbl);
    end;

    procedure Creationandsettlementadjustments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CreationandsettlementadjustmentsName()));
    end;

    procedure ReservesandadjfromfinactivitiestotalName(): Text[100]
    begin
        exit(ReservesandadjfromfinactivitiestotalLbl);
    end;

    procedure Reservesandadjfromfinactivitiestotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReservesandadjfromfinactivitiestotalName()));
    end;

    procedure ChangeininventoryofownproductionandactivationName(): Text[100]
    begin
        exit(ChangeininventoryofownproductionandactivationLbl);
    end;

    procedure Changeininventoryofownproductionandactivation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChangeininventoryofownproductionandactivationName()));
    end;

    procedure ChangeininventoryofownproductionandactivationtotalName(): Text[100]
    begin
        exit(ChangeininventoryofownproductionandactivationtotalLbl);
    end;

    procedure Changeininventoryofownproductionandactivationtotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChangeininventoryofownproductionandactivationtotalName()));
    end;

    procedure ChangeinWIPName(): Text[100]
    begin
        exit(ChangeinWIPLbl);
    end;

    procedure ChangeinWIP(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChangeinWIPName()));
    end;

    procedure VarianceofoverheadcostName(): Text[100]
    begin
        exit(VarianceofoverheadcostLbl);
    end;

    procedure Varianceofoverheadcost(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VarianceofoverheadcostName()));
    end;

    procedure ChangeinsemifinishedproductsName(): Text[100]
    begin
        exit(ChangeinsemifinishedproductsLbl);
    end;

    procedure Changeinsemifinishedproducts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChangeinsemifinishedproductsName()));
    end;

    procedure ChangeinfinishedproductsName(): Text[100]
    begin
        exit(ChangeinfinishedproductsLbl);
    end;

    procedure Changeinfinishedproducts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChangeinfinishedproductsName()));
    end;

    procedure ChangeofanimalsName(): Text[100]
    begin
        exit(ChangeofanimalsLbl);
    end;

    procedure Changeofanimals(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChangeofanimalsName()));
    end;

    procedure ActivationofgoodsandmaterialName(): Text[100]
    begin
        exit(ActivationofgoodsandmaterialLbl);
    end;

    procedure Activationofgoodsandmaterial(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ActivationofgoodsandmaterialName()));
    end;

    procedure ActivationofinternalservicesName(): Text[100]
    begin
        exit(ActivationofinternalservicesLbl);
    end;

    procedure Activationofinternalservices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ActivationofinternalservicesName()));
    end;

    procedure ActivationofintangiblefixedassetsName(): Text[100]
    begin
        exit(ActivationofintangiblefixedassetsLbl);
    end;

    procedure Activationofintangiblefixedassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ActivationofintangiblefixedassetsName()));
    end;

    procedure ActivationoftangiblefixedassetsName(): Text[100]
    begin
        exit(ActivationoftangiblefixedassetsLbl);
    end;

    procedure Activationoftangiblefixedassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ActivationoftangiblefixedassetsName()));
    end;

    procedure IncometaxonordinaryactivitiespayableName(): Text[100]
    begin
        exit(IncometaxonordinaryactivitiespayableLbl);
    end;

    procedure Incometaxonordinaryactivitiespayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncometaxonordinaryactivitiespayableName()));
    end;

    procedure IncometaxonordinaryactivitiesdeferredName(): Text[100]
    begin
        exit(IncometaxonordinaryactivitiesdeferredLbl);
    end;

    procedure Incometaxonordinaryactivitiesdeferred(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncometaxonordinaryactivitiesdeferredName()));
    end;

    procedure SalesjobsName(): Text[100]
    begin
        exit(SalesjobsLbl);
    end;

    procedure Salesjobs(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesjobsName()));
    end;

    procedure SalesmaterialName(): Text[100]
    begin
        exit(SalesmaterialLbl);
    end;

    procedure Salesmaterial(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesmaterialName()));
    end;

    procedure RevenuesfromlongtermfinancialassetsName(): Text[100]
    begin
        exit(RevenuesfromlongtermfinancialassetsLbl);
    end;

    procedure Revenuesfromlongtermfinancialassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenuesfromlongtermfinancialassetsName()));
    end;

    procedure RevenuesfromshorttermfinancialassetsName(): Text[100]
    begin
        exit(RevenuesfromshorttermfinancialassetsLbl);
    end;

    procedure Revenuesfromshorttermfinancialassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenuesfromshorttermfinancialassetsName()));
    end;

    procedure FinancialrevenuestotalName(): Text[100]
    begin
        exit(FinancialrevenuestotalLbl);
    end;

    procedure Financialrevenuestotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialrevenuestotalName()));
    end;

    procedure TransferaccountsName(): Text[100]
    begin
        exit(TransferaccountsLbl);
    end;

    procedure Transferaccounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TransferaccountsName()));
    end;

    procedure TransferofoperatingrevenuesName(): Text[100]
    begin
        exit(TransferofoperatingrevenuesLbl);
    end;

    procedure Transferofoperatingrevenues(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TransferofoperatingrevenuesName()));
    end;

    procedure TransferoffinancialrevenuesName(): Text[100]
    begin
        exit(TransferoffinancialrevenuesLbl);
    end;

    procedure Transferoffinancialrevenues(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TransferoffinancialrevenuesName()));
    end;

    procedure TransferaccountstotalName(): Text[100]
    begin
        exit(TransferaccountstotalLbl);
    end;

    procedure Transferaccountstotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TransferaccountstotalName()));
    end;

    procedure OpeningbalancesheetaccountName(): Text[100]
    begin
        exit(OpeningbalancesheetaccountLbl);
    end;

    procedure Openingbalancesheetaccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OpeningbalancesheetaccountName()));
    end;

    procedure ClosingbalancesheetaccountName(): Text[100]
    begin
        exit(ClosingbalancesheetaccountLbl);
    end;

    procedure Closingbalancesheetaccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ClosingbalancesheetaccountName()));
    end;

    procedure ProfitandlossaccountName(): Text[100]
    begin
        exit(ProfitandlossaccountLbl);
    end;

    procedure Profitandlossaccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProfitandlossaccountName()));
    end;

    procedure PrepaidexpensesName(): Text[100]
    begin
        exit(PrepaidexpensesLbl);
    end;

    procedure Prepaidexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaidexpensesName()));
    end;

    procedure ComplexprepaidexpensesName(): Text[100]
    begin
        exit(ComplexprepaidexpensesLbl);
    end;

    procedure Complexprepaidexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ComplexprepaidexpensesName()));
    end;

    procedure AccruedexpensesName(): Text[100]
    begin
        exit(AccruedexpensesLbl);
    end;

    procedure Accruedexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedexpensesName()));
    end;

    procedure DeferredrevenuesName(): Text[100]
    begin
        exit(DeferredrevenuesLbl);
    end;

    procedure Deferredrevenues(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferredrevenuesName()));
    end;

    procedure AccruedincomesName(): Text[100]
    begin
        exit(AccruedincomesLbl);
    end;

    procedure Accruedincomes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedincomesName()));
    end;

    procedure IntangibleresultsofresearchanddevelopmentName(): Text[100]
    begin
        exit(IntangibleresultsofresearchanddevelopmentLbl);
    end;

    procedure Intangibleresultsofresearchanddevelopment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntangibleresultsofresearchanddevelopmentName()));
    end;

    procedure ValuablerightsName(): Text[100]
    begin
        exit(ValuablerightsLbl);
    end;

    procedure Valuablerights(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ValuablerightsName()));
    end;

    procedure GoodwillName(): Text[100]
    begin
        exit(GoodwillLbl);
    end;

    procedure Goodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodwillName()));
    end;

    procedure IntangiblefixedassetsName(): Text[100]
    begin
        exit(IntangiblefixedassetsLbl);
    end;

    procedure Intangiblefixedassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntangiblefixedassetsName()));
    end;

    procedure IntangiblefixedassetstotalName(): Text[100]
    begin
        exit(IntangiblefixedassetstotalLbl);
    end;

    procedure Intangiblefixedassetstotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntangiblefixedassetstotalName()));
    end;

    procedure OtherintangiblefixedassetsName(): Text[100]
    begin
        exit(OtherintangiblefixedassetsLbl);
    end;

    procedure Otherintangiblefixedassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherintangiblefixedassetsName()));
    end;

    procedure TangiblefixedassetsnondeductibleName(): Text[100]
    begin
        exit(TangiblefixedassetsnondeductibleLbl);
    end;

    procedure Tangiblefixedassetsnondeductible(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TangiblefixedassetsnondeductibleName()));
    end;

    procedure LandsName(): Text[100]
    begin
        exit(LandsLbl);
    end;

    procedure Lands(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LandsName()));
    end;

    procedure TangiblefixedassetsnondeductibletotalName(): Text[100]
    begin
        exit(TangiblefixedassetsnondeductibletotalLbl);
    end;

    procedure Tangiblefixedassetsnondeductibletotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TangiblefixedassetsnondeductibletotalName()));
    end;

    procedure AccumulateddepreciationtointangiblefixedassetsName(): Text[100]
    begin
        exit(AccumulateddepreciationtointangiblefixedassetsLbl);
    end;

    procedure Accumulateddepreciationtointangiblefixedassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulateddepreciationtointangiblefixedassetsName()));
    end;

    procedure AccumulateddepreciationtointangibleresultsofresearchanddevelopmentName(): Text[100]
    begin
        exit(AccumulateddepreciationtointangibleresultsofresearchanddevelopmentLbl);
    end;

    procedure Accumulateddepreciationtointangibleresultsofresearchanddevelopment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulateddepreciationtointangibleresultsofresearchanddevelopmentName()));
    end;

    procedure AccumulateddepreciationtosoftwareName(): Text[100]
    begin
        exit(AccumulateddepreciationtosoftwareLbl);
    end;

    procedure Accumulateddepreciationtosoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulateddepreciationtosoftwareName()));
    end;

    procedure AccumulateddepreciationtovaluablerightsName(): Text[100]
    begin
        exit(AccumulateddepreciationtovaluablerightsLbl);
    end;

    procedure Accumulateddepreciationtovaluablerights(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulateddepreciationtovaluablerightsName()));
    end;

    procedure AccumulateddepreciationtogoodwillName(): Text[100]
    begin
        exit(AccumulateddepreciationtogoodwillLbl);
    end;

    procedure Accumulateddepreciationtogoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulateddepreciationtogoodwillName()));
    end;

    procedure AccumulateddepreciationtootherintangiblefixedassetsName(): Text[100]
    begin
        exit(AccumulateddepreciationtootherintangiblefixedassetsLbl);
    end;

    procedure Accumulateddepreciationtootherintangiblefixedassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulateddepreciationtootherintangiblefixedassetsName()));
    end;

    procedure AccumulateddepreciationtointangiblefixedassetstotalName(): Text[100]
    begin
        exit(AccumulateddepreciationtointangiblefixedassetstotalLbl);
    end;

    procedure Accumulateddepreciationtointangiblefixedassetstotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulateddepreciationtointangiblefixedassetstotalName()));
    end;

    procedure UnidentifiedpaymentsName(): Text[100]
    begin
        exit(UnidentifiedpaymentsLbl);
    end;

    procedure Unidentifiedpayments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(UnidentifiedpaymentsName()));
    end;

    procedure TemporaryaccountsofassetsandliabilitiesName(): Text[100]
    begin
        exit(TemporaryaccountsofassetsandliabilitiesLbl);
    end;

    procedure Temporaryaccountsofassetsandliabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TemporaryaccountsofassetsandliabilitiesName()));
    end;

    procedure TemporaryaccountsofassetsandliabilitiestotalName(): Text[100]
    begin
        exit(TemporaryaccountsofassetsandliabilitiestotalLbl);
    end;

    procedure Temporaryaccountsofassetsandliabilitiestotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TemporaryaccountsofassetsandliabilitiestotalName()));
    end;

    procedure IncometaxprovisionsName(): Text[100]
    begin
        exit(IncometaxprovisionsLbl);
    end;

    procedure Incometaxprovisions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncometaxprovisionsName()));
    end;

    procedure OtherprovisionsName(): Text[100]
    begin
        exit(OtherprovisionsLbl);
    end;

    procedure Otherprovisions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherprovisionsName()));
    end;

    procedure OtherlongtermpayablesName(): Text[100]
    begin
        exit(OtherlongtermpayablesLbl);
    end;

    procedure Otherlongtermpayables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherlongtermpayablesName()));
    end;

    procedure DepreciationofpatentsName(): Text[100]
    begin
        exit(DepreciationofpatentsLbl);
    end;

    procedure Depreciationofpatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationofpatentsName()));
    end;

    procedure DepreciationofsoftwareName(): Text[100]
    begin
        exit(DepreciationofsoftwareLbl);
    end;

    procedure Depreciationofsoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationofsoftwareName()));
    end;

    procedure DepreciationofgoodwillName(): Text[100]
    begin
        exit(DepreciationofgoodwillLbl);
    end;

    procedure Depreciationofgoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationofgoodwillName()));
    end;

    procedure DepreciationofotherintangiblefixedassetsName(): Text[100]
    begin
        exit(DepreciationofotherintangiblefixedassetsLbl);
    end;

    procedure Depreciationofotherintangiblefixedassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationofotherintangiblefixedassetsName()));
    end;

    procedure PostponedVATPurchaseName(): Text[100]
    begin
        exit(PostponedVATPurchaseLbl);
    end;

    procedure PostponedVATPurchase(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PostponedVATPurchaseName()));
    end;

    procedure InputVAT12Name(): Text[100]
    begin
        exit(InputVAT12Lbl);
    end;

    procedure InputVAT12(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InputVAT12Name()));
    end;

    procedure InputVAT21Name(): Text[100]
    begin
        exit(InputVAT21Lbl);
    end;

    procedure InputVAT21(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InputVAT21Name()));
    end;

    procedure OutputVAT12Name(): Text[100]
    begin
        exit(OutputVAT12Lbl);
    end;

    procedure OutputVAT12(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OutputVAT12Name()));
    end;

    procedure OutputVAT21Name(): Text[100]
    begin
        exit(OutputVAT21Lbl);
    end;

    procedure OutputVAT21(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OutputVAT21Name()));
    end;

    procedure ReverseChargeVAT12Name(): Text[100]
    begin
        exit(ReverseChargeVAT12Lbl);
    end;

    procedure ReverseChargeVAT12(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReverseChargeVAT12Name()));
    end;

    procedure ReverseChargeVAT21Name(): Text[100]
    begin
        exit(ReverseChargeVAT21Lbl);
    end;

    procedure ReverseChargeVAT21(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReverseChargeVAT21Name()));
    end;

    procedure AdvancesVAT12Name(): Text[100]
    begin
        exit(AdvancesVAT12Lbl);
    end;

    procedure AdvancesVAT12(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancesVAT12Name()));
    end;

    procedure AdvancesVAT21Name(): Text[100]
    begin
        exit(AdvancesVAT21Lbl);
    end;

    procedure AdvancesVAT21(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancesVAT21Name()));
    end;

    procedure DirectCostAppliedRetailName(): Text[100]
    begin
        exit(DirectCostAppliedRetailLbl);
    end;

    procedure DirectCostAppliedRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DirectCostAppliedRetailName()));
    end;

    procedure OverheadAppliedRetailName(): Text[100]
    begin
        exit(OverheadAppliedRetailLbl);
    end;

    procedure OverheadAppliedRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OverheadAppliedRetailName()));
    end;

    procedure PurchaseVarianceRetailName(): Text[100]
    begin
        exit(PurchaseVarianceRetailLbl);
    end;

    procedure PurchaseVarianceRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVarianceRetailName()));
    end;

    procedure PurchaseVarianceRawmatName(): Text[100]
    begin
        exit(PurchaseVarianceRawmatLbl);
    end;

    procedure PurchaseVarianceRawmat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVarianceRawmatName()));
    end;

    procedure OverheadAppliedCapName(): Text[100]
    begin
        exit(OverheadAppliedCapLbl);
    end;

    procedure OverheadAppliedCap(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OverheadAppliedCapName()));
    end;

    procedure PurchaseVarianceCapName(): Text[100]
    begin
        exit(PurchaseVarianceCapLbl);
    end;

    procedure PurchaseVarianceCap(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVarianceCapName()));
    end;

    procedure CapacityVarianceName(): Text[100]
    begin
        exit(CapacityVarianceLbl);
    end;

    procedure CapacityVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapacityVarianceName()));
    end;

    procedure SubcontractedVarianceName(): Text[100]
    begin
        exit(SubcontractedVarianceLbl);
    end;

    procedure SubcontractedVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SubcontractedVarianceName()));
    end;

    procedure InventoryOfOwnProductionName(): Text[100]
    begin
        exit(InventoryOfOwnProductionLbl);
    end;

    procedure InventoryOfOwnProduction(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryOfOwnProductionName()));
    end;

    procedure InventoryOfOwnProductionTotalName(): Text[100]
    begin
        exit(InventoryOfOwnProductionTotalLbl);
    end;

    procedure InventoryOfOwnProductionTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryOfOwnProductionTotalName()));
    end;

    procedure GoodsName(): Text[100]
    begin
        exit(GoodsLbl);
    end;

    procedure Goods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsName()));
    end;

    procedure GoodsTotalName(): Text[100]
    begin
        exit(GoodsTotalLbl);
    end;

    procedure GoodsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsTotalName()));
    end;

    procedure CurrentFinancialAssetsName(): Text[100]
    begin
        exit(CurrentFinancialAssetsLbl);
    end;

    procedure CurrentFinancialAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentFinancialAssetsName()));
    end;

    procedure CurrentFinancialAssetsTotalName(): Text[100]
    begin
        exit(CurrentFinancialAssetsTotalLbl);
    end;

    procedure CurrentFinancialAssetsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentFinancialAssetsTotalName()));
    end;

    procedure NettingRelationshipsName(): Text[100]
    begin
        exit(NettingRelationshipsLbl);
    end;

    procedure NettingRelationships(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NettingRelationshipsName()));
    end;

    procedure NettingRelationshipsTotalName(): Text[100]
    begin
        exit(NettingRelationshipsTotalLbl);
    end;

    procedure NettingRelationshipsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NettingRelationshipsTotalName()));
    end;

    procedure CustomersIntercompanyName(): Text[100]
    begin
        exit(CustomersIntercompanyLbl);
    end;

    procedure CustomersIntercompany(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomersIntercompanyName()));
    end;

    procedure VendorsIntercompanyName(): Text[100]
    begin
        exit(VendorsIntercompanyLbl);
    end;

    procedure VendorsIntercompany(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorsIntercompanyName()));
    end;

    procedure PrepaidHardwareContractsName(): Text[100]
    begin
        exit(PrepaidHardwareContractsLbl);
    end;

    procedure PrepaidHardwareContracts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaidHardwareContractsName()));
    end;

    procedure PrepaidSoftwareContractsName(): Text[100]
    begin
        exit(PrepaidSoftwareContractsLbl);
    end;

    procedure PrepaidSoftwareContracts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaidSoftwareContractsName()));
    end;

    procedure ServiceContractSaleName(): Text[100]
    begin
        exit(ServiceContractSaleLbl);
    end;

    procedure ServiceContractSale(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ServiceContractSaleName()));
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        BuildingsLbl: Label 'Buildings', MaxLength = 100;
        MachinestoolsequipmentLbl: Label 'Machines, tools, equipment', MaxLength = 100;
        AcquisitionoffixedassetsLbl: Label 'Acquisition of fixed assets', MaxLength = 100;
        AcquisitionoffixedassetstotalLbl: Label 'Acquisition of fixed assets total', MaxLength = 100;
        AcquisitionOfIntangibleFixedAssetsLbl: Label 'Acquisition of intangible fixed assets', MaxLength = 100;
        AcquisitionOfTangibleFixedAssetsLbl: Label 'Acquisition of tangible fixed assets', MaxLength = 100;
        AcquisitionOfMachineryLbl: Label 'Acquisition of machinery', MaxLength = 100;
        AcquisitionOfVehiclesLbl: Label 'Acquisition of vehicles', MaxLength = 100;
        AccumulatedDepreciationToTangibleFixedAssetsLbl: Label 'Accumulated depreciation to tangible fixed assets', MaxLength = 100;
        AccumulatedDepreciationToBuildingsLbl: Label 'Accumulated depreciation to buildings', MaxLength = 100;
        AccumulatedDepreciationToMachineryLbl: Label 'Accumulated depreciation to machinery', MaxLength = 100;
        AccumulatedDepreciationToVehiclesLbl: Label 'Accumulated depreciation to vehicles', MaxLength = 100;
        AccumulatedDepreciationToTangibleFixedAssetsTotalLbl: Label 'Accumulated depreciation to tangible fixed assets total', MaxLength = 100;
        AcquisitionOfMaterialLbl: Label 'Acquisition of material', MaxLength = 100;
        MaterialLbl: Label 'Material', MaxLength = 100;
        MaterialTotalLbl: Label 'Material total', MaxLength = 100;
        MaterialInStockInterimLbl: Label 'Material in stock (interim)', MaxLength = 100;
        MaterialInStockLbl: Label 'Material in stock', MaxLength = 100;
        WorkInProgressBeginLbl: Label 'Work in progress begin', MaxLength = 100;
        WorkInProgressLbl: Label 'Work in progress', MaxLength = 100;
        WorkInProgressTotalLbl: Label 'Work in progress total', MaxLength = 100;
        FinishedProductsInterimLbl: Label 'Finished products (interim)', MaxLength = 100;
        FinishedProductsLbl: Label 'Finished products', MaxLength = 100;
        FinishedProductsBeginLbl: Label 'Finished products begin', MaxLength = 100;
        FinishedProductsTotalLbl: Label 'Finished products total', MaxLength = 100;
        AcquisitionOfGoodsBeginLbl: Label 'Acquisition of goods begin', MaxLength = 100;
        AcquisitionOfGoodsLbl: Label 'Acquisition of goods', MaxLength = 100;
        AcquisitionRetailLbl: Label 'Acquisition - retail', MaxLength = 100;
        AcquisitionRetailInterimLbl: Label 'Acquisition - retail (interim)', MaxLength = 100;
        AcquisitionRawMaterialInterimLbl: Label 'Acquisition - raw material (interim)', MaxLength = 100;
        AcquisitionRawMaterialDomesticLbl: Label 'Acquisition - raw material, domestic', MaxLength = 100;
        AcquisitionRawMaterialEuLbl: Label 'Acquisition - raw material, EU', MaxLength = 100;
        AcquisitionRawMaterialExportLbl: Label 'Acquisition - raw material, export', MaxLength = 100;
        AcquisitionRawMaterialLbl: Label 'Acquisition - raw material', MaxLength = 100;
        AcquisitionOfGoodsTotalLbl: Label 'Acquisition of goods total', MaxLength = 100;
        GoodsInStockLbl: Label 'Goods in stock', MaxLength = 100;
        GoodsInRetailLbl: Label 'Goods in retail', MaxLength = 100;
        GoodsInRetailInterimLbl: Label 'Goods in retail (interim)', MaxLength = 100;
        GoodsInStockTotalLbl: Label 'Goods in stock total', MaxLength = 100;
        CashDeskLmLbl: Label 'Cash Desk LM', MaxLength = 100;
        BankAccountsLbl: Label 'Bank Accounts', MaxLength = 100;
        BankAccountsTotalLbl: Label 'Bank Accounts total', MaxLength = 100;
        BankAccountEURLbl: Label 'Bank Account - EUR', MaxLength = 100;
        BankAccountKBLbl: Label 'Bank Account - KB', MaxLength = 100;
        ShortTermBankLoansLbl: Label 'Short-term bank loans', MaxLength = 100;
        ShortTermSecuritiesLbl: Label 'Short-term securities', MaxLength = 100;
        CashtransferLbl: Label 'Cash transfer', MaxLength = 100;
        CashBeginLbl: Label 'Cash begin', MaxLength = 100;
        CashTotalLbl: Label 'Cash total', MaxLength = 100;
        ReceivablesLbl: Label 'Receivables', MaxLength = 100;
        DomesticCustomersReceivablesLbl: Label 'Domestic customers (receivables)', MaxLength = 100;
        ForeignCustomersOutsideEUReceivablesLbl: Label 'Foreign customers outside EU (receivables)', MaxLength = 100;
        EUCustomersReceivablesLbl: Label 'EU customers (receivables)', MaxLength = 100;
        ReceivablesFromBusinessRelationFeesLbl: Label 'Receivables from business relation (fees)', MaxLength = 100;
        PurchaseAdvancesDomesticLbl: Label 'Purchase Advances - domestic', MaxLength = 100;
        PurchaseAdvancesForeignLbl: Label 'Purchase Advances - foreign', MaxLength = 100;
        PurchaseAdvancesEULbl: Label 'Purchase Advances - EU', MaxLength = 100;
        OtherReceivablesLbl: Label 'Other receivables', MaxLength = 100;
        ReceivablesTotalLbl: Label 'Receivables total', MaxLength = 100;
        PayablesLbl: Label 'Payables', MaxLength = 100;
        DomesticVendorsPayablesLbl: Label 'Domestic vendors (payables)', MaxLength = 100;
        ForeignVendorsOutsideEUPayablesLbl: Label 'Foreign vendors outside EU (payables)', MaxLength = 100;
        EUVendorsPayablesLbl: Label 'EU vendors (payables)', MaxLength = 100;
        SalesAdvancesDomesticLbl: Label 'Sales Advances - domestic', MaxLength = 100;
        SalesAdvancesForeignLbl: Label 'Sales Advances - foreign', MaxLength = 100;
        SalesAdvancesEULbl: Label 'Sales Advances - EU', MaxLength = 100;
        OtherpayablesLbl: Label 'Other payables', MaxLength = 100;
        PayablesTotalLbl: Label 'Payables total', MaxLength = 100;
        EmployeesAndInstitutionsSettlementLbl: Label 'Employees and institutions settlement', MaxLength = 100;
        EmployeesLbl: Label 'Employees', MaxLength = 100;
        PayablesToEmployeesLbl: Label 'Payables to employees', MaxLength = 100;
        SocialInstitutionsSettlementLbl: Label 'Social institutions settlement', MaxLength = 100;
        HealthInstitutionsSettlementLbl: Label 'Health institutions settlement', MaxLength = 100;
        EmployeesAndInstitutionsSettlementTotalLbl: Label 'Employees and institutions settlement total', MaxLength = 100;
        SocialInsuranceLbl: Label 'Social insurance', MaxLength = 100;
        HealthInsuranceLbl: Label 'Health insurance', MaxLength = 100;
        IncomeTaxBeginLbl: Label 'Income tax begin', MaxLength = 100;
        IncomeTaxLbl: Label 'Income tax', MaxLength = 100;
        IncomeTaxTotalLbl: Label 'Income tax total', MaxLength = 100;
        IncomeTaxOnEmploymentLbl: Label 'Income tax on employment', MaxLength = 100;
        VATLbl: Label 'VAT', MaxLength = 100;
        InputVAT12Lbl: Label 'Input VAT 12', MaxLength = 100;
        InputVAT21Lbl: Label 'Input VAT 21', MaxLength = 100;
        OutputVAT12Lbl: Label 'Output VAT 12', MaxLength = 100;
        OutputVAT21Lbl: Label 'Output VAT 21', MaxLength = 100;
        ReverseChargeVAT12Lbl: Label 'Reverse Charge VAT 12', MaxLength = 100;
        ReverseChargeVAT21Lbl: Label 'Reverse Charge VAT 21', MaxLength = 100;
        AdvancesVAT12Lbl: Label 'Advances VAT 12', MaxLength = 100;
        AdvancesVAT21Lbl: Label 'Advances VAT 21', MaxLength = 100;
        VATSettlementLbl: Label 'VAT settlement', MaxLength = 100;
        VATTotalLbl: Label 'VAT total', MaxLength = 100;
        PostponedVatLbl: Label 'Postponed VAT', MaxLength = 100;
        AccruedRevenueItemsLbl: Label 'Accrued revenue (items)', MaxLength = 100;
        AccrualsLbl: Label 'Accruals', MaxLength = 100;
        InternalSettlementLbl: Label 'Internal settlement', MaxLength = 100;
        EquityAndLongTermPayablesLbl: Label 'Equity and long-term payables', MaxLength = 100;
        RegisteredCapitalAndCapitalFundsLbl: Label 'Registered capital and capital funds', MaxLength = 100;
        StatutoryreserveLbl: Label 'Statutory reserve', MaxLength = 100;
        ProfitLossPreviousYearsLbl: Label 'Profit/loss previous years', MaxLength = 100;
        ResultofcurrentyearLbl: Label 'Result of current year', MaxLength = 100;
        MediumTermBankLoansLbl: Label 'Medium-term bank loans', MaxLength = 100;
        LongTermBankLoansLbl: Label 'Long-term bank loans', MaxLength = 100;
        EquityAndLongTermPayablesTotalLbl: Label 'Equity and long-term payables total', MaxLength = 100;
        ExpensesLbl: Label 'Expenses', MaxLength = 100;
        ConsumptionOfMaterialBeginLbl: Label 'Consumption of material begin', MaxLength = 100;
        ConsumptionOfMaterialLbl: Label 'Consumption of material', MaxLength = 100;
        ComputersConsumableMaterialLbl: Label 'Computers - consumable material', MaxLength = 100;
        ConsumptionOfMaterialTotalLbl: Label 'Consumption of material total', MaxLength = 100;
        ElectricityBeginLbl: Label 'Electricity begin', MaxLength = 100;
        ElectricityLbl: Label 'Electricity', MaxLength = 100;
        ElectricityTotalLbl: Label 'Electricity total', MaxLength = 100;
        NonstorablesuppliesBeginLbl: Label 'Non-storable supplies begin', MaxLength = 100;
        NonstorablesuppliesLbl: Label 'Non-storable supplies', MaxLength = 100;
        NonstorablesuppliestotalLbl: Label 'Non-storable supplies total', MaxLength = 100;
        FuelLbl: Label 'Fuel', MaxLength = 100;
        COGSLbl: Label 'COGS', MaxLength = 100;
        COGSRetailLbl: Label 'COGS - retail', MaxLength = 100;
        COGSRetailInterimLbl: Label 'COGS - retail (interim)', MaxLength = 100;
        COGSOthersLbl: Label 'COGS - others', MaxLength = 100;
        COGSOthersInterimLbl: Label 'COGS - others (interim)', MaxLength = 100;
        COGSTotalLbl: Label 'COGS total', MaxLength = 100;
        JobCorrectionLbl: Label 'Job correction', MaxLength = 100;
        ServicesLbl: Label 'Services', MaxLength = 100;
        ServicesTotalLbl: Label 'Services total', MaxLength = 100;
        RepresentationCostsLbl: Label 'Representation costs', MaxLength = 100;
        CleaningLbl: Label 'Cleaning', MaxLength = 100;
        PhoneChargeLbl: Label 'Phone charge', MaxLength = 100;
        PostageLbl: Label 'Postage', MaxLength = 100;
        AdvertisementLbl: Label 'Advertisement', MaxLength = 100;
        OtherServicesBeginLbl: Label 'Other services begin', MaxLength = 100;
        OtherServicesLbl: Label 'Other services', MaxLength = 100;
        OtherServicesTotalLbl: Label 'Other services total', MaxLength = 100;
        PersonalExpensesLbl: Label 'Personal expenses', MaxLength = 100;
        SalariesAndWagesLbl: Label 'Salaries and wages', MaxLength = 100;
        TravelExpensesLbl: Label 'Travel expenses', MaxLength = 100;
        PersonalExpensesTotalLbl: Label 'Personal expenses total', MaxLength = 100;
        NetBookValueOfFixedAssetsSoldLbl: Label 'Net book value of fixed assets sold', MaxLength = 100;
        ContractualPenaltiesAndInterestsLbl: Label 'Contractual penalties and interests', MaxLength = 100;
        PaymentsToleranceLbl: Label 'Payments tolerance', MaxLength = 100;
        OtherOperatingExpensesTotalLbl: Label 'Other operating expenses total', MaxLength = 100;
        DepreciationLbl: Label 'Depreciation', MaxLength = 100;
        DepreciationOfBuildingsLbl: Label 'Depreciation of buildings', MaxLength = 100;
        DepreciationOfMachinesAndToolsLbl: Label 'Depreciation of machines and tools', MaxLength = 100;
        DepreciationOfVehiclesLbl: Label 'Depreciation of vehicles', MaxLength = 100;
        NetBookValueOfFixedAssetsDisposedLbl: Label 'Net book value of fixed assets disposed', MaxLength = 100;
        DepreciationtotalLbl: Label 'Depreciation total', MaxLength = 100;
        InterestLbl: Label 'Interest', MaxLength = 100;
        ExchangeLossesRealizedLbl: Label 'Exchange losses - realized', MaxLength = 100;
        ExchangeLossesUnrealizedLbl: Label 'Exchange losses - unrealized', MaxLength = 100;
        ExpensesTotalLbl: Label 'EXPENSES - TOTAL', MaxLength = 100;
        RevenuesLbl: Label 'Revenues', MaxLength = 100;
        SalesProductsDomesticLbl: Label 'Sales products - domestic', MaxLength = 100;
        SalesProductsEULbl: Label 'Sales products - EU', MaxLength = 100;
        SalesProductsExportLbl: Label 'Sales products - export', MaxLength = 100;
        SalesServicesDomesticLbl: Label 'Sales services - domestic', MaxLength = 100;
        SalesServicesEULbl: Label 'Sales services - EU', MaxLength = 100;
        SalesServicesExportLbl: Label 'Sales services - export', MaxLength = 100;
        SalesGoodsLbl: Label 'Sales goods', MaxLength = 100;
        SalesGoodsDomesticLbl: Label 'Sales goods - domestic', MaxLength = 100;
        SalesGoodsEULbl: Label 'Sales goods - EU', MaxLength = 100;
        SalesGoodsExportLbl: Label 'Sales goods - export', MaxLength = 100;
        SalesGoodsOtherLbl: Label 'Sales goods - other', MaxLength = 100;
        SalesGoodsTotalLbl: Label 'Sales goods total', MaxLength = 100;
        OtherOperatingIncomeBeginLbl: Label 'Other operating income begin', MaxLength = 100;
        OtherOperatingIncomeLbl: Label 'Other operating income', MaxLength = 100;
        SalesFixedAssetsLbl: Label 'Sales fixed assets', MaxLength = 100;
        DiscountsLbl: Label 'Discounts', MaxLength = 100;
        RoundingLbl: Label 'Rounding', MaxLength = 100;
        OtherOperatingIncomeTotalLbl: Label 'Other operating income total', MaxLength = 100;
        FinancialRevenuesLbl: Label 'Financial revenues', MaxLength = 100;
        InterestReceivedLbl: Label 'Interest received', MaxLength = 100;
        ExchangeGainsRealizedLbl: Label 'Exchange gains - realized', MaxLength = 100;
        ExchangeGainsUnrealizedLbl: Label 'Exchange gains - unrealized', MaxLength = 100;
        RevenuesTotalLbl: Label 'REVENUES TOTAL', MaxLength = 100;
        SubBalanceSheetAccountsLbl: Label 'Sub-balance sheet accounts', MaxLength = 100;
        RentOfFixedAssetsLbl: Label 'Rent of fixed assets', MaxLength = 100;
        ComputersLbl: Label 'Computers', MaxLength = 100;
        RentOfFixedAssetsTotalLbl: Label 'Rent of fixed assets total', MaxLength = 100;
        BalancingAccountLbl: Label 'Balancing Account', MaxLength = 100;
        SubBalanceSheetAccountsTotalLbl: Label 'Sub-balance sheet accounts total', MaxLength = 100;
        IncomefromemploymentcompanionsLbl: Label 'Income from employment companions', MaxLength = 100;
        RemunerationtomembersofcompanymanagementLbl: Label 'Remuneration to members of company management', MaxLength = 100;
        OtherSocialInsuranceLbl: Label 'Other social insurance', MaxLength = 100;
        IndividualsocialcostforbusinessmanLbl: Label 'Individual social cost for businessman', MaxLength = 100;
        StatutorysocialcostLbl: Label 'Statutory social cost', MaxLength = 100;
        OthersocialcostsLbl: Label 'Other social costs', MaxLength = 100;
        OthernontaxsocialcostsLbl: Label 'Other non-tax social costs', MaxLength = 100;
        OthertaxesandfeesBeginLbl: Label 'Other taxes and fees begin', MaxLength = 100;
        OthertaxesandfeesLbl: Label 'Other taxes and fees', MaxLength = 100;
        RoadtaxLbl: Label 'Road tax', MaxLength = 100;
        PropertytaxLbl: Label 'Property tax', MaxLength = 100;
        OthernotaxtaxesandfeesLbl: Label 'Other non-tax taxes and fees', MaxLength = 100;
        OthertaxesandfeestotalLbl: Label 'Other taxes and fees total', MaxLength = 100;
        CostofmaterialsoldInterimLbl: Label 'Cost of material sold (Interim)', MaxLength = 100;
        CostofmaterialsoldLbl: Label 'Cost of material sold', MaxLength = 100;
        PresentsLbl: Label 'Presents', MaxLength = 100;
        OtherpenaltiesandinterestsLbl: Label 'Other penalties and interests', MaxLength = 100;
        ReceivablewriteoffLbl: Label 'Receivable write-off', MaxLength = 100;
        OtheroperatingexpensesBeginLbl: Label 'Other operating expenses begin', MaxLength = 100;
        OtheroperatingexpensesLbl: Label 'Other operating expenses', MaxLength = 100;
        ShortagesanddamagefromoperactLbl: Label 'Shortages and damage from oper. act.', MaxLength = 100;
        DepreciationandreservesLbl: Label 'Depreciation and reserves', MaxLength = 100;
        CreatandsettlofreservesaccordtospecregulLbl: Label 'Creat. and settl. of reserves accord. to spec. regul.', MaxLength = 100;
        CreationandsettlementofothersreservesLbl: Label 'Creation and settlement of others reserves', MaxLength = 100;
        CreationandsettlementlegaladjustmentsLbl: Label 'Creation and settlement legal adjustments', MaxLength = 100;
        CreationandsettlementadjustmentstooperactivitiesLbl: Label 'Creation and settlement adjustments to oper. activities', MaxLength = 100;
        DepreciationandreservestotalLbl: Label 'Depreciation and reserves total', MaxLength = 100;
        FinancialexpensesLbl: Label 'Financial expenses', MaxLength = 100;
        ExpensesrelatedtofinancialassetsLbl: Label 'Expenses related to financial assets', MaxLength = 100;
        OtherfinancialrevenuesLbl: Label 'Other financial revenues', MaxLength = 100;
        OtherfinancialexpensesLbl: Label 'Other financial expenses', MaxLength = 100;
        FinancialexpensestotalLbl: Label 'Financial expenses total', MaxLength = 100;
        ReservesandadjfromfinactivitiesLbl: Label 'Reserves and adj. from fin. activities', MaxLength = 100;
        CreationandsettlementoffinancialreservesLbl: Label 'Creation and settlement of financial reserves', MaxLength = 100;
        CreationandsettlementadjustmentsLbl: Label 'Creation and settlement adjustments', MaxLength = 100;
        ReservesandadjfromfinactivitiestotalLbl: Label 'Reserves and adj. from fin. activities total', MaxLength = 100;
        ChangeininventoryofownproductionandactivationLbl: Label 'Change in inventory of own production and activation', MaxLength = 100;
        ChangeininventoryofownproductionandactivationtotalLbl: Label 'Change in inventory of own production and activation total', MaxLength = 100;
        ChangeinWIPLbl: Label 'Change in WIP', MaxLength = 100;
        VarianceofoverheadcostLbl: Label 'Variance of overhead cost', MaxLength = 100;
        ChangeinsemifinishedproductsLbl: Label 'Change in semi-finished products', MaxLength = 100;
        ChangeinfinishedproductsLbl: Label 'Change in finished products', MaxLength = 100;
        ChangeofanimalsLbl: Label 'Change of animals', MaxLength = 100;
        ActivationofgoodsandmaterialLbl: Label 'Activation of goods and material', MaxLength = 100;
        ActivationofinternalservicesLbl: Label 'Activation of internal services', MaxLength = 100;
        ActivationofintangiblefixedassetsLbl: Label 'Activation of intangible fixed assets', MaxLength = 100;
        ActivationoftangiblefixedassetsLbl: Label 'Activation of tangible fixed assets', MaxLength = 100;
        IncometaxonordinaryactivitiespayableLbl: Label 'Income tax on ordinary activities - payable', MaxLength = 100;
        IncometaxonordinaryactivitiesdeferredLbl: Label 'Income tax on ordinary activities - deferred', MaxLength = 100;
        SalesjobsLbl: Label 'Sales jobs', MaxLength = 100;
        SalesmaterialLbl: Label 'Sales material', MaxLength = 100;
        RevenuesfromlongtermfinancialassetsLbl: Label 'Revenues from long-term financial assets', MaxLength = 100;
        RevenuesfromshorttermfinancialassetsLbl: Label 'Revenues from short-term financial assets', MaxLength = 100;
        FinancialrevenuestotalLbl: Label 'Financial revenues total', MaxLength = 100;
        TransferaccountsLbl: Label 'Transfer accounts', MaxLength = 100;
        TransferofoperatingrevenuesLbl: Label 'Transfer of operating revenues', MaxLength = 100;
        TransferoffinancialrevenuesLbl: Label 'Transfer of financial revenues', MaxLength = 100;
        TransferaccountstotalLbl: Label 'Transfer accounts total', MaxLength = 100;
        OpeningbalancesheetaccountLbl: Label 'Opening balance sheet account', MaxLength = 100;
        ClosingbalancesheetaccountLbl: Label 'Closing balance sheet account', MaxLength = 100;
        ProfitandlossaccountLbl: Label 'Profit and loss account', MaxLength = 100;
        PrepaidexpensesLbl: Label 'Prepaid expenses', MaxLength = 100;
        ComplexprepaidexpensesLbl: Label 'Complex prepaid expenses', MaxLength = 100;
        AccruedexpensesLbl: label 'Accrued expenses', MaxLength = 100;
        DeferredrevenuesLbl: Label 'Deferred revenues', MaxLength = 100;
        AccruedincomesLbl: Label 'Accrued incomes', MaxLength = 100;
        IntangibleresultsofresearchanddevelopmentLbl: Label 'Intangible results of research and development', MaxLength = 100;
        ValuablerightsLbl: Label 'Valuable rights', MaxLength = 100;
        GoodwillLbl: Label 'Goodwill', MaxLength = 100;
        IntangiblefixedassetsLbl: Label 'Intangible fixed assets', MaxLength = 100;
        IntangiblefixedassetstotalLbl: Label 'Intangible fixed assets total', MaxLength = 100;
        OtherintangiblefixedassetsLbl: Label 'Other intangible fixed assets', MaxLength = 100;
        TangiblefixedassetsnondeductibleLbl: Label 'Tangible fixed assets non-deductible', MaxLength = 100;
        LandsLbl: Label 'Lands', MaxLength = 100;
        TangiblefixedassetsnondeductibletotalLbl: Label 'Tangible fixed assets non-deductible total', MaxLength = 100;
        AccumulateddepreciationtointangiblefixedassetsLbl: Label 'Accumulated depreciation to intangible fixed assets', MaxLength = 100;
        AccumulateddepreciationtointangibleresultsofresearchanddevelopmentLbl: Label 'Accumulated depreciation to intangible results of research and development', MaxLength = 100;
        AccumulateddepreciationtosoftwareLbl: Label 'Accumulated depreciation to software', MaxLength = 100;
        AccumulateddepreciationtovaluablerightsLbl: Label 'Accumulated depreciation to valuable rights', MaxLength = 100;
        AccumulateddepreciationtogoodwillLbl: Label 'Accumulated depreciation to goodwill', MaxLength = 100;
        AccumulateddepreciationtootherintangiblefixedassetsLbl: Label 'Accumulated depreciation to other intangible fixed assets', MaxLength = 100;
        AccumulateddepreciationtointangiblefixedassetstotalLbl: Label 'Accumulated depreciation to intangible fixed assets total', MaxLength = 100;
        UnidentifiedpaymentsLbl: Label 'Unidentified payments', MaxLength = 100;
        TemporaryaccountsofassetsandliabilitiesLbl: Label 'Temporary accounts of assets and liabilities', MaxLength = 100;
        TemporaryaccountsofassetsandliabilitiestotalLbl: Label 'Temporary accounts of assets and liabilities total', MaxLength = 100;
        IncometaxprovisionsLbl: Label 'Income tax provisions', MaxLength = 100;
        OtherprovisionsLbl: Label 'Other provisions', MaxLength = 100;
        OtherlongtermpayablesLbl: Label 'Other long-term payables', MaxLength = 100;
        DepreciationofpatentsLbl: Label 'Depreciation of patents', MaxLength = 100;
        DepreciationofsoftwareLbl: Label 'Depreciation of software', MaxLength = 100;
        DepreciationofgoodwillLbl: Label 'Depreciation of goodwill', MaxLength = 100;
        DepreciationofotherintangiblefixedassetsLbl: Label 'Depreciation of other intangible fixed assets', MaxLength = 100;
        PostponedVATPurchaseLbl: Label 'Postponed VAT - Purchase', MaxLength = 100;
        DirectCostAppliedRetailLbl: Label 'Direct Cost Applied, Retail', MaxLength = 100;
        OverheadAppliedRetailLbl: Label 'Overhead Applied, Retail', MaxLength = 100;
        PurchaseVarianceRetailLbl: Label 'Purchase Variance, Retail', MaxLength = 100;
        PurchaseVarianceRawmatLbl: Label 'Purchase Variance, Rawmat.', MaxLength = 100;
        OverheadAppliedCapLbl: Label 'Overhead Applied, Cap.', MaxLength = 100;
        PurchaseVarianceCapLbl: Label 'Purchase Variance, Cap.', MaxLength = 100;
        CapacityVarianceLbl: Label 'Capacity Variance', MaxLength = 100;
        SubcontractedVarianceLbl: Label 'Subcontracted Variance', MaxLength = 100;
        InventoryOfOwnProductionLbl: Label 'Inventory of own production', MaxLength = 100;
        InventoryOfOwnProductionTotalLbl: Label 'Inventory of own production total', MaxLength = 100;
        GoodsLbl: Label 'Goods', MaxLength = 100;
        GoodsTotalLbl: Label 'Goods total', MaxLength = 100;
        CurrentFinancialAssetsLbl: Label 'Current financial assets', MaxLength = 100;
        CurrentFinancialAssetsTotalLbl: Label 'Current financial assets total', MaxLength = 100;
        NettingRelationshipsLbl: Label 'Netting relationships', MaxLength = 100;
        NettingRelationshipsTotalLbl: Label 'Netting relationships total', MaxLength = 100;
        CustomersIntercompanyLbl: Label 'Customers, Intercompany', MaxLength = 100;
        VendorsIntercompanyLbl: Label 'Vendors, Intercompany', MaxLength = 100;
        PrepaidHardwareContractsLbl: Label 'Prepaid Hardware Contracts', MaxLength = 100;
        PrepaidSoftwareContractsLbl: Label 'Prepaid Software Contracts', MaxLength = 100;
        ServiceContractSaleLbl: Label 'Service Contract Sale', MaxLength = 100;
}
