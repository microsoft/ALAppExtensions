codeunit 12224 "Contoso No. Series IT"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "No. Series Line" = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertNoSeriesSalesPurchase(NoSeriesCode: Code[20]; LineNo: Integer; StartingNo: Code[20]; StartingDate: Date)
    var
        NoSeriesLine: Record "No. Series Line";
        Exists: Boolean;
    begin
        if NoSeriesLine.Get(NoSeriesCode, LineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        NoSeriesLine.Validate("Series Code", NoSeriesCode);
        NoSeriesLine.Validate("Line No.", LineNo);
        NoSeriesLine.Validate("Starting No.", StartingNo);
        NoSeriesLine.Validate("Starting Date", StartingDate);

        if Exists then
            NoSeriesLine.Modify(true)
        else
            NoSeriesLine.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}