report 11714 "Joining G/L Account Adj. CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/JoiningGLAccountAdj.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Joining G/L Account Adjustment';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("G/L Entry"; "G/L Entry")
        {
            DataItemTableView = sorting("G/L Account No.", "Posting Date");
            RequestFilterFields = "G/L Account No.", "Document No.", "External Document No.";

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
                    TempBuffer.Amount := TempBuffer.Amount + "G/L Entry".Amount;
                    TempBuffer."Debit Amount" := TempBuffer."Debit Amount" + "Debit Amount";
                    TempBuffer."Credit Amount" := TempBuffer."Credit Amount" + "Credit Amount";
                    if ShowPostingDate and (TempBuffer."Posting Date" = 0D) and ("Posting Date" <> 0D) then
                        TempBuffer."Posting Date" := "Posting Date";
                    if ShowDescription and (TempBuffer.Description = '') and (Description <> '') then
                        TempBuffer.Description := Description;
                    TempBuffer.Modify();
                end else begin
                    TempBuffer.Init();
                    TempBuffer."Document No." := lcoDocNo;
                    TempBuffer.Amount := "G/L Entry".Amount;
                    TempBuffer."Debit Amount" := "Debit Amount";
                    TempBuffer."Credit Amount" := "Credit Amount";
                    if ShowPostingDate then
                        TempBuffer."Posting Date" := "Posting Date";
                    if ShowDescription then
                        TempBuffer.Description := Description;
                    TempBuffer.Insert();
                end;
            end;

            trigger OnPreDataItem()
            begin
                if GetFilter("G/L Account No.") = '' then
                    Error(EmptyAccountNoFilterErr);

                Filter := CopyStr("G/L Entry".GetFilters, 1, MaxStrLen(Filter));
                i := Count;
                j := 0;
                Window.Open(ProcessingEntriesMsg);
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = sorting(Number) WHERE(Number = FILTER(1 ..));
            column(USERID; UserId)
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
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
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Joining_G_L_Account_AdjustmentCaption; Joining_G_L_Account_AdjustmentCaptionLbl)
            {
            }
            column(greTBuffer__Document_No__Caption; TBuffer__Document_No__CaptionLbl)
            {
            }
            column(G_L_Entry2_AmountCaption; "G/L Entry2".FieldCaption(Amount))
            {
            }
            column(G_L_Entry2__Debit_Amount_Caption; "G/L Entry2".FieldCaption("Debit Amount"))
            {
            }
            column(G_L_Entry2__Credit_Amount_Caption; "G/L Entry2".FieldCaption("Credit Amount"))
            {
            }
            column(G_L_Entry2_DescriptionCaption; "G/L Entry2".FieldCaption(Description))
            {
            }
            column(G_L_Entry2__Posting_Date_Caption; "G/L Entry2".FieldCaption("Posting Date"))
            {
            }
            column(G_L_Entry2__Entry_No__Caption; "G/L Entry2".FieldCaption("Entry No."))
            {
            }
            column(G_L_Entry2_DescriptionCaption_Control34; "G/L Entry2".FieldCaption(Description))
            {
            }
            column(G_L_Entry2__Credit_Amount_Caption_Control35; "G/L Entry2".FieldCaption("Credit Amount"))
            {
            }
            column(G_L_Entry2__Debit_Amount_Caption_Control36; "G/L Entry2".FieldCaption("Debit Amount"))
            {
            }
            column(G_L_Entry2_AmountCaption_Control37; "G/L Entry2".FieldCaption(Amount))
            {
            }
            column(greTBuffer__Document_No__Caption_Control38; TBuffer__Document_No__Caption_Control38Lbl)
            {
            }
            column(G_L_Entry2__Posting_Date_Caption_Control40; "G/L Entry2".FieldCaption("Posting Date"))
            {
            }
            column(G_L_Entry2__Entry_No__Caption_Control1100162001; "G/L Entry2".FieldCaption("Entry No."))
            {
            }
            column(gdeTotalCaption; TotalCaptionLbl)
            {
            }
            column(Integer_Number; Number)
            {
            }
            dataitem("G/L Entry2"; "G/L Entry")
            {
                DataItemTableView = sorting("Entry No.");
                column(G_L_Entry2_Amount; Amount)
                {
                }
                column(G_L_Entry2__Debit_Amount_; "Debit Amount")
                {
                }
                column(G_L_Entry2__Credit_Amount_; "Credit Amount")
                {
                }
                column(G_L_Entry2_Description; Description)
                {
                }
                column(G_L_Entry2__Posting_Date_; "Posting Date")
                {
                }
                column(G_L_Entry2__Entry_No__; "Entry No.")
                {
                }
                column(gboDetail; ShowDetail)
                {
                }
                trigger OnPreDataItem()
                begin
                    if not ShowDetail then
                        CurrReport.Break();

                    CopyFilters("G/L Entry");
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

                if TempBuffer.Amount = 0 then
                    CurrReport.Skip();
            end;

            trigger OnPreDataItem()
            begin
                if not TempBuffer.FindSet() then
                    CurrReport.Quit();
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
        TempBuffer: Record "G/L Account Adjustment Buffer" temporary;
        Window: Dialog;
        "Filter": Text[250];
        SortingType: Option DocumentNo,ExternalDocumentNo,Combination;
        i: Integer;
        j: Integer;
        ShowDetail: Boolean;
        ShowDescription: Boolean;
        ShowPostingDate: Boolean;
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Joining_G_L_Account_AdjustmentCaptionLbl: Label 'Joining G/L Account Adjustment';
        TBuffer__Document_No__CaptionLbl: Label 'Document No.';
        TBuffer__Document_No__Caption_Control38Lbl: Label 'Document No.';
        TotalCaptionLbl: Label 'Total';
        EmptyAccountNoFilterErr: Label 'Please enter a Filter to Account No..';
        ProcessingEntriesMsg: Label 'Processing Entries @1@@@@@@@@@@@@';
}
