page 4095 "GP Item"
{
    PageType = Card;
    SourceTable = "GP Item";
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
                field(No; No) { ApplicationArea = All; ToolTip = 'Number'; }
                field(Description; Description) { ApplicationArea = All; ToolTip = 'Description'; }
                field(SearchDescription; SearchDescription) { ApplicationArea = All; ToolTip = 'Search Description'; }
                field(ShortName; ShortName) { ApplicationArea = All; ToolTip = 'Short Name'; }
                field(BaseUnitOfMeasure; BaseUnitOfMeasure) { ApplicationArea = All; ToolTip = 'Base Unit of Measure'; }
                field(ItemType; ItemType) { ApplicationArea = All; ToolTip = 'ITem Type'; }
                field(CostingMethod; CostingMethod) { ApplicationArea = All; ToolTip = 'Costing Method'; }
                field(CurrentCost; CurrentCost) { ApplicationArea = All; ToolTip = 'Current Cost'; }
                field(StandardCost; StandardCost) { ApplicationArea = All; ToolTip = 'Standard Cost'; }
                field(UnitListPrice; UnitListPrice) { ApplicationArea = All; ToolTip = 'Unit List Price'; }
                field(ShipWeight; ShipWeight) { ApplicationArea = All; ToolTip = 'Ship Weight'; }
                field(InActive; InActive) { ApplicationArea = All; ToolTip = 'InActive'; }
                field(QuantityOnHand; QuantityOnHand) { ApplicationArea = All; ToolTip = 'Quantity On Hand'; }
                field(SalesUnitOfMeasure; SalesUnitOfMeasure) { ApplicationArea = All; ToolTip = 'Sales Unit of Measure'; }
                field(PurchUnitOfMeasure; PurchUnitOfMeasure) { ApplicationArea = All; ToolTip = 'Purchase Unit of Measure'; }
                field(ItemTrackingCode; ItemTrackingCode) { ApplicationArea = All; ToolTip = 'Item Tracking Code'; }
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
                    RunObject = Page "GP Posting Accounts";
                    RunPageMode = Edit;
                    ToolTip = 'Posting Account Setup';
                }
            }
        }
    }
}