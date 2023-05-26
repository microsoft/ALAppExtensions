page 2631 "Statistical Account Card"
{
    PageType = Card;
    SourceTable = "Statistical Account";
    Caption = 'Statistical account';
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                    ToolTip = 'Specifies the statistical account number.';
                }

                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the statistical account name.';
                }

                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    Caption = 'Blocked';
                    ToolTip = 'Specifies that the statistical account cannot be used.';
                }

                field(Balance; Rec.Balance)
                {
                    ApplicationArea = All;
                    Caption = 'Balance';
                    ToolTip = 'Specifies the balance';
                }
            }
        }
        area(factboxes)
        {
            part(Control1905532107; "Dimensions FactBox")
            {
                ApplicationArea = Dimensions;
                SubPageLink = "Table ID" = const(2632),
                              "No." = field("No.");
                Visible = false;
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
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
            group("A&ccount")
            {
                action(Dimensions)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = const(2632),
                                  "No." = field("No.");
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';
                }
                action(LedgerEntries)
                {
                    ApplicationArea = All;
                    Caption = 'Ledger Entries';
                    Image = Ledger;
                    RunObject = Page "Statistical Ledger Entry List";
                    RunPageLink = "Statistical Account No." = field("No.");
                    ToolTip = 'View the statistical ledger entries for the selected account.';
                }
                action(StatisticalAccountBalance)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Statistical &Account Balance';
                    Image = GLAccountBalance;
                    RunObject = Page "Stat. Account Balance";
                    RunPageLink = "No." = field("No."),
                                  "Global Dimension 1 Filter" = field("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = field("Global Dimension 2 Filter");
                    ToolTip = 'View a summary of the balances for different time periods for the account.';
                }
            }
            group("Periodic Activities")
            {
                Caption = 'Periodic Activities';
                action("Statistical Accounts Journal")
                {
                    ApplicationArea = All;
                    Caption = 'Statistical Accounts Journal';
                    Image = Journal;
                    RunObject = Page "Statistical Accounts Journal";
                    ToolTip = 'Open the statistical accounts journal, for example, to record or post an update to non-transactional data.';
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref("StatisticalAccountsJournal_Promoted"; "Statistical Accounts Journal")
                {
                }
                actionref("Dimensions_Promoted"; Dimensions)
                {
                }
                actionref("StatisticalAccountBalance_Promoted"; StatisticalAccountBalance)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        StatAccTelemetry: Codeunit "Stat. Acc. Telemetry";
    begin
        StatAccTelemetry.LogDiscovered();
    end;
}