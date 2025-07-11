// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using System.Utilities;

report 18930 "Bank Book"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/rdlc/BankBook.rdl';
    Caption = 'Bank Book';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Bank Account"; "Bank Account")
        {
            DataItemTableView = sorting("No.")
                                order(ascending);
            RequestFilterFields = "No.", "Date Filter", "Global Dimension 1 Filter", "Global Dimension 2 Filter";

            column(FORMAT_TODAY_0_4_; Format(TODAY(), 0, 4))
            {
            }
            column(CompInfo_Name; CompanyInformation.Name)
            {
            }
            column(CurrReport_PAGENO; '')
            {
            }
            column(USERID; UserId())
            {
            }
            column(Bank_Account_Name; Name)
            {
            }
            column(GETFILTERS; GetFilters())
            {
            }
            column(Bank_Book_; BankBookLbl)
            {
            }
            column(Opening_Balance_As_On_______FORMAT_GETRANGEMIN__Date_Filter___; OpeningBalanceAsOnLbl + ' ' + Format(GETRANGEMIN("Date Filter")))
            {
            }
            column(OpeningDRBal; OpeningDRBal)
            {
            }
            column(OpeningCRBal; OpeningCRBal)
            {
            }
            column(ABS_OpeningDRBal_OpeningCRBal_; ABS(OpeningDRBal - OpeningCRBal))
            {
            }
            column(DrCrTextBalance; DrCrTextBalance)
            {
            }
            column(OpeningCRBal_TransCredits; OpeningCRBal + TransCredits)
            {
            }
            column(OpeningDRBal_TransDebits; OpeningDRBal + TransDebits)
            {
            }
            column(ABS_OpeningDRBal_OpeningCRBal_TransDebits_TransCredits_; ABS(OpeningDRBal - OpeningCRBal + TransDebits - TransCredits))
            {
            }
            column(DrCrTextBalance_Control1500007; DrCrTextBalance)
            {
            }
            column(TransDebits; TransDebits)
            {
            }
            column(TransCredits; TransCredits)
            {
            }
            column(Bank_Account_No_; "No.")
            {
            }
            column(Bank_Account_Date_Filter; "Date Filter")
            {
            }
            column(Bank_Account_Global_Dimension_1_Filter; "Global Dimension 1 Filter")
            {
            }
            column(Bank_Account_Global_Dimension_2_Filter; "Global Dimension 2 Filter")
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Posting_DateCaption; Posting_DateCaptionLbl)
            {
            }
            column(Document_No_Caption; Document_No_CaptionLbl)
            {
            }
            column(Debit_AmountCaption; Debit_AmountCaptionLbl)
            {
            }
            column(Credit_AmountCaption; Credit_AmountCaptionLbl)
            {
            }
            column(Account_NameCaption; Account_NameCaptionLbl)
            {
            }
            column(BalanceCaption; BalanceCaptionLbl)
            {
            }
            column(Voucher_TypeCaption; Voucher_TypeCaptionLbl)
            {
            }
            column(Cheque_NoCaption; Cheque_NoCaptionLbl)
            {
            }
            column(Cheque_DateCaption; Cheque_DateCaptionLbl)
            {
            }
            column(Closing_BalanceCaption; Closing_BalanceCaptionLbl)
            {
            }
            dataitem(DataItem4920; "Bank Account Ledger Entry")
            {
                DataItemLink = "Bank Account No." = field("No."),
                               "Posting Date" = field("Date Filter"),
                               "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                               "Global Dimension 2 Code" = field("Global Dimension 2 Filter");
                DataItemTableView = sorting("Bank Account No.", "Posting Date")
                                    order(ascending);

                column(Bank_Account_Ledger_Entry_Entry_No_; "Entry No.")
                {
                }
                column(Bank_Account_Ledger_Entry_Bank_Account_No_; "Bank Account No.")
                {
                }
                column(Bank_Account_Ledger_Entry_Posting_Date; "Posting Date")
                {
                }
                column(Bank_Account_Ledger_Entry___Cheque_No__; DataItem4920."Cheque No.")
                {
                }
                column(Bank_Account_Ledger_Entry___Cheque_Date_; Format(DataItem4920."Cheque Date"))
                {
                }
                column(Bank_Account_Ledger_Entry_Global_Dimension_1_Code; "Global Dimension 1 Code")
                {
                }
                column(Bank_Account_Ledger_Entry_Global_Dimension_2_Code; "Global Dimension 2 Code")
                {
                }
                dataitem("G/L Entry"; "G/L Entry")
                {
                    DataItemLink = "Entry No." = field("Entry No.");
                    DataItemTableView = sorting("G/L Account No.", "Posting Date")
                                        order(ascending);

                    column(G_L_Entry__Posting_Date_; Format("Posting Date"))
                    {
                    }
                    column(G_L_Entry__Document_No__; "Document No.")
                    {
                    }
                    column(AccountName; AccountName)
                    {
                    }
                    column(G_L_Entry__Debit_Amount_; "Debit Amount")
                    {
                    }
                    column(G_L_Entry__Credit_Amount_; "Credit Amount")
                    {
                    }
                    column(ABS_OpeningDRBal_OpeningCRBal_TransDebits_TransCredits__Control1500026; ABS(OpeningDRBal - OpeningCRBal + TransDebits - TransCredits))
                    {
                    }
                    column(SourceDesc; SourceDesc)
                    {
                    }
                    column(DrCrTextBalance_Control1500065; DrCrTextBalance)
                    {
                    }
                    column(OneEntryRecord; OneEntryRecord)
                    {
                    }
                    column(G_L_Entry_Entry_No_; "Entry No.")
                    {
                    }
                    column(G_L_Entry_Transaction_No_; "Transaction No.")
                    {
                    }
                    dataitem(DataItem5444; Integer)
                    {
                        DataItemTableView = sorting(Number);

                        column(GLEntry__Posting_Date_; Format(GLEntry."Posting Date"))
                        {
                        }
                        column(GLEntry__Document_No__; GLEntry."Document No.")
                        {
                        }
                        column(AccountName_Control1500018; AccountName)
                        {
                        }
                        column(G_L_Entry___Debit_Amount_; "G/L Entry"."Debit Amount")
                        {
                        }
                        column(G_L_Entry___Credit_Amount_; "G/L Entry"."Credit Amount")
                        {
                        }
                        column(ABS_DetailAmt_; ABS(DetailAmt))
                        {
                        }
                        column(ABS_OpeningDRBal_OpeningCRBal_TransDebits_TransCredits__Control1500049; ABS(OpeningDRBal - OpeningCRBal + TransDebits - TransCredits))
                        {
                        }
                        column(SourceDesc_Control1500036; SourceDesc)
                        {
                        }
                        column(Bank_Account_Ledger_Entry___Cheque_No; DataItem4920."Cheque No.")
                        {
                        }
                        column(Bank_Account_Ledger_Entry___Cheque_Date; Format(DataItem4920."Cheque Date"))
                        {
                        }
                        column(DrCrText; DrCrText)
                        {
                        }
                        column(DrCrTextBalance_Control1500067; DrCrTextBalance)
                        {
                        }
                        column(AccountName_Control1500042; AccountName)
                        {
                        }
                        column(ABS_GLEntry_Amount_; ABS(GLEntry.Amount))
                        {
                        }
                        column(DrCrText_Control1500056; DrCrText)
                        {
                        }
                        column(FirstRecord; FirstRecord)
                        {
                        }
                        column(PrintDetail; PrintDetail)
                        {
                        }
                        column(Integer_Number; Number)
                        {
                        }
                        trigger OnAfterGetRecord()
                        begin
                            DrCrText := '';
                            if Number > 1 then begin
                                FirstRecord := false;
                                GLEntry.Next();
                            end;

                            if FirstRecord then begin
                                DetailAmt := 0;
                                if PrintDetail then
                                    DetailAmt := GLEntry.Amount;

                                if DetailAmt > 0 then
                                    DrCrText := DrLbl;
                                if DetailAmt < 0 then
                                    DrCrText := CrLbl;

                                if not PrintDetail then
                                    AccountName := DetailsLbl
                                else
                                    AccountName := Daybook.FindGLAccName(GLEntry."Source Type", GLEntry."Entry No.", GLEntry."Source No.", GLEntry."G/L Account No.")
                                      ;

                                DrCrTextBalance := '';
                                if OpeningDRBal - OpeningCRBal + TransDebits - TransCredits > 0 then
                                    DrCrTextBalance := DrLbl;
                                if OpeningDRBal - OpeningCRBal + TransDebits - TransCredits < 0 then
                                    DrCrTextBalance := CrLbl;
                            end else
                                if PrintDetail and (not FirstRecord) then begin
                                    if GLEntry.Amount > 0 then
                                        DrCrText := DrLbl;
                                    if GLEntry.Amount < 0 then
                                        DrCrText := CrLbl;
                                    AccountName :=
                                      Daybook.FindGLAccName(GLEntry."Source Type", GLEntry."Entry No.", GLEntry."Source No.", GLEntry."G/L Account No.");
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
                    dataitem(PostedNarration; "Posted Narration")
                    {
                        DataItemLink = "Entry No." = field("Entry No.");
                        DataItemTableView = sorting("Entry No.", "Transaction No.", "Line No.")
                                         order(ascending);

                        column(Posted_Narration_Narration; Narration)
                        {
                        }
                        column(Posted_Narration_Entry_No_; "Entry No.")
                        {
                        }
                        column(Posted_Narration_Transaction_No_; "Transaction No.")
                        {
                        }
                        column(Posted_Narration_Line_No_; "Line No.")
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

                        column(PostedNarration1_Narration; Narration)
                        {
                        }
                        column(PostedNarration1_Entry_No_; "Entry No.")
                        {
                        }
                        column(PostedNarration1_Transaction_No_; "Transaction No.")
                        {
                        }
                        column(PostedNarration_Entry_No_; "Document No.")
                        {
                        }
                        column(PostedNarration_Transaction_No_; "Document No.")
                        {
                        }
                        column(PostedNarration1_Line_No_; "Line No.")
                        {
                        }
                        trigger OnPreDataItem()
                        begin
                            if not PrintVchNarration then
                                CurrReport.Break();

                            GLEntry2.Reset();
                            GLEntry2.SetCurrentKey(GLEntry2."Posting Date", GLEntry2."Source Code", GLEntry2."Transaction No.");
                            GLEntry2.SetRange(GLEntry2."Posting Date", "G/L Entry"."Posting Date");
                            GLEntry2.SetRange(GLEntry2."Source Code", "G/L Entry"."Source Code");
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
                        if GLEntry.Find('-') then;

                        DrCrText := '';
                        OneEntryRecord := true;
                        if GLEntry.Count > 1 then
                            OneEntryRecord := false;

                        TransDebits := TransDebits + "Debit Amount";
                        TransCredits := TransCredits + "Credit Amount";

                        SourceDesc := '';
                        if "Source Code" <> '' then begin
                            SourceCode.Get("Source Code");
                            SourceDesc := CopyStr(SourceCode.Description, 1, MaxStrLen(SourceDesc));
                        end;

                        AccountName := '';
                        if OneEntryRecord then begin
                            AccountName := Daybook.FindGLAccName(GLEntry."Source Type", GLEntry."Entry No.", GLEntry."Source No.", GLEntry."G/L Account No.");

                            DrCrTextBalance := '';
                            if OpeningDRBal - OpeningCRBal + TransDebits - TransCredits > 0 then
                                DrCrTextBalance := DrLbl
                            else
                                DrCrTextBalance := CrLbl;
                        end;

                        if BankAccountNo = "Bank Account"."No." then begin
                            DrCrTextBalance := '';
                            if OpeningDRBal - OpeningCRBal + TransDebits - TransCredits > 0 then
                                DrCrTextBalance := DrLbl
                            else
                                DrCrTextBalance := CrLbl;
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        GLEntry.Reset();
                        GLEntry.SetCurrentKey("Transaction No.");
                    end;
                }
            }
            trigger OnAfterGetRecord()
            begin
                TransDebits := 0;
                TransCredits := 0;

                VoucherPostingCreditAccount.SetFilter(Type, '%1|%2',
                    VoucherPostingCreditAccount.Type::"Bank Payment Voucher",
                    VoucherPostingCreditAccount.Type::"Bank Receipt Voucher");
                VoucherPostingCreditAccount.SetRange("Account Type", VoucherPostingCreditAccount."Account Type"::"Bank Account");
                VoucherPostingCreditAccount.SetRange("Account No.", "No.");

                VoucherPostingDebitAccount.SetFilter(Type, '%1|%2',
                    VoucherPostingDebitAccount.Type::"Bank Payment Voucher",
                    VoucherPostingDebitAccount.Type::"Bank Receipt Voucher");
                VoucherPostingDebitAccount.SetRange("Account Type", VoucherPostingDebitAccount."Account Type"::"Bank Account");
                VoucherPostingDebitAccount.SetRange("Account No.", "No.");
                if (not VoucherPostingCreditAccount.FindFirst()) and (not VoucherPostingDebitAccount.FindFirst()) then
                    CurrReport.Skip();

                if BankAccountNo <> "No." then begin
                    OpeningDRBal := 0;
                    OpeningCRBal := 0;

                    BankAccountLedgerEntry.Reset();
                    BankAccountLedgerEntry.SetCurrentKey("Bank Account No.", "Global Dimension 1 Code",
                      "Global Dimension 2 Code", "Posting Date");
                    BankAccountLedgerEntry.SetRange("Bank Account No.", "No.");
                    BankAccountLedgerEntry.SetFilter("Posting Date", '%1..%2', 0D, NormalDate(GetRangeMin("Date Filter")) - 1);
                    if GetFilter("Global Dimension 1 Filter") <> '' then
                        BankAccountLedgerEntry.SetFilter("Global Dimension 1 Code", GetFilter("Global Dimension 1 Filter"));
                    if "Global Dimension 2 Filter" <> '' then
                        BankAccountLedgerEntry.SetFilter("Global Dimension 2 Code", GetFilter("Global Dimension 2 Filter"));

                    BankAccountLedgerEntry.CalcSums("Amount (LCY)");
                    if BankAccountLedgerEntry."Amount (LCY)" > 0 then
                        OpeningDRBal := BankAccountLedgerEntry."Amount (LCY)"
                    else
                        OpeningCRBal := -BankAccountLedgerEntry."Amount (LCY)";

                    DrCrTextBalance := '';
                    if OpeningDRBal - OpeningCRBal > 0 then
                        DrCrTextBalance := DrLbl
                    else
                        DrCrTextBalance := CrLbl;

                    BankAccountNo := "No.";
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

    trigger OnInitReport()
    begin
        BankAccountNo := '';
    end;

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
    end;

    var
        CompanyInformation: Record "Company Information";
        GLEntry: Record "G/L Entry";
        GLEntry2: Record "G/L Entry";
        VoucherPostingCreditAccount: Record "Voucher Posting Credit Account";
        VoucherPostingDebitAccount: Record "Voucher Posting Debit Account";
        SourceCode: Record "Source Code";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
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
        SourceDesc: Text[50];
        DrCrText: Text[2];
        DrCrTextBalance: Text[2];
        BankAccountNo: Code[20];
        DetailsLbl: Label 'As per Details';
        DrLbl: Label 'Dr';
        CrLbl: Label 'Cr';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Posting_DateCaptionLbl: Label 'Posting Date';
        Document_No_CaptionLbl: Label 'Document No.';
        Debit_AmountCaptionLbl: Label 'Debit Amount';
        Credit_AmountCaptionLbl: Label 'Credit Amount';
        Account_NameCaptionLbl: Label 'Account Name';
        BalanceCaptionLbl: Label 'Balance';
        Voucher_TypeCaptionLbl: Label 'Voucher Type';
        Cheque_NoCaptionLbl: Label 'Cheque No';
        Cheque_DateCaptionLbl: Label 'Cheque Date';
        OpeningBalanceAsOnLbl: Label 'Opening Balance As On';
        BankBookLbl: Label 'Bank Book';
        Closing_BalanceCaptionLbl: Label 'Closing Balance';
}
