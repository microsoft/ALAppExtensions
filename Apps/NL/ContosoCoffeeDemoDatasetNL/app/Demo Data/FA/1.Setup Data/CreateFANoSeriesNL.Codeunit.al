codeunit 11540 "Create FA No. Series NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        CreateFANoSeries: Codeunit "Create FA No Series";
    begin
        UpdateFANoSeriesLine(CreateFANoSeries.FixedAssetGLJournal(), 10000, 'F00001', 'F01000', 1);
        UpdateFANoSeriesLine(CreateFANoSeries.RecurringFixedAssetGLJournal(), 10000, 'RF00001', 'RF01000', 1);
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
}