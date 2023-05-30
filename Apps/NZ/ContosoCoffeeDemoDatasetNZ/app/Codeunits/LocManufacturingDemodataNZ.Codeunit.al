codeunit 17105 "Loc. Manufacturing Demodata-NZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyManufacturingDemoAccounts()
    begin
        ManufacturingDemoAccount.ReturnAccountKey(true);

        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.WIPAccountFinishedgoods(), '2140');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MaterialVariance(), '7890');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapacityVariance(), '7891');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MfgOverheadVariance(), '7894');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapOverheadVariance(), '7893');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.SubcontractedVariance(), '7892');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.FinishedGoods(), '2120');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.RawMaterials(), '2130');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedCap(), '7791');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRawMat(), '7291');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRetail(), '7191');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRawMat(), '7270');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRetail(), '7170');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedCap(), '7792');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRawMat(), '7292');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRetail(), '7192');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchRawMatDom(), '7210');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceCap(), '7793');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceCap(), '7793');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRawMat(), '7293');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRawMat(), '7293');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRetail(), '7193');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Manufacturing Demo Data Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure ModifySeriesCode(var Rec: Record "Manufacturing Demo Data Setup")
    begin
        Rec."Base VAT Code" := XVATLbl + ConvertStr(Format(GoodsVATRateLbl), ',', '.');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Whse Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyWhseDemoAccounts()
    begin
        WhseDemoAccount.ReturnAccountKey(true);

        WhseDemoAccounts.AddAccount(WhseDemoAccount.CustDomestic(), '2310');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.Resale(), '2110');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.ResaleInterim(), '2111');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.VendDomestic(), '5410');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.SalesDomestic(), '6110');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchDomestic(), '7110');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.SalesVAT(), '5615');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchaseVAT(), '5625');
    end;

    // Job events:

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Jobs Cust Data", 'OnBeforeCustomerInsert', false, false)]
    local procedure UpdateJobsCustomer(var Customer: Record Customer)
    begin
        Customer.Validate("Customer Posting Group", 'DOMESTIC');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Jobs Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyJobsDemoAccounts()
    begin
        JobsDemoAccount.ReturnAccountKey(true);
        JobsDemoAccounts.AddAccount(JobsDemoAccount.WIPCosts(), '2231');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.WIPAccruedCosts(), '2232');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.JobCostsApplied(), '7180');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.JobCostsAdjustment(), '7181');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.GLExpense(), '6610');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.JobSalesAdjustment(), '6191');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.WIPAccruedSales(), '2211');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.WIPInvoicedSales(), '2212');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.JobSalesApplied(), '6190');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.RecognizedCosts(), '7620');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.RecognizedSales(), '6620');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.ItemCostsApplied(), '7180');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.ResourceCostsApplied(), '7480');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.GLCostsApplied(), '7280');
    end;

    // Service Events:

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc Cust Data", 'OnBeforeCustomerInsert', false, false)]
    local procedure UpdateSvcCustomer(var Customer: Record Customer)
    begin
        Customer.Validate("Customer Posting Group", 'DOMESTIC');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifySvcDemoAccounts()
    begin
        SvcDemoAccount.ReturnAccountKey(true);
        SvcDemoAccounts.AddAccount(SvcDemoAccount.Contract(), '6700');
    end;


    var
        ManufacturingDemoAccount: Record "Manufacturing Demo Account";
        WhseDemoAccount: Record "Whse. Demo Account";
        SvcDemoAccount: Record "Svc Demo Account";
        JobsDemoAccount: Record "Jobs Demo Account";
        ManufacturingDemoAccounts: Codeunit "Manufacturing Demo Accounts";
        WhseDemoAccounts: Codeunit "Whse. Demo Accounts";
        SvcDemoAccounts: Codeunit "Svc Demo Accounts";
        JobsDemoAccounts: Codeunit "Jobs Demo Accounts";
        GoodsVATRateLbl: Label 'GST15';
        XVATLbl: Label 'VAT';
}