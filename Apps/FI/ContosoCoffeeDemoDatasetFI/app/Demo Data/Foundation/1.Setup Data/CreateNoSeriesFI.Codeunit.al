codeunit 13402 "Create No. Series FI"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        UpdateNoSeriesLine(CreateNoSeries.Customer(), 10000, '10', '99990', '');
        UpdateNoSeriesLine(CreateNoSeries.InterCompanyGenJnl(), 10000, '0010', '9999', '');
        UpdateNoSeriesLine(CreateNoSeries.Vendor(), 10000, '10', '99990', '');
    end;

    local procedure UpdateNoSeriesLine(NoSeriesCode: Code[20]; LineNo: Integer; StartingNo: Code[20]; EndingNo: Code[20]; WarningNo: Code[20])
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeriesLine.Get(NoSeriesCode, LineNo);
        NoSeriesLine.Validate("Starting No.", StartingNo);
        NoSeriesLine.Validate("Warning No.", WarningNo);
        NoSeriesLine.Validate("Ending No.", EndingNo);
        NoSeriesLine.Modify(true);
    end;
}
