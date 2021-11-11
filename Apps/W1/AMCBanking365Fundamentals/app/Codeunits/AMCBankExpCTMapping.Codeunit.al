#if not CLEAN20
codeunit 20108 "AMC Bank Exp. CT Mapping"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by the new implementation in V19.1 of credit transfer mapping.';
    ObsoleteTag = '20.0';
    Permissions = TableData "Data Exch." = rimd;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PaymentExportDataRecordRef: RecordRef;
        WindowDialog: Dialog;
        LineNo: Integer;
    begin

        PaymentExportData.SetRange("Data Exch Entry No.", "Entry No.");
        PaymentExportData.FindSet();

        WindowDialog.Open(ProgressMsg);

        repeat
            LineNo += 1;
            WindowDialog.Update(1, LineNo);

            DataExch.Get(PaymentExportData."Data Exch Entry No.");
            DataExch.Validate("Data Exch. Line Def Code", PaymentExportData."Data Exch. Line Def Code");
            DataExch.Modify(true);

            PaymentExportDataRecordRef.GetTable(PaymentExportData);
            PaymentExportMgt.ProcessColumnMapping(DataExch, PaymentExportDataRecordRef,
              PaymentExportData."Line No.", PaymentExportData."Data Exch. Line Def Code", PaymentExportDataRecordRef.Number());
        until PaymentExportData.Next() = 0;

        WindowDialog.Close();
    end;

    var
        ProgressMsg: Label 'Processing line no. #1######.', Comment = '#1=Line number';

}

#endif