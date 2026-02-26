// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47073 "SL APDoc Buffer"
{
    Access = Internal;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; Acct; Text[10])
        {
            Caption = 'Account Number';
        }
        field(2; AddlCost; Integer)
        {
            Caption = 'Additional Cost';
        }
        field(3; ApplyAmt; Decimal)
        {
            Caption = 'Apply Amount';
            AutoFormatType = 0;
        }
        field(4; ApplyDate; Date)
        {
            Caption = 'Apply Date';
        }
        field(5; ApplyRefNbr; Text[10])
        {
            Caption = 'Apply Ref Nbr';
        }
        field(6; BatNbr; Text[10])
        {
            Caption = 'Batch Number';
        }
        field(7; BatSeq; Integer)
        {
            Caption = 'Batch Sequence';
        }
        field(8; BWAmt; Decimal)
        {
            Caption = 'BW Amount';
            AutoFormatType = 0;
        }
        field(9; CashAcct; Text[10])
        {
            Caption = 'CashAcct';
        }
        field(10; CashSub; Text[24])
        {
            Caption = 'CashSub';
        }
        field(11; ClearAmt; Decimal)
        {
            Caption = 'ClearAmt';
            AutoFormatType = 0;
        }
        field(12; ClearDate; Date)
        {
            Caption = 'ClearDate';
        }
        field(13; CodeType; Text[4])
        {
            Caption = 'CodeType';
        }
        field(14; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(15; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(16; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(17; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(18; CurrentNbr; Integer)
        {
            Caption = 'CurrentNbr';
        }
        field(19; CuryBWAmt; Decimal)
        {
            Caption = 'CuryBWAmt';
            AutoFormatType = 0;
        }
        field(20; CuryDiscBal; Decimal)
        {
            Caption = 'CuryDiscBal';
            AutoFormatType = 0;
        }
        field(21; CuryDiscTkn; Decimal)
        {
            Caption = 'CuryDiscTkn';
            AutoFormatType = 0;
        }
        field(22; CuryDocBal; Decimal)
        {
            Caption = 'CuryDocBal';
            AutoFormatType = 0;
        }
        field(23; CuryEffDate; Date)
        {
            Caption = 'CuryEffDateDate';
        }
        field(24; CuryId; Text[4])
        {
            Caption = 'CuryId';
        }
        field(25; CuryMultDiv; Text[1])
        {
            Caption = 'CuryMultDiv';
        }
        field(26; CuryOrigDocAmt; Decimal)
        {
            Caption = 'CuryOrigDocAmt';
            AutoFormatType = 0;
        }
        field(27; CuryPmtAmt; Decimal)
        {
            Caption = 'CuryPmtAmt';
            AutoFormatType = 0;
        }
        field(28; CuryRate; Decimal)
        {
            Caption = 'CuryRate';
            AutoFormatType = 0;
        }
        field(29; CuryRateType; Text[6])
        {
            Caption = 'CuryRateType';
        }
        field(30; CuryTaxTot00; Decimal)
        {
            Caption = 'CuryTaxTot00';
            AutoFormatType = 0;
        }
        field(31; CuryTaxTot01; Decimal)
        {
            Caption = 'CuryTaxTot01';
            AutoFormatType = 0;
        }
        field(32; CuryTaxTot02; Decimal)
        {
            Caption = 'CuryTaxTot02';
            AutoFormatType = 0;
        }
        field(33; CuryTaxTot03; Decimal)
        {
            Caption = 'CuryTaxTot03';
            AutoFormatType = 0;
        }
        field(34; CuryTxblTot00; Decimal)
        {
            Caption = 'CuryTxblTot00';
            AutoFormatType = 0;
        }
        field(35; CuryTxblTot01; Decimal)
        {
            Caption = 'CuryTxblTot01';
            AutoFormatType = 0;
        }
        field(36; CuryTxblTot02; Decimal)
        {
            Caption = 'CuryTxblTot02';
            AutoFormatType = 0;
        }
        field(37; CuryTxblTot03; Decimal)
        {
            Caption = 'CuryTxblTot03';
            AutoFormatType = 0;
        }
        field(38; Cycle; Integer)
        {
            Caption = 'Cycle';
        }
        field(39; DfltDetail; Integer)
        {
            Caption = 'DfltDetail';
        }
        field(40; DirectDeposit; Text[1])
        {
            Caption = 'DirectDeposit';
        }
        field(41; DiscBal; Decimal)
        {
            Caption = 'DiscBal';
            AutoFormatType = 0;
        }
        field(42; DiscDate; Date)
        {
            Caption = 'DiscDate';
        }
        field(43; DiscTkn; Decimal)
        {
            Caption = 'DiscTkn';
            AutoFormatType = 0;
        }
        field(44; Doc1099; Integer)
        {
            Caption = 'Doc1099';
        }
        field(45; DocBal; Decimal)
        {
            Caption = 'DocBal';
            AutoFormatType = 0;
        }
        field(46; DocClass; Text[1])
        {
            Caption = 'DocClass';
        }
        field(47; DocDate; Date)
        {
            Caption = 'DocDate';
        }
        field(48; DocDesc; Text[30])
        {
            Caption = 'DocDesc';
        }
        field(49; DocType; Text[2])
        {
            Caption = 'DocType';
        }
        field(50; DueDate; Date)
        {
            Caption = 'DueDate';
        }
        field(51; Econfirm; Text[18])
        {
            Caption = 'Econfirm';
        }
        field(52; Estatus; Text[1])
        {
            Caption = 'Estatus';
        }
        field(53; ExcludeFreight; Text[1])
        {
            Caption = 'ExcludeFreight';
        }
        field(54; FreightAmt; Decimal)
        {
            Caption = 'FreightAmt';
            AutoFormatType = 0;
        }
        field(55; InstallNbr; Integer)
        {
            Caption = 'InstallNbr';
        }
        field(56; InvcDate; Date)
        {
            Caption = 'InvcDate';
        }
        field(57; InvcNbr; Text[15])
        {
            Caption = 'InvcNbr';
        }
        field(58; LCCode; Text[10])
        {
            Caption = 'LCCode';
        }
        field(59; LineCntr; Integer)
        {
            Caption = 'LineCntr';
        }
        field(60; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(61; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(62; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(63; MasterDocNbr; Text[10])
        {
            Caption = 'MasterDocNbr';
        }
        field(64; NbrCycle; Integer)
        {
            Caption = 'NbrCycle';
        }
        field(65; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(66; OpenDoc; Integer)
        {
            Caption = 'OpenDoc';
        }
        field(67; OrigDocAmt; Decimal)
        {
            Caption = 'OrigDocAmt';
            AutoFormatType = 0;
        }
        field(68; PayDate; Date)
        {
            Caption = 'PayDate';
        }
        field(69; PayHoldDesc; Text[30])
        {
            Caption = 'PayHoldDesc';
        }
        field(70; PC_Status; Text[1])
        {
            Caption = 'PC_Status';
        }
        field(71; PerClosed; Text[6])
        {
            Caption = 'PerClosed';
        }
        field(72; PerEnt; Text[6])
        {
            Caption = 'PerEnt';
        }
        field(73; PerPost; Text[6])
        {
            Caption = 'PerPost';
        }
        field(74; PmtAmt; Decimal)
        {
            Caption = 'PmtAmt';
            AutoFormatType = 0;
        }
        field(75; PmtID; Text[10])
        {
            Caption = 'PmtID';
        }
        field(76; PmtMethod; Text[1])
        {
            Caption = 'PmtMethod';
        }
        field(77; PONbr; Text[10])
        {
            Caption = 'PONbr';
        }
        field(78; PrePay_RefNbr; Text[10])
        {
            Caption = 'PrePay_RefNbr';
        }
        field(79; ProjectID; Text[16])
        {
            Caption = 'ProjectID';
        }
        field(80; "RecordID"; Integer)
        {
            Caption = 'RecordID';
        }
        field(81; RefNbr; Text[10])
        {
            Caption = 'RefNbr';
        }
        field(82; Retention; Integer)
        {
            Caption = 'Retention';
        }
        field(83; RGOLAmt; Decimal)
        {
            Caption = 'RGOLAmt';
            AutoFormatType = 0;
        }
        field(84; Rlsed; Integer)
        {
            Caption = 'Rlsed';
        }
        field(85; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(86; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(87; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
            AutoFormatType = 0;
        }
        field(88; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
            AutoFormatType = 0;
        }
        field(89; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
            AutoFormatType = 0;
        }
        field(90; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
            AutoFormatType = 0;
        }
        field(91; S4Future07; Date)
        {
            Caption = 'S4Future07';
        }
        field(92; S4Future08; Date)
        {
            Caption = 'S4Future08';
        }
        field(93; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(94; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(95; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(96; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(97; Selected; Integer)
        {
            Caption = 'Selected';
        }
        field(98; Status; Text[1])
        {
            Caption = 'Status';
        }
        field(99; Sub; Text[24])
        {
            Caption = 'Sub';
        }
        field(100; Subcontract; Text[16])
        {
            Caption = 'Subcontract';
        }
        field(101; TaxCntr00; Integer)
        {
            Caption = 'TaxCntr00';
        }
        field(102; TaxCntr01; Integer)
        {
            Caption = 'TaxCntr01';
        }
        field(103; TaxCntr02; Integer)
        {
            Caption = 'TaxCntr02';
        }
        field(104; TaxCntr03; Integer)
        {
            Caption = 'TaxCntr03';
        }
        field(105; TaxId00; Text[10])
        {
            Caption = 'TaxId00';
        }
        field(106; TaxId01; Text[10])
        {
            Caption = 'TaxId01';
        }
        field(107; TaxId02; Text[10])
        {
            Caption = 'TaxId02';
        }
        field(108; TaxId03; Text[10])
        {
            Caption = 'TaxId03';
        }
        field(109; TaxTot00; Decimal)
        {
            Caption = 'TaxTot00';
            AutoFormatType = 0;
        }
        field(110; TaxTot01; Decimal)
        {
            Caption = 'TaxTot01';
            AutoFormatType = 0;
        }
        field(111; TaxTot02; Decimal)
        {
            Caption = 'TaxTot02';
            AutoFormatType = 0;
        }
        field(112; TaxTot03; Decimal)
        {
            Caption = 'TaxTot03';
            AutoFormatType = 0;
        }
        field(113; Terms; Text[2])
        {
            Caption = 'Terms';
        }
        field(114; TxblTot00; Decimal)
        {
            Caption = 'TxblTot00';
            AutoFormatType = 0;
        }
        field(115; TxblTot01; Decimal)
        {
            Caption = 'TxblTot01';
            AutoFormatType = 0;
        }
        field(116; TxblTot02; Decimal)
        {
            Caption = 'TxblTot02';
            AutoFormatType = 0;
        }
        field(117; TxblTot03; Decimal)
        {
            Caption = 'TxblTot03';
            AutoFormatType = 0;
        }
        field(118; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(119; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(120; User3; Decimal)
        {
            Caption = 'User3';
            AutoFormatType = 0;
        }
        field(121; User4; Decimal)
        {
            Caption = 'User4';
            AutoFormatType = 0;
        }
        field(122; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(123; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(124; User7; Date)
        {
            Caption = 'User7';
        }
        field(125; User8; Date)
        {
            Caption = 'User8';
        }
        field(126; VCVoidDocs; Integer)
        {
            Caption = 'VCVoidDocs';
        }
        field(127; VendId; Text[15])
        {
            Caption = 'VendId';
        }
        field(128; VendName; Text[60])
        {
            Caption = 'VendName';
        }
    }
    keys
    {
        key(Key1; Acct, Sub, DocType, RefNbr, RecordID)
        {
            Clustered = true;
        }
    }
}
