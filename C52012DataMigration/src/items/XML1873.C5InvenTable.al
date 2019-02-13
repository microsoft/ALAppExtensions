// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

xmlport 1873 "C5 InvenTable"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'InvenTableDocument';
            tableelement(C5InvenTable; "C5 InvenTable")
            {
                fieldelement(DEL_UserLock; C5InvenTable.DEL_UserLock) { }
                fieldelement(ItemNumber; C5InvenTable.ItemNumber) { }
                fieldelement(ItemName1; C5InvenTable.ItemName1) { }
                fieldelement(ItemName2; C5InvenTable.ItemName2) { }
                fieldelement(ItemName3; C5InvenTable.ItemName3) { }
                fieldelement(ItemType; C5InvenTable.ItemType) { }
                fieldelement(DiscGroup; C5InvenTable.DiscGroup) { }
                fieldelement(CostCurrency; C5InvenTable.CostCurrency) { }
                fieldelement(CostPrice; C5InvenTable.CostPrice) { }
                fieldelement(Group; C5InvenTable.Group) { }
                fieldelement(SalesModel; C5InvenTable.SalesModel) { }
                fieldelement(CostingMethod; C5InvenTable.CostingMethod) { }
                fieldelement(PurchSeriesSize; C5InvenTable.PurchSeriesSize) { }
                fieldelement(PrimaryVendor; C5InvenTable.PrimaryVendor) { }
                fieldelement(VendItemNumber; C5InvenTable.VendItemNumber) { }
                fieldelement(Blocked; C5InvenTable.Blocked) { }
                fieldelement(Alternative; C5InvenTable.Alternative) { }
                fieldelement(AltItemNumber; C5InvenTable.AltItemNumber) { }
                fieldelement(Decimals_; C5InvenTable.Decimals_) { }
                fieldelement(DEL_SalesDuty; C5InvenTable.DEL_SalesDuty) { }
                fieldelement(Commission; C5InvenTable.Commission) { }
                fieldelement(ImageFile; C5InvenTable.ImageFile) { }
                fieldelement(NetWeight; C5InvenTable.NetWeight) { }
                fieldelement(Volume; C5InvenTable.Volume) { }
                fieldelement(TariffNumber; C5InvenTable.TariffNumber) { }
                fieldelement(UnitCode; C5InvenTable.UnitCode) { }
                fieldelement(OneTimeItem; C5InvenTable.OneTimeItem) { }
                fieldelement(CostType; C5InvenTable.CostType) { }
                fieldelement(ExtraCost; C5InvenTable.ExtraCost) { }
                fieldelement(PurchCostModel; C5InvenTable.PurchCostModel) { }
                fieldelement(MainLocation; C5InvenTable.MainLocation) { }
                fieldelement(InvenLocation; C5InvenTable.InvenLocation) { }
                fieldelement(PurchVat; C5InvenTable.PurchVat) { }
                fieldelement(RESERVED2; C5InvenTable.RESERVED2) { }
                fieldelement(Inventory; C5InvenTable.Inventory) { }
                fieldelement(Delivered; C5InvenTable.Delivered) { }
                fieldelement(Reserved; C5InvenTable.Reserved) { }
                fieldelement(Received; C5InvenTable.Received) { }
                fieldelement(Ordered; C5InvenTable.Ordered) { }
                fieldelement(InventoryValue; C5InvenTable.InventoryValue) { }
                fieldelement(DeliveredValue; C5InvenTable.DeliveredValue) { }
                fieldelement(ReceivedValue; C5InvenTable.ReceivedValue) { }
                fieldelement(Department; C5InvenTable.Department) { }
                fieldelement(CostPriceUnit; C5InvenTable.CostPriceUnit) { }
                fieldelement(DEL_PurchDuty; C5InvenTable.DEL_PurchDuty) { }
                fieldelement(Level; C5InvenTable.Level) { }
                fieldelement(Pulled; C5InvenTable.Pulled) { }
                fieldelement(WarnNegativeInventory; C5InvenTable.WarnNegativeInventory) { }
                fieldelement(NegativeInventory; C5InvenTable.NegativeInventory) { }
                fieldelement(IgnoreListCode; C5InvenTable.IgnoreListCode) { }
                fieldelement(PayCType; C5InvenTable.PayCType) { }
                fieldelement(ItemTracking; C5InvenTable.ItemTracking) { }
                fieldelement(ItemTrackGroup; C5InvenTable.ItemTrackGroup) { }
                fieldelement(ProjCostFactor; C5InvenTable.ProjCostFactor) { }
                fieldelement(Centre; C5InvenTable.Centre) { }
                fieldelement(Purpose; C5InvenTable.Purpose) { }
                fieldelement(SupplFactor; C5InvenTable.SupplFactor) { }
                fieldelement(SupplementaryUnits; C5InvenTable.SupplementaryUnits) { }
                fieldelement(MarkedPhysical; C5InvenTable.MarkedPhysical) { }
                textelement(LastMovementDateText)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(LastMovementDateText, CopyStr(DateFormatStringTxt, 1, 20), C5InvenTable.LastMovementDate);
                    end;
                }

                fieldelement(VatGroup; C5InvenTable.VatGroup) { }
                fieldelement(StdItemNumber; C5InvenTable.StdItemNumber) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5InvenTable.RecId := Counter;
                    Counter += 1;
                end;
            }
        }
    }

    var
        C5HelperFunctions: Codeunit "C5 Helper Functions";
        DateFormatStringTxt: label 'yyyy/MM/dd', locked = true;
        Counter: Integer;
}

