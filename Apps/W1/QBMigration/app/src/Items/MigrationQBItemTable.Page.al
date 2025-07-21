#pragma warning disable AA0247
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
                field(Name; Rec.Name) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Type; Rec.Type) { ApplicationArea = All; }
                field(UnitPrice; Rec.UnitPrice) { ApplicationArea = All; }
                field(PurchaseCost; Rec.PurchaseCost) { ApplicationArea = All; }
                field(QtyOnHand; Rec.QtyOnHand) { ApplicationArea = All; }
                field(Taxable; Rec.Taxable) { ApplicationArea = All; }
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
                    ToolTip = 'View QuickBooks posting accounts.';
                }
            }
        }
    }
}
