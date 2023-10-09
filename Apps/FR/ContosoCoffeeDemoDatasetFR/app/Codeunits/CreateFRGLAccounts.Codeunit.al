codeunit 10850 "Create FR GL Accounts"
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

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.CustomerDomesticName(), '411100');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.VendorDomesticName(), '401100');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesDomesticName(), '706100');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '607100');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '445711');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '445661');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '904100');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '603710');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '905100');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '603711');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '961000');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '603712');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.RawMaterialsName(), '350000');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchRawMatDomName(), '601100');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRawMatName(), '961000');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRetailName(), '603712');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResalesName(), '370000');
        if InventorySetup."Expected Cost Posting to G/L" then
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '378000')
        else
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyServiceGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '758800');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyManufacturingGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        MfgGLAccount: Codeunit "Create Mfg GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '904300');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '905300');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '961300');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '963100');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '963200');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '963300');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '963400');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '963500');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '310000');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '331000');
    end;
}