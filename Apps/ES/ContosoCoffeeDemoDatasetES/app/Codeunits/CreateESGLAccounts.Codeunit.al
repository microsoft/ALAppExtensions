codeunit 10780 "Create ES GL Accounts"
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

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.CustomerDomesticName(), '4300001');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.VendorDomesticName(), '4000001');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesDomesticName(), '7050011');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '6000001');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '4770001');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '4720001');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '3300130');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '3300100');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '3300140');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '3300110');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '3300150');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '3300120');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.RawMaterialsName(), '3000002');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchRawMatDomName(), '6010001');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRawMatName(), '6110001');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRetailName(), '6100001');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResalesName(), '3000001');
        if InventorySetup."Expected Cost Posting to G/L" then
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '3000004')
        else
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyServiceGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '7051001');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyManufacturingGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        MfgGLAccount: Codeunit "Create Mfg GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '3300180');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '3300190');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '3300200');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '3300230');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '3300240');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '3300240');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '3300260');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '3300250');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '3100001');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '3300280');
    end;
}