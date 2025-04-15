// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Common;
using Microsoft.DemoData.Service;
using Microsoft.DemoData.Manufacturing;
using Microsoft.DemoData.FixedAsset;
using Microsoft.DemoData.HumanResources;
using Microsoft.DemoData.Jobs;
using Microsoft.Finance.GeneralLedger.Account;

codeunit 31212 "Create CZ GL Accounts"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentPermissions = X;
    InherentEntitlements = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Common GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyCommonGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        CommonGLAccount: Codeunit "Create Common GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.CustomerDomesticName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.VendorDomesticName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesDomesticName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRetailName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.RawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchRawMatDomName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyServiceGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyManufacturingGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        MfgGLAccount: Codeunit "Create Mfg GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '');
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create FA GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyFixedAssetGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        FAGLAccount: Codeunit "Create FA GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.IncreasesDuringTheYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DecreasesDuringTheYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.AccumDepreciationBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.MiscellaneousName(), '');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DepreciationEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.GainsAndLossesName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create HR GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyHumanResourcesGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        HRGLAccount: Codeunit "Create HR GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(HRGLAccount.EmployeesPayableName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Job GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyJobGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        JobGLAccount: Codeunit "Create Job GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPInvoicedSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPJobCostsName(), '');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobSalesAppliedName(), '');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedSalesName(), '');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobCostsAppliedName(), '');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedCostsName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso GL Account", 'OnBeforeValidateGLAccountCategory', '', false, false)]
    local procedure SkipAccountCategoryValidation(var GLAccount: Record "G/L Account"; var Category: Enum "G/L Account Category"; var SubCategory: Text[80])
    begin
        Category := Enum::"G/L Account Category"::" ";
    end;
}
