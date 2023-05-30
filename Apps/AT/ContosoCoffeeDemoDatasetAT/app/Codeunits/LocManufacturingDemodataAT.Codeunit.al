codeunit 11140 "Loc. Manufacturing Demodata-AT"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyManufacturingDemoAccounts()
    begin
        ManufacturingDemoAccount.ReturnAccountKey(true);

        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.WIPAccountFinishedgoods(), '1410');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MaterialVariance(), '5310');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapacityVariance(), '5320');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MfgOverheadVariance(), '5350');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapOverheadVariance(), '5340');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.SubcontractedVariance(), '5330');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.FinishedGoods(), '1510');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.RawMaterials(), '1110');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedCap(), '5230');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRawMat(), '5130');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRetail(), '5030');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRawMat(), '5120');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRetail(), '5020');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedCap(), '5240');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRawMat(), '5140');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRetail(), '5040');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchRawMatDom(), '5540');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceCap(), '5245');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRawMat(), '5145');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRetail(), '5045');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Manufacturing Demo Data Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure ModifySeriesCode(var Rec: Record "Manufacturing Demo Data Setup")
    begin
        Rec."Base VAT Code" := 'OHNE MWST';
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Whse Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyWhseDemoAccounts()
    begin
        WhseDemoAccount.ReturnAccountKey(true);

        WhseDemoAccounts.AddAccount(WhseDemoAccount.CustDomestic(), '2020');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.Resale(), '1610');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.ResaleInterim(), '1620');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.VendDomestic(), '3320');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.SalesDomestic(), '4010');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchDomestic(), '5510');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.SalesVAT(), '3520');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchaseVAT(), '2520');
    end;

    // Job events:

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Jobs Cust Data", 'OnBeforeCustomerInsert', false, false)]
    local procedure UpdateJobsCustomer(var Customer: Record Customer)
    begin
        Customer.Validate("Customer Posting Group", 'INLAND');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Jobs Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyJobsDemoAccounts()
    begin
        JobsDemoAccount.ReturnAccountKey(true);
        JobsDemoAccounts.AddAccount(JobsDemoAccount.WIPCosts(), '1420');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.WIPAccruedCosts(), '1421');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.JobCostsApplied(), '5270');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.JobCostsAdjustment(), '5280');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.GLExpense(), '4260');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.JobSalesAdjustment(), '4050');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.WIPAccruedSales(), '1430');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.WIPInvoicedSales(), '1431');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.JobSalesApplied(), '4040');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.RecognizedCosts(), '5260');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.RecognizedSales(), '4250');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.ItemCostsApplied(), '5270');
        JobsDemoAccounts.AddAccount(JobsDemoAccount.GLCostsApplied(), '7280');
    end;

    // Service Events:

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc Cust Data", 'OnBeforeCustomerInsert', false, false)]
    local procedure UpdateSvcCustomer(var Customer: Record Customer)
    begin
        Customer.Validate("Customer Posting Group", 'INLAND');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifySvcDemoAccounts()
    begin
        SvcDemoAccount.ReturnAccountKey(true);
        SvcDemoAccounts.AddAccount(SvcDemoAccount.Contract(), '4500');
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