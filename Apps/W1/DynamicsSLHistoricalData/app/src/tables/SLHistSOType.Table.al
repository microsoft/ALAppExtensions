// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

table 42818 "SL Hist. SOType"
{
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(76; Active; Integer)
        {
            Caption = 'Active';
        }
        field(1; ARAcct; Text[10])
        {
            Caption = 'ARAcct';
        }
        field(2; ARSub; Text[31])
        {
            Caption = 'ARSub';
        }
        field(3; AssemblyOnSat; Integer)
        {
            Caption = 'AssemblyOnSat';
        }
        field(4; AssemblyOnSun; Integer)
        {
            Caption = 'AssemblyOnSun';
        }
        field(5; AutoReleaseReturns; Integer)
        {
            Caption = 'AutoReleaseReturns';
        }
        field(6; Behavior; Text[4])
        {
            Caption = 'Behavior';
        }
        field(7; CancelDays; Integer)
        {
            Caption = 'CancelDays';
        }
        field(8; COGSAcct; Text[10])
        {
            Caption = 'COGSAcct';
        }
        field(9; COGSSub; Text[31])
        {
            Caption = 'COGSSub';
        }
        field(10; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(11; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd';
        }
        field(12; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd';
        }
        field(13; Crtd_User; Text[10])
        {
            Caption = 'Crtd';
        }
        field(14; Descr; Text[30])
        {
            Caption = 'Descr';
        }
        field(15; DiscAcct; Text[10])
        {
            Caption = 'DiscAcct';
        }
        field(16; DiscSub; Text[31])
        {
            Caption = 'DiscSub';
        }
        field(17; Disp; Text[3])
        {
            Caption = 'Disp';
        }
        field(18; EnterLotSer; Integer)
        {
            Caption = 'EnterLotSer';
        }
        field(19; FrtAcct; Text[10])
        {
            Caption = 'FrtAcct';
        }
        field(20; FrtSub; Text[31])
        {
            Caption = 'FrtSub';
        }
        field(21; InvAcct; Text[10])
        {
            Caption = 'InvAcct';
        }
        field(22; InvcNbrAR; Integer)
        {
            Caption = 'InvcNbrAR';
        }
        field(23; InvcNbrPrefix; Text[15])
        {
            Caption = 'InvcNbrPrefix';
        }
        field(24; InvcNbrType; Text[4])
        {
            Caption = 'InvcNbrType';
        }
        field(25; InvSub; Text[31])
        {
            Caption = 'InvSub';
        }
        field(26; LastInvcNbr; Text[10])
        {
            Caption = 'LastInvcNbr';
        }
        field(27; LastOrdNbr; Text[10])
        {
            Caption = 'LastOrdNbr';
        }
        field(28; LastShipperNbr; Text[10])
        {
            Caption = 'LastShipperNbr';
        }
        field(29; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd';
        }
        field(30; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd';
        }
        field(31; LUpd_User; Text[10])
        {
            Caption = 'LUpd';
        }
        field(32; MiscAcct; Text[10])
        {
            Caption = 'MiscAcct';
        }
        field(33; MiscSub; Text[31])
        {
            Caption = 'MiscSub';
        }
        field(34; NoAutoCreateShippers; Integer)
        {
            Caption = 'NoAutoCreateShippers';
        }
        field(35; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(36; OrdNbrPrefix; Text[15])
        {
            Caption = 'OrdNbrPrefix';
        }
        field(37; OrdNbrType; Text[4])
        {
            Caption = 'OrdNbrType';
        }
        field(38; ProjectStatus; Text[1])
        {
            Caption = 'ProjectStatus';
        }
        field(39; RequireDetailAppr; Integer)
        {
            Caption = 'RequireDetailAppr';
        }
        field(40; RequireManRelease; Integer)
        {
            Caption = 'RequireManRelease';
        }
        field(41; RequireTechAppr; Integer)
        {
            Caption = 'RequireTechAppr';
        }
        field(42; ReturnOrderTypeID; Text[4])
        {
            Caption = 'ReturnOrderTypeID';
        }
        field(43; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(44; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(45; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(46; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(47; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(48; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(49; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(50; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(51; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(52; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(53; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(54; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(55; ShipperPrefix; Text[15])
        {
            Caption = 'ShipperPrefix';
        }
        field(56; ShipperType; Text[4])
        {
            Caption = 'ShipperType';
        }
        field(57; ShiptoType; Text[1])
        {
            Caption = 'ShiptoType';
        }
        field(58; SlsAcct; Text[10])
        {
            Caption = 'SlsAcct';
        }
        field(59; SlsSub; Text[31])
        {
            Caption = 'SlsSub';
        }
        field(60; SOTypeID; Text[4])
        {
            Caption = 'SOTypeID';
        }
        field(61; StdOrdType; Integer)
        {
            Caption = 'StdOrdType';
        }
        field(62; TemplateProject; Text[16])
        {
            Caption = 'TemplateProject';
        }
        field(63; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(64; User10; DateTime)
        {
            Caption = 'User10';
        }
        field(65; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(66; User3; Text[30])
        {
            Caption = 'User3';
        }
        field(67; User4; Text[30])
        {
            Caption = 'User4';
        }
        field(68; User5; Decimal)
        {
            Caption = 'User5';
        }
        field(69; User6; Decimal)
        {
            Caption = 'User6';
        }
        field(70; User7; Text[10])
        {
            Caption = 'User7';
        }
        field(71; User8; Text[10])
        {
            Caption = 'User8';
        }
        field(72; User9; DateTime)
        {
            Caption = 'User9';
        }
        field(73; WholeOrdDiscAcct; Text[10])
        {
            Caption = 'WholeOrdDiscAcct';
        }
        field(74; WholeOrdDiscSub; Text[31])
        {
            Caption = 'WholeOrdDiscSub';
        }
    }

    keys
    {
        key(PK; CpnyID, SOTypeID)
        {
            Clustered = true;
        }
    }
}