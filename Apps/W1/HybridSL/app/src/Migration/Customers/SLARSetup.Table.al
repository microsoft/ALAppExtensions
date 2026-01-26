// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47011 "SL ARSetup"
{
    Access = Internal;
    Caption = 'SL ARSetup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; AnnFinChrg; Decimal)
        {
            Caption = 'AnnFinChrg';
        }
        field(2; ArAcct; Text[10])
        {
            Caption = 'ArAcct';
        }
        field(3; ArSub; Text[24])
        {
            Caption = 'ArSub';
        }
        field(4; AutoApplyWO; Integer)
        {
            Caption = 'AutoApplyWO';
        }
        field(5; AutoBatRpt; Integer)
        {
            Caption = 'AutoBatRpt';
        }
        field(6; AutoNSF; Integer)
        {
            Caption = 'AutoNSF';
        }
        field(7; AutoRef; Integer)
        {
            Caption = 'AutoRef';
        }
        field(8; ChkAcct; Text[10])
        {
            Caption = 'ChkAcct';
        }
        field(9; ChkSub; Text[24])
        {
            Caption = 'ChkSub';
        }
        field(10; ChrgMin; Integer)
        {
            Caption = 'ChrgMin';
        }
        field(11; CompdFinChrg; Integer)
        {
            Caption = 'CompdFinChrg';
        }
        field(12; CreditHoldType; Text[1])
        {
            Caption = 'CreditHoldType';
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
        field(16; CurrPerNbr; Text[6])
        {
            Caption = 'CurrPerNbr';
        }
        field(17; CustViewDflt; Text[1])
        {
            Caption = 'CustViewDflt';
        }
        field(18; DaysPastDue; Integer)
        {
            Caption = 'DaysPastDue';
        }
        field(19; DecPlPrcCst; Integer)
        {
            Caption = 'DecPlPrcCst';
        }
        field(20; DecPlQty; Integer)
        {
            Caption = 'DecPlQty';
        }
        field(21; DfltAutoApply; Integer)
        {
            Caption = 'DfltAutoApply';
        }
        field(22; DfltClass; Text[6])
        {
            Caption = 'DfltClass';
        }
        field(23; DfltNSFAcct; Text[10])
        {
            Caption = 'DfltNSFAcct';
        }
        field(24; DfltNSFSub; Text[24])
        {
            Caption = 'DfltNSFSub';
        }
        field(25; DfltSBWOAcct; Text[10])
        {
            Caption = 'DfltSBWOAcct';
        }
        field(26; DfltSBWOSub; Text[24])
        {
            Caption = 'DfltSBWOSub';
        }
        field(27; DfltSCWOAcct; Text[10])
        {
            Caption = 'DfltSCWOAcct';
        }
        field(28; DfltSCWOSub; Text[24])
        {
            Caption = 'DfltSCWOSub';
        }
        field(29; DfltStmtCycle; Text[2])
        {
            Caption = 'DfltStmtCycle';
        }
        field(30; DfltStmtType; Text[1])
        {
            Caption = 'DfltStmtType';
        }
        field(31; DiscAcct; Text[10])
        {
            Caption = 'DiscAcct';
        }
        field(32; DiscSub; Text[24])
        {
            Caption = 'DiscSub';
        }
        field(33; DiscCpnyFromInvc; Integer)
        {
            Caption = 'DiscCpnyFromInvc';
        }
        field(34; FinChrgAcct; Text[10])
        {
            Caption = 'FinChrgAcct';
        }
        field(35; FinChrgFirst; Text[1])
        {
            Caption = 'FinChrgFirst';
        }
        field(36; FinChrgSub; Text[24])
        {
            Caption = 'FinChrgSub';
        }
        field(37; GLPostOpt; Text[1])
        {
            Caption = 'GLPostOpt';
        }
        field(38; IncAcct; Text[10])
        {
            Caption = 'IncAcct';
        }
        field(39; IncSub; Text[24])
        {
            Caption = 'IncSub';
        }
        field(40; "Init"; Integer)
        {
            Caption = 'Init';
        }
        field(41; LastBatNbr; Text[10])
        {
            Caption = 'LastBatNbr';
        }
        field(42; LastCrMemoNbr; Text[10])
        {
            Caption = 'LastCrMemoNbr';
        }
        field(43; LastDrMemoNbr; Text[10])
        {
            Caption = 'LastDrMemoNbr';
        }
        field(44; LastFinChrgRefNbr; Text[10])
        {
            Caption = 'LastFinChrgRefNbr';
        }
        field(45; LastRefNbr; Text[10])
        {
            Caption = 'LastRefNbr';
        }
        field(46; LastWORefNbr; Text[10])
        {
            Caption = 'LastWORefNbr';
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
        field(50; MCuryBatRpt; Integer)
        {
            Caption = 'MCuryBatRpt';
        }
        field(51; MinFinChrg; Decimal)
        {
            Caption = 'MinFinChrg';
        }
        field(52; Nbr0803Docs; Integer)
        {
            Caption = 'Nbr0803Docs';
        }
        field(53; NoteId; Integer)
        {
            Caption = 'NoteId';
        }
        field(54; NSFChrg; Decimal)
        {
            Caption = 'NSFChrg';
        }
        field(55; OverLimitAmt; Decimal)
        {
            Caption = 'OverLimitAmt';
        }
        field(56; OverLimitType; Text[1])
        {
            Caption = 'OverLimitType';
        }
        field(57; PASortDflt; Text[1])
        {
            Caption = 'PASortDflt';
        }
        field(58; PerNbr; Text[6])
        {
            Caption = 'PerNbr';
        }
        field(59; PerRetHist; Integer)
        {
            Caption = 'PerRetHist';
        }
        field(60; PerRetStmtDtl; Integer)
        {
            Caption = 'PerRetStmtDtl';
        }
        field(61; PerRetTran; Integer)
        {
            Caption = 'PerRetTran';
        }
        field(62; PrePayAcct; Text[10])
        {
            Caption = 'PrePayAcct';
        }
        field(63; PrePaySub; Text[24])
        {
            Caption = 'PrePaySub';
        }
        field(64; RetAllowAcct; Text[10])
        {
            Caption = 'RetAllowAcct';
        }
        field(65; RetAllowSub; Text[24])
        {
            Caption = 'RetAllowSub';
        }
        field(66; RetAvgDay; Integer)
        {
            Caption = 'RetAvgDay';
        }
        field(67; RfndAcct; Text[10])
        {
            Caption = 'RfndAcct';
        }
        field(68; RfndSub; Text[24])
        {
            Caption = 'RfndSub';
        }
        field(69; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(70; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(71; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(72; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(73; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(74; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(75; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(76; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(77; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(78; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(79; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(80; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(81; S4Future13; Text[10])
        {
            Caption = 'S4Future13';
        }
        field(82; SBLimit; Decimal)
        {
            Caption = 'SBLimit';
        }
        field(83; SetupId; Text[2])
        {
            Caption = 'SetupId';
        }
        field(84; SlsTax; Integer)
        {
            Caption = 'SlsTax';
        }
        field(85; SlsTaxDflt; Text[1])
        {
            Caption = 'SlsTaxDflt';
        }
        field(86; TranDescDflt; Text[1])
        {
            Caption = 'TranDescDflt';
        }
        field(87; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(88; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(89; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(90; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(91; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(92; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(93; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(94; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(95; WarningLvlLimit; Integer)
        {
            Caption = 'WarningLvlLimit';
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