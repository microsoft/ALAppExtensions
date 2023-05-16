codeunit 4762 "Create Mfg Demo Accounts"
{
    TableNo = "Manufacturing Demo Account";

    trigger OnRun()
    begin
        Rec.ReturnAccountKey(true);

        ManufacturingDemoAccounts.AddAccount(Rec.FinishedGoods(), '2120', XFinishedGoodsTok);
        ManufacturingDemoAccounts.AddAccount(Rec.RawMaterials(), '2130', XRawMaterialsTxt);
        ManufacturingDemoAccounts.AddAccount(Rec.WIPAccountFinishedgoods(), '2140', XWIPAccountFinishedgoodsTok);
        ManufacturingDemoAccounts.AddAccount(Rec.MaterialVariance(), '7890', XMaterialVarianceTok);
        ManufacturingDemoAccounts.AddAccount(Rec.CapacityVariance(), '7891', XCapacityVarianceTok);
        ManufacturingDemoAccounts.AddAccount(Rec.SubcontractedVariance(), '7892', XSubcontractedVarianceTok);
        ManufacturingDemoAccounts.AddAccount(Rec.CapOverheadVariance(), '7893', XCapOverheadVarianceTok);
        ManufacturingDemoAccounts.AddAccount(Rec.MfgOverheadVariance(), '7894', XMfgOverheadVarianceTok);

        ManufacturingDemoAccounts.AddAccount(Rec.DirectCostAppliedCap(), '7791', XDirectCostAppliedCapTok);
        ManufacturingDemoAccounts.AddAccount(Rec.OverheadAppliedCap(), '7792', XOverheadAppliedCapTok);
        ManufacturingDemoAccounts.AddAccount(Rec.PurchaseVarianceCap(), '7793', XPurchaseVarianceCapTok);

        ManufacturingDemoAccounts.AddAccount(Rec.DirectCostAppliedRetail(), '7191', XDirectCostAppliedRetailTok);
        ManufacturingDemoAccounts.AddAccount(Rec.OverheadAppliedRetail(), '7192', XOverheadAppliedRetailTok);
        ManufacturingDemoAccounts.AddAccount(Rec.PurchaseVarianceRetail(), '7193', XPurchaseVarianceRetailTok);

        ManufacturingDemoAccounts.AddAccount(Rec.DirectCostAppliedRawMat(), '7291', XDirectCostAppliedRawMatTok);
        ManufacturingDemoAccounts.AddAccount(Rec.OverheadAppliedRawMat(), '7292', XOverheadAppliedawMatTok);
        ManufacturingDemoAccounts.AddAccount(Rec.PurchaseVarianceRawMat(), '7293', XPurchaseVarianceRawMatTok);
        ManufacturingDemoAccounts.AddAccount(Rec.PurchRawMatDom(), '7210', XPurchRawMatDomTok);

        ManufacturingDemoAccounts.AddAccount(Rec.InventoryAdjRawMat(), '7270', XInventoryAdjRawMatTok);
        ManufacturingDemoAccounts.AddAccount(Rec.InventoryAdjRetail(), '7170', XInventoryAdjRetailTok);

        OnAfterCreateDemoAccounts();
    end;

    var
        ManufacturingDemoAccounts: Codeunit "Manufacturing Demo Accounts";
        XFinishedGoodsTok: Label 'Finished Goods', MaxLength = 50;
        XRawMaterialsTxt: Label 'Raw Materials', MaxLength = 50;
        XWIPAccountFinishedgoodsTok: Label 'WIP Account, Finished goods', MaxLength = 50;
        XDirectCostAppliedCapTok: Label 'Direct Cost Applied, Cap.', MaxLength = 50;
        XOverheadAppliedCapTok: Label 'Overhead Applied, Cap.', MaxLength = 50;
        XPurchaseVarianceCapTok: Label 'Purchase Variance, Cap.', MaxLength = 50;
        XMaterialVarianceTok: Label 'Material Variance', MaxLength = 50;
        XCapacityVarianceTok: Label 'Capacity Variance', MaxLength = 50;
        XSubcontractedVarianceTok: Label 'Subcontracted Variance', MaxLength = 50;
        XCapOverheadVarianceTok: Label 'Cap. Overhead Variance', MaxLength = 50;
        XMfgOverheadVarianceTok: Label 'Mfg. Overhead Variance', MaxLength = 50;
        XOverheadAppliedRetailTok: Label 'Overhead Applied, Retail', MaxLength = 50;
        XPurchaseVarianceRetailTok: Label 'Purchase Variance, Retail', MaxLength = 50;
        XDirectCostAppliedRawMatTok: Label 'Direct Cost Applied, Rawmat.', MaxLength = 50;
        XDirectCostAppliedRetailTok: Label 'Direct Cost Applied, Retail.', MaxLength = 50;
        XOverheadAppliedawMatTok: Label 'Overhead Applied, Rawmat.', MaxLength = 50;
        XPurchaseVarianceRawMatTok: Label 'Overhead Applied, Rawmat.', MaxLength = 50;
        XPurchRawMatDomTok: Label 'Purch., Raw Materials - Dom.', MaxLength = 50;
        XInventoryAdjRawMatTok: Label 'Inventory Adjmt., Raw Mat.', MaxLength = 50;
        XInventoryAdjRetailTok: Label 'Inventory Adjmt., Retail', MaxLength = 50;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDemoAccounts()
    begin
    end;
}