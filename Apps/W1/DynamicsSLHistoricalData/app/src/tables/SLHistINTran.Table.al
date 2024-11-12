// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

table 42808 "SL Hist. INTran"
{
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; Acct; Text[10])
        {
            Caption = 'Acct';
        }
        field(2; AcctDist; Integer)
        {
            Caption = 'AcctDist';
        }
        field(3; ARDocType; Text[2])
        {
            Caption = 'ARDocType';
        }
        field(4; ARLineID; Integer)
        {
            Caption = 'ARLineID';
        }
        field(5; ARLineRef; Text[5])
        {
            Caption = 'ARLineRef';
        }
        field(6; BatNbr; Text[10])
        {
            Caption = 'BatNbr';
        }
        field(7; BMICuryID; Text[4])
        {
            Caption = 'BMICuryID';
        }
        field(8; BMIEffDate; DateTime)
        {
            Caption = 'BMIEffDate';
        }
        field(9; BMIEstimatedCost; Decimal)
        {
            Caption = 'BMIEstimatedCost';
        }
        field(10; BMIExtCost; Decimal)
        {
            Caption = 'BMIExtCost';
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
        field(14; BMITranAmt; Decimal)
        {
            Caption = 'BMITranAmt';
        }
        field(15; BMIUnitPrice; Decimal)
        {
            Caption = 'BMIUnitPrice';
        }
        field(16; CmmnPct; Decimal)
        {
            Caption = 'CmmnPct';
        }
        field(17; CnvFact; Decimal)
        {
            Caption = 'CnvFact';
        }
        field(18; COGSAcct; Text[10])
        {
            Caption = 'COGSAcct';
        }
        field(19; COGSSub; Text[24])
        {
            Caption = 'COGSSub';
        }
        field(20; CostType; Text[8])
        {
            Caption = 'CostType';
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
        field(25; DrCr; Text[1])
        {
            Caption = 'DrCr';
        }
        field(26; EstimatedCost; Decimal)
        {
            Caption = 'EstimatedCost';
        }
        field(27; Excpt; Integer)
        {
            Caption = 'Excpt';
        }
        field(28; ExtCost; Decimal)
        {
            Caption = 'ExtCost';
        }
        field(29; ExtRefNbr; Text[15])
        {
            Caption = 'ExtRefNbr';
        }
        field(30; FiscYr; Text[4])
        {
            Caption = 'FiscYr';
        }
        field(31; FlatRateLineNbr; Integer)
        {
            Caption = 'FlatRateLineNbr';
        }
        field(32; ID; Text[15])
        {
            Caption = 'ID';
        }
        field(34; InsuffQty; Integer)
        {
            Caption = 'InsuffQty';
        }
        field(35; InvtAcct; Text[10])
        {
            Caption = 'InvtAcct';
        }
        field(36; InvtID; Text[30])
        {
            Caption = 'InvtID';
        }
        field(37; InvtMult; Integer)
        {
            Caption = 'InvtMult';
        }
        field(38; InvtSub; Text[24])
        {
            Caption = 'InvtSub';
        }
        field(39; IRProcessed; Integer)
        {
            Caption = 'IRProcessed';
        }
        field(40; JrnlType; Text[3])
        {
            Caption = 'JrnlType';
        }
        field(41; KitID; Text[30])
        {
            Caption = 'KitID';
        }
        field(42; KitStdQty; Decimal)
        {
            Caption = 'KitStdQty';
        }
        field(43; LayerType; Text[1])
        {
            Caption = 'LayerType';
        }
        field(44; LineID; Integer)
        {
            Caption = 'LineID';
        }
        field(45; LineNbr; Integer)
        {
            Caption = 'LineNbr';
        }
        field(46; LineRef; Text[5])
        {
            Caption = 'LineRef';
        }
        field(47; LotSerCntr; Integer)
        {
            Caption = 'LotSerCntr';
        }
        field(48; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(49; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(50; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(51; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(52; OrigBatNbr; Text[10])
        {
            Caption = 'OrigBatNbr';
        }
        field(53; OrigJrnlType; Text[3])
        {
            Caption = 'OrigJrnlType';
        }
        field(54; OrigLineRef; Text[5])
        {
            Caption = 'OrigLineRef';
        }
        field(55; OrigRefNbr; Text[10])
        {
            Caption = 'OrigRefNbr';
        }
        field(56; OvrhdAmt; Decimal)
        {
            Caption = 'OvrhdAmt';
        }
        field(57; OvrhdFlag; Integer)
        {
            Caption = 'OvrhdFlag';
        }
        field(58; PC_Flag; Text[1])
        {
            Caption = 'PC_Flag';
        }
        field(59; PC_ID; Text[20])
        {
            Caption = 'PC_ID';
        }
        field(60; PC_Status; Text[1])
        {
            Caption = 'PC_Status';
        }
        field(61; PerEnt; Text[6])
        {
            Caption = 'PerEnt';
        }
        field(62; PerPost; Text[6])
        {
            Caption = 'PerPost';
        }
        field(63; PoNbr; Text[10])
        {
            Caption = 'PoNbr';
        }
        field(64; PostingOption; Integer)
        {
            Caption = 'PostingOption';
        }
        field(65; ProjectID; Text[16])
        {
            Caption = 'ProjectID';
        }
        field(66; Qty; Decimal)
        {
            Caption = 'Qty';
        }
        field(67; QtyUnCosted; Decimal)
        {
            Caption = 'QtyUnCosted';
        }
        field(68; RcptDate; DateTime)
        {
            Caption = 'RcptDate';
        }
        field(69; RcptNbr; Text[15])
        {
            Caption = 'RcptNbr';
        }
        field(70; ReasonCd; Text[6])
        {
            Caption = 'ReasonCd';
        }
        field(71; RecordID; Integer)
        {
            Caption = 'RecordID';
        }
        field(72; RefNbr; Text[15])
        {
            Caption = 'RefNbr';
        }
        field(73; Retired; Integer)
        {
            Caption = 'Retired';
        }
        field(74; Rlsed; Integer)
        {
            Caption = 'Rlsed';
        }
        field(75; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(76; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(77; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(78; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(79; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(80; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(81; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(82; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(83; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(84; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(85; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(86; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(87; ServiceCallID; Text[10])
        {
            Caption = 'ServiceCallID';
        }
        field(88; ShipperCpnyID; Text[10])
        {
            Caption = 'ShipperCpnyID';
        }
        field(89; ShipperID; Text[15])
        {
            Caption = 'ShipperID';
        }
        field(90; ShipperLineRef; Text[5])
        {
            Caption = 'ShipperLineRef';
        }
        field(91; ShortQty; Decimal)
        {
            Caption = 'ShortQty';
        }
        field(92; SiteID; Text[10])
        {
            Caption = 'SiteID';
        }
        field(93; SlsperID; Text[10])
        {
            Caption = 'SlsperID';
        }
        field(94; SpecificCostID; Text[25])
        {
            Caption = 'SpecificCostID';
        }
        field(95; SrcDate; DateTime)
        {
            Caption = 'SrcDate';
        }
        field(96; SrcLineRef; Text[5])
        {
            Caption = 'SrcLineRef';
        }
        field(97; SrcNbr; Text[15])
        {
            Caption = 'SrcNbr';
        }
        field(98; SrcType; Text[3])
        {
            Caption = 'SrcType';
        }
        field(99; StdTotalQty; Decimal)
        {
            Caption = 'StdTotalQty';
        }
        field(100; Sub; Text[24])
        {
            Caption = 'Sub';
        }
        field(101; SvcContractID; Text[10])
        {
            Caption = 'SvcContractID';
        }
        field(102; SvcLineNbr; Integer)
        {
            Caption = 'SvcLineNbr';
        }
        field(103; TaskID; Text[32])
        {
            Caption = 'TaskID';
        }
        field(104; ToSiteID; Text[10])
        {
            Caption = 'ToSiteID';
        }
        field(105; ToWhseLoc; Text[10])
        {
            Caption = 'ToWhseLoc';
        }
        field(106; TranAmt; Decimal)
        {
            Caption = 'TranAmt';
        }
        field(107; TranDate; DateTime)
        {
            Caption = 'TranDate';
        }
        field(108; TranDesc; Text[30])
        {
            Caption = 'TranDesc';
        }
        field(109; TranType; Text[2])
        {
            Caption = 'TranType';
        }
        field(110; UnitCost; Decimal)
        {
            Caption = 'UnitCost';
        }
        field(111; UnitDesc; Text[6])
        {
            Caption = 'UnitDesc';
        }
        field(112; UnitMultDiv; Text[1])
        {
            Caption = 'UnitMultDiv';
        }
        field(113; UnitPrice; Decimal)
        {
            Caption = 'UnitPrice';
        }
        field(114; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(115; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(116; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(117; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(118; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(119; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(120; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(121; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(122; UseTranCost; Integer)
        {
            Caption = 'UseTranCost';
        }
        field(123; WhseLoc; Text[10])
        {
            Caption = 'WhseLoc';
        }
    }

    keys
    {
        key(PK; InvtID, SiteID, CpnyID, RecordID)
        {
            Clustered = true;
        }
    }
}