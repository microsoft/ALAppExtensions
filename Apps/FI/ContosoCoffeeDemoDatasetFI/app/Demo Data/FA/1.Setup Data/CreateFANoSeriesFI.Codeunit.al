codeunit 13439 "Create FA No. Series FI"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        ContosoNoSeries: Codeunit "Contoso No Series";
        CreateFANoSeries: Codeunit "Create FA No Series";
    begin
        ContosoNoSeries.InsertNoSeries(FaJnl(), FixedAssetJournalLbl, 'G05001', 'G06000', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(Job(), JobTok, 'J00010', 'J99990', '', '', 10, Enum::"No. Series Implementation"::Sequence, true);

        UpdateFANNoSeries(CreateFANoSeries.FixedAsset(), true);

        UpdateFANoSeriesLine(CreateFANoSeries.InsuranceJournal(), 10000, 'N00001', 'N01000', 1);
        UpdateFANoSeriesLine(CreateFANoSeries.FixedAssetGLJournal(), 10000, 'F00001', 'F01000', 1);
        UpdateFANoSeriesLine(CreateFANoSeries.RecurringFixedAssetGLJournal(), 10000, 'RF00001', 'RF01000', 1);
        UpdateFANoSeriesLine(CreateFANoSeries.FixedAsset(), 10000, 'FA000010', 'FA999990', 10);
        UpdateFANoSeriesLine(CreateFANoSeries.Insurance(), 10000, 'INS000010', 'INS999990', 10);
    end;

    procedure FaJnl(): Code[20]
    begin
        exit(FaJnlTok);
    end;

    procedure Job(): Code[20]
    begin
        exit(JobTok);
    end;

    local procedure UpdateFANNoSeries(NoSeriesCode: Code[20]; ManualNo: Boolean)
    var
        NoSeries: Record "No. Series";
    begin
        NoSeries.Get(NoSeriesCode);
        NoSeries.Validate("Manual Nos.", ManualNo);
        NoSeries.Modify(true);
    end;

    local procedure UpdateFANoSeriesLine(NoSeriesCode: Code[20]; LineNo: Integer; StartingNo: Code[20]; EndingNo: Code[20]; IncrementbyNo: Integer)
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeriesLine.Get(NoSeriesCode, LineNo);
        NoSeriesLine.Validate("Starting No.", StartingNo);
        NoSeriesLine.Validate("Ending No.", EndingNo);
        NoSeriesLine.Validate("Increment-by No.", IncrementbyNo);
        NoSeriesLine.Modify(true);
    end;

    var
        JobTok: Label 'JOB', MaxLength = 20, Locked = true;
        FaJnlTok: Label 'FA-JNL', MaxLength = 20;
        FixedAssetJournalLbl: Label 'Fixed Asset Journal', MaxLength = 100;
}