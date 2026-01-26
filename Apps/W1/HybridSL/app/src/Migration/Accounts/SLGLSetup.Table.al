// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47009 "SL GLSetup"
{
    Access = Internal;
    Caption = 'SL GLSetup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Addr1; Text[30])
        {
            Caption = 'Addr1';
        }
        field(2; Addr2; Text[30])
        {
            Caption = 'Addr2';
        }
        field(3; AllowPostOpt; Text[1])
        {
            Caption = 'AllowPostOpt';
        }
        field(4; AutoBatRpt; Integer)
        {
            Caption = 'AutoBatRpt';
        }
        field(5; AutoPost; Text[1])
        {
            Caption = 'AutoPost';
        }
        field(6; AutoRef; Text[1])
        {
            Caption = 'AutoRef';
        }
        field(7; AutoRevOpt; Text[1])
        {
            Caption = 'AutoRevOpt';
        }
        field(8; BaseCuryId; Text[4])
        {
            Caption = 'BaseCuryId';
        }
        field(9; BatCntrlByMod; Text[150])
        {
            Caption = 'BatCntrlByMod';
        }
        field(10; BegFiscalYr; Integer)
        {
            Caption = 'BegFiscalYr';
        }
        field(11; BudgetLedgerID; Text[10])
        {
            Caption = 'BudgetLedgerID';
        }
        field(12; BudgetSpreadDir; Text[50])
        {
            Caption = 'BudgetSpreadDir';
        }
        field(13; BudgetSpreadType; Text[1])
        {
            Caption = 'BudgetSpreadType';
        }
        field(14; BudgetSubSeg00; Text[1])
        {
            Caption = 'BudgetSubSeg00';
        }
        field(15; BudgetSubSeg01; Text[1])
        {
            Caption = 'BudgetSubSeg01';
        }
        field(16; BudgetSubSeg02; Text[1])
        {
            Caption = 'BudgetSubSeg02';
        }
        field(17; BudgetSubSeg03; Text[1])
        {
            Caption = 'BudgetSubSeg03';
        }
        field(18; BudgetSubSeg04; Text[1])
        {
            Caption = 'BudgetSubSeg04';
        }
        field(19; BudgetSubSeg05; Text[1])
        {
            Caption = 'BudgetSubSeg05';
        }
        field(20; BudgetSubSeg06; Text[1])
        {
            Caption = 'BudgetSubSeg06';
        }
        field(21; BudgetSubSeg07; Text[1])
        {
            Caption = 'BudgetSubSeg07';
        }
        field(22; BudgetYear; Text[4])
        {
            Caption = 'BudgetYear';
        }
        field(23; Central_Cash_Cntl; Integer)
        {
            Caption = 'Central_Cash_Cntl';
        }
        field(24; ChngNbrPer; Integer)
        {
            Caption = 'ChngNbrPer';
        }
        field(25; City; Text[30])
        {
            Caption = 'City';
        }
        field(26; COAOrder; Text[1])
        {
            Caption = 'COAOrder';
        }
        field(27; Country; Text[3])
        {
            Caption = 'Country';
        }
        field(28; CpnyId; Text[10])
        {
            Caption = 'CpnyId';
        }
        field(29; CpnyName; Text[30])
        {
            Caption = 'CpnyName';
        }
        field(30; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(31; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(32; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(33; EditInit; Integer)
        {
            Caption = 'EditInit';
        }
        field(34; EmplId; Text[12])
        {
            Caption = 'EmplId';
        }
        field(35; Fax; Text[30])
        {
            Caption = 'Fax';
        }
        field(36; FiscalPerEnd00; Text[4])
        {
            Caption = 'FiscalPerEnd00';
        }
        field(37; FiscalPerEnd01; Text[4])
        {
            Caption = 'FiscalPerEnd01';
        }
        field(38; FiscalPerEnd02; Text[4])
        {
            Caption = 'FiscalPerEnd02';
        }
        field(39; FiscalPerEnd03; Text[4])
        {
            Caption = 'FiscalPerEnd03';
        }
        field(40; FiscalPerEnd04; Text[4])
        {
            Caption = 'FiscalPerEnd04';
        }
        field(41; FiscalPerEnd05; Text[4])
        {
            Caption = 'FiscalPerEnd05';
        }
        field(42; FiscalPerEnd06; Text[4])
        {
            Caption = 'FiscalPerEnd06';
        }
        field(43; FiscalPerEnd07; Text[4])
        {
            Caption = 'FiscalPerEnd07';
        }
        field(44; FiscalPerEnd08; Text[4])
        {
            Caption = 'FiscalPerEnd08';
        }
        field(45; FiscalPerEnd09; Text[4])
        {
            Caption = 'FiscalPerEnd09';
        }
        field(46; FiscalPerEnd10; Text[4])
        {
            Caption = 'FiscalPerEnd10';
        }
        field(47; FiscalPerEnd11; Text[4])
        {
            Caption = 'FiscalPerEnd11';
        }
        field(48; FiscalPerEnd12; Text[4])
        {
            Caption = 'FiscalPerEnd12';
        }
        field(49; "Init"; Integer)
        {
            Caption = 'Init';
        }
        field(50; LastBatNbr; Text[10])
        {
            Caption = 'LastBatNbr';
        }
        field(51; LastClosePerNbr; Text[6])
        {
            Caption = 'LastClosePerNbr';
        }
        field(52; LedgerID; Text[10])
        {
            Caption = 'LedgerID';
        }
        field(53; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(54; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(55; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(56; Master_Fed_ID; Integer)
        {
            Caption = 'Master_Fed_ID';
        }
        field(57; MCActive; Integer)
        {
            Caption = 'MCActive';
        }
        field(58; MCuryBatRpt; Integer)
        {
            Caption = 'MCuryBatRpt';
        }
        field(59; ModPriorPost; Text[180])
        {
            Caption = 'ModPriorPost';
        }
        field(60; Mult_Cpny_Db; Integer)
        {
            Caption = 'Mult_Cpny_Db';
        }
        field(61; NbrPer; Integer)
        {
            Caption = 'NbrPer';
        }
        field(62; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(63; PerNbr; Text[6])
        {
            Caption = 'PerNbr';
        }
        field(64; PerRetHist; Integer)
        {
            Caption = 'PerRetHist';
        }
        field(65; PerRetModTran; Integer)
        {
            Caption = 'PerRetModTran';
        }
        field(66; PerRetTran; Integer)
        {
            Caption = 'PerRetTran';
        }
        field(67; Phone; Text[30])
        {
            Caption = 'Phone';
        }
        field(68; PriorYearPost; Integer)
        {
            Caption = 'PriorYearPost';
        }
        field(69; PSC; Text[4])
        {
            Caption = 'PSC';
        }
        field(70; RetEarnAcct; Text[10])
        {
            Caption = 'RetEarnAcct';
        }
        field(71; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(72; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(73; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(74; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(75; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(76; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(77; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(78; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(79; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(80; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(81; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(82; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(83; SetupId; Text[2])
        {
            Caption = 'SetupId';
        }
        field(84; State; Text[3])
        {
            Caption = 'State';
        }
        field(85; SubAcctSeg; Text[2])
        {
            Caption = 'SubAcctSeg';
        }
        field(86; SummPostYCntr; Integer)
        {
            Caption = 'SummPostYCntr';
        }
        field(87; UpdateCA; Integer)
        {
            Caption = 'UpdateCA';
        }
        field(88; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(89; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(90; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(91; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(92; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(93; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(94; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(95; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(96; ValidateAcctSub; Integer)
        {
            Caption = 'ValidateAcctSub';
        }
        field(97; ValidateAtPosting; Integer)
        {
            Caption = 'ValidateAtPosting';
        }
        field(98; YtdNetIncAcct; Text[10])
        {
            Caption = 'YtdNetIncAcct';
        }
        field(99; ZCount; Integer)
        {
            Caption = 'ZCount';
        }
        field(100; Zip; Text[10])
        {
            Caption = 'Zip';
        }
        field(101; Zp; Text[256])
        {
            Caption = 'Zp';
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