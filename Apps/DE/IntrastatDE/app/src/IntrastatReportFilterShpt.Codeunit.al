codeunit 11032 "Intrastat Report Filter Shpt."
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
        IntrastatReportLine.SetRange(Type, IntrastatReportLine.Type::Shipment);

        Clear(Rec."Table Filters");
        Rec."Table Filters".CreateOutStream(OutStreamFilters);
        OutStreamFilters.WriteText(IntrastatReportLine.GetView());
        Rec.Modify(true);
    end;
}