codeunit 11345 "Loc. Manufacturing Demodata-BE"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyManufacturingDemoAccounts()
    begin
        ManufacturingDemoAccount.ReturnAccountKey(true);

        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.WIPAccountFinishedgoods(), '330100');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MaterialVariance(), '609890');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapacityVariance(), '609891');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MfgOverheadVariance(), '609894');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapOverheadVariance(), '609893');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.SubcontractedVariance(), '609892');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.FinishedGoods(), '330000');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.RawMaterials(), '300000');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedCap(), '609791');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRawMat(), '609291');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRetail(), '609191');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRawMat(), '609270');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRetail(), '609170');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedCap(), '609792');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRawMat(), '609292');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRetail(), '609192');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchRawMatDom(), '600000');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceCap(), '609793');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRawMat(), '609293');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRetail(), '609193');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Whse Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyWhseDemoAccounts()
    begin
        WhseDemoAccount.ReturnAccountKey(true);

        WhseDemoAccounts.AddAccount(WhseDemoAccount.CustDomestic(), '400000');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.Resale(), '340000');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.ResaleInterim(), '340010');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.VendDomestic(), '440000');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.SalesDomestic(), '702000');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchDomestic(), '604000');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.SalesVAT(), '451000');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchaseVAT(), '411000');
    end;

    var
        ManufacturingDemoAccount: Record "Manufacturing Demo Account";
        WhseDemoAccount: Record "Whse. Demo Account";
        ManufacturingDemoAccounts: Codeunit "Manufacturing Demo Accounts";
        WhseDemoAccounts: Codeunit "Whse. Demo Accounts";
}