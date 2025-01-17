namespace Microsoft.Sustainability.Account;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.FinancialReports;
using Microsoft.Foundation.Comment;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Reports;

page 6210 "Chart of Sustain. Accounts"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Chart of Sustainability Accounts';
    CardPageID = "Sustainability Account Card";
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "Sustainability Account";
    UsageCategory = Lists;
    AnalysisModeEnabled = false;
    AdditionalSearchTerms = 'Sustainability Account List, Sustainability Accounts, Sustainability Overview, Sustainability Chart, CsA';

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = Name;
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    Style = Strong;
                    StyleExpr = Rec."Account Type" <> Rec."Account Type"::Posting;
                    ToolTip = 'Specifies the account number of the sustainability account.';
                }
                field("No. 2"; Rec."No. 2")
                {
                    Style = Strong;
                    StyleExpr = Rec."Account Type" <> Rec."Account Type"::Posting;
                    ToolTip = 'Specifies the additional account number of the sustainability account.';
                    Visible = false;
                }
                field(Name; Rec.Name)
                {
                    Style = Strong;
                    StyleExpr = Rec."Account Type" <> Rec."Account Type"::Posting;
                    ToolTip = 'Specifies the name of the sustainability account.';
                    Width = 60;
                }
                field("Name 2"; Rec."Name 2")
                {
                    Style = Strong;
                    StyleExpr = Rec."Account Type" <> Rec."Account Type"::Posting;
                    ToolTip = 'Specifies the additional name of the sustainability account.';
                    Visible = false;
                }
                field("Net Change (CO2)"; Rec."Net Change (CO2)")
                {
                    ToolTip = 'Specifies the net change of CO2 in the account balance during the time period in the Date Filter field.';
                }
                field("Balance at Date (CO2)"; Rec."Balance at Date (CO2)")
                {
                    ToolTip = 'Specifies the balance at date of CO2 on the account for the upper date in the Date Filter field.';
                    Visible = false;
                }
                field("Balance (CO2)"; Rec."Balance (CO2)")
                {
                    ToolTip = 'Specifies the balance of CO2 on the account.';
                }
                field("Net Change (CH4)"; Rec."Net Change (CH4)")
                {
                    ToolTip = 'Specifies the net change of CH4 in the account balance during the time period in the Date Filter field.';
                }
                field("Balance at Date (CH4)"; Rec."Balance at Date (CH4)")
                {
                    ToolTip = 'Specifies the balance at date of CH4 on the account for the upper date in the Date Filter field.';
                    Visible = false;
                }
                field("Balance (CH4)"; Rec."Balance (CH4)")
                {
                    ToolTip = 'Specifies the balance of CH4 on the account.';
                }
                field("Net Change (N2O)"; Rec."Net Change (N2O)")
                {
                    ToolTip = 'Specifies the net change of N2O in the account balance during the time period in the Date Filter field.';
                }
                field("Balance at Date (N2O)"; Rec."Balance at Date (N2O)")
                {
                    ToolTip = 'Specifies the balance at date of N2O on the account for the upper date in the Date Filter field.';
                    Visible = false;
                }
                field("Balance (N2O)"; Rec."Balance (N2O)")
                {
                    ToolTip = 'Specifies the balance of N2O on the account.';
                }
                field("Net Change (Water)"; Rec."Net Change (Water)")
                {
                    ToolTip = 'Specifies the Water net change on this account.';
                }
                field("Balance at Date (Water)"; Rec."Balance at Date (Water)")
                {
                    ToolTip = 'Specifies the Water balance at date on this account.';
                    Visible = false;
                }
                field("Balance (Water)"; Rec."Balance (Water)")
                {
                    ToolTip = 'Specifies the Water balance on this account.';
                }
                field("Net Change (Disch. Water)"; Rec."Net Change (Disch. Water)")
                {
                    ToolTip = 'Specifies the Disch. Water net change on this account.';
                }
                field("Balance at Date (Disch. Water)"; Rec."Balance at Date (Disch. Water)")
                {
                    ToolTip = 'Specifies the Disch. Water balance at date on this account.';
                    Visible = false;
                }
                field("Balance (Disch. Water)"; Rec."Balance (Disch. Water)")
                {
                    ToolTip = 'Specifies the Disch. Water balance on this account.';
                }
                field("Net Change (Waste)"; Rec."Net Change (Waste)")
                {
                    ToolTip = 'Specifies the Waste net change on this account.';
                }
                field("Balance at Date (Waste)"; Rec."Balance at Date (Waste)")
                {
                    ToolTip = 'Specifies the Waste balance at date on this account.';
                    Visible = false;
                }
                field("Balance (Waste)"; Rec."Balance (Waste)")
                {
                    ToolTip = 'Specifies the Waste balance on this account.';
                }
                field(Category; Rec.Category)
                {
                    ToolTip = 'Specifies the category of the sustainability account.';
                }
                field(Subcategory; Rec.Subcategory)
                {
                    ToolTip = 'Specifies the subcategory of the account category of the sustainability account.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ToolTip = 'Specifies the purpose of the account. Total: Used to total a series of balances on accounts from many different account groupings. To use Total, leave this field blank. Begin-Total: A marker for the beginning of a series of accounts to be totaled that ends with an End-Total account. End-Total: A total of a series of accounts that starts with the preceding Begin-Total account. The total is defined in the Totaling field.';
                }
                field("Direct Posting"; Rec."Direct Posting")
                {
                    ToolTip = 'Specifies whether you will be able to post directly or only indirectly to this sustainability account.';
                    Visible = false;
                }
                field(Totaling; Rec.Totaling)
                {
                    ToolTip = 'Specifies an account interval or a list of account numbers. The entries of the account will be totaled to give a total balance. How entries are totaled depends on the value in the Account Type field.';
                }
            }
        }
        area(factboxes)
        {
            part(DimensionsFactBox; "Dimensions FactBox")
            {
                ApplicationArea = Dimensions;
                SubPageLink = "Table ID" = const(Database::"Sustainability Account"), "No." = field("No.");
                Visible = false;
            }
            systempart(LinksFactBox; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(NotesFactBox; Notes)
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
            group("Account")
            {
                Caption = 'Account';
                Image = ChartOfAccounts;
                action("Ledger Entries")
                {
                    Caption = 'Ledger Entries';
                    Image = Ledger;
                    RunObject = Page "Sustainability Ledger Entries";
                    RunPageLink = "Account No." = field("No.");
                    RunPageView = sorting("Account No.");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the history of transactions that have been posted for the selected record.';
                }
                action("Comments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Comments';
                    Image = ViewComments;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = const("Sustainability Account"), "No." = field("No.");
                    ToolTip = 'View or add comments for the record.';
                }
                group(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    action("Dimensions-Single")
                    {
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensions-Single';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID" = const(Database::"Sustainability Account"), "No." = field("No.");
                        ShortCutKey = 'Alt+D';
                        ToolTip = 'View or edit the single set of dimensions that are set up for the selected record.';
                    }
                    action("Dimensions-Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensions-Multiple';
                        Image = DimensionSets;
                        ToolTip = 'View or edit dimensions for a group of records. You can assign dimension codes to transactions to distribute costs and analyze historical information.';
                        trigger OnAction()
                        var
                            SustainAccount: Record "Sustainability Account";
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SetSelectionFilter(SustainAccount);
                            DefaultDimMultiple.SetMultiRecord(SustainAccount, Rec.FieldNo("No."));
                            DefaultDimMultiple.RunModal();
                        end;
                    }
                    action(SetDimensionFilter)
                    {
                        ApplicationArea = Dimensions;
                        Caption = 'Set Dimension Filter';
                        Ellipsis = true;
                        Image = "Filter";
                        ToolTip = 'Limit the entries according to the dimension filters that you specify. NOTE: If you use a high number of dimension combinations, this function may not work and can result in a message that the SQL server only supports a maximum of 2100 parameters.';
                        trigger OnAction()
                        var
                            DimensionSetIDFilter: Page "Dimension Set ID Filter";
                        begin
                            Rec.SetFilter("Dimension Set ID Filter", DimensionSetIDFilter.LookupFilter());
                        end;
                    }
                }
            }
        }
        area(processing)
        {
            group("Functions")
            {
                Caption = 'Functions';
                Image = "Action";
                action(IndentChartOfSustainAccounts)
                {
                    Caption = 'Indent Chart of Sustainability Accounts';
                    Image = IndentChartOfAccounts;
                    ToolTip = 'Indent accounts between a Begin-Total and the matching End-Total one level to make the chart of sustainability accounts easier to read.';
                    trigger OnAction()
                    var
                        SustainabilityAccountMgt: Codeunit "Sustainability Account Mgt.";
                    begin
                        SustainabilityAccountMgt.IndentChartOfSustainabilityAccounts(false);
                    end;
                }
                action(FinancialReporting)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Financial Reporting';
                    RunObject = page "Financial Reports";
                    Tooltip = 'Open the Financial Reporting page.';
                }
            }
            group("Periodic Activities")
            {
                Caption = 'Periodic Activities';
                action("Sustainability Journal")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sustainability Journal';
                    Image = Journal;
                    RunObject = Page "Sustainability Journal";
                    ToolTip = 'Open the sustainability journal, for example, to record or post an emission.';
                }
            }
        }
        area(reporting)
        {
            action(TotalEmissions)
            {
                Caption = 'Total Emissions';
                RunObject = report "Total Emissions";
                Image = Report;
                ToolTip = 'View total emissions details.';
            }
            action(EmissionByCategory)
            {
                Caption = 'Emission By Category';
                RunObject = report "Emission By Category";
                Image = Report;
                ToolTip = 'View emissions details by category.';
            }
            action(EmissionPerFacility)
            {
                Caption = 'Emission Per Facility';
                RunObject = report "Emission Per Facility";
                Image = Report;
                ToolTip = 'View emissions details by responsibility center.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(IndentChartOfSustainAccounts_Promoted; IndentChartOfSustainAccounts) { }
                actionref(FinancialReporting_Promoted; FinancialReporting) { }
            }
            group(Category_Category5)
            {
                Caption = 'Account';
                group(Category_Dimensions)
                {
                    Caption = 'Dimensions';
                    ShowAs = SplitButton;
                    actionref("Dimensions-Multiple_Promoted"; "Dimensions-Multiple") { }
                    actionref("Dimensions-Single_Promoted"; "Dimensions-Single") { }
                }
                actionref("Comments_Promoted"; "Comments") { }
                actionref(SetDimensionFilter_Promoted; SetDimensionFilter) { }
                actionref("Ledger Entries_Promoted"; "Ledger Entries") { }
            }
            group(Category_Navigate)
            {
                Caption = 'Navigate';
                actionref("Sustainability Journal_Promoted"; "Sustainability Journal") { }
            }
            group(Category_Report)
            {
                Caption = 'Report';
                actionref(TotalEmissions_Promoted; TotalEmissions) { }
                actionref(EmissionPerFacility_Promoted; EmissionPerFacility) { }
                actionref(EmissionByCategory_Promoted; EmissionByCategory) { }
            }
        }
    }
}