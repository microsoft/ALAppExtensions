namespace Microsoft.Finance.Analysis.StatisticalAccount;

page 2630 "Statistical Acc. Journal Batch"
{
    Caption = 'Statistical Account Journal Batch';
    SourceTable = "Statistical Acc. Journal Batch";
    PageType = List;

    layout
    {
        area(content)
        {
            repeater(MainGroup)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the journal.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a brief description of the journal batch you are creating.';
                }
                field(StatisticalAccountNo; Rec."Statistical Account No.")
                {
                    ApplicationArea = All;
                    Caption = 'Statistical Account No.';
                    ToolTip = 'Specifies the account number that the entry on the journal line will be posted to.';
                }
                field(AccountName; Rec."Statistical Account Name")
                {
                    ApplicationArea = All;
                    Caption = 'Statistical Account Name';
                    Editable = false;
                    ToolTip = 'Specifies the account name that the entry on the journal line will be posted to.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Process)
            {
                action(EditJournal)
                {
                    ApplicationArea = All;
                    Caption = 'Edit Journal';
                    Image = OpenWorksheet;
                    ShortCutKey = 'Return';
                    ToolTip = 'Modify an existing statistical account journal.';

                    trigger OnAction()
                    begin
                        OpenWorksheet();
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref(EditJournal_Promoted; EditJournal)
                {
                }
            }
        }
    }

    local procedure OpenWorksheet()
    var
        StatisticalAccJournalLine: Record "Statistical Acc. Journal Line";
    begin
        StatisticalAccJournalLine.FilterGroup := 2;
        StatisticalAccJournalLine.SetRange("Journal Batch Name", Rec.Name);
        StatisticalAccJournalLine.FilterGroup := 0;
        if StatisticalAccJournalLine.FindFirst() then;
        Page.Run(Page::"Statistical Accounts Journal", StatisticalAccJournalLine);
    end;
}

