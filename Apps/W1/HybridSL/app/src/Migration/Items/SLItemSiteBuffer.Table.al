// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47086 "SL ItemSite Buffer"
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
            AutoFormatType = 0;
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
            AutoFormatType = 0;
        }
        field(6; BMIAvgCost; Decimal)
        {
            Caption = 'BMIAvgCost';
            AutoFormatType = 0;
        }
        field(7; BMIDirStdCst; Decimal)
        {
            Caption = 'BMIDirStdCst';
            AutoFormatType = 0;
        }
        field(8; BMIFOvhStdCst; Decimal)
        {
            Caption = 'BMIFOvhStdCst';
            AutoFormatType = 0;
        }
        field(9; BMILastCost; Decimal)
        {
            Caption = 'BMILastCost';
            AutoFormatType = 0;
        }
        field(10; BMIPDirStdCst; Decimal)
        {
            Caption = 'BMIPDirStdCst';
            AutoFormatType = 0;
        }
        field(11; BMIPFOvhStdCst; Decimal)
        {
            Caption = 'BMIPFOvhStdCst';
            AutoFormatType = 0;
        }
        field(12; BMIPStdCst; Decimal)
        {
            Caption = 'BMIPStdCst';
            AutoFormatType = 0;
        }
        field(13; BMIPVOvhStdCst; Decimal)
        {
            Caption = 'BMIPVOvhStdCst';
            AutoFormatType = 0;
        }
        field(14; BMIStdCost; Decimal)
        {
            Caption = 'BMIStdCost';
            AutoFormatType = 0;
        }
        field(15; BMITotCost; Decimal)
        {
            Caption = 'BMITotCost';
            AutoFormatType = 0;
        }
        field(16; BMIVOvhStdCst; Decimal)
        {
            Caption = 'BMIVOvhStdCst';
            AutoFormatType = 0;
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
            AutoFormatType = 0;
        }
        field(34; EOQ; Decimal)
        {
            Caption = 'EOQ';
            AutoFormatType = 0;
        }
        field(35; FOvhStdCst; Decimal)
        {
            Caption = 'FOvhStdCst';
            AutoFormatType = 0;
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
            AutoFormatType = 0;
        }
        field(40; IRCalcEOQ; Decimal)
        {
            Caption = 'IRCalcEOQ';
            AutoFormatType = 0;
        }
        field(41; IRCalcLeadTime; Decimal)
        {
            Caption = 'IRCalcLeadTime';
            AutoFormatType = 0;
        }
        field(42; IRCalcLinePt; Decimal)
        {
            Caption = 'IRCalcLinePt';
            AutoFormatType = 0;
        }
        field(43; IRCalcRCycDays; Integer)
        {
            Caption = 'IRCalcRCycDays';
        }
        field(44; IRCalcReOrdPt; Decimal)
        {
            Caption = 'IRCalcReOrdPt';
            AutoFormatType = 0;
        }
        field(45; IRCalcReOrdQty; Decimal)
        {
            Caption = 'IRCalcReOrdQty';
            AutoFormatType = 0;
        }
        field(46; IRCalcSafetyStk; Decimal)
        {
            Caption = 'IRCalcSafetyStk';
            AutoFormatType = 0;
        }
        field(47; IRDailyUsage; Decimal)
        {
            Caption = 'IRDailyUsage';
            AutoFormatType = 0;
        }
        field(48; IRDaysSupply; Decimal)
        {
            Caption = 'IRDaysSupply';
            AutoFormatType = 0;
        }
        field(49; IRDemandID; Text[10])
        {
            Caption = 'IRDemandID';
        }
        field(50; IRFutureDate; Date)
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
            AutoFormatType = 0;
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
            AutoFormatType = 0;
        }
        field(63; IRMaxEOQ; Decimal)
        {
            Caption = 'IRMaxEOQ';
            AutoFormatType = 0;
        }
        field(64; IRMaxLeadTime; Decimal)
        {
            Caption = 'IRMaxLeadTime';
            AutoFormatType = 0;
        }
        field(65; IRMaxLinePt; Decimal)
        {
            Caption = 'IRMaxLinePt';
            AutoFormatType = 0;
        }
        field(66; IRMaxRCycDays; Decimal)
        {
            Caption = 'IRMaxRCycDays';
            AutoFormatType = 0;
        }
        field(67; IRMaxReOrdPt; Decimal)
        {
            Caption = 'IRMaxReOrdPt';
            AutoFormatType = 0;
        }
        field(68; IRMaxReOrdQty; Decimal)
        {
            Caption = 'IRMaxReOrdQty';
            AutoFormatType = 0;
        }
        field(69; IRMaxSafetyStk; Decimal)
        {
            Caption = 'IRMaxSafetyStk';
            AutoFormatType = 0;
        }
        field(70; IRMinDailyUsage; Decimal)
        {
            Caption = 'IRMinDailyUsage';
            AutoFormatType = 0;
        }
        field(71; IRMinEOQ; Decimal)
        {
            Caption = 'IRMinEOQ';
            AutoFormatType = 0;
        }
        field(72; IRMinLeadTime; Decimal)
        {
            Caption = 'IRMinLeadTime';
            AutoFormatType = 0;
        }
        field(73; IRMinLinePt; Decimal)
        {
            Caption = 'IRMinLinePt';
            AutoFormatType = 0;
        }
        field(74; IRMinOnHand; Decimal)
        {
            Caption = 'IRMinOnHand';
            AutoFormatType = 0;
        }
        field(75; IRMinRCycDays; Decimal)
        {
            Caption = 'IRMinRCycDays';
            AutoFormatType = 0;
        }
        field(76; IRMinReOrdPt; Decimal)
        {
            Caption = 'IRMinReOrdPt';
            AutoFormatType = 0;
        }
        field(77; IRMinReOrdQty; Decimal)
        {
            Caption = 'IRMinReOrdQty';
            AutoFormatType = 0;
        }
        field(78; IRMinSafetyStk; Decimal)
        {
            Caption = 'IRMinSafetyStk';
            AutoFormatType = 0;
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
            AutoFormatType = 0;
        }
        field(86; IRSftyStkDays; Decimal)
        {
            Caption = 'IRSftyStkDays';
            AutoFormatType = 0;
        }
        field(87; IRSftyStkPct; Decimal)
        {
            Caption = 'IRSftyStkPct';
            AutoFormatType = 0;
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
            AutoFormatType = 0;
        }
        field(92; IRTransferSiteID; Text[10])
        {
            Caption = 'IRTransferSiteID';
        }
        field(93; LastBookQty; Decimal)
        {
            Caption = 'LastBookQty';
            AutoFormatType = 0;
        }
        field(94; LastCost; Decimal)
        {
            Caption = 'LastCost';
            AutoFormatType = 0;
        }
        field(95; LastCountDate; Date)
        {
            Caption = 'LastCountDate';
        }
        field(96; LastPurchaseDate; Date)
        {
            Caption = 'LastPurchaseDate';
        }
        field(97; LastPurchasePrice; Decimal)
        {
            Caption = 'LastPurchasePrice';
            AutoFormatType = 0;
        }
        field(98; LastStdCost; Decimal)
        {
            Caption = 'LastStdCost';
            AutoFormatType = 0;
        }
        field(99; LastVarAmt; Decimal)
        {
            Caption = 'LastVarAmt';
            AutoFormatType = 0;
        }
        field(100; LastVarPct; Decimal)
        {
            Caption = 'LastVarPct';
            AutoFormatType = 0;
        }
        field(101; LastVarQty; Decimal)
        {
            Caption = 'LastVarQty';
            AutoFormatType = 0;
        }
        field(102; LastVendor; Text[15])
        {
            Caption = 'LastVendor';
        }
        field(103; LeadTime; Decimal)
        {
            Caption = 'LeadTime';
            AutoFormatType = 0;
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
            AutoFormatType = 0;
        }
        field(108; MfgClassID; Text[10])
        {
            Caption = 'MfgClassID';
        }
        field(109; MfgLeadTime; Decimal)
        {
            Caption = 'MfgLeadTime';
            AutoFormatType = 0;
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
            AutoFormatType = 0;
        }
        field(113; PFOvhStdCst; Decimal)
        {
            Caption = 'PFOvhStdCst';
            AutoFormatType = 0;
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
            AutoFormatType = 0;
        }
        field(117; PrjINQtyAllocIN; Decimal)
        {
            Caption = 'PrjINQtyAllocIN';
            AutoFormatType = 0;
        }
        field(118; PrjINQtyAllocPORet; Decimal)
        {
            Caption = 'PrjINQtyAllocPORet';
            AutoFormatType = 0;
        }
        field(119; PrjINQtyAllocSO; Decimal)
        {
            Caption = 'PrjINQtyAllocSO';
            AutoFormatType = 0;
        }
        field(120; PrjINQtyCustOrd; Decimal)
        {
            Caption = 'PrjINQtyCustOrd';
            AutoFormatType = 0;
        }
        field(121; PrjINQtyShipNotInv; Decimal)
        {
            Caption = 'PrjINQtyShipNotInv';
            AutoFormatType = 0;
        }
        field(122; PStdCostDate; Date)
        {
            Caption = 'PStdCostDate';
        }
        field(123; PStdCst; Decimal)
        {
            Caption = 'PStdCst';
            AutoFormatType = 0;
        }
        field(124; PVOvhStdCst; Decimal)
        {
            Caption = 'PVOvhStdCst';
            AutoFormatType = 0;
        }
        field(125; QtyAlloc; Decimal)
        {
            Caption = 'QtyAlloc';
            AutoFormatType = 0;
        }
        field(126; QtyAllocBM; Decimal)
        {
            Caption = 'QtyAllocBM';
            AutoFormatType = 0;
        }
        field(127; QtyAllocIN; Decimal)
        {
            Caption = 'QtyAllocIN';
            AutoFormatType = 0;
        }
        field(128; QtyAllocOther; Decimal)
        {
            Caption = 'QtyAllocOther';
            AutoFormatType = 0;
        }
        field(129; QtyAllocPORet; Decimal)
        {
            Caption = 'QtyAllocPORet';
            AutoFormatType = 0;
        }
        field(130; QtyAllocProjIN; Decimal)
        {
            Caption = 'QtyAllocProjIN';
            AutoFormatType = 0;
        }
        field(131; QtyAllocSD; Decimal)
        {
            Caption = 'QtyAllocSD';
            AutoFormatType = 0;
        }
        field(132; QtyAllocSO; Decimal)
        {
            Caption = 'QtyAllocSO';
            AutoFormatType = 0;
        }
        field(133; QtyAvail; Decimal)
        {
            Caption = 'QtyAvail';
            AutoFormatType = 0;
        }
        field(134; QtyCustOrd; Decimal)
        {
            Caption = 'QtyCustOrd';
            AutoFormatType = 0;
        }
        field(135; QtyInTransit; Decimal)
        {
            Caption = 'QtyInTransit';
            AutoFormatType = 0;
        }
        field(136; QtyNotAvail; Decimal)
        {
            Caption = 'QtyNotAvail';
            AutoFormatType = 0;
        }
        field(137; QtyOnBO; Decimal)
        {
            Caption = 'QtyOnBO';
            AutoFormatType = 0;
        }
        field(138; QtyOnDP; Decimal)
        {
            Caption = 'QtyOnDP';
            AutoFormatType = 0;
        }
        field(139; QtyOnHand; Decimal)
        {
            Caption = 'QtyOnHand';
            AutoFormatType = 0;
        }
        field(140; QtyOnKitAssyOrders; Decimal)
        {
            Caption = 'QtyOnKitAssyOrders';
            AutoFormatType = 0;
        }
        field(141; QtyOnPO; Decimal)
        {
            Caption = 'QtyOnPO';
            AutoFormatType = 0;
        }
        field(142; QtyOnTransferOrders; Decimal)
        {
            Caption = 'QtyOnTransferOrders';
            AutoFormatType = 0;
        }
        field(143; QtyShipNotInv; Decimal)
        {
            Caption = 'QtyShipNotInv';
            AutoFormatType = 0;
        }
        field(144; QtyWOFirmDemand; Decimal)
        {
            Caption = 'QtyWOFirmDemand';
            AutoFormatType = 0;
        }
        field(145; QtyWOFirmSupply; Decimal)
        {
            Caption = 'QtyWOFirmSupply';
            AutoFormatType = 0;
        }
        field(146; QtyWORlsedDemand; Decimal)
        {
            Caption = 'QtyWORlsedDemand';
            AutoFormatType = 0;
        }
        field(147; QtyWORlsedSupply; Decimal)
        {
            Caption = 'QtyWORlsedSupply';
            AutoFormatType = 0;
        }
        field(148; ReordInterval; Integer)
        {
            Caption = 'ReordInterval';
        }
        field(149; ReordPt; Decimal)
        {
            Caption = 'ReordPt';
            AutoFormatType = 0;
        }
        field(150; ReordPtCalc; Decimal)
        {
            Caption = 'ReordPtCalc';
            AutoFormatType = 0;
        }
        field(151; ReordQty; Decimal)
        {
            Caption = 'ReordQty';
            AutoFormatType = 0;
        }
        field(152; ReordQtyCalc; Decimal)
        {
            Caption = 'ReordQtyCalc';
            AutoFormatType = 0;
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
            AutoFormatType = 0;
        }
        field(157; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
            AutoFormatType = 0;
        }
        field(158; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
            AutoFormatType = 0;
        }
        field(159; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
            AutoFormatType = 0;
        }
        field(160; S4Future07; Date)
        {
            Caption = 'S4Future07';
        }
        field(161; S4Future08; Date)
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
            AutoFormatType = 0;
        }
        field(167; SafetyStkCalc; Decimal)
        {
            Caption = 'SafetyStkCalc';
            AutoFormatType = 0;
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
            AutoFormatType = 0;
        }
        field(176; StdCostDate; Date)
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
            AutoFormatType = 0;
        }
        field(179; Turns; Decimal)
        {
            Caption = 'Turns';
            AutoFormatType = 0;
        }
        field(180; UsageRate; Decimal)
        {
            Caption = 'UsageRate';
            AutoFormatType = 0;
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
            AutoFormatType = 0;
        }
        field(184; User4; Decimal)
        {
            Caption = 'User4';
            AutoFormatType = 0;
        }
        field(185; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(186; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(187; User7; Date)
        {
            Caption = 'User7';
        }
        field(188; User8; Date)
        {
            Caption = 'User8';
        }
        field(189; VOvhStdCst; Decimal)
        {
            Caption = 'VOvhStdCst';
            AutoFormatType = 0;
        }
        field(190; YTDUsage; Decimal)
        {
            Caption = 'YTDUsage';
            AutoFormatType = 0;
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