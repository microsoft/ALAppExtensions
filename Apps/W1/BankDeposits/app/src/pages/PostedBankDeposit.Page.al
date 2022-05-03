page 1694 "Posted Bank Deposit"
{
    Caption = 'Posted Bank Deposit';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Bank Deposit,Print/Send';
    SourceTable = "Posted Bank Deposit Header";
    Permissions = tabledata "Posted Bank Deposit Header" = r,
                  tabledata "Posted Bank Deposit Line" = r;

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
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the document number of the deposit document.';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of the bank account to which the deposit was made.';
                }
                field("Total Deposit Amount"; Rec."Total Deposit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the total amount deposited to the bank account.';
                }
                field(Difference; GetDifference())
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 1;
                    Caption = 'Difference';
                    Editable = false;
                    ToolTip = 'Specifies the difference between the Amount field and the Cleared Amount field.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the date the deposit was posted.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the date of the deposit document.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ToolTip = 'Specifies the value assigned to this dimension for this deposit.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ToolTip = 'Specifies the value assigned to this dimension for this deposit.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the currency code of the bank account that the deposit was deposited in.';
                }
                field(Reversed; GLRegisterReversed)
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    Caption = 'Reversed';
                    ToolTip = 'Specifies if transactions from the corresponding G/L Register have been reversed.';
                }
            }
            part(Subform; "Posted Bank Deposit Subform")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Bank Deposit No." = FIELD("No.");
            }
        }
        area(factboxes)
        {
            systempart(Control1905767507; Notes)
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
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "Bank Acc. Comment Sheet";
                    RunPageLink = "Bank Account No." = FIELD("Bank Account No."),
                                  "No." = FIELD("No.");
                    RunPageView = WHERE("Table Name" = CONST("Posted Bank Deposit Header"));
                    ToolTip = 'View deposit comments that apply.';
                }
                action(Dimensions)
                {
                    ApplicationArea = Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim();
                    end;
                }
            }
        }
        area(processing)
        {
            action(Print)
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

                trigger OnAction()
                var
                    PostedBankDepositHeader: Record "Posted Bank Deposit Header";
                    ReportSelections: Record "Report Selections";
                    FeatureTelemetry: Codeunit "Feature Telemetry";
                    IsHandled: Boolean;
                begin
                    FeatureTelemetry.LogUptake('0000H7Y', 'Bank Deposit', Enum::"Feature Uptake Status"::Used);
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
                    FeatureTelemetry.LogUsage('0000H7Z', 'Bank Deposit', 'Bank deposit printed');
                end;
            }
            action(Undo)
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Undo Posting';
                Ellipsis = true;
                Image = Undo;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
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
            action("&Navigate")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Find entries...';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                ToolTip = 'Find all bank account ledger entries that exist for this bank deposit.';

                trigger OnAction()
                begin
                    Rec.FindEntries();
                end;
            }
        }
    }

    var
        GLRegisterReversed: Text;
        BankDepositReportSelectionErr: Label 'Bank deposit report has not been set up.';
        UndoPostingQst: Label 'This will reverse all ledger entries that are related to the lines of the bank deposit. Do you want to continue?';
        BankDepositNonGUISessionErr: Label 'To undo the posting of a bank deposit, you must sign in to Business Central from a web browser.';
        YesTxt: Label 'Yes';
        NoTxt: Label 'No';

    trigger OnAfterGetCurrRecord()
    var
        GLRegister: Record "G/L Register";
        GLRegNo: Integer;
    begin
        GLRegisterReversed := NoTxt;

        if Rec.FindGLRegisterNo(GLRegNo) then begin
            GLRegister.Get(GLRegNo);
            if GLRegister.Reversed then
                GLRegisterReversed := YesTxt;
        end;
    end;

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000H8A', 'Bank Deposit', Enum::"Feature Uptake Status"::"Set up");
    end;

    local procedure GetDifference(): Decimal
    begin
        CalcFields("Total Deposit Lines");
        exit("Total Deposit Amount" - "Total Deposit Lines");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintPostedBankDeposit(var PostedBankDepositHeader: Record "Posted Bank Deposit Header"; var IsHandled: Boolean)
    begin
    end;
}

