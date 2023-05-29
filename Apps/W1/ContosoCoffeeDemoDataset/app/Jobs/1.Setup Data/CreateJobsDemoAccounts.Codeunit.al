codeunit 5112 "Create Jobs Demo Accounts"
{
    TableNo = "Jobs Demo Account";

    trigger OnRun()
    begin
        Rec.ReturnAccountKey(true);

        JobsDemoAccounts.AddAccount(Rec.WIPCosts(), '2231', XWIPCostsTok);
        JobsDemoAccounts.AddAccount(Rec.WIPAccruedCosts(), '2232', XWIPAccruedCostsTok);
        JobsDemoAccounts.AddAccount(Rec.JobCostsApplied(), '7180', XJobCostsAppliedTok);
        JobsDemoAccounts.AddAccount(Rec.JobCostsAdjustment(), '7181', XJobCostsAdjustmentTok);
        JobsDemoAccounts.AddAccount(Rec.GLExpense(), '6610', XGLExpenseTok);
        JobsDemoAccounts.AddAccount(Rec.JobSalesAdjustment(), '6191', XJobSalesAdjustmentTok);
        JobsDemoAccounts.AddAccount(Rec.WIPAccruedSales(), '2211', XWIPAccruedSalesTok);
        JobsDemoAccounts.AddAccount(Rec.WIPInvoicedSales(), '2212', XWIPInvoicedSalesTok);
        JobsDemoAccounts.AddAccount(Rec.JobSalesApplied(), '6190', XJobSalesAppliedTok);
        JobsDemoAccounts.AddAccount(Rec.RecognizedCosts(), '7620', XRecognizedCostsTok);
        JobsDemoAccounts.AddAccount(Rec.RecognizedSales(), '6620', XRecognizedSalesTok);
        JobsDemoAccounts.AddAccount(Rec.ItemCostsApplied(), '7180', XItemCostsAppliedTok);
        JobsDemoAccounts.AddAccount(Rec.ResourceCostsApplied(), '7480', XResourceCostsAppliedTok);
        JobsDemoAccounts.AddAccount(Rec.GLCostsApplied(), '7280', XGLCostsAppliedTok);

        OnAfterCreateDemoAccounts();
    end;

    var
        JobsDemoAccounts: Codeunit "Jobs Demo Accounts";
        XWIPCostsTok: Label 'WIP Job Costs', MaxLength = 50;
        XWIPAccruedCostsTok: Label 'Accrued Job Costs', MaxLength = 50;
        XJobCostsAppliedTok: Label 'Job Cost Applied, Retail', MaxLength = 50;
        XJobCostsAdjustmentTok: Label 'Job Cost Adjmt., Retail', MaxLength = 50;
        XGLExpenseTok: Label 'Sales, Other Job Expenses', MaxLength = 50;
        XJobSalesAdjustmentTok: Label 'Job Sales Adjmt., Retail', MaxLength = 50;
        XWIPAccruedSalesTok: Label 'WIP Job Sales', MaxLength = 50;
        XWIPInvoicedSalesTok: Label 'Invoiced Job Sales', MaxLength = 50;
        XJobSalesAppliedTok: Label 'Job Sales Applied, Retail', MaxLength = 50;
        XRecognizedCostsTok: Label 'Job Costs', MaxLength = 50;
        XRecognizedSalesTok: Label 'Job Sales', MaxLength = 50;
        XItemCostsAppliedTok: Label 'Job Cost Applied, Retail', MaxLength = 50;
        XResourceCostsAppliedTok: Label 'Job Cost Applied, Resources', MaxLength = 50;
        XGLCostsAppliedTok: Label 'Job Cost Applied, Raw Mat.', MaxLength = 50;


    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDemoAccounts()
    begin
    end;
}