namespace Microsoft.Payroll.Ceridian;

using Microsoft.Finance.Payroll;
using Microsoft.Utilities;
using System.Utilities;
using System.IO;

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payroll Management", 'OnRegisterPayrollService', '', false, false)]
    local procedure OnRegisterPayrollService(var TempServiceConnection: Record "Service Connection" temporary);
    var
        MSCeridianPayrollSetup: Record "MS Ceridian Payroll Setup";
    begin
        if not MSCeridianPayrollSetup.ReadPermission then
            exit;
        if not MSCeridianPayrollSetup.GET() then begin
            if not MSCeridianPayrollSetup.WritePermission then
                exit;
            MSCeridianPayrollSetup.INSERT(true);
            COMMIT();
        end;
        TempServiceConnection."Record ID" := MSCeridianPayrollSetup.RECORDID();
        TempServiceConnection."No." := FORMAT(TempServiceConnection."Record ID");
        TempServiceConnection.Name := CeridianPayrollTok;
        TempServiceConnection.Status := TempServiceConnection.Status::Enabled;
        TempServiceConnection.INSERT();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payroll Management", 'OnImportPayroll', '', false, false)]
    local procedure OnImportPayroll(var TempServiceConnection: Record "Service Connection" temporary; GenJournalLine: Record 81);
    var
        PayrollImportTransactions: Page "Payroll Import Transactions";
    begin
        if not AMSCeridanRequest(FORMAT(TempServiceConnection."Record ID")) then
            exit;
        PayrollImportTransactions.Set(TempServiceConnection, GenJournalLine);
        PayrollImportTransactions.RUNMODAL();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Payroll Import Transactions", 'OnImportPayrollTransactions', '', false, false)]
    local procedure OnImportPayrollTransactions(var TempServiceConnection: Record "Service Connection"; var TempImportGLTransaction: Record 1661 temporary);
    var
        ImportCeridianPayroll: XMLport "Import Ceridian Payroll";
    begin
        if not AMSCeridanRequest(FORMAT(TempServiceConnection."Record ID")) then
            exit;
        TempImportGLTransaction.DELETEALL();
        ImportCeridianPayroll.RUN();
        ImportCeridianPayroll.GetTemporaryRecords(TempImportGLTransaction);
        Session.LogMessage('00001SW', STRSUBSTNO(TransactionsImportedTxt, TempImportGLTransaction.COUNT()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CeridianTelemetryCategoryTok);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Payroll Import Transactions", 'OnCreateSampleFile', '', false, false)]
    local procedure OnCreateSampleFile(TempServiceConnection: Record "Service Connection");
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        OutStream: OutStream;
    begin
        if not AMSCeridanRequest(FORMAT(TempServiceConnection."Record ID")) then
            exit;

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

        FileMgt.BLOBExport(TempBlob, 'CeridianSample.csv', true);
    end;

    local procedure GetDate(): Code[8];
    begin
        exit(FORMAT(WORKDATE(), 0, '<Month,2><Day,2><Year4>'))
    end;

    local procedure GetRecordID(): Text;
    var
        MSCeridianPayrollSetup: Record "MS Ceridian Payroll Setup";
    begin
        MSCeridianPayrollSetup.GET();
        exit(FORMAT(MSCeridianPayrollSetup.RECORDID()));
    end;

    local procedure AMSCeridanRequest(CallingRecordID: Text): Boolean;
    begin
        exit(CallingRecordID = GetRecordID());
    end;
}


