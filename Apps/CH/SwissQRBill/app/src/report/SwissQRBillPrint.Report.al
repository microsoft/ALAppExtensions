// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Customer;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Reminder;
using Microsoft.Service.History;
using System.Globalization;

report 11510 "Swiss QR-Bill Print"
{
    Caption = 'Swiss QR-Bill';
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Print.rdlc';

    dataset
    {
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
            DataItemTableView = sorting("No.");

            trigger OnPreDataItem()
            begin
                if BufferIsSet or (GetFilters() = '') then
                    CurrReport.Break();
                FilteredCount += Count();
            end;

            trigger OnAfterGetRecord()
            var
                TempSwissQRBillBuffer: Record "Swiss QR-Bill Buffer" temporary;
                RecRef: RecordRef;
            begin
                if SwissQRBillMgt.AllowedCurrencyCode("Currency Code") then begin
                    RecRef.GetTable(SalesInvoiceHeader);
                    TempSwissQRBillBuffer.InitSourceRecord(RecRef);
                    TempSwissQRBillBuffer.InitBuffer('');
                    TempSwissQRBillBuffer.SetSourceRecord("Cust. Ledger Entry No.");
                    SwissQRBillBuffer.AddBufferRecord(TempSwissQRBillBuffer);
                end;
            end;
        }

        dataitem(ServiceInvoiceHeader; "Service Invoice Header")
        {
            DataItemTableView = sorting("No.");

            trigger OnPreDataItem()
            begin
                if BufferIsSet or (GetFilters() = '') then
                    CurrReport.Break();
                FilteredCount += Count();
            end;

            trigger OnAfterGetRecord()
            var
                TempSwissQRBillBuffer: Record "Swiss QR-Bill Buffer" temporary;
                RecRef: RecordRef;
                LedgerEntryNo: Integer;
            begin
                if SwissQRBillMgt.AllowedCurrencyCode("Currency Code") then
                    if SwissQRBillMgt.FindCustLedgerEntry(
                           LedgerEntryNo, "Bill-to Customer No.", DocumentType::Invoice, "No.", "Posting Date")
                    then begin
                        RecRef.GetTable(ServiceInvoiceHeader);
                        TempSwissQRBillBuffer.InitSourceRecord(RecRef);
                        TempSwissQRBillBuffer.InitBuffer('');
                        TempSwissQRBillBuffer.SetSourceRecord(LedgerEntryNo);
                        SwissQRBillBuffer.AddBufferRecord(TempSwissQRBillBuffer);
                    end;
            end;
        }

        dataitem(IssuedReminderHeader; "Issued Reminder Header")
        {
            DataItemTableView = sorting("No.");

            trigger OnPreDataItem()
            begin
                if BufferIsSet or (GetFilters() = '') then
                    CurrReport.Break();
                FilteredCount += Count();
            end;

            trigger OnAfterGetRecord()
            var
                CustLedgerEntry: Record "Cust. Ledger Entry";
            begin
                if SwissQRBillMgt.AllowedCurrencyCode("Currency Code") then begin
                    SwissQRBillMgt.FilterCustLedgerEntry(
                        CustLedgerEntry, "Customer No.", DocumentType::Reminder, "No.", "Posting Date");
                    SetBufferFromReminders(CustLedgerEntry);
                end;
            end;
        }

        dataitem(IssuedFinChargeMemoHeader; "Issued Fin. Charge Memo Header")
        {
            DataItemTableView = sorting("No.");

            trigger OnPreDataItem()
            begin
                if BufferIsSet or (GetFilters() = '') then
                    CurrReport.Break();
                FilteredCount += Count();
            end;

            trigger OnAfterGetRecord()
            var
                CustLedgerEntry: Record "Cust. Ledger Entry";
            begin
                if SwissQRBillMgt.AllowedCurrencyCode("Currency Code") then begin
                    SwissQRBillMgt.FilterCustLedgerEntry(
                        CustLedgerEntry, "Customer No.", DocumentType::"Finance Charge Memo", "No.", "Posting Date");
                    SetBufferFromReminders(CustLedgerEntry);
                end;
            end;
        }

        dataitem(SwissQRBillBuffer; "Swiss QR-Bill Buffer")
        {
            DataItemTableView = sorting("Entry No.");
            UseTemporary = true;

            column(PaymentPartLbl; PaymentPartLbl) { }
            column(AccountPayableToLbl; AccountPayableToLbl) { }
            column(ReferenceLbl; ReferenceLbl) { }
            column(AdditionalInformationLbl; AdditionalInformationLbl) { }
            column(CurrencyLbl; CurrencyLbl) { }
            column(AmountLbl; AmountLbl) { }
            column(ReceiptLbl; ReceiptLbl) { }
            column(AcceptancePointLbl; AcceptancePointLbl) { }
            column(PayableByLbl; PayableByLbl) { }
            column(PayableByNameAddressLbl; PayableByNameAddressLbl) { }
            column(AltProcName1Lbl; "Alt. Procedure Name 1") { }
            column(AltProcName2Lbl; "Alt. Procedure Name 2") { }
            column(SeparateLbl; SeparateLbl) { }

            column(QRImage; "QR-Code Image") { }
            column(AccountPayableToText; AccountPayableTo) { }
            column(ReferenceText; PaymentReferenceNoText) { }
            column(PayableByText; PayableBy) { }
            column(AdditionalInformationText; AddInformationText) { }
            column(CurrencyText; Currency) { }
            column(AmountText; AmountText) { }
            column(AltProcValue1Text; "Alt. Procedure Value 1") { }
            column(AltProcValue2Text; "Alt. Procedure Value 2") { }

            trigger OnPreDataItem()
            begin
                PrintedCount := Count();
                if PrintedCount > 0 then
                    if FindSet() then;
            end;

            trigger OnAfterGetRecord()
            var
                Language: Codeunit Language;
            begin
                CurrReport.Language := Language.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := Language.GetFormatRegionOrDefault("Format Region");
                PrepareForPrint();
                SwissQRBillMgt.GenerateImage(SwissQRBillBuffer);
                AccountPayableTo := ReportAccountPayableToInfo(SwissQRBillBuffer);
                PayableBy := ReportAccountPayableByInfo(SwissQRBillBuffer);
                AmountText := FormatAmount(Amount);
                PaymentReferenceNoText := SwissQRBillMgt.FormatPaymentReference("Payment Reference Type", "Payment Reference");
                AddInformationText := ReportAddInformationInfo(SwissQRBillBuffer);
                SwissQRBillBuffer.Modify();
            end;
        }
    }

    var
        SwissQRBillMgt: Codeunit "Swiss QR-Bill Mgt.";
        DocumentType: Enum "Gen. Journal Document Type";
        AccountPayableTo: Text;
        PayableBy: Text;
        AddInformationText: Text;
        AmountText: Text;
        PaymentReferenceNoText: Text;
        PrintedCount: Integer;
        FilteredCount: Integer;
        BufferIsSet: Boolean;
        PaymentPartLbl: Label 'Payment part';
        AccountPayableToLbl: Label 'Account / Payable to';
        ReferenceLbl: Label 'Reference';
        AdditionalInformationLbl: Label 'Additional information';
        CurrencyLbl: Label 'Currency';
        AmountLbl: Label 'Amount';
        ReceiptLbl: Label 'Receipt';
        AcceptancePointLbl: Label 'Acceptance point';
        PayableByLbl: Label 'Payable by';
        PayableByNameAddressLbl: Label 'Payable by (name/address)';
        SeparateLbl: Label 'Separate before paying in';
        BlankedOutputErr: Label 'There is no document found to print QR-Bill with the specified filters. Only CHF and EUR currency is allowed.';
        NotAllPrintedMsg: Label 'Not all documents were printed QR-Bill with the specified filters. Only CHF and EUR currency is allowed.';

    trigger OnPostReport()
    begin
        if SwissQRBillBuffer.FindSet() then
            repeat
                SwissQRBillMgt.DeleteTenantMedia(SwissQRBillBuffer."QR-Code Image".MediaId);
            until SwissQRBillBuffer.Next() = 0;

        if (PrintedCount = 0) and GuiAllowed() then
            Error(BlankedOutputErr);

        if (PrintedCount < FilteredCount) and GuiAllowed() then
            Message(NotAllPrintedMsg);
    end;

    internal procedure SetBuffer(var SourceSwissQRBillBuffer: Record "Swiss QR-Bill Buffer" temporary)
    begin
        if SourceSwissQRBillBuffer.FindSet() then
            repeat
                SwissQRBillBuffer.AddBufferRecord(SourceSwissQRBillBuffer);
            until SourceSwissQRBillBuffer.Next() = 0;

        FilteredCount := SourceSwissQRBillBuffer.Count();
        BufferIsSet := true;
    end;

    local procedure SetBufferFromReminders(var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        TempSwissQRBillBuffer: Record "Swiss QR-Bill Buffer" temporary;
    begin
        if CustLedgerEntry.FindSet() then
            repeat
                TempSwissQRBillBuffer.InitBuffer('');
                TempSwissQRBillBuffer.SetSourceRecord(CustLedgerEntry."Entry No.");
                SwissQRBillBuffer.AddBufferRecord(TempSwissQRBillBuffer);
            until CustLedgerEntry.Next() = 0;
    end;

    local procedure ReportAccountPayableToInfo(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer") Result: Text
    var
        TempCustomer: Record Customer temporary;
    begin
        Result := SwissQRBillMgt.FormatIBAN(SwissQRBillBuffer.IBAN);
        if SwissQRBillBuffer.GetCreditorInfo(TempCustomer) then
            SwissQRBillMgt.AddLine(Result, ReportFormatCustomerPartyInfo(TempCustomer));
    end;

    local procedure ReportAccountPayableByInfo(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer"): Text
    var
        TempCustomer: Record Customer temporary;
    begin
        if SwissQRBillBuffer.GetUltimateDebitorInfo(TempCustomer) then
            exit(ReportFormatCustomerPartyInfo(TempCustomer));
    end;

    local procedure ReportFormatCustomerPartyInfo(Customer: Record Customer) Result: Text
    begin
        with Customer do begin
            SwissQRBillMgt.AddLineIfNotBlanked(Result, CopyStr(Name, 1, 70));
            SwissQRBillMgt.AddLineIfNotBlanked(Result, CopyStr(Address + ' ' + "Address 2", 1, 70));
            SwissQRBillMgt.AddLineIfNotBlanked(Result, CopyStr("Post Code" + ' ' + City, 1, 70));
        end;
    end;

    local procedure ReportAddInformationInfo(SwissQRBillBuffer: Record "Swiss QR-Bill Buffer") Result: Text
    var
        BillingInfo: Text;
    begin
        SwissQRBillBuffer.CheckLimitForUnstrAndBillInfoText();
        BillingInfo := SwissQRBillBuffer."Billing Information";
        Result := SwissQRBillBuffer."Unstructured Message";
        if (Result <> '') and (StrLen(BillingInfo) > 45) then
            Result += ' ' + BillingInfo
        else
            SwissQRBillMgt.AddLineIfNotBlanked(Result, BillingInfo);
    end;

    local procedure FormatAmount(Amount: Decimal): Text
    begin
        if Amount = 0 then
            exit('');
        exit(Format(Round(Amount, 0.01), 0, '<Sign><Integer Thousand><1000Character, ><Decimals,3><Comma,.><Filler Character,0>'));
    end;
}
