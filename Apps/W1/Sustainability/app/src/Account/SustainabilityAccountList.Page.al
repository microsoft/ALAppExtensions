namespace Microsoft.Sustainability.Account;

using Microsoft.Sustainability.Ledger;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.Comment;
using System.Text;

page 6212 "Sustainability Account List"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Sustainability Account List';
    CardPageID = "Sustainability Account Card";
    DataCaptionFields = "Search Name";
    Editable = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "Sustainability Account";
    AnalysisModeEnabled = false;

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
                    ToolTip = 'Specifies the number of the the sustainability account.';
                }
                field(Name; Rec.Name)
                {
                    Style = Strong;
                    StyleExpr = Rec."Account Type" <> Rec."Account Type"::Posting;
                    ToolTip = 'Specifies the name of the sustainability account.';
                }
                field(Category; Rec.Category)
                {
                    ToolTip = 'Specifies the category of the sustainability account.';
                }
                field(Subcategory; Rec.Subcategory)
                {
                    ToolTip = 'Specifies the subcategory of the category of the sustainability account.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ToolTip = 'Specifies the purpose of the account. Total: Used to total a series of balances on accounts from many different account groupings. To use Total, leave this field blank. Begin-Total: A marker for the beginning of a series of accounts to be totaled that ends with an End-Total account. End-Total: A total of a series of accounts that starts with the preceding Begin-Total account. The total is defined in the Totaling field.';
                }
                field("Direct Posting"; Rec."Direct Posting")
                {
                    ToolTip = 'Specifies whether you will be able to post directly or only indirectly to this sustainability account. To allow Direct Posting to the sustainability account, place a check mark in the check box.';
                }
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
                    Image = CustomerLedger;
                    RunObject = Page "Sustainability Ledger Entries";
                    RunPageLink = "Account No." = field("No.");
                    RunPageView = sorting("Account No.") order(descending);
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
                action(Dimensions)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = const(Database::"Sustainability Account"), "No." = field("No.");
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to posting to distribute costs and analyze transaction history.';
                }
            }
        }
        area(reporting)
        {
        }
        area(Promoted)
        {
            group(Category_Report)
            {
                Caption = 'Report';
            }
            group(Category_Category4)
            {
                Caption = 'Account';
                actionref("Ledger Entries_Promoted"; "Ledger Entries") { }
                actionref(Dimensions_Promoted; Dimensions) { }
                actionref("Comments_Promoted"; "Comments") { }
            }
        }
    }

    procedure GetSelectionFilter(): Text
    var
        SustainAccount: Record "Sustainability Account";
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
    begin
        CurrPage.SetSelectionFilter(SustainAccount);
        RecRef.GetTable(SustainAccount);
        exit(SelectionFilterManagement.GetSelectionFilter(RecRef, SustainAccount.FieldNo("No.")));
    end;
}