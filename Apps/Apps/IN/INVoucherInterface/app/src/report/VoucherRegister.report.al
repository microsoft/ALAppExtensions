// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using System.Utilities;

report 18933 "Voucher Register"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/rdlc/VoucherRegister.rdl';
    Caption = 'Voucher Register';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("G/L Register"; "G/L Register")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";

            column(No_GLReg; "No.")
            {
            }
            dataitem("G/L Entry"; "G/L Entry")
            {
                DataItemTableView = sorting("Document No.", "Posting Date", Amount)
                                    order(descending);

                column(VoucherSourceDesc; SourceDesc + VoucherLbl)
                {
                }
                column(DocumentNo_GLEntry; "Document No.")
                {
                }
                column(PostingDateFormatted; DateLbl + Format("Posting Date"))
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
                column(ChequeNoDateFormatted; ChequeNoLbl + ChequeNo + DatedLbl + Format(ChequeDate))
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
                column(AmountinwordsCaption; AmountinwordsCaptionLbl)
                {
                }
                column(PreparedbyCaption; PreparedbyCaptionLbl)
                {
                }
                column(CheckedbyCaption; CheckedbyCaptionLbl)
                {
                }
                column(ApprovedbyCaption; ApprovedbyCaptionLbl)
                {
                }
                dataitem(PostedNarration; "Posted Narration")
                {
                    DataItemLink = "Transaction No." = field("Transaction No."), "Entry No." = field("Entry No.");
                    DataItemTableView = sorting("Entry No.", "Transaction No.", "Line No.")
                                         order(ascending);

                    column(Narration_LineNarration; Narration)
                    {
                    }
                    column(PrintLineNarration; PrintLineNarration)
                    {
                    }
                }
                dataitem(DataItem5444; Integer)
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
                        GLEntry.SetRange(GLEntry."Posting Date", "G/L Entry"."Posting Date");
                        GLEntry.SetRange(GLEntry."Document No.", "G/L Entry"."Document No.");
                        GLEntry.SetRange(GLEntry."Entry No.", "G/L Register"."From Entry No.", "G/L Register"."To Entry No.");
                        if GLEntry.FindLast() then
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

                    column(Narration_PostedNarration; Narration)
                    {
                    }
                    column(NarrationCaption; NarrationCaptionLbl)
                    {
                    }
                    trigger OnPreDataItem()
                    begin
                        GLEntry.SetCurrentKey("Document No.", "Posting Date", Amount);
                        GLEntry.Ascending(false);
                        GLEntry.SetRange(GLEntry."Posting Date", "G/L Entry"."Posting Date");
                        GLEntry.SetRange(GLEntry."Document No.", "G/L Entry"."Document No.");
                        GLEntry.SetRange(GLEntry."Entry No.", "G/L Register"."From Entry No.", "G/L Register"."To Entry No.");
                        GLEntry.FindLast();
                        if not (GLEntry."Entry No." = "G/L Entry"."Entry No.") then
                            CurrReport.Break();
                    end;
                }
                trigger OnAfterGetRecord()
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
                    if "Source Code" <> '' then begin
                        SourceCode.Get("Source Code");
                        SourceDesc := CopyStr(SourceCode.Description, 1, MaxStrLen(SourceDesc));
                    end;

                    PageLoop := PageLoop - 1;
                    LinesPrinted := LinesPrinted + 1;

                    ChequeNo := '';
                    ChequeDate := 0D;
                    if ("Source No." <> '') and ("Source Type" = "Source Type"::"Bank Account") then
                        if BankAccLedgEntry.Get("Entry No.") then begin
                            ChequeNo := BankAccLedgEntry."Cheque No.";
                            ChequeDate := BankAccLedgEntry."Cheque Date";
                        end;

                    PrintBody5 := (ChequeNo <> '') and (ChequeDate <> 0D);
                    if PrintBody5 or PrintLineNarration then begin
                        PageLoop := PageLoop - 1;
                        LinesPrinted := LinesPrinted + 1;
                    end;

                    if PostingDate <> "G/L Entry"."Posting Date" then begin
                        PostingDate := "G/L Entry"."Posting Date";
                        TotalDebitAmt := 0;
                    end;
                    if DocumentNo <> "G/L Entry"."Document No." then begin
                        DocumentNo := "G/L Entry"."Document No.";
                        TotalDebitAmt := 0;
                    end;
                    if PostingDate = "G/L Entry"."Posting Date" then begin
                        InitTextVariable();
                        TotalDebitAmt += "G/L Entry"."Debit Amount";
                        FormatNoText(NumberText, Abs(TotalDebitAmt), '');
                        PageLoop := NUMLines;
                        LinesPrinted := 0;
                    end;

                    if (PrePostingDate <> "G/L Entry"."Posting Date") or (PreDocumentNo <> "G/L Entry"."Document No.") then begin
                        DebitAmountTotal := 0;
                        CreditAmountTotal := 0;
                        PrePostingDate := "G/L Entry"."Posting Date";
                        PreDocumentNo := "G/L Entry"."Document No.";
                        PageLoop := NUMLines;
                        LinesPrinted := 0;
                        PageLoop := PageLoop - 1;
                    end;
                    DebitAmountTotal := DebitAmountTotal + "Debit Amount";
                    CreditAmountTotal := CreditAmountTotal + "Credit Amount";

                    LinesPrinted := LinesPrinted + 1;

                    InitTextVariable();
                    FormatNoText(NumberText, Abs(DebitAmountTotal), '');
                end;

                trigger OnPreDataItem()
                begin
                    NUMLines := 13;
                    PageLoop := NUMLines;
                    LinesPrinted := 0;
                    TotalDebitAmt := 0;
                    SetRange("Entry No.", "G/L Register"."From Entry No.", "G/L Register"."To Entry No.");
                    SetCurrentKey("Document No.", "Posting Date", Amount);
                end;
            }
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
                        ToolTip = 'Place a check mark in this field if line narration is to be printed.';
                        ApplicationArea = Basic, Suite;
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
        GLEntry: Record "G/L Entry";
        SourceCode: Record "Source Code";
        BankAccLedgEntry: Record "Bank Account Ledger Entry";
        GLAccName: Text[50];
        SourceDesc: Text[50];
        CrText: Text[2];
        DrText: Text[2];
        NumberText: array[2] of Text[80];
        PageLoop: Integer;
        LinesPrinted: Integer;
        NUMLines: Integer;
        ChequeNo: Code[20];
        ChequeDate: Date;
        OnesText: array[20] of Text[30];
        TensText: array[10] of Text[30];
        ExponentText: array[5] of Text[30];
        PrintLineNarration: Boolean;
        PrePostingDate: Date;
        PreDocumentNo: Code[30];
        DebitAmountTotal: Decimal;
        CreditAmountTotal: Decimal;
        PrintBody5: Boolean;
        PostingDate: Date;
        TotalDebitAmt: Decimal;
        DocumentNo: Code[20];
        ZeroLbl: Label 'ZERO';
        HundredLbl: Label 'HUNDRED';
        AndLbl: Label 'and';
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
        ThirteenLbl: Label 'THIRTEEN';
        FourteenLbl: Label 'FOURTEEN';
        FifteenLbl: Label 'FIFTEEN';
        SixteenLbl: Label 'SIXTEEN';
        SeventeenLbl: Label 'SEVENTEEN';
        EighteenLbl: Label 'EIGHTEEN';
        NineteenLbl: Label 'NINETEEN';
        TwentyLbl: Label 'TWENTY';
        ThirtyLbl: Label 'THIRTY';
        FortyLbl: Label 'FORTY';
        FiftyLbl: Label 'FIFTY';
        SixtyLbl: Label 'SIXTY';
        SeventyLbl: Label 'SEVENTY';
        EightyLbl: Label 'EIGHTY';
        NinetyLbl: Label 'NINETY';
        VoucherLbl: Label ' Voucher';
        DateLbl: Label 'Date: ';
        ThousandLbl: Label 'THOUSAND';
        LakhLbl: Label 'LAKH';
        CroreLbl: Label 'CRORE';
        VoucherNoCaptionLbl: Label 'Voucher No. :';
        CreditAmountCaptionLbl: Label 'Credit Amount';
        DebitAmountCaptionLbl: Label 'Debit Amount';
        RUPEESLbl: Label 'RUPEES';
        ParticularsCaptionLbl: Label 'Particulars';
        DrLbl: Label 'Dr';
        ToLbl: Label 'To';
        RsLbl: Label 'Rs. ';
        DatedLbl: Label '  Dated: ';
        ChequeNoLbl: Label 'Cheque No:';
        AmountinwordsCaptionLbl: Label 'Amount (in words):';
        PreparedbyCaptionLbl: Label 'Prepared by:';
        CheckedbyCaptionLbl: Label 'Checked by:';
        ApprovedbyCaptionLbl: Label 'Approved by:';
        PaisaOnlyLbl: Label ' PAISA ONLY';
        IntegerOccurcesCaptionLbl: Label 'IntegerOccurcesCaption';
        NarrationCaptionLbl: Label 'Narration :';

    procedure FindGLAccName(
        "Source Type": Enum "Gen. Journal Source Type";
        "Entry No.": Integer;
        "Source No.": Code[20];
        "G/L Account No.": Code[20]): Text[50]
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        BankAccount: Record "Bank Account";
        FALedgerEntry: Record "FA Ledger Entry";
        FixedAsset: Record "Fixed Asset";
        GLAccount: Record "G/L Account";
        AccName: Text[50];
    begin
        case "Source Type" of
            "Source Type"::Vendor:
                if VendorLedgerEntry.Get("Entry No.") then begin
                    Vendor.Get("Source No.");
                    AccName := CopyStr(Vendor.Name, 1, MaxStrLen(AccName));
                end else begin
                    GLAccount.Get("G/L Account No.");
                    AccName := CopyStr(GLAccount.Name, 1, MaxStrLen(AccName));
                end;
            "Source Type"::Customer:
                if CustLedgerEntry.Get("Entry No.") then begin
                    Customer.Get("Source No.");
                    AccName := CopyStr(Customer.Name, 1, MaxStrLen(AccName));
                end else begin
                    GLAccount.Get("G/L Account No.");
                    AccName := CopyStr(GLAccount.Name, 1, MaxStrLen(AccName));
                end;
            "Source Type"::"Bank Account":
                if BankAccountLedgerEntry.Get("Entry No.") then begin
                    BankAccount.Get("Source No.");
                    AccName := CopyStr(BankAccount.Name, 1, MaxStrLen(AccName));
                end else begin
                    GLAccount.Get("G/L Account No.");
                    AccName := CopyStr(GLAccount.Name, 1, MaxStrLen(AccName));
                end;
            "Source Type"::"Fixed Asset":
                begin
                    FALedgerEntry.Reset();
                    FALedgerEntry.SetRange("G/L Entry No.", "Entry No.");
                    if not FALedgerEntry.IsEmpty() then begin
                        FixedAsset.Get("Source No.");
                        AccName := CopyStr(FixedAsset.Description, 1, MaxStrLen(AccName));
                    end else begin
                        GLAccount.Get("G/L Account No.");
                        AccName := CopyStr(GLAccount.Name, 1, MaxStrLen(AccName));
                    end;
                end else begin
                GLAccount.Get("G/L Account No.");
                AccName := CopyStr(GLAccount.Name, 1, MaxStrLen(AccName));
            end;
                        GLAccount.Get("G/L Account No.");
                        AccName := CopyStr(GLAccount.Name, 1, MaxStrLen(AccName));
        end;
        exit(AccName);
    end;

    procedure FormatNoText(var NoText: array[2] of Text[80]; No: Decimal; CurrencyCode: Code[10])
    var
        Currency: Record Currency;
        PrintExponent: Boolean;
        Ones: Integer;
        Tens: Integer;
        Hundreds: Integer;
        Exponent: Integer;
        NoTextIndex: Integer;
        TensDec: Integer;
        OnesDec: Integer;
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
                    AddToNoText(NoText, NoTextIndex, PrintExponent, HundredLbl);
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
            AddToNoText(NoText, NoTextIndex, PrintExponent, RUPEESLbl);
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
            AddToNoText(NoText, NoTextIndex, PrintExponent, ' ')
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
        OnesText[13] := ThirteenLbl;
        OnesText[14] := FourteenLbl;
        OnesText[15] := FifteenLbl;
        OnesText[16] := SixteenLbl;
        OnesText[17] := SeventeenLbl;
        OnesText[18] := EighteenLbl;
        OnesText[19] := NineteenLbl;
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
        var NoText: array[5] of Text[80];
        var NoTextIndex: Integer;
        var PrintExponent: Boolean;
        AddText: Text[30])
    begin
        PrintExponent := true;
        while StrLen(NoText[NoTextIndex] + ' ' + AddText) > MaxStrLen(NoText[1]) do begin
            NoTextIndex := NoTextIndex + 1;
            if NoTextIndex > ArrayLen(NoText) then
                Error(ExceededStringErr, AddText);
        end;
        NoText[NoTextIndex] := CopyStr(DelChr(NoText[NoTextIndex] + ' ' + AddText, '<'), 1, 80);
    end;
}
