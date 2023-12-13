// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Reports;

using Microsoft.Bank.Ledger;
using Microsoft.Finance.Currency;
using System.Utilities;

report 11713 "Joining Bank. Acc. Adj. CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/JoiningBankAccAdj.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Joining Banking Account Adjustment';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(BankAccountLedgerEntryFilter; "Bank Account Ledger Entry")
        {
            DataItemTableView = sorting("Bank Account No.", "Posting Date");
            RequestFilterFields = "Bank Account No.", "Document No.", "External Document No.";

            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(BankAccountLedgerEntry_Filters; BankAccountLedgerEntryFilters)
            {
            }

            trigger OnAfterGetRecord()
            var
                DocumentNo: Code[20];
            begin
                j := j + 1;
                WindowDialog.Update(1, Round((9999 / i) * j, 1));

                DocumentNo := GetDocumentNoBySortingType(BankAccountLedgerEntryFilter);
                if TempBankAccAdjustBufferCZL.Get(DocumentNo) then begin
                    if TempBankAccAdjustBufferCZL.Valid and (TempBankAccAdjustBufferCZL."Currency Code" = BankAccountLedgerEntryFilter."Currency Code") then begin
                        TempBankAccAdjustBufferCZL.Amount += BankAccountLedgerEntryFilter.Amount;
                        TempBankAccAdjustBufferCZL."Debit Amount" += BankAccountLedgerEntryFilter."Debit Amount";
                        TempBankAccAdjustBufferCZL."Credit Amount" += BankAccountLedgerEntryFilter."Credit Amount";
                    end else begin
                        TempBankAccAdjustBufferCZL.Amount := 0;
                        TempBankAccAdjustBufferCZL."Debit Amount" := 0;
                        TempBankAccAdjustBufferCZL."Credit Amount" := 0;
                        TempBankAccAdjustBufferCZL.Valid := false;
                    end;
                    TempBankAccAdjustBufferCZL."Amount (LCY)" += BankAccountLedgerEntryFilter."Amount (LCY)";
                    if ShowPostingDate and (TempBankAccAdjustBufferCZL."Posting Date" = 0D) and (BankAccountLedgerEntryFilter."Posting Date" <> 0D) then
                        TempBankAccAdjustBufferCZL."Posting Date" := BankAccountLedgerEntryFilter."Posting Date";
                    if ShowDescription and (TempBankAccAdjustBufferCZL.Description = '') and (BankAccountLedgerEntryFilter.Description <> '') then
                        TempBankAccAdjustBufferCZL.Description := BankAccountLedgerEntryFilter.Description;
                    TempBankAccAdjustBufferCZL.Modify();
                end else begin
                    TempBankAccAdjustBufferCZL.Init();
                    TempBankAccAdjustBufferCZL."Document No." := DocumentNo;
                    TempBankAccAdjustBufferCZL.Amount := BankAccountLedgerEntryFilter.Amount;
                    TempBankAccAdjustBufferCZL."Debit Amount" := BankAccountLedgerEntryFilter."Debit Amount";
                    TempBankAccAdjustBufferCZL."Credit Amount" := BankAccountLedgerEntryFilter."Credit Amount";
                    TempBankAccAdjustBufferCZL."Amount (LCY)" := BankAccountLedgerEntryFilter."Amount (LCY)";
                    TempBankAccAdjustBufferCZL."Currency Code" := BankAccountLedgerEntryFilter."Currency Code";
                    if ShowPostingDate then
                        TempBankAccAdjustBufferCZL."Posting Date" := BankAccountLedgerEntryFilter."Posting Date";
                    if ShowDescription then
                        TempBankAccAdjustBufferCZL.Description := BankAccountLedgerEntryFilter.Description;
                    TempBankAccAdjustBufferCZL.Valid := true;
                    TempBankAccAdjustBufferCZL.Insert();
                end;

                if TempEnhancedCurrencyBufferCZL.Get(BankAccountLedgerEntryFilter."Currency Code") then begin
                    TempEnhancedCurrencyBufferCZL."Total Amount" += BankAccountLedgerEntryFilter.Amount;
                    TempEnhancedCurrencyBufferCZL."Total Amount (LCY)" += BankAccountLedgerEntryFilter."Amount (LCY)";
                    TempEnhancedCurrencyBufferCZL."Total Credit Amount" += BankAccountLedgerEntryFilter."Credit Amount";
                    TempEnhancedCurrencyBufferCZL."Total Debit Amount" += BankAccountLedgerEntryFilter."Debit Amount";
                    TempEnhancedCurrencyBufferCZL.Counter += 1;
                    TempEnhancedCurrencyBufferCZL.Modify();
                end else begin
                    TempEnhancedCurrencyBufferCZL.Init();
                    TempEnhancedCurrencyBufferCZL."Currency Code" := BankAccountLedgerEntryFilter."Currency Code";
                    TempEnhancedCurrencyBufferCZL."Total Amount" := BankAccountLedgerEntryFilter.Amount;
                    TempEnhancedCurrencyBufferCZL."Total Amount (LCY)" := BankAccountLedgerEntryFilter."Amount (LCY)";
                    TempEnhancedCurrencyBufferCZL."Total Credit Amount" := BankAccountLedgerEntryFilter."Credit Amount";
                    TempEnhancedCurrencyBufferCZL."Total Debit Amount" := BankAccountLedgerEntryFilter."Debit Amount";
                    TempEnhancedCurrencyBufferCZL.Counter := 1;
                    TempEnhancedCurrencyBufferCZL.Insert();
                end;
            end;

            trigger OnPreDataItem()
            begin
                i := BankAccountLedgerEntryFilter.Count;
                j := 0;
                WindowDialog.Open(ProcessingEntriesMsg);
            end;
        }
        dataitem(EntryBuffer; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = filter(1 ..));
            column(EntryBuffer_DocumentNo; TempBankAccAdjustBufferCZL."Document No.")
            {
            }
            column(EntryBuffer_Amount; TempBankAccAdjustBufferCZL.Amount)
            {
            }
            column(EntryBuffer_AmountLCY; TempBankAccAdjustBufferCZL."Amount (LCY)")
            {
            }
            column(EntryBuffer_DebitAmount; TempBankAccAdjustBufferCZL."Debit Amount")
            {
            }
            column(EntryBuffer_CreditAmount; TempBankAccAdjustBufferCZL."Credit Amount")
            {
            }
            column(EntryBuffer_Description; TempBankAccAdjustBufferCZL.Description)
            {
            }
            column(EntryBuffer_PostingDate; TempBankAccAdjustBufferCZL."Posting Date")
            {
            }
            column(EntryBuffer_CurrencyCode; TempBankAccAdjustBufferCZL."Currency Code")
            {
            }
            column(EntryBuffer_Number; Number)
            {
            }
            dataitem(BankAccountLedgerEntry; "Bank Account Ledger Entry")
            {
                DataItemTableView = sorting("Entry No.");
                column(BankAccountLedgerEntry_Amount; Amount)
                {
                    IncludeCaption = true;
                }
                column(BankAccountLedgerEntry_AmountLCY; "Amount (LCY)")
                {
                    IncludeCaption = true;
                }
                column(BankAccountLedgerEntry_DebitAmount; "Debit Amount")
                {
                    IncludeCaption = true;
                }
                column(BankAccountLedgerEntry_CreditAmount; "Credit Amount")
                {
                    IncludeCaption = true;
                }
                column(BankAccountLedgerEntry_Description; Description)
                {
                    IncludeCaption = true;
                }
                column(BankAccountLedgerEntry_PostingDate; "Posting Date")
                {
                    IncludeCaption = true;
                }
                column(BankAccountLedgerEntry_EntryNo; "Entry No.")
                {
                    IncludeCaption = true;
                }
                column(BankAccountLedgerEntry_CurrencyCode; "Currency Code")
                {
                    IncludeCaption = true;
                }
                trigger OnPreDataItem()
                begin
                    if not ShowDetail then
                        CurrReport.Break();

                    BankAccountLedgerEntry.CopyFilters(BankAccountLedgerEntryFilter);
                    if SortingType = SortingType::"Document No." then begin
                        BankAccountLedgerEntry.SetCurrentKey("Document No.");
                        BankAccountLedgerEntry.SetRange("Document No.", TempBankAccAdjustBufferCZL."Document No.");
                    end else
                        BankAccountLedgerEntry.SetRange("External Document No.", TempBankAccAdjustBufferCZL."Document No.");
                end;
            }
            trigger OnAfterGetRecord()
            begin
                if EntryBuffer.Number <> 1 then
                    if TempBankAccAdjustBufferCZL.Next() = 0 then
                        CurrReport.Break();

                if TempBankAccAdjustBufferCZL."Amount (LCY)" = 0 then
                    CurrReport.Skip();
            end;

            trigger OnPreDataItem()
            begin
                if not TempBankAccAdjustBufferCZL.FindSet() then
                    CurrReport.Quit();
            end;
        }
        dataitem(CurrencyBuffer; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = filter(1 ..));
            column(CurrencyBuffer_TotalAmount; TempEnhancedCurrencyBufferCZL."Total Amount")
            {
            }
            column(CurrencyBuffer_TotalAmountLCY; TempEnhancedCurrencyBufferCZL."Total Amount (LCY)")
            {
            }
            column(CurrencyBuffer_CurrencyCode; TempEnhancedCurrencyBufferCZL."Currency Code")
            {
            }
            column(CurrencyBuffer_TotalCreditAmount; TempEnhancedCurrencyBufferCZL."Total Credit Amount")
            {
            }
            column(CurrencyBuffer_TotalDebitAmount; TempEnhancedCurrencyBufferCZL."Total Debit Amount")
            {
            }
            column(CurrencyBuffer_Number; Number)
            {
            }
            trigger OnAfterGetRecord()
            begin
                if CurrencyBuffer.Number = 1 then
                    TempEnhancedCurrencyBufferCZL.FindSet()
                else
                    TempEnhancedCurrencyBufferCZL.Next();
            end;

            trigger OnPreDataItem()
            begin
                CurrencyBuffer.SetRange(Number, 1, TempEnhancedCurrencyBufferCZL.Count);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(SortingTypeField; SortingType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'By';
                        OptionCaption = 'Document No.,External Document No.,Combination';
                        ToolTip = 'Specifies type of sorting';
                    }
                    field(ShowDescriptionField; ShowDescription)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Description';
                        ToolTip = 'Specifies when the currency is to be show';
                    }
                    field(ShowPostingDateField; ShowPostingDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Posting Date';
                        ToolTip = 'Specifies when the posting date is to be show';
                    }
                    field(ShowDetailField; ShowDetail)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Detail';
                        ToolTip = 'Specifies when the detail is to be show';
                    }
                }
            }
        }
    }

    labels
    {
        ReportNameLbl = 'Joining Bank Account Adjustment';
        PageLbl = 'Page';
        DocumentNoLbl = 'Document No.';
        TotalLbl = 'Total';
    }

    trigger OnPreReport()
    begin
        if BankAccountLedgerEntryFilter.GetFilter("Bank Account No.") = '' then
            Error(EnterBankAccountNoFilterErr);
        if BankAccountLedgerEntryFilter.GetFilters() <> '' then
            BankAccountLedgerEntryFilters := BankAccountLedgerEntryFilter.GetFilters();
    end;

    var
        TempBankAccAdjustBufferCZL: Record "Bank Acc. Adjust. Buffer CZL" temporary;
        TempEnhancedCurrencyBufferCZL: Record "Enhanced Currency Buffer CZL" temporary;
        BankAccountLedgerEntryFilters: Text;
        WindowDialog: Dialog;
        i: Integer;
        j: Integer;
        SortingType: Option "Document No.","External Document No.",Combination;
        ShowDetail: Boolean;
        ShowDescription: Boolean;
        ShowPostingDate: Boolean;
        ProcessingEntriesMsg: Label 'Processing Entries @1@@@@@@@@@@@@';
        EnterBankAccountNoFilterErr: Label 'Please enter a Filter to Bank Account No..';

    local procedure GetDocumentNoBySortingType(BankAccountLedgerEntry: Record "Bank Account Ledger Entry"): Code[20]
    begin
        case SortingType of
            SortingType::"Document No.":
                exit(BankAccountLedgerEntry."Document No.");
            SortingType::"External Document No.":
                exit(CopyStr(BankAccountLedgerEntry."External Document No.", 1, MaxStrLen(BankAccountLedgerEntry."Document No.")));
            SortingType::Combination:
                begin
                    if BankAccountLedgerEntry."External Document No." <> '' then
                        exit(CopyStr(BankAccountLedgerEntry."External Document No.", 1, MaxStrLen(BankAccountLedgerEntry."Document No.")));
                    exit(BankAccountLedgerEntry."Document No.");
                end;
        end;
    end;
}
