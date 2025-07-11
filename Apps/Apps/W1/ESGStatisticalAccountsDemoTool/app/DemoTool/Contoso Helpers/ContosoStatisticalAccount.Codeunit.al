#pragma warning disable AA0247
codeunit 5276 "Contoso Statistical Account"
{
    InherentPermissions = X;
    InherentEntitlements = X;
    Permissions =
        tabledata "Statistical Account" = rim,
        tabledata "Statistical Acc. Journal Batch" = rim,
        tabledata "Statistical Acc. Journal Line" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertStatisticalAccount(AccountNo: Code[20]; Name: Text[100])
    var
        StatisticalAccount: Record "Statistical Account";
        Exists: Boolean;
    begin
        if StatisticalAccount.Get(AccountNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        StatisticalAccount.Validate("No.", AccountNo);
        StatisticalAccount.Validate(Name, Name);

        if Exists then
            StatisticalAccount.Modify(true)
        else
            StatisticalAccount.Insert(true);
    end;

    procedure InsertStatisticalJournalBatch(TemplateName: Code[10]; BatchName: Code[10]; Description: Text[100])
    var
        StatisticalAccJnlBatch: Record "Statistical Acc. Journal Batch";
        Exists: Boolean;
    begin
        if StatisticalAccJnlBatch.Get(TemplateName, BatchName) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        StatisticalAccJnlBatch.Validate("Journal Template Name", TemplateName);
        StatisticalAccJnlBatch.Validate(Name, BatchName);
        StatisticalAccJnlBatch.Validate(Description, Description);

        if Exists then
            StatisticalAccJnlBatch.Modify(true)
        else
            StatisticalAccJnlBatch.Insert(true);
    end;

    procedure InsertStatisticalJournalLine(TemplateName: Code[10]; BatchName: Code[10]; DocumentNo: Code[20]; AccountNo: Code[20]; PostingDate: Date; Description: Text[100]; CustomAmount: Decimal)
    var
        StatisticalAccJnlLine: Record "Statistical Acc. Journal Line";
    begin
        StatisticalAccJnlLine.Validate("Journal Template Name", TemplateName);
        StatisticalAccJnlLine.Validate("Journal Batch Name", BatchName);
        StatisticalAccJnlLine.Validate("Line No.", GetNextStatisticalJournalLineNo(TemplateName, BatchName));
        StatisticalAccJnlLine.Validate("Document No.", DocumentNo);
        StatisticalAccJnlLine.Validate("Statistical Account No.", AccountNo);
        StatisticalAccJnlLine.Validate("Posting Date", PostingDate);
        StatisticalAccJnlLine.Validate(Description, Description);
        StatisticalAccJnlLine.Validate(Amount, CustomAmount);
        StatisticalAccJnlLine.Insert(true);
    end;

    local procedure GetNextStatisticalJournalLineNo(TemplateName: Code[10]; BatchName: Code[10]): Integer
    var
        StatisticalAccJnlLine: Record "Statistical Acc. Journal Line";
    begin
        StatisticalAccJnlLine.SetRange("Journal Template Name", TemplateName);
        StatisticalAccJnlLine.SetRange("Journal Batch Name", BatchName);
        StatisticalAccJnlLine.SetCurrentKey("Line No.");

        if StatisticalAccJnlLine.FindLast() then
            exit(StatisticalAccJnlLine."Line No." + 10000)
        else
            exit(10000);
    end;
}
