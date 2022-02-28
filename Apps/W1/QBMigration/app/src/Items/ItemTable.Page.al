page 1916 "MigrationQB ItemTable"
{
    PageType = Card;
    SourceTable = "MigrationQB Item";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'Item Table';
    PromotedActionCategories = 'Related Entities';

    layout
    {
        area(content)
        {
            group(General)
            {
#pragma warning disable AA0218
                field(Name; Name) { ApplicationArea = All; }
                field(Description; Description) { ApplicationArea = All; }
                field(Type; Type) { ApplicationArea = All; }
                field(UnitPrice; UnitPrice) { ApplicationArea = All; }
                field(PurchaseCost; PurchaseCost) { ApplicationArea = All; }
                field(QtyOnHand; QtyOnHand) { ApplicationArea = All; }
                field(Taxable; Taxable) { ApplicationArea = All; }
#pragma warning restore
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            group(SupportingPages)
            {
                Caption = 'Supporting Pages';

                action(AccountSetup)
                {
                    ApplicationArea = All;
                    Caption = 'Posting Accounts';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = EntriesList;
                    RunObject = Page "MigrationQB Posting Accounts";
                    RunPageMode = Edit;
                }
            }
        }
    }
}