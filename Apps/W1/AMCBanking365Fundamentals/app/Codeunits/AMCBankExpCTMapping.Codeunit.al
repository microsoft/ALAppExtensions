codeunit 20108 "AMC Bank Exp. CT Mapping"
{
    Permissions = TableData "Data Exch." = rimd;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PaymentExportDataRecRef: RecordRef;
        Window: Dialog;
        LineNo: Integer;
    begin
        PaymentExportData.SetRange("Data Exch Entry No.", "Entry No.");
        PaymentExportData.FindSet();

        Window.Open(ProgressMsg);

        repeat
            LineNo += 1;
            Window.Update(1, LineNo);

            DataExch.Get(PaymentExportData."Data Exch Entry No.");
            DataExch.Validate("Data Exch. Line Def Code", PaymentExportData."Data Exch. Line Def Code");
            DataExch.Modify(true);

            PaymentExportDataRecRef.GetTable(PaymentExportData);
            PaymentExportMgt.ProcessColumnMapping(DataExch, PaymentExportDataRecRef,
              PaymentExportData."Line No.", PaymentExportData."Data Exch. Line Def Code", PaymentExportDataRecRef.Number());
        until PaymentExportData.Next() = 0;

        Window.Close();
    end;

    var
        ProgressMsg: Label 'Processing line no. #1######.';
}

