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

    // Job events:

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Jobs Cust Data", 'OnBeforeCustomerInsert', false, false)]
    local procedure UpdateJobsCustomer(var Customer: Record Customer)
    begin
        Customer.Validate("Customer Posting Group", 'BINNENLAND');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Jobs Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyJobsDemoAccounts()
    begin
        JobsDemoAccount.ReturnAccountKey(true);
        JobsDemoAccounts.AddAccount(JobsDemoAccount.WIPCosts(), '320000');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.WIPAccruedCosts(), '320000');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.JobCostsApplied(), '609180');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.JobCostsAdjustment(), '609180');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.GLExpense(), '703010');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.JobSalesAdjustment(), '742000');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.WIPAccruedSales(), '320000');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.WIPInvoicedSales(), '320000');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.JobSalesApplied(), '742000');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.RecognizedCosts(), '602010');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.RecognizedSales(), '703000');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.ItemCostsApplied(), '609180');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.ResourceCostsApplied(), '609480');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.GLCostsApplied(), '609280');
    end;

    // Service Events:

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc Cust Data", 'OnBeforeCustomerInsert', false, false)]
    local procedure UpdateSvcCustomer(var Customer: Record Customer)
    begin
        Customer.Validate("Customer Posting Group", 'BINNENLAND');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifySvcDemoAccounts()
    begin
        SvcDemoAccount.ReturnAccountKey(true);
        SvcDemoAccounts.AddAccount(SvcDemoAccount.Contract(), '705000');
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