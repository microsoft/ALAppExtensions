codeunit 11345 "Create BE GL Accounts"
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

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.CustomerDomesticName(), '400000');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.VendorDomesticName(), '440000');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesDomesticName(), '702000');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '604000');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '451000');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '411000');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRawMatName(), '609270');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRetailName(), '609170');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.RawMaterialsName(), '300000');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchRawMatDomName(), '600000');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResalesName(), '340000');
        if InventorySetup."Expected Cost Posting to G/L" then
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '340010')
        else
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

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '330000');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create FA GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyFixedAssetGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        FAGLAccount: Codeunit "Create FA GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.IncreasesDuringTheYearName(), '230000');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DecreasesDuringTheYearName(), '230000');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.AccumDepreciationBuildingsName(), '230009');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.MiscellaneousName(), '643000');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DepreciationEquipmentName(), '630210');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.GainsAndLossesName(), '663000');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create HR GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyHumanResourcesGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        HRGLAccount: Codeunit "Create HR GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(HRGLAccount.EmployeesPayableName(), '457000');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Job GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyJobGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        JobGLAccount: Codeunit "Create Job GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPInvoicedSalesName(), '320000');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPJobCostsName(), '320000');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobSalesAppliedName(), '742000');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedSalesName(), '703000');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobCostsAppliedName(), '609180');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedCostsName(), '602010');
    end;
}