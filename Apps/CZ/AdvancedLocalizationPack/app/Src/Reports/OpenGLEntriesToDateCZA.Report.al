// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Reports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;

report 31130 "Open G/L Entries To Date CZA"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/OpenGLEntriesToDate.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Open G/L Entries To Date';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("G/L Entry"; "G/L Entry")
        {
            RequestFilterFields = "G/L Account No.";
            column(SkipEntriesDetail; SkipEntriesDetail)
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(BalanceToDate; BalanceToDate)
            {
            }
            column(GLEntry_GLAccountNo; "G/L Entry"."G/L Account No.")
            {
            }
            column(GLAccount_Name; GLAccount.Name)
            {
            }
            column(GLEntry_PostingDate; "Posting Date")
            {
                IncludeCaption = true;
            }
            column(GLEntry_DocumentType; "Document Type")
            {
                IncludeCaption = true;
            }
            column(GLEntry_DocumentNo; "Document No.")
            {
                IncludeCaption = true;
            }
            column(GLEntry_Description; Description)
            {
                IncludeCaption = true;
            }
            column(GLEntry_Amount; Amount)
            {
            }
            column(Amount_AppliedAmount; Amount - AppliedAmount)
            {
            }
            column(DebitAmount; DebitAmount)
            {
            }
            column(CreditAmount; CreditAmount)
            {
            }
            column(TotalOpenAmount; TotalOpenAmount)
            {
            }
            column(TotalDebitAmount; TotalDebitAmount)
            {
            }
            column(TotalCreditAmount; TotalCreditAmount)
            {
            }

            trigger OnAfterGetRecord()
            var
                GLEntry: Record "G/L Entry";
            begin
                if PreviousAccountNo <> "G/L Entry"."G/L Account No." then begin
                    TotalOpenAmount := 0;
                    TotalDebitAmount := 0;
                    TotalCreditAmount := 0;
                    PreviousAccountNo := "G/L Entry"."G/L Account No.";
                end;
                AppliedAmount := 0;
                DebitAmount := 0;
                CreditAmount := 0;
                GLAccount.Get("G/L Account No.");

                GLEntry.Get("G/L Entry"."Entry No.");
                GLEntry.SetFilter("Date Filter CZA", '..%1', BalanceToDate);
                GLEntry.CalcFields("Applied Amount CZA");
                AppliedAmount := GLEntry."Applied Amount CZA";
                if (Amount - AppliedAmount) = 0 then
                    CurrReport.Skip();
                if "Debit Amount" <> 0 then
                    DebitAmount := (Amount - AppliedAmount)
                else
                    CreditAmount := -(Amount - AppliedAmount);

                TotalOpenAmount += (Amount - AppliedAmount);
                TotalDebitAmount += DebitAmount;
                TotalCreditAmount += CreditAmount;
            end;

            trigger OnPreDataItem()
            begin
                SetCurrentKey("G/L Account No.", "Posting Date");
                if BalanceToDate = 0D then
                    BalanceToDate := WorkDate();

                SetFilter("Posting Date", '..%1', BalanceToDate);
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
                    field(BalanceToDateField; BalanceToDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Balance to Date';
                        ToolTip = 'Specifies the last date in the period for open general ledger entries.';
                    }
                    field(SkipEntriesDetailField; SkipEntriesDetail)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Skip Entry Details';
                        ToolTip = 'Specifies when entry details are to be skip';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            BalanceToDate := WorkDate();
        end;
    }

    labels
    {
        PageLbl = 'Page';
        OpenGLEntriesToDateLbl = 'Open G/L Entries To Date';
        BalanceToDateLbl = 'Balance To Date:';
        CreditAmountLbl = 'Credit Amount';
        DebitAmountLbl = 'Debit Amount';
        Open_AmountLbl = 'Open Amount';
        OriginalAmountLbl = 'Original Amount';
        AccountNoLbl = 'Account No.';
        AccountTotalLbl = 'Account Total';
    }

    var
        GLAccount: Record "G/L Account";
        BalanceToDate: Date;
        SkipEntriesDetail: Boolean;
        DebitAmount: Decimal;
        CreditAmount: Decimal;
        AppliedAmount: Decimal;
        TotalOpenAmount: Decimal;
        TotalDebitAmount: Decimal;
        TotalCreditAmount: Decimal;
        PreviousAccountNo: Code[20];
}
