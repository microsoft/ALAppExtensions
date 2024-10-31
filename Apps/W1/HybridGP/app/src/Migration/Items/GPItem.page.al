#if not CLEAN26
namespace Microsoft.DataMigration.GP;

page 4095 "GP Item"
{
    PageType = Card;
    SourceTable = "GP Item";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'Item Table';
    PromotedActionCategories = 'Related Entities';
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteReason = 'Removing the GP staging table pages because they cause confusion and should not be used.';
    ObsoleteTag = '26.0';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(No; Rec.No)
                {
                    ApplicationArea = All;
                    ToolTip = 'Number';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Description';
                }
                field(SearchDescription; Rec.SearchDescription)
                {
                    ApplicationArea = All;
                    ToolTip = 'Search Description';
                }
                field(ShortName; Rec.ShortName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Short Name';
                }
                field(BaseUnitOfMeasure; Rec.BaseUnitOfMeasure)
                {
                    ApplicationArea = All;
                    ToolTip = 'Base Unit of Measure';
                }
                field(ItemType; Rec.ItemType)
                {
                    ApplicationArea = All;
                    ToolTip = 'ITem Type';
                }
                field(CostingMethod; Rec.CostingMethod)
                {
                    ApplicationArea = All;
                    ToolTip = 'Costing Method';
                }
                field(CurrentCost; Rec.CurrentCost)
                {
                    ApplicationArea = All;
                    ToolTip = 'Current Cost';
                }
                field(StandardCost; Rec.StandardCost)
                {
                    ApplicationArea = All;
                    ToolTip = 'Standard Cost';
                }
                field(UnitListPrice; Rec.UnitListPrice)
                {
                    ApplicationArea = All;
                    ToolTip = 'Unit List Price';
                }
                field(ShipWeight; Rec.ShipWeight)
                {
                    ApplicationArea = All;
                    ToolTip = 'Ship Weight';
                }
                field(InActive; Rec.InActive)
                {
                    ApplicationArea = All;
                    ToolTip = 'InActive';
                }
                field(QuantityOnHand; Rec.QuantityOnHand)
                {
                    ApplicationArea = All;
                    ToolTip = 'Quantity On Hand';
                }
                field(SalesUnitOfMeasure; Rec.SalesUnitOfMeasure)
                {
                    ApplicationArea = All;
                    ToolTip = 'Sales Unit of Measure';
                }
                field(PurchUnitOfMeasure; Rec.PurchUnitOfMeasure)
                {
                    ApplicationArea = All;
                    ToolTip = 'Purchase Unit of Measure';
                }
                field(ItemTrackingCode; Rec.ItemTrackingCode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Item Tracking Code';
                }
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
#endif