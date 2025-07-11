// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47047 "SL APSetup"
{
    Access = Internal;
    Caption = 'SL APSetup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; A1099byCpnyID; Integer)
        {
            Caption = 'A1099byCpnyID';
        }
        field(2; AllowBkupWthld; Integer)
        {
            Caption = 'AllowBkupWthld';
        }
        field(3; APAcct; Text[10])
        {
            Caption = 'APAcct';
        }
        field(4; APSub; Text[24])
        {
            Caption = 'APSub';
        }
        field(5; AutoBatRpt; Integer)
        {
            Caption = 'AutoBatRpt';
        }
        field(6; AutoRef; Integer)
        {
            Caption = 'AutoRef';
        }
        field(7; BkupWthldAcct; Text[10])
        {
            Caption = 'BkupWthldAcct';
        }
        field(8; BkupWthldPct; Decimal)
        {
            Caption = 'BkupWthldPct';
        }
        field(9; BkupWthldSub; Text[24])
        {
            Caption = 'BkupWthldSub';
        }
        field(10; ChkAcct; Text[10])
        {
            Caption = 'ChkAcct';
        }
        field(11; ChkSub; Text[24])
        {
            Caption = 'ChkSub';
        }
        field(12; ClassID; Text[10])
        {
            Caption = 'ClassID';
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
        field(16; Curr1099Yr; Text[4])
        {
            Caption = 'Curr1099Yr';
        }
        field(17; CurrPerNbr; Text[6])
        {
            Caption = 'CurrPerNbr';
        }
        field(18; CY1099Stat; Text[1])
        {
            Caption = 'CY1099Stat';
        }
        field(19; DecPlPrcCst; Integer)
        {
            Caption = 'DecPlPrcCst';
        }
        field(20; DecPlQty; Integer)
        {
            Caption = 'DecPlQty';
        }
        field(21; DfltPPVAccount; Text[10])
        {
            Caption = 'DfltPPVAccount';
        }
        field(22; DfltPPVSub; Text[24])
        {
            Caption = 'DfltPPVSub';
        }
        field(23; DirectDeposit; Text[1])
        {
            Caption = 'DirectDeposit';
        }
        field(24; DisableBkupWthldMsg; Integer)
        {
            Caption = 'DisableBkupWthldMsg';
        }
        field(25; DiscTknAcct; Text[10])
        {
            Caption = 'DiscTknAcct';
        }
        field(26; DiscTknSub; Text[24])
        {
            Caption = 'DiscTknSub';
        }
        field(27; DupInvcChk; Integer)
        {
            Caption = 'DupInvcChk';
        }
        field(28; ExcludeFreight; Text[1])
        {
            Caption = 'ExcludeFreight';
        }
        field(29; ExpAcct; Text[10])
        {
            Caption = 'ExpAcct';
        }
        field(30; ExpSub; Text[24])
        {
            Caption = 'ExpSub';
        }
        field(31; GLPostOpt; Text[1])
        {
            Caption = 'GLPostOpt';
        }
        field(32; "Init"; Integer)
        {
            Caption = 'Init';
        }
        field(33; LastBatNbr; Text[10])
        {
            Caption = 'LastBatNbr';
        }
        field(34; LastECheckNum; Text[10])
        {
            Caption = 'LastECheckNum';
        }
        field(35; LastRefNbr; Text[10])
        {
            Caption = 'LastRefNbr';
        }
        field(36; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(37; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(38; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(39; MCuryBatRpt; Integer)
        {
            Caption = 'MCuryBatRpt';
        }
        field(40; Next1099Yr; Text[4])
        {
            Caption = 'Next1099Yr';
        }
        field(41; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(42; NY1099Stat; Text[1])
        {
            Caption = 'NY1099Stat';
        }
        field(43; PastDue00; Integer)
        {
            Caption = 'PastDue00';
        }
        field(44; PastDue01; Integer)
        {
            Caption = 'PastDue01';
        }
        field(45; PastDue02; Integer)
        {
            Caption = 'PastDue02';
        }
        field(46; PerDupChk; Integer)
        {
            Caption = 'PerDupChk';
        }
        field(47; PerNbr; Text[6])
        {
            Caption = 'PerNbr';
        }
        field(48; PerRetHist; Integer)
        {
            Caption = 'PerRetHist';
        }
        field(49; PerRetTran; Integer)
        {
            Caption = 'PerRetTran';
        }
        field(50; PMAvail; Integer)
        {
            Caption = 'PMAvail';
        }
        field(51; PPayAcct; Text[10])
        {
            Caption = 'PPayAcct';
        }
        field(52; PPaySub; Text[24])
        {
            Caption = 'PPaySub';
        }
        field(53; PPVAcct; Text[10])
        {
            Caption = 'PPVAcct';
        }
        field(54; PPVSub; Text[24])
        {
            Caption = 'PPVSub';
        }
        field(55; Req_PO_for_PP; Integer)
        {
            Caption = 'Req_PO_for_PP';
        }
        field(56; RetChkRcncl; Integer)
        {
            Caption = 'RetChkRcncl';
        }
        field(57; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(58; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(59; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(60; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(61; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(62; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(63; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(64; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(65; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(66; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(67; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(68; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(69; SetupId; Text[2])
        {
            Caption = 'SetupId';
        }
        field(70; SlsTax; Integer)
        {
            Caption = 'SlsTax';
        }
        field(71; SlsTaxDflt; Text[1])
        {
            Caption = 'SlsTaxDflt';
        }
        field(72; Terms; Text[2])
        {
            Caption = 'Terms';
        }
        field(73; TranDescDflt; Text[1])
        {
            Caption = 'TranDescDflt';
        }
        field(74; UntlDue00; Integer)
        {
            Caption = 'UntlDue00';
        }
        field(75; UntlDue01; Integer)
        {
            Caption = 'UntlDue01';
        }
        field(76; UntlDue02; Integer)
        {
            Caption = 'UntlDue02';
        }
        field(77; UnvoucheredPOAlrt; Integer)
        {
            Caption = 'UnvoucheredPOAlrt';
        }
        field(78; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(79; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(80; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(81; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(82; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(83; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(84; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(85; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(86; VCVoidDocs; Integer)
        {
            Caption = 'VCVoidDocs';
        }
        field(87; Vend1099Lmt; Decimal)
        {
            Caption = 'Vend1099Lmt';
        }
        field(88; VendViewDflt; Text[1])
        {
            Caption = 'VendViewDflt';
        }
        field(89; ZCPrint; Integer)
        {
            Caption = 'ZCPrint';
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