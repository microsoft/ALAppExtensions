#pragma warning disable AA0247
codeunit 5240 "Create Statistical Journal"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        StatisticalJnlSetup: Codeunit "Create Statistical Jnl. Setup";
        ContosoUtility: Codeunit "Contoso Utilities";
    begin
        CreateLinesForDefaultBatch(StatisticalJnlSetup.BlankTemplate(), StatisticalJnlSetup.ESGBatch(), ContosoUtility.AdjustDate(19040805D));
    end;

    local procedure CreateLinesForDefaultBatch(TemplateName: Code[10]; BatchName: Code[10]; DefaultDate: Date)
    var
        ContosoStatistical: Codeunit "Contoso Statistical Account";
        StatisticalAccount: Codeunit "Create Statistical Account";
    begin
        ContosoStatistical.InsertStatisticalJournalLine(TemplateName, BatchName, 'ESG' + Format(Date2DWY(Today, 3)), StatisticalAccount.DivGenFemale(), DefaultDate, DivGenFemaleLbl, 51);
        ContosoStatistical.InsertStatisticalJournalLine(TemplateName, BatchName, 'ESG' + Format(Date2DWY(Today, 3)), StatisticalAccount.DivGenMale(), DefaultDate, DivGenMaleLbl, 45);
        ContosoStatistical.InsertStatisticalJournalLine(TemplateName, BatchName, 'ESG' + Format(Date2DWY(Today, 3)), StatisticalAccount.DivAge25(), DefaultDate, DivAge25Lbl, 20);
        ContosoStatistical.InsertStatisticalJournalLine(TemplateName, BatchName, 'ESG' + Format(Date2DWY(Today, 3)), StatisticalAccount.DivAge40(), DefaultDate, DivAge40Lbl, 24);
        ContosoStatistical.InsertStatisticalJournalLine(TemplateName, BatchName, 'ESG' + Format(Date2DWY(Today, 3)), StatisticalAccount.DivAge55(), DefaultDate, DivAge55Lbl, 33);
        ContosoStatistical.InsertStatisticalJournalLine(TemplateName, BatchName, 'ESG' + Format(Date2DWY(Today, 3)), StatisticalAccount.DivAge55Plus(), DefaultDate, DivAge55PlusLbl, 19);
    end;

    var
        DivAge25Lbl: Label 'Employees under the age of 25', MaxLength = 100;
        DivAge40Lbl: Label 'Employees aged 25 to 40', MaxLength = 100;
        DivAge55Lbl: Label 'Employees aged 40 to 55', MaxLength = 100;
        DivAge55PlusLbl: Label 'Employees over the age of 55', MaxLength = 100;
        DivGenFemaleLbl: Label 'Female employees', MaxLength = 100;
        DivGenMaleLbl: Label 'Male employees', MaxLength = 100;
}
