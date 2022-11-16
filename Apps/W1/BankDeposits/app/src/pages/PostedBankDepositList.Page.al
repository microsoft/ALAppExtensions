page 1696 "Posted Bank Deposit List"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Posted Bank Deposits';
    CardPageID = "Posted Bank Deposit";
    Editable = false;
    PageType = List;
    SourceTable = "Posted Bank Deposit Header";
    Permissions = tabledata "Posted Bank Deposit Header" = r;
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the document number of the deposit document.';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the bank account to which the deposit was made.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date the deposit was posted.';
                }
                field("Total Deposit Amount"; Rec."Total Deposit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount deposited to the bank account.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date of the deposit document.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the value assigned to this dimension for this deposit.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the value assigned to this dimension for this deposit.';
                    Visible = false;
                }
                field("Posting Description"; Rec."Posting Description")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting description of the deposit.';
                    Visible = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the currency code of the bank account that the deposit was deposited in.';
                    Visible = false;
                }
                field(Reversed; GLRegisterReversed)
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    Caption = 'Reversed';
                    ToolTip = 'Specifies if transactions from the corresponding G/L Register have been reversed.';
                }
                field("Language Code"; Rec."Language Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the language code of the bank account that the deposit was deposited into.';
                    Visible = false;
                }
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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Bank Acc. Comment Sheet";
                    RunPageLink = "Bank Account No." = FIELD("Bank Account No."),
                                  "No." = FIELD("No.");
                    RunPageView = WHERE("Table Name" = CONST("Posted Bank Deposit Header"));
                    ToolTip = 'View a list of deposit comments.';
                }
                action(Undo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Undo Posting';
                    Ellipsis = true;
                    Image = Undo;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Undo the posting of the bank deposit by reversing all related ledger entries.';

                    trigger OnAction()
                    begin
                        if not GuiAllowed() then
                            Error(BankDepositNonGUISessionErr);

                        if not Confirm(UndoPostingQst) then
                            exit;
                        Rec.ReverseTransactions();
                        CurrPage.Update(false);
                    end;
                }
                action(Dimensions)
                {
                    ApplicationArea = Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim();
                    end;
                }
            }
        }
        area(reporting)
        {
            action(BankDeposit)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bank Deposit';
                Image = Report;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

                trigger OnAction()
                var
                    PostedBankDepositHeader: Record "Posted Bank Deposit Header";
                    ReportSelections: Record "Report Selections";
                    IsHandled: Boolean;
                begin
                    if PostedBankDepositHeader.Get(Rec."No.") then begin
                        PostedBankDepositHeader.SetRange("No.", Rec."No.");
                        PostedBankDepositHeader.SetRange("Bank Account No.", Rec."Bank Account No.");
                    end;
                    IsHandled := false;
                    OnBeforePrintPostedBankDeposit(PostedBankDepositHeader, IsHandled);
                    if IsHandled then
                        exit;

                    ReportSelections.SetRange(Usage, ReportSelections.Usage::"Bank Deposit");
                    ReportSelections.SetRange("Report ID", Report::"Bank Deposit");
                    if not ReportSelections.FindFirst() then
                        Error(BankDepositReportSelectionErr);

                    REPORT.Run(ReportSelections."Report ID", true, false, PostedBankDepositHeader);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        GLRegister: Record "G/L Register";
        GLRegNo: Integer;
    begin
        GLRegisterReversed := false;

        if Rec.FindGLRegisterNo(GLRegNo) then begin
            GLRegister.Get(GLRegNo);
            if GLRegister.Reversed then
                GLRegisterReversed := true;
        end;
    end;

    trigger OnInit()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
#if not CLEAN21
        FeatureBankDeposits: Codeunit "Feature Bank Deposits";
#endif
    begin
        FeatureTelemetry.LogUptake('0000IG2', 'Bank Deposit', Enum::"Feature Uptake Status"::Discovered);
#if not CLEAN21
        if FeatureBankDeposits.ShouldSeePostedBankDeposits() then
            exit;
        FeatureBankDeposits.PromptFeatureBlockingOpen();
#endif
    end;

    var
        GLRegisterReversed: Boolean;
        BankDepositReportSelectionErr: Label 'Bank deposit report has not been set up.';
        UndoPostingQst: Label 'This will reverse all ledger entries that are related to the lines of the bank deposit. Do you want to continue?';
        BankDepositNonGUISessionErr: Label 'To undo the posting of a bank deposit, you must sign in to Business Central from a web browser.';

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintPostedBankDeposit(var PostedBankDepositHeader: Record "Posted Bank Deposit Header"; var IsHandled: Boolean)
    begin
    end;
}

