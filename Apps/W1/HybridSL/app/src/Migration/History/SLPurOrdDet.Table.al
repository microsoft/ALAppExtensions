// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47031 "SL PurOrdDet"
{
    Access = Internal;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; AddlCostPct; Decimal)
        {
            Caption = 'AddlCostPct';
            AutoFormatType = 0;
        }
        field(2; AllocCntr; Integer)
        {
            Caption = 'AllocCntr';
        }
        field(3; AlternateID; Text[30])
        {
            Caption = 'AlternateID';
        }
        field(4; AltIDType; Text[1])
        {
            Caption = 'AltIDType';
        }
        field(5; BlktLineID; Integer)
        {
            Caption = 'BlktLineID';
        }
        field(6; BlktLineRef; Text[5])
        {
            Caption = 'BlktLineRef';
        }
        field(7; Buyer; Text[10])
        {
            Caption = 'Buyer';
        }
        field(8; CnvFact; Decimal)
        {
            Caption = 'CnvFact';
            AutoFormatType = 0;
        }
        field(9; CostReceived; Decimal)
        {
            Caption = 'CostReceived';
            AutoFormatType = 0;
        }
        field(10; CostReturned; Decimal)
        {
            Caption = 'CostReturned';
            AutoFormatType = 0;
        }
        field(11; CostVouched; Decimal)
        {
            Caption = 'CostVouched';
            AutoFormatType = 0;
        }
        field(12; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(13; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(14; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(15; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(16; CuryCostReceived; Decimal)
        {
            Caption = 'CuryCostReceived';
            AutoFormatType = 0;
        }
        field(17; CuryCostReturned; Decimal)
        {
            Caption = 'CuryCostReturned';
            AutoFormatType = 0;
        }
        field(18; CuryCostVouched; Decimal)
        {
            Caption = 'CuryCostVouched';
            AutoFormatType = 0;
        }
        field(19; CuryExtCost; Decimal)
        {
            Caption = 'CuryExtCost';
            AutoFormatType = 0;
        }
        field(20; CuryID; Text[4])
        {
            Caption = 'CuryID';
        }
        field(21; CuryMultDiv; Text[1])
        {
            Caption = 'CuryMultDiv';
        }
        field(22; CuryRate; Decimal)
        {
            Caption = 'CuryRate';
            AutoFormatType = 0;
        }
        field(23; CuryTaxAmt00; Decimal)
        {
            Caption = 'CuryTaxAmt00';
            AutoFormatType = 0;
        }
        field(24; CuryTaxAmt01; Decimal)
        {
            Caption = 'CuryTaxAmt01';
            AutoFormatType = 0;
        }
        field(25; CuryTaxAmt02; Decimal)
        {
            Caption = 'CuryTaxAmt02';
            AutoFormatType = 0;
        }
        field(26; CuryTaxAmt03; Decimal)
        {
            Caption = 'CuryTaxAmt03';
            AutoFormatType = 0;
        }
        field(27; CuryTxblAmt00; Decimal)
        {
            Caption = 'CuryTxblAmt00';
            AutoFormatType = 0;
        }
        field(28; CuryTxblAmt01; Decimal)
        {
            Caption = 'CuryTxblAmt01';
            AutoFormatType = 0;
        }
        field(29; CuryTxblAmt02; Decimal)
        {
            Caption = 'CuryTxblAmt02';
            AutoFormatType = 0;
        }
        field(30; CuryTxblAmt03; Decimal)
        {
            Caption = 'CuryTxblAmt03';
            AutoFormatType = 0;
        }
        field(31; CuryUnitCost; Decimal)
        {
            Caption = 'CuryUnitCost';
            AutoFormatType = 0;
        }
        field(32; ExtCost; Decimal)
        {
            Caption = 'ExtCost';
            AutoFormatType = 0;
        }
        field(33; ExtWeight; Decimal)
        {
            Caption = 'ExtWeight';
            AutoFormatType = 0;
        }
        field(34; FlatRateLineNbr; Integer)
        {
            Caption = 'FlatRateLineNbr';
        }
        field(35; InclForecastUsageClc; Integer)
        {
            Caption = 'InclForecastUsageClc';
        }
        field(36; InvtID; Text[30])
        {
            Caption = 'InvtID';
        }
        field(37; IRIncLeadTime; Integer)
        {
            Caption = 'IRIncLeadTime';
        }
        field(38; KitUnExpld; Integer)
        {
            Caption = 'KitUnExpld';
        }
        field(39; Labor_Class_Cd; Text[4])
        {
            Caption = 'Labor_Class_Cd';
        }
        field(40; LineID; Integer)
        {
            Caption = 'LineID';
        }
        field(41; LineNbr; Integer)
        {
            Caption = 'LineNbr';
        }
        field(42; LineRef; Text[5])
        {
            Caption = 'LineRef';
        }
        field(43; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(44; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(45; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(46; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(47; OpenLine; Integer)
        {
            Caption = 'OpenLine';
        }
        field(48; OrigPOLine; Integer)
        {
            Caption = 'OrigPOLine';
        }
        field(49; PC_Flag; Text[1])
        {
            Caption = 'PC_Flag';
        }
        field(50; PC_ID; Text[20])
        {
            Caption = 'PC_ID';
        }
        field(51; PC_Status; Text[1])
        {
            Caption = 'PC_Status';
        }
        field(52; PONbr; Text[10])
        {
            Caption = 'PONbr';
        }
        field(53; POType; Text[2])
        {
            Caption = 'POType';
        }
        field(54; ProjectID; Text[16])
        {
            Caption = 'ProjectID';
        }
        field(55; PromDate; DateTime)
        {
            Caption = 'PromDate';
        }
        field(56; PurAcct; Text[10])
        {
            Caption = 'PurAcct';
        }
        field(57; PurchaseType; Text[2])
        {
            Caption = 'PurchaseType';
        }
        field(58; PurchUnit; Text[6])
        {
            Caption = 'PurchUnit';
        }
        field(59; PurSub; Text[24])
        {
            Caption = 'PurSub';
        }
        field(60; QtyOrd; Decimal)
        {
            Caption = 'QtyOrd';
            AutoFormatType = 0;
        }
        field(61; QtyRcvd; Decimal)
        {
            Caption = 'QtyRcvd';
            AutoFormatType = 0;
        }
        field(62; QtyReturned; Decimal)
        {
            Caption = 'QtyReturned';
            AutoFormatType = 0;
        }
        field(63; QtyVouched; Decimal)
        {
            Caption = 'QtyVouched';
            AutoFormatType = 0;
        }
        field(64; RcptPctAct; Text[1])
        {
            Caption = 'RcptPctAct';
        }
        field(65; RcptPctMax; Decimal)
        {
            Caption = 'RcptPctMax';
            AutoFormatType = 0;
        }
        field(66; RcptPctMin; Decimal)
        {
            Caption = 'RcptPctMin';
            AutoFormatType = 0;
        }
        field(67; RcptStage; Text[1])
        {
            Caption = 'RcptStage';
        }
        field(68; ReasonCd; Text[6])
        {
            Caption = 'ReasonCd';
        }
        field(69; RefNbr; Text[10])
        {
            Caption = 'RefNbr';
        }
        field(70; ReqdDate; DateTime)
        {
            Caption = 'ReqdDate';
        }
        field(71; ReqNbr; Text[10])
        {
            Caption = 'ReqNbr';
        }
        field(72; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(73; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(74; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
            AutoFormatType = 0;
        }
        field(75; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
            AutoFormatType = 0;
        }
        field(76; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
            AutoFormatType = 0;
        }
        field(77; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
            AutoFormatType = 0;
        }
        field(78; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(79; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(80; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(81; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(82; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(83; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(84; ServiceCallID; Text[10])
        {
            Caption = 'ServiceCallID';
        }
        field(85; ShelfLife; Integer)
        {
            Caption = 'ShelfLife';
        }
        field(86; ShipAddr1; Text[60])
        {
            Caption = 'ShipAddr1';
        }
        field(87; ShipAddr2; Text[60])
        {
            Caption = 'ShipAddr2';
        }
        field(88; ShipAddrID; Text[10])
        {
            Caption = 'ShipAddrID';
        }
        field(89; ShipCity; Text[30])
        {
            Caption = 'ShipCity';
        }
        field(90; ShipCountry; Text[3])
        {
            Caption = 'ShipCountry';
        }
        field(91; ShipName; Text[60])
        {
            Caption = 'ShipName';
        }
        field(92; ShipState; Text[3])
        {
            Caption = 'ShipState';
        }
        field(93; ShipViaID; Text[15])
        {
            Caption = 'ShipViaID';
        }
        field(94; ShipZip; Text[10])
        {
            Caption = 'ShipZip';
        }
        field(95; SiteID; Text[10])
        {
            Caption = 'SiteID';
        }
        field(96; SOLineRef; Text[5])
        {
            Caption = 'SOLineRef';
        }
        field(97; SOOrdNbr; Text[15])
        {
            Caption = 'SOOrdNbr';
        }
        field(98; SOSchedRef; Text[5])
        {
            Caption = 'SOSchedRef';
        }
        field(99; StepNbr; Integer)
        {
            Caption = 'StepNbr';
        }
        field(100; SvcContractID; Text[10])
        {
            Caption = 'SvcContractID';
        }
        field(101; SvcLineNbr; Integer)
        {
            Caption = 'SvcLineNbr';
        }
        field(102; TaskID; Text[32])
        {
            Caption = 'TaskID';
        }
        field(103; TaxAmt00; Decimal)
        {
            Caption = 'TaxAmt00';
            AutoFormatType = 0;
        }
        field(104; TaxAmt01; Decimal)
        {
            Caption = 'TaxAmt01';
            AutoFormatType = 0;
        }
        field(105; TaxAmt02; Decimal)
        {
            Caption = 'TaxAmt02';
            AutoFormatType = 0;
        }
        field(106; TaxAmt03; Decimal)
        {
            Caption = 'TaxAmt03';
            AutoFormatType = 0;
        }
        field(107; TaxCalced; Text[1])
        {
            Caption = 'TaxCalced';
        }
        field(108; TaxCat; Text[10])
        {
            Caption = 'TaxCat';
        }
        field(109; TaxID00; Text[10])
        {
            Caption = 'TaxID00';
        }
        field(110; TaxID01; Text[10])
        {
            Caption = 'TaxID01';
        }
        field(111; TaxID02; Text[10])
        {
            Caption = 'TaxID02';
        }
        field(112; TaxID03; Text[10])
        {
            Caption = 'TaxID03';
        }
        field(113; TaxIdDflt; Text[10])
        {
            Caption = 'TaxIdDflt';
        }
        field(114; TranDesc; Text[60])
        {
            Caption = 'TranDesc';
        }
        field(115; TxblAmt00; Decimal)
        {
            Caption = 'TxblAmt00';
            AutoFormatType = 0;
        }
        field(116; TxblAmt01; Decimal)
        {
            Caption = 'TxblAmt01';
            AutoFormatType = 0;
        }
        field(117; TxblAmt02; Decimal)
        {
            Caption = 'TxblAmt02';
            AutoFormatType = 0;
        }
        field(118; TxblAmt03; Decimal)
        {
            Caption = 'TxblAmt03';
            AutoFormatType = 0;
        }
        field(119; UnitCost; Decimal)
        {
            Caption = 'UnitCost';
            AutoFormatType = 0;
        }
        field(120; UnitMultDiv; Text[1])
        {
            Caption = 'UnitMultDiv';
        }
        field(121; UnitWeight; Decimal)
        {
            Caption = 'UnitWeight';
            AutoFormatType = 0;
        }
        field(122; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(123; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(124; User3; Decimal)
        {
            Caption = 'User3';
            AutoFormatType = 0;
        }
        field(125; User4; Decimal)
        {
            Caption = 'User4';
            AutoFormatType = 0;
        }
        field(126; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(127; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(128; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(129; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(130; VouchStage; Text[1])
        {
            Caption = 'VouchStage';
        }
        field(131; WIP_COGS_Acct; Text[10])
        {
            Caption = 'WIP_COGS_Acct';
        }
        field(132; WIP_COGS_Sub; Text[24])
        {
            Caption = 'WIP_COGS_Sub';
        }
        field(133; WOBOMSeq; Integer)
        {
            Caption = 'WOBOMSeq';
        }
        field(134; WOCostType; Text[2])
        {
            Caption = 'WOCostType';
        }
        field(135; WONbr; Text[10])
        {
            Caption = 'WONbr';
        }
        field(136; WOStepNbr; Integer)
        {
            Caption = 'WOStepNbr';
        }
    }

    keys
    {
        key(Key1; PONbr, LineRef)
        {
            Clustered = true;
        }
    }
}