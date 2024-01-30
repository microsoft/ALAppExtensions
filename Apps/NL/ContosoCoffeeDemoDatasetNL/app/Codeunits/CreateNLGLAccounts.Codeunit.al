codeunit 11499 "Create NL GL Accounts"
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

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.CustomerDomesticName(), '0610');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.VendorDomesticName(), '1210');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesDomesticName(), '6130');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '0505');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '1340');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '0760');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '0501');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '0505');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '0501');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '0505');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '3285');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '3085');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.RawMaterialsName(), '0501');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchRawMatDomName(), '3230');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRawMatName(), '5110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRetailName(), '5110');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResalesName(), '0505');
        if InventorySetup."Expected Cost Posting to G/L" then
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '7101')
        else
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyServiceGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '6430');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyManufacturingGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        MfgGLAccount: Codeunit "Create Mfg GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '3420');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '3430');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '5311');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '5312');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '5313');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '5314');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '5315');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '5316');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '0504');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '0555');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create FA GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyFixedAssetGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        FAGLAccount: Codeunit "Create FA GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.IncreasesDuringTheYearName(), '0206');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DecreasesDuringTheYearName(), '0208');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.AccumDepreciationBuildingsName(), '0204');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.MiscellaneousName(), '4290');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DepreciationEquipmentName(), '4850');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.GainsAndLossesName(), '8840');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create HR GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyHumanResourcesGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        HRGLAccount: Codeunit "Create HR GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(HRGLAccount.EmployeesPayableName(), '1520');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Job GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyJobGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        JobGLAccount: Codeunit "Create Job GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPInvoicedSalesName(), '0551');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPJobCostsName(), '0552');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobSalesAppliedName(), '6420');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedSalesName(), '6410');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobCostsAppliedName(), '5520');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedCostsName(), '5510');
    end;
}