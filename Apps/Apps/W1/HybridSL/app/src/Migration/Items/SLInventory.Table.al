// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47015 "SL Inventory"
{
    Access = Internal;
    Caption = 'SL Inventory';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ABCCode; Text[2])
        {
            Caption = 'ABCCode';
        }
        field(2; ApprovedVendor; Integer)
        {
            Caption = 'ApprovedVendor';
        }
        field(3; AutoPODropShip; Integer)
        {
            Caption = 'AutoPODropShip';
        }
        field(4; AutoPOPolicy; Text[2])
        {
            Caption = 'AutoPOPolicy';
        }
        field(5; BMIDirStdCost; Decimal)
        {
            Caption = 'BMIDirStdCost';
        }
        field(6; BMIFOvhStdCost; Decimal)
        {
            Caption = 'BMIFOvhStdCost';
        }
        field(7; BMILastCost; Decimal)
        {
            Caption = 'BMILastCost';
        }
        field(8; BMIPDirStdCost; Decimal)
        {
            Caption = 'BMIPDirStdCost';
        }
        field(9; BMIPFOvhStdCost; Decimal)
        {
            Caption = 'BMIPFOvhStdCost';
        }
        field(10; BMIPStdCost; Decimal)
        {
            Caption = 'BMIPStdCost';
        }
        field(11; BMIPVOvhStdCost; Decimal)
        {
            Caption = 'BMIPVOvhStdCost';
        }
        field(12; BMIStdCost; Decimal)
        {
            Caption = 'BMIStdCost';
        }
        field(13; BMIVOvhStdCost; Decimal)
        {
            Caption = 'BMIVOvhStdCost';
        }
        field(14; BOLCode; Text[10])
        {
            Caption = 'BOLCode';
        }
        field(15; Buyer; Text[10])
        {
            Caption = 'Buyer';
        }
        field(16; ChkOrdQty; Text[1])
        {
            Caption = 'ChkOrdQty';
        }
        field(17; ClassID; Text[6])
        {
            Caption = 'ClassID';
        }
        field(18; COGSAcct; Text[10])
        {
            Caption = 'COGSAcct';
        }
        field(19; COGSSub; Text[24])
        {
            Caption = 'COGSSub';
        }
        field(20; Color; Text[20])
        {
            Caption = 'Color';
        }
        field(21; CountStatus; Text[1])
        {
            Caption = 'CountStatus';
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
        field(25; CuryListPrice; Decimal)
        {
            Caption = 'CuryListPrice';
        }
        field(26; CuryMinPrice; Decimal)
        {
            Caption = 'CuryMinPrice';
        }
        field(27; CustomFtr; Integer)
        {
            Caption = 'CustomFtr';
        }
        field(28; CycleID; Text[10])
        {
            Caption = 'CycleID';
        }
        field(29; Descr; Text[60])
        {
            Caption = 'Descr';
        }
        field(30; DfltPickLoc; Text[10])
        {
            Caption = 'DfltPickLoc';
        }
        field(31; DfltPOUnit; Text[6])
        {
            Caption = 'DfltPOUnit';
        }
        field(32; DfltSalesAcct; Text[10])
        {
            Caption = 'DfltSalesAcct';
        }
        field(33; DfltSalesSub; Text[24])
        {
            Caption = 'DfltSalesSub';
        }
        field(34; DfltShpnotInvAcct; Text[10])
        {
            Caption = 'DfltShpnotInvAcct';
        }
        field(35; DfltShpnotInvSub; Text[24])
        {
            Caption = 'DfltShpnotInvSub';
        }
        field(36; DfltSite; Text[10])
        {
            Caption = 'DfltSite';
        }
        field(37; DfltSOUnit; Text[6])
        {
            Caption = 'DfltSOUnit';
        }
        field(38; DfltWhseLoc; Text[10])
        {
            Caption = 'DfltWhseLoc';
        }
        field(39; DirStdCost; Decimal)
        {
            Caption = 'DirStdCost';
        }
        field(40; DiscAcct; Text[10])
        {
            Caption = 'DiscAcct';
        }
        field(41; DiscPrc; Text[1])
        {
            Caption = 'DiscPrc';
        }
        field(42; DiscSub; Text[31])
        {
            Caption = 'DiscSub';
        }
        field(43; EOQ; Decimal)
        {
            Caption = 'EOQ';
        }
        field(44; ExplInvoice; Integer)
        {
            Caption = 'ExplInvoice';
        }
        field(45; ExplOrder; Integer)
        {
            Caption = 'ExplOrder';
        }
        field(46; ExplPackSlip; Integer)
        {
            Caption = 'ExplPackSlip';
        }
        field(47; ExplPickList; Integer)
        {
            Caption = 'ExplPickList';
        }
        field(48; ExplShipping; Integer)
        {
            Caption = 'ExplShipping';
        }
        field(49; FOvhStdCost; Decimal)
        {
            Caption = 'FOvhStdCost';
        }
        field(50; FrtAcct; Text[10])
        {
            Caption = 'FrtAcct';
        }
        field(51; FrtSub; Text[24])
        {
            Caption = 'FrtSub';
        }
        field(52; GLClassID; Text[4])
        {
            Caption = 'GLClassID';
        }
        field(53; InvtAcct; Text[10])
        {
            Caption = 'InvtAcct';
        }
        field(54; InvtID; Text[30])
        {
            Caption = 'InvtID';
        }
        field(55; InvtSub; Text[24])
        {
            Caption = 'InvtSub';
        }
        field(56; InvtType; Text[1])
        {
            Caption = 'InvtType';
        }
        field(57; IRCalcPolicy; Text[1])
        {
            Caption = 'IRCalcPolicy';
        }
        field(58; IRDaysSupply; Decimal)
        {
            Caption = 'IRDaysSupply';
        }
        field(59; IRDemandID; Text[10])
        {
            Caption = 'IRDemandID';
        }
        field(60; IRFutureDate; DateTime)
        {
            Caption = 'IRFutureDate';
        }
        field(61; IRFuturePolicy; Text[1])
        {
            Caption = 'IRFuturePolicy';
        }
        field(62; IRLeadTimeID; Text[10])
        {
            Caption = 'IRLeadTimeID';
        }
        field(63; IRLinePtQty; Decimal)
        {
            Caption = 'IRLinePtQty';
        }
        field(64; IRMinOnHand; Decimal)
        {
            Caption = 'IRMinOnHand';
        }
        field(65; IRModelInvtID; Text[30])
        {
            Caption = 'IRModelInvtID';
        }
        field(66; IRRCycDays; Integer)
        {
            Caption = 'IRRCycDays';
        }
        field(67; IRSeasonEndDay; Integer)
        {
            Caption = 'IRSeasonEndDay';
        }
        field(68; IRSeasonEndMon; Integer)
        {
            Caption = 'IRSeasonEndMon';
        }
        field(69; IRSeasonStrtDay; Integer)
        {
            Caption = 'IRSeasonStrtDay';
        }
        field(70; IRSeasonStrtMon; Integer)
        {
            Caption = 'IRSeasonStrtMon';
        }
        field(71; IRServiceLevel; Decimal)
        {
            Caption = 'IRServiceLevel';
        }
        field(72; IRSftyStkDays; Decimal)
        {
            Caption = 'IRSftyStkDays';
        }
        field(73; IRSftyStkPct; Decimal)
        {
            Caption = 'IRSftyStkPct';
        }
        field(74; IRSftyStkPolicy; Text[1])
        {
            Caption = 'IRSftyStkPolicy';
        }
        field(75; IRSourceCode; Text[1])
        {
            Caption = 'IRSourceCode';
        }
        field(76; IRTargetOrdMethod; Text[1])
        {
            Caption = 'IRTargetOrdMethod';
        }
        field(77; IRTargetOrdReq; Decimal)
        {
            Caption = 'IRTargetOrdReq';
        }
        field(78; IRTransferSiteID; Text[10])
        {
            Caption = 'IRTransferSiteID';
        }
        field(79; ItemCommClassID; Text[10])
        {
            Caption = 'ItemCommClassID';
        }
        field(80; Kit; Integer)
        {
            Caption = 'Kit';
        }
        field(81; LastBookQty; Decimal)
        {
            Caption = 'LastBookQty';
        }
        field(82; LastCost; Decimal)
        {
            Caption = 'LastCost';
        }
        field(83; LastCountDate; DateTime)
        {
            Caption = 'LastCountDate';
        }
        field(84; LastSiteID; Text[10])
        {
            Caption = 'LastSiteID';
        }
        field(85; LastStdCost; Decimal)
        {
            Caption = 'LastStdCost';
        }
        field(86; LastVarAmt; Decimal)
        {
            Caption = 'LastVarAmt';
        }
        field(87; LastVarPct; Decimal)
        {
            Caption = 'LastVarPct';
        }
        field(88; LastVarQty; Decimal)
        {
            Caption = 'LastVarQty';
        }
        field(89; LCVarianceAcct; Text[10])
        {
            Caption = 'LCVarianceAcct';
        }
        field(90; LCVarianceSub; Text[24])
        {
            Caption = 'LCVarianceSub';
        }
        field(91; LeadTime; Decimal)
        {
            Caption = 'LeadTime';
        }
        field(92; LinkSpecId; Integer)
        {
            Caption = 'LinkSpecId';
        }
        field(93; LotSerFxdLen; Integer)
        {
            Caption = 'LotSerFxdLen';
        }
        field(94; LotSerFxdTyp; Text[1])
        {
            Caption = 'LotSerFxdTyp';
        }
        field(95; LotSerFxdVal; Text[12])
        {
            Caption = 'LotSerFxdVal';
        }
        field(96; LotSerIssMthd; Text[1])
        {
            Caption = 'LotSerIssMthd';
        }
        field(97; LotSerNumLen; Integer)
        {
            Caption = 'LotSerNumLen';
        }
        field(98; LotSerNumVal; Text[25])
        {
            Caption = 'LotSerNumVal';
        }
        field(99; LotSerTrack; Text[2])
        {
            Caption = 'LotSerTrack';
        }
        field(100; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(101; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(102; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(103; MaterialType; Text[10])
        {
            Caption = 'MaterialType';
        }
        field(104; MaxOnHand; Decimal)
        {
            Caption = 'MaxOnHand';
        }
        field(105; MfgClassID; Text[10])
        {
            Caption = 'MfgClassID';
        }
        field(106; MfgLeadTime; Decimal)
        {
            Caption = 'MfgLeadTime';
        }
        field(107; MinGrossProfit; Decimal)
        {
            Caption = 'MinGrossProfit';
        }
        field(108; MoveClass; Text[10])
        {
            Caption = 'MoveClass';
        }
        field(109; MSDS; Text[24])
        {
            Caption = 'MSDS';
        }
        field(110; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(111; Pack; Text[6])
        {
            Caption = 'Pack';
        }
        field(112; PDirStdCost; Decimal)
        {
            Caption = 'PDirStdCost';
        }
        field(113; PerNbr; Text[6])
        {
            Caption = 'PerNbr';
        }
        field(114; PFOvhStdCost; Decimal)
        {
            Caption = 'PFOvhStdCost';
        }
        field(115; PPVAcct; Text[10])
        {
            Caption = 'PPVAcct';
        }
        field(116; PPVSub; Text[24])
        {
            Caption = 'PPVSub';
        }
        field(117; PriceClassID; Text[6])
        {
            Caption = 'PriceClassID';
        }
        field(118; ProdMgrID; Text[10])
        {
            Caption = 'ProdMgrID';
        }
        field(119; ProductionUnit; Text[6])
        {
            Caption = 'ProductionUnit';
        }
        field(120; PStdCost; Decimal)
        {
            Caption = 'PStdCost';
        }
        field(121; PStdCostDate; DateTime)
        {
            Caption = 'PStdCostDate';
        }
        field(122; PVOvhStdCost; Decimal)
        {
            Caption = 'PVOvhStdCost';
        }
        field(123; ReordPt; Decimal)
        {
            Caption = 'ReordPt';
        }
        field(124; ReOrdPtCalc; Decimal)
        {
            Caption = 'ReOrdPtCalc';
        }
        field(125; ReordQty; Decimal)
        {
            Caption = 'ReordQty';
        }
        field(126; ReOrdQtyCalc; Decimal)
        {
            Caption = 'ReOrdQtyCalc';
        }
        field(127; ReplMthd; Text[1])
        {
            Caption = 'ReplMthd';
        }
        field(128; RollupCost; Integer)
        {
            Caption = 'RollupCost';
        }
        field(129; RollupPrice; Integer)
        {
            Caption = 'RollupPrice';
        }
        field(130; RvsdPrc; Integer)
        {
            Caption = 'RvsdPrc';
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
        field(143; S4Future13; Text[10])
        {
            Caption = 'S4Future13';
        }
        field(144; SafetyStk; Decimal)
        {
            Caption = 'SafetyStk';
        }
        field(145; SafetyStkCalc; Decimal)
        {
            Caption = 'SafetyStkCalc';
        }
        field(146; Selected; Integer)
        {
            Caption = 'Selected';
        }
        field(147; SerAssign; Text[1])
        {
            Caption = 'SerAssign';
        }
        field(148; Service; Integer)
        {
            Caption = 'Service';
        }
        field(149; ShelfLife; Integer)
        {
            Caption = 'ShelfLife';
        }
        field(150; Size; Text[10])
        {
            Caption = 'Size';
        }
        field(151; Source; Text[1])
        {
            Caption = 'Source';
        }
        field(152; Status; Text[1])
        {
            Caption = 'Status';
        }
        field(153; StdCost; Decimal)
        {
            Caption = 'StdCost';
        }
        field(154; StdCostDate; DateTime)
        {
            Caption = 'StdCostDate';
        }
        field(155; StkBasePrc; Decimal)
        {
            Caption = 'StkBasePrc';
        }
        field(156; StkItem; Integer)
        {
            Caption = 'StkItem';
        }
        field(157; StkRvsdPrc; Decimal)
        {
            Caption = 'StkRvsdPrc';
        }
        field(158; StkTaxBasisPrc; Decimal)
        {
            Caption = 'StkTaxBasisPrc';
        }
        field(159; StkUnit; Text[6])
        {
            Caption = 'StkUnit';
        }
        field(160; StkVol; Decimal)
        {
            Caption = 'StkVol';
        }
        field(161; StkWt; Decimal)
        {
            Caption = 'StkWt';
        }
        field(162; StkWtUnit; Text[6])
        {
            Caption = 'StkWtUnit';
        }
        field(163; Style; Text[10])
        {
            Caption = 'Style';
        }
        field(164; Supplr1; Text[15])
        {
            Caption = 'Supplr1';
        }
        field(165; Supplr2; Text[15])
        {
            Caption = 'Supplr2';
        }
        field(166; SupplrItem1; Text[20])
        {
            Caption = 'SupplrItem1';
        }
        field(167; SupplrItem2; Text[20])
        {
            Caption = 'SupplrItem2';
        }
        field(168; TaskID; Text[32])
        {
            Caption = 'TaskID';
        }
        field(169; TaxCat; Text[10])
        {
            Caption = 'TaxCat';
        }
        field(170; TranStatusCode; Text[2])
        {
            Caption = 'TranStatusCode';
        }
        field(171; Turns; Decimal)
        {
            Caption = 'Turns';
        }
        field(172; UPCCode; Text[30])
        {
            Caption = 'UPCCode';
        }
        field(173; UsageRate; Decimal)
        {
            Caption = 'UsageRate';
        }
        field(174; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(175; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(176; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(177; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(178; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(179; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(180; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(181; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(182; ValMthd; Text[1])
        {
            Caption = 'ValMthd';
        }
        field(183; VOvhStdCost; Decimal)
        {
            Caption = 'VOvhStdCost';
        }
        field(184; WarrantyDays; Integer)
        {
            Caption = 'WarrantyDays';
        }
        field(185; YTDUsage; Decimal)
        {
            Caption = 'YTDUsage';
        }
    }

    keys
    {
        key(Key1; InvtID)
        {
            Clustered = true;
        }
    }
}