codeunit 11080 "Loc. Manufacturing Demodata-DE"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyManufacturingDemoAccounts()
    begin
        ManufacturingDemoAccount.ReturnAccountKey(true);

        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.WIPAccountFinishedgoods(), '7050');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MaterialVariance(), '5090');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapacityVariance(), '5091');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MfgOverheadVariance(), '5094');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapOverheadVariance(), '5093');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.SubcontractedVariance(), '5092');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.FinishedGoods(), '3982');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.RawMaterials(), '3983');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedCap(), '4091');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRawMat(), '4091');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRetail(), '4091');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRawMat(), '3960');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRetail(), '3960');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedCap(), '4092');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRawMat(), '4092');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRetail(), '4092');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchRawMatDom(), '3400');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceCap(), '4093');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRawMat(), '4093');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRetail(), '4093');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Whse Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyWhseDemoAccounts()
    begin
        WhseDemoAccount.ReturnAccountKey(true);

        WhseDemoAccounts.AddAccount(WhseDemoAccount.CustDomestic(), '8650');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.Resale(), '3981');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.ResaleInterim(), '3984');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.VendDomestic(), '3800');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.SalesDomestic(), '8400');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchDomestic(), '3400');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.SalesVAT(), '1775');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchaseVAT(), '1575');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Whse Demo Data Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure ModifyWhseTaxSetting(var Rec: Record "Whse Demo Data Setup")
    begin
        Rec."VAT Prod. Posting Group Code" := 'MWST.19';
    end;

    var
        ManufacturingDemoAccount: Record "Manufacturing Demo Account";
        WhseDemoAccount: Record "Whse. Demo Account";
        ManufacturingDemoAccounts: Codeunit "Manufacturing Demo Accounts";
        WhseDemoAccounts: Codeunit "Whse. Demo Accounts";
}