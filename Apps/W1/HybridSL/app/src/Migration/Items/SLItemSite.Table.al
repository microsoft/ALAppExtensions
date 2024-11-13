// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47041 "SL ItemSite"
{
    Access = Internal;
    Caption = 'SL ItemSite';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ABCCode; Text[2])
        {
            Caption = 'ABCCode';
        }
        field(2; AllocQty; Decimal)
        {
            Caption = 'AllocQty';
        }
        field(3; AutoPODropShip; Integer)
        {
            Caption = 'AutoPODropShip';
        }
        field(4; AutoPOPolicy; Text[2])
        {
            Caption = 'AutoPOPolicy';
        }
        field(5; AvgCost; Decimal)
        {
            Caption = 'AvgCost';
        }
        field(6; BMIAvgCost; Decimal)
        {
            Caption = 'BMIAvgCost';
        }
        field(7; BMIDirStdCst; Decimal)
        {
            Caption = 'BMIDirStdCst';
        }
        field(8; BMIFOvhStdCst; Decimal)
        {
            Caption = 'BMIFOvhStdCst';
        }
        field(9; BMILastCost; Decimal)
        {
            Caption = 'BMILastCost';
        }
        field(10; BMIPDirStdCst; Decimal)
        {
            Caption = 'BMIPDirStdCst';
        }
        field(11; BMIPFOvhStdCst; Decimal)
        {
            Caption = 'BMIPFOvhStdCst';
        }
        field(12; BMIPStdCst; Decimal)
        {
            Caption = 'BMIPStdCst';
        }
        field(13; BMIPVOvhStdCst; Decimal)
        {
            Caption = 'BMIPVOvhStdCst';
        }
        field(14; BMIStdCost; Decimal)
        {
            Caption = 'BMIStdCost';
        }
        field(15; BMITotCost; Decimal)
        {
            Caption = 'BMITotCost';
        }
        field(16; BMIVOvhStdCst; Decimal)
        {
            Caption = 'BMIVOvhStdCst';
        }
        field(17; Buyer; Text[10])
        {
            Caption = 'Buyer';
        }
        field(18; COGSAcct; Text[10])
        {
            Caption = 'COGSAcct';
        }
        field(19; COGSSub; Text[24])
        {
            Caption = 'COGSSub';
        }
        field(20; CountStatus; Text[1])
        {
            Caption = 'CountStatus';
        }
        field(21; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(22; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(23; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(24; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(25; CycleID; Text[10])
        {
            Caption = 'CycleID';
        }
        field(26; DfltPickBin; Text[10])
        {
            Caption = 'DfltPickBin';
        }
        field(27; DfltPOUnit; Text[6])
        {
            Caption = 'DfltPOUnit';
        }
        field(28; DfltPutAwayBin; Text[10])
        {
            Caption = 'DfltPutAwayBin';
        }
        field(29; DfltRepairBin; Text[10])
        {
            Caption = 'DfltRepairBin';
        }
        field(30; DfltSOUnit; Text[6])
        {
            Caption = 'DfltSOUnit';
        }
        field(31; DfltVendorBin; Text[10])
        {
            Caption = 'DfltVendorBin';
        }
        field(32; DfltWhseLoc; Text[10])
        {
            Caption = 'DfltWhseLoc';
        }
        field(33; DirStdCst; Decimal)
        {
            Caption = 'DirStdCst';
        }
        field(34; EOQ; Decimal)
        {
            Caption = 'EOQ';
        }
        field(35; FOvhStdCst; Decimal)
        {
            Caption = 'FOvhStdCst';
        }
        field(36; InvtAcct; Text[10])
        {
            Caption = 'InvtAcct';
        }
        field(37; InvtID; Text[30])
        {
            Caption = 'InvtID';
        }
        field(38; InvtSub; Text[24])
        {
            Caption = 'InvtSub';
        }
        field(39; IRCalcDailyUsage; Decimal)
        {
            Caption = 'IRCalcDailyUsage';
        }
        field(40; IRCalcEOQ; Decimal)
        {
            Caption = 'IRCalcEOQ';
        }
        field(41; IRCalcLeadTime; Decimal)
        {
            Caption = 'IRCalcLeadTime';
        }
        field(42; IRCalcLinePt; Decimal)
        {
            Caption = 'IRCalcLinePt';
        }
        field(43; IRCalcRCycDays; Integer)
        {
            Caption = 'IRCalcRCycDays';
        }
        field(44; IRCalcReOrdPt; Decimal)
        {
            Caption = 'IRCalcReOrdPt';
        }
        field(45; IRCalcReOrdQty; Decimal)
        {
            Caption = 'IRCalcReOrdQty';
        }
        field(46; IRCalcSafetyStk; Decimal)
        {
            Caption = 'IRCalcSafetyStk';
        }
        field(47; IRDailyUsage; Decimal)
        {
            Caption = 'IRDailyUsage';
        }
        field(48; IRDaysSupply; Decimal)
        {
            Caption = 'IRDaysSupply';
        }
        field(49; IRDemandID; Text[10])
        {
            Caption = 'IRDemandID';
        }
        field(50; IRFutureDate; DateTime)
        {
            Caption = 'IRFutureDate';
        }
        field(51; IRFuturePolicy; Text[1])
        {
            Caption = 'IRFuturePolicy';
        }
        field(52; IRLeadTimeID; Text[10])
        {
            Caption = 'IRLeadTimeID';
        }
        field(53; IRLinePt; Decimal)
        {
            Caption = 'IRLinePt';
        }
        field(54; IRManualDailyUsage; Integer)
        {
            Caption = 'IRManualDailyUsage';
        }
        field(55; IRManualEOQ; Integer)
        {
            Caption = 'IRManualEOQ';
        }
        field(56; IRManualLeadTime; Integer)
        {
            Caption = 'IRManualLeadTime';
        }
        field(57; IRManualLinePt; Integer)
        {
            Caption = 'IRManualLinePt';
        }
        field(58; IRManualRCycDays; Integer)
        {
            Caption = 'IRManualRCycDays';
        }
        field(59; IRManualReOrdPt; Integer)
        {
            Caption = 'IRManualReOrdPt';
        }
        field(60; IRManualReOrdQty; Integer)
        {
            Caption = 'IRManualReOrdQty';
        }
        field(61; IRManualSafetyStk; Integer)
        {
            Caption = 'IRManualSafetyStk';
        }
        field(62; IRMaxDailyUsage; Decimal)
        {
            Caption = 'IRMaxDailyUsage';
        }
        field(63; IRMaxEOQ; Decimal)
        {
            Caption = 'IRMaxEOQ';
        }
        field(64; IRMaxLeadTime; Decimal)
        {
            Caption = 'IRMaxLeadTime';
        }
        field(65; IRMaxLinePt; Decimal)
        {
            Caption = 'IRMaxLinePt';
        }
        field(66; IRMaxRCycDays; Decimal)
        {
            Caption = 'IRMaxRCycDays';
        }
        field(67; IRMaxReOrdPt; Decimal)
        {
            Caption = 'IRMaxReOrdPt';
        }
        field(68; IRMaxReOrdQty; Decimal)
        {
            Caption = 'IRMaxReOrdQty';
        }
        field(69; IRMaxSafetyStk; Decimal)
        {
            Caption = 'IRMaxSafetyStk';
        }
        field(70; IRMinDailyUsage; Decimal)
        {
            Caption = 'IRMinDailyUsage';
        }
        field(71; IRMinEOQ; Decimal)
        {
            Caption = 'IRMinEOQ';
        }
        field(72; IRMinLeadTime; Decimal)
        {
            Caption = 'IRMinLeadTime';
        }
        field(73; IRMinLinePt; Decimal)
        {
            Caption = 'IRMinLinePt';
        }
        field(74; IRMinOnHand; Decimal)
        {
            Caption = 'IRMinOnHand';
        }
        field(75; IRMinRCycDays; Decimal)
        {
            Caption = 'IRMinRCycDays';
        }
        field(76; IRMinReOrdPt; Decimal)
        {
            Caption = 'IRMinReOrdPt';
        }
        field(77; IRMinReOrdQty; Decimal)
        {
            Caption = 'IRMinReOrdQty';
        }
        field(78; IRMinSafetyStk; Decimal)
        {
            Caption = 'IRMinSafetyStk';
        }
        field(79; IRModelInvtID; Text[30])
        {
            Caption = 'IRModelInvtID';
        }
        field(80; IRRCycDays; Integer)
        {
            Caption = 'IRRCycDays';
        }
        field(81; IRSeasonEndDay; Integer)
        {
            Caption = 'IRSeasonEndDay';
        }
        field(82; IRSeasonEndMon; Integer)
        {
            Caption = 'IRSeasonEndMon';
        }
        field(83; IRSeasonStrtDay; Integer)
        {
            Caption = 'IRSeasonStrtDay';
        }
        field(84; IRSeasonStrtMon; Integer)
        {
            Caption = 'IRSeasonStrtMon';
        }
        field(85; IRServiceLevel; Decimal)
        {
            Caption = 'IRServiceLevel';
        }
        field(86; IRSftyStkDays; Decimal)
        {
            Caption = 'IRSftyStkDays';
        }
        field(87; IRSftyStkPct; Decimal)
        {
            Caption = 'IRSftyStkPct';
        }
        field(88; IRSftyStkPolicy; Text[1])
        {
            Caption = 'IRSftyStkPolicy';
        }
        field(89; IRSourceCode; Text[1])
        {
            Caption = 'IRSourceCode';
        }
        field(90; IRTargetOrdMethod; Text[1])
        {
            Caption = 'IRTargetOrdMethod';
        }
        field(91; IRTargetOrdReq; Decimal)
        {
            Caption = 'IRTargetOrdReq';
        }
        field(92; IRTransferSiteID; Text[10])
        {
            Caption = 'IRTransferSiteID';
        }
        field(93; LastBookQty; Decimal)
        {
            Caption = 'LastBookQty';
        }
        field(94; LastCost; Decimal)
        {
            Caption = 'LastCost';
        }
        field(95; LastCountDate; DateTime)
        {
            Caption = 'LastCountDate';
        }
        field(96; LastPurchaseDate; DateTime)
        {
            Caption = 'LastPurchaseDate';
        }
        field(97; LastPurchasePrice; Decimal)
        {
            Caption = 'LastPurchasePrice';
        }
        field(98; LastStdCost; Decimal)
        {
            Caption = 'LastStdCost';
        }
        field(99; LastVarAmt; Decimal)
        {
            Caption = 'LastVarAmt';
        }
        field(100; LastVarPct; Decimal)
        {
            Caption = 'LastVarPct';
        }
        field(101; LastVarQty; Decimal)
        {
            Caption = 'LastVarQty';
        }
        field(102; LastVendor; Text[15])
        {
            Caption = 'LastVendor';
        }
        field(103; LeadTime; Decimal)
        {
            Caption = 'LeadTime';
        }
        field(104; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(105; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(106; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(107; MaxOnHand; Decimal)
        {
            Caption = 'MaxOnHand';
        }
        field(108; MfgClassID; Text[10])
        {
            Caption = 'MfgClassID';
        }
        field(109; MfgLeadTime; Decimal)
        {
            Caption = 'MfgLeadTime';
        }
        field(110; MoveClass; Text[10])
        {
            Caption = 'MoveClass';
        }
        field(111; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(112; PDirStdCst; Decimal)
        {
            Caption = 'PDirStdCst';
        }
        field(113; PFOvhStdCst; Decimal)
        {
            Caption = 'PFOvhStdCst';
        }
        field(114; PrimVendID; Text[15])
        {
            Caption = 'PrimVendID';
        }
        field(115; ProdMgrID; Text[10])
        {
            Caption = 'ProdMgrID';
        }
        field(116; PrjINQtyAlloc; Decimal)
        {
            Caption = 'PrjINQtyAlloc';
        }
        field(117; PrjINQtyAllocIN; Decimal)
        {
            Caption = 'PrjINQtyAllocIN';
        }
        field(118; PrjINQtyAllocPORet; Decimal)
        {
            Caption = 'PrjINQtyAllocPORet';
        }
        field(119; PrjINQtyAllocSO; Decimal)
        {
            Caption = 'PrjINQtyAllocSO';
        }
        field(120; PrjINQtyCustOrd; Decimal)
        {
            Caption = 'PrjINQtyCustOrd';
        }
        field(121; PrjINQtyShipNotInv; Decimal)
        {
            Caption = 'PrjINQtyShipNotInv';
        }
        field(122; PStdCostDate; DateTime)
        {
            Caption = 'PStdCostDate';
        }
        field(123; PStdCst; Decimal)
        {
            Caption = 'PStdCst';
        }
        field(124; PVOvhStdCst; Decimal)
        {
            Caption = 'PVOvhStdCst';
        }
        field(125; QtyAlloc; Decimal)
        {
            Caption = 'QtyAlloc';
        }
        field(126; QtyAllocBM; Decimal)
        {
            Caption = 'QtyAllocBM';
        }
        field(127; QtyAllocIN; Decimal)
        {
            Caption = 'QtyAllocIN';
        }
        field(128; QtyAllocOther; Decimal)
        {
            Caption = 'QtyAllocOther';
        }
        field(129; QtyAllocPORet; Decimal)
        {
            Caption = 'QtyAllocPORet';
        }
        field(130; QtyAllocProjIN; Decimal)
        {
            Caption = 'QtyAllocProjIN';
        }
        field(131; QtyAllocSD; Decimal)
        {
            Caption = 'QtyAllocSD';
        }
        field(132; QtyAllocSO; Decimal)
        {
            Caption = 'QtyAllocSO';
        }
        field(133; QtyAvail; Decimal)
        {
            Caption = 'QtyAvail';
        }
        field(134; QtyCustOrd; Decimal)
        {
            Caption = 'QtyCustOrd';
        }
        field(135; QtyInTransit; Decimal)
        {
            Caption = 'QtyInTransit';
        }
        field(136; QtyNotAvail; Decimal)
        {
            Caption = 'QtyNotAvail';
        }
        field(137; QtyOnBO; Decimal)
        {
            Caption = 'QtyOnBO';
        }
        field(138; QtyOnDP; Decimal)
        {
            Caption = 'QtyOnDP';
        }
        field(139; QtyOnHand; Decimal)
        {
            Caption = 'QtyOnHand';
        }
        field(140; QtyOnKitAssyOrders; Decimal)
        {
            Caption = 'QtyOnKitAssyOrders';
        }
        field(141; QtyOnPO; Decimal)
        {
            Caption = 'QtyOnPO';
        }
        field(142; QtyOnTransferOrders; Decimal)
        {
            Caption = 'QtyOnTransferOrders';
        }
        field(143; QtyShipNotInv; Decimal)
        {
            Caption = 'QtyShipNotInv';
        }
        field(144; QtyWOFirmDemand; Decimal)
        {
            Caption = 'QtyWOFirmDemand';
        }
        field(145; QtyWOFirmSupply; Decimal)
        {
            Caption = 'QtyWOFirmSupply';
        }
        field(146; QtyWORlsedDemand; Decimal)
        {
            Caption = 'QtyWORlsedDemand';
        }
        field(147; QtyWORlsedSupply; Decimal)
        {
            Caption = 'QtyWORlsedSupply';
        }
        field(148; ReordInterval; Integer)
        {
            Caption = 'ReordInterval';
        }
        field(149; ReordPt; Decimal)
        {
            Caption = 'ReordPt';
        }
        field(150; ReordPtCalc; Decimal)
        {
            Caption = 'ReordPtCalc';
        }
        field(151; ReordQty; Decimal)
        {
            Caption = 'ReordQty';
        }
        field(152; ReordQtyCalc; Decimal)
        {
            Caption = 'ReordQtyCalc';
        }
        field(153; ReplMthd; Text[1])
        {
            Caption = 'ReplMthd';
        }
        field(154; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(155; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(156; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(157; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(158; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(159; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(160; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(161; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(162; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(163; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(164; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(165; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(166; SafetyStk; Decimal)
        {
            Caption = 'SafetyStk';
        }
        field(167; SafetyStkCalc; Decimal)
        {
            Caption = 'SafetyStkCalc';
        }
        field(168; SalesAcct; Text[10])
        {
            Caption = 'SalesAcct';
        }
        field(169; SalesSub; Text[24])
        {
            Caption = 'SalesSub';
        }
        field(170; SecondVendID; Text[15])
        {
            Caption = 'SecondVendID';
        }
        field(171; Selected; Integer)
        {
            Caption = 'Selected';
        }
        field(172; ShipNotInvAcct; Text[10])
        {
            Caption = 'ShipNotInvAcct';
        }
        field(173; ShipNotInvSub; Text[24])
        {
            Caption = 'ShipNotInvSub';
        }
        field(174; SiteID; Text[10])
        {
            Caption = 'SiteID';
        }
        field(175; StdCost; Decimal)
        {
            Caption = 'StdCost';
        }
        field(176; StdCostDate; DateTime)
        {
            Caption = 'StdCostDate';
        }
        field(177; StkItem; Integer)
        {
            Caption = 'StkItem';
        }
        field(178; TotCost; Decimal)
        {
            Caption = 'TotCost';
        }
        field(179; Turns; Decimal)
        {
            Caption = 'Turns';
        }
        field(180; UsageRate; Decimal)
        {
            Caption = 'UsageRate';
        }
        field(181; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(182; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(183; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(184; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(185; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(186; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(187; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(188; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(189; VOvhStdCst; Decimal)
        {
            Caption = 'VOvhStdCst';
        }
        field(190; YTDUsage; Decimal)
        {
            Caption = 'YTDUsage';
        }
    }

    keys
    {
        key(Key1; InvtID, SiteID)
        {
            Clustered = true;
        }
    }
}