codeunit 4783 "Create Mfg No. Series"
{
    Permissions = tabledata "No. Series" = ri,
        tabledata "No. Series Line" = ri;

    procedure InitFinalSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100]; No: Integer)
    var
        StartingNo: Code[20];
        EndingNo: Code[20];
    begin
        StartingNo := '10' + Format(No);
        EndingNo := '10' + Format(No + 1);
        InsertSeries(
          SeriesCode, Code, Description,
          StartingNo + '001',
          EndingNo + '999',
          '',
          EndingNo + '995',
          1,
          false);
    end;

    procedure InitTempSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100])
    begin
        InitTempSeries(SeriesCode, Code, Description, 1);
    end;

    procedure InitTempSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100]; No: Integer)
    var
        StartingNo: Code[20];
        EndingNo: Code[20];
    begin
        StartingNo := Format(No);
        EndingNo := Format(No + 1);
        InsertSeries(
          SeriesCode, Code, Description,
          StartingNo + '001',
          EndingNo + '999',
          '',
          EndingNo + '995',
          1,
          false,
          false);
    end;

    procedure InitBaseSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100]; StartingNo: Code[20]; EndingNo: Code[20]; LastNumberUsed: Code[20]; WarningAtNo: Code[20]; "Increment-by No.": Integer)
    begin
        InitBaseSeries(SeriesCode, "Code", Description, StartingNo, EndingNo, LastNumberUsed, WarningAtNo, "Increment-by No.", false);
    end;

    procedure InitBaseSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100]; StartingNo: Code[20]; EndingNo: Code[20]; LastNumberUsed: Code[20]; WarningAtNo: Code[20]; "Increment-by No.": Integer; "Allow Gaps": Boolean)
    begin
        InsertSeries(
          SeriesCode, Code, Description,
          StartingNo, EndingNo, LastNumberUsed, WarningAtNo, "Increment-by No.", true, "Allow Gaps");
    end;

    procedure InsertSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100]; StartingNo: Code[20]; EndingNo: Code[20]; LastNumberUsed: Code[20]; WarningNo: Code[20]; "Increment-by No.": Integer; "Manual Nos.": Boolean)
    begin
        InsertSeries(SeriesCode, "Code", Description, StartingNo, EndingNo, LastNumberUsed, WarningNo, "Increment-by No.", "Manual Nos.", false);
    end;

    internal procedure InsertSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100]; StartingNo: Code[20]; EndingNo: Code[20]; LastNumberUsed: Code[20]; WarningNo: Code[20]; "Increment-by No.": Integer; "Manual Nos.": Boolean; "Allow Gaps": Boolean)
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeries.Init();
        NoSeries.Code := Code;
        NoSeries.Description := Description;
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := "Manual Nos.";
        NoSeries.Insert();

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine.Validate("Starting No.", StartingNo);
        NoSeriesLine.Validate("Ending No.", EndingNo);
        NoSeriesLine.Validate("Last No. Used", LastNumberUsed);
        if WarningNo <> '' then
            NoSeriesLine.Validate("Warning No.", WarningNo);
        NoSeriesLine.Validate("Increment-by No.", "Increment-by No.");
        NoSeriesLine.Validate("Allow Gaps in Nos.", "Allow Gaps");
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine.Insert(true);

        SeriesCode := Code;
    end;
}