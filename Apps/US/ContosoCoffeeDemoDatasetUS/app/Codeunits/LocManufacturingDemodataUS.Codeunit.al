codeunit 10499 "Loc. Manufacturing Demodata-US"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyManufacturingDemoAccounts()
    begin
        ManufacturingDemoAccount.ReturnAccountKey(true);

        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapOverheadVariance(), '50423');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapacityVariance(), '50421');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedCap(), '50200');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRawMat(), '10700');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRetail(), '10700');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.FinishedGoods(), '10700');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.RawMaterials(), '10700');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRawMat(), '50100');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRetail(), '50100');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MaterialVariance(), '50420');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MfgOverheadVariance(), '50424');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedCap(), '50200');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRawMat(), '10700');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRetail(), '10700');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchRawMatDom(), '10700');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceCap(), '50410');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRawMat(), '50410');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRetail(), '50410');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.SubcontractedVariance(), '50422');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.WIPAccountFinishedgoods(), '10750');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Whse Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyWhseDemoAccounts()
    begin
        WhseDemoAccount.ReturnAccountKey(true);

        WhseDemoAccounts.AddAccount(WhseDemoAccount.CustDomestic(), '10400');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.Resale(), '10700');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.ResaleInterim(), '');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.VendDomestic(), '20100');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.SalesDomestic(), '40200');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchDomestic(), '10700');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.SalesVAT(), '');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchaseVAT(), '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Manufacturing Demo Data Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure ModifySeriesCode(var Rec: Record "Manufacturing Demo Data Setup")
    begin
        Rec."Company Type" := Rec."Company Type"::"Sales Tax";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Whse Demo Data Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure ModifyWhseTaxSetting(var Rec: Record "Whse Demo Data Setup")
    begin
        Rec."Company Type" := Rec."Company Type"::"Sales Tax";
    end;

    var
        ManufacturingDemoAccount: Record "Manufacturing Demo Account";
        WhseDemoAccount: Record "Whse. Demo Account";
        ManufacturingDemoAccounts: Codeunit "Manufacturing Demo Accounts";
        WhseDemoAccounts: Codeunit "Whse. Demo Accounts";
}