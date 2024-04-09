// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Reconciliation;
using Microsoft.Bank.Setup;
using System.IO;
using System.Utilities;

codeunit 31364 "Imp. Launch Bank Statement CZB"
{
    TableNo = "Bank Statement Header CZB";

    trigger OnRun()
    var
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
        BankAccount: Record "Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        BankStatementHeaderCZB.Copy(Rec);

        BankAccount.Get(Rec."Bank Account No.");
        BankExportImportSetup.Get(BankAccount."Bank Statement Import Format");
        BankExportImportSetup.TestField(Direction, BankExportImportSetup.Direction::Import);

        if BankExportImportSetup."Processing Report ID CZB" > 0 then
            RunProcessingReport(BankExportImportSetup, BankStatementHeaderCZB);

        if BankExportImportSetup."Processing XMLport ID" > 0 then
            RunProcessingXMLPort(BankExportImportSetup, BankStatementHeaderCZB);

        if BankExportImportSetup."Data Exch. Def. Code" <> '' then
            RunProcessingDataExchDef(BankStatementHeaderCZB);
    end;

    var
        WindowTitleTxt: Label 'Import';

    local procedure RunProcessingReport(BankExportImportSetup: Record "Bank Export/Import Setup"; BankStatementHeaderCZB: Record "Bank Statement Header CZB")
    var
        BankStatementLineCZB: Record "Bank Statement Line CZB";
    begin
        BankStatementLineCZB.SetRange("Bank Statement No.", BankStatementHeaderCZB."No.");
        Report.RunModal(BankExportImportSetup."Processing Report ID CZB", false, false, BankStatementLineCZB);
    end;

    local procedure RunProcessingXMLPort(BankExportImportSetup: Record "Bank Export/Import Setup"; BankStatementHeaderCZB: Record "Bank Statement Header CZB")
    var
        BankStatementLineCZB: Record "Bank Statement Line CZB";
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        InStream: InStream;
    begin
        TempBlob.CreateInStream(InStream);
        FileManagement.BLOBImportWithFilter(
          TempBlob, WindowTitleTxt, '', BankExportImportSetup.GetFilterTextCZB(), BankExportImportSetup."Default File Type CZB");
        BankStatementLineCZB.Init();
        BankStatementLineCZB.SetRange("Bank Statement No.", BankStatementHeaderCZB."No.");
        OnRunProcessingXMLPortOnAfterSetFilters(BankExportImportSetup, BankStatementHeaderCZB, BankStatementLineCZB);
        if TempBlob.HasValue() then
            XMLPORT.Import(BankExportImportSetup."Processing XMLport ID", InStream, BankStatementLineCZB);
    end;

    local procedure RunProcessingDataExchDef(BankStatementHeaderCZB: Record "Bank Statement Header CZB")
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        BankAccReconciliation.Init();
        BankAccReconciliation."Statement Type" := BankAccReconciliation."Statement Type"::"Payment Application";
        BankAccReconciliation."Bank Account No." := BankStatementHeaderCZB."Bank Account No.";
        BankAccReconciliation."Statement No." := BankStatementHeaderCZB."No.";
        BankAccReconciliation.Insert();
        Commit();

        if not ImportBankStatement(BankAccReconciliation) then begin
            BankAccReconciliationLine.SetRange("Statement Type", BankAccReconciliation."Statement Type");
            BankAccReconciliationLine.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
            BankAccReconciliationLine.SetRange("Statement No.", BankAccReconciliation."Statement No.");
            Page.RunModal(Page::"Payment Reconciliation Journal", BankAccReconciliationLine);
        end;
        if not CreateBankStmtLine(BankAccReconciliation) then begin
            BankAccReconciliation.Delete(true);
            Error(GetLastErrorText);
        end;
        BankAccReconciliation.Delete(true);
    end;

    local procedure ImportBankStatement(var BankAccReconciliation: Record "Bank Acc. Reconciliation"): Boolean
    var
        ImportBankStatementCZB: Codeunit "Import Bank Statement CZB";
    begin
        exit(ImportBankStatementCZB.Run(BankAccReconciliation));
    end;

    local procedure CreateBankStmtLine(var BankAccReconciliation: Record "Bank Acc. Reconciliation"): Boolean
    var
        CreateBankAccStmtLineCZB: Codeunit "Create Bank Acc. Stmt Line CZB";
    begin
        exit(CreateBankAccStmtLineCZB.Run(BankAccReconciliation));
    end;

    [IntegrationEvent(true, false)]
    local procedure OnRunProcessingXMLPortOnAfterSetFilters(BankExportImportSetup: Record "Bank Export/Import Setup"; BankStatementHeaderCZB: Record "Bank Statement Header CZB"; var BankStatementLineCZB: Record "Bank Statement Line CZB")
    begin
    end;
}
