codeunit 11031 "Intrastat Report Filter Rcpt."
{
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportLineFilters: Text;
        InStreamFilters: InStream;
        OutStreamFilters: OutStream;
    begin
        Rec."Table Filters".CreateInStream(InStreamFilters);
        InStreamFilters.ReadText(IntrastatReportLineFilters);
        IntrastatReportLine.SetView(IntrastatReportLineFilters);
        IntrastatReportLine.SetRange(Type, IntrastatReportLine.Type::Receipt);

        Clear(Rec."Table Filters");
        Rec."Table Filters".CreateOutStream(OutStreamFilters);
        OutStreamFilters.WriteText(IntrastatReportLine.GetView());
        Rec.Modify(true);
    end;
}