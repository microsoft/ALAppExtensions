page 1691 "Bank Deposit List"
{
    Caption = 'Bank Deposit List';
    Editable = false;
    PageType = List;
    SourceTable = "Bank Deposit Header";
    Permissions = tabledata "Bank Deposit Header" = rimd;

    layout
    {
        area(content)
        {
            repeater(BankDepositFields)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the bank deposit.';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the bank account.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency of the bank deposit.';
                }
                field("Total Deposit Amount"; Rec."Total Deposit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount of the bank deposit.';
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(BankDeposit)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bank Deposit';
                Image = Document;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Bank Deposit";
                ToolTip = 'Create a new bank deposit. ';
            }
        }
        area(reporting)
        {
            action("Bank Deposit Test Report")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bank Deposit Test Report';
                Image = "Report";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                ToolTip = 'Verify the result of posting the deposit before you run the deposit report.';

                trigger OnAction()
                var
                    ReportSelections: Record "Report Selections";
                    BankDepositHeader: Record "Bank Deposit Header";
                    IsHandled: Boolean;
                begin
                    if BankDepositHeader.Get("No.") then begin
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
        }
    }

    trigger OnInit()
    var
        FeatureBankDeposits: Codeunit "Feature Bank Deposits";
    begin
        FeatureBankDeposits.OpenPageGuard();
    end;

    var
        BankDepositReportSelectionErr: Label 'Bank deposit test report has not been set up.';

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintBankDeposit(var BankDepositHeader: Record "Bank Deposit Header"; var IsHandled: Boolean)
    begin
    end;
}

