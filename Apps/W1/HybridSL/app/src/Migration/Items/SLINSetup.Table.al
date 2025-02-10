// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47014 "SL INSetup"
{
    Access = Internal;
    Caption = 'SL INSetup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ActivateLang; Integer)
        {
            Caption = 'ActivateLang';
        }
        field(2; AdjustmentsAcct; Text[10])
        {
            Caption = 'AdjustmentsAcct';
        }
        field(3; AdjustmentsSub; Text[24])
        {
            Caption = 'AdjustmentsSub';
        }
        field(4; AllowCostEntry; Integer)
        {
            Caption = 'AllowCostEntry';
        }
        field(5; APClearingAcct; Text[10])
        {
            Caption = 'APClearingAcct';
        }
        field(6; APClearingSub; Text[24])
        {
            Caption = 'APClearingSub';
        }
        field(7; ARClearingAcct; Text[10])
        {
            Caption = 'ARClearingAcct';
        }
        field(8; ARClearingSub; Text[24])
        {
            Caption = 'ARClearingSub';
        }
        field(9; AutoAdjustEntry; Integer)
        {
            Caption = 'AutoAdjustEntry';
        }
        field(10; AutoBatRpt; Integer)
        {
            Caption = 'AutoBatRpt';
        }
        field(11; AutoRelease; Text[1])
        {
            Caption = 'AutoRelease';
        }
        field(12; BMICuryID; Text[4])
        {
            Caption = 'BMICuryID';
        }
        field(13; BMIDfltRtTp; Text[6])
        {
            Caption = 'BMIDfltRtTp';
        }
        field(14; BMIEnabled; Integer)
        {
            Caption = 'BMIEnabled';
        }
        field(15; CPSOnOff; Integer)
        {
            Caption = 'CPSOnOff';
        }
        field(16; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(17; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(18; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(19; CurrPerNbr; Text[6])
        {
            Caption = 'CurrPerNbr';
        }
        field(20; DecPlPrcCst; Integer)
        {
            Caption = 'DecPlPrcCst';
        }
        field(21; DecPlQty; Integer)
        {
            Caption = 'DecPlQty';
        }
        field(22; DfltChkOrdQty; Text[1])
        {
            Caption = 'DfltChkOrdQty';
        }
        field(23; DfltCOGSAcct; Text[10])
        {
            Caption = 'DfltCOGSAcct';
        }
        field(24; DfltCOGSSub; Text[24])
        {
            Caption = 'DfltCOGSSub';
        }
        field(25; DfltDIscPrc; Text[1])
        {
            Caption = 'DfltDIscPrc';
        }
        field(26; DfltInvtAcct; Text[10])
        {
            Caption = 'DfltInvtAcct';
        }
        field(27; DfltInvtLeadTime; Decimal)
        {
            Caption = 'DfltInvtLeadTime';
        }
        field(28; DfltInvtMfgLeadTime; Decimal)
        {
            Caption = 'DfltInvtMfgLeadTime';
        }
        field(29; DfltInvtSub; Text[24])
        {
            Caption = 'DfltInvtSub';
        }
        field(30; DfltInvtType; Text[1])
        {
            Caption = 'DfltInvtType';
        }
        field(31; DfltItmSiteAcct; Text[10])
        {
            Caption = 'DfltItmSiteAcct';
        }
        field(32; DfltLCVarianceAcct; Text[10])
        {
            Caption = 'DfltLCVarianceAcct';
        }
        field(33; DfltLCVarianceSub; Text[24])
        {
            Caption = 'DfltLCVarianceSub';
        }
        field(34; DfltLotAssign; Text[1])
        {
            Caption = 'DfltLotAssign';
        }
        field(35; DfltlotFxdLen; Integer)
        {
            Caption = 'DfltlotFxdLen';
        }
        field(36; DfltLotFxdTyp; Text[1])
        {
            Caption = 'DfltLotFxdTyp';
        }
        field(37; DfltLotFxdVal; Text[12])
        {
            Caption = 'DfltLotFxdVal';
        }
        field(38; DfltLotMthd; Text[1])
        {
            Caption = 'DfltLotMthd';
        }
        field(39; DfltLotNumLen; Integer)
        {
            Caption = 'DfltLotNumLen';
        }
        field(40; DfltLotNumVal; Text[25])
        {
            Caption = 'DfltLotNumVal';
        }
        field(41; DfltLotSerTrack; Text[1])
        {
            Caption = 'DfltLotSerTrack';
        }
        field(42; DfltLotShelfLife; Integer)
        {
            Caption = 'DfltLotShelfLife';
        }
        field(43; DfltPhysQty; Integer)
        {
            Caption = 'DfltPhysQty';
        }
        field(44; DfltPPVAcct; Text[10])
        {
            Caption = 'DfltPPVAcct';
        }
        field(45; DfltPPVSub; Text[24])
        {
            Caption = 'DfltPPVSub';
        }
        field(46; DfltProdClass; Text[6])
        {
            Caption = 'DfltProdClass';
        }
        field(47; DfltSalesAcct; Text[10])
        {
            Caption = 'DfltSalesAcct';
        }
        field(48; DfltSalesSub; Text[24])
        {
            Caption = 'DfltSalesSub';
        }
        field(49; DfltSerAssign; Text[1])
        {
            Caption = 'DfltSerAssign';
        }
        field(50; DfltSerFxdLen; Integer)
        {
            Caption = 'DfltSerFxdLen';
        }
        field(51; DfltSerFxdTyp; Text[1])
        {
            Caption = 'DfltSerFxdTyp';
        }
        field(52; DfltSerFxdVal; Text[12])
        {
            Caption = 'DfltSerFxdVal';
        }
        field(53; DfltSerMethod; Text[1])
        {
            Caption = 'DfltSerMethod';
        }
        field(54; DfltSerNumLen; Integer)
        {
            Caption = 'DfltSerNumLen';
        }
        field(55; DfltSerNumVal; Text[25])
        {
            Caption = 'DfltSerNumVal';
        }
        field(56; DfltSerShelfLife; Integer)
        {
            Caption = 'DfltSerShelfLife';
        }
        field(57; DfltShpnotInvAcct; Text[10])
        {
            Caption = 'DfltShpnotInvAcct';
        }
        field(58; DfltShpnotInvSub; Text[24])
        {
            Caption = 'DfltShpnotInvSub';
        }
        field(59; DfltSite; Text[10])
        {
            Caption = 'DfltSite';
        }
        field(60; DfltSlsTaxCat; Text[10])
        {
            Caption = 'DfltSlsTaxCat';
        }
        field(61; DfltSource; Text[1])
        {
            Caption = 'DfltSource';
        }
        field(62; DfltStatus; Text[1])
        {
            Caption = 'DfltStatus';
        }
        field(63; DfltStatusQtyZero; Text[1])
        {
            Caption = 'DfltStatusQtyZero';
        }
        field(64; DfltStkItem; Integer)
        {
            Caption = 'DfltStkItem';
        }
        field(65; DfltValMthd; Text[1])
        {
            Caption = 'DfltValMthd';
        }
        field(66; DfltVarAcct; Text[10])
        {
            Caption = 'DfltVarAcct';
        }
        field(67; DfltVarSub; Text[24])
        {
            Caption = 'DfltVarSub';
        }
        field(68; ExplInvoice; Integer)
        {
            Caption = 'ExplInvoice';
        }
        field(69; ExplOrder; Integer)
        {
            Caption = 'ExplOrder';
        }
        field(70; ExplPackSlip; Integer)
        {
            Caption = 'ExplPackSlip';
        }
        field(71; ExplPickList; Integer)
        {
            Caption = 'ExplPickList';
        }
        field(72; ExplShipping; Integer)
        {
            Caption = 'ExplShipping';
        }
        field(73; ExprdLotNbrs; Integer)
        {
            Caption = 'ExprdLotNbrs';
        }
        field(74; ExprdSerNbrs; Integer)
        {
            Caption = 'ExprdSerNbrs';
        }
        field(75; GLPostOpt; Text[1])
        {
            Caption = 'GLPostOpt';
        }
        field(76; InclAllocQty; Integer)
        {
            Caption = 'InclAllocQty';
        }
        field(77; INClearingAcct; Text[10])
        {
            Caption = 'INClearingAcct';
        }
        field(78; INClearingSub; Text[24])
        {
            Caption = 'INClearingSub';
        }
        field(79; InclQtyAllocWO; Integer)
        {
            Caption = 'InclQtyAllocWO';
        }
        field(80; InclQtyCustOrd; Integer)
        {
            Caption = 'InclQtyCustOrd';
        }
        field(81; InclQtyInTransit; Integer)
        {
            Caption = 'InclQtyInTransit';
        }
        field(82; InclQtyOnBO; Integer)
        {
            Caption = 'InclQtyOnBO';
        }
        field(83; InclQtyOnPO; Integer)
        {
            Caption = 'InclQtyOnPO';
        }
        field(84; InclQtyOnWO; Integer)
        {
            Caption = 'InclQtyOnWO';
        }
        field(85; InclWOFirmDemand; Integer)
        {
            Caption = 'InclWOFirmDemand';
        }
        field(86; InclWOFirmSupply; Integer)
        {
            Caption = 'InclWOFirmSupply';
        }
        field(87; InclWORlsedDemand; Integer)
        {
            Caption = 'InclWORlsedDemand';
        }
        field(88; InclWORlsedSupply; Integer)
        {
            Caption = 'InclWORlsedSupply';
        }
        field(89; "Init"; Integer)
        {
            Caption = 'Init';
        }
        field(90; InTransitAcct; Text[10])
        {
            Caption = 'InTransitAcct';
        }
        field(91; InTransitSub; Text[24])
        {
            Caption = 'InTransitSub';
        }
        field(92; IssuesAcct; Text[10])
        {
            Caption = 'IssuesAcct';
        }
        field(93; IssuesSub; Text[24])
        {
            Caption = 'IssuesSub';
        }
        field(94; LanguageID; Text[4])
        {
            Caption = 'LanguageID';
        }
        field(95; LastArchiveDate; DateTime)
        {
            Caption = 'LastArchiveDate';
        }
        field(96; LastBatNbr; Text[10])
        {
            Caption = 'LastBatNbr';
        }
        field(97; LastCountDate; DateTime)
        {
            Caption = 'LastCountDate';
        }
        field(98; LastTagNbr; Integer)
        {
            Caption = 'LastTagNbr';
        }
        field(99; LotSerRetHist; Integer)
        {
            Caption = 'LotSerRetHist';
        }
        field(100; LstSlsPrcID; Text[10])
        {
            Caption = 'LstSlsPrcID';
        }
        field(101; LstTrnsfrDocNbr; Text[10])
        {
            Caption = 'LstTrnsfrDocNbr';
        }
        field(102; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(103; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(104; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(105; MaterialType; Text[10])
        {
            Caption = 'MaterialType';
        }
        field(106; MatlOvhCalc; Text[1])
        {
            Caption = 'MatlOvhCalc';
        }
        field(107; MatlOvhOffAcct; Text[10])
        {
            Caption = 'MatlOvhOffAcct';
        }
        field(108; MatlOvhOffSub; Text[24])
        {
            Caption = 'MatlOvhOffSub';
        }
        field(109; MatlOvhRatePct; Text[1])
        {
            Caption = 'MatlOvhRatePct';
        }
        field(110; MatlOvhVarAcct; Text[10])
        {
            Caption = 'MatlOvhVarAcct';
        }
        field(111; MatlOvhVarSub; Text[24])
        {
            Caption = 'MatlOvhVarSub';
        }
        field(112; MfgClassID; Text[10])
        {
            Caption = 'MfgClassID';
        }
        field(113; MinGrossProfit; Decimal)
        {
            Caption = 'MinGrossProfit';
        }
        field(114; MultWhse; Integer)
        {
            Caption = 'MultWhse';
        }
        field(115; NbrCounts; Integer)
        {
            Caption = 'NbrCounts';
        }
        field(116; NbrCycleCounts; Integer)
        {
            Caption = 'NbrCycleCounts';
        }
        field(117; NegQty; Integer)
        {
            Caption = 'NegQty';
        }
        field(118; NonKitAssy; Integer)
        {
            Caption = 'NonKitAssy';
        }
        field(119; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(120; OverSoldCostLayers; Integer)
        {
            Caption = 'OverSoldCostLayers';
        }
        field(121; PerNbr; Text[6])
        {
            Caption = 'PerNbr';
        }
        field(122; PerRetPITrans; Integer)
        {
            Caption = 'PerRetPITrans';
        }
        field(123; PerRetTran; Integer)
        {
            Caption = 'PerRetTran';
        }
        field(124; PhysAdjVarAcct; Text[10])
        {
            Caption = 'PhysAdjVarAcct';
        }
        field(125; PhysAdjVarSub; Text[24])
        {
            Caption = 'PhysAdjVarSub';
        }
        field(126; PIABC; Text[1])
        {
            Caption = 'PIABC';
        }
        field(127; PMAvail; Integer)
        {
            Caption = 'PMAvail';
        }
        field(128; RollBackBatches; Integer)
        {
            Caption = 'RollBackBatches';
        }
        field(129; RollupCost; Integer)
        {
            Caption = 'RollupCost';
        }
        field(130; RollupPrice; Integer)
        {
            Caption = 'RollupPrice';
        }
        field(131; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(132; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(133; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(134; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(135; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(136; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(137; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(138; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(139; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(140; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(141; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(142; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(143; SerAssign; Text[1])
        {
            Caption = 'SerAssign';
        }
        field(144; SetupId; Text[2])
        {
            Caption = 'SetupId';
        }
        field(145; SiteID; Text[10])
        {
            Caption = 'SiteID';
        }
        field(146; SpecChar; Text[24])
        {
            Caption = 'SpecChar';
        }
        field(147; StdCstRevalAcct; Text[10])
        {
            Caption = 'StdCstRevalAcct';
        }
        field(148; StdCstRevalSub; Text[24])
        {
            Caption = 'StdCstRevalSub';
        }
        field(149; TableBypass; Integer)
        {
            Caption = 'TableBypass';
        }
        field(150; Tagged; Integer)
        {
            Caption = 'Tagged';
        }
        field(151; TranCOGSSub; Text[1])
        {
            Caption = 'TranCOGSSub';
        }
        field(152; UpdateGL; Integer)
        {
            Caption = 'UpdateGL';
        }
        field(153; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(154; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(155; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(156; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(157; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(158; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(159; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(160; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(161; VolUnit; Text[6])
        {
            Caption = 'VolUnit';
        }
        field(162; WhseLocValid; Text[1])
        {
            Caption = 'WhseLocValid';
        }
        field(163; WtUnit; Text[6])
        {
            Caption = 'WtUnit';
        }
        field(164; YrsRetArchTran; Integer)
        {
            Caption = 'YrsRetArchTran';
        }
        field(165; YrsRetHist; Integer)
        {
            Caption = 'YrsRetHist';
        }
    }

    keys
    {
        key(Key1; SetupId)
        {
            Clustered = true;
        }
    }
}