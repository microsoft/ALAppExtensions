codeunit 27009 "Loc. Manufacturing Demodata-CA"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyManufacturingDemoAccounts()
    begin
        ManufacturingDemoAccount.ReturnAccountKey(true);

        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.WIPAccountFinishedgoods(), '14600');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MaterialVariance(), '57100');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapacityVariance(), '57200');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MfgOverheadVariance(), '57400');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapOverheadVariance(), '57300');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.SubcontractedVariance(), '57210');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.FinishedGoods(), '14200');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.RawMaterials(), '14300');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedCap(), '52450');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRawMat(), '53700');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRetail(), '54710');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRawMat(), '53400');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRetail(), '54500');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedCap(), '52460');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRawMat(), '53800');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRetail(), '54702');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchRawMatDom(), '53100');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceCap(), '52475');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRawMat(), '53850');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRetail(), '54703');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Whse Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyWhseDemoAccounts()
    begin
        WhseDemoAccount.ReturnAccountKey(true);

        WhseDemoAccounts.AddAccount(WhseDemoAccount.CustDomestic(), '13100');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.Resale(), '14100');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.ResaleInterim(), '14101');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.VendDomestic(), '22300');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.SalesDomestic(), '44100');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchDomestic(), '54100');
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