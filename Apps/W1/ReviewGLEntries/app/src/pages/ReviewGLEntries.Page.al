namespace Microsoft.Finance.GeneralLedger.Review;

using Microsoft.Finance.GeneralLedger.Ledger;
using System.Telemetry;
using System.Utilities;
using Microsoft.Finance.GeneralLedger.Account;

page 22207 "Review G/L Entries"
{
    Caption = 'Review G/L Entries';
    DataCaptionExpression = GetCaption();
    DeleteAllowed = false;
    InsertAllowed = false;
    ApplicationArea = Basic, Suite;
    PageType = List;
    Permissions = tabledata "G/L Entry" = rimd,
                  tabledata "G/L Entry Review Setup" = ri;
    SourceTableView = sorting("G/L Account No.", "Posting Date")
                      order(descending);
    SourceTable = "G/L Entry";
    AboutTitle = 'About Review G/L Entries';
    AboutText = 'Select one or more entries by marking one and marking a second one while holding down either CTRL or SHIFT while marking entries. On this page you manually mark entries as reviewed according to the given review policy, which is specified on the G/L Account. When you review one or more entries, they are given a unique common identifier, the data can be opened in Excel';

    layout
    {
        area(content)
        {
            repeater(Overview)
            {
                ShowCaption = false;
                field(Reviewed; Rec.Reviewed)
                {
                    ApplicationArea = Basic, Suite;
                    Width = 8;
                    Editable = false;
                    ToolTip = 'Specifies if an entry is marked as reviewed.';
                    AboutTitle = 'About reviewed?';
                    AboutText = 'In this column you can see which entries have already been marked as reviewed and which has not, you can easily filter on this or use the Hide/Show actions';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the date when the G/L entries were posted.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the amount that will be applied.';
                }
                field("Credit Amount"; Rec."Credit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the credit amount that will be applied.';
                }
                field("Debit Amount"; Rec."Debit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the debit amount that will be applied.';
                }
                field(Account; Rec."G/L Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the account no. that will be applied.';
                }
                field(Reviewer; Rec."Reviewed By")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies a code for the ID when you set entries as reviewed.';
                    AboutTitle = 'About Reviewer?';
                    AboutText = 'When an entry has been marked as reviewed, you can see the name of that person';
                }
                field("Reviewed Date"; Rec."Reviewed Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the time when the ledger entries were reviewed.';
                    AboutTitle = 'About Reviewed Date?';
                    AboutText = 'When an entry has been marked as reviewed, you can see the date on which it was done';
                }
                field("Amount to Review"; Rec."Amount to Review")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        if AreOppositeSign(Rec."Amount to Review", RemainingAmount) then
                            Error(MustHavetheSameSignErr);

                        if Abs(Rec."Amount to Review") > Abs(RemainingAmount) then
                            Error(MustNotBelargerErr);
                    end;
                }
                field(RemainingAmount; RemainingAmount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Remaining Amount';
                    Editable = false;
                    ToolTip = 'Specifies the remaining amount that can be applied to the entry.';
                }
                field("Review Id"; Rec."Reviewed Identifier")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the id that represents the review.';
                    AboutTitle = 'About Review Id?';
                    AboutText = 'When one or more entries has been marked as reviewed together, you can see an identifier unique to the entries that were reviewed together';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the type of document that the G/L entries apply to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number of the document that the general ledger entries apply to.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies additional information about the general ledger entry.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the general ledger entry no.';
                }
            }
            group(CalculatedFields)
            {
                ShowCaption = false;
                field(Debit; Debit)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    Caption = 'Debit (LCY)';
                    Editable = false;
                    ToolTip = 'Specifies the accumulated debit amount of all the lines applied to this line.';
                }
                field(Credit; Credit)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    Caption = 'Credit (LCY)';
                    Editable = false;
                    ToolTip = 'Specifies the accumulated credit amount of all the lines applied to this line.';
                }
                field(Balance; Balance)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    Caption = 'Balance';
                    Editable = false;
                    ToolTip = 'Specifies the accumulated balance of all the lines applied to this line.';
                    AboutTitle = 'About Balance?';
                    AboutText = 'Based on the selected records, the balance displays the sum of debit and credit';
                }
                field("Review Policy"; ReviewPolicy)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    Caption = 'Review Policy';
                    Editable = false;
                    ToolTip = 'Specifies the review policy for the G/L Account shown in the page caption';
                    AboutTitle = 'About Review Policy?';
                    AboutText = 'The review policy specifies the rules for which the selected entries must adhere to';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Application)
            {
                Caption = 'Application';
                Image = Apply;
                action(SetSelectedAsReviewed)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Set selected as reviewed';
                    Enabled = ReviewPolicy <> "G/L Account Review Policy"::None;
                    Image = SelectLineToApply;
                    ShortCutKey = 'Ctrl+Alt+Q';
                    ToolTip = 'This action can only be selected when the G/L Account''s Review Policy is either "Review Allowed or "Review Allowed and Match Balance". For selected G/L Entries, field Reviewer is set to the current user, field Review Status is set to Reviewed, field Reviewed On is set to current date, field Review Id is to a number which all the marked entries share';
                    AboutTitle = 'About review and unreview entries';
                    AboutText = 'Set selected as reviewed updates the fields related to reviews and marks the entry as reviewed, set selected as not reviewed clears these fields';
                    trigger OnAction()
                    begin
                        SetSelectedRecordsAsReviewed();
                    end;
                }
                action(SetSelectedAsNotReviewed)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Set selected as not reviewed';
                    Enabled = ReviewPolicy <> "G/L Account Review Policy"::None;
                    Image = SelectLineToApply;
                    ShortCutKey = 'Ctrl+Alt+W';
                    ToolTip = 'This action can only be selected when the G/L Account''s Review Policy is either "Review Allowed or "Review Allowed and Match Balance". For selected G/L Entries, field Reviewer is set to blank, field Review Status is set to Not Reviewed, field Reviewed On is set to blank, field Review Id is to blank';

                    trigger OnAction()
                    begin
                        SetSelectedRecordsAsNotReviewed();
                    end;
                }
                action("Show Reviewed Entries")
                {
                    ApplicationArea = Dimensions;
                    Image = Filter;
                    ToolTip = 'Shows all the reviewed entries on the page';
                    Caption = 'Show reviewed entries';
                    ShortCutKey = 'Ctrl+Alt+E';

                    trigger OnAction()
                    var
                        GLEntryReviewLog: Record "G/L Entry Review Log";
                        ReviewedGLEntries: Page "Reviewed G/L Entries";
                    begin
                        GLEntryReviewLog.SetRange("G/L Account No.", Rec."G/L Account No.");
                        ReviewedGLEntries.SetTableView(GLEntryReviewLog);
                        ReviewedGLEntries.RunModal();
                    end;
                }
                action("Hide Reviewed Entries")
                {
                    ApplicationArea = Dimensions;
                    Image = Filter;
                    ToolTip = 'Hide reviewed entries, hides all the reviewed entries on the page';
                    Caption = 'Hide reviewed entries';
                    ShortCutKey = 'Ctrl+Alt+A';
                    AboutTitle = 'About hiding and showing entries';
                    AboutText = 'You can use the show or hide reviewed entries to toggle which entries are displayed on the table and show all to see both reviewed and unreviewed';
                    trigger OnAction()
                    var
                        GLEntry: Record "G/L Entry";
                    begin
                        GLEntry.Reset();
                        GLEntry.SetView(InitialRecordsLoaded);
                        GLEntry.SetRange(Reviewed, false);
                        CurrPage.SetTableView(GLEntry);
                    end;
                }
                action("Show All")
                {
                    ApplicationArea = Basic, Suite;
                    Image = Filter;
                    Caption = 'Show all entries';
                    ToolTip = 'Show all entries, removes the filters set in the view';
                    ShortCutKey = 'Ctrl+Alt+S';

                    trigger OnAction()
                    var
                        GLEntry: Record "G/L Entry";
                    begin
                        GLEntry.Reset();
                        GLEntry.SetView(InitialRecordsLoaded);
                        CurrPage.SetTableView(GLEntry);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Entry';
                Image = Accounts;

                actionref(SetSelectedAsReviewed_Promoted; SetSelectedAsReviewed)
                {
                }
                actionref(SetSelectedAsNotReviewed_Promoted; SetSelectedAsNotReviewed)
                {
                }
                actionref(ShowReviewedEntries_Promoted; "Show Reviewed Entries")
                {
                }
                actionref(HideReviewedEntries_Promoted; "Hide Reviewed Entries")
                {
                }
                actionref(ShowAllEntries_Promoted; "Show All")
                {
                }
            }
        }
    }

    var
        GLEntryReviewer: Interface "G/L Entry Reviewer";
        Debit: Decimal;
        Credit: Decimal;
        RemainingAmount: Decimal;
        Balance: Decimal;
        ReviewPolicy: Enum "Review Policy Type";
        InitialRecordsLoaded: Text;
        CaptionLbl: Label '%1 %2', Comment = '%1 is the G/L Account No. and %2 is the G/L Account Name';
        MustHavetheSameSignErr: Label 'Amount to Review must have the same sign as Remaining Amount';
        MustNotBelargerErr: Label 'Amount to Review must not be larger than Remaining Amount';


    trigger OnOpenPage()
    var
        GLEntryReviewSetup: Record "G/L Entry Review Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        GLEntryReviewSetupPage: Page "G/L Entry Review Setup";
        GLEntryReviewerEnum: Enum "G/L Entry Reviewer";
    begin
        if GLEntryReviewSetup.IsEmpty() then
            if GLEntryReviewerEnum.Names().Count() > 1 then
                GLEntryReviewSetupPage.RunModal();
        if GLEntryReviewSetup.IsEmpty() then
            GLEntryReviewSetup.Insert();
        GLEntryReviewSetup.Get();
        GLEntryReviewer := GLEntryReviewSetup.GLEntryReviewer;
        InitialRecordsLoaded := Rec.GetView();
        FeatureTelemetry.LogUptake('0000J2Y', 'Review G/L Entries', "Feature Uptake Status"::Discovered);

        CalcBalance();
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Reviewed Amount");
        RemainingAmount := Rec.Amount - Rec."Reviewed Amount";
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CalcAmount();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Balance := Balance + Rec."Amount to Review" - xRec."Amount to Review";
    end;

    local procedure SetSelectedRecordsAsReviewed()
    var
        GLEntry: Record "G/L Entry";
    begin
        SelectedGLEntries(GLEntry);
        GLEntryReviewer.ReviewEntries(GLEntry)
    end;

    local procedure SetSelectedRecordsAsNotReviewed()
    var
        GLEntry: record "G/L Entry";
    begin
        SelectedGLEntries(GLEntry);
        GLEntryReviewer.UnreviewEntries(GLEntry);
    end;

    local procedure CalcAmount()
    var
        GLEntry: Record "G/L Entry";
    begin
        SelectedGLEntries(GLEntry);
        GLEntry.CalcSums("Debit Amount", "Credit Amount");
        Debit := GLEntry."Debit Amount";
        Credit := GLEntry."Credit Amount";
        CurrPage.Update(false);
    end;

    local procedure SelectedGLEntries(var GLEntry: record "G/L Entry")
    begin
        CurrPage.SetSelectionFilter(GLEntry);
    end;

    local procedure GetCaption(): Text[250]
    var
        GLAccount: record "G/L Account";
    begin
        if not GLAccount.Get(Rec."G/L Account No.") then
            if Rec.GetFilter(Rec."G/L Account No.") <> '' then
                GLAccount.Get(Rec.GetRangeMin(Rec."G/L Account No."));
        ReviewPolicy := GLAccount."Review Policy";
        exit(StrSubstNo(CaptionLbl, GLAccount."No.", GLAccount.Name));
    end;

    local procedure CalcBalance()
    var
        GLEntry: Record "G/L Entry";
    begin
        Balance := 0;
        GLEntry.Copy(Rec);
        if GLEntry.FindSet() then
            repeat
                Balance += GLEntry."Amount to Review";
            until GLEntry.Next() = 0;
    end;

    local procedure AreOppositeSign(Amount1: Decimal; Amount2: Decimal): Boolean
    var
        Math: Codeunit "Math";
    begin
        if (Amount1 = 0) or (Amount2 = 0) then
            exit(false);

        exit(Math.Sign(Amount1) <> Math.Sign(Amount2));
    end;
}

