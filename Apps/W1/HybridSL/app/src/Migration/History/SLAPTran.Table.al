// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47022 "SL APTran"
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
        field(3; AlternateID; Text[30])
        {
            Caption = 'AlternateID';
        }
        field(4; Applied_PPRefNbr; Text[10])
        {
            Caption = 'Applied_PPRefNbr';
        }
        field(5; BatNbr; Text[10])
        {
            Caption = 'BatNbr';
        }
        field(6; BOMLineRef; Text[5])
        {
            Caption = 'BOMLineRef';
        }
        field(7; BoxNbr; Text[2])
        {
            Caption = 'BoxNbr';
        }
        field(8; Component; Text[30])
        {
            Caption = 'Component';
        }
        field(9; CostType; Text[8])
        {
            Caption = 'CostType';
        }
        field(10; CostTypeWO; Text[2])
        {
            Caption = 'CostTypeWO';
        }
        field(11; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(12; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(13; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(14; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(15; CuryId; Text[4])
        {
            Caption = 'CuryId';
        }
        field(16; CuryMultDiv; Text[1])
        {
            Caption = 'CuryMultDiv';
        }
        field(17; CuryPOExtPrice; Decimal)
        {
            Caption = 'CuryPOExtPrice';
        }
        field(18; CuryPOUnitPrice; Decimal)
        {
            Caption = 'CuryPOUnitPrice';
        }
        field(19; CuryPPV; Decimal)
        {
            Caption = 'CuryPPV';
        }
        field(20; CuryRate; Decimal)
        {
            Caption = 'CuryRate';
        }
        field(21; CuryTaxAmt00; Decimal)
        {
            Caption = 'CuryTaxAmt00';
        }
        field(22; CuryTaxAmt01; Decimal)
        {
            Caption = 'CuryTaxAmt01';
        }
        field(23; CuryTaxAmt02; Decimal)
        {
            Caption = 'CuryTaxAmt02';
        }
        field(24; CuryTaxAmt03; Decimal)
        {
            Caption = 'CuryTaxAmt03';
        }
        field(25; CuryTranAmt; Decimal)
        {
            Caption = 'CuryTranAmt';
        }
        field(26; CuryTxblAmt00; Decimal)
        {
            Caption = 'CuryTxblAmt00';
        }
        field(27; CuryTxblAmt01; Decimal)
        {
            Caption = 'CuryTxblAmt01';
        }
        field(28; CuryTxblAmt02; Decimal)
        {
            Caption = 'CuryTxblAmt02';
        }
        field(29; CuryTxblAmt03; Decimal)
        {
            Caption = 'CuryTxblAmt03';
        }
        field(30; CuryUnitPrice; Decimal)
        {
            Caption = 'CuryUnitPrice';
        }
        field(31; DrCr; Text[1])
        {
            Caption = 'DrCr';
        }
        field(32; Employee; Text[10])
        {
            Caption = 'Employee';
        }
        field(33; EmployeeID; Text[10])
        {
            Caption = 'EmployeeID';
        }
        field(34; Excpt; Integer)
        {
            Caption = 'Excpt';
        }
        field(35; ExtRefNbr; Text[15])
        {
            Caption = 'ExtRefNbr';
        }
        field(36; FiscYr; Text[4])
        {
            Caption = 'FiscYr';
        }
        field(37; InstallNbr; Integer)
        {
            Caption = 'InstallNbr';
        }
        field(38; InvcTypeID; Text[10])
        {
            Caption = 'InvcTypeID';
        }
        field(39; InvtID; Text[30])
        {
            Caption = 'InvtID';
        }
        field(40; JobRate; Decimal)
        {
            Caption = 'JobRate';
        }
        field(41; JrnlType; Text[3])
        {
            Caption = 'JrnlType';
        }
        field(42; Labor_Class_Cd; Text[4])
        {
            Caption = 'Labor_Class_Cd';
        }
        field(43; LCCode; Text[10])
        {
            Caption = 'LCCode';
        }
        field(44; LineId; Integer)
        {
            Caption = 'LineId';
        }
        field(45; LineNbr; Integer)
        {
            Caption = 'LineNbr';
        }
        field(46; LineRef; Text[5])
        {
            Caption = 'LineRef';
        }
        field(47; LineType; Text[1])
        {
            Caption = 'LineType';
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
        field(51; MasterDocNbr; Text[10])
        {
            Caption = 'MasterDocNbr';
        }
        field(52; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(53; PC_Flag; Text[1])
        {
            Caption = 'PC_Flag';
        }
        field(54; PC_ID; Text[20])
        {
            Caption = 'PC_ID';
        }
        field(55; PC_Status; Text[1])
        {
            Caption = 'PC_Status';
        }
        field(56; PerEnt; Text[6])
        {
            Caption = 'PerEnt';
        }
        field(57; PerPost; Text[6])
        {
            Caption = 'PerPost';
        }
        field(58; PmtMethod; Text[1])
        {
            Caption = 'PmtMethod';
        }
        field(59; POExtPrice; Decimal)
        {
            Caption = 'POExtPrice';
        }
        field(60; POLineRef; Text[5])
        {
            Caption = 'POLineRef';
        }
        field(61; PONbr; Text[10])
        {
            Caption = 'PONbr';
        }
        field(62; POQty; Decimal)
        {
            Caption = 'POQty';
        }
        field(63; POUnitPrice; Decimal)
        {
            Caption = 'POUnitPrice';
        }
        field(64; PPV; Decimal)
        {
            Caption = 'PPV';
        }
        field(65; ProjectID; Text[16])
        {
            Caption = 'ProjectID';
        }
        field(66; Qty; Decimal)
        {
            Caption = 'Qty';
        }
        field(67; QtyVar; Decimal)
        {
            Caption = 'QtyVar';
        }
        field(68; RcptLineRef; Text[5])
        {
            Caption = 'RcptLineRef';
        }
        field(69; RcptNbr; Text[10])
        {
            Caption = 'RcptNbr';
        }
        field(70; RcptQty; Decimal)
        {
            Caption = 'RcptQty';
        }
        field(71; "RecordID"; Integer)
        {
            Caption = 'RecordID';
        }
        field(72; RefNbr; Text[10])
        {
            Caption = 'RefNbr';
        }
        field(73; Rlsed; Integer)
        {
            Caption = 'Rlsed';
        }
        field(74; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(75; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(76; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(77; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(78; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(79; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(80; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(81; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(82; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(83; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(84; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(85; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(86; ServiceDate; DateTime)
        {
            Caption = 'ServiceDate';
        }
        field(87; SiteId; Text[10])
        {
            Caption = 'SiteId';
        }
        field(88; SoLineRef; Text[5])
        {
            Caption = 'SoLineRef';
        }
        field(89; SOOrdNbr; Text[15])
        {
            Caption = 'SOOrdNbr';
        }
        field(90; SOTypeID; Text[4])
        {
            Caption = 'SOTypeID';
        }
        field(91; Sub; Text[24])
        {
            Caption = 'Sub';
        }
        field(92; TaskID; Text[32])
        {
            Caption = 'TaskID';
        }
        field(93; TaxAmt00; Decimal)
        {
            Caption = 'TaxAmt00';
        }
        field(94; TaxAmt01; Decimal)
        {
            Caption = 'TaxAmt01';
        }
        field(95; TaxAmt02; Decimal)
        {
            Caption = 'TaxAmt02';
        }
        field(96; TaxAmt03; Decimal)
        {
            Caption = 'TaxAmt03';
        }
        field(97; TaxCalced; Text[1])
        {
            Caption = 'TaxCalced';
        }
        field(98; TaxCat; Text[10])
        {
            Caption = 'TaxCat';
        }
        field(99; TaxId00; Text[10])
        {
            Caption = 'TaxId00';
        }
        field(100; TaxId01; Text[10])
        {
            Caption = 'TaxId01';
        }
        field(101; TaxId02; Text[10])
        {
            Caption = 'TaxId02';
        }
        field(102; TaxId03; Text[10])
        {
            Caption = 'TaxId03';
        }
        field(103; TaxIdDflt; Text[10])
        {
            Caption = 'TaxIdDflt';
        }
        field(104; TranAmt; Decimal)
        {
            Caption = 'TranAmt';
        }
        field(105; TranClass; Text[1])
        {
            Caption = 'TranClass';
        }
        field(106; TranDate; DateTime)
        {
            Caption = 'TranDate';
        }
        field(107; TranDesc; Text[30])
        {
            Caption = 'TranDesc';
        }
        field(108; trantype; Text[2])
        {
            Caption = 'trantype';
        }
        field(109; TxblAmt00; Decimal)
        {
            Caption = 'TxblAmt00';
        }
        field(110; TxblAmt01; Decimal)
        {
            Caption = 'TxblAmt01';
        }
        field(111; TxblAmt02; Decimal)
        {
            Caption = 'TxblAmt02';
        }
        field(112; TxblAmt03; Decimal)
        {
            Caption = 'TxblAmt03';
        }
        field(113; UnitDesc; Text[10])
        {
            Caption = 'UnitDesc';
        }
        field(114; UnitPrice; Decimal)
        {
            Caption = 'UnitPrice';
        }
        field(115; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(116; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(117; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(118; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(119; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(120; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(121; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(122; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(123; VendId; Text[15])
        {
            Caption = 'VendId';
        }
        field(124; WONbr; Text[10])
        {
            Caption = 'WONbr';
        }
        field(125; WOStepNbr; Text[5])
        {
            Caption = 'WOStepNbr';
        }
    }
    keys
    {
        key(Key1; BatNbr, Acct, Sub, RefNbr, RecordID)
        {
            Clustered = true;
        }
    }
}