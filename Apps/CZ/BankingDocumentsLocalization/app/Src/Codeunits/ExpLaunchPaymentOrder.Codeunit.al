// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Setup;
using Microsoft.Finance.GeneralLedger.Journal;
using System.IO;
using System.Utilities;

codeunit 31366 "Exp. Launch Payment Order CZB"
{
    TableNo = "Iss. Payment Order Header CZB";

    trigger OnRun()
    var
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
        BankAccount: Record "Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        IssPaymentOrderHeaderCZB.Copy(Rec);

        BankAccount.Get(Rec."Bank Account No.");
        if Rec."Foreign Payment Order" then
            BankExportImportSetup.Get(BankAccount."Foreign Payment Ex. Format CZB")
        else
            BankExportImportSetup.Get(BankAccount."Payment Export Format");

        BankExportImportSetup.TestField(Direction, BankExportImportSetup.Direction::Export);

        if BankExportImportSetup."Processing Report ID CZB" > 0 then
            RunProcessingReport(BankExportImportSetup, IssPaymentOrderHeaderCZB);

        if BankExportImportSetup."Processing XMLport ID" > 0 then
            RunProcessingXMLPort(BankExportImportSetup, IssPaymentOrderHeaderCZB);

        if BankExportImportSetup."Data Exch. Def. Code" <> '' then
            RunProcessingDataExchDef(IssPaymentOrderHeaderCZB);
    end;

    local procedure RunProcessingReport(BankExportImportSetup: Record "Bank Export/Import Setup"; IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB")
    var
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
    begin
        IssPaymentOrderLineCZB.SetRange("Payment Order No.", IssPaymentOrderHeaderCZB."No.");
        Report.RunModal(BankExportImportSetup."Processing Report ID CZB", false, false, IssPaymentOrderLineCZB);
    end;

    local procedure RunProcessingXMLPort(BankExportImportSetup: Record "Bank Export/Import Setup"; IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB")
    var
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        OutStream: OutStream;
        FileFilterTok: Label '*.%1', Comment = '%1 = Default File Type', Locked = true;
    begin
        TempBlob.CreateOutStream(OutStream);
        IssPaymentOrderLineCZB.Init();
        IssPaymentOrderLineCZB.SetRange("Payment Order No.", IssPaymentOrderHeaderCZB."No.");
        Xmlport.Export(BankExportImportSetup."Processing XMLport ID", OutStream, IssPaymentOrderLineCZB);
        FileManagement.BLOBExport(TempBlob, StrSubstNo(FileFilterTok, BankExportImportSetup."Default File Type CZB"), true);
    end;

    local procedure RunProcessingDataExchDef(IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB")
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        BankAccount.Get(IssPaymentOrderHeaderCZB."Bank Account No.");
        BankAccount.TestField("Payment Jnl. Template Name CZB");
        BankAccount.TestField("Payment Jnl. Batch Name CZB");
        IssPaymentOrderHeaderCZB.CreatePaymentJournal(BankAccount."Payment Jnl. Template Name CZB", BankAccount."Payment Jnl. Batch Name CZB");

        GenJournalLine.SetRange("Journal Template Name", BankAccount."Payment Jnl. Template Name CZB");
        GenJournalLine.SetRange("Journal Batch Name", BankAccount."Payment Jnl. Batch Name CZB");
        GenJournalLine.SetRange("Document No.", IssPaymentOrderHeaderCZB."No.");

        Commit();
        if not Codeunit.Run(Codeunit::"Exp. Launcher Gen. Jnl.", GenJournalLine) then
            Page.RunModal(Page::"Payment Journal", GenJournalLine);
    end;
}
