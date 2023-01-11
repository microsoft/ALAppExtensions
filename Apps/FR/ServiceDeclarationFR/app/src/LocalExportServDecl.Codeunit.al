codeunit 10891 "Local Export Serv. Decl."
{
    TableNo = "Service Declaration Header";

    trigger OnRun()
    var
        ServiceDeclarationSetup: Record "Service Declaration Setup";
        ServiceDeclarationHeader: Record "Service Declaration Header";
        ServiceDeclarationLine: Record "Service Declaration Line";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        DataExchMapping: Record "Data Exch. Mapping";
        DataExchTableFilter: Record "Data Exch. Table Filter";
        OutStr: OutStream;
    begin
        ServiceDeclarationSetup.Get();
        ServiceDeclarationSetup.TestField("Enable VAT Registration No.");
        ServiceDeclarationSetup.TestField("Data Exch. Def. Code");
        DataExchDef.Get(ServiceDeclarationSetup."Data Exch. Def. Code");

        DataExchMapping.SetRange("Data Exch. Def Code", DataExchDef.Code);
        DataExchMapping.SetRange("Table ID", DATABASE::"Service Declaration Line");
        DataExchMapping.FindFirst();

        DataExch.Init();
        DataExch."Data Exch. Def Code" := DataExchMapping."Data Exch. Def Code";
        DataExch."Data Exch. Line Def Code" := DataExchMapping."Data Exch. Line Def Code";
        DataExch."Table Filters".CreateOutStream(OutStr);
        ServiceDeclarationLine.SetRange("Service Declaration No.", Rec."No.");
        OutStr.WriteText(ServiceDeclarationLine.GetView());
        DataExch.Insert(true);

        DataExchTableFilter."Data Exch. No." := DataExch."Entry No.";
        DataExchTableFilter."Table ID" := Database::"Service Declaration Header";
        DataExchTableFilter."Table Filters".CreateOutStream(OutStr);
        ServiceDeclarationHeader := Rec;
        ServiceDeclarationHeader.SetRecFilter();
        OutStr.WriteText(ServiceDeclarationHeader.GetView());
        DataExchTableFilter.Insert();

        DataExch.ExportFromDataExch(DataExchMapping);

        DataExchTableFilter.SetRange("Data Exch. No.", DataExchTableFilter."Data Exch. No.");
        DataExchTableFilter.DeleteAll(true);
    end;
}
