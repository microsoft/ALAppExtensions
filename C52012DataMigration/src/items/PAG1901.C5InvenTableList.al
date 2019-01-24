// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 1901 "C5 InvenTable List"
{
    PageType = List;
    SourceTable = "C5 InvenTable";
    CardPageId = "C5 InvenTable";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    Caption = 'Items';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Error Message"; MigrationErrorText)
                {
                    ApplicationArea = All;
                    Enabled = false;
                }
                field(ItemNumber; ItemNumber) { ApplicationArea = All; }
                field(ItemName1; ItemName1) { ApplicationArea = All; }
                field(ItemName2; ItemName2) { ApplicationArea = All; }
                field(ItemName3; ItemName3) { ApplicationArea = All; }
                field(ItemType; ItemType) { ApplicationArea = All; }
                field(DiscGroup; DiscGroup) { ApplicationArea = All; }
                field(CostCurrency; CostCurrency) { ApplicationArea = All; }
                field(CostPrice; CostPrice) { ApplicationArea = All; }
                field(Group; Group) { ApplicationArea = All; }
                field(SalesModel; SalesModel) { ApplicationArea = All; }
                field(CostingMethod; CostingMethod) { ApplicationArea = All; }
                field(PurchSeriesSize; PurchSeriesSize) { ApplicationArea = All; }
                field(PrimaryVendor; PrimaryVendor) { ApplicationArea = All; }
                field(VendItemNumber; VendItemNumber) { ApplicationArea = All; }
                field(Blocked; Blocked) { ApplicationArea = All; }
                field(Alternative; Alternative) { ApplicationArea = All; }
                field(AltItemNumber; AltItemNumber) { ApplicationArea = All; }
                field(Decimals_; Decimals_) { ApplicationArea = All; }
                field(DEL_SalesDuty; DEL_SalesDuty) { ApplicationArea = All; }
                field(Commission; Commission) { ApplicationArea = All; }
                field(ImageFile; ImageFile) { ApplicationArea = All; }
                field(NetWeight; NetWeight) { ApplicationArea = All; }
                field(Volume; Volume) { ApplicationArea = All; }
                field(TariffNumber; TariffNumber) { ApplicationArea = All; }
                field(UnitCode; UnitCode) { ApplicationArea = All; }
                field(OneTimeItem; OneTimeItem) { ApplicationArea = All; }
                field(CostType; CostType) { ApplicationArea = All; }
                field(ExtraCost; ExtraCost) { ApplicationArea = All; }
                field(PurchCostModel; PurchCostModel) { ApplicationArea = All; }
                field(MainLocation; MainLocation) { ApplicationArea = All; }
                field(InvenLocation; InvenLocation) { ApplicationArea = All; }
                field(PurchVat; PurchVat) { ApplicationArea = All; }
                field(RESERVED2; RESERVED2) { ApplicationArea = All; }
                field(Inventory; Inventory) { ApplicationArea = All; }
                field(Delivered; Delivered) { ApplicationArea = All; }
                field(Reserved; Reserved) { ApplicationArea = All; }
                field(Received; Received) { ApplicationArea = All; }
                field(Ordered; Ordered) { ApplicationArea = All; }
                field(InventoryValue; InventoryValue) { ApplicationArea = All; }
                field(DeliveredValue; DeliveredValue) { ApplicationArea = All; }
                field(ReceivedValue; ReceivedValue) { ApplicationArea = All; }
                field(Department; Department) { ApplicationArea = All; }
                field(CostPriceUnit; CostPriceUnit) { ApplicationArea = All; }
                field(DEL_PurchDuty; DEL_PurchDuty) { ApplicationArea = All; }
                field(Level; Level) { ApplicationArea = All; }
                field(Pulled; Pulled) { ApplicationArea = All; }
                field(WarnNegativeInventory; WarnNegativeInventory) { ApplicationArea = All; }
                field(NegativeInventory; NegativeInventory) { ApplicationArea = All; }
                field(IgnoreListCode; IgnoreListCode) { ApplicationArea = All; }
                field(PayCType; PayCType) { ApplicationArea = All; }
                field(ItemTracking; ItemTracking) { ApplicationArea = All; }
                field(ItemTrackGroup; ItemTrackGroup) { ApplicationArea = All; }
                field(ProjCostFactor; ProjCostFactor) { ApplicationArea = All; }
                field(Centre; Centre) { ApplicationArea = All; }
                field(Purpose; Purpose) { ApplicationArea = All; }
                field(SupplFactor; SupplFactor) { ApplicationArea = All; }
                field(SupplementaryUnits; SupplementaryUnits) { ApplicationArea = All; }
                field(MarkedPhysical; MarkedPhysical) { ApplicationArea = All; }
                field(LastMovementDate; LastMovementDate) { ApplicationArea = All; }
                field(VatGroup; VatGroup) { ApplicationArea = All; }
                field(StdItemNumber; StdItemNumber) { ApplicationArea = All; }
            }
        }
    }

    var
        C5MigrDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
        MigrationErrorText: Text[250];

    trigger OnAfterGetRecord();
    var
        DataMigrationError: Record "Data Migration Error";
    begin
        DataMigrationError.GetErrorMessage(C5MigrDashboardMgt.GetC5MigrationTypeTxt(), RecordId(), MigrationErrorText);
    end;

}