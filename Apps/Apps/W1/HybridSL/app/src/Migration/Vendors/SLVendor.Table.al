// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47049 "SL Vendor"
{
    Access = Internal;
    Caption = 'SL Vendor';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Addr1; Text[60])
        {
            Caption = 'Addr1';
        }
        field(2; Addr2; Text[60])
        {
            Caption = 'Addr2';
        }
        field(3; APAcct; Text[10])
        {
            Caption = 'APAcct';
        }
        field(4; APSub; Text[24])
        {
            Caption = 'APSub';
        }
        field(5; Attn; Text[30])
        {
            Caption = 'Attn';
        }
        field(6; BkupWthld; Integer)
        {
            Caption = 'BkupWthld';
        }
        field(7; City; Text[30])
        {
            Caption = 'City';
        }
        field(8; ClassID; Text[10])
        {
            Caption = 'ClassID';
        }
        field(9; ContTwc1099; Integer)
        {
            Caption = 'ContTwc1099';
        }
        field(10; Country; Text[3])
        {
            Caption = 'Country';
        }
        field(11; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(12; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(13; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(14; Curr1099Yr; Text[4])
        {
            Caption = 'Curr1099Yr';
        }
        field(15; CuryId; Text[4])
        {
            Caption = 'CuryId';
        }
        field(16; CuryRateType; Text[6])
        {
            Caption = 'CuryRateType';
        }
        field(17; DfltBox; Text[2])
        {
            Caption = 'DfltBox';
        }
        field(18; DfltOrdFromId; Text[10])
        {
            Caption = 'DfltOrdFromId';
        }
        field(19; DfltPurchaseType; Text[2])
        {
            Caption = 'DfltPurchaseType';
        }
        field(20; DirectDeposit; Text[1])
        {
            Caption = 'DirectDeposit';
        }
        field(21; DocPublishingFlag; Text[1])
        {
            Caption = 'DocPublishingFlag';
        }
        field(22; EMailAddr; Text[80])
        {
            Caption = 'EMailAddr';
        }
        field(23; ExcludeFreight; Text[1])
        {
            Caption = 'ExcludeFreight';
        }
        field(24; ExpAcct; Text[10])
        {
            Caption = 'ExpAcct';
        }
        field(25; ExpSub; Text[24])
        {
            Caption = 'ExpSub';
        }
        field(26; Fax; Text[30])
        {
            Caption = 'Fax';
        }
        field(27; LCCode; Text[10])
        {
            Caption = 'LCCode';
        }
        field(28; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(29; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(30; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(31; MultiChk; Integer)
        {
            Caption = 'MultiChk';
        }
        field(32; Name; Text[60])
        {
            Caption = 'Name';
        }
        field(33; Next1099Yr; Text[4])
        {
            Caption = 'Next1099Yr';
        }
        field(34; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(35; PayDateDflt; Text[1])
        {
            Caption = 'PayDateDflt';
        }
        field(36; PerNbr; Text[6])
        {
            Caption = 'PerNbr';
        }
        field(37; Phone; Text[30])
        {
            Caption = 'Phone';
        }
        field(38; PmtMethod; Text[1])
        {
            Caption = 'PmtMethod';
        }
        field(39; PPayAcct; Text[10])
        {
            Caption = 'PPayAcct';
        }
        field(40; PPaySub; Text[24])
        {
            Caption = 'PPaySub';
        }
        field(41; RcptPctAct; Text[1])
        {
            Caption = 'RcptPctAct';
        }
        field(42; RcptPctMax; Decimal)
        {
            Caption = 'RcptPctMax';
        }
        field(43; RcptPctMin; Decimal)
        {
            Caption = 'RcptPctMin';
        }
        field(44; RecipientName2; Text[40])
        {
            Caption = 'RecipientName2';
        }
        field(45; RemitAddr1; Text[60])
        {
            Caption = 'RemitAddr1';
        }
        field(46; RemitAddr2; Text[60])
        {
            Caption = 'RemitAddr2';
        }
        field(47; RemitAttn; Text[30])
        {
            Caption = 'RemitAttn';
        }
        field(48; RemitCity; Text[30])
        {
            Caption = 'RemitCity';
        }
        field(49; RemitCountry; Text[3])
        {
            Caption = 'RemitCountry';
        }
        field(50; RemitFax; Text[30])
        {
            Caption = 'RemitFax';
        }
        field(51; RemitName; Text[60])
        {
            Caption = 'RemitName';
        }
        field(52; RemitPhone; Text[30])
        {
            Caption = 'RemitPhone';
        }
        field(53; RemitSalut; Text[30])
        {
            Caption = 'RemitSalut';
        }
        field(54; RemitState; Text[3])
        {
            Caption = 'RemitState';
        }
        field(55; RemitZip; Text[10])
        {
            Caption = 'RemitZip';
        }
        field(56; ReqBkupWthld; Integer)
        {
            Caption = 'ReqBkupWthld';
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
        field(69; Salut; Text[30])
        {
            Caption = 'Salut';
        }
        field(70; State; Text[3])
        {
            Caption = 'State';
        }
        field(71; Status; Text[1])
        {
            Caption = 'Status';
        }
        field(72; TaxDflt; Text[1])
        {
            Caption = 'TaxDflt';
        }
        field(73; TaxId00; Text[10])
        {
            Caption = 'TaxId00';
        }
        field(74; TaxId01; Text[10])
        {
            Caption = 'TaxId01';
        }
        field(75; TaxId02; Text[10])
        {
            Caption = 'TaxId02';
        }
        field(76; TaxId03; Text[10])
        {
            Caption = 'TaxId03';
        }
        field(77; TaxLocId; Text[15])
        {
            Caption = 'TaxLocId';
        }
        field(78; TaxPost; Text[1])
        {
            Caption = 'TaxPost';
        }
        field(79; TaxRegNbr; Text[15])
        {
            Caption = 'TaxRegNbr';
        }
        field(80; Terms; Text[2])
        {
            Caption = 'Terms';
        }
        field(81; TIN; Text[11])
        {
            Caption = 'TIN';
        }
        field(82; TINNAME; Text[60])
        {
            Caption = 'TINNAME';
        }
        field(83; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(84; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(85; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(86; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(87; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(88; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(89; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(90; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(91; Vend1099; Integer)
        {
            Caption = 'Vend1099';
        }
        field(92; Vend1099AddrType; Text[1])
        {
            Caption = 'Vend1099AddrType';
        }
        field(93; VendId; Text[15])
        {
            Caption = 'VendId';
        }
        field(94; Zip; Text[10])
        {
            Caption = 'Zip';
        }
    }

    keys
    {
        key(Key1; VendId)
        {
            Clustered = true;
        }
    }
}