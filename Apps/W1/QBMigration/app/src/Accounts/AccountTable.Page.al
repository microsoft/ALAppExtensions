page 1911 "MigrationQB AccountTable"
{
    PageType = Card;
    SourceTable = "MigrationQB Account";
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
#pragma warning disable AA0218
                field(AcctNum; AcctNum) { ApplicationArea = All; }
                field(Name; Name) { ApplicationArea = All; }
                field(SubAccount; SubAccount) { ApplicationArea = All; }
                field(FullyQualifiedName; FullyQualifiedName) { ApplicationArea = All; }
                field(Active; Active) { ApplicationArea = All; }
                field(Classification; Classification) { ApplicationArea = All; }
                field(AccountType; AccountType) { ApplicationArea = All; }
                field(AccountSubType; AccountSubType) { ApplicationArea = All; }
                field(CurrentBalance; CurrentBalance) { ApplicationArea = All; }
                field(CurrentBalanceWithSubAccounts; CurrentBalanceWithSubAccounts) { ApplicationArea = All; }
#pragma warning restore
            }
        }
    }
}