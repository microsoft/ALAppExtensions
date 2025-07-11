// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47038 "SL SOShipLot"
{
    Access = Internal;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; BoxRef; Text[5])
        {
            Caption = 'BoxRef';
        }
        field(2; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(3; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(4; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(5; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(6; DropShip; Integer)
        {
            Caption = 'DropShip';
        }
        field(7; InvtId; Text[30])
        {
            Caption = 'InvtId';
        }
        field(8; LineRef; Text[5])
        {
            Caption = 'LineRef';
        }
        field(9; LotSerNbr; Text[25])
        {
            Caption = 'LotSerNbr';
        }
        field(10; LotSerRef; Text[5])
        {
            Caption = 'LotSerRef';
        }
        field(11; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(12; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(13; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(14; MfgrLotSerNbr; Text[25])
        {
            Caption = 'MfgrLotSerNbr';
        }
        field(15; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(16; OrdLineRef; Text[5])
        {
            Caption = 'OrdLineRef';
        }
        field(17; OrdLotSerRef; Text[5])
        {
            Caption = 'OrdLotSerRef';
        }
        field(18; OrdNbr; Text[15])
        {
            Caption = 'OrdNbr';
        }
        field(19; OrdSchedRef; Text[5])
        {
            Caption = 'OrdSchedRef';
        }
        field(20; QtyPick; Decimal)
        {
            Caption = 'QtyPick';
        }
        field(21; QtyPickStock; Decimal)
        {
            Caption = 'QtyPickStock';
        }
        field(22; QtyShip; Decimal)
        {
            Caption = 'QtyShip';
        }
        field(23; RMADisposition; Text[3])
        {
            Caption = 'RMADisposition';
        }
        field(24; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(25; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(26; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(27; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(28; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(29; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(30; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(31; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(32; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(33; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(34; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(35; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(36; ShipperID; Text[15])
        {
            Caption = 'ShipperID';
        }
        field(37; SpecificCostID; Text[25])
        {
            Caption = 'SpecificCostID';
        }
        field(38; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(39; User10; DateTime)
        {
            Caption = 'User10';
        }
        field(40; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(41; User3; Text[30])
        {
            Caption = 'User3';
        }
        field(42; User4; Text[30])
        {
            Caption = 'User4';
        }
        field(43; User5; Decimal)
        {
            Caption = 'User5';
        }
        field(44; User6; Decimal)
        {
            Caption = 'User6';
        }
        field(45; User7; Text[10])
        {
            Caption = 'User7';
        }
        field(46; User8; Text[10])
        {
            Caption = 'User8';
        }
        field(47; User9; DateTime)
        {
            Caption = 'User9';
        }
        field(48; WhseLoc; Text[10])
        {
            Caption = 'WhseLoc';
        }
    }

    keys
    {
        key(Key1; CpnyID, ShipperID, LineRef, LotSerRef)
        {
            Clustered = true;
        }
    }
}