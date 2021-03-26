codeunit 2414 "XS Xero Report Management"
{
    procedure AddAdditionalParametersToList(var ListOfAdditionalParametersForReports: List of [Text]; Parameter: Text)
    begin
        ListOfAdditionalParametersForReports.Add(Parameter);
    end;

    procedure GetReportDateFromTitle(FetchedReport: JsonToken) ReportDate: Text
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
        Title: Text;
        TitleElements: List of [Text];
        TitlesToken: JsonToken;
    begin
        JsonObjectHelper.SetJsonObject(FetchedReport);
        TitlesToken := JsonObjectHelper.GetJsonToken(XeroSyncManagement.GetJsonTagForReportTitles());
        TitlesToken.WriteTo(Title);
        TitleElements := Title.Split(',');
        ReportDate := TitleElements.Get(TitleElements.Count()).Replace('"', '').Replace(']', '');
    end;

    procedure GetSpecificCellValue(Cells: JsonArray; CellIndex: Integer; var CurrentAmmount: Decimal)
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        CellToken: JsonToken;
        Value: Text;
        SumHelper: Decimal;
    begin
        Cells.Get(CellIndex, CellToken);
        JsonObjectHelper.SetJsonObject(CellToken);
        Value := JsonObjectHelper.GetJsonValueAsText('Value');
        if Value <> '' then begin
            SumHelper := CurrentAmmount;
            Evaluate(CurrentAmmount, Value, 9);
            CurrentAmmount := SumHelper + CurrentAmmount;
        end;
    end;
}