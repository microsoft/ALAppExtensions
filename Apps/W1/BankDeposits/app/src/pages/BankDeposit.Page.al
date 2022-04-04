page 1690 "Bank Deposit"
{
    Caption = 'Bank Deposit';
    DataCaptionExpression = FormCaption();
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Posting,Bank Deposit';
    SourceTable = "Bank Deposit Header";
    SourceTableView = SORTING("Journal Template Name", "Journal Batch Name");
    Permissions = tabledata "Bank Deposit Header" = rimd;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of the bank deposit that you are creating.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the bank account number to which this bank deposit is being made.';
                }
                field("Total Deposit Amount"; Rec."Total Deposit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount of the bank deposit. The sum of the amounts must equal this field value before you will be able to post this bank deposit.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(Difference; GetDifference())
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    Caption = 'Difference';
                    Editable = false;
                    ToolTip = 'Specifies the difference between the Amount field and the Cleared Amount field.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the date when the bank deposit should be posted. This should be the date that the bank deposit is deposited in the bank.';
                }
                field("Post as Lump Sum"; Rec."Post as Lump Sum")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies if the bank deposit should be posted as a single bank account ledger entry with the total amount.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date of the bank deposit document.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the dimension value code the bank deposit header will be associated with.';

                    trigger OnValidate()
                    begin
                        PropagateDimensionsToLines();
                    end;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the dimension value code the bank deposit header will be associated with.';

                    trigger OnValidate()
                    begin
                        PropagateDimensionsToLines();
                    end;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the currency that will be used for this Deposit.';
                }
            }
            part(Subform; "Bank Deposit Subform")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Journal Template Name" = FIELD("Journal Template Name"),
                              "Journal Batch Name" = FIELD("Journal Batch Name");
                UpdatePropagation = Both;
            }
        }
        area(factboxes)
        {
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Bank &Deposit")
            {
                Caption = 'Bank &Deposit';
                action(Comments)
                {
                    ApplicationArea = Comments;
                    Caption = 'Comments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "Bank Acc. Comment Sheet";
                    RunPageLink = "Bank Account No." = FIELD("Bank Account No."),
                                  "No." = FIELD("No.");
                    RunPageView = WHERE("Table Name" = CONST("Bank Deposit Header"));
                    ToolTip = 'View deposit comments that apply.';
                }
                action(Dimensions)
                {
                    ApplicationArea = Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    var
                        OriginalDimensionSetId: Integer;
                        NewDimensionSetID: Integer;
                    begin
                        OriginalDimensionSetId := Rec."Dimension Set ID";
                        Rec.ShowDocDim();
                        CurrPage.SaveRecord();
                        Rec.Find();
                        NewDimensionSetID := Rec."Dimension Set ID";
                        if (NewDimensionSetID = OriginalDimensionSetId) then
                            exit;
                        PropagateDimensionsToLines();
                    end;
                }
                separator(LineSeparator)
                {
                }
                action("Change &Batch")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Change &Batch';
                    Image = ChangeBatch;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ToolTip = 'Edit the journal batch that the bank deposit is based on.';

                    trigger OnAction()
                    begin
                        CurrPage.SaveRecord();
                        GenJnlManagement.LookupName(CurrentJnlBatchName, GenJournalLine);
                        if Rec."Journal Batch Name" <> CurrentJnlBatchName then begin
                            Clear(Rec);
                            SyncFormWithJournal();
                            OnChangeBatchActionOnAfterSyncFormWithJournal(GenJournalLine);
                        end;
                    end;
                }
            }
        }
        area(processing)
        {
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action("Test Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'View a test report so that you can find and correct any errors before you perform the actual posting of the journal or document.';

                    trigger OnAction()
                    var
                        ReportSelections: Record "Report Selections";
                        BankDepositHeader: Record "Bank Deposit Header";
                        IsHandled: Boolean;
                    begin
                        if BankDepositHeader.Get(Rec."No.") then begin
                            BankDepositHeader.SetRange("No.", Rec."No.");
                            BankDepositHeader.SetRange("Bank Account No.", Rec."Bank Account No.");
                        end;
                        IsHandled := false;
                        OnBeforePrintBankDeposit(BankDepositHeader, IsHandled);
                        if IsHandled then
                            exit;

                        ReportSelections.SetRange(Usage, ReportSelections.Usage::"Bank Deposit Test");
                        ReportSelections.SetRange("Report ID", Report::"Bank Deposit Test Report");
                        if not ReportSelections.FindFirst() then
                            Error(BankDepositReportSelectionErr);

                        REPORT.Run(ReportSelections."Report ID", true, false, BankDepositHeader);
                    end;
                }
                action(Post)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = Post;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Bank Deposit-Post (Yes/No)", Rec);
                    end;
                }
                action(PostAndPrint)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post and &Print';
                    Ellipsis = true;
                    Image = PostPrint;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';
                    ToolTip = 'Finalize and prepare to print the document or journal. The values and quantities are posted to the related accounts. A report request window where you can specify what to include on the print-out.';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Bank Deposit-Post + Print", Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields("Total Deposit Lines");
    end;

    trigger OnOpenPage()
    begin
        CurrentJnlBatchName := Rec."Journal Batch Name";
        if Rec."Journal Template Name" <> '' then begin
            GenJournalLine.FilterGroup(2);
            GenJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
            GenJournalLine.FilterGroup(0);
        end else begin
            GenJnlManagement.TemplateSelection(Page::"Bank Deposit", "Gen. Journal Template Type"::"Bank Deposits", false, GenJournalLine, JnlSelected);
            if not JnlSelected then
                Error('');
        end;
        if GenJournalLine.GetRangeMax("Journal Template Name") <> Rec."Journal Template Name" then
            CurrentJnlBatchName := '';
        GenJnlManagement.OpenJnl(CurrentJnlBatchName, GenJournalLine);
        SyncFormWithJournal();
    end;

    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJnlManagement: Codeunit GenJnlManagement;
        JnlSelected: Boolean;
        CurrentJnlBatchName: Code[10];
        BankDepositReportSelectionErr: Label 'Bank deposit test report has not been set up.';
        UpdateDimensionsOnExistingLinesQst: Label 'Do you want to add the bank deposit dimensions to all bank deposit lines?';

    local procedure GetDifference(): Decimal
    begin
        exit(Rec."Total Deposit Amount" - Rec."Total Deposit Lines");
    end;

    local procedure PropagateDimensionsToLines()
    var
        LocalGenJournalLine: Record "Gen. Journal Line";
        BankDepositPost: Codeunit "Bank Deposit-Post";
    begin
        LocalGenJournalLine.Reset();
        LocalGenJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
        LocalGenJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        if LocalGenJournalLine.FindSet() then
            if Confirm(UpdateDimensionsOnExistingLinesQst) then begin
                repeat
                    LocalGenJournalLine.Validate("Dimension Set ID", BankDepositPost.CombineDimensionSetsHeaderPriority(Rec, LocalGenJournalLine));
                    LocalGenJournalLine.Modify(true);
                until LocalGenJournalLine.Next() = 0;
                CurrPage.Subform.Page.Update(false);
            end;
    end;

    local procedure SyncFormWithJournal()
    begin
        GenJournalLine.FilterGroup(2);
        Rec.FilterGroup(2);
        GenJournalLine.CopyFilter("Journal Template Name", "Journal Template Name");
        GenJournalLine.CopyFilter("Journal Batch Name", "Journal Batch Name");
        Rec."Journal Template Name" := Rec.GetRangeMax("Journal Template Name");
        Rec."Journal Batch Name" := Rec.GetRangeMax("Journal Batch Name");
        Rec.FilterGroup(0);
        GenJournalLine.FilterGroup(0);
        if not Rec.Find('-') then;
    end;

    local procedure FormCaption(): Text[80]
    begin
        if Rec."No." = '' then
            exit(Rec.GetRangeMax("Journal Batch Name"));

        exit(Rec."No." + ' (' + Rec."Journal Batch Name" + ')');
    end;

    [IntegrationEvent(true, false)]
    local procedure OnChangeBatchActionOnAfterSyncFormWithJournal(var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintBankDeposit(var BankDepositHeader: Record "Bank Deposit Header"; var IsHandled: Boolean)
    begin
    end;
}

