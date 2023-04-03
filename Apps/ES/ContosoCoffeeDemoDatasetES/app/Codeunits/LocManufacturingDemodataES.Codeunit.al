codeunit 10780 "Loc. Manufacturing Demodata-ES"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyManufacturingDemoAccounts()
    begin
        ManufacturingDemoAccount.ReturnAccountKey(true);

        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.WIPAccountFinishedgoods(), '3300280');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MaterialVariance(), '3300230');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapacityVariance(), '3300240');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MfgOverheadVariance(), '3300250');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapOverheadVariance(), '3300260');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.SubcontractedVariance(), '3300240');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.FinishedGoods(), '3100001');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.RawMaterials(), '3000002');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedCap(), '3300180');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRawMat(), '3300130');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRetail(), '3300100');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRawMat(), '6110001');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRetail(), '6100001');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedCap(), '3300190');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRawMat(), '3300140');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRetail(), '3300110');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchRawMatDom(), '6010001');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceCap(), '3300200');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRawMat(), '3300150');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRetail(), '3300120');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Manufacturing Demo Data Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure ModifySeriesCode(var Rec: Record "Manufacturing Demo Data Setup")
    begin
        Rec."Base VAT Code" := 'NO IVA';
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Whse Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyWhseDemoAccounts()
    begin
        WhseDemoAccount.ReturnAccountKey(true);

        WhseDemoAccounts.AddAccount(WhseDemoAccount.CustDomestic(), '4300001');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.Resale(), '3000001');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.ResaleInterim(), '3000004');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.VendDomestic(), '4000001');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.SalesDomestic(), '7050011');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchDomestic(), '6000001');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.SalesVAT(), '4770001');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchaseVAT(), '4720001');
    end;

    var
        ManufacturingDemoAccount: Record "Manufacturing Demo Account";
        WhseDemoAccount: Record "Whse. Demo Account";
        ManufacturingDemoAccounts: Codeunit "Manufacturing Demo Accounts";
        WhseDemoAccounts: Codeunit "Whse. Demo Accounts";
}