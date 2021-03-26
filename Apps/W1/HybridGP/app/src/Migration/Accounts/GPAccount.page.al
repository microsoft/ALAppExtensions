page 4090 "GP Account"
{
    PageType = Card;
    SourceTable = "GP Account";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'Account Table';
    PromotedActionCategories = 'Related Entities';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(AcctNum; AcctNum) { ApplicationArea = All; ToolTip = 'Account Number'; }
                field(AcctIndex; AcctIndex) { ApplicationArea = All; ToolTip = 'Account Index'; }
                field(Name; Name) { ApplicationArea = All; ToolTip = 'Account Name'; }
                field(SearchName; SearchName) { ApplicationArea = All; ToolTip = 'Search Name'; }
                field(AccountCategory; AccountCategory) { ApplicationArea = All; ToolTip = 'Account Category'; }
                field(IncomeBalance; IncomeBalance) { ApplicationArea = All; ToolTip = 'Income Balance'; }
                field(DebitCredit; DebitCredit) { ApplicationArea = All; ToolTip = 'Debit or Credit'; }
                field(Active; Active) { ApplicationArea = All; ToolTip = 'Active'; }
                field(DirectPosting; DirectPosting) { ApplicationArea = All; ToolTip = 'Direct Posting'; }
                field(AccountSubcategoryEntryNo; AccountSubcategoryEntryNo) { ApplicationArea = All; ToolTip = 'Account Subcategory Entry Number'; }
                field(AccountType; AccountType) { ApplicationArea = All; ToolTip = 'Account Type'; }
            }
        }
    }
}