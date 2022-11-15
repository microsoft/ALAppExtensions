codeunit 5014 "Export Service Declaration"
{
    TableNo = "Service Declaration Header";

    trigger OnRun()
    var
        ServiceDeclarationSetup: Record "Service Declaration Setup";
        ServiceDeclarationLine: Record "Service Declaration Line";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        DataExchMapping: Record "Data Exch. Mapping";
        OutStr: OutStream;
    begin
        ServiceDeclarationSetup.Get();
        ServiceDeclarationSetup.TestField("Data Exch. Def. Code");
        DataExchDef.Get(ServiceDeclarationSetup."Data Exch. Def. Code");
        DataExchMapping.SetRange("Data Exch. Def Code", DataExchDef.Code);
        DataExchMapping.SetRange("Table ID", Database::"Service Declaration Line");
        DataExchMapping.FindFirst();

        DataExch.Init();
        DataExch."Data Exch. Def Code" := DataExchMapping."Data Exch. Def Code";
        DataExch."Data Exch. Line Def Code" := DataExchMapping."Data Exch. Line Def Code";
        DataExch."Table Filters".CreateOutStream(OutStr);
        ServiceDeclarationLine.SetRange("Service Declaration No.", Rec."No.");
        OutStr.WriteText(ServiceDeclarationLine.GetView());
        DataExch.Insert(true);
        DataExch.ExportFromDataExch(DataExchMapping);
    end;
}

