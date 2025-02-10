// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

table 42810 "SL Hist. POTran"
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
        field(3; AddlCost; Decimal)
        {
            Caption = 'AddlCost';
        }
        field(4; AddlCostPct; Decimal)
        {
            Caption = 'AddlCostPct';
        }
        field(5; AddlCostVouch; Decimal)
        {
            Caption = 'AddlCostVouch';
        }
        field(6; AlternateID; Text[30])
        {
            Caption = 'AlternateID';
        }
        field(7; AltIDType; Text[1])
        {
            Caption = 'AltIDType';
        }
        field(8; APLineID; Integer)
        {
            Caption = 'APLineID';
        }
        field(9; APLineRef; Text[5])
        {
            Caption = 'APLineRef';
        }
        field(10; BatNbr; Text[10])
        {
            Caption = 'BatNbr';
        }
        field(11; BMICuryID; Text[4])
        {
            Caption = 'BMICuryID';
        }
        field(12; BMIEffDate; DateTime)
        {
            Caption = 'BMIEffDate';
        }
        field(13; BMIExtCost; Decimal)
        {
            Caption = 'BMIExtCost';
        }
        field(14; BMIMultDiv; Text[1])
        {
            Caption = 'BMIMultDiv';
        }
        field(15; BMIRate; Decimal)
        {
            Caption = 'BMIRate';
        }
        field(16; BMIRtTp; Text[6])
        {
            Caption = 'BMIRtTp';
        }
        field(17; BMITranAmt; Decimal)
        {
            Caption = 'BMITranAmt';
        }
        field(18; BMIUnitCost; Decimal)
        {
            Caption = 'BMIUnitCost';
        }
        field(19; BMIUnitPrice; Decimal)
        {
            Caption = 'BMIUnitPrice';
        }
        field(20; BOMLineRef; Text[5])
        {
            Caption = 'BOMLineRef';
        }
        field(21; BOMSequence; Integer)
        {
            Caption = 'BOMSequence';
        }
        field(22; CnvFact; Decimal)
        {
            Caption = 'CnvFact';
        }
        field(23; CostVouched; Decimal)
        {
            Caption = 'CostVouched';
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
        field(28; CuryAddlCost; Decimal)
        {
            Caption = 'CuryAddlCost';
        }
        field(29; CuryAddlCostVouch; Decimal)
        {
            Caption = 'CuryAddlCostVouch';
        }
        field(30; CuryCostVouched; Decimal)
        {
            Caption = 'CuryCostVouched';
        }
        field(31; CuryExtCost; Decimal)
        {
            Caption = 'CuryExtCost';
        }
        field(32; CuryID; Text[4])
        {
            Caption = 'CuryID';
        }
        field(33; CuryMultDiv; Text[1])
        {
            Caption = 'CuryMultDiv';
        }
        field(34; CuryRate; Decimal)
        {
            Caption = 'CuryRate';
        }
        field(35; CuryTranAmt; Decimal)
        {
            Caption = 'CuryTranAmt';
        }
        field(36; CuryUnitCost; Decimal)
        {
            Caption = 'CuryUnitCost';
        }
        field(37; DrCr; Text[1])
        {
            Caption = 'DrCr';
        }
        field(38; ExtCost; Decimal)
        {
            Caption = 'ExtCost';
        }
        field(39; ExtWeight; Decimal)
        {
            Caption = 'ExtWeight';
        }
        field(40; FlatRateLineNbr; Integer)
        {
            Caption = 'FlatRateLineNbr';
        }
        field(41; InvtID; Text[30])
        {
            Caption = 'InvtID';
        }
        field(42; JrnlType; Text[3])
        {
            Caption = 'JrnlType';
        }
        field(43; Labor_Class_Cd; Text[4])
        {
            Caption = 'Labor_Class_Cd';
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
        field(47; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(48; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(49; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(50; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(51; OrigRcptDate; DateTime)
        {
            Caption = 'OrigRcptDate';
        }
        field(52; OrigRcptNbr; Text[10])
        {
            Caption = 'OrigRcptNbr';
        }
        field(53; OrigRetRcptNbr; Text[10])
        {
            Caption = 'OrigRetRcptNbr';
        }
        field(54; PC_Flag; Text[1])
        {
            Caption = 'PC_Flag';
        }
        field(55; PC_ID; Text[20])
        {
            Caption = 'PC_ID';
        }
        field(56; PC_Status; Text[1])
        {
            Caption = 'PC_Status';
        }
        field(57; PerEnt; Text[6])
        {
            Caption = 'PerEnt';
        }
        field(58; PerPost; Text[6])
        {
            Caption = 'PerPost';
        }
        field(59; POLineID; Integer)
        {
            Caption = 'POLineID';
        }
        field(60; POLineNbr; Integer)
        {
            Caption = 'POLineNbr';
        }
        field(61; POLIneRef; Text[5])
        {
            Caption = 'POLIneRef';
        }
        field(62; PONbr; Text[10])
        {
            Caption = 'PONbr';
        }
        field(63; POOriginal; Text[1])
        {
            Caption = 'POOriginal';
        }
        field(64; ProjectID; Text[16])
        {
            Caption = 'ProjectID';
        }
        field(65; PurchaseType; Text[2])
        {
            Caption = 'PurchaseType';
        }
        field(66; Qty; Decimal)
        {
            Caption = 'Qty';
        }
        field(67; QtyVouched; Decimal)
        {
            Caption = 'QtyVouched';
        }
        field(68; RcptConvFact; Decimal)
        {
            Caption = 'RcptConvFact';
        }
        field(69; RcptDate; DateTime)
        {
            Caption = 'RcptDate';
        }
        field(70; RcptLineRefOrig; Text[5])
        {
            Caption = 'RcptLineRefOrig';
        }
        field(71; RcptMultDiv; Text[1])
        {
            Caption = 'RcptMultDiv';
        }
        field(72; RcptNbr; Text[10])
        {
            Caption = 'RcptNbr';
        }
        field(73; RcptNbrOrig; Text[10])
        {
            Caption = 'RcptNbrOrig';
        }
        field(74; RcptQty; Decimal)
        {
            Caption = 'RcptQty';
        }
        field(75; RcptUnitDescr; Text[6])
        {
            Caption = 'RcptUnitDescr';
        }
        field(76; ReasonCd; Text[6])
        {
            Caption = 'ReasonCd';
        }
        field(77; Refnbr; Text[10])
        {
            Caption = 'Refnbr';
        }
        field(78; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(79; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(80; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(81; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(82; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(83; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(84; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(85; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(86; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(87; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(88; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(89; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(90; ServiceCallID; Text[10])
        {
            Caption = 'ServiceCallID';
        }
        field(91; SiteID; Text[10])
        {
            Caption = 'SiteID';
        }
        field(92; SOLineID; Integer)
        {
            Caption = 'SOLineID';
        }
        field(93; SOLineRef; Text[5])
        {
            Caption = 'SOLineRef';
        }
        field(94; SOOrdNbr; Text[15])
        {
            Caption = 'SOOrdNbr';
        }
        field(95; SOTypeID; Text[4])
        {
            Caption = 'SOTypeID';
        }
        field(96; SpecificCostID; Text[25])
        {
            Caption = 'SpecificCostID';
        }
        field(97; StepNbr; Integer)
        {
            Caption = 'StepNbr';
        }
        field(98; Sub; Text[24])
        {
            Caption = 'Sub';
        }
        field(99; SvcContractID; Text[10])
        {
            Caption = 'SvcContractID';
        }
        field(100; SvcLineNbr; Integer)
        {
            Caption = 'SvcLineNbr';
        }
        field(101; TaskID; Text[32])
        {
            Caption = 'TaskID';
        }
        field(102; TaxCat; Text[10])
        {
            Caption = 'TaxCat';
        }
        field(103; TaxIDDflt; Text[10])
        {
            Caption = 'TaxIDDflt';
        }
        field(104; TranAmt; Decimal)
        {
            Caption = 'TranAmt';
        }
        field(105; TranDate; DateTime)
        {
            Caption = 'TranDate';
        }
        field(106; TranDesc; Text[60])
        {
            Caption = 'TranDesc';
        }
        field(107; TranType; Text[2])
        {
            Caption = 'TranType';
        }
        field(108; UnitCost; Decimal)
        {
            Caption = 'UnitCost';
        }
        field(109; UnitDescr; Text[6])
        {
            Caption = 'UnitDescr';
        }
        field(110; UnitMultDiv; Text[1])
        {
            Caption = 'UnitMultDiv';
        }
        field(111; UnitWeight; Decimal)
        {
            Caption = 'UnitWeight';
        }
        field(112; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(113; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(114; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(115; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(116; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(117; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(118; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(119; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(120; VendId; Text[15])
        {
            Caption = 'VendId';
        }
        field(121; VouchStage; Text[1])
        {
            Caption = 'VouchStage';
        }
        field(122; WhseLoc; Text[10])
        {
            Caption = 'WhseLoc';
        }
        field(123; WIP_COGS_Acct; Text[10])
        {
            Caption = 'WIP_COGS_Acct';
        }
        field(124; WIP_COGS_Sub; Text[24])
        {
            Caption = 'WIP_COGS_Sub';
        }
        field(125; WOBomRef; Text[5])
        {
            Caption = 'WOBomRef';
        }
        field(126; WOCostType; Text[2])
        {
            Caption = 'WOCostType';
        }
        field(127; WONbr; Text[10])
        {
            Caption = 'WONbr';
        }
        field(128; WOStepNbr; Text[5])
        {
            Caption = 'WOStepNbr';
        }
    }

    keys
    {
        key(PK; RcptNbr, LineRef)
        {
            Clustered = true;
        }
    }
}