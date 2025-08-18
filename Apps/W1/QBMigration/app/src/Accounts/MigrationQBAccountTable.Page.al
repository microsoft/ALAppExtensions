#pragma warning disable AA0247
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
                field(AcctNum; Rec.AcctNum) { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field(SubAccount; Rec.SubAccount) { ApplicationArea = All; }
                field(FullyQualifiedName; Rec.FullyQualifiedName) { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
                field(Classification; Rec.Classification) { ApplicationArea = All; }
                field(AccountType; Rec.AccountType) { ApplicationArea = All; }
                field(AccountSubType; Rec.AccountSubType) { ApplicationArea = All; }
                field(CurrentBalance; Rec.CurrentBalance) { ApplicationArea = All; }
                field(CurrentBalanceWithSubAccounts; Rec.CurrentBalanceWithSubAccounts) { ApplicationArea = All; }
#pragma warning restore
            }
        }
    }
}
