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
                if TempBankAccAdjustmentBuffer.Get(DocumentNo) then begin
                    if TempBankAccAdjustmentBuffer.Valid and (TempBankAccAdjustmentBuffer."Currency Code" = BankAccountLedgerEntryFilter."Currency Code") then begin
                        TempBankAccAdjustmentBuffer.Amount += BankAccountLedgerEntryFilter.Amount;
                        TempBankAccAdjustmentBuffer."Debit Amount" += BankAccountLedgerEntryFilter."Debit Amount";
                        TempBankAccAdjustmentBuffer."Credit Amount" += BankAccountLedgerEntryFilter."Credit Amount";
                    end else begin
                        TempBankAccAdjustmentBuffer.Amount := 0;
                        TempBankAccAdjustmentBuffer."Debit Amount" := 0;
                        TempBankAccAdjustmentBuffer."Credit Amount" := 0;
                        TempBankAccAdjustmentBuffer.Valid := false;
                    end;
                    TempBankAccAdjustmentBuffer."Amount (LCY)" += BankAccountLedgerEntryFilter."Amount (LCY)";
                    if ShowPostingDate and (TempBankAccAdjustmentBuffer."Posting Date" = 0D) and (BankAccountLedgerEntryFilter."Posting Date" <> 0D) then
                        TempBankAccAdjustmentBuffer."Posting Date" := BankAccountLedgerEntryFilter."Posting Date";
                    if ShowDescription and (TempBankAccAdjustmentBuffer.Description = '') and (BankAccountLedgerEntryFilter.Description <> '') then
                        TempBankAccAdjustmentBuffer.Description := BankAccountLedgerEntryFilter.Description;
                    TempBankAccAdjustmentBuffer.Modify();
                end else begin
                    TempBankAccAdjustmentBuffer.Init();
                    TempBankAccAdjustmentBuffer."Document No." := DocumentNo;
                    TempBankAccAdjustmentBuffer.Amount := BankAccountLedgerEntryFilter.Amount;
                    TempBankAccAdjustmentBuffer."Debit Amount" := BankAccountLedgerEntryFilter."Debit Amount";
                    TempBankAccAdjustmentBuffer."Credit Amount" := BankAccountLedgerEntryFilter."Credit Amount";
                    TempBankAccAdjustmentBuffer."Amount (LCY)" := BankAccountLedgerEntryFilter."Amount (LCY)";
                    TempBankAccAdjustmentBuffer."Currency Code" := BankAccountLedgerEntryFilter."Currency Code";
                    if ShowPostingDate then
                        TempBankAccAdjustmentBuffer."Posting Date" := BankAccountLedgerEntryFilter."Posting Date";
                    if ShowDescription then
                        TempBankAccAdjustmentBuffer.Description := BankAccountLedgerEntryFilter.Description;
                    TempBankAccAdjustmentBuffer.Valid := true;
                    TempBankAccAdjustmentBuffer.Insert();
                end;

                if TempEnhancedCurrencyBuffer.Get(BankAccountLedgerEntryFilter."Currency Code") then begin
                    TempEnhancedCurrencyBuffer."Total Amount" += BankAccountLedgerEntryFilter.Amount;
                    TempEnhancedCurrencyBuffer."Total Amount (LCY)" += BankAccountLedgerEntryFilter."Amount (LCY)";
                    TempEnhancedCurrencyBuffer."Total Credit Amount" += BankAccountLedgerEntryFilter."Credit Amount";
                    TempEnhancedCurrencyBuffer."Total Debit Amount" += BankAccountLedgerEntryFilter."Debit Amount";
                    TempEnhancedCurrencyBuffer.Counter += 1;
                    TempEnhancedCurrencyBuffer.Modify();
                end else begin
                    TempEnhancedCurrencyBuffer.Init();
                    TempEnhancedCurrencyBuffer."Currency Code" := BankAccountLedgerEntryFilter."Currency Code";
                    TempEnhancedCurrencyBuffer."Total Amount" := BankAccountLedgerEntryFilter.Amount;
                    TempEnhancedCurrencyBuffer."Total Amount (LCY)" := BankAccountLedgerEntryFilter."Amount (LCY)";
                    TempEnhancedCurrencyBuffer."Total Credit Amount" := BankAccountLedgerEntryFilter."Credit Amount";
                    TempEnhancedCurrencyBuffer."Total Debit Amount" := BankAccountLedgerEntryFilter."Debit Amount";
                    TempEnhancedCurrencyBuffer.Counter := 1;
                    TempEnhancedCurrencyBuffer.Insert();
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
            DataItemTableView = sorting(Number) WHERE(Number = FILTER(1 ..));
            column(EntryBuffer_DocumentNo; TempBankAccAdjustmentBuffer."Document No.")
            {
            }
            column(EntryBuffer_Amount; TempBankAccAdjustmentBuffer.Amount)
            {
            }
            column(EntryBuffer_AmountLCY; TempBankAccAdjustmentBuffer."Amount (LCY)")
            {
            }
            column(EntryBuffer_DebitAmount; TempBankAccAdjustmentBuffer."Debit Amount")
            {
            }
            column(EntryBuffer_CreditAmount; TempBankAccAdjustmentBuffer."Credit Amount")
            {
            }
            column(EntryBuffer_Description; TempBankAccAdjustmentBuffer.Description)
            {
            }
            column(EntryBuffer_PostingDate; TempBankAccAdjustmentBuffer."Posting Date")
            {
            }
            column(EntryBuffer_CurrencyCode; TempBankAccAdjustmentBuffer."Currency Code")
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
                        BankAccountLedgerEntry.SetRange("Document No.", TempBankAccAdjustmentBuffer."Document No.");
                    end else
                        BankAccountLedgerEntry.SetRange("External Document No.", TempBankAccAdjustmentBuffer."Document No.");
                end;
            }
            trigger OnAfterGetRecord()
            begin
                if EntryBuffer.Number <> 1 then
                    if TempBankAccAdjustmentBuffer.Next() = 0 then
                        CurrReport.Break();

                if TempBankAccAdjustmentBuffer."Amount (LCY)" = 0 then
                    CurrReport.Skip();
            end;

            trigger OnPreDataItem()
            begin
                if not TempBankAccAdjustmentBuffer.FindSet() then
                    CurrReport.Quit();
            end;
        }
        dataitem(CurrencyBuffer; "Integer")
        {
            DataItemTableView = sorting(Number) WHERE(Number = FILTER(1 ..));
            column(CurrencyBuffer_TotalAmount; TempEnhancedCurrencyBuffer."Total Amount")
            {
            }
            column(CurrencyBuffer_TotalAmountLCY; TempEnhancedCurrencyBuffer."Total Amount (LCY)")
            {
            }
            column(CurrencyBuffer_CurrencyCode; TempEnhancedCurrencyBuffer."Currency Code")
            {
            }
            column(CurrencyBuffer_TotalCreditAmount; TempEnhancedCurrencyBuffer."Total Credit Amount")
            {
            }
            column(CurrencyBuffer_TotalDebitAmount; TempEnhancedCurrencyBuffer."Total Debit Amount")
            {
            }
            column(CurrencyBuffer_Number; Number)
            {
            }
            trigger OnAfterGetRecord()
            begin
                if CurrencyBuffer.Number = 1 then
                    TempEnhancedCurrencyBuffer.FindSet()
                else
                    TempEnhancedCurrencyBuffer.Next();
            end;

            trigger OnPreDataItem()
            begin
                CurrencyBuffer.SetRange(Number, 1, TempEnhancedCurrencyBuffer.Count);
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
        TempBankAccAdjustmentBuffer: Record "Bank Acc. Adjustment Buffer" temporary;
        TempEnhancedCurrencyBuffer: Record "Enhanced Currency Buffer" temporary;
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
