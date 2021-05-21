report 11714 "Joining G/L Account Adj. CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/JoiningGLAccountAdj.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Joining G/L Account Adjustment';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(GLEntryFilter; "G/L Entry")
        {
            DataItemTableView = sorting("G/L Account No.", "Posting Date");
            RequestFilterFields = "G/L Account No.", "Document No.", "External Document No.";

            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(GLEntry_Filters; GLEntryFilters)
            {
            }

            trigger OnAfterGetRecord()
            var
                DocumentNo: Code[20];
            begin
                j := j + 1;
                WindowDialog.Update(1, Round((9999 / i) * j, 1));

                DocumentNo := GetDocumentNoBySortingType(GLEntryFilter);
                if TempGLAccountAdjustmentBuffer.Get(DocumentNo) then begin
                    TempGLAccountAdjustmentBuffer.Amount += GLEntryFilter.Amount;
                    TempGLAccountAdjustmentBuffer."Debit Amount" += GLEntryFilter."Debit Amount";
                    TempGLAccountAdjustmentBuffer."Credit Amount" += GLEntryFilter."Credit Amount";
                    if ShowPostingDate and (TempGLAccountAdjustmentBuffer."Posting Date" = 0D) and (GLEntryFilter."Posting Date" <> 0D) then
                        TempGLAccountAdjustmentBuffer."Posting Date" := GLEntryFilter."Posting Date";
                    if ShowDescription and (TempGLAccountAdjustmentBuffer.Description = '') and (GLEntryFilter.Description <> '') then
                        TempGLAccountAdjustmentBuffer.Description := GLEntryFilter.Description;
                    TempGLAccountAdjustmentBuffer.Modify();
                end else begin
                    TempGLAccountAdjustmentBuffer.Init();
                    TempGLAccountAdjustmentBuffer."Document No." := DocumentNo;
                    TempGLAccountAdjustmentBuffer.Amount := GLEntryFilter.Amount;
                    TempGLAccountAdjustmentBuffer."Debit Amount" := GLEntryFilter."Debit Amount";
                    TempGLAccountAdjustmentBuffer."Credit Amount" := GLEntryFilter."Credit Amount";
                    if ShowPostingDate then
                        TempGLAccountAdjustmentBuffer."Posting Date" := GLEntryFilter."Posting Date";
                    if ShowDescription then
                        TempGLAccountAdjustmentBuffer.Description := GLEntryFilter.Description;
                    TempGLAccountAdjustmentBuffer.Insert();
                end;
            end;

            trigger OnPreDataItem()
            begin
                i := Count;
                j := 0;
                WindowDialog.Open(ProcessingEntriesMsg);
            end;
        }
        dataitem(EntryBuffer; "Integer")
        {
            DataItemTableView = sorting(Number) WHERE(Number = FILTER(1 ..));
            column(EntryBuffer_DocumentNo; TempGLAccountAdjustmentBuffer."Document No.")
            {
            }
            column(EntryBuffer_Amount; TempGLAccountAdjustmentBuffer.Amount)
            {
            }
            column(EntryBuffer_DebitAmount; TempGLAccountAdjustmentBuffer."Debit Amount")
            {
            }
            column(EntryBuffer_CreditAmount; TempGLAccountAdjustmentBuffer."Credit Amount")
            {
            }
            column(EntryBuffer_Description; TempGLAccountAdjustmentBuffer.Description)
            {
            }
            column(EntryBuffer_PostingDate; TempGLAccountAdjustmentBuffer."Posting Date")
            {
            }
            dataitem(GLEntry; "G/L Entry")
            {
                DataItemTableView = sorting("Entry No.");
                column(GLEntry_Amount; Amount)
                {
                    IncludeCaption = true;
                }
                column(GLEntry_DebitAmount; "Debit Amount")
                {
                    IncludeCaption = true;
                }
                column(GLEntry_CreditAmount; "Credit Amount")
                {
                    IncludeCaption = true;
                }
                column(GLEntry_Description; Description)
                {
                    IncludeCaption = true;
                }
                column(GLEntry_PostingDate; "Posting Date")
                {
                    IncludeCaption = true;
                }
                column(GLEntry_EntryNo; "Entry No.")
                {
                    IncludeCaption = true;
                }
                trigger OnPreDataItem()
                begin
                    if not ShowDetail then
                        CurrReport.Break();

                    GLEntry.CopyFilters(GLEntryFilter);
                    if SortingType = 0 then begin
                        GLEntry.SetCurrentKey("Document No.");
                        GLEntry.SetRange("Document No.", TempGLAccountAdjustmentBuffer."Document No.");
                    end else
                        GLEntry.SetRange("External Document No.", TempGLAccountAdjustmentBuffer."Document No.");
                end;
            }
            trigger OnAfterGetRecord()
            begin
                if EntryBuffer.Number <> 1 then
                    if TempGLAccountAdjustmentBuffer.Next() = 0 then
                        CurrReport.Break();

                if TempGLAccountAdjustmentBuffer.Amount = 0 then
                    CurrReport.Skip();
            end;

            trigger OnPreDataItem()
            begin
                if not TempGLAccountAdjustmentBuffer.FindSet() then
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

    labels
    {
        PageLbl = 'Page';
        ReportNameLbl = 'Joining G/L Account Adjustment';
        DocumentNoLbl = 'Document No.';
        TotalLbl = 'Total';
    }

    trigger OnPreReport()
    begin
        if GLEntryFilter.GetFilter("G/L Account No.") = '' then
            Error(EmptyAccountNoFilterErr);
        if GLEntryFilter.GetFilters() <> '' then
            GLEntryFilters := GLEntryFilter.GetFilters();
    end;

    var
        TempGLAccountAdjustmentBuffer: Record "G/L Account Adjustment Buffer" temporary;
        WindowDialog: Dialog;
        GLEntryFilters: Text;
        SortingType: Option DocumentNo,ExternalDocumentNo,Combination;
        i: Integer;
        j: Integer;
        ShowDetail: Boolean;
        ShowDescription: Boolean;
        ShowPostingDate: Boolean;
        EmptyAccountNoFilterErr: Label 'Please enter a Filter to Account No..';
        ProcessingEntriesMsg: Label 'Processing Entries @1@@@@@@@@@@@@';

    local procedure GetDocumentNoBySortingType(GLEntry: Record "G/L Entry"): Code[20]
    begin
        case SortingType of
            SortingType::DocumentNo:
                exit(GLEntry."Document No.");
            SortingType::ExternalDocumentNo:
                exit(CopyStr(GLEntry."External Document No.", 1, MaxStrLen(GLEntry."Document No.")));
            SortingType::Combination:
                begin
                    if GLEntry."External Document No." <> '' then
                        exit(CopyStr(GLEntry."External Document No.", 1, MaxStrLen(GLEntry."Document No.")));
                    exit(GLEntry."Document No.");
                end;
        end;
    end;
}
