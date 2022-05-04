page 1692 "Bank Deposits"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Bank Deposits';
    CardPageID = "Bank Deposit";
    Editable = false;
    PageType = List;
    SourceTable = "Bank Deposit Header";
    UsageCategory = Lists;
    Permissions = tabledata "Bank Deposit Header" = rimd;

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
                    ToolTip = 'Specifies the number of the bank deposit that you are creating.';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account number to which this bank deposit is being made.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the bank eposit should be posted. This should be the date that the bank eposit is deposited in the bank.';
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the journal batch name from the general journal batch.';
                    Visible = false;
                }
                field("Total Deposit Amount"; Rec."Total Deposit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount of the bank deposit. The sum of the amounts must equal this field value before you will be able to post this bank deposit.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date of the bank deposit document.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the dimension value code the bank deposit header will be associated with.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the dimension value code the bank deposit header will be associated with.';
                    Visible = false;
                }
                field("Posting Description"; Rec."Posting Description")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s document type and number (Bank Deposit No. 1001, for example).';
                    Visible = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the currency that will be used for this Deposit.';
                    Visible = false;
                }
                field("Language Code"; Rec."Language Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account''s language code from the Bank Account table.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action(TestReport)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Report;
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
                action("P&ost")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = Post;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Codeunit "Bank Deposit-Post (Yes/No)";
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';
                }
                action("Post and &Print")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post and &Print';
                    Ellipsis = true;
                    Image = PostPrint;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Codeunit "Bank Deposit-Post + Print";
                    ShortCutKey = 'Shift+F9';
                    ToolTip = 'Finalize and prepare to print the document or journal. The values and quantities are posted to the related accounts. A report request window where you can specify what to include on the print-out.';
                }
            }
        }
    }

    var
        BankDepositReportSelectionErr: Label 'Bank deposit test report has not been set up.';

    trigger OnInit()
    var
#if not CLEAN21
        FeatureBankDeposits: Codeunit "Feature Bank Deposits";
#endif
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000H80', 'Bank Deposit', Enum::"Feature Uptake Status"::Discovered);
#if not CLEAN21
        FeatureBankDeposits.OpenPageGuard();
#endif
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintBankDeposit(var BankDepositHeader: Record "Bank Deposit Header"; var IsHandled: Boolean)
    begin
    end;
}

