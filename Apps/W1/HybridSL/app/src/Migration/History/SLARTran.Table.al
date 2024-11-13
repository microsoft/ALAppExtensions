// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47025 "SL ARTran"
{
    Access = Internal;
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
        field(3; BatNbr; Text[10])
        {
            Caption = 'BatNbr';
        }
        field(4; CmmnPct; Decimal)
        {
            Caption = 'CmmnPct';
        }
        field(5; CnvFact; Decimal)
        {
            Caption = 'CnvFact';
        }
        field(6; ContractID; Text[10])
        {
            Caption = 'ContractID';
        }
        field(7; CostType; Text[8])
        {
            Caption = 'CostType';
        }
        field(8; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(9; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(10; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(11; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(12; CuryExtCost; Decimal)
        {
            Caption = 'CuryExtCost';
        }
        field(13; CuryId; Text[4])
        {
            Caption = 'CuryId';
        }
        field(14; CuryMultDiv; Text[1])
        {
            Caption = 'CuryMultDiv';
        }
        field(15; CuryRate; Decimal)
        {
            Caption = 'CuryRate';
        }
        field(16; CuryTaxAmt00; Decimal)
        {
            Caption = 'CuryTaxAmt00';
        }
        field(17; CuryTaxAmt01; Decimal)
        {
            Caption = 'CuryTaxAmt01';
        }
        field(18; CuryTaxAmt02; Decimal)
        {
            Caption = 'CuryTaxAmt02';
        }
        field(19; CuryTaxAmt03; Decimal)
        {
            Caption = 'CuryTaxAmt03';
        }
        field(20; CuryTranAmt; Decimal)
        {
            Caption = 'CuryTranAmt';
        }
        field(21; CuryTxblAmt00; Decimal)
        {
            Caption = 'CuryTxblAmt00';
        }
        field(22; CuryTxblAmt01; Decimal)
        {
            Caption = 'CuryTxblAmt01';
        }
        field(23; CuryTxblAmt02; Decimal)
        {
            Caption = 'CuryTxblAmt02';
        }
        field(24; CuryTxblAmt03; Decimal)
        {
            Caption = 'CuryTxblAmt03';
        }
        field(25; CuryUnitPrice; Decimal)
        {
            Caption = 'CuryUnitPrice';
        }
        field(26; CustId; Text[15])
        {
            Caption = 'CustId';
        }
        field(27; DrCr; Text[1])
        {
            Caption = 'DrCr';
        }
        field(28; Excpt; Integer)
        {
            Caption = 'Excpt';
        }
        field(29; ExtCost; Decimal)
        {
            Caption = 'ExtCost';
        }
        field(30; ExtRefNbr; Text[15])
        {
            Caption = 'ExtRefNbr';
        }
        field(31; FiscYr; Text[4])
        {
            Caption = 'FiscYr';
        }
        field(32; FlatRateLineNbr; Integer)
        {
            Caption = 'FlatRateLineNbr';
        }
        field(33; InstallNbr; Integer)
        {
            Caption = 'InstallNbr';
        }
        field(34; InvtId; Text[30])
        {
            Caption = 'InvtId';
        }
        field(35; JobRate; Decimal)
        {
            Caption = 'JobRate';
        }
        field(36; JrnlType; Text[3])
        {
            Caption = 'JrnlType';
        }
        field(37; LineId; Integer)
        {
            Caption = 'LineId';
        }
        field(38; LineNbr; Integer)
        {
            Caption = 'LineNbr';
        }
        field(39; LineRef; Text[5])
        {
            Caption = 'LineRef';
        }
        field(40; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(41; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(42; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(43; MasterDocNbr; Text[10])
        {
            Caption = 'MasterDocNbr';
        }
        field(44; NoteId; Integer)
        {
            Caption = 'NoteId';
        }
        field(45; OrdNbr; Text[15])
        {
            Caption = 'OrdNbr';
        }
        field(46; PC_Flag; Text[1])
        {
            Caption = 'PC_Flag';
        }
        field(47; PC_ID; Text[20])
        {
            Caption = 'PC_ID';
        }
        field(48; PC_Status; Text[1])
        {
            Caption = 'PC_Status';
        }
        field(49; PerEnt; Text[6])
        {
            Caption = 'PerEnt';
        }
        field(50; PerPost; Text[6])
        {
            Caption = 'PerPost';
        }
        field(51; ProjectID; Text[16])
        {
            Caption = 'ProjectID';
        }
        field(52; Qty; Decimal)
        {
            Caption = 'Qty';
        }
        field(53; "RecordID"; Integer)
        {
            Caption = 'RecordID';
        }
        field(54; RefNbr; Text[10])
        {
            Caption = 'RefNbr';
        }
        field(55; Rlsed; Integer)
        {
            Caption = 'Rlsed';
        }
        field(56; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(57; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(58; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(59; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(60; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(61; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(62; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(63; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(64; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(65; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(66; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(67; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(68; ServiceCallID; Text[10])
        {
            Caption = 'ServiceCallID';
        }
        field(69; ServiceCallLineNbr; Integer)
        {
            Caption = 'ServiceCallLineNbr';
        }
        field(70; ServiceDate; DateTime)
        {
            Caption = 'ServiceDate';
        }
        field(71; ShipperCpnyID; Text[10])
        {
            Caption = 'ShipperCpnyID';
        }
        field(72; ShipperID; Text[15])
        {
            Caption = 'ShipperID';
        }
        field(73; ShipperLineRef; Text[5])
        {
            Caption = 'ShipperLineRef';
        }
        field(74; SiteId; Text[10])
        {
            Caption = 'SiteId';
        }
        field(75; SlsperId; Text[10])
        {
            Caption = 'SlsperId';
        }
        field(76; SpecificCostID; Text[25])
        {
            Caption = 'SpecificCostID';
        }
        field(77; Sub; Text[24])
        {
            Caption = 'Sub';
        }
        field(78; TaskID; Text[32])
        {
            Caption = 'TaskID';
        }
        field(79; TaxAmt00; Decimal)
        {
            Caption = 'TaxAmt00';
        }
        field(80; TaxAmt01; Decimal)
        {
            Caption = 'TaxAmt01';
        }
        field(81; TaxAmt02; Decimal)
        {
            Caption = 'TaxAmt02';
        }
        field(82; TaxAmt03; Decimal)
        {
            Caption = 'TaxAmt03';
        }
        field(83; TaxCalced; Text[1])
        {
            Caption = 'TaxCalced';
        }
        field(84; TaxCat; Text[10])
        {
            Caption = 'TaxCat';
        }
        field(85; TaxId00; Text[10])
        {
            Caption = 'TaxId00';
        }
        field(86; TaxId01; Text[10])
        {
            Caption = 'TaxId01';
        }
        field(87; TaxId02; Text[10])
        {
            Caption = 'TaxId02';
        }
        field(88; TaxId03; Text[10])
        {
            Caption = 'TaxId03';
        }
        field(89; TaxIdDflt; Text[10])
        {
            Caption = 'TaxIdDflt';
        }
        field(90; TranAmt; Decimal)
        {
            Caption = 'TranAmt';
        }
        field(91; TranClass; Text[1])
        {
            Caption = 'TranClass';
        }
        field(92; TranDate; DateTime)
        {
            Caption = 'TranDate';
        }
        field(93; TranDesc; Text[30])
        {
            Caption = 'TranDesc';
        }
        field(94; TranType; Text[2])
        {
            Caption = 'TranType';
        }
        field(95; TxblAmt00; Decimal)
        {
            Caption = 'TxblAmt00';
        }
        field(96; TxblAmt01; Decimal)
        {
            Caption = 'TxblAmt01';
        }
        field(97; TxblAmt02; Decimal)
        {
            Caption = 'TxblAmt02';
        }
        field(98; TxblAmt03; Decimal)
        {
            Caption = 'TxblAmt03';
        }
        field(99; UnitDesc; Text[6])
        {
            Caption = 'UnitDesc';
        }
        field(100; UnitPrice; Decimal)
        {
            Caption = 'UnitPrice';
        }
        field(101; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(102; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(103; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(104; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(105; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(106; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(107; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(108; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(109; WhseLoc; Text[10])
        {
            Caption = 'WhseLoc';
        }
    }

    keys
    {
        key(Key1; CustId, TranType, RefNbr, LineNbr, RecordID)
        {
            Clustered = true;
        }
    }
}