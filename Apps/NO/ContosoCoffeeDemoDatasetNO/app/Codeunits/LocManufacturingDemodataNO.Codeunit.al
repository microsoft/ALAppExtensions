codeunit 10660 "Loc. Manufacturing Demodata-NO"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyManufacturingDemoAccounts()
    begin
        ManufacturingDemoAccount.ReturnAccountKey(true);

        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapOverheadVariance(), '7823');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapacityVariance(), '7821');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedCap(), '7700');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRawMat(), '7270');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRetail(), '7170');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.FinishedGoods(), '2120');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.RawMaterials(), '2130');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRawMat(), '7270');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRetail(), '7170');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MaterialVariance(), '7820');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MfgOverheadVariance(), '7824');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedCap(), '7700');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRawMat(), '7270');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRetail(), '7170');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchRawMatDom(), '7210');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceCap(), '7810');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRawMat(), '7810');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRetail(), '7810');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.SubcontractedVariance(), '7822');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.WIPAccountFinishedgoods(), '2150');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Manufacturing Demo Data Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure ModifySeriesCode(var Rec: Record "Manufacturing Demo Data Setup")
    begin
        Rec."Price Factor" := 10;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg Vendor", 'OnBeforeVendorInsert', '', false, false)]
    local procedure UpdateVendor(var Vendor: Record Vendor)
    begin
        Vendor.validate("Vendor Posting Group", 'INNENLANDS');
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
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchDomestic(), '7140');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.SalesVAT(), '5611');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchaseVAT(), '5631');
    end;

    // Job events:

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Jobs Cust Data", 'OnBeforeCustomerInsert', false, false)]
    local procedure UpdateJobsCustomer(var Customer: Record Customer)
    begin
        Customer.Validate("Customer Posting Group", 'INNENLANDS');
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
        Customer.Validate("Customer Posting Group", 'INNENLANDS');
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
}