// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank;
using Microsoft.Bank.BankAccount;
using Microsoft.Bank.DirectDebit;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Reporting;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Reminder;
using Microsoft.Service.History;
using System.Environment;
using System.Globalization;
using System.IO;
using System.Utilities;

codeunit 11518 "Swiss QR-Bill Mgt."
{
    Permissions = tabledata "Tenant Media" = rd;

    var
        PaymentMethodsTxt: Label '%1 of %2 Payment Methods enabled with QR-Bill Layout', Comment = '%1, %2 - number of records';
        DocumentTypesTxt: Label '%1 of %2 Document Types enabled for QR-Bills', Comment = '%1, %2 - number of records';
        QRBillCaptionLbl: Label 'QR-Bill';

    internal procedure GetQRBillCaption(): Text
    begin
        exit(QRBillCaptionLbl);
    end;

    internal procedure FindServiceInvoiceFromLedgerEntry(var ServiceInvoiceHeader: Record "Service Invoice Header"; CustLedgerEntry: Record "Cust. Ledger Entry"): Boolean
    begin
        CustLedgerEntry.TestField("Entry No.");
        if CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice then
            with ServiceInvoiceHeader do begin
                SetRange("No.", CustLedgerEntry."Document No.");
                exit(FindFirst());
            end;
    end;

    internal procedure FindIssuedReminderFromLedgerEntry(var IssuedReminderHeader: Record "Issued Reminder Header"; CustLedgerEntry: Record "Cust. Ledger Entry"): Boolean
    begin
        CustLedgerEntry.TestField("Entry No.");
        if CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Reminder then
            with IssuedReminderHeader do begin
                SetRange("No.", CustLedgerEntry."Document No.");
                SetRange("Posting Date", CustLedgerEntry."Posting Date");
                SetRange("Customer No.", CustLedgerEntry."Customer No.");
                exit(FindFirst());
            end;
    end;

    internal procedure FindIssuedFinChargeMemoFromLedgerEntry(var IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header"; CustLedgerEntry: Record "Cust. Ledger Entry"): Boolean
    begin
        CustLedgerEntry.TestField("Entry No.");
        if CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::"Finance Charge Memo" then
            with IssuedFinChargeMemoHeader do begin
                SetRange("No.", CustLedgerEntry."Document No.");
                SetRange("Posting Date", CustLedgerEntry."Posting Date");
                SetRange("Customer No.", CustLedgerEntry."Customer No.");
                exit(FindFirst());
            end;
    end;

    procedure FindCustLedgerEntry(var LedgerEntryNo: Integer; CustomerNo: Code[20]; DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]; PostingDate: Date) Found: Boolean
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        FilterCustLedgerEntry(CustLedgerEntry, CustomerNo, DocumentType, DocumentNo, PostingDate);
        Found := CustLedgerEntry.FindFirst();
        LedgerEntryNo := CustLedgerEntry."Entry No.";
    end;

    procedure FilterCustLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; CustomerNo: Code[20]; DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]; PostingDate: Date): Boolean
    begin
        with CustLedgerEntry do begin
            SetRange("Customer No.", CustomerNo);
            SetRange("Document Type", DocumentType);
            SetRange("Document No.", DocumentNo);
            SetRange("Posting Date", PostingDate);
        end;
    end;

    internal procedure FormatEnabledReportsCount(EnabledReportsCount: Integer): Text
    begin
        exit(StrSubstNo(DocumentTypesTxt, EnabledReportsCount, 2));
    end;

    internal procedure CalcEnabledReportsCount(): Integer
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.SetRange("Report ID", Report::"Swiss QR-Bill Print");
        exit(ReportSelections.Count());
    end;

    internal procedure FormatQRPaymentMethodsCount(QRPaymentMethods: Integer): Text
    var
        PaymentMethod: Record "Payment Method";
    begin
        exit(StrSubstNo(PaymentMethodsTxt, QRPaymentMethods, PaymentMethod.Count()));
    end;

    internal procedure CalcQRPaymentMethodsCount(): Integer
    var
        PaymentMethod: Record "Payment Method";
    begin
        PaymentMethod.SetFilter("Swiss QR-Bill Layout", '<>%1', '');
        exit(PaymentMethod.Count());
    end;

    internal procedure PrintFromBuffer(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer")
    var
        FileManagement: Codeunit "File Management";
        PDFFileTempBlob: Codeunit "Temp Blob";
        PDFFileInStream: InStream;
    begin
        PDFFileTempBlob.CreateInStream(PDFFileInStream);
        if ReportPrintToStream(SwissQRBillBuffer, PDFFileTempBlob) then
            FileManagement.DownloadFromStreamHandler(PDFFileInStream, 'Save QR-Bill', '', 'pdf', SwissQRBillBuffer."File Name");
    end;

    local procedure ReportPrintToStream(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer"; var PDFFileTempBlob: Codeunit "Temp Blob") Result: Boolean
    var
        SwissQRBillPrint: Report "Swiss QR-Bill Print";
        PDFFileOutStream: OutStream;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeReportPrintToStream(SwissQRBillBuffer, PDFFileTempBlob, Result, IsHandled);
        if IsHandled then
            exit(Result);

        SwissQRBillPrint.SetBuffer(SwissQRBillBuffer);
        PDFFileTempBlob.CreateOutStream(PDFFileOutStream);
        exit(SwissQRBillPrint.SaveAs('', ReportFormat::Pdf, PDFFileOutStream));
    end;

    procedure GenerateImage(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer")
    var
        TempBlob: Codeunit "Temp Blob";
        SwissQRBillImageMgt: Codeunit "Swiss QR-Bill Image Mgt.";
        SwissQRBillEncode: Codeunit "Swiss QR-Bill Encode";
        QRCodeText: Text;
    begin
        QRCodeText := SwissQRBillEncode.GenerateQRCodeText(SwissQRBillBuffer);
        if SwissQRBillImageMgt.GenerateSwissQRCodeImage(QRCodeText, TempBlob) then
            SwissQRBillBuffer.SetQRCodeImage(TempBlob);
    end;

    internal procedure GetCurrency(CurrencyCode: Code[10]): Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if CurrencyCode = '' then
            with GeneralLedgerSetup do begin
                Get();
                exit("LCY Code");
            end;

        exit(CurrencyCode);
    end;

    procedure AllowedCurrencyCode(CurrencyCode: Code[10]): Boolean
    begin
        if CurrencyCode = '' then
            CurrencyCode := '''''';
        exit(GetAllowedCurrencyCodeFilter().Split('|').Contains(CurrencyCode));
    end;

    internal procedure AllowedISOCurrency(CurrencyText: Text): Boolean
    begin
        exit(CurrencyText in ['CHF', 'EUR']);
    end;

    internal procedure GetAllowedCurrencyCodeFilter() Result: Text
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Currency: Record Currency;
    begin
        GeneralLedgerSetup.Get();
        if AllowedISOCurrency(GeneralLedgerSetup."LCY Code") then
            Result += '''''';

        with Currency do begin
            SetFilter("ISO Code", '%1|%2', 'CHF', 'EUR');
            if FindSet() then
                repeat
                    if Result <> '' then
                        Result += '|';
                    Result += Code;
                until Next() = 0;
        end;
    end;

    internal procedure LookupFilteredSalesInvoices(): Code[20]
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PostedSalesInvoices: Page "Posted Sales Invoices";
    begin
        SalesInvoiceHeader.SetFilter("Currency Code", GetAllowedCurrencyCodeFilter());
        PostedSalesInvoices.LookupMode(true);
        PostedSalesInvoices.SetTableView(SalesInvoiceHeader);
        if PostedSalesInvoices.RunModal() = Action::LookupOK then begin
            PostedSalesInvoices.GetRecord(SalesInvoiceHeader);
            exit(SalesInvoiceHeader."No.");
        end;
    end;

    internal procedure LookupFilteredServiceInvoices(): Code[20]
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        PostedServiceInvoices: Page "Posted Service Invoices";
    begin
        ServiceInvoiceHeader.SetFilter("Currency Code", GetAllowedCurrencyCodeFilter());
        PostedServiceInvoices.LookupMode(true);
        PostedServiceInvoices.SetTableView(ServiceInvoiceHeader);
        if PostedServiceInvoices.RunModal() = Action::LookupOK then begin
            PostedServiceInvoices.GetRecord(ServiceInvoiceHeader);
            exit(ServiceInvoiceHeader."No.");
        end;
    end;

    internal procedure LookupFilteredReminders(): Code[20]
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedReminderList: Page "Issued Reminder List";
    begin
        IssuedReminderHeader.SetFilter("Currency Code", GetAllowedCurrencyCodeFilter());
        IssuedReminderList.LookupMode(true);
        IssuedReminderList.SetTableView(IssuedReminderHeader);
        if IssuedReminderList.RunModal() = Action::LookupOK then begin
            IssuedReminderList.GetRecord(IssuedReminderHeader);
            exit(IssuedReminderHeader."No.");
        end;
    end;

    internal procedure LookupFilteredFinChargeMemos(): Code[20]
    var
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        IssuedFinChargeMemoList: Page "Issued Fin. Charge Memo List";
    begin
        IssuedFinChargeMemoHeader.SetFilter("Currency Code", GetAllowedCurrencyCodeFilter());
        IssuedFinChargeMemoList.LookupMode(true);
        IssuedFinChargeMemoList.SetTableView(IssuedFinChargeMemoHeader);
        if IssuedFinChargeMemoList.RunModal() = Action::LookupOK then begin
            IssuedFinChargeMemoList.GetRecord(IssuedFinChargeMemoHeader);
            exit(IssuedFinChargeMemoHeader."No.");
        end;
    end;

    internal procedure LookupFilteredCustLedgerEntries(): Integer
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustomerLedgerEntries: Page "Customer Ledger Entries";
        DocumentType: Enum "Gen. Journal Document Type";
    begin
        CustLedgerEntry.SetFilter(
            "Document Type",
            Format(DocumentType::Invoice) + '|' + Format(DocumentType::Reminder) + '|' + Format(DocumentType::"Finance Charge Memo"));
        CustLedgerEntry.SetFilter("Currency Code", GetAllowedCurrencyCodeFilter());
        CustomerLedgerEntries.LookupMode(true);
        CustomerLedgerEntries.SetTableView(CustLedgerEntry);
        if CustomerLedgerEntries.RunModal() = Action::LookupOK then begin
            CustomerLedgerEntries.GetRecord(CustLedgerEntry);
            exit(CustLedgerEntry."Entry No.");
        end;
    end;

    internal procedure GetNextReferenceNo(ReferenceType: Enum "Swiss QR-Bill Payment Reference Type"; UpdateLastUsed: Boolean) Result: Code[50]
    var
        SwissQRBillSetup: Record "Swiss QR-Bill Setup";
        TempReferenceNo: Text;
    begin
        with SwissQRBillSetup do begin
            Get();
            "Last Used Reference No." += 1;
            if UpdateLastUsed then
                Modify();
        end;

        case ReferenceType of
            ReferenceType::"Creditor Reference (ISO 11649)":
                begin
                    TempReferenceNo := Format(SwissQRBillSetup."Last Used Reference No.");
                    exit(CopyStr('RF' + CalcCheckDigitForCreditorReference(TempReferenceNo) + TempReferenceNo, 1, 25));
                end;
            ReferenceType::"QR Reference":
                begin
                    TempReferenceNo := Format(SwissQRBillSetup."Last Used Reference No.", 0, '<Integer,26><Filler Character,0>');
                    exit(CopyStr(TempReferenceNo + CalcCheckDigitForQRReference(TempReferenceNo), 1, 27));
                end;
        end;
    end;

    local procedure CalcCheckDigitForCreditorReference(SourceReferenceNo: Text): Text[2]
    var
        Module97: Integer;
        CheckDigit: Integer;
    begin
        SourceReferenceNo += 'RF00';
        Module97 := CalcCreditorReferenceModule97(SourceReferenceNo);
        CheckDigit := (98 - Module97) mod 97;
        exit(CopyStr(Format(CheckDigit, 0, '<Integer,2><Filler Character,0>'), 1, 2));
    end;

    local procedure CalcCreditorReferenceModule97(SourceReferenceNo: Text): Integer
    var
        IntegerReferenceNoText: Text;
        i: Integer;
    begin
        for i := 1 to StrLen(SourceReferenceNo) do
            case true of
                (SourceReferenceNo[i] >= '0') and (SourceReferenceNo[i] <= '9'):
                    IntegerReferenceNoText += SourceReferenceNo[i];
                (SourceReferenceNo[i] >= 'a') and (SourceReferenceNo[i] <= 'z'):
                    IntegerReferenceNoText += Format(10 + SourceReferenceNo[i] - 'a');
                (SourceReferenceNo[i] >= 'A') and (SourceReferenceNo[i] <= 'Z'):
                    IntegerReferenceNoText += Format(10 + SourceReferenceNo[i] - 'A');
            end;

        exit(RecursiveModule97(IntegerReferenceNoText));
    end;

    local procedure RecursiveModule97(BigIntegerText: Text): Integer
    var
        LeastMillion: Integer;
    begin
        if StrLen(BigIntegerText) < 7 then begin
            Evaluate(LeastMillion, BigIntegerText);
            exit(LeastMillion mod 97);
        end;

        Evaluate(LeastMillion, CopyStr(BigIntegerText, StrLen(BigIntegerText) - 5, 6));
        exit(((LeastMillion mod 97) + 1000000 * RecursiveModule97(BigIntegerText.Remove(StrLen(BigIntegerText) - 5, 6))) mod 97);
    end;

    local procedure CalcCheckDigitForQRReference(PaymentReference: Text): Text[1]
    var
        BankMgt: Codeunit BankMgt;
    begin
        exit(BankMgt.CalcCheckDigit(CopyStr(PaymentReference, 1, 250)));
    end;

    internal procedure CheckDigitForQRReference(PaymentReference: Text): Boolean
    begin
        PaymentReference := DelChr(PaymentReference);
        exit(CalcCheckDigitForQRReference(CopyStr(PaymentReference, 1, 26)) = PaymentReference[27]);
    end;

    internal procedure CheckDigitForCreditorReference(PaymentReference: Text): Boolean
    begin
        if ('RF' <> CopyStr(PaymentReference, 1, 2)) or (StrLen(PaymentReference) < 5) then
            exit(false);

        PaymentReference := CopyStr(PaymentReference.Remove(1, 4) + CopyStr(PaymentReference, 1, 4), 1, 25);
        exit(CalcCreditorReferenceModule97(PaymentReference) = 1);
    end;

    procedure FormatPaymentReference(ReferenceType: Enum "Swiss QR-Bill Payment Reference Type"; PaymentReference: Code[50]) Result: Code[50]
    begin
        PaymentReference := CopyStr(DelChr(PaymentReference), 1, MaxStrLen(PaymentReference));
        case ReferenceType of
            ReferenceType::"Creditor Reference (ISO 11649)":
                if (StrLen(PaymentReference) > 4) and (StrLen(PaymentReference) < 26) then begin
                    while StrLen(PaymentReference) >= 4 do begin
                        if Result <> '' then
                            Result += ' ' + CopyStr(PaymentReference, 1, 4)
                        else
                            Result := CopyStr(PaymentReference, 1, 4);
                        PaymentReference := DelStr(PaymentReference, 1, 4);
                    end;
                    if StrLen(PaymentReference) > 0 then
                        Result += ' ' + CopyStr(PaymentReference, 1);
                    exit(Result);
                end;
            ReferenceType::"QR Reference":
                if StrLen(PaymentReference) = 27 then
                    exit(
                        CopyStr(PaymentReference, 1, 2) + ' ' +
                        CopyStr(PaymentReference, 3, 5) + ' ' +
                        CopyStr(PaymentReference, 8, 5) + ' ' +
                        CopyStr(PaymentReference, 13, 5) + ' ' +
                        CopyStr(PaymentReference, 18, 5) + ' ' +
                        CopyStr(PaymentReference, 23, 5));
        end;

        exit(PaymentReference);
    end;

    procedure FormatIBAN(IBAN: Code[50]): Code[50]
    begin
        IBAN := CopyStr(DelChr(IBAN), 1, MaxStrLen(IBAN));
        if StrLen(IBAN) = 21 then
            exit(
                CopyStr(
                    CopyStr(IBAN, 1, 4) + ' ' +
                    CopyStr(IBAN, 5, 4) + ' ' +
                    CopyStr(IBAN, 9, 4) + ' ' +
                    CopyStr(IBAN, 13, 4) + ' ' +
                    CopyStr(IBAN, 17, 4) + ' ' +
                    CopyStr(IBAN, 21, 1),
                    1, 50)
            );
        exit(IBAN);
    end;

    procedure AddLineIfNotBlanked(var TargetText: Text; LineText: Text)
    begin
        if LineText <> '' then
            AddLine(TargetText, LineText);
    end;

    procedure AddLine(var TargetText: Text; LineText: Text)
    var
        CRLF: Text[2];
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;

        if TargetText <> '' then
            TargetText += CRLF;
        TargetText += LineText;
    end;

    internal procedure GetLanguageIdENU(): Integer
    begin
        exit(1033); // en-us
    end;

    internal procedure GetLanguageIdDEU(): Integer
    begin
        exit(2055); // de-ch
    end;

    internal procedure GetLanguageIdFRA(): Integer
    begin
        exit(4108); // fr-ch
    end;

    internal procedure GetLanguageIdITA(): Integer
    begin
        exit(2064); // it-ch
    end;

    internal procedure GetLanguagesIdDEU(): Text
    begin
        exit('1031|3079|2055');
    end;

    internal procedure GetLanguagesIdFRA(): Text
    begin
        exit('1036|2060|3084|4108');
    end;

    internal procedure GetLanguagesIdITA(): Text
    begin
        exit('1040|2064');
    end;

    internal procedure GetLanguageCodeENU(): Code[10]
    var
        Language: Codeunit Language;
    begin
        exit(Language.GetLanguageCode(GetLanguageIdENU()));
    end;

    procedure DeleteTenantMedia(MediaId: Guid)
    var
        TenantMedia: Record "Tenant Media";
    begin
        if TenantMedia.Get(MediaId) then
            TenantMedia.Delete();       // Tenant Media Thumbnails are also removed
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SEPA DD-Fill Export Buffer", 'OnBeforeInsertPaymentExportData', '', false, false)]
    local procedure OnBeforeInsertPaymentExportDataForSEPADD(var PaymentExportData: Record "Payment Export Data"; var TempDirectDebitCollectionEntry: Record "Direct Debit Collection Entry")
    begin
        TempDirectDebitCollectionEntry.CalcFields("Payment Reference");
        if TempDirectDebitCollectionEntry."Payment Reference" <> '' then
            PaymentExportData."Message to Recipient 1" :=
                CopyStr(
                    TempDirectDebitCollectionEntry."Applies-to Entry Description" + '; ' +
                    TempDirectDebitCollectionEntry."Payment Reference",
                    1, MaxStrLen(PaymentExportData."Message to Recipient 1"));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReportPrintToStream(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer"; var PDFFileTempBlob: Codeunit "Temp Blob"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
}
