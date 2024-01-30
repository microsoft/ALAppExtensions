codeunit 10499 "Create US GL Accounts"
{
    InherentPermissions = X;
    InherentEntitlements = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Common GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyCommonGLAccounts()
    var
        InventorySetup: Record "Inventory Setup";
        ContosoGLAccount: Codeunit "Contoso GL Account";
        CommonGLAccount: Codeunit "Create Common GL Account";
    begin
        InventorySetup.Get();

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.CustomerDomesticName(), '15110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.VendorDomesticName(), '22100');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesDomesticName(), '40140');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '14140');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '14110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '14140');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '14110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '14140');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '14110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '50410');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.RawMaterialsName(), '14110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchRawMatDomName(), '14110');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRawMatName(), '50110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRetailName(), '50110');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResalesName(), '14140');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyServiceGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '40430');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyManufacturingGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        MfgGLAccount: Codeunit "Create Mfg GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '50210');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '50210');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '50410');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '50420');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '50421');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '50422');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '50423');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '50424');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '14130');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '14210');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create FA GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyFixedAssetGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        FAGLAccount: Codeunit "Create FA GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.IncreasesDuringTheYearName(), '12210');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DecreasesDuringTheYearName(), '17120');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.AccumDepreciationBuildingsName(), '17200');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.MiscellaneousName(), '67400');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DepreciationEquipmentName(), '66200');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.GainsAndLossesName(), '81200');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create HR GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyHumanResourcesGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        HRGLAccount: Codeunit "Create HR GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(HRGLAccount.EmployeesPayableName(), '23850');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Job GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyJobGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        JobGLAccount: Codeunit "Create Job GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPInvoicedSalesName(), '14250');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPJobCostsName(), '14230');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobSalesAppliedName(), '40420');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedSalesName(), '40410');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobCostsAppliedName(), '50320');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedCostsName(), '50310');
    end;
}