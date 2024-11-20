// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

table 42816 "SL Hist. SOShipLine"
{
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; AlternateID; Text[30])
        {
            Caption = 'AlternateID';
        }
        field(2; AltIDType; Text[1])
        {
            Caption = 'AltIDType';
        }
        field(3; AvgCost; Decimal)
        {
            Caption = 'AvgCost';
        }
        field(4; BMICost; Decimal)
        {
            Caption = 'BMICost';
        }
        field(5; BMICuryID; Text[4])
        {
            Caption = 'BMICuryID';
        }
        field(6; BMIEffDate; DateTime)
        {
            Caption = 'BMIEffDate';
        }
        field(7; BMIExtPriceInvc; Decimal)
        {
            Caption = 'BMIExtPriceInvc';
        }
        field(8; BMIMultDiv; Text[1])
        {
            Caption = 'BMIMultDiv';
        }
        field(9; BMIRate; Decimal)
        {
            Caption = 'BMIRate';
        }
        field(10; BMIRtTp; Text[6])
        {
            Caption = 'BMIRtTp';
        }
        field(11; BMISlsPrice; Decimal)
        {
            Caption = 'BMISlsPrice';
        }
        field(12; ChainDisc; Text[15])
        {
            Caption = 'ChainDisc';
        }
        field(13; CmmnPct; Decimal)
        {
            Caption = 'CmmnPct';
        }
        field(14; CnvFact; Decimal)
        {
            Caption = 'CnvFact';
        }
        field(15; COGSAcct; Text[10])
        {
            Caption = 'COGSAcct';
        }
        field(16; COGSSub; Text[24])
        {
            Caption = 'COGSSub';
        }
        field(17; CommCost; Decimal)
        {
            Caption = 'CommCost';
        }
        field(18; Cost; Decimal)
        {
            Caption = 'Cost';
        }
        field(19; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(20; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(21; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(22; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(23; CuryCommCost; Decimal)
        {
            Caption = 'CuryCommCost';
        }
        field(24; CuryCost; Decimal)
        {
            Caption = 'CuryCost';
        }
        field(25; CuryListPrice; Decimal)
        {
            Caption = 'CuryListPrice';
        }
        field(26; CurySlsPrice; Decimal)
        {
            Caption = 'CurySlsPrice';
        }
        field(27; CuryTaxAmt00; Decimal)
        {
            Caption = 'CuryTaxAmt00';
        }
        field(28; CuryTaxAmt01; Decimal)
        {
            Caption = 'CuryTaxAmt01';
        }
        field(29; CuryTaxAmt02; Decimal)
        {
            Caption = 'CuryTaxAmt02';
        }
        field(30; CuryTaxAmt03; Decimal)
        {
            Caption = 'CuryTaxAmt03';
        }
        field(31; CuryTotCommCost; Decimal)
        {
            Caption = 'CuryTotCommCost';
        }
        field(32; CuryTotCost; Decimal)
        {
            Caption = 'CuryTotCost';
        }
        field(33; CuryTotInvc; Decimal)
        {
            Caption = 'CuryTotInvc';
        }
        field(34; CuryTotMerch; Decimal)
        {
            Caption = 'CuryTotMerch';
        }
        field(35; CuryTxblAmt00; Decimal)
        {
            Caption = 'CuryTxblAmt00';
        }
        field(36; CuryTxblAmt01; Decimal)
        {
            Caption = 'CuryTxblAmt01';
        }
        field(37; CuryTxblAmt02; Decimal)
        {
            Caption = 'CuryTxblAmt02';
        }
        field(38; CuryTxblAmt03; Decimal)
        {
            Caption = 'CuryTxblAmt03';
        }
        field(39; Descr; Text[60])
        {
            Caption = 'Descr';
        }
        field(40; DescrLang; Text[30])
        {
            Caption = 'DescrLang';
        }
        field(41; DiscAcct; Text[10])
        {
            Caption = 'DiscAcct';
        }
        field(42; DiscPct; Decimal)
        {
            Caption = 'DiscPct';
        }
        field(43; DiscSub; Text[24])
        {
            Caption = 'DiscSub';
        }
        field(44; Disp; Text[3])
        {
            Caption = 'Disp';
        }
        field(45; InspID; Text[2])
        {
            Caption = 'InspID';
        }
        field(46; InspNoteID; Integer)
        {
            Caption = 'InspNoteID';
        }
        field(47; InvAcct; Text[10])
        {
            Caption = 'InvAcct';
        }
        field(48; InvSub; Text[24])
        {
            Caption = 'InvSub';
        }
        field(49; InvtID; Text[30])
        {
            Caption = 'InvtID';
        }
        field(50; IRDemand; Integer)
        {
            Caption = 'IRDemand';
        }
        field(51; IRInvtID; Text[30])
        {
            Caption = 'IRInvtID';
        }
        field(52; IRSiteID; Text[10])
        {
            Caption = 'IRSiteID';
        }
        field(53; ItemGLClassID; Text[4])
        {
            Caption = 'ItemGLClassID';
        }
        field(54; LineNbr; Integer)
        {
            Caption = 'LineNbr';
        }
        field(55; LineRef; Text[5])
        {
            Caption = 'LineRef';
        }
        field(56; ListPrice; Decimal)
        {
            Caption = 'ListPrice';
        }
        field(57; LotSerCntr; Integer)
        {
            Caption = 'LotSerCntr';
        }
        field(58; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(59; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(60; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(61; ManualCost; Integer)
        {
            Caption = 'ManualCost';
        }
        field(62; ManualPrice; Integer)
        {
            Caption = 'ManualPrice';
        }
        field(63; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(64; OrdLineRef; Text[5])
        {
            Caption = 'OrdLineRef';
        }
        field(65; OrdNbr; Text[15])
        {
            Caption = 'OrdNbr';
        }
        field(66; OrigBO; Decimal)
        {
            Caption = 'OrigBO';
        }
        field(67; OrigINBatNbr; Text[10])
        {
            Caption = 'OrigINBatNbr';
        }
        field(68; OrigInvcNbr; Text[15])
        {
            Caption = 'OrigInvcNbr';
        }
        field(69; OrigInvtID; Text[30])
        {
            Caption = 'OrigInvtID';
        }
        field(70; OrigShipperID; Text[15])
        {
            Caption = 'OrigShipperID';
        }
        field(71; OrigShipperLineRef; Text[5])
        {
            Caption = 'OrigShipperLineRef';
        }
        field(72; ProjectID; Text[16])
        {
            Caption = 'ProjectID';
        }
        field(73; QtyBO; Decimal)
        {
            Caption = 'QtyBO';
        }
        field(74; QtyFuture; Decimal)
        {
            Caption = 'QtyFuture';
        }
        field(75; QtyOrd; Decimal)
        {
            Caption = 'QtyOrd';
        }
        field(76; QtyPick; Decimal)
        {
            Caption = 'QtyPick';
        }
        field(77; QtyPrevShip; Decimal)
        {
            Caption = 'QtyPrevShip';
        }
        field(78; QtyShip; Decimal)
        {
            Caption = 'QtyShip';
        }
        field(79; RebateID; Text[10])
        {
            Caption = 'RebateID';
        }
        field(80; RebatePer; Text[6])
        {
            Caption = 'RebatePer';
        }
        field(81; RebateRefNbr; Text[10])
        {
            Caption = 'RebateRefNbr';
        }
        field(82; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(83; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(84; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(85; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(86; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(87; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(88; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(89; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(90; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(91; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(92; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(93; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(94; Sample; Integer)
        {
            Caption = 'Sample';
        }
        field(95; Service; Integer)
        {
            Caption = 'Service';
        }
        field(96; ShipperID; Text[15])
        {
            Caption = 'ShipperID';
        }
        field(97; ShipWght; Decimal)
        {
            Caption = 'ShipWght';
        }
        field(98; SiteID; Text[10])
        {
            Caption = 'SiteID';
        }
        field(99; SlsAcct; Text[10])
        {
            Caption = 'SlsAcct';
        }
        field(100; SlsperID; Text[10])
        {
            Caption = 'SlsperID';
        }
        field(101; SlsPrice; Decimal)
        {
            Caption = 'SlsPrice';
        }
        field(102; SlsPriceID; Text[15])
        {
            Caption = 'SlsPriceID';
        }
        field(103; SlsSub; Text[24])
        {
            Caption = 'SlsSub';
        }
        field(104; SplitLots; Integer)
        {
            Caption = 'SplitLots';
        }
        field(105; Status; Text[1])
        {
            Caption = 'Status';
        }
        field(106; TaskID; Text[32])
        {
            Caption = 'TaskID';
        }
        field(107; Taxable; Integer)
        {
            Caption = 'Taxable';
        }
        field(108; TaxAmt00; Decimal)
        {
            Caption = 'TaxAmt00';
        }
        field(109; TaxAmt01; Decimal)
        {
            Caption = 'TaxAmt01';
        }
        field(110; TaxAmt02; Decimal)
        {
            Caption = 'TaxAmt02';
        }
        field(111; TaxAmt03; Decimal)
        {
            Caption = 'TaxAmt03';
        }
        field(112; TaxCat; Text[10])
        {
            Caption = 'TaxCat';
        }
        field(113; TaxID00; Text[10])
        {
            Caption = 'TaxID00';
        }
        field(114; TaxID01; Text[10])
        {
            Caption = 'TaxID01';
        }
        field(115; TaxID02; Text[10])
        {
            Caption = 'TaxID02';
        }
        field(116; TaxID03; Text[10])
        {
            Caption = 'TaxID03';
        }
        field(117; TaxIDDflt; Text[10])
        {
            Caption = 'TaxIDDflt';
        }
        field(118; TotCommCost; Decimal)
        {
            Caption = 'TotCommCost';
        }
        field(119; TotCost; Decimal)
        {
            Caption = 'TotCost';
        }
        field(120; TotInvc; Decimal)
        {
            Caption = 'TotInvc';
        }
        field(121; TotMerch; Decimal)
        {
            Caption = 'TotMerch';
        }
        field(122; TxblAmt00; Decimal)
        {
            Caption = 'TxblAmt00';
        }
        field(123; TxblAmt01; Decimal)
        {
            Caption = 'TxblAmt01';
        }
        field(124; TxblAmt02; Decimal)
        {
            Caption = 'TxblAmt02';
        }
        field(125; TxblAmt03; Decimal)
        {
            Caption = 'TxblAmt03';
        }
        field(126; UnitDesc; Text[6])
        {
            Caption = 'UnitDesc';
        }
        field(127; UnitMultDiv; Text[1])
        {
            Caption = 'UnitMultDiv';
        }
        field(128; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(129; User10; DateTime)
        {
            Caption = 'User10';
        }
        field(130; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(131; User3; Text[30])
        {
            Caption = 'User3';
        }
        field(132; User4; Text[30])
        {
            Caption = 'User4';
        }
        field(133; User5; Decimal)
        {
            Caption = 'User5';
        }
        field(134; User6; Decimal)
        {
            Caption = 'User6';
        }
        field(135; User7; Text[10])
        {
            Caption = 'User7';
        }
        field(136; User8; Text[10])
        {
            Caption = 'User8';
        }
        field(137; User9; DateTime)
        {
            Caption = 'User9';
        }
    }

    keys
    {
        key(PK; CpnyID, ShipperID, LineRef)
        {
            Clustered = true;
        }
    }
}