namespace Microsoft.Sustainability.FinancialReporting;

using Microsoft.Finance.Dimension;
using Microsoft.Sustainability.Account;
using Microsoft.Foundation.Comment;
using Microsoft.Sustainability.Ledger;

page 6244 "Sust. Accs. (Analysis View)"
{
    Caption = 'Sustainability Accs. (Analysis View)';
    Editable = false;
    PageType = List;
    SourceTable = "Sust. Account (Analysis View)";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                IndentationColumn = NameIndent;
                IndentationControls = Name;
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = Suite;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Suite;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the value of the Account Type field.';
                }
                field("Direct Posting"; Rec."Direct Posting")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Direct Posting field.';
                }
                field(Totaling; Rec.Totaling)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the value of the Totaling field.';
                }
                field("Gen. Posting Type"; Rec."Gen. Posting Type")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the value of the Gen. Posting Type field.';
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field.';
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field.';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the value of the VAT Prod. Posting Group field.';
                }
                field("Net Change (CO2)"; Rec."Net Change (CO2)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the net change of CO2 in the account balance during the time period in the Date Filter field.';
                }
                field("Balance at Date (CO2)"; Rec."Balance at Date (CO2)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the balance at date of CO2 on the account for the upper date in the Date Filter field.';
                    Visible = false;
                }
                field("Balance (CO2)"; Rec."Balance (CO2)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the balance of CO2 on the account.';
                }
                field("Net Change (CH4)"; Rec."Net Change (CH4)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the net change of CH4 in the account balance during the time period in the Date Filter field.';
                }
                field("Balance at Date (CH4)"; Rec."Balance at Date (CH4)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the balance at date of CH4 on the account for the upper date in the Date Filter field.';
                    Visible = false;
                }
                field("Balance (CH4)"; Rec."Balance (CH4)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the balance of CH4 on the account.';
                }
                field("Net Change (N2O)"; Rec."Net Change (N2O)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the net change of N2O in the account balance during the time period in the Date Filter field.';
                }
                field("Balance at Date (N2O)"; Rec."Balance at Date (N2O)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the balance at date of N2O on the account for the upper date in the Date Filter field.';
                    Visible = false;
                }
                field("Balance (N2O)"; Rec."Balance (N2O)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the balance of N2O on the account.';
                }
                field("Net Change (CO2e Emission)"; Rec."Net Change (CO2e Emission)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the net change of CO2e Emission in the account balance during the time period in the Date Filter field.';
                }
                field("Balance at Date (CO2e Emission)"; Rec."Bal. at Date (CO2e Emission)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the balance at date of CO2e Emission on the account for the upper date in the Date Filter field.';
                    Visible = false;
                }
                field("Balance (CO2e Emission)"; Rec."Balance (CO2e Emission)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the balance of CO2e Emission on the account.';
                }
                field("Net Change (Carbon Fee)"; Rec."Net Change (Carbon Fee)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the net change of Carbon Fee in the account balance during the time period in the Date Filter field.';
                }
                field("Balance at Date (Carbon Fee)"; Rec."Balance at Date (Carbon Fee)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the balance at date of Carbon Fee on the account for the upper date in the Date Filter field.';
                    Visible = false;
                }
                field("Balance (Carbon Fee)"; Rec."Balance (Carbon Fee)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the balance of Carbon Fee on the account.';
                }
                field("Consol. Debit Acc."; Rec."Consol. Debit Acc.")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Consol. Debit Acc. field.';
                }
                field("Consol. Credit Acc."; Rec."Consol. Credit Acc.")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Consol. Credit Acc. field.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("A&ccount")
            {
                Caption = 'A&ccount';
                Image = Account;
                action(Card)
                {
                    ApplicationArea = Suite;
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "Sustainability Account Card";
                    RunPageLink = "No." = field("No."),
                                  "Date Filter" = field("Date Filter"),
                                  "Global Dimension 1 Filter" = field("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = field("Global Dimension 2 Filter");
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View or change detailed information about the record on the document or journal line.';
                }
                action("Ledger E&ntries")
                {
                    ApplicationArea = Suite;
                    Caption = 'Ledger E&ntries';
                    Image = GLRegisters;
                    RunObject = Page "Sustainability Ledger Entries";
                    RunPageLink = "Account No." = field("No.");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the history of transactions that have been posted for the selected record.';
                }
                action("Co&mments")
                {
                    ApplicationArea = Suite;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = const("Sustainability Account"),
                                  "No." = field("No.");
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
                        RunPageLink = "Table ID" = const(Database::"Sustainability Account"),
                                      "No." = field("No.");
                        ShortCutKey = 'Alt+D';
                        ToolTip = 'View or edit the single set of dimensions that are set up for the selected record.';
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;
                        ToolTip = 'View or edit dimensions for a group of records. You can assign dimension codes to transactions to distribute costs and analyze historical information.';

                        trigger OnAction()
                        var
                            SustainabilityAccount: Record "Sustainability Account";
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SetSelectionFilter(SustainabilityAccount);
                            DefaultDimMultiple.SetMultiRecord(SustainabilityAccount, Rec.FieldNo("No."));
                            DefaultDimMultiple.RunModal();
                        end;
                    }
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(IndentChartOfSustainAccounts)
                {
                    ApplicationArea = Basic, Suite;
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
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(IndentChartOfSustainAccountsPromoted; IndentChartOfSustainAccounts)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        NameIndent := 0;
        FormatLine();
    end;

    var
        Emphasize: Boolean;
        NameIndent: Integer;

    procedure InsertTempSustAccountAnalysisView(var SustainabilityAccount: Record "Sustainability Account")
    begin
        if SustainabilityAccount.Find('-') then
            repeat
                Rec.Init();
                Rec."No." := SustainabilityAccount."No.";
                Rec.Name := SustainabilityAccount.Name;
                Rec."Account Type" := SustainabilityAccount."Account Type";
                Rec.Blocked := SustainabilityAccount.Blocked;
                Rec.Validate(Indentation, SustainabilityAccount.Indentation);
                Rec.Totaling := SustainabilityAccount.Totaling;
                Rec.Comment := SustainabilityAccount.Comment;
                Rec."Account Source" := Rec."Account Source"::"Sust. Account";
                Rec.Insert();
            until SustainabilityAccount.Next() = 0;
    end;

    local procedure FormatLine()
    begin
        NameIndent := Rec.Indentation;
        Emphasize := Rec."Account Type" <> Rec."Account Type"::Posting;
    end;
}

