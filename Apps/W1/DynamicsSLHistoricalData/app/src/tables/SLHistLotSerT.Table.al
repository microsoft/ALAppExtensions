// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

table 42807 "SL Hist. LotSerT"
{
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; BatNbr; Text[10])
        {
            Caption = 'BatNbr';
        }
        field(2; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(3; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTimeDateTime';
        }
        field(4; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(5; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(6; CustID; Text[15])
        {
            Caption = 'CustID';
        }
        field(7; ExpDate; DateTime)
        {
            Caption = 'ExpDate';
        }
        field(8; INTranLineID; Integer)
        {
            Caption = 'INTranLineID';
        }
        field(9; INTranLineRef; Text[5])
        {
            Caption = 'INTranLineRef';
        }
        field(10; InvtID; Text[30])
        {
            Caption = 'InvtID';
        }
        field(11; InvtMult; Integer)
        {
            Caption = 'InvtMult';
        }
        field(12; KitID; Text[30])
        {
            Caption = 'KitID';
        }
        field(13; LineNbr; Integer)
        {
            Caption = 'LineNbr';
        }
        field(14; LotSerNbr; Text[25])
        {
            Caption = 'LotSerNbr';
        }
        field(15; LotSerRef; Text[5])
        {
            Caption = 'LotSerRef';
        }
        field(16; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(17; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(18; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(19; MfgrLotSerNbr; Text[25])
        {
            Caption = 'MfgrLotSerNbr';
        }
        field(20; NoQtyUpdate; Integer)
        {
            Caption = 'NoQtyUpdate';
        }
        field(21; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(22; ParInvtID; Text[30])
        {
            Caption = 'ParInvtID';
        }
        field(23; ParLotSerNbr; Text[25])
        {
            Caption = 'ParLotSerNbr';
        }
        field(24; Qty; Decimal)
        {
            Caption = 'Qty';
        }
        field(25; RcptNbr; Text[10])
        {
            Caption = 'RcptNbr';
        }
        field(26; RecordID; Integer)
        {
            Caption = 'RecordID';
        }
        field(27; RefNbr; Text[15])
        {
            Caption = 'RefNbr';
        }
        field(28; Retired; Integer)
        {
            Caption = 'Retired';
        }
        field(29; Rlsed; Integer)
        {
            Caption = 'Rlsed';
        }
        field(30; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(31; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(32; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(33; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(34; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(35; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(36; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(37; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(38; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(39; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(40; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(41; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(42; ShipContCode; Text[20])
        {
            Caption = 'ShipContCode';
        }
        field(43; ShipmentNbr; Integer)
        {
            Caption = 'ShipmentNbr';
        }
        field(44; SiteID; Text[10])
        {
            Caption = 'SiteID';
        }
        field(45; ToSiteID; Text[10])
        {
            Caption = 'ToSiteID';
        }
        field(46; ToWhseLoc; Text[10])
        {
            Caption = 'ToWhseLoc';
        }
        field(47; TranDate; DateTime)
        {
            Caption = 'TranDate';
        }
        field(48; TranSrc; Text[2])
        {
            Caption = 'TranSrc';
        }
        field(49; TranTime; DateTime)
        {
            Caption = 'TranTime';
        }
        field(50; TranType; Text[2])
        {
            Caption = 'TranType';
        }
        field(51; UnitCost; Decimal)
        {
            Caption = 'UnitCost';
        }
        field(52; UnitPrice; Decimal)
        {
            Caption = 'UnitPrice';
        }
        field(53; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(54; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(55; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(56; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(57; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(58; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(59; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(60; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(61; WarrantyDate; DateTime)
        {
            Caption = 'WarrantyDate';
        }
        field(62; WhseLoc; Text[10])
        {
            Caption = 'WhseLoc';
        }
    }

    keys
    {
        key(PK; LotSerNbr, RecordID)
        {
            Clustered = true;
        }
    }
}