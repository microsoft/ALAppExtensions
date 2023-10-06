codeunit 4768 "Create Mfg Posting Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Manufacturing Setup" = ri;

    trigger OnRun()
    begin
        CreateInventoryPostingSetup();
        CreateGeneralPostingSetup();

        CreateManufacturingSetup();
    end;

    local procedure CreateInventoryPostingSetup()
    var
        ManufacturingDemoDataSetup: Record "Manufacturing Module Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CommonGLAccount: Codeunit "Create Common GL Account";
        MfgGLAccount: Codeunit "Create Mfg GL Account";
        CommonPostingGroup: Codeunit "Create Common Posting Group";
        MfgPostingGroup: Codeunit "Create Mfg Posting Group";
    begin
        ManufacturingDemoDataSetup.Get();

        ContosoPostingSetup.InsertInventoryPostingSetup('', MfgPostingGroup.Finished(), MfgGLAccount.FinishedGoods(), '', MfgGLAccount.WIPAccountFinishedGoods(), MfgGLAccount.MaterialVariance(), MfgGLAccount.CapacityVariance(), MfgGLAccount.SubcontractedVariance(), MfgGLAccount.CapOverheadVariance(), MfgGLAccount.MfgOverheadVariance());
        ContosoPostingSetup.InsertInventoryPostingSetup(ManufacturingDemoDataSetup."Manufacturing Location", MfgPostingGroup.Finished(), MfgGLAccount.FinishedGoods(), '', MfgGLAccount.WIPAccountFinishedGoods(), MfgGLAccount.MaterialVariance(), MfgGLAccount.CapacityVariance(), MfgGLAccount.SubcontractedVariance(), MfgGLAccount.CapOverheadVariance(), MfgGLAccount.MfgOverheadVariance());
        ContosoPostingSetup.InsertInventoryPostingSetup('', CommonPostingGroup.RawMaterial(), CommonGLAccount.RawMaterials(), '', MfgGLAccount.WIPAccountFinishedGoods(), '', '', '', '', '');
        ContosoPostingSetup.InsertInventoryPostingSetup(ManufacturingDemoDataSetup."Manufacturing Location", CommonPostingGroup.RawMaterial(), CommonGLAccount.RawMaterials(), '', MfgGLAccount.WIPAccountFinishedGoods(), '', '', '', '', '');
    end;

    local procedure CreateGeneralPostingSetup()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CommonPostingGroup: Codeunit "Create Common Posting Group";
        CommonGLAccount: Codeunit "Create Common GL Account";
        MfgGLAccount: Codeunit "Create Mfg GL Account";
        MfgPostingGroup: Codeunit "Create Mfg Posting Group";
    begin
        ContosoPostingSetup.InsertGeneralPostingSetup('', MfgPostingGroup.Manufacturing(), CommonGLAccount.SalesDomestic(), CommonGLAccount.PurchaseDomestic(), '', MfgGLAccount.DirectCostAppliedCap(), MfgGLAccount.OverheadAppliedCap(), MfgGLAccount.PurchaseVarianceCap());
        ContosoPostingSetup.InsertGeneralPostingSetup(CommonPostingGroup.Domestic(), MfgPostingGroup.Manufacturing(), CommonGLAccount.SalesDomestic(), CommonGLAccount.PurchaseDomestic(), CommonGLAccount.InventoryAdjRawMat(), CommonGLAccount.DirectCostAppliedRawMat(), CommonGLAccount.OverheadAppliedRawMat(), CommonGLAccount.PurchaseVarianceRawMat());
    end;

    local procedure CreateManufacturingSetup()
    var
        ManufacturingSetup: Record "Manufacturing Setup";
        MfgNoSeries: Codeunit "Create Mfg No Series";
        MfgCapUnitOfMeasure: Codeunit "Create Mfg Cap Unit Of Measure";
    begin
        if not ManufacturingSetup.Get() then
            ManufacturingSetup.Insert();

        ManufacturingSetup.Validate("Normal Starting Time", 080000T);
        ManufacturingSetup.Validate("Normal Ending Time", 230000T);
        ManufacturingSetup.Validate("Doc. No. Is Prod. Order No.", true);

        ManufacturingSetup.Validate("Cost Incl. Setup", true);
        ManufacturingSetup.Validate("Planning Warning", true);
        ManufacturingSetup.Validate("Dynamic Low-Level Code", true);

        ManufacturingSetup.Validate("Show Capacity In", MfgCapUnitOfMeasure.Minutes());

        ManufacturingSetup.Validate("Combined MPS/MRP Calculation", true);
        Evaluate(ManufacturingSetup."Default Safety Lead Time", '<1D>');

        if ManufacturingSetup."Work Center Nos." = '' then
            ManufacturingSetup.Validate("Work Center Nos.", MfgNoSeries.WorkCenter());
        if ManufacturingSetup."Machine Center Nos." = '' then
            ManufacturingSetup.Validate("Machine Center Nos.", MfgNoSeries.MachineCenter());
        if ManufacturingSetup."Production BOM Nos." = '' then
            ManufacturingSetup.Validate("Production BOM Nos.", MfgNoSeries.ProductionBOM());
        if ManufacturingSetup."Routing Nos." = '' then
            ManufacturingSetup.Validate("Routing Nos.", MfgNoSeries.Routing());

        if ManufacturingSetup."Simulated Order Nos." = '' then
            ManufacturingSetup.Validate("Simulated Order Nos.", MfgNoSeries.SimulatedOrder());
        if ManufacturingSetup."Planned Order Nos." = '' then
            ManufacturingSetup.Validate("Planned Order Nos.", MfgNoSeries.PlannedOrder());
        if ManufacturingSetup."Firm Planned Order Nos." = '' then
            ManufacturingSetup.Validate("Firm Planned Order Nos.", MfgNoSeries.FirmPlannedOrder());
        if ManufacturingSetup."Released Order Nos." = '' then
            ManufacturingSetup.Validate("Released Order Nos.", MfgNoSeries.ReleasedOrderCode());

        ManufacturingSetup.Modify();
    end;
}