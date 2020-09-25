page 1931 "MigrationGP AccountTable"
{
    PageType = Card;
    SourceTable = "MigrationGP Account";
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
                field(AcctNum; AcctNum) { ApplicationArea = All; }
                field(AcctIndex; AcctIndex) { ApplicationArea = All; }
                field(Name; Name) { ApplicationArea = All; }
                field(SearchName; SearchName) { ApplicationArea = All; }
                field(AccountCategory; AccountCategory) { ApplicationArea = All; }
                field(IncomeBalance; IncomeBalance) { ApplicationArea = All; }
                field(DebitCredit; DebitCredit) { ApplicationArea = All; }
                field(Active; Active) { ApplicationArea = All; }
                field(DirectPosting; DirectPosting) { ApplicationArea = All; }
                field(AccountSubcategoryEntryNo; AccountSubcategoryEntryNo) { ApplicationArea = All; }
                field(Balance; Balance) { ApplicationArea = All; }
                field(AccountType; AccountType) { ApplicationArea = All; }
                field(AcctNumNew; AcctNumNew) { ApplicationArea = All; }
            }
        }
    }
}