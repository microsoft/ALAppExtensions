codeunit 13707 "Create FA No. Series DK"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        CreateFANoSeries: Codeunit "Create FA No Series";
    begin
        UpdateFANoSeriesLine(CreateFANoSeries.InsuranceJournal(), 10000, 'N00001', 'N01000');
        UpdateFANoSeriesLine(CreateFANoSeries.FixedAssetGLJournal(), 10000, 'F00001', 'F01000');
        UpdateFANoSeriesLine(CreateFANoSeries.RecurringFixedAssetGLJournal(), 10000, 'RF00001', 'RF01000');
    end;

    local procedure UpdateFANoSeriesLine(NoSeriesCode: Code[20]; LineNo: Integer; StartingNo: Code[20]; EndingNo: Code[20])
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeriesLine.Get(NoSeriesCode, LineNo);
        NoSeriesLine.Validate("Starting No.", StartingNo);
        NoSeriesLine.Validate("Ending No.", EndingNo);
        NoSeriesLine.Modify(true);
    end;
}