#pragma warning disable AA0247
codeunit 5241 "Create Statistical Entry"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Statistical Acc. Journal Line" = r;

    trigger OnRun()
    var
        StatisticalAccJnlLine: Record "Statistical Acc. Journal Line";
        StatisticalJnlSetup: Codeunit "Create Statistical Jnl. Setup";
        LastLineNo: Integer;
    begin
        StatisticalAccJnlLine.SetRange("Journal Template Name", StatisticalJnlSetup.BlankTemplate());
        StatisticalAccJnlLine.SetRange("Journal Batch Name", StatisticalJnlSetup.ESGBatch());
        StatisticalAccJnlLine.FindLast();
        LastLineNo := StatisticalAccJnlLine."Line No.";

        CreateLinesToPost(StatisticalJnlSetup.BlankTemplate(), StatisticalJnlSetup.ESGBatch());

        PostCreatedEntries(LastLineNo, StatisticalJnlSetup.BlankTemplate(), StatisticalJnlSetup.ESGBatch());
    end;

    local procedure CreateLinesToPost(TemplateName: Code[10]; BatchName: Code[10])
    var
        ContosoUtility: Codeunit "Contoso Utilities";
        ContosoStatistical: Codeunit "Contoso Statistical Account";
        StatisticalAccount: Codeunit "Create Statistical Account";
    begin
        ContosoStatistical.InsertStatisticalJournalLine(TemplateName, BatchName, 'ESG' + Format(Date2DWY(Today, 3)), StatisticalAccount.DivGenFemale(), ContosoUtility.AdjustDate(19030806D), DivGenFemaleLbl, 48);
        ContosoStatistical.InsertStatisticalJournalLine(TemplateName, BatchName, 'ESG' + Format(Date2DWY(Today, 3)), StatisticalAccount.DivGenMale(), ContosoUtility.AdjustDate(19030806D), DivGenMaleLbl, 42);
        ContosoStatistical.InsertStatisticalJournalLine(TemplateName, BatchName, 'ESG' + Format(Date2DWY(Today, 3)), StatisticalAccount.DivAge25(), ContosoUtility.AdjustDate(19030806D), DivAge25Lbl, 18);
        ContosoStatistical.InsertStatisticalJournalLine(TemplateName, BatchName, 'ESG' + Format(Date2DWY(Today, 3)), StatisticalAccount.DivAge40(), ContosoUtility.AdjustDate(19030806D), DivAge40Lbl, 22);
        ContosoStatistical.InsertStatisticalJournalLine(TemplateName, BatchName, 'ESG' + Format(Date2DWY(Today, 3)), StatisticalAccount.DivAge55(), ContosoUtility.AdjustDate(19030806D), DivAge55Lbl, 30);
        ContosoStatistical.InsertStatisticalJournalLine(TemplateName, BatchName, 'ESG' + Format(Date2DWY(Today, 3)), StatisticalAccount.DivAge55Plus(), ContosoUtility.AdjustDate(19030806D), DivAge55PlusLbl, 20);
    end;

    local procedure PostCreatedEntries(LastLineNo: Integer; TemplateName: Code[10]; BatchName: Code[10])
    var
        StatisticalAccJnlLine: Record "Statistical Acc. Journal Line";
    begin
        StatisticalAccJnlLine.SetRange("Journal Template Name", TemplateName);
        StatisticalAccJnlLine.SetRange("Journal Batch Name", BatchName);
        StatisticalAccJnlLine.SetFilter("Line No.", '>%1', LastLineNo);
        StatisticalAccJnlLine.FindSet();

        Codeunit.Run(Codeunit::"Stat. Acc. Post. Batch", StatisticalAccJnlLine);
    end;

    var
        DivAge25Lbl: Label 'Employees under the age of 25', MaxLength = 100;
        DivAge40Lbl: Label 'Employees aged 25 to 40', MaxLength = 100;
        DivAge55Lbl: Label 'Employees aged 40 to 55', MaxLength = 100;
        DivAge55PlusLbl: Label 'Employees over the age of 55', MaxLength = 100;
        DivGenFemaleLbl: Label 'Female employees', MaxLength = 100;
        DivGenMaleLbl: Label 'Male employees', MaxLength = 100;
}
