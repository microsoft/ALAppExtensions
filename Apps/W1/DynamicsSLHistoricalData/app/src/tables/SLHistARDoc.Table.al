// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

table 42804 "SL Hist. ARDoc"
{
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; AcctNbr; Text[30])
        {
            Caption = 'AcctNbr';
        }
        field(2; AgentID; Text[10])
        {
            Caption = 'AgentID';
        }
        field(3; ApplAmt; Decimal)
        {
            Caption = 'ApplAmt';
        }
        field(4; ApplBatNbr; Text[10])
        {
            Caption = 'ApplBatNbr';
        }
        field(5; ApplBatSeq; Integer)
        {
            Caption = 'ApplBatSeq';
        }
        field(6; ASID; Integer)
        {
            Caption = 'ASID';
        }
        field(7; BankAcct; Text[10])
        {
            Caption = 'BankAcct';
        }
        field(8; BankID; Text[10])
        {
            Caption = 'BankID';
        }
        field(9; BankSub; Text[24])
        {
            Caption = 'BankSub';
        }
        field(10; BatNbr; Text[10])
        {
            Caption = 'BatNbr';
        }
        field(11; BatSeq; Integer)
        {
            Caption = 'BatSeq';
        }
        field(12; Cleardate; DateTime)
        {
            Caption = 'Cleardate';
        }
        field(13; CmmnAmt; Decimal)
        {
            Caption = 'CmmnAmt';
        }
        field(14; CmmnPct; Decimal)
        {
            Caption = 'CmmnPct';
        }
        field(15; ContractID; Text[10])
        {
            Caption = 'ContractID';
        }
        field(16; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(17; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(18; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(19; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(20; CurrentNbr; Integer)
        {
            Caption = 'CurrentNbr';
        }
        field(21; CuryApplAmt; Decimal)
        {
            Caption = 'CuryApplAmt';
        }
        field(22; CuryClearAmt; Decimal)
        {
            Caption = 'CuryClearAmt';
        }
        field(23; CuryCmmnAmt; Decimal)
        {
            Caption = 'CuryCmmnAmt';
        }
        field(24; CuryDiscApplAmt; Decimal)
        {
            Caption = 'CuryDiscApplAmt';
        }
        field(25; CuryDiscBal; Decimal)
        {
            Caption = 'CuryDiscBal';
        }
        field(26; CuryDocBal; Decimal)
        {
            Caption = 'CuryDocBal';
        }
        field(27; CuryEffDate; DateTime)
        {
            Caption = 'CuryEffDate';
        }
        field(28; CuryId; Text[4])
        {
            Caption = 'CuryId';
        }
        field(29; CuryMultDiv; Text[1])
        {
            Caption = 'CuryMultDiv';
        }
        field(30; CuryOrigDocAmt; Decimal)
        {
            Caption = 'CuryOrigDocAmt';
        }
        field(31; CuryRate; Decimal)
        {
            Caption = 'CuryRate';
        }
        field(32; CuryRateType; Text[6])
        {
            Caption = 'CuryRateType';
        }
        field(33; CuryStmtBal; Decimal)
        {
            Caption = 'CuryStmtBal';
        }
        field(34; CuryTaxTot00; Decimal)
        {
            Caption = 'CuryTaxTot00';
        }
        field(35; CuryTaxTot01; Decimal)
        {
            Caption = 'CuryTaxTot01';
        }
        field(36; CuryTaxTot02; Decimal)
        {
            Caption = 'CuryTaxTot02';
        }
        field(37; CuryTaxTot03; Decimal)
        {
            Caption = 'CuryTaxTot03';
        }
        field(38; CuryTxblTot00; Decimal)
        {
            Caption = 'CuryTxblTot00';
        }
        field(39; CuryTxblTot01; Decimal)
        {
            Caption = 'CuryTxblTot01';
        }
        field(40; CuryTxblTot02; Decimal)
        {
            Caption = 'CuryTxblTot02';
        }
        field(41; CuryTxblTot03; Decimal)
        {
            Caption = 'CuryTxblTot03';
        }
        field(42; CustId; Text[15])
        {
            Caption = 'CustId';
        }
        field(43; CustOrdNbr; Text[25])
        {
            Caption = 'CustOrdNbr';
        }
        field(44; Cycle; Integer)
        {
            Caption = 'Cycle';
        }
        field(45; DiscApplAmt; Decimal)
        {
            Caption = 'DiscApplAmt';
        }
        field(46; DiscBal; Decimal)
        {
            Caption = 'DiscBal';
        }
        field(47; DiscDate; DateTime)
        {
            Caption = 'DiscDate';
        }
        field(48; DocBal; Decimal)
        {
            Caption = 'DocBal';
        }
        field(49; DocClass; Text[1])
        {
            Caption = 'DocClass';
        }
        field(50; DocDate; DateTime)
        {
            Caption = 'DocDate';
        }
        field(51; DocDesc; Text[30])
        {
            Caption = 'DocDesc';
        }
        field(52; DocType; Text[2])
        {
            Caption = 'DocType';
        }
        field(53; DraftIssued; Integer)
        {
            Caption = 'DraftIssued';
        }
        field(54; DueDate; DateTime)
        {
            Caption = 'DueDate';
        }
        field(55; InstallNbr; Integer)
        {
            Caption = 'InstallNbr';
        }
        field(56; JobCntr; Integer)
        {
            Caption = 'JobCntr';
        }
        field(57; LineCntr; Integer)
        {
            Caption = 'LineCntr';
        }
        field(58; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(59; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(60; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(61; MasterDocNbr; Text[10])
        {
            Caption = 'MasterDocNbr';
        }
        field(62; NbrCycle; Integer)
        {
            Caption = 'NbrCycle';
        }
        field(67; NoPrtStmt; Integer)
        {
            Caption = 'NoPrtStmt';
        }
        field(68; NoteId; Integer)
        {
            Caption = 'NoteId';
        }
        field(69; OpenDoc; Integer)
        {
            Caption = 'OpenDoc';
        }
        field(70; OrdNbr; Text[15])
        {
            Caption = 'OrdNbr';
        }
        field(71; OrigBankAcct; Text[10])
        {
            Caption = 'OrigBankAcct';
        }
        field(72; OrigBankSub; Text[24])
        {
            Caption = 'OrigBankSub';
        }
        field(73; OrigCpnyID; Text[10])
        {
            Caption = 'OrigCpnyID';
        }
        field(74; OrigDocAmt; Decimal)
        {
            Caption = 'OrigDocAmt';
        }
        field(75; OrigDocNbr; Text[10])
        {
            Caption = 'OrigDocNbr';
        }
        field(76; PC_Status; Text[1])
        {
            Caption = 'PC_Status';
        }
        field(77; PerClosed; Text[6])
        {
            Caption = 'PerClosed';
        }
        field(78; PerEnt; Text[6])
        {
            Caption = 'PerEnt';
        }
        field(79; PerPost; Text[6])
        {
            Caption = 'PerPost';
        }
        field(80; PmtMethod; Text[1])
        {
            Caption = 'PmtMethod';
        }
        field(81; ProjectID; Text[16])
        {
            Caption = 'ProjectID';
        }
        field(82; RefNbr; Text[10])
        {
            Caption = 'RefNbr';
        }
        field(83; RGOLAmt; Decimal)
        {
            Caption = 'RGOLAmt';
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
        }
        field(88; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(89; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(90; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(91; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(92; S4Future08; DateTime)
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
        field(97; ServiceCallID; Text[10])
        {
            Caption = 'ServiceCallID';
        }
        field(98; ShipmentNbr; Integer)
        {
            Caption = 'ShipmentNbr';
        }
        field(99; SlsperId; Text[10])
        {
            Caption = 'SlsperId';
        }
        field(100; Status; Text[1])
        {
            Caption = 'Status';
        }
        field(101; StmtBal; Decimal)
        {
            Caption = 'StmtBal';
        }
        field(102; StmtDate; DateTime)
        {
            Caption = 'StmtDate';
        }
        field(103; TaskID; Text[32])
        {
            Caption = 'TaskID';
        }
        field(104; TaxCntr00; Integer)
        {
            Caption = 'TaxCntr00';
        }
        field(105; TaxCntr01; Integer)
        {
            Caption = 'TaxCntr01';
        }
        field(106; TaxCntr02; Integer)
        {
            Caption = 'TaxCntr02';
        }
        field(107; TaxCntr03; Integer)
        {
            Caption = 'TaxCntr03';
        }
        field(108; TaxId00; Text[10])
        {
            Caption = 'TaxId00';
        }
        field(109; TaxId01; Text[10])
        {
            Caption = 'TaxId01';
        }
        field(110; TaxId02; Text[10])
        {
            Caption = 'TaxId02';
        }
        field(111; TaxId03; Text[10])
        {
            Caption = 'TaxId03';
        }
        field(112; TaxTot00; Decimal)
        {
            Caption = 'TaxTot00';
        }
        field(113; TaxTot01; Decimal)
        {
            Caption = 'TaxTot01';
        }
        field(114; TaxTot02; Decimal)
        {
            Caption = 'TaxTot02';
        }
        field(115; TaxTot03; Decimal)
        {
            Caption = 'TaxTot03';
        }
        field(116; Terms; Text[2])
        {
            Caption = 'Terms';
        }
        field(117; TxblTot00; Decimal)
        {
            Caption = 'TxblTot00';
        }
        field(118; TxblTot01; Decimal)
        {
            Caption = 'TxblTot01';
        }
        field(119; TxblTot02; Decimal)
        {
            Caption = 'TxblTot02';
        }
        field(120; TxblTot03; Decimal)
        {
            Caption = 'TxblTot03';
        }
        field(121; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(122; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(123; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(124; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(125; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(126; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(127; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(128; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(129; WSID; Integer)
        {
            Caption = 'WSID';
        }
    }

    keys
    {
        key(PK; CustId, DocType, RefNbr, BatNbr, BatSeq)
        {
            Clustered = true;
        }
    }
}