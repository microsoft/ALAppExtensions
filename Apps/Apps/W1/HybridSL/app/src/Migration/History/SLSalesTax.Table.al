// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47058 "SL SalesTax"
{
    Access = Internal;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; "AccruTaxAcct"; Text[10])
        {
            Caption = 'AccruTaxAcct';
        }
        field(2; "AccruTaxSubAcct"; Text[24])
        {
            Caption = 'AccruTaxSubAcct';
        }
        field(3; "AdjByTermsDisc"; Text[1])
        {
            Caption = 'AdjByTermsDisc';
        }
        field(4; "ApplTermDisc"; Text[1])
        {
            Caption = 'ApplTermDisc';
        }
        field(5; "ApplTermsDiscTax"; Integer)
        {
            Caption = 'ApplTermsDiscTax';
        }
        field(6; "APTaxPtDate"; Text[1])
        {
            Caption = 'APTaxPtDate';
        }
        field(7; "ARTaxPtDate"; Text[1])
        {
            Caption = 'ARTaxPtDate';
        }
        field(8; "CatExcept00"; Text[10])
        {
            Caption = 'CatExcept00';
        }
        field(9; "CatExcept01"; Text[10])
        {
            Caption = 'CatExcept01';
        }
        field(10; "CatExcept02"; Text[10])
        {
            Caption = 'CatExcept02';
        }
        field(11; "CatExcept03"; Text[10])
        {
            Caption = 'CatExcept03';
        }
        field(12; "CatExcept04"; Text[10])
        {
            Caption = 'CatExcept04';
        }
        field(13; "CatExcept05"; Text[10])
        {
            Caption = 'CatExcept05';
        }
        field(14; "CatFlg"; Text[1])
        {
            Caption = 'CatFlg';
        }
        field(15; "Crtd_DateTime"; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(16; "Crtd_Prog"; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(17; "Crtd_User"; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(18; "Descr"; Text[30])
        {
            Caption = 'Descr';
        }
        field(19; "Exemption"; Text[1])
        {
            Caption = 'Exemption';
        }
        field(20; "ExemTaxId"; Text[10])
        {
            Caption = 'ExemTaxId';
        }
        field(21; "Exp_to_Proj_Sw"; Integer)
        {
            Caption = 'Exp_to_Proj_Sw';
        }
        field(22; "ExpTaxAcct"; Text[10])
        {
            Caption = 'ExpTaxAcct';
        }
        field(23; "ExpTaxSub"; Text[24])
        {
            Caption = 'ExpTaxSub';
        }
        field(24; "FilingLoc"; Text[10])
        {
            Caption = 'FilingLoc';
        }
        field(25; "GroupDetCnt"; Integer)
        {
            Caption = 'GroupDetCnt';
        }
        field(26; "GroupID"; Text[10])
        {
            Caption = 'GroupID';
        }
        field(27; "GroupRule"; Text[1])
        {
            Caption = 'GroupRule';
        }
        field(28; "InclFrt"; Text[1])
        {
            Caption = 'InclFrt';
        }
        field(29; "InclInDocTot"; Text[1])
        {
            Caption = 'InclInDocTot';
        }
        field(30; "Inclmisc"; Text[1])
        {
            Caption = 'Inclmisc';
        }
        field(31; "LiabTaxAcct"; Text[10])
        {
            Caption = 'LiabTaxAcct';
        }
        field(32; "LiabTaxSub"; Text[24])
        {
            Caption = 'LiabTaxSub';
        }
        field(33; "LocalCode"; Text[15])
        {
            Caption = 'LocalCode';
        }
        field(34; "LongId"; Text[15])
        {
            Caption = 'LongId';
        }
        field(35; "LUpd_DateTime"; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(36; "LUpd_Prog"; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(37; "LUpd_User"; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(38; "Lvl2Exmpt"; Integer)
        {
            Caption = 'Lvl2Exmpt';
        }
        field(39; "NewRateDate"; DateTime)
        {
            Caption = 'NewRateDate';
        }
        field(40; "NewTaxRate"; Decimal)
        {
            Caption = 'NewTaxRate';
        }
        field(41; "NoteId"; Integer)
        {
            Caption = 'NoteId';
        }
        field(42; "OldTaxRate"; Decimal)
        {
            Caption = 'OldTaxRate';
        }
        field(43; "OPTaxPtDate"; Text[1])
        {
            Caption = 'OPTaxPtDate';
        }
        field(44; "POTaxPtDate"; Text[1])
        {
            Caption = 'POTaxPtDate';
        }
        field(45; "PrcTaxIncl"; Text[1])
        {
            Caption = 'PrcTaxIncl';
        }
        field(46; "PurTaxAcct"; Text[10])
        {
            Caption = 'PurTaxAcct';
        }
        field(47; "PurTaxDiscAcct"; Text[10])
        {
            Caption = 'PurTaxDiscAcct';
        }
        field(48; "PurTaxDiscSub"; Text[24])
        {
            Caption = 'PurTaxDiscSub';
        }
        field(49; "PurTaxSub"; Text[24])
        {
            Caption = 'PurTaxSub';
        }
        field(50; "RateAboveMax"; Decimal)
        {
            Caption = 'RateAboveMax';
        }
        field(51; "S4Future01"; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(52; "S4Future02"; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(53; "S4Future03"; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(54; "S4Future04"; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(55; "S4Future05"; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(56; "S4Future06"; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(57; "S4Future07"; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(58; "S4Future08"; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(59; "S4Future09"; Integer)
        {
            Caption = 'S4Future09';
        }
        field(60; "S4Future10"; Integer)
        {
            Caption = 'S4Future10';
        }
        field(61; "S4Future11"; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(62; "S4Future12"; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(63; "SlsTaxAcct"; Text[10])
        {
            Caption = 'SlsTaxAcct';
        }
        field(64; "SlsTaxDiscAcct"; Text[10])
        {
            Caption = 'SlsTaxDiscAcct';
        }
        field(65; "SlsTaxDiscSub"; Text[24])
        {
            Caption = 'SlsTaxDiscSub';
        }
        field(66; "SlsTaxSub"; Text[24])
        {
            Caption = 'SlsTaxSub';
        }
        field(67; "TaxAuthLvl"; Text[1])
        {
            Caption = 'TaxAuthLvl';
        }
        field(68; "TaxBasis"; Text[1])
        {
            Caption = 'TaxBasis';
        }
        field(69; "TaxCalcLvl"; Text[1])
        {
            Caption = 'TaxCalcLvl';
        }
        field(70; "TaxCalcMeth"; Text[1])
        {
            Caption = 'TaxCalcMeth';
        }
        field(71; "TaxCalcType"; Text[1])
        {
            Caption = 'TaxCalcType';
        }
        field(72; "TaxId"; Text[10])
        {
            Caption = 'TaxId';
        }
        field(73; "TaxRate"; Decimal)
        {
            Caption = 'TaxRate';
        }
        field(74; "TaxRvsdDate"; DateTime)
        {
            Caption = 'TaxRvsdDate';
        }
        field(75; "TaxType"; Text[1])
        {
            Caption = 'TaxType';
        }
        field(76; "TxblAdjPct"; Decimal)
        {
            Caption = 'TxblAdjPct';
        }
        field(77; "TxblMax"; Decimal)
        {
            Caption = 'TxblMax';
        }
        field(78; "TxblMin"; Decimal)
        {
            Caption = 'TxblMin';
        }
        field(79; "TxblMinMaxCuryID"; Text[4])
        {
            Caption = 'TxblMinMaxCuryID';
        }
        field(80; "User1"; Text[30])
        {
            Caption = 'User1';
        }
        field(81; "User2"; Text[30])
        {
            Caption = 'User2';
        }
        field(82; "User3"; Decimal)
        {
            Caption = 'User3';
        }
        field(83; "User4"; Decimal)
        {
            Caption = 'User4';
        }
        field(84; "User5"; Text[10])
        {
            Caption = 'User5';
        }
        field(85; "User6"; Text[10])
        {
            Caption = 'User6';
        }
        field(86; "User7"; DateTime)
        {
            Caption = 'User7';
        }
        field(87; "User8"; DateTime)
        {
            Caption = 'User8';
        }
        field(88; "VendID"; Text[15])
        {
            Caption = 'VendID';
        }
        field(89; "VoucherTax"; Integer)
        {
            Caption = 'VoucherTax';
        }
    }

    keys
    {
        key(Key1; TaxType, TaxId)
        {
            Clustered = true;
        }
    }
}