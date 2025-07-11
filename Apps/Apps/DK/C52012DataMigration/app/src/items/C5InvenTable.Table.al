// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

table 1862 "C5 InvenTable"
{
    ReplicateData = false;

    fields
    {
        field(1; RecId; Integer)
        {
            Caption = 'Row number';
        }
        field(2; LastChanged; Date)
        {
            Caption = 'Last changed';
        }
        field(3; DEL_UserLock; Integer)
        {
            Caption = 'Lock';
        }
        field(4; ItemNumber; Code[20])
        {
            Caption = 'Item number';
        }
        field(5; ItemName1; Text[40])
        {
            Caption = 'Item name';
        }
        field(6; ItemName2; Text[40])
        {
            Caption = 'Suppl. item name 1';
        }
        field(7; ItemName3; Text[40])
        {
            Caption = 'Suppl. item name 2';
        }
        field(8; ItemType; Option)
        {
            Caption = 'Item type';
            OptionMembers = Item,Service,BOM,Kit;
        }
        field(9; DiscGroup; Code[10])
        {
            Caption = 'Discount group';
        }
        field(10; CostCurrency; Code[3])
        {
            Caption = 'Cost currency';
        }
        field(11; CostPrice; Decimal)
        {
            Caption = 'Cost price';
        }
        field(12; Group; Code[10])
        {
            Caption = 'Group';
        }
        field(13; SalesModel; Option)
        {
            Caption = 'Sales model';
            OptionMembers = "No change","Last sale",Adjust;
        }
        field(14; CostingMethod; Option)
        {
            Caption = 'Inven. model';
            OptionMembers = FIFO,LIFO,"Cost price",Average,"Serial number";
        }
        field(15; PurchSeriesSize; Decimal)
        {
            Caption = 'Purch. qty';
        }
        field(16; PrimaryVendor; Code[10])
        {
            Caption = 'Primary Vendor';
        }
        field(17; VendItemNumber; Text[20])
        {
            Caption = 'Vendor item no.';
        }
        field(18; Blocked; Option)
        {
            Caption = 'Locked';
            OptionMembers = No,Yes;
        }
        field(19; Alternative; Option)
        {
            Caption = 'Alternative';
            OptionMembers = Never,"Not available",Always;
        }
        field(20; AltItemNumber; Code[20])
        {
            Caption = 'Alt. item';
        }
        field(21; Decimals_; Integer)
        {
            Caption = 'Decimals';
        }
        field(22; DEL_SalesDuty; Text[10])
        {
            Caption = 'DELETESalesDuty';
        }
        field(23; Commission; Option)
        {
            Caption = 'Commission';
            OptionMembers = No,Yes;
        }
        field(24; ImageFile; Text[250])
        {
            Caption = 'Image';
        }
        field(25; NetWeight; Decimal)
        {
            Caption = 'Net weight';
        }
        field(26; Volume; Decimal)
        {
            Caption = 'Volume';
        }
        field(27; TariffNumber; Code[20])
        {
            Caption = 'Item CN8 codes';
        }
        field(28; UnitCode; Code[10])
        {
            Caption = 'Unit';
        }
        field(29; OneTimeItem; Option)
        {
            Caption = 'One-off item';
            OptionMembers = No,Yes;
        }
        field(30; CostType; Text[10])
        {
            Caption = 'Cost type';
        }
        field(31; ExtraCost; Decimal)
        {
            Caption = 'Misc. charges';
        }
        field(32; PurchCostModel; Option)
        {
            Caption = 'Purch. cost model';
            OptionMembers = "No change","Last purchase",Average;
        }
        field(33; MainLocation; Text[10])
        {
            Caption = 'Main inventory';
        }
        field(34; InvenLocation; Option)
        {
            Caption = 'Location';
            OptionMembers = No,Yes;
        }
        field(35; PurchVat; Code[10])
        {
            Caption = 'Purch. VAT';
        }
        field(36; RESERVED2; Text[10])
        {
            Caption = 'RESERVED2';
        }
        field(37; Inventory; Decimal)
        {
            Caption = 'Inventory';
        }
        field(38; Delivered; Decimal)
        {
            Caption = 'Delivered';
        }
        field(39; Reserved; Decimal)
        {
            Caption = 'Reserved';
        }
        field(40; Received; Decimal)
        {
            Caption = 'Received';
        }
        field(41; Ordered; Decimal)
        {
            Caption = 'Ordered';
        }
        field(42; InventoryValue; Decimal)
        {
            Caption = 'Inventory value in LCY';
        }
        field(43; DeliveredValue; Decimal)
        {
            Caption = 'Value delivered in LCY';
        }
        field(44; ReceivedValue; Decimal)
        {
            Caption = 'Value received in LCY';
        }
        field(45; Department; Code[10])
        {
            Caption = 'Department';
        }
        field(46; CostPriceUnit; Decimal)
        {
            Caption = 'Cost price unit';
        }
        field(47; DEL_PurchDuty; Text[10])
        {
            Caption = 'DELETEPurchDuty';
        }
        field(48; Level; Integer)
        {
            Caption = 'Level';
        }
        field(49; Pulled; Decimal)
        {
            Caption = 'Pulled';
        }
        field(50; WarnNegativeInventory; Option)
        {
            Caption = 'Warning';
            OptionMembers = No,Yes;
        }
        field(51; NegativeInventory; Option)
        {
            Caption = 'Negative';
            OptionMembers = No,Yes;
        }
        field(52; IgnoreListCode; Option)
        {
            Caption = '-Lst';
            OptionMembers = No,Yes;
        }
        field(53; PayCType; Text[10])
        {
            Caption = 'Payroll CT';
        }
        field(54; ItemTracking; Option)
        {
            Caption = 'Item tracking';
            OptionMembers = None,Batch,"Serial number";
        }
        field(55; ItemTrackGroup; Text[10])
        {
            Caption = 'Tracking group';
        }
        field(56; ProjCostFactor; Decimal)
        {
            Caption = 'Proj. factor';
        }
        field(57; Centre; Code[10])
        {
            Caption = 'Cost centre';
        }
        field(58; Purpose; Code[10])
        {
            Caption = 'Purpose';
        }
        field(59; SupplFactor; Decimal)
        {
            Caption = 'Suppl. factor';
        }
        field(60; SupplementaryUnits; Text[13])
        {
            Caption = 'Supplementary unit';
        }
        field(61; MarkedPhysical; Decimal)
        {
            Caption = 'Mrk. physical';
        }
        field(62; LastMovementDate; Date)
        {
            Caption = 'Latest movement';
        }
        field(63; VatGroup; Code[10])
        {
            Caption = 'VAT group';
        }
        field(64; StdItemNumber; Option)
        {
            Caption = 'Default';
            OptionMembers = No,Yes;
        }
    }

    keys
    {
        key(PK; RecId)
        {
            Clustered = true;
        }
    }
}

