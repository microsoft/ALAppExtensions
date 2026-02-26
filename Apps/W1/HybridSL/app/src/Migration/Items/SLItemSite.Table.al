#if not CLEANSCHEMA31
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
    ObsoleteReason = 'Replaced by table SL ItemSite Buffer.';
#if not CLEAN28
    ObsoleteState = Pending;
    ObsoleteTag = '28.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '31.0';
#endif

    fields
    {
        field(1; ABCCode; Text[2])
        {
            Caption = 'ABCCode';
        }
        field(2; AllocQty; Decimal)
        {
            AutoFormatType = 0;
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
            AutoFormatType = 0;
            Caption = 'AvgCost';
        }
        field(6; BMIAvgCost; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'BMIAvgCost';
        }
        field(7; BMIDirStdCst; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'BMIDirStdCst';
        }
        field(8; BMIFOvhStdCst; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'BMIFOvhStdCst';
        }
        field(9; BMILastCost; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'BMILastCost';
        }
        field(10; BMIPDirStdCst; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'BMIPDirStdCst';
        }
        field(11; BMIPFOvhStdCst; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'BMIPFOvhStdCst';
        }
        field(12; BMIPStdCst; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'BMIPStdCst';
        }
        field(13; BMIPVOvhStdCst; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'BMIPVOvhStdCst';
        }
        field(14; BMIStdCost; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'BMIStdCost';
        }
        field(15; BMITotCost; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'BMITotCost';
        }
        field(16; BMIVOvhStdCst; Decimal)
        {
            AutoFormatType = 0;
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
            AutoFormatType = 0;
            Caption = 'DirStdCst';
        }
        field(34; EOQ; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'EOQ';
        }
        field(35; FOvhStdCst; Decimal)
        {
            AutoFormatType = 0;
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
            AutoFormatType = 0;
            Caption = 'IRCalcDailyUsage';
        }
        field(40; IRCalcEOQ; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRCalcEOQ';
        }
        field(41; IRCalcLeadTime; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRCalcLeadTime';
        }
        field(42; IRCalcLinePt; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRCalcLinePt';
        }
        field(43; IRCalcRCycDays; Integer)
        {
            Caption = 'IRCalcRCycDays';
        }
        field(44; IRCalcReOrdPt; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRCalcReOrdPt';
        }
        field(45; IRCalcReOrdQty; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRCalcReOrdQty';
        }
        field(46; IRCalcSafetyStk; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRCalcSafetyStk';
        }
        field(47; IRDailyUsage; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRDailyUsage';
        }
        field(48; IRDaysSupply; Decimal)
        {
            AutoFormatType = 0;
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
            AutoFormatType = 0;
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
            AutoFormatType = 0;
            Caption = 'IRMaxDailyUsage';
        }
        field(63; IRMaxEOQ; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRMaxEOQ';
        }
        field(64; IRMaxLeadTime; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRMaxLeadTime';
        }
        field(65; IRMaxLinePt; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRMaxLinePt';
        }
        field(66; IRMaxRCycDays; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRMaxRCycDays';
        }
        field(67; IRMaxReOrdPt; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRMaxReOrdPt';
        }
        field(68; IRMaxReOrdQty; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRMaxReOrdQty';
        }
        field(69; IRMaxSafetyStk; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRMaxSafetyStk';
        }
        field(70; IRMinDailyUsage; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRMinDailyUsage';
        }
        field(71; IRMinEOQ; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRMinEOQ';
        }
        field(72; IRMinLeadTime; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRMinLeadTime';
        }
        field(73; IRMinLinePt; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRMinLinePt';
        }
        field(74; IRMinOnHand; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRMinOnHand';
        }
        field(75; IRMinRCycDays; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRMinRCycDays';
        }
        field(76; IRMinReOrdPt; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRMinReOrdPt';
        }
        field(77; IRMinReOrdQty; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRMinReOrdQty';
        }
        field(78; IRMinSafetyStk; Decimal)
        {
            AutoFormatType = 0;
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
            AutoFormatType = 0;
            Caption = 'IRServiceLevel';
        }
        field(86; IRSftyStkDays; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'IRSftyStkDays';
        }
        field(87; IRSftyStkPct; Decimal)
        {
            AutoFormatType = 0;
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
            AutoFormatType = 0;
            Caption = 'IRTargetOrdReq';
        }
        field(92; IRTransferSiteID; Text[10])
        {
            Caption = 'IRTransferSiteID';
        }
        field(93; LastBookQty; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'LastBookQty';
        }
        field(94; LastCost; Decimal)
        {
            AutoFormatType = 0;
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
            AutoFormatType = 0;
            Caption = 'LastPurchasePrice';
        }
        field(98; LastStdCost; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'LastStdCost';
        }
        field(99; LastVarAmt; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'LastVarAmt';
        }
        field(100; LastVarPct; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'LastVarPct';
        }
        field(101; LastVarQty; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'LastVarQty';
        }
        field(102; LastVendor; Text[15])
        {
            Caption = 'LastVendor';
        }
        field(103; LeadTime; Decimal)
        {
            AutoFormatType = 0;
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
            AutoFormatType = 0;
            Caption = 'MaxOnHand';
        }
        field(108; MfgClassID; Text[10])
        {
            Caption = 'MfgClassID';
        }
        field(109; MfgLeadTime; Decimal)
        {
            AutoFormatType = 0;
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
            AutoFormatType = 0;
            Caption = 'PDirStdCst';
        }
        field(113; PFOvhStdCst; Decimal)
        {
            AutoFormatType = 0;
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
            AutoFormatType = 0;
            Caption = 'PrjINQtyAlloc';
        }
        field(117; PrjINQtyAllocIN; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'PrjINQtyAllocIN';
        }
        field(118; PrjINQtyAllocPORet; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'PrjINQtyAllocPORet';
        }
        field(119; PrjINQtyAllocSO; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'PrjINQtyAllocSO';
        }
        field(120; PrjINQtyCustOrd; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'PrjINQtyCustOrd';
        }
        field(121; PrjINQtyShipNotInv; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'PrjINQtyShipNotInv';
        }
        field(122; PStdCostDate; DateTime)
        {
            Caption = 'PStdCostDate';
        }
        field(123; PStdCst; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'PStdCst';
        }
        field(124; PVOvhStdCst; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'PVOvhStdCst';
        }
        field(125; QtyAlloc; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyAlloc';
        }
        field(126; QtyAllocBM; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyAllocBM';
        }
        field(127; QtyAllocIN; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyAllocIN';
        }
        field(128; QtyAllocOther; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyAllocOther';
        }
        field(129; QtyAllocPORet; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyAllocPORet';
        }
        field(130; QtyAllocProjIN; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyAllocProjIN';
        }
        field(131; QtyAllocSD; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyAllocSD';
        }
        field(132; QtyAllocSO; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyAllocSO';
        }
        field(133; QtyAvail; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyAvail';
        }
        field(134; QtyCustOrd; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyCustOrd';
        }
        field(135; QtyInTransit; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyInTransit';
        }
        field(136; QtyNotAvail; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyNotAvail';
        }
        field(137; QtyOnBO; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyOnBO';
        }
        field(138; QtyOnDP; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyOnDP';
        }
        field(139; QtyOnHand; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyOnHand';
        }
        field(140; QtyOnKitAssyOrders; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyOnKitAssyOrders';
        }
        field(141; QtyOnPO; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyOnPO';
        }
        field(142; QtyOnTransferOrders; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyOnTransferOrders';
        }
        field(143; QtyShipNotInv; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyShipNotInv';
        }
        field(144; QtyWOFirmDemand; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyWOFirmDemand';
        }
        field(145; QtyWOFirmSupply; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyWOFirmSupply';
        }
        field(146; QtyWORlsedDemand; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyWORlsedDemand';
        }
        field(147; QtyWORlsedSupply; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'QtyWORlsedSupply';
        }
        field(148; ReordInterval; Integer)
        {
            Caption = 'ReordInterval';
        }
        field(149; ReordPt; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'ReordPt';
        }
        field(150; ReordPtCalc; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'ReordPtCalc';
        }
        field(151; ReordQty; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'ReordQty';
        }
        field(152; ReordQtyCalc; Decimal)
        {
            AutoFormatType = 0;
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
            AutoFormatType = 0;
            Caption = 'S4Future03';
        }
        field(157; S4Future04; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'S4Future04';
        }
        field(158; S4Future05; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'S4Future05';
        }
        field(159; S4Future06; Decimal)
        {
            AutoFormatType = 0;
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
            AutoFormatType = 0;
            Caption = 'SafetyStk';
        }
        field(167; SafetyStkCalc; Decimal)
        {
            AutoFormatType = 0;
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
            AutoFormatType = 0;
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
            AutoFormatType = 0;
            Caption = 'TotCost';
        }
        field(179; Turns; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Turns';
        }
        field(180; UsageRate; Decimal)
        {
            AutoFormatType = 0;
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
            AutoFormatType = 0;
            Caption = 'User3';
        }
        field(184; User4; Decimal)
        {
            AutoFormatType = 0;
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
            AutoFormatType = 0;
            Caption = 'VOvhStdCst';
        }
        field(190; YTDUsage; Decimal)
        {
            AutoFormatType = 0;
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
#endif
