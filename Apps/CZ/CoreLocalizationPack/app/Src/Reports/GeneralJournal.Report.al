report 11705 "General Journal CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/GeneralJournal.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'General Journal';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Date; Date)
        {
            DataItemTableView = sorting("Period Type", "Period Start") WHERE("Period Type" = CONST(Date));
            PrintOnlyIfDetail = true;
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(USERID; UserId)
            {
            }
            column(greTGLEntry_FIELDCAPTION__Posting_Date___________; TempGLEntry.FieldCaption("Posting Date") + ': ' + GetFilter("Period Start"))
            {
            }
            column(General_JournalCaption; General_JournalCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(greTGLEntry__Credit_Amount_Caption; TGLEntry__Credit_Amount_CaptionLbl)
            {
            }
            column(greTGLEntry__Debit_Amount_Caption; TGLEntry__Debit_Amount_CaptionLbl)
            {
            }
            column(greTGLEntry_DescriptionCaption; TGLEntry_DescriptionCaptionLbl)
            {
            }
            column(greTGLEntry__G_L_Account_No__Caption; TGLEntry__G_L_Account_No__CaptionLbl)
            {
            }
            column(greTGLEntry__External_Document_No__Caption; TGLEntry__External_Document_No__CaptionLbl)
            {
            }
            column(greTGLEntry__Document_No__Caption; TGLEntry__Document_No__CaptionLbl)
            {
            }
            column(greTGLEntry__Posting_Date_Caption; TGLEntry__Posting_Date_CaptionLbl)
            {
            }
            dataitem("G/L Entry"; "G/L Entry")
            {
                DataItemLink = "Posting Date" = field("Period Start");
                DataItemTableView = sorting("Posting Date", "G/L Account No.", "Dimension Set ID");

                trigger OnAfterGetRecord()
                begin
                    if Amount = 0 then
                        CurrReport.Skip();

                    if (RecordNo mod 100) = 0 then
                        Window.Update(2, Round(RecordNo / NoOfRecords * 10000, 1));
                    RecordNo := RecordNo + 1;

                    TempGLEntry.SetRange("Document No.", "Document No.");
                    TempGLEntry.SetRange("G/L Account No.", "G/L Account No.");
                    TempGLEntry.SetRange("Global Dimension 1 Code", "Global Dimension 1 Code");
                    TempGLEntry.SetRange("Global Dimension 2 Code", "Global Dimension 2 Code");
                    TempGLEntry.SetRange("Job No.", "Job No.");

                    if TempGLEntry.FindSet() and SumGLAccounts then begin
                        TempGLEntry."Debit Amount" += "Debit Amount";
                        TempGLEntry."Credit Amount" += "Credit Amount";
                        TempGLEntry.Modify();
                    end else begin
                        TempGLEntry.Init();
                        TempGLEntry.TransferFields("G/L Entry");
                        TempGLEntry.Insert();
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    Clear(RecordNo);
                    NoOfRecords := Count;
                end;
            }
            dataitem("Integer"; "Integer")
            {
                column(greTGLEntry__Posting_Date_; TempGLEntry."Posting Date")
                {
                }
                column(greTGLEntry__Document_No__; TempGLEntry."Document No.")
                {
                }
                column(greTGLEntry__External_Document_No__; TempGLEntry."External Document No.")
                {
                }
                column(greTGLEntry__G_L_Account_No__; TempGLEntry."G/L Account No.")
                {
                }
                column(greTGLEntry_Description; TempGLEntry.Description)
                {
                }
                column(greTGLEntry__Debit_Amount_; TempGLEntry."Debit Amount")
                {
                }
                column(greTGLEntry__Credit_Amount_; TempGLEntry."Credit Amount")
                {
                }
                column(Integer_Number; Number)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempGLEntry.FindSet()
                    else
                        TempGLEntry.Next();

                    GLAccount.Get(TempGLEntry."G/L Account No.");
                end;

                trigger OnPostDataItem()
                begin
                    TempGLEntry.DeleteAll();
                end;

                trigger OnPreDataItem()
                begin
                    TempGLEntry.Reset();
                    TempGLEntry.SetCurrentKey("Document No.", "Posting Date");

                    SetRange(Number, 1, TempGLEntry.Count);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                Window.Update(1, "Period Start");
                Window.Update(2, 0);
            end;

            trigger OnPostDataItem()
            begin
                Window.Close();
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Period Start", FromDate, ToDate);

                Window.Open(ProcessingDateMsg + ProgressMsg);
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
                    field(FromDateField; FromDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'From Date';
                        ToolTip = 'Specifies the first date of period.';
                    }
                    field(ToDateField; ToDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'To Date';
                        ToolTip = 'Specifies report to date';
                    }
                    field(SumGLAccountsField; SumGLAccounts)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Sum Identical G/L Account';
                        ToolTip = 'Specifies if the identical G/L account have to be sumed.';
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        if FromDate = 0D then
            Error(FromDateErr);
    end;

    var
        GLAccount: Record "G/L Account";
        TempGLEntry: Record "G/L Entry" temporary;
        FromDateErr: Label 'Enter the value "From Date".';
        ProcessingDateMsg: Label 'Processing Date #1#########\\', Comment = '#1 = date of period';
        ProgressMsg: Label 'Progress @2@@@@@@@@@@@@@';
        General_JournalCaptionLbl: Label 'General Journal';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        TGLEntry__Credit_Amount_CaptionLbl: Label 'Credit Amount';
        TGLEntry__Debit_Amount_CaptionLbl: Label 'Debit Amount';
        TGLEntry_DescriptionCaptionLbl: Label 'Description';
        TGLEntry__G_L_Account_No__CaptionLbl: Label 'G/L Account No.';
        TGLEntry__External_Document_No__CaptionLbl: Label 'External Document No.';
        TGLEntry__Document_No__CaptionLbl: Label 'Document No.';
        TGLEntry__Posting_Date_CaptionLbl: Label 'Posting Date';
        Window: Dialog;
        RecordNo: Integer;
        NoOfRecords: Integer;
        SumGLAccounts: Boolean;
        FromDate: Date;
        ToDate: Date;
}
