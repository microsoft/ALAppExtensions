// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

page 1862 "C5 InvenTable"
{
    PageType = Card;
    SourceTable = "C5 InvenTable";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Inventory Table';
    PromotedActionCategories = 'Related Entities';

    layout
    {
        area(content)
        {
            group(General)
            {
#pragma warning disable AA0218
                field(ItemNumber; Rec.ItemNumber) { ApplicationArea = All; }
                field(ItemName1; Rec.ItemName1) { ApplicationArea = All; }
                field(ItemName2; Rec.ItemName2) { ApplicationArea = All; }
                field(ItemName3; Rec.ItemName3) { ApplicationArea = All; }
                field(ItemType; Rec.ItemType) { ApplicationArea = All; }
                field(DiscGroup; Rec.DiscGroup) { ApplicationArea = All; }
                field(CostCurrency; Rec.CostCurrency) { ApplicationArea = All; }
                field(CostPrice; Rec.CostPrice) { ApplicationArea = All; }
                field(Group; Rec.Group) { ApplicationArea = All; }
                field(SalesModel; Rec.SalesModel) { ApplicationArea = All; }
                field(CostingMethod; Rec.CostingMethod) { ApplicationArea = All; }
                field(PurchSeriesSize; Rec.PurchSeriesSize) { ApplicationArea = All; }
                field(PrimaryVendor; Rec.PrimaryVendor) { ApplicationArea = All; }
                field(VendItemNumber; Rec.VendItemNumber) { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
                field(Alternative; Rec.Alternative) { ApplicationArea = All; }
                field(AltItemNumber; Rec.AltItemNumber) { ApplicationArea = All; }
                field(Decimals_; Rec.Decimals_) { ApplicationArea = All; }
                field(DEL_SalesDuty; Rec.DEL_SalesDuty) { ApplicationArea = All; }
                field(Commission; Rec.Commission) { ApplicationArea = All; }
                field(ImageFile; Rec.ImageFile) { ApplicationArea = All; }
                field(NetWeight; Rec.NetWeight) { ApplicationArea = All; }
                field(Volume; Rec.Volume) { ApplicationArea = All; }
                field(TariffNumber; Rec.TariffNumber) { ApplicationArea = All; }
                field(UnitCode; Rec.UnitCode) { ApplicationArea = All; }
                field(OneTimeItem; Rec.OneTimeItem) { ApplicationArea = All; }
                field(CostType; Rec.CostType) { ApplicationArea = All; }
                field(ExtraCost; Rec.ExtraCost) { ApplicationArea = All; }
                field(PurchCostModel; Rec.PurchCostModel) { ApplicationArea = All; }
                field(MainLocation; Rec.MainLocation) { ApplicationArea = All; }
                field(InvenLocation; Rec.InvenLocation) { ApplicationArea = All; }
                field(PurchVat; Rec.PurchVat) { ApplicationArea = All; }
                field(RESERVED2; Rec.RESERVED2) { ApplicationArea = All; }
                field(Inventory; Rec.Inventory) { ApplicationArea = All; }
                field(Delivered; Rec.Delivered) { ApplicationArea = All; }
                field(Reserved; Rec.Reserved) { ApplicationArea = All; }
                field(Received; Rec.Received) { ApplicationArea = All; }
                field(Ordered; Rec.Ordered) { ApplicationArea = All; }
                field(InventoryValue; Rec.InventoryValue) { ApplicationArea = All; }
                field(DeliveredValue; Rec.DeliveredValue) { ApplicationArea = All; }
                field(ReceivedValue; Rec.ReceivedValue) { ApplicationArea = All; }
                field(Department; Rec.Department) { ApplicationArea = All; }
                field(CostPriceUnit; Rec.CostPriceUnit) { ApplicationArea = All; }
                field(DEL_PurchDuty; Rec.DEL_PurchDuty) { ApplicationArea = All; }
                field(Level; Rec.Level) { ApplicationArea = All; }
                field(Pulled; Rec.Pulled) { ApplicationArea = All; }
                field(WarnNegativeInventory; Rec.WarnNegativeInventory) { ApplicationArea = All; }
                field(NegativeInventory; Rec.NegativeInventory) { ApplicationArea = All; }
                field(IgnoreListCode; Rec.IgnoreListCode) { ApplicationArea = All; }
                field(PayCType; Rec.PayCType) { ApplicationArea = All; }
                field(ItemTracking; Rec.ItemTracking) { ApplicationArea = All; }
                field(ItemTrackGroup; Rec.ItemTrackGroup) { ApplicationArea = All; }
                field(ProjCostFactor; Rec.ProjCostFactor) { ApplicationArea = All; }
                field(Centre; Rec.Centre) { ApplicationArea = All; }
                field(Purpose; Rec.Purpose) { ApplicationArea = All; }
                field(SupplFactor; Rec.SupplFactor) { ApplicationArea = All; }
                field(SupplementaryUnits; Rec.SupplementaryUnits) { ApplicationArea = All; }
                field(MarkedPhysical; Rec.MarkedPhysical) { ApplicationArea = All; }
                field(LastMovementDate; Rec.LastMovementDate) { ApplicationArea = All; }
                field(VatGroup; Rec.VatGroup) { ApplicationArea = All; }
                field(StdItemNumber; Rec.StdItemNumber) { ApplicationArea = All; }
#pragma warning restore
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            group(RelatedEntities)
            {
                Caption = 'Related entities';

                action(C5InvenCustDisc)
                {
                    ApplicationArea = All;
                    Caption = 'Item Discount';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = Discount;
                    RunObject = Page "C5 InvenDiscGroup";
                    RunPageLink = DiscGroup = field(DiscGroup);
                    RunPageMode = Edit;
                    Enabled = Rec.DiscGroup <> '';
                    ToolTip = 'Open the C5 Inventory Discount page.';
                }

                action(C5InvenPrice)
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Prices';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = Price;
                    RunObject = Page "C5 InvenPrice";
                    RunPageLink = ItemNumber = field(ItemNumber);
                    RunPageMode = Edit;
                    ToolTip = 'Open the C5 Inventory Prices page.';
                }

                action(C5CN8Code)
                {
                    ApplicationArea = All;
                    Caption = 'Item CN8 Codes';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = BarCode;
                    RunObject = Page "C5 CN8Code";
                    RunPageLink = CN8Code = field(TariffNumber);
                    RunPageMode = Edit;
                    Enabled = Rec.TariffNumber <> '';
                    ToolTip = 'Open the C5 Item CN8 Codes page.';
                }

                action(InvenItemGroup)
                {
                    ApplicationArea = All;
                    Caption = 'Item Groups';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = Group;
                    RunObject = Page "C5 InvenItemGroup";
                    RunPageLink = Group = field(Group);
                    RunPageMode = Edit;
                    Enabled = Rec.Group <> '';
                    ToolTip = 'Open the C5 Item Groups page.';
                }

                action(InvenTrans)
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Entries';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = EntriesList;
                    RunObject = Page "C5 InvenTrans";
                    RunPageLink = ItemNumber = field(ItemNumber), Open = const(Yes), BudgetCode = const(Actual);
                    RunPageMode = Edit;
                    ToolTip = 'Open the C5 Inventory Entries page.';
                }

                action(BOM)
                {
                    ApplicationArea = All;
                    Caption = 'Bill of Materials';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = BOM;
                    RunObject = Page "C5 InvenBOM List";
                    RunPageLink = BOMItemNumber = field(ItemNumber);
                    RunPageMode = Edit;
                    Enabled = BOMActionEnabled;
                    ToolTip = 'Open the Bill of Materials page.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        C5InvenBOM: Record "C5 InvenBOM";
    begin
        C5InvenBOM.SetRange(BOMItemNumber, Rec.ItemNumber);
        BOMActionEnabled := not C5InvenBOM.IsEmpty();
    end;

    var
        BOMActionEnabled: Boolean;
}
