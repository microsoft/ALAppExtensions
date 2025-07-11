// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47042 "SL LotSerMst"
{
    Access = Internal;
    Caption = 'SL LotSerMst';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Cost; Decimal)
        {
            Caption = 'Cost';
        }
        field(2; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(3; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(4; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(5; ExpDate; DateTime)
        {
            Caption = 'ExpDate';
        }
        field(6; InvtID; Text[30])
        {
            Caption = 'InvtID';
        }
        field(7; LIFODate; DateTime)
        {
            Caption = 'LIFODate';
        }
        field(8; LotSerNbr; Text[25])
        {
            Caption = 'LotSerNbr';
        }
        field(9; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(10; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(11; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(12; MfgrLotSerNbr; Text[25])
        {
            Caption = 'MfgrLotSerNbr';
        }
        field(13; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(14; OrigQty; Decimal)
        {
            Caption = 'OrigQty';
        }
        field(15; PrjINQtyAlloc; Decimal)
        {
            Caption = 'PrjINQtyAlloc';
        }
        field(16; PrjINQtyAllocIN; Decimal)
        {
            Caption = 'PrjINQtyAllocIN';
        }
        field(17; PrjINQtyAllocPORet; Decimal)
        {
            Caption = 'PrjINQtyAllocPORet';
        }
        field(18; PrjINQtyAllocSO; Decimal)
        {
            Caption = 'PrjINQtyAllocSO';
        }
        field(19; PrjINQtyShipNotInv; Decimal)
        {
            Caption = 'PrjINQtyShipNotInv';
        }
        field(20; QtyAlloc; Decimal)
        {
            Caption = 'QtyAlloc';
        }
        field(21; QtyAllocBM; Decimal)
        {
            Caption = 'QtyAllocBM';
        }
        field(22; QtyAllocIN; Decimal)
        {
            Caption = 'QtyAllocIN';
        }
        field(23; QtyAllocOther; Decimal)
        {
            Caption = 'QtyAllocOther';
        }
        field(24; QtyAllocPORet; Decimal)
        {
            Caption = 'QtyAllocPORet';
        }
        field(25; QtyAllocProjIN; Decimal)
        {
            Caption = 'QtyAllocProjIN';
        }
        field(26; QtyAllocSD; Decimal)
        {
            Caption = 'QtyAllocSD';
        }
        field(27; QtyAllocSO; Decimal)
        {
            Caption = 'QtyAllocSO';
        }
        field(28; QtyAvail; Decimal)
        {
            Caption = 'QtyAvail';
        }
        field(29; QtyOnHand; Decimal)
        {
            Caption = 'QtyOnHand';
        }
        field(30; QtyShipNotInv; Decimal)
        {
            Caption = 'QtyShipNotInv';
        }
        field(31; QtyWORlsedDemand; Decimal)
        {
            Caption = 'QtyWORlsedDemand';
        }
        field(32; RcptDate; DateTime)
        {
            Caption = 'RcptDate';
        }
        field(33; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(34; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(35; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(36; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(37; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(38; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(39; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(40; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(41; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(42; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(43; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(44; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(45; ShipConfirmQty; Decimal)
        {
            Caption = 'ShipConfirmQty';
        }
        field(46; ShipContCode; Text[20])
        {
            Caption = 'ShipContCode';
        }
        field(47; SiteID; Text[10])
        {
            Caption = 'SiteID';
        }
        field(48; Source; Text[2])
        {
            Caption = 'Source';
        }
        field(49; SrcOrdNbr; Text[10])
        {
            Caption = 'SrcOrdNbr';
        }
        field(50; Status; Text[1])
        {
            Caption = 'Status';
        }
        field(51; StatusDate; DateTime)
        {
            Caption = 'StatusDate';
        }
        field(52; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(53; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(54; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(55; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(56; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(57; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(58; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(59; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(60; WarrantyDate; DateTime)
        {
            Caption = 'WarrantyDate';
        }
        field(61; WhseLoc; Text[10])
        {
            Caption = 'WhseLoc';
        }
    }

    keys
    {
        key(Key1; InvtID, LotSerNbr, SiteID, WhseLoc)
        {
            Clustered = true;
        }
    }
}