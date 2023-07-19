page 2632 "Statistical Account List"
{
    ApplicationArea = All;
    AdditionalSearchTerms = 'Statistical accounts, Unit accounts, Non-posting accounts';
    Caption = 'Statistical Accounts';
    CardPageId = "Statistical Account Card";
    PageType = List;
    SourceTable = "Statistical Account";
    UsageCategory = Lists;
    MultipleNewLines = false;
    ModifyAllowed = false;
    InsertAllowed = false;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                Editable = false;
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
                    ToolTip = 'Specifies whether the statistical account can be used.';
                }

                field(Balance; Rec.Balance)
                {
                    ApplicationArea = All;
                    Caption = 'Balance';
                    ToolTip = 'Specifies the balance of the entries in the statistical account.';
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

            group(DemoData)
            {
                Caption = 'Demo data';
                Visible = DemoDataVisible;
                action(SetupDemoData)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Setup demonstrational data';
                    Image = Setup;
                    RunObject = Codeunit "Stat. Acc. Demo Data";
                    ToolTip = 'Runs the action to setup the demonstrational data. It can only be used in a non-productional company.';
                }

                action(CleanupDemoData)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Cleanup demonstrational Data';
                    Image = CancelAllLines;
                    ToolTip = 'Runs the action to cleanup the demonstrational data. It can only be used in a non-productional company.';
                    trigger OnAction()
                    var
                        StatAccDemoData: Codeunit "Stat. Acc. Demo Data";
                    begin
                        StatAccDemoData.CleanupDemoData();
                    end;
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
                actionref("LedgerEntries_Promoted"; LedgerEntries)
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
        StatAccDemoData: Codeunit "Stat. Acc. Demo Data";
    begin
        DemoDataVisible := StatAccDemoData.CanSetupDemoData();
        if DemoDataVisible then
            StatAccDemoData.ShowSetupNotification();

        StatAccTelemetry.LogDiscovered();
    end;

    internal procedure GetSelectionFilter(): Text
    var
        StatisticalAccount: Record "Statistical Account";
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        StatisticalAccountRecRef: RecordRef;
    begin
        CurrPage.SetSelectionFilter(StatisticalAccount);
        StatisticalAccountRecRef.GetTable(StatisticalAccount);
        exit(SelectionFilterManagement.GetSelectionFilter(StatisticalAccountRecRef, StatisticalAccount.FieldNo("No.")));
    end;

    var
        DemoDataVisible: Boolean;
}