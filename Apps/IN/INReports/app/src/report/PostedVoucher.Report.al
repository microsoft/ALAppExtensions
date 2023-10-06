// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Bank.VoucherInterface;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GST.Base;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using System.Utilities;

report 18041 "Posted Voucher"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/PostedVoucher.rdl';
    Caption = 'Posted Voucher';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem("G/L Entry"; "G/L Entry")
        {
            DataItemTableView = sorting("Document No.", "Posting Date")
                                order(descending);
            RequestFilterFields = "Posting Date", "Document No.";

            column(VoucherSourceDesc; SourceDesc)
            {
            }
            column(DocumentNo_GLEntry; "Document No.")
            {
            }
            column(PostingDateFormatted; DateLbl + FORMAT("Posting Date"))
            {
            }
            column(CompanyInformationAddress; CompanyInformation.Address + ' ' + CompanyInformation."Address 2" + '  ' + CompanyInformation.City)
            {
            }
            column(CompanyInformationName; CompanyInformation.Name)
            {
            }
            column(CreditAmount_GLEntry; "Credit Amount")
            {
            }
            column(DebitAmount_GLEntry; "Debit Amount")
            {
            }
            column(DrText; DrText)
            {
            }
            column(GLAccName; GLAccName)
            {
            }
            column(CrText; CrText)
            {
            }
            column(DebitAmountTotal; DebitAmountTotal)
            {
            }
            column(CreditAmountTotal; CreditAmountTotal)
            {
            }
            column(ChequeDetail; ChequeNoLbl + ChequeNo + DatedLbl + FORMAT(ChequeDate))
            {
            }
            column(ChequeNo; ChequeNo)
            {
            }
            column(ChequeDate; ChequeDate)
            {
            }
            column(RsNumberText1NumberText2; RsLbl + NumberText[1] + ' ' + NumberText[2])
            {
            }
            column(EntryNo_GLEntry; "Entry No.")
            {
            }
            column(PostingDate_GLEntry; "Posting Date")
            {
            }
            column(TransactionNo_GLEntry; "Transaction No.")
            {
            }
            column(VoucherNoCaption; VoucherNoCaptionLbl)
            {
            }
            column(CreditAmountCaption; CreditAmountCaptionLbl)
            {
            }
            column(DebitAmountCaption; DebitAmountCaptionLbl)
            {
            }
            column(ParticularsCaption; ParticularsCaptionLbl)
            {
            }
            column(AmountInWordsCaption; AmountInWordsCaptionLbl)
            {
            }
            column(PreparedByCaption; PreparedByCaptionLbl)
            {
            }
            column(CheckedByCaption; CheckedByCaptionLbl)
            {
            }
            column(ApprovedByCaption; ApprovedByCaptionLbl)
            {
            }
            dataitem(LineNarration; "Posted Narration")
            {
                DataItemLink = "Transaction No." = field("Transaction No."),
                               "Entry No." = field("Entry No.");
                DataItemTableView = sorting("Entry No.", "Transaction No.", "Line No.");

                column(Narration_LineNarration; Narration)
                {
                }
                column(PrintLineNarration; PrintLineNarration)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if PrintLineNarration then begin
                        PageLoop := PageLoop - 1;
                        LinesPrinted := LinesPrinted + 1;
                    end;
                end;
            }
            dataitem(Integer; Integer)
            {
                DataItemTableView = sorting(Number);

                column(IntegerOccurcesCaption; IntegerOccurcesCaptionLbl)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    PageLoop := PageLoop - 1;
                end;

                trigger OnPreDataItem()
                begin
                    GLEntry.SetCurrentKey("Document No.", "Posting Date", Amount);
                    GLEntry.Ascending(false);
                    GLEntry.SetRange("Posting Date", "G/L Entry"."Posting Date");
                    GLEntry.SetRange("Document No.", "G/L Entry"."Document No.");
                    GLEntry.FindLast();
                    if not (GLEntry."Entry No." = "G/L Entry"."Entry No.") then
                        CurrReport.Break();

                    SetRange(Number, 1, PageLoop)
                end;
            }
            dataitem(PostedNarration1; "Posted Narration")
            {
                DataItemLink = "Transaction No." = field("Transaction No.");
                DataItemTableView = sorting("Entry No.", "Transaction No.", "Line No.")
                                    where("Entry No." = filter(0));

                column(Narration_PostedNarration1; Narration)
                {
                }
                column(NarrationCaption; NarrationCaptionLbl)
                {
                }

                trigger OnPreDataItem()
                begin
                    GLEntry.SetCurrentKey("Document No.", "Posting Date", Amount);
                    GLEntry.Ascending(false);
                    GLEntry.SetRange("Posting Date", "G/L Entry"."Posting Date");
                    GLEntry.SetRange("Document No.", "G/L Entry"."Document No.");
                    GLEntry.FindLast();
                    if not (GLEntry."Entry No." = "G/L Entry"."Entry No.") then
                        CurrReport.Break();
                end;
            }

            trigger OnAfterGetRecord()
            var
                BankAccLedgEntry: Record "Bank Account Ledger Entry";
            begin
                GLAccName := FindGLAccName("Source Type", "Entry No.", "Source No.", "G/L Account No.");

                if Amount < 0 then begin
                    CrText := ToLbl;
                    DrText := '';
                end else begin
                    CrText := '';
                    DrText := DrLbl;
                end;

                SourceDesc := '';
                if "G/L Entry"."Source Code" <> '' then begin
                    SourceCode.Get("G/L Entry"."Source Code");
                    SourceDesc := SourceCode.Description;
                end;

                PageLoop := PageLoop - 1;
                LinesPrinted := LinesPrinted + 1;
                if (ChequeNo <> '') and (ChequeDate <> 0D) then begin
                    PageLoop := PageLoop - 1;
                    LinesPrinted := LinesPrinted + 1;
                end;

                ChequeNo := '';
                ChequeDate := 0D;
                if ("Source No." <> '') and ("Source Type" = "Source Type"::"Bank Account") then
                    if BankAccLedgEntry.Get("Entry No.") then begin
                        ChequeNo := BankAccLedgEntry."Cheque No.";
                        ChequeDate := BankAccLedgEntry."Cheque Date";
                    end;

                if PostingDate <> "Posting Date" then begin
                    PostingDate := "Posting Date";
                    TotalDebitAmt := 0;
                end;

                if DocumentNo <> "Document No." then begin
                    DocumentNo := "Document No.";
                    TotalDebitAmt := 0;
                end;

                if PostingDate = "Posting Date" then begin
                    InitTextVariable();
                    TotalDebitAmt += "Debit Amount";
                    FormatNoText(NumberText, Abs(TotalDebitAmt), '');
                    PageLoop := NUMLines;
                    LinesPrinted := 0;
                end;

                if (PrePostingDate <> "Posting Date") or (PreDocumentNo <> "Document No.") then begin
                    DebitAmountTotal := 0;
                    CreditAmountTotal := 0;
                    PrePostingDate := "Posting Date";
                    PreDocumentNo := "Document No.";
                end;

                DebitAmountTotal := DebitAmountTotal + "Debit Amount";
                CreditAmountTotal := CreditAmountTotal + "Credit Amount";
            end;

            trigger OnPreDataItem()
            begin
                NUMLines := 13;
                PageLoop := NUMLines;
                LinesPrinted := 0;
                DebitAmountTotal := 0;
                CreditAmountTotal := 0;
                SetCurrentKey("Document No.", "Posting Date", Amount);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PrintLineNarration1; PrintLineNarration)
                    {
                        Caption = 'PrintLineNarration';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Place a check mark in this field if line narration is to be printed.';
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        CompanyInformation.Get();
    end;

    var
        CompanyInformation: Record "Company Information";
        SourceCode: Record "Source Code";
        GLEntry: Record "G/L Entry";
        GLAccName: Text[100];
        SourceDesc: Text[100];
        CrText: Text[2];
        DrText: Text[2];
        NumberText: array[2] of Text[80];
        PageLoop: Integer;
        LinesPrinted: Integer;
        NUMLines: Integer;
        ChequeNo: Code[50];
        ChequeDate: Date;
        OnesText: array[20] of Text[30];
        TensText: array[10] of Text[30];
        ExponentText: array[5] of Text[30];
        PrintLineNarration: Boolean;
        PostingDate: Date;
        TotalDebitAmt: Decimal;
        DocumentNo: Code[20];
        DebitAmountTotal: Decimal;
        CreditAmountTotal: Decimal;
        PrePostingDate: Date;
        PreDocumentNo: Code[50];
        ZeroLbl: Label 'ZERO';
        OnlyLbl: Label 'ONLY';
        DrLbl: Label 'Dr';
        ToLbl: Label 'To';
        RupeesLbl: Label 'RUPEES';
        PaisaOnlyLbl: Label ' PAISA ONLY';
        DatedLbl: Label '  Dated: ';
        RsLbl: Label 'Rs. ';
        ChequeNoLbl: Label 'Cheque No: ';
        DateLbl: Label 'Date: ';
        HundreadLbl: Label 'HUNDRED';
        AndLbl: Label 'AND';
        ExceededStringErr: Label '%1 results in a written number that is too long.', Comment = '%1= AddText';
        OneLbl: Label 'ONE';
        TwoLbl: Label 'TWO';
        ThreeLbl: Label 'THREE';
        FourLbl: Label 'FOUR';
        FiveLbl: Label 'FIVE';
        SixLbl: Label 'SIX';
        SevenLbl: Label 'SEVEN';
        EightLbl: Label 'EIGHT';
        NineLbl: Label 'NINE';
        TenLbl: Label 'TEN';
        ElevenLbl: Label 'ELEVEN';
        TwelveLbl: Label 'TWELVE';
        ThireentLbl: Label 'THIRTEEN';
        FourteenLbl: Label 'FOURTEEN';
        FifteenLbl: Label 'FIFTEEN';
        SixteenLbl: Label 'SIXTEEN';
        SeventeenLbl: Label 'SEVENTEEN';
        EighteenLbl: Label 'EIGHTEEN';
        NinteenLbl: Label 'NINETEEN';
        TwentyLbl: Label 'TWENTY';
        ThirtyLbl: Label 'THIRTY';
        FortyLbl: Label 'FORTY';
        FiftyLbl: Label 'FIFTY';
        SixtyLbl: Label 'SIXTY';
        SeventyLbl: Label 'SEVENTY';
        EightyLbl: Label 'EIGHTY';
        NinetyLbl: Label 'NINETY';
        ThousandLbl: Label 'THOUSAND';
        LakhLbl: Label 'LAKH';
        CroreLbl: Label 'CRORE';
        VoucherNoCaptionLbl: Label 'Voucher No. :';
        CreditAmountCaptionLbl: Label 'Credit Amount';
        DebitAmountCaptionLbl: Label 'Debit Amount';
        ParticularsCaptionLbl: Label 'Particulars';
        AmountInWordsCaptionLbl: Label 'Amount (in words):';
        PreparedByCaptionLbl: Label 'Prepared by:';
        CheckedByCaptionLbl: Label 'Checked by:';
        ApprovedByCaptionLbl: Label 'Approved by:';
        IntegerOccurcesCaptionLbl: Label 'IntegerOccurces';
        NarrationCaptionLbl: Label 'Narration :';

    procedure FindGLAccName(
        "Source Type": Enum "Gen. Journal Source Type";
        "Entry No.": Integer;
        "Source No.": Code[20];
        "G/L Account No.": Code[20]): Text[100]
    var
        GLAccount: Record "G/L Account";
        Vendor: Record "Vendor";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        BankAccount: Record "Bank Account";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        AccName: Text[100];
    begin
        case "Source Type" of
            "Source Type"::Vendor:
                if VendorLedgerEntry.Get("Entry No.") then
                    if IsGSTDocument(VendorLedgerEntry."Document Type", VendorLedgerEntry."Document No.") then begin
                        if Vendor.Get("Source No.") then
                            AccName := Vendor.Name
                        else begin
                            GLAccount.Get("G/L Account No.");
                            AccName := GLAccount.Name;
                        end;
                    end else begin
                        Vendor.Get("Source No.");
                        AccName := Vendor.Name;
                    end
                else begin
                    GLAccount.Get("G/L Account No.");
                    AccName := GLAccount.Name;
                end;
            "Source Type"::Customer:
                if CustLedgerEntry.Get("Entry No.") then
                    if IsGSTDocument(CustLedgerEntry."Document Type", CustLedgerEntry."Document No.") then begin
                        if Customer.Get("Source No.") then
                            AccName := Customer.Name
                        else begin
                            GLAccount.Get("G/L Account No.");
                            AccName := GLAccount.Name;
                        end;
                    end else begin
                        Customer.Get("Source No.");
                        AccName := Customer.Name;
                    end
                else begin
                    GLAccount.Get("G/L Account No.");
                    AccName := GLAccount.Name;
                end;
            "Source Type"::"Bank Account":
                if BankAccountLedgerEntry.Get("Entry No.") then begin
                    BankAccount.Get("Source No.");
                    AccName := BankAccount.Name;
                end else begin
                    GLAccount.Get("G/L Account No.");
                    AccName := GLAccount.Name;
                end
            else begin
                GLAccount.Get("G/L Account No.");
                AccName := GLAccount.Name;
            end;
                GLAccount.Get("G/L Account No.");
                AccName := GLAccount.Name;
        end;

        exit(AccName);

    end;

    procedure FormatNoText(var NoText: array[2] of Text[80]; No: Decimal; CurrencyCode: Code[10])
    var
        Currency: Record Currency;
        PrintExponent: Boolean;
        NoTextIndex: Integer;
        TensDec: Integer;
        OnesDec: Integer;
        Ones: Integer;
        Tens: Integer;
        Hundreds: Integer;
        Exponent: Integer;
    begin
        Clear(NoText);
        NoTextIndex := 1;
        NoText[1] := '';

        if No < 1 then
            AddToNoText(NoText, NoTextIndex, PrintExponent, ZeroLbl)
        else
            for Exponent := 4 DOWNTO 1 do begin
                PrintExponent := false;
                if No > 99999 then begin
                    Ones := No DIV (Power(100, Exponent - 1) * 10);
                    Hundreds := 0;
                end else begin
                    Ones := No DIV Power(1000, Exponent - 1);
                    Hundreds := Ones DIV 100;
                end;
                Tens := (Ones MOD 100) DIV 10;
                Ones := Ones MOD 10;
                if Hundreds > 0 then begin
                    AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Hundreds]);
                    AddToNoText(NoText, NoTextIndex, PrintExponent, HundreadLbl);
                end;
                if Tens >= 2 then begin
                    AddToNoText(NoText, NoTextIndex, PrintExponent, TensText[Tens]);
                    if Ones > 0 then
                        AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Ones]);
                end else
                    if (Tens * 10 + Ones) > 0 then
                        AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Tens * 10 + Ones]);
                if PrintExponent and (Exponent > 1) then
                    AddToNoText(NoText, NoTextIndex, PrintExponent, ExponentText[Exponent]);
                if No > 99999 then
                    No := No - (Hundreds * 100 + Tens * 10 + Ones) * Power(100, Exponent - 1) * 10
                else
                    No := No - (Hundreds * 100 + Tens * 10 + Ones) * Power(1000, Exponent - 1);
            end;

        if CurrencyCode <> '' then begin
            Currency.Get(CurrencyCode);
            AddToNoText(NoText, NoTextIndex, PrintExponent, ' ');
        end else
            AddToNoText(NoText, NoTextIndex, PrintExponent, RupeesLbl);

        AddToNoText(NoText, NoTextIndex, PrintExponent, AndLbl);

        TensDec := ((No * 100) MOD 100) DIV 10;
        OnesDec := (No * 100) MOD 10;
        if TensDec >= 2 then begin
            AddToNoText(NoText, NoTextIndex, PrintExponent, TensText[TensDec]);
            if OnesDec > 0 then
                AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[OnesDec]);
        end else
            if (TensDec * 10 + OnesDec) > 0 then
                AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[TensDec * 10 + OnesDec])
            else
                AddToNoText(NoText, NoTextIndex, PrintExponent, ZeroLbl);
        if (CurrencyCode <> '') then
            AddToNoText(NoText, NoTextIndex, PrintExponent, OnlyLbl)
        else
            AddToNoText(NoText, NoTextIndex, PrintExponent, PaisaOnlyLbl);
    end;

    procedure InitTextVariable()
    begin
        OnesText[1] := OneLbl;
        OnesText[2] := TwoLbl;
        OnesText[3] := ThreeLbl;
        OnesText[4] := FourLbl;
        OnesText[5] := FiveLbl;
        OnesText[6] := SixLbl;
        OnesText[7] := SevenLbl;
        OnesText[8] := EightLbl;
        OnesText[9] := NineLbl;
        OnesText[10] := TenLbl;
        OnesText[11] := ElevenLbl;
        OnesText[12] := TwelveLbl;
        OnesText[13] := ThireentLbl;
        OnesText[14] := FourteenLbl;
        OnesText[15] := FifteenLbl;
        OnesText[16] := SixteenLbl;
        OnesText[17] := SeventeenLbl;
        OnesText[18] := EighteenLbl;
        OnesText[19] := NinteenLbl;

        TensText[1] := '';
        TensText[2] := TwentyLbl;
        TensText[3] := ThirtyLbl;
        TensText[4] := FortyLbl;
        TensText[5] := FiftyLbl;
        TensText[6] := SixtyLbl;
        TensText[7] := SeventyLbl;
        TensText[8] := EightyLbl;
        TensText[9] := NinetyLbl;

        ExponentText[1] := '';
        ExponentText[2] := ThousandLbl;
        ExponentText[3] := LakhLbl;
        ExponentText[4] := CroreLbl;
    end;

    local procedure AddToNoText(
        var NoText: array[2] of Text[80];
        var NoTextIndex: Integer;
        var PrintExponent: Boolean;
        AddText: Text[30])
    begin
        PrintExponent := true;

        while StrLen(NoText[NoTextIndex] + ' ' + AddText) > MaxStrLen(NoText[1]) do begin
            NoTextIndex := NoTextIndex + 1;
            if NoTextIndex > ArrayLen(NoText) then
                Error(exceededStringErr, AddText);
        end;
        NoText[NoTextIndex] := DelChr(NoText[NoTextIndex] + ' ' + AddText, '<');
    end;

    local procedure IsGSTDocument(DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]): Boolean
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
        if DetailedGSTLedgerEntry.FindFirst() then
            exit(true);
        DetailedGSTLedgerEntry.SetRange("Document No.");
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::Application);
        DetailedGSTLedgerEntry.SetRange("Application Doc. Type", GetApplicationDocType(DocumentType));
        DetailedGSTLedgerEntry.SetRange("Application Doc. No", DocumentNo);
        if not DetailedGSTLedgerEntry.IsEmpty then
            exit(true);
        exit(false);
    end;

    local procedure GetApplicationDocType(DocumentType: Enum "Gen. Journal Document Type"): Enum "Application Doc Type"
    var
        ApplicationDocType: Enum "Application Doc Type";
    begin
        case DocumentType of
            DocumentType::Invoice:
                exit(ApplicationDocType::Invoice);
            DocumentType::"Credit Memo":
                exit(ApplicationDocType::"Credit Memo");
            DocumentType::"Finance Charge Memo":
                exit(ApplicationDocType::"Finance Charge Memo");
            DocumentType::Refund:
                exit(ApplicationDocType::Refund);
            DocumentType::Payment:
                exit(ApplicationDocType::Payment);
            DocumentType::" ":
                exit(ApplicationDocType::" ")
        end;
    end;
}
