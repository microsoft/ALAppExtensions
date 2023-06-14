codeunit 5114 "Create Jobs Demo Accounts"
{
    TableNo = "Jobs Demo Account";

    trigger OnRun()
    begin
        Rec.ReturnAccountKey(true);

        JobsDemoAccounts.AddAccount(Rec.WIPCosts(), '2231', WIPCostsTok);
        JobsDemoAccounts.AddAccount(Rec.WIPAccruedCosts(), '2232', WIPAccruedCostsTok);
        JobsDemoAccounts.AddAccount(Rec.JobCostsApplied(), '7180', JobCostsAppliedTok);
        JobsDemoAccounts.AddAccount(Rec.JobCostsAdjustment(), '7181', JobCostsAdjustmentTok);
        JobsDemoAccounts.AddAccount(Rec.GLExpense(), '6610', GLExpenseTok);
        JobsDemoAccounts.AddAccount(Rec.JobSalesAdjustment(), '6191', JobSalesAdjustmentTok);
        JobsDemoAccounts.AddAccount(Rec.WIPAccruedSales(), '2211', WIPAccruedSalesTok);
        JobsDemoAccounts.AddAccount(Rec.WIPInvoicedSales(), '2212', WIPInvoicedSalesTok);
        JobsDemoAccounts.AddAccount(Rec.JobSalesApplied(), '6190', JobSalesAppliedTok);
        JobsDemoAccounts.AddAccount(Rec.RecognizedCosts(), '7620', RecognizedCostsTok);
        JobsDemoAccounts.AddAccount(Rec.RecognizedSales(), '6620', RecognizedSalesTok);
        JobsDemoAccounts.AddAccount(Rec.ItemCostsApplied(), '7180', ItemCostsAppliedTok);
        JobsDemoAccounts.AddAccount(Rec.ResourceCostsApplied(), '7480', ResourceCostsAppliedTok);
        JobsDemoAccounts.AddAccount(Rec.GLCostsApplied(), '7280', GLCostsAppliedTok);

        OnAfterCreateDemoAccounts();
    end;

    var
        JobsDemoAccounts: Codeunit "Jobs Demo Accounts";
        WIPCostsTok: Label 'WIP Job Costs', MaxLength = 50;
        WIPAccruedCostsTok: Label 'Accrued Job Costs', MaxLength = 50;
        JobCostsAppliedTok: Label 'Job Cost Applied, Retail', MaxLength = 50;
        JobCostsAdjustmentTok: Label 'Job Cost Adjmt., Retail', MaxLength = 50;
        GLExpenseTok: Label 'Sales, Other Job Expenses', MaxLength = 50;
        JobSalesAdjustmentTok: Label 'Job Sales Adjmt., Retail', MaxLength = 50;
        WIPAccruedSalesTok: Label 'WIP Job Sales', MaxLength = 50;
        WIPInvoicedSalesTok: Label 'Invoiced Job Sales', MaxLength = 50;
        JobSalesAppliedTok: Label 'Job Sales Applied, Retail', MaxLength = 50;
        RecognizedCostsTok: Label 'Job Costs', MaxLength = 50;
        RecognizedSalesTok: Label 'Job Sales', MaxLength = 50;
        ItemCostsAppliedTok: Label 'Job Cost Applied, Retail', MaxLength = 50;
        ResourceCostsAppliedTok: Label 'Job Cost Applied, Resources', MaxLength = 50;
        GLCostsAppliedTok: Label 'Job Cost Applied, Raw Mat.', MaxLength = 50;


    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDemoAccounts()
    begin
    end;
}