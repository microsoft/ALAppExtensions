// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

table 42814 "SL Hist. SOLine"
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
        field(3; AutoPO; Integer)
        {
            Caption = 'AutoPO';
        }
        field(4; AutoPOVendID; Text[15])
        {
            Caption = 'AutoPOVendID';
        }
        field(5; BlktOrdLineRef; Text[5])
        {
            Caption = 'BlktOrdLineRef';
        }
        field(6; BlktOrdQty; Decimal)
        {
            Caption = 'BlktOrdQty';
        }
        field(7; BMICost; Decimal)
        {
            Caption = 'BMICost';
        }
        field(8; BMICuryID; Text[4])
        {
            Caption = 'BMICuryID';
        }
        field(9; BMIEffDate; DateTime)
        {
            Caption = 'BMIEffDate';
        }
        field(10; BMIExtPriceInvc; Decimal)
        {
            Caption = 'BMIExtPriceInvc';
        }
        field(11; BMIMultDiv; Text[1])
        {
            Caption = 'BMIMultDiv';
        }
        field(12; BMIRate; Decimal)
        {
            Caption = 'BMIRate';
        }
        field(13; BMIRtTp; Text[6])
        {
            Caption = 'BMIRtTp';
        }
        field(14; BMISlsPrice; Decimal)
        {
            Caption = 'BMISlsPrice';
        }
        field(15; BoundToWO; Integer)
        {
            Caption = 'BoundToWO';
        }
        field(16; CancelDate; DateTime)
        {
            Caption = 'CancelDate';
        }
        field(17; ChainDisc; Text[15])
        {
            Caption = 'ChainDisc';
        }
        field(18; CmmnPct; Decimal)
        {
            Caption = 'CmmnPct';
        }
        field(19; CnvFact; Decimal)
        {
            Caption = 'CnvFact';
        }
        field(20; COGSAcct; Text[10])
        {
            Caption = 'COGSAcct';
        }
        field(21; COGSSub; Text[24])
        {
            Caption = 'COGSSub';
        }
        field(22; CommCost; Decimal)
        {
            Caption = 'CommCost';
        }
        field(23; Cost; Decimal)
        {
            Caption = 'Cost';
        }
        field(24; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(25; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(26; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(27; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(28; CuryCommCost; Decimal)
        {
            Caption = 'CuryCommCost';
        }
        field(29; CuryCost; Decimal)
        {
            Caption = 'CuryCost';
        }
        field(30; CuryListPrice; Decimal)
        {
            Caption = 'CuryListPrice';
        }
        field(31; CurySlsPrice; Decimal)
        {
            Caption = 'CurySlsPrice';
        }
        field(32; CurySlsPriceOrig; Decimal)
        {
            Caption = 'CurySlsPriceOrig';
        }
        field(33; CuryTotCommCost; Decimal)
        {
            Caption = 'CuryTotCommCost';
        }
        field(34; CuryTotCost; Decimal)
        {
            Caption = 'CuryTotCost';
        }
        field(35; CuryTotOrd; Decimal)
        {
            Caption = 'CuryTotOrd';
        }
        field(36; Descr; Text[60])
        {
            Caption = 'Descr';
        }
        field(37; DescrLang; Text[30])
        {
            Caption = 'DescrLang';
        }
        field(38; DiscAcct; Text[10])
        {
            Caption = 'DiscAcct';
        }
        field(39; DiscPct; Decimal)
        {
            Caption = 'DiscPct';
        }
        field(40; DiscPrcType; Text[1])
        {
            Caption = 'DiscPrcType';
        }
        field(41; DiscSub; Text[24])
        {
            Caption = 'DiscSub';
        }
        field(42; Disp; Text[3])
        {
            Caption = 'Disp';
        }
        field(43; DropShip; Integer)
        {
            Caption = 'DropShip';
        }
        field(44; InclForecastUsageClc; Integer)
        {
            Caption = 'InclForecastUsageClc';
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
        field(50; InvtID; Text[30])
        {
            Caption = 'InvtID';
        }
        field(51; IRDemand; Integer)
        {
            Caption = 'IRDemand';
        }
        field(52; IRInvtID; Text[30])
        {
            Caption = 'IRInvtID';
        }
        field(53; IRProcessed; Integer)
        {
            Caption = 'IRProcessed';
        }
        field(54; IRSiteID; Text[10])
        {
            Caption = 'IRSiteID';
        }
        field(55; ItemGLClassID; Text[4])
        {
            Caption = 'ItemGLClassID';
        }
        field(56; KitComponent; Integer)
        {
            Caption = 'KitComponent';
        }
        field(57; LineNbr; Integer)
        {
            Caption = 'LineNbr';
        }
        field(58; LineRef; Text[5])
        {
            Caption = 'LineRef';
        }
        field(59; ListPrice; Decimal)
        {
            Caption = 'ListPrice';
        }
        field(60; LotSerialReq; Integer)
        {
            Caption = 'LotSerialReq';
        }
        field(61; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(62; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(63; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(64; ManualCost; Integer)
        {
            Caption = 'ManualCost';
        }
        field(65; ManualPrice; Integer)
        {
            Caption = 'ManualPrice';
        }
        field(66; NoteId; Integer)
        {
            Caption = 'NoteId';
        }
        field(67; OrdNbr; Text[15])
        {
            Caption = 'OrdNbr';
        }
        field(68; OrigINBatNbr; Text[10])
        {
            Caption = 'OrigINBatNbr';
        }
        field(69; OrigInvcNbr; Text[15])
        {
            Caption = 'OrigInvcNbr';
        }
        field(70; OrigInvtID; Text[30])
        {
            Caption = 'OrigInvtID';
        }
        field(71; OrigShipperCnvFact; Decimal)
        {
            Caption = 'OrigShipperCnvFact';
        }
        field(72; OrigShipperID; Text[15])
        {
            Caption = 'OrigShipperID';
        }
        field(73; OrigShipperLineQty; Decimal)
        {
            Caption = 'OrigShipperLineQty';
        }
        field(74; OrigShipperLineRef; Text[5])
        {
            Caption = 'OrigShipperLineRef';
        }
        field(75; OrigShipperUnitDesc; Text[6])
        {
            Caption = 'OrigShipperUnitDesc';
        }
        field(76; OrigShipperMultDiv; Text[1])
        {
            Caption = 'OrigShipperMultDiv';
        }
        field(77; PC_Status; Text[1])
        {
            Caption = 'PC_Status';
        }
        field(78; ProjectID; Text[16])
        {
            Caption = 'ProjectID';
        }
        field(79; PromDate; DateTime)
        {
            Caption = 'PromDate';
        }
        field(80; QtyBO; Decimal)
        {
            Caption = 'QtyBO';
        }
        field(81; QtyCloseShip; Decimal)
        {
            Caption = 'QtyCloseShip';
        }
        field(82; QtyFuture; Decimal)
        {
            Caption = 'QtyFuture';
        }
        field(83; QtyOpenShip; Decimal)
        {
            Caption = 'QtyOpenShip';
        }
        field(84; QtyOrd; Decimal)
        {
            Caption = 'QtyOrd';
        }
        field(85; QtyShip; Decimal)
        {
            Caption = 'QtyShip';
        }
        field(86; QtyToInvc; Decimal)
        {
            Caption = 'QtyToInvc';
        }
        field(87; ReasonCd; Text[6])
        {
            Caption = 'ReasonCd';
        }
        field(88; RebateID; Text[10])
        {
            Caption = 'RebateID';
        }
        field(89; ReqDate; DateTime)
        {
            Caption = 'ReqDate';
        }
        field(90; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(91; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(92; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(93; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(94; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(95; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(96; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(97; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(98; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(99; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(100; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(101; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(102; SalesPriceID; Text[15])
        {
            Caption = 'SalesPriceID';
        }
        field(103; Sample; Integer)
        {
            Caption = 'Sample';
        }
        field(104; SchedCntr; Integer)
        {
            Caption = 'SchedCntr';
        }
        field(105; Service; Integer)
        {
            Caption = 'Service';
        }
        field(106; ShipWght; Decimal)
        {
            Caption = 'ShipWght';
        }
        field(107; SiteID; Text[10])
        {
            Caption = 'SiteID';
        }
        field(108; SlsAcct; Text[10])
        {
            Caption = 'SlsAcct';
        }
        field(109; SlsperID; Text[10])
        {
            Caption = 'SlsperID';
        }
        field(110; SlsPrice; Decimal)
        {
            Caption = 'SlsPrice';
        }
        field(111; SlsPriceID; Text[15])
        {
            Caption = 'SlsPriceID';
        }
        field(112; SlsPriceOrig; Decimal)
        {
            Caption = 'SlsPriceOrig';
        }
        field(113; SlsSub; Text[24])
        {
            Caption = 'SlsSub';
        }
        field(114; SplitLots; Integer)
        {
            Caption = 'SplitLots';
        }
        field(115; Status; Text[1])
        {
            Caption = 'Status';
        }
        field(116; TaskID; Text[32])
        {
            Caption = 'TaskID';
        }
        field(117; Taxable; Integer)
        {
            Caption = 'Taxable';
        }
        field(118; TaxCat; Text[10])
        {
            Caption = 'TaxCat';
        }
        field(119; TotCommCost; Decimal)
        {
            Caption = 'TotCommCost';
        }
        field(120; TotCost; Decimal)
        {
            Caption = 'TotCost';
        }
        field(121; TotOrd; Decimal)
        {
            Caption = 'TotOrd';
        }
        field(122; TotShipWght; Decimal)
        {
            Caption = 'TotShipWght';
        }
        field(123; UnitDesc; Text[6])
        {
            Caption = 'UnitDesc';
        }
        field(124; UnitMultDiv; Text[1])
        {
            Caption = 'UnitMultDiv';
        }
        field(125; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(126; User10; DateTime)
        {
            Caption = 'User10';
        }
        field(127; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(128; User3; Text[30])
        {
            Caption = 'User3';
        }
        field(129; User4; Text[30])
        {
            Caption = 'User4';
        }
        field(130; User5; Decimal)
        {
            Caption = 'User5';
        }
        field(131; User6; Decimal)
        {
            Caption = 'User6';
        }
        field(132; User7; Text[10])
        {
            Caption = 'User7';
        }
        field(133; User8; Text[10])
        {
            Caption = 'User8';
        }
        field(134; User9; DateTime)
        {
            Caption = 'User9';
        }
    }

    keys
    {
        key(PK; CpnyID, OrdNbr, LineRef)
        {
            Clustered = true;
        }
    }
}