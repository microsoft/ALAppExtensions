// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Bank.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;

report 11727 "Cash Desk Account Book CZP"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/CashDeskAccountBook.rdl';
    PreviewMode = PrintLayout;
    ApplicationArea = Basic, Suite;
    Caption = 'Cash Desk Account Book';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(CashDeskCZP; "Cash Desk CZP")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
            column(CashDesk_No; "No.")
            {
                IncludeCaption = true;
            }
            column(CashDesk_Currency_Code; "Currency Code")
            {
                IncludeCaption = true;
            }
            column(CashDesk_Name; Name)
            {
            }
            column(CompanyAddress3; CompanyAddress[3])
            {
            }
            column(CompanyAddress2; CompanyAddress[2])
            {
            }
            column(CompanyAddress1; CompanyAddress[1])
            {
            }
            column(CashDeskFilter; CashDeskFilter)
            {
            }
            column(ShowLCY; Format(ShowLCY))
            {
            }
            column(ShowEntry; ShowEntry)
            {
            }
            column(EndDate; EndDate)
            {
            }
            column(StartDate; StartDate)
            {
            }
            column(ReceiptTotal; ReceiptTotal)
            {
            }
            column(PaymentTotal; PaymentTotal)
            {
            }
            column(BalanceToDate; BalanceToDate)
            {
            }
            dataitem(BankAccountLedgerEntry; "Bank Account Ledger Entry")
            {
                DataItemLink = "Bank Account No." = field("No."), "Posting Date" = field("Date Filter");
                DataItemTableView = sorting("Entry No.");
                column(BankAccountLedgerEntry_Posting_Date; "Posting Date")
                {
                    IncludeCaption = true;
                }
                column(BankAccountLedgerEntry_External_Document_No; "External Document No.")
                {
                    IncludeCaption = true;
                }
                column(BankAccountLedgerEntry_Description; Description)
                {
                    IncludeCaption = true;
                }
                column(BankAccountLedgerEntry_Document_No; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(BankAccountLedgerEntry_Entry_No; "Entry No.")
                {
                }
                column(BankAccountLedgerEntry_CashDesk_No; "Bank Account No.")
                {
                }
                column(Balance; Balance)
                {
                }
                column(Receipt; Receipt)
                {
                }
                column(Payment; Payment)
                {
                }
                dataitem(PostedCashDocumentHdrCZP; "Posted Cash Document Hdr. CZP")
                {
                    DataItemLink = "No." = field("Document No."), "Posting Date" = field("Posting Date");
                    DataItemTableView = sorting("No.", "Posting Date");
                    column(PostedCashDocumentHeader_Cash_Desk_No; "Cash Desk No.")
                    {
                    }
                    column(PostedCashDocumentHeader_No; "No.")
                    {
                    }
                    column(PostedCashDocumentHeader_Posting_Date; "Posting Date")
                    {
                    }
                    dataitem(PostedCashDocumentLineCZP; "Posted Cash Document Line CZP")
                    {
                        DataItemLink = "Cash Desk No." = field("Cash Desk No."), "Cash Document No." = field("No.");
                        DataItemTableView = sorting("Cash Desk No.", "Cash Document No.", "Line No.") ORDER(Ascending);
                        column(PostedCashDocumentLine_Cash_Desk_No; "Cash Desk No.")
                        {
                        }
                        column(PostedCashDocumentLine_Line_No; "Line No.")
                        {
                        }
                        column(PostedCashDocumentLine_Cash_Document_No; "Cash Document No.")
                        {
                        }
                        column(PostedCashDocumentLine_External_Document_No; "External Document No.")
                        {
                        }
                        column(PostedCashDocumentLine_Description; Description)
                        {
                        }
                        column(PostedReceipt; PostedReceipt)
                        {
                        }
                        column(PostedPayment; PostedPayment)
                        {
                        }

                        trigger OnAfterGetRecord()
                        var
                            Amt: Decimal;
                        begin
                            if "Document Type" = "Document Type"::Withdrawal then begin
                                "Amount Including VAT (LCY)" := -"Amount Including VAT (LCY)";
                                "Amount Including VAT" := -"Amount Including VAT";
                            end;
                            if ShowLCY then
                                Amt := "Amount Including VAT (LCY)"
                            else
                                Amt := "Amount Including VAT";

                            if Amt < 0 then begin
                                PostedPayment := Amt;
                                PostedReceipt := 0;
                            end else begin
                                PostedReceipt := Amt;
                                PostedPayment := 0;
                            end;
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        if not ShowEntry then
                            CurrReport.Break();
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    Amt: Decimal;
                begin
                    if ShowLCY then
                        Amt := "Amount (LCY)"
                    else
                        Amt := Amount;
                    if Amt < 0 then begin
                        Payment := Amt;
                        PaymentTotal += Amt;
                        Receipt := 0;
                    end else begin
                        Receipt := Amt;
                        ReceiptTotal += Amt;
                        Payment := 0;
                    end;
                    Balance += Amt;
                end;

                trigger OnPreDataItem()
                var
                    BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
                begin
                    case EntriesSorting of
                        EntriesSorting::PostingDate:
                            SetCurrentKey("Bank Account No.", "Posting Date");
                        EntriesSorting::DocumentNo:
                            SetCurrentKey("Document No.");
                    end;

                    if (StartDate <> 0D) or (EndDate <> 0D) then
                        SetFilter("Posting Date", '%1..%2', StartDate, EndDate);
                    Balance := 0;
                    BalanceToDate := 0;
                    if StartDate <> 0D then begin
                        BankAccountLedgerEntry.SetCurrentKey("Bank Account No.");
                        BankAccountLedgerEntry.SetRange("Bank Account No.", CashDeskCZP."No.");
                        if StartDate <> 0D then
                            BankAccountLedgerEntry.SetFilter("Posting Date", '..%1', CalcDate('<-1D>', StartDate));
                        BankAccountLedgerEntry.CalcSums(Amount, "Amount (LCY)");
                        if ShowLCY then
                            BalanceToDate := BankAccountLedgerEntry."Amount (LCY)"
                        else
                            BalanceToDate := BankAccountLedgerEntry.Amount;
                        Balance := BalanceToDate;
                    end;

                    ReceiptTotal := 0;
                    PaymentTotal := 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CashDeskManagementCZP.CheckCashDesk("No.");

                if "Currency Code" = '' then
                    "Currency Code" := GeneralLedgerSetup."LCY Code";
            end;

            trigger OnPreDataItem()
            var
                TwoPlaceholdersTok: Label '%1: %2', Comment = '%1 = TableCaption, %2 = GetFilters', Locked = true;
            begin
                if (StartDate <> 0D) or (EndDate <> 0D) then
                    SetFilter("Date Filter", '%1..%2', StartDate, EndDate);
                if GetFilters <> '' then
                    CashDeskFilter := StrSubstNo(TwoPlaceholdersTok, TableCaption(), GetFilters());
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
                    field(StartDateCZP; StartDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the start date of cash desk account book.';
                    }
                    field(EndDateCZP; EndDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Closing Date';
                        ToolTip = 'Specifies the end date of cash desk account book.';
                    }
                    field(ShowEntryCZP; ShowEntry)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Ledger Entry';
                        ToolTip = 'Specifies if you want notes about ledger entry to be shown on the report.';
                    }
                    field(ShowLCYCZP; ShowLCY)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show in LCY';
                        ToolTip = 'Specifies if the reported amounts are shown in the local currency.';
                    }
                    field(SortingCZP; EntriesSorting)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Sorting';
                        OptionCaption = 'Posting Date,Document No.';
                        ToolTip = 'Specifies the method by which the entries are sorted on the report.';
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            CashDeskCZP.SetRange("Date Filter", WorkDate());
        end;
    }

    labels
    {
        ReportNameLbl = 'Cash Desk Book';
        ReportDescriptionLbl = '(Posted Documents)';
        PageLbl = 'Page';
        ShowLCYLbl = 'Show in LCY';
        InitialConditionLbl = 'Initial Condition:';
        InitialConditionLCYLbl = 'Initial Condition in LCY:';
        ReceiptLbl = 'Receipt';
        WithdrawalLbl = 'Withdrawal';
        BalanceLbl = 'Balance';
        DateFilterLbl = 'Date Filter:';
        TotalBalanceLbl = 'Total Balance';
        DateLbl = 'Date';
        CashierSignLbl = 'Cashier Sign';
    }

    trigger OnPreReport()
    begin
        GeneralLedgerSetup.Get();
        CompanyInformation.Get();
        FormatAddress.Company(CompanyAddress, CompanyInformation);
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CompanyInformation: Record "Company Information";
        FormatAddress: Codeunit "Format Address";
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";
        Balance, BalanceToDate, Receipt, Payment, ReceiptTotal, PaymentTotal, PostedReceipt, PostedPayment : Decimal;
        StartDate, EndDate : Date;
        CashDeskFilter: Text;
        CompanyAddress: array[8] of Text[150];
        EntriesSorting: Option PostingDate,DocumentNo;
        ShowEntry, ShowLCY : Boolean;
}
