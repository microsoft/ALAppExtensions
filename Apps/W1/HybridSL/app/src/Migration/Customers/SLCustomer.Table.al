// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47012 "SL Customer"
{
    Access = Internal;
    Caption = 'SL Customer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; AccrRevAcct; Text[10])
        {
            Caption = 'AccrRevAcct';
        }
        field(2; AccrRevSub; Text[24])
        {
            Caption = 'AccrRevSub';
        }
        field(3; AcctNbr; Text[30])
        {
            Caption = 'AcctNbr';
        }
        field(4; Addr1; Text[60])
        {
            Caption = 'Addr1';
        }
        field(5; Addr2; Text[60])
        {
            Caption = 'Addr2';
        }
        field(6; AgentID; Text[10])
        {
            Caption = 'AgentID';
        }
        field(7; ApplFinChrg; Integer)
        {
            Caption = 'ApplFinChrg';
        }
        field(8; ArAcct; Text[10])
        {
            Caption = 'ArAcct';
        }
        field(9; ArSub; Text[24])
        {
            Caption = 'ArSub';
        }
        field(10; Attn; Text[30])
        {
            Caption = 'Attn';
        }
        field(11; AutoApply; Integer)
        {
            Caption = 'AutoApply';
        }
        field(12; BankID; Text[10])
        {
            Caption = 'BankID';
        }
        field(13; BillAddr1; Text[60])
        {
            Caption = 'BillAddr1';
        }
        field(14; BillAddr2; Text[60])
        {
            Caption = 'BillAddr2';
        }
        field(15; BillAttn; Text[30])
        {
            Caption = 'BillAttn';
        }
        field(16; BillCity; Text[30])
        {
            Caption = 'BillCity';
        }
        field(17; BillCountry; Text[3])
        {
            Caption = 'BillCountry';
        }
        field(18; BillFax; Text[30])
        {
            Caption = 'BillFax';
        }
        field(19; BillName; Text[60])
        {
            Caption = 'BillName';
        }
        field(20; BillPhone; Text[30])
        {
            Caption = 'BillPhone';
        }
        field(21; BillSalut; Text[30])
        {
            Caption = 'BillSalut';
        }
        field(22; BillState; Text[3])
        {
            Caption = 'BillState';
        }
        field(23; BillThruProject; Integer)
        {
            Caption = 'BillThruProject';
        }
        field(24; BillZip; Text[10])
        {
            Caption = 'BillZip';
        }
        field(25; CardExpDate; DateTime)
        {
            Caption = 'CardExpDate';
        }
        field(26; CardHldrName; Text[60])
        {
            Caption = 'CardHldrName';
        }
        field(27; CardNbr; Text[20])
        {
            Caption = 'CardNbr';
        }
        field(28; CardType; Text[1])
        {
            Caption = 'CardType';
        }
        field(29; City; Text[30])
        {
            Caption = 'City';
        }
        field(30; ClassId; Text[6])
        {
            Caption = 'ClassId';
        }
        field(31; ConsolInv; Integer)
        {
            Caption = 'ConsolInv';
        }
        field(32; Country; Text[3])
        {
            Caption = 'Country';
        }
        field(33; CrLmt; Decimal)
        {
            Caption = 'CrLmt';
        }
        field(34; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(35; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(36; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(37; CuryId; Text[4])
        {
            Caption = 'CuryId';
        }
        field(38; CuryPrcLvlRtTp; Text[6])
        {
            Caption = 'CuryPrcLvlRtTp';
        }
        field(39; CuryRateType; Text[6])
        {
            Caption = 'CuryRateType';
        }
        field(40; CustFillPriority; Integer)
        {
            Caption = 'CustFillPriority';
        }
        field(41; CustId; Text[15])
        {
            Caption = 'CustId';
        }
        field(42; DfltShipToId; Text[10])
        {
            Caption = 'DfltShipToId';
        }
        field(43; DocPublishingFlag; Text[1])
        {
            Caption = 'DocPublishingFlag';
        }
        field(44; DunMsg; Integer)
        {
            Caption = 'DunMsg';
        }
        field(45; EMailAddr; Text[80])
        {
            Caption = 'EMailAddr';
        }
        field(46; Fax; Text[30])
        {
            Caption = 'Fax';
        }
        field(47; InvtSubst; Integer)
        {
            Caption = 'InvtSubst';
        }
        field(48; LanguageID; Text[4])
        {
            Caption = 'LanguageID';
        }
        field(49; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(50; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(51; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(52; Name; Text[60])
        {
            Caption = 'Name';
        }
        field(53; NoteId; Integer)
        {
            Caption = 'NoteId';
        }
        field(54; OneDraft; Integer)
        {
            Caption = 'OneDraft';
        }
        field(55; PerNbr; Text[6])
        {
            Caption = 'PerNbr';
        }
        field(56; Phone; Text[30])
        {
            Caption = 'Phone';
        }
        field(57; PmtMethod; Text[1])
        {
            Caption = 'PmtMethod';
        }
        field(58; PrcLvlId; Text[10])
        {
            Caption = 'PrcLvlId';
        }
        field(59; PrePayAcct; Text[10])
        {
            Caption = 'PrePayAcct';
        }
        field(60; PrePaySub; Text[24])
        {
            Caption = 'PrePaySub';
        }
        field(61; PriceClassID; Text[6])
        {
            Caption = 'PriceClassID';
        }
        field(62; PrtMCStmt; Integer)
        {
            Caption = 'PrtMCStmt';
        }
        field(63; PrtStmt; Integer)
        {
            Caption = 'PrtStmt';
        }
        field(64; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(65; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(66; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(67; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(68; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(69; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(70; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(71; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(72; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(73; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(74; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(75; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(76; Salut; Text[30])
        {
            Caption = 'Salut';
        }
        field(77; SetupDate; DateTime)
        {
            Caption = 'SetupDate';
        }
        field(78; ShipCmplt; Integer)
        {
            Caption = 'ShipCmplt';
        }
        field(79; ShipPctAct; Text[1])
        {
            Caption = 'ShipPctAct';
        }
        field(80; ShipPctMax; Decimal)
        {
            Caption = 'ShipPctMax';
        }
        field(81; SICCode1; Text[4])
        {
            Caption = 'SICCode1';
        }
        field(82; SICCode2; Text[4])
        {
            Caption = 'SICCode2';
        }
        field(83; SingleInvoice; Integer)
        {
            Caption = 'SingleInvoice';
        }
        field(84; SlsAcct; Text[10])
        {
            Caption = 'SlsAcct';
        }
        field(85; SlsperId; Text[10])
        {
            Caption = 'SlsperId';
        }
        field(86; SlsSub; Text[24])
        {
            Caption = 'SlsSub';
        }
        field(87; State; Text[3])
        {
            Caption = 'State';
        }
        field(88; Status; Text[1])
        {
            Caption = 'Status';
        }
        field(89; StmtCycleId; Text[2])
        {
            Caption = 'StmtCycleId';
        }
        field(90; StmtType; Text[1])
        {
            Caption = 'StmtType';
        }
        field(91; TaxDflt; Text[1])
        {
            Caption = 'TaxDflt';
        }
        field(92; TaxExemptNbr; Text[15])
        {
            Caption = 'TaxExemptNbr';
        }
        field(93; TaxID00; Text[10])
        {
            Caption = 'TaxID00';
        }
        field(94; TaxID01; Text[10])
        {
            Caption = 'TaxID01';
        }
        field(95; TaxID02; Text[10])
        {
            Caption = 'TaxID02';
        }
        field(96; TaxID03; Text[10])
        {
            Caption = 'TaxID03';
        }
        field(97; TaxLocId; Text[15])
        {
            Caption = 'TaxLocId';
        }
        field(98; TaxRegNbr; Text[15])
        {
            Caption = 'TaxRegNbr';
        }
        field(99; Terms; Text[2])
        {
            Caption = 'Terms';
        }
        field(100; Territory; Text[10])
        {
            Caption = 'Territory';
        }
        field(101; TradeDisc; Decimal)
        {
            Caption = 'TradeDisc';
        }
        field(102; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(103; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(104; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(105; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(106; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(107; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(108; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(109; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(110; Zip; Text[10])
        {
            Caption = 'Zip';
        }
    }

    keys
    {
        key(Key1; CustId)
        {
            Clustered = true;
        }
    }
}