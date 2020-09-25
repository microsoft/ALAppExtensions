codeunit 1666 "MS Ceridian Payroll import"
{

    var
        CeridianPayrollTok: Label 'Ceridian Payroll Import';
        CashTok: Label 'Cash';
        EarningsTok: Label 'Earnings';
        DeductionsTok: Label 'Deductions';
        EmployeeTaxTok: Label 'Employee Tax';
        CeridianTelemetryCategoryTok: Label 'AL Ceridian', Locked = true;
        TransactionsImportedTxt: Label '%1 Ceridian payroll transactions imported.', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, 1660, 'OnRegisterPayrollService', '', false, false)]
    local procedure OnRegisterPayrollService(var TempServiceConnection: Record 1400 temporary);
    var
        MSCeridianPayrollSetup: Record 1665;
    begin
        IF NOT MSCeridianPayrollSetup.GET() THEN BEGIN
            MSCeridianPayrollSetup.INSERT(TRUE);
            COMMIT();
        END;
        TempServiceConnection."Record ID" := MSCeridianPayrollSetup.RECORDID();
        TempServiceConnection."No." := FORMAT(TempServiceConnection."Record ID");
        TempServiceConnection.Name := CeridianPayrollTok;
        TempServiceConnection.Status := TempServiceConnection.Status::Enabled;
        TempServiceConnection.INSERT();
    end;

    [EventSubscriber(ObjectType::Codeunit, 1660, 'OnImportPayroll', '', false, false)]
    local procedure OnImportPayroll(var TempServiceConnection: Record 1400 temporary; GenJournalLine: Record 81);
    var
        PayrollImportTransactions: Page 1661;
    begin
        IF NOT AMSCeridanRequest(FORMAT(TempServiceConnection."Record ID")) THEN
            EXIT;
        PayrollImportTransactions.Set(TempServiceConnection, GenJournalLine);
        PayrollImportTransactions.RUNMODAL();
    end;

    [EventSubscriber(ObjectType::Page, 1661, 'OnImportPayrollTransactions', '', false, false)]
    local procedure OnImportPayrollTransactions(var TempServiceConnection: Record 1400; var TempImportGLTransaction: Record 1661 temporary);
    var
        ImportCeridianPayroll: XMLport 1661;
    begin
        IF NOT AMSCeridanRequest(FORMAT(TempServiceConnection."Record ID")) THEN
            EXIT;
        TempImportGLTransaction.DELETEALL();
        ImportCeridianPayroll.RUN();
        ImportCeridianPayroll.GetTemporaryRecords(TempImportGLTransaction);
        Session.LogMessage('00001SW', STRSUBSTNO(TransactionsImportedTxt, TempImportGLTransaction.COUNT()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CeridianTelemetryCategoryTok);
    end;

    [EventSubscriber(ObjectType::Page, 1661, 'OnCreateSampleFile', '', false, false)]
    local procedure OnCreateSampleFile(TempServiceConnection: Record 1400);
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit 419;
        OutStream: OutStream;
    begin
        IF NOT AMSCeridanRequest(FORMAT(TempServiceConnection."Record ID")) THEN
            EXIT;

        TempBlob.CreateOutStream(OutStream);

        OutStream.WRITETEXT('000-5000' + ',' + GetDate() + ',' + '-30224.08' + ',' + CashTok);
        OutStream.WRITETEXT();
        OutStream.WRITETEXT('900-1000' + ',' + GetDate() + ',' + '23315.00' + ',' + EarningsTok);
        OutStream.WRITETEXT();
        OutStream.WRITETEXT('900-2000' + ',' + GetDate() + ',' + '-517.10' + ',' + DeductionsTok);
        OutStream.WRITETEXT();
        OutStream.WRITETEXT('900-3000' + ',' + GetDate() + ',' + '-6952.24' + ',' + EmployeeTaxTok);
        OutStream.WRITETEXT();
        OutStream.WRITETEXT('900-4000' + ',' + GetDate() + ',' + '1904.81' + ',' + EmployeeTaxTok);
        OutStream.WRITETEXT();
        OutStream.WRITETEXT('910-1000' + ',' + GetDate() + ',' + '10480.00' + ',' + EarningsTok);
        OutStream.WRITETEXT();
        OutStream.WRITETEXT('910-2000' + ',' + GetDate() + ',' + '-55.00' + ',' + DeductionsTok);
        OutStream.WRITETEXT();
        OutStream.WRITETEXT('910-3000' + ',' + GetDate() + ',' + '-2745.36' + ',' + EmployeeTaxTok);
        OutStream.WRITETEXT();
        OutStream.WRITETEXT('910-4000' + ',' + GetDate() + ',' + '871.29' + ',' + EmployeeTaxTok);
        OutStream.WRITETEXT();
        OutStream.WRITETEXT('920-1000' + ',' + GetDate() + ',' + '4850.00' + ',' + EarningsTok);
        OutStream.WRITETEXT();
        OutStream.WRITETEXT('920-2000' + ',' + GetDate() + ',' + '-25.00' + ',' + DeductionsTok);
        OutStream.WRITETEXT();
        OutStream.WRITETEXT('920-3000' + ',' + GetDate() + ',' + '-1294.63' + ',' + EmployeeTaxTok);
        OutStream.WRITETEXT();
        OutStream.WRITETEXT('920-4000' + ',' + GetDate() + ',' + '392.31' + ',' + EmployeeTaxTok);
        OutStream.WRITETEXT();

        FileMgt.BLOBExport(TempBlob, 'CeridianSample.csv', TRUE);
    end;

    local procedure GetDate(): Code[8];
    begin
        EXIT(FORMAT(WORKDATE(), 0, '<Month,2><Day,2><Year4>'))
    end;

    local procedure GetRecordID(): Text;
    var
        MSCeridianPayrollSetup: Record 1665;
    begin
        MSCeridianPayrollSetup.GET();
        EXIT(FORMAT(MSCeridianPayrollSetup.RECORDID()));
    end;

    local procedure AMSCeridanRequest(CallingRecordID: Text): Boolean;
    begin
        EXIT(CallingRecordID = GetRecordID());
    end;
}


