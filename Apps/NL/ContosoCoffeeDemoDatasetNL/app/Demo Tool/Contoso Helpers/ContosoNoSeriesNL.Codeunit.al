codeunit 11537 "Contoso No Series NL"
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

    procedure InsertNoSeries(NoSeriesCode: Code[20]; Description: Text[100]; StartingNo: Code[20]; IncrementBy: Integer; Implementation: Enum "No. Series Implementation"; AllowManualNo: Boolean)
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
        NoSeriesLine.Validate("Increment-by No.", IncrementBy);
        NoSeriesLine.Validate(Implementation, Implementation);
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