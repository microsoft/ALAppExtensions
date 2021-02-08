report 11713 "Joining Bank. Acc. Adj. CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/JoiningBankAccAdj.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Joining Banking Account Adjustment';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Bank Account Ledger Entry"; "Bank Account Ledger Entry")
        {
            DataItemTableView = sorting("Bank Account No.", "Posting Date");
            RequestFilterFields = "Bank Account No.", "Document No.", "External Document No.";

            trigger OnAfterGetRecord()
            var
                lcoDocNo: Code[20];
            begin
                j := j + 1;
                Window.Update(1, Round((9999 / i) * j, 1));
                case SortingType of
                    0:
                        lcoDocNo := "Document No.";
                    1:
                        lcoDocNo := CopyStr("External Document No.", 1, MaxStrLen(lcoDocNo));
                    2:
                        if "External Document No." <> '' then
                            lcoDocNo := CopyStr("External Document No.", 1, MaxStrLen(lcoDocNo))
                        else
                            lcoDocNo := "Document No.";
                end;
                if TempBuffer.Get(lcoDocNo) then begin
                    if TempBuffer.Valid and (TempBuffer."Currency Code" = "Currency Code") then begin
                        TempBuffer.Amount := TempBuffer.Amount + "Bank Account Ledger Entry".Amount;
                        TempBuffer."Debit Amount" := TempBuffer."Debit Amount" + "Debit Amount";
                        TempBuffer."Credit Amount" := TempBuffer."Credit Amount" + "Credit Amount";
                    end
                    else begin
                        TempBuffer.Amount := 0;
                        TempBuffer."Debit Amount" := 0;
                        TempBuffer."Credit Amount" := 0;
                        TempBuffer.Valid := false;
                    end;
                    TempBuffer."Amount (LCY)" := TempBuffer."Amount (LCY)" + "Amount (LCY)";
                    if ShowPostingDate and (TempBuffer."Posting Date" = 0D) and ("Posting Date" <> 0D) then
                        TempBuffer."Posting Date" := "Posting Date";
                    if ShowDescription and (TempBuffer.Description = '') and (Description <> '') then
                        TempBuffer.Description := Description;
                    TempBuffer.Modify();
                end else begin
                    TempBuffer.Init();
                    TempBuffer."Document No." := lcoDocNo;
                    TempBuffer.Amount := "Bank Account Ledger Entry".Amount;
                    TempBuffer."Debit Amount" := "Debit Amount";
                    TempBuffer."Credit Amount" := "Credit Amount";
                    TempBuffer."Amount (LCY)" := "Amount (LCY)";
                    TempBuffer."Currency Code" := "Currency Code";
                    if ShowPostingDate then
                        TempBuffer."Posting Date" := "Posting Date";
                    if ShowDescription then
                        TempBuffer.Description := Description;
                    TempBuffer.Valid := true;
                    TempBuffer.Insert();
                end;

                if TempCurrBuffer.Get("Currency Code") then begin
                    TempCurrBuffer."Total Amount" += Amount;
                    TempCurrBuffer."Total Amount (LCY)" += "Amount (LCY)";
                    TempCurrBuffer."Total Credit Amount" += "Credit Amount";
                    TempCurrBuffer."Total Debit Amount" += "Debit Amount";
                    TempCurrBuffer.Counter += 1;
                    TempCurrBuffer.Modify();
                end else begin
                    TempCurrBuffer.Init();
                    TempCurrBuffer."Currency Code" := "Currency Code";
                    TempCurrBuffer."Total Amount" := Amount;
                    TempCurrBuffer."Total Amount (LCY)" := "Amount (LCY)";
                    TempCurrBuffer."Total Credit Amount" := "Credit Amount";
                    TempCurrBuffer."Total Debit Amount" := "Debit Amount";
                    TempCurrBuffer.Counter := 1;
                    TempCurrBuffer.Insert();
                end;
            end;

            trigger OnPreDataItem()
            begin
                Filter := CopyStr("Bank Account Ledger Entry".GetFilters, 1, MaxStrLen(Filter));

                if GetFilter("Bank Account No.") = '' then
                    Error(EnterBankAccountNoFilterErr);

                i := Count;
                j := 0;
                Window.Open(ProcessingEntriesMsg);
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = sorting(Number) WHERE(Number = FILTER(1 ..));
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(Joining_Bank_Account_AdjustmentCaption; Joining_Bank_Account_AdjustmentCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(gteFilter; Filter)
            {
            }
            column(greTBuffer__Document_No__; TempBuffer."Document No.")
            {
            }
            column(greTBuffer_Amount; TempBuffer.Amount)
            {
            }
            column(greTBuffer__Debit_Amount_; TempBuffer."Debit Amount")
            {
            }
            column(greTBuffer__Credit_Amount_; TempBuffer."Credit Amount")
            {
            }
            column(greTBuffer_Description; TempBuffer.Description)
            {
            }
            column(greTBuffer__Posting_Date_; TempBuffer."Posting Date")
            {
            }
            column(greTBuffer__Currency_Code_; TempBuffer."Currency Code")
            {
            }
            column(greTBuffer__Amount__LCY__; TempBuffer."Amount (LCY)")
            {
            }
            column(greTBuffer__Document_No__Caption; TBuffer__Document_No__CaptionLbl)
            {
            }
            column(Bank_Account_Ledger_Entry_2_AmountCaption; "Bank Account Ledger Entry 2".FieldCaption(Amount))
            {
            }
            column(Bank_Account_Ledger_Entry_2__Debit_Amount_Caption; "Bank Account Ledger Entry 2".FieldCaption("Debit Amount"))
            {
            }
            column(Bank_Account_Ledger_Entry_2__Credit_Amount_Caption; "Bank Account Ledger Entry 2".FieldCaption("Credit Amount"))
            {
            }
            column(Bank_Account_Ledger_Entry_2_DescriptionCaption; "Bank Account Ledger Entry 2".FieldCaption(Description))
            {
            }
            column(Bank_Account_Ledger_Entry_2__Posting_Date_Caption; "Bank Account Ledger Entry 2".FieldCaption("Posting Date"))
            {
            }
            column(Bank_Account_Ledger_Entry_2__Entry_No__Caption; "Bank Account Ledger Entry 2".FieldCaption("Entry No."))
            {
            }
            column(Bank_Account_Ledger_Entry_2__Amount__LCY__Caption; "Bank Account Ledger Entry 2".FieldCaption("Amount (LCY)"))
            {
            }
            column(Bank_Account_Ledger_Entry_2__Currency_Code_Caption; "Bank Account Ledger Entry 2".FieldCaption("Currency Code"))
            {
            }
            column(CurrReport_PAGENO_Control25Caption; CurrReport_PAGENO_Control25CaptionLbl)
            {
            }
            column(Joining_Bank_Account_AdjustmentCaption_Control33; Joining_Bank_Account_AdjustmentCaption_Control33Lbl)
            {
            }
            column(Bank_Account_Ledger_Entry_2_DescriptionCaption_Control34; "Bank Account Ledger Entry 2".FieldCaption(Description))
            {
            }
            column(Bank_Account_Ledger_Entry_2__Credit_Amount_Caption_Control35; "Bank Account Ledger Entry 2".FieldCaption("Credit Amount"))
            {
            }
            column(Bank_Account_Ledger_Entry_2__Debit_Amount_Caption_Control36; "Bank Account Ledger Entry 2".FieldCaption("Debit Amount"))
            {
            }
            column(Bank_Account_Ledger_Entry_2_AmountCaption_Control37; "Bank Account Ledger Entry 2".FieldCaption(Amount))
            {
            }
            column(greTBuffer__Document_No__Caption_Control38; TBuffer__Document_No__Caption_Control38Lbl)
            {
            }
            column(Bank_Account_Ledger_Entry_2__Posting_Date_Caption_Control40; "Bank Account Ledger Entry 2".FieldCaption("Posting Date"))
            {
            }
            column(Bank_Account_Ledger_Entry_2__Currency_Code_Caption_Control1100162003; "Bank Account Ledger Entry 2".FieldCaption("Currency Code"))
            {
            }
            column(Bank_Account_Ledger_Entry_2__Amount__LCY__Caption_Control1100162004; "Bank Account Ledger Entry 2".FieldCaption("Amount (LCY)"))
            {
            }
            column(Bank_Account_Ledger_Entry_2__Entry_No__Caption_Control1100162005; "Bank Account Ledger Entry 2".FieldCaption("Entry No."))
            {
            }
            column(Integer_Number; Number)
            {
            }
            dataitem("Bank Account Ledger Entry 2"; "Bank Account Ledger Entry")
            {
                DataItemTableView = sorting("Entry No.");
                column(Bank_Account_Ledger_Entry_2_Amount; Amount)
                {
                }
                column(Bank_Account_Ledger_Entry_2__Debit_Amount_; "Debit Amount")
                {
                }
                column(Bank_Account_Ledger_Entry_2__Credit_Amount_; "Credit Amount")
                {
                }
                column(Bank_Account_Ledger_Entry_2_Description; Description)
                {
                }
                column(Bank_Account_Ledger_Entry_2__Posting_Date_; "Posting Date")
                {
                }
                column(Bank_Account_Ledger_Entry_2__Entry_No__; "Entry No.")
                {
                }
                column(Bank_Account_Ledger_Entry_2__Currency_Code_; "Currency Code")
                {
                }
                column(Bank_Account_Ledger_Entry_2__Amount__LCY__; "Amount (LCY)")
                {
                }
                trigger OnPreDataItem()
                begin
                    if not ShowDetail then
                        CurrReport.Break();

                    CopyFilters("Bank Account Ledger Entry");
                    if SortingType = 0 then begin
                        SetCurrentKey("Document No.");
                        SetRange("Document No.", TempBuffer."Document No.");
                    end else
                        SetRange("External Document No.", TempBuffer."Document No.");
                end;
            }
            trigger OnAfterGetRecord()
            begin
                if Number <> 1 then
                    if TempBuffer.Next() = 0 then
                        CurrReport.Break();

                if TempBuffer."Amount (LCY)" = 0 then
                    CurrReport.Skip();
            end;

            trigger OnPreDataItem()
            begin
                if not TempBuffer.FindSet() then
                    CurrReport.Quit();
            end;
        }
        dataitem("Currency Summary"; "Integer")
        {
            DataItemTableView = sorting(Number) WHERE(Number = FILTER(1 ..));
            column(greTCurrBuffer__Total_Amount__LCY__; TempCurrBuffer."Total Amount (LCY)")
            {
            }
            column(greTCurrBuffer__Currency_Code_; TempCurrBuffer."Currency Code")
            {
            }
            column(greTCurrBuffer__Total_Credit_Amount_; TempCurrBuffer."Total Credit Amount")
            {
            }
            column(greTCurrBuffer__Total_Debit_Amount_; TempCurrBuffer."Total Debit Amount")
            {
            }
            column(greTCurrBuffer__Total_Amount_; TempCurrBuffer."Total Amount")
            {
            }
            column(greTCurrBuffer__Total_Amount_Caption; TCurrBuffer__Total_Amount_CaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            column(greTCurrBuffer__Currency_Code_Caption; TCurrBuffer__Currency_Code_CaptionLbl)
            {
            }
            column(greTCurrBuffer__Total_Amount__LCY__Caption; TCurrBuffer__Total_Amount__LCY__CaptionLbl)
            {
            }
            column(greTCurrBuffer__Total_Debit_Amount_Caption; TCurrBuffer__Total_Debit_Amount_CaptionLbl)
            {
            }
            column(greTCurrBuffer__Total_Credit_Amount_Caption; TCurrBuffer__Total_Credit_Amount_CaptionLbl)
            {
            }
            column(Currency_Summary_Number; Number)
            {
            }
            trigger OnAfterGetRecord()
            begin
                if Number = 1 then
                    TempCurrBuffer.FindSet()
                else
                    TempCurrBuffer.Next();
            end;

            trigger OnPreDataItem()
            begin
                SetRange(Number, 1, TempCurrBuffer.Count);
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
    var
        TempBuffer: Record "Bank Acc. Adjustment Buffer" temporary;
        TempCurrBuffer: Record "Enhanced Currency Buffer" temporary;
        "Filter": Text[250];
        Window: Dialog;
        i: Integer;
        j: Integer;
        SortingType: Option "Document No.","External Document No.",Combination;
        ShowDetail: Boolean;
        ShowDescription: Boolean;
        ShowPostingDate: Boolean;
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Joining_Bank_Account_AdjustmentCaptionLbl: Label 'Joining Bank Account Adjustment';
        TBuffer__Document_No__CaptionLbl: Label 'Document No.';
        CurrReport_PAGENO_Control25CaptionLbl: Label 'Page';
        Joining_Bank_Account_AdjustmentCaption_Control33Lbl: Label 'Joining Bank Account Adjustment';
        TBuffer__Document_No__Caption_Control38Lbl: Label 'Document No.';
        TCurrBuffer__Total_Amount_CaptionLbl: Label 'Amount';
        TotalCaptionLbl: Label 'Total';
        TCurrBuffer__Currency_Code_CaptionLbl: Label 'Currency Code';
        TCurrBuffer__Total_Amount__LCY__CaptionLbl: Label 'Amount (LCY)';
        TCurrBuffer__Total_Debit_Amount_CaptionLbl: Label 'Debit Amount';
        TCurrBuffer__Total_Credit_Amount_CaptionLbl: Label 'Credit Amount';
        ProcessingEntriesMsg: Label 'Processing Entries @1@@@@@@@@@@@@';
        EnterBankAccountNoFilterErr: Label 'Please enter a Filter to Bank Account No..';
}
