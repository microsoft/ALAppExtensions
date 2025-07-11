// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

using Microsoft.Bank.Ledger;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;
using System.Utilities;

report 18932 "Ledger"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/rdlc/Ledger.rdl';
    Caption = 'Ledger';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = sorting("No.")
                                order(ascending)
                                where("Account Type" = filter(Posting));
            RequestFilterFields = "No.", "Date Filter", "Global Dimension 1 Filter", "Global Dimension 2 Filter";

            column(TodayFormatted; Format(TODAY(), 0, 4))
            {
            }
            column(CompInfoName; CompanyInformation.Name)
            {
            }
            column(LedgerName; Name + '  ' + LedgerLbl)
            {
            }
            column(GetFilters; GETFILTERS())
            {
            }
            column(OpeningBalDesc; OpeningBalanceAsOnLbl + ' ' + Format(GETRANGEMIN("Date Filter")))
            {
            }
            column(OpeningDRBal; OpeningDRBal)
            {
            }
            column(OpeningCRBal; OpeningCRBal)
            {
            }
            column(DRCRBal; ABS(OpeningDRBal - OpeningCRBal))
            {
            }
            column(DrCrTextBalance; DrCrTextBalance)
            {
            }
            column(OpeningCRBalGLEntryCreditAmt; OpeningCRBal + "G/L Entry"."Credit Amount")
            {
            }
            column(OpeningDRBalGLEntryDebitAmt; OpeningDRBal + "G/L Entry"."Debit Amount")
            {
            }
            column(SumOpeningDRCRBalTransDRCR; ABS(OpeningDRBal - OpeningCRBal + TransDebits - TransCredits))
            {
            }
            column(DrCrTextBalance2; DrCrTextBalance2)
            {
            }
            column(TotalDebitAmount; TotalDebitAmount)
            {
            }
            column(TotalCreditAmount; TotalCreditAmount)
            {
            }
            column(TransDebits; TransDebits)
            {
            }
            column(TransCredits; TransCredits)
            {
            }
            column(No_GLAccount; "No.")
            {
            }
            column(DateFilter_GLAccount; "Date Filter")
            {
            }
            column(GlobalDim1Filter_GLAccount; "Global Dimension 1 Filter")
            {
            }
            column(GlobalDim2Filter_GLAccount; "Global Dimension 2 Filter")
            {
            }
            column(PageNoCaption; PageCaptionLbl)
            {
            }
            column(PostingDateCaption; PostingDateCaptionLbl)
            {
            }
            column(DocumentNoCaption; DocumentNoCaptionLbl)
            {
            }
            column(Debit_AmountCaption; DebitAmountCaptionLbl)
            {
            }
            column(CreditAmountCaption; CreditAmountCaptionLbl)
            {
            }
            column(AccountNameCaption; AccountNameCaptionLbl)
            {
            }
            column(VoucherTypeCaption; VoucherTypeCaptionLbl)
            {
            }
            column(BalanceCaption; BalanceCaptionLbl)
            {
            }
            column(Closing_BalanceCaption; Closing_BalanceCaptionLbl)
            {
            }
            dataitem("G/L Entry"; "G/L Entry")
            {
                DataItemLink = "G/L Account No." = field("No."),
                               "Posting Date" = field("Date Filter"),
                               "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                               "Global Dimension 2 Code" = field("Global Dimension 2 Filter");
                DataItemTableView = sorting("G/L Account No.", "Posting Date")
                                    order(ascending);

                column(ControlAccountName; ControlAccountName)
                {
                }
                column(PostingDate_GLEntry; Format("Posting Date"))
                {
                }
                column(DocumentNo_GLEntry; "Document No.")
                {
                }
                column(AccountName; AccountName)
                {
                }
                column(DebitAmount_GLEntry; "Debit Amount")
                {
                }
                column(CreditAmoutnt_GLEntry; "Credit Amount")
                {
                }
                column(SourceDesc; SourceDesc)
                {
                }
                column(SumOpeningDRCRBalTransDRCR2; ABS(OpeningDRBal - OpeningCRBal + TransDebits - TransCredits))
                {
                }
                column(DrCrTextBalance3; DrCrTextBalance)
                {
                }
                column(OneEntryRecord; OneEntryRecord)
                {
                }
                column(EntryNo_GLEntry; "Entry No.")
                {
                }
                dataitem(Integer; Integer)
                {
                    DataItemTableView = sorting(Number);

                    column(ControlAccountName1; ControlAccountName)
                    {
                    }
                    column(PostingDate_GLEntry2; Format(GLEntry."Posting Date"))
                    {
                    }
                    column(GLEntryDocumentNo; GLEntry."Document No.")
                    {
                    }
                    column(AccountName2; AccountName)
                    {
                    }
                    column(GLEntryDebitAmount; "G/L Entry"."Debit Amount")
                    {
                    }
                    column(GLEntryCreditAmount; "G/L Entry"."Credit Amount")
                    {
                    }
                    column(DetailAmt; ABS(DetailAmt))
                    {
                    }
                    column(SourceDesc2; SourceDesc)
                    {
                    }
                    column(DrCrText; DrCrText)
                    {
                    }
                    column(SumOpeningDRCRBalTransDRCR3; ABS(OpeningDRBal - OpeningCRBal + TransDebits - TransCredits))
                    {
                    }
                    column(DrCrTextBalance4; DrCrTextBalance)
                    {
                    }
                    column(FirstRecord; FirstRecord)
                    {
                    }
                    column(Amount_GLEntry2; ABS(GLEntry.Amount))
                    {
                    }
                    column(PrintDetail; PrintDetail)
                    {
                    }
                    trigger OnAfterGetRecord()
                    begin
                        DrCrText := '';
                        if Number > 1 then begin
                            FirstRecord := false;
                            GLEntry.Next();
                        end;
                        if FirstRecord and (ControlAccountName <> '') then begin
                            DetailAmt := 0;
                            if PrintDetail then
                                DetailAmt := GLEntry.Amount;
                            AssignDebitCreditText();

                            if not PrintDetail then
                                AccountName := DetailsLbl
                            else
                                AccountName := Daybook.FindGLAccName(GLEntry."Source Type", GLEntry."Entry No.", GLEntry."Source No.", GLEntry."G/L Account No.");

                            DrCrTextBalance := '';
                            if OpeningDRBal - OpeningCRBal + TransDebits - TransCredits > 0 then
                                DrCrTextBalance := DrLbl
                            else
                                DrCrTextBalance := CrLbl;
                        end else
                            if FirstRecord and (ControlAccountName = '') then begin
                                DetailAmt := 0;
                                if PrintDetail then
                                    DetailAmt := GLEntry.Amount;
                                AssignDebitCreditText();
                                if not PrintDetail then
                                    AccountName := DetailsLbl
                                else
                                    AccountName := Daybook.FindGLAccName(GLEntry."Source Type", GLEntry."Entry No.", GLEntry."Source No.", GLEntry."G/L Account No.");
                                DrCrTextBalance := '';
                                if OpeningDRBal - OpeningCRBal + TransDebits - TransCredits > 0 then
                                    DrCrTextBalance := DrLbl
                                else
                                    DrCrTextBalance := CrLbl;
                            end;

                        if PrintDetail and (not FirstRecord) then begin
                            if GLEntry.Amount > 0 then
                                DrCrText := DrLbl
                            else
                                DrCrText := CrLbl;
                            AccountName := Daybook.FindGLAccName(GLEntry."Source Type", GLEntry."Entry No.", GLEntry."Source No.", GLEntry."G/L Account No.");
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, GLEntry.Count);
                        FirstRecord := true;

                        if GLEntry.Count = 1 then
                            CurrReport.Break();
                    end;
                }
                dataitem(DataItem5326; "Posted Narration")
                {
                    DataItemLink = "Entry No." = field("Entry No.");
                    DataItemTableView = sorting("Entry No.", "Transaction No.", "Line No.")
                                         order(ascending);

                    column(Narration_PostedNarration; Narration)
                    {
                    }
                    trigger OnPreDataItem()
                    begin
                        if not PrintLineNarration then
                            CurrReport.Break();
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
                    trigger OnPreDataItem()
                    begin
                        if not PrintVchNarration then
                            CurrReport.Break();

                        GLEntry2.Reset();
                        GLEntry2.SetCurrentKey(GLEntry2."Posting Date", GLEntry2."Source Code", GLEntry2."Transaction No.");
                        GLEntry2.SetRange(GLEntry2."Posting Date", "G/L Entry"."Posting Date");
                        GLEntry2.SetRange(GLEntry2."Transaction No.", "G/L Entry"."Transaction No.");
                        GLEntry2.SetRange(GLEntry2."G/L Account No.", "G/L Entry"."G/L Account No.");
                        GLEntry2.FindLast();
                        if not (GLEntry2."Entry No." = "G/L Entry"."Entry No.") then
                            CurrReport.Break();
                    end;
                }
                trigger OnAfterGetRecord()
                begin
                    GLEntry.SetRange("Transaction No.", "Transaction No.");
                    GLEntry.SetFilter("Entry No.", '<>%1', "Entry No.");
                    if GLEntry.FindFirst() then;

                    DrCrText := '';
                    ControlAccount := false;
                    OneEntryRecord := true;
                    if GLEntry.Count > 1 then
                        OneEntryRecord := false;

                    GLAccount.Get("G/L Entry"."G/L Account No.");
                    ControlAccount := FindControlAccount("Source Type", "G/L Entry"."Entry No.", "Source No.", "G/L Entry"."G/L Account No.");
                    if ControlAccount then
                        ControlAccountName := Daybook.FindGLAccName("Source Type", "G/L Entry"."Entry No.", "Source No.", "G/L Entry"."G/L Account No.");

                    if Amount > 0 then
                        TransDebits := TransDebits + Amount
                    else
                        TransCredits := TransCredits - Amount;

                    SourceDesc := '';
                    if "Source Code" <> '' then begin
                        SourceCode.Get("Source Code");
                        SourceDesc := CopyStr(SourceCode.Description, 1, 50);
                    end;

                    AccountName := '';
                    if OneEntryRecord and (ControlAccountName <> '') then begin
                        AccountName := Daybook.FindGLAccName(GLEntry."Source Type", GLEntry."Entry No.", GLEntry."Source No.", GLEntry."G/L Account No.");
                        DrCrTextBalance := '';
                        if OpeningDRBal - OpeningCRBal + TransDebits - TransCredits > 0 then
                            DrCrTextBalance := DrLbl
                        else
                            DrCrTextBalance := CrLbl;
                    end else
                        if OneEntryRecord and (ControlAccountName = '') then begin
                            AccountName := Daybook.FindGLAccName(GLEntry."Source Type", GLEntry."Entry No.", GLEntry."Source No.", GLEntry."G/L Account No.");
                            DrCrTextBalance := '';
                            if OpeningDRBal - OpeningCRBal + TransDebits - TransCredits > 0 then
                                DrCrTextBalance := DrLbl
                            else
                                DrCrTextBalance := CrLbl;
                        end;

                    if GLAccountNo <> "G/L Account"."No." then
                        GLAccountNo := "G/L Account"."No.";

                    if GLAccountNo = "G/L Account"."No." then begin
                        DrCrTextBalance2 := '';
                        if OpeningDRBal - OpeningCRBal + TransDebits - TransCredits > 0 then
                            DrCrTextBalance2 := DrLbl
                        else
                            DrCrTextBalance2 := CrLbl;
                    end;

                    TotalDebitAmount += "G/L Entry"."Debit Amount";
                    TotalCreditAmount += "G/L Entry"."Credit Amount";
                end;

                trigger OnPreDataItem()
                begin
                    GLEntry.Reset();
                    GLEntry.SetCurrentKey("Transaction No.");
                    TotalDebitAmount := 0;
                    TotalCreditAmount := 0;
                    TransDebits := 0;
                    TransCredits := 0;
                end;
            }
            trigger OnAfterGetRecord()
            begin
                if AccountNo <> "No." then begin
                    AccountNo := "No.";
                    OpeningDRBal := 0;
                    OpeningCRBal := 0;

                    GLEntry2.Reset();
                    GLEntry2.SetCurrentKey(GLEntry2."G/L Account No.", GLEntry2."Business Unit Code", GLEntry2."Global Dimension 1 Code",
                    GLEntry2."Global Dimension 2 Code", GLEntry2."Close Income Statement Dim. ID", GLEntry2."Posting Date");
                    GLEntry2.SetRange(GLEntry2."G/L Account No.", "No.");
                    GLEntry2.SetFilter(GLEntry2."Posting Date", '%1..%2', 0D, ClosingDate(GetRangeMin("Date Filter") - 1));
                    if GetFilter("Global Dimension 1 Filter") <> '' then
                        GLEntry2.SetFilter("Global Dimension 1 Code", GetFilter("Global Dimension 1 Filter"));
                    if GetFilter("Global Dimension 2 Filter") <> '' then
                        GLEntry2.SetFilter("Global Dimension 2 Code", GetFilter("Global Dimension 2 Filter"));

                    GLEntry2.CalcSums(GLEntry2.Amount);
                    if GLEntry2.Amount > 0 then
                        OpeningDRBal := GLEntry2.Amount
                    else
                        OpeningCRBal := -GLEntry2.Amount;

                    DrCrTextBalance := '';
                    if OpeningDRBal - OpeningCRBal > 0 then
                        DrCrTextBalance := DrLbl
                    else
                        DrCrTextBalance := CrLbl;
                end;
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
                    field(PrintDetail1; PrintDetail)
                    {
                        Caption = 'Print Detail';
                        ToolTip = 'Place a check mark in this field if details of bank vouchers in Bank Book are to be printed.';
                        ApplicationArea = Basic, Suite;
                    }
                    field(PrintLineNarration1; PrintLineNarration)
                    {
                        Caption = 'Print Line Narration';
                        ToolTip = 'Place a check mark in this field if line narration is to be printed.';
                        ApplicationArea = Basic, Suite;
                    }
                    field(PrintVchNarration1; PrintVchNarration)
                    {
                        Caption = 'Print Voucher Narration';
                        ToolTip = 'Place a check mark in this field if voucher narration is to be printed.';
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
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        GLEntry2: Record "G/L Entry";
        SourceCode: Record "Source Code";
        Daybook: Report "Day Book";
        OpeningDRBal: Decimal;
        OpeningCRBal: Decimal;
        TransDebits: Decimal;
        TransCredits: Decimal;
        OneEntryRecord: Boolean;
        FirstRecord: Boolean;
        PrintDetail: Boolean;
        PrintLineNarration: Boolean;
        PrintVchNarration: Boolean;
        DetailAmt: Decimal;
        AccountName: Text[100];
        ControlAccountName: Text[100];
        ControlAccount: Boolean;
        SourceDesc: Text[50];
        DrCrText: Text[2];
        DrCrTextBalance: Text[2];
        AccountNo: Code[20];
        DrCrTextBalance2: Text[2];
        GLAccountNo: Code[20];
        TotalDebitAmount: Decimal;
        TotalCreditAmount: Decimal;
        DetailsLbl: Label 'As per Details';
        DrLbl: Label 'Dr';
        CrLbl: Label 'Cr';
        PageCaptionLbl: Label 'Page';
        OpeningBalanceAsOnLbl: Label 'Opening Balance As On';
        PostingDateCaptionLbl: Label 'Posting Date';
        DocumentNoCaptionLbl: Label 'Document No.';
        DebitAmountCaptionLbl: Label 'Debit Amount';
        CreditAmountCaptionLbl: Label 'Credit Amount';
        AccountNameCaptionLbl: Label 'Account Name';
        VoucherTypeCaptionLbl: Label 'Voucher Type';
        LedgerLbl: Label 'Ledger';
        BalanceCaptionLbl: Label 'Balance';
        Closing_BalanceCaptionLbl: Label 'Closing Balance';

    procedure FindControlAccount(
        "Source Type": Enum "Gen. Journal Source Type";
        "Entry No.": Integer;
        "Source No.": Code[20];
        "G/L Account No.": Code[20]): Boolean
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        FALedgerEntry: Record "FA Ledger Entry";
        SubLedgerFound: Boolean;
    begin
        if "Source Type" = "Source Type"::Vendor then
            if VendorLedgerEntry.Get("Entry No.") then
                SubLedgerFound := true;
        if "Source Type" = "Source Type"::Customer then
            if CustLedgerEntry.Get("Entry No.") then
                SubLedgerFound := true;
        if "Source Type" = "Source Type"::"Bank Account" then
            if BankAccountLedgerEntry.Get("Entry No.") then
                SubLedgerFound := true;
        if "Source Type" = "Source Type"::"Fixed Asset" then begin
            FALedgerEntry.Reset();
            FALedgerEntry.SetCurrentKey("G/L Entry No.");
            FALedgerEntry.SetRange("G/L Entry No.", "Entry No.");
            if not FALedgerEntry.IsEmpty() then
                SubLedgerFound := true;
        end;
        exit(SubLedgerFound);
    end;

    local procedure AssignDebitCreditText()
    begin
        if DetailAmt > 0 then
            DrCrText := DrLbl
        else
            DrCrText := CrLbl;
    end;
}
