codeunit 5109 "Create Common Posting Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CommonPostingGroup: Codeunit "Create Common Posting Group";
        CommonGLAccount: Codeunit "Create Common GL Account";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        ContosoPostingSetup.InsertGeneralPostingSetup('', CommonPostingGroup.Retail(), CommonGLAccount.SalesDomestic(), CommonGLAccount.PurchaseDomestic(), CommonGLAccount.InventoryAdjRetail(), CommonGLAccount.DirectCostAppliedRetail(), CommonGLAccount.OverheadAppliedRetail(), '');
        ContosoPostingSetup.InsertGeneralPostingSetup('', CommonPostingGroup.RawMaterial(), CommonGLAccount.SalesDomestic(), CommonGLAccount.PurchaseDomestic(), CommonGLAccount.InventoryAdjRawMat(), CommonGLAccount.DirectCostAppliedRawMat(), CommonGLAccount.OverheadAppliedRawMat(), '');

        ContosoPostingSetup.InsertGeneralPostingSetup(CommonPostingGroup.Domestic(), CommonPostingGroup.Retail(), CommonGLAccount.SalesDomestic(), CommonGLAccount.PurchaseDomestic(), CommonGLAccount.InventoryAdjRetail(), CommonGLAccount.DirectCostAppliedRetail(), CommonGLAccount.OverheadAppliedRetail(), '');
        ContosoPostingSetup.InsertGeneralPostingSetup(CommonPostingGroup.Domestic(), CommonPostingGroup.RawMaterial(), CommonGLAccount.SalesDomestic(), CommonGLAccount.PurchaseDomestic(), CommonGLAccount.InventoryAdjRawMat(), CommonGLAccount.DirectCostAppliedRawMat(), CommonGLAccount.OverheadAppliedRawMat(), CommonGLAccount.PurchaseVarianceRawMat());

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::VAT then
            ContosoPostingSetup.InsertVATPostingSetup(CommonPostingGroup.Domestic(), CommonPostingGroup.StandardVAT(), CommonGLAccount.SalesVATStandard(), CommonGLAccount.PurchaseVATStandard(), CommonPostingGroup.StandardVAT(), 25, Enum::"Tax Calculation Type"::"Normal VAT")
        else // Sales Tax Company requires a "Empty" Tax Posting Setup for posting process
            ContosoPostingSetup.InsertVATPostingSetup('', '', '', '', '', 0, Enum::"Tax Calculation Type"::"Sales Tax");
    end;
}