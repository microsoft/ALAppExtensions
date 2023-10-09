codeunit 14099 "Create MX GL Accounts"
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

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.CustomerDomesticName(), '6310');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.VendorDomesticName(), '9410');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesDomesticName(), '1410');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '1410');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '9610');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '9630');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '6120');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '6130');


        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '2110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '2110');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '2410');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '2410');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.RawMaterialsName(), '6130');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchRawMatDomName(), '2110');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRawMatName(), '2170');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRetailName(), '2170');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResalesName(), '6110');
        if InventorySetup."Expected Cost Posting to G/L" then
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '6111')
        else
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyServiceGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '1800');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyManufacturingGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        MfgGLAccount: Codeunit "Create Mfg GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '2500');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '2500');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '2410');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '2420');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '2421');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '2422');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '2423');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '2424');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '6120');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '6150');
    end;
}