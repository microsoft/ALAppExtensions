namespace Microsoft.Sustainability.Account;

using Microsoft.Sustainability.Ledger;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.Comment;

page 6211 "Sustainability Account Card"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Sustainability Account Card';
    PageType = Card;
    RefreshOnActivate = true;
    SourceTable = "Sustainability Account";
    AdditionalSearchTerms = 'Sustainability Account Card, Sustainability Account';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies the account number of the sustainability account.';
                }
                field("No. 2"; Rec."No. 2")
                {
                    ToolTip = 'Specifies the additional account number of the sustainability account.';
                    Visible = false;
                }
                field(Name; Rec.Name)
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies the name of the sustainability account.';
                }
                field("Name 2"; Rec."Name 2")
                {
                    ToolTip = 'Specifies the additional name of the sustainability account.';
                    Visible = false;
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
                field(Totaling; Rec.Totaling)
                {
                    ToolTip = 'Specifies an account interval or a list of account numbers. The entries of the account will be totaled to give a total balance. How entries are totaled depends on the value in the Account Type field.';
                }
                field("Search Name"; Rec."Search Name")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies an alternate name that you can use to search for the record in question when you cannot remember the value in the Name field.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies if the account is blocked. If the field is selected, then the account is blocked and you cannot post to it.';
                    Visible = false;
                }
                field("Direct Posting"; Rec."Direct Posting")
                {
                    ToolTip = 'Specifies whether you will be able to post directly or only indirectly to this sustainability account. To allow Direct Posting to the sustainability account, place a check mark in the check box.';
                }
            }
            group(Balances)
            {
                Caption = 'Balances';

                field("Net Change (CO2)"; Rec."Net Change (CO2)")
                {
                    ToolTip = 'Specifies the CO2 net change on this account.';
                }
                field("Balance (CO2)"; Rec."Balance (CO2)")
                {
                    ToolTip = 'Specifies the CO2 balance on this account.';
                }
                field("Balance at Date (CO2)"; Rec."Balance at Date (CO2)")
                {
                    ToolTip = 'Specifies the CO2 balance at date on this account.';
                }
                field("Net Change (CH4)"; Rec."Net Change (CH4)")
                {
                    ToolTip = 'Specifies the CH4 net change on this account.';
                }
                field("Balance (CH4)"; Rec."Balance (CH4)")
                {
                    ToolTip = 'Specifies the CH4 balance on this account.';
                }
                field("Balance at Date (CH4)"; Rec."Balance at Date (CH4)")
                {
                    ToolTip = 'Specifies the CH4 balance at date on this account.';
                }
                field("Net Change (N2O)"; Rec."Net Change (N2O)")
                {
                    ToolTip = 'Specifies the N2O net change on this account.';
                }
                field("Balance (N2O)"; Rec."Balance (N2O)")
                {
                    ToolTip = 'Specifies the N2O balance on this account.';
                }
                field("Balance at Date (N2O)"; Rec."Balance at Date (N2O)")
                {
                    ToolTip = 'Specifies the N2O balance at date on this account.';
                }
            }
            group(DimensionsGr)
            {
                Caption = 'Dimensions';
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ToolTip = 'Specifies the global dimension 1 value.';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ToolTip = 'Specifies the global dimension 2 value.';
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
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to postings to distribute costs and analyze transaction history.';
                }
            }
        }
        area(reporting)
        {
        }
        area(Promoted)
        {
            group(Category_Category4)
            {
                Caption = 'Account';
                actionref(Dimensions_Promoted; Dimensions) { }
                actionref("Comments_Promoted"; "Comments") { }
                actionref("Ledger Entries_Promoted"; "Ledger Entries") { }
            }
            group(Category_Report)
            {
                Caption = 'Report';
            }
        }
    }
}