codeunit 5127 "Contoso No Series"
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

    procedure InsertNoSeries(NoSeriesCode: Code[20]; Description: Text[100]; StartingNo: Code[20]; EndingNo: Code[20]; WarningNo: Code[20]; LastNoUsed: Code[20]; IncrementBy: Integer; AllowGaps: Boolean; AllowManualNo: Boolean)
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        NoSeriesExists, NoSeriesLineExists : Boolean;
    begin
        if NoSeries.Get(NoSeriesCode) then begin
            NoSeriesExists := true;

            if not OverwriteData then
                exit;
        end;


        NoSeries.Init();
        NoSeries.Validate(Code, NoSeriesCode);
        NoSeries.Validate(Description, Description);
        NoSeries.Validate("Default Nos.", true);
        NoSeries.Validate("Manual Nos.", AllowManualNo);

        if NoSeriesExists then
            NoSeries.Modify(true)
        else
            NoSeries.Insert(true);

        if NoSeriesLine.Get(NoSeriesCode, GetDefaultLineNo()) then begin
            NoSeriesLineExists := true;

            if not OverwriteData then
                exit;
        end;

        NoSeriesLine.Validate("Series Code", NoSeries.Code);
        NoSeriesLine.Validate("Starting No.", StartingNo);
        NoSeriesLine.Validate("Ending No.", EndingNo);
        NoSeriesLine.Validate("Warning No.", WarningNo);
        NoSeriesLine.Validate("Last No. Used", LastNoUsed);
        NoSeriesLine.Validate("Increment-by No.", IncrementBy);
        NoSeriesLine.Validate("Allow Gaps in Nos.", AllowGaps);
        NoSeriesLine.Validate("Line No.", GetDefaultLineNo());

        if NoSeriesLineExists then
            NoSeriesLine.Modify(true)
        else
            NoSeriesLine.Insert(true);
    end;

    local procedure GetDefaultLineNo(): Integer
    begin
        exit(10000);
    end;
}