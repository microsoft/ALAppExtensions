codeunit 31226 "Contoso No. Series CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "No. Series" = rim,
        tabledata "No. Series Line" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertNoSeries(NoSeriesCode: Code[20]; Description: Text[100]; AllowManualNo: Boolean)
    var
        NoSeries: Record "No. Series";
        Exists: Boolean;
    begin
        if NoSeries.Get(NoSeriesCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        NoSeries.Init();
        NoSeries.Validate(Code, NoSeriesCode);
        NoSeries.Validate(Description, Description);
        NoSeries.Validate("Default Nos.", true);
        NoSeries.Validate("Manual Nos.", AllowManualNo);

        if Exists then
            NoSeries.Modify(true)
        else
            NoSeries.Insert(true);
    end;

    procedure InsertNoSeriesLine(NoSeriesCode: Code[20]; NoSeriesLineNo: Integer; StartingDate: Date; StartingNo: Code[20]; EndingNo: Code[20]; WarningNo: Code[20]; LastNoUsed: Code[20]; IncrementBy: Integer; Implementation: Enum "No. Series Implementation")
    var
        NoSeriesLine: Record "No. Series Line";
        Exists: Boolean;
    begin
        if NoSeriesLine.Get(NoSeriesCode, NoSeriesLineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        NoSeriesLine.Validate("Series Code", NoSeriesCode);
        NoSeriesLine.Validate("Line No.", NoSeriesLineNo);
        NoSeriesLine.Validate("Starting Date", StartingDate);
        NoSeriesLine.Validate("Starting No.", StartingNo);
        NoSeriesLine.Validate("Ending No.", EndingNo);
        NoSeriesLine.Validate("Warning No.", WarningNo);
        NoSeriesLine.Validate("Last No. Used", LastNoUsed);
        NoSeriesLine.Validate("Increment-by No.", IncrementBy);
        NoSeriesLine.Validate(Implementation, Implementation);

        if Exists then
            NoSeriesLine.Modify(true)
        else
            NoSeriesLine.Insert(true);
    end;
}