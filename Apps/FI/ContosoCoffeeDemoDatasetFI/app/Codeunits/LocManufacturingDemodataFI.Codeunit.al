codeunit 13405 "Loc. Manufacturing Demodata-FI"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyManufacturingDemoAccounts()
    begin
        ManufacturingDemoAccount.ReturnAccountKey(true);

        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.WIPAccountFinishedgoods(), '1650');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MaterialVariance(), '4510');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapacityVariance(), '4511');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MfgOverheadVariance(), '4514');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapOverheadVariance(), '4513');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.SubcontractedVariance(), '4512');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.FinishedGoods(), '1610');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.RawMaterials(), '1630');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedCap(), '4411');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRawMat(), '4141');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRetail(), '4131');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRawMat(), '4800');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRetail(), '4820');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedCap(), '4412');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRawMat(), '4142');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRetail(), '4132');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchRawMatDom(), '7210');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceCap(), '4413');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRawMat(), '4143');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRetail(), '4133');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Whse Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyWhseDemoAccounts()
    begin
        WhseDemoAccount.ReturnAccountKey(true);

        WhseDemoAccounts.AddAccount(WhseDemoAccount.CustDomestic(), '1700');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.Resale(), '1620');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.ResaleInterim(), '1621');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.VendDomestic(), '2760');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.SalesDomestic(), '3001');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchDomestic(), '7110');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.SalesVAT(), '2943');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchaseVAT(), '1842');
    end;

    // Job events:

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Jobs Cust Data", 'OnBeforeCustomerInsert', false, false)]
    local procedure UpdateJobsCustomer(var Customer: Record Customer)
    begin
        Customer.Validate("Customer Posting Group", 'KOTIMAAN');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Jobs Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyJobsDemoAccounts()
    begin
        JobsDemoAccount.ReturnAccountKey(true);
        JobsDemoAccounts.AddAccount(JobsDemoAccount.WIPCosts(), '1641');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.WIPAccruedCosts(), '1641');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.JobCostsApplied(), '4121');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.JobCostsAdjustment(), '1641');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.GLExpense(), '3075');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.JobSalesAdjustment(), '3122');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.WIPAccruedSales(), '1641');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.WIPInvoicedSales(), '1641');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.JobSalesApplied(), '3121');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.RecognizedCosts(), '4150');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.RecognizedSales(), '3070');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.ItemCostsApplied(), '4121');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.ResourceCostsApplied(), '4122');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.GLCostsApplied(), '4120');
    end;

    // Service Events:

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc Cust Data", 'OnBeforeCustomerInsert', false, false)]
    local procedure UpdateSvcCustomer(var Customer: Record Customer)
    begin
        Customer.Validate("Customer Posting Group", 'KOTIMAAN');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifySvcDemoAccounts()
    begin
        SvcDemoAccount.ReturnAccountKey(true);
        SvcDemoAccounts.AddAccount(SvcDemoAccount.Contract(), '3820');
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
}