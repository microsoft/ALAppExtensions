page 1936 "MigrationGP ItemTable"
{
    PageType = Card;
    SourceTable = "MigrationGP Item";
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
                field(No; No) { ApplicationArea = All; }
                field(Description; Description) { ApplicationArea = All; }
                field(SearchDescription; SearchDescription) { ApplicationArea = All; }
                field(ShortName; ShortName) { ApplicationArea = All; }
                field(BaseUnitOfMeasure; BaseUnitOfMeasure) { ApplicationArea = All; }
                field(ItemType; ItemType) { ApplicationArea = All; }
                field(CostingMethod; CostingMethod) { ApplicationArea = All; }
                field(CurrentCost; CurrentCost) { ApplicationArea = All; }
                field(StandardCost; StandardCost) { ApplicationArea = All; }
                field(UnitListPrice; UnitListPrice) { ApplicationArea = All; }
                field(ShipWeight; ShipWeight) { ApplicationArea = All; }
                field(InActive; InActive) { ApplicationArea = All; }
                field(QuantityOnHand; QuantityOnHand) { ApplicationArea = All; }
                field(SalesUnitOfMeasure; SalesUnitOfMeasure) { ApplicationArea = All; }
                field(PurchUnitOfMeasure; PurchUnitOfMeasure) { ApplicationArea = All; }
                field(ItemTrackingCode; ItemTrackingCode) { ApplicationArea = All; }
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
                    RunObject = Page "MigrationGP Posting Accounts";
                    RunPageMode = Edit;
                }
            }
        }
    }
}