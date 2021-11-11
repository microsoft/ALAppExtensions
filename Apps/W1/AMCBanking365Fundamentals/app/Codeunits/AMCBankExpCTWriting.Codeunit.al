#if not CLEAN20
codeunit 20110 "AMC Bank Exp. CT Writing"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by the new implementation in V19.1 of credit transfer writing.';
    ObsoleteTag = '20.0';

    Permissions = TableData "Data Exch. Field" = rimd;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        DataExchDef: Record "Data Exch. Def";
        DataExchField: Record "Data Exch. Field";
        OutputStream: OutStream;
    begin
        DataExchDef.Get("Data Exch. Def Code");
        DataExchDef.TestField("Reading/Writing XMLport");

        "File Content".CreateOutStream(OutputStream);
        DataExchField.SetRange("Data Exch. No.", "Entry No.");
        XMLPORT.Export(DataExchDef."Reading/Writing XMLport", OutputStream, DataExchField);

        DataExchField.DeleteAll(true);
    end;
}

#endif