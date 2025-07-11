// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

table 42800 "SL Hist. APAdjust"
{
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; AdjAmt; Decimal)
        {
            Caption = 'AdjAmt';
        }
        field(2; AdjBatNbr; Text[10])
        {
            Caption = 'AdjBatNbr';
        }
        field(3; AdjBkupWthld; Decimal)
        {
            Caption = 'AdjBkupWthld';
        }
        field(4; AdjdDocType; Text[2])
        {
            Caption = 'AdjdDocType';
        }
        field(5; AdjDiscAmt; Decimal)
        {
            Caption = 'AdjDiscAmt';
        }
        field(6; AdjdRefNbr; Text[10])
        {
            Caption = 'AdjdRefNbr';
        }
        field(7; AdjgAcct; Text[10])
        {
            Caption = 'AdjgAcct';
        }
        field(8; AdjgDocDate; DateTime)
        {
            Caption = 'AdjgDocDate';
        }
        field(9; AdjgDocType; Text[2])
        {
            Caption = 'AdjgDocType';
        }
        field(10; AdjgPerPost; Text[6])
        {
            Caption = 'AdjgPerPost';
        }
        field(11; AdjgRefNbr; Text[10])
        {
            Caption = 'AdjgRefNbr';
        }
        field(12; AdjgSub; Text[24])
        {
            Caption = 'AdjgSub';
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
        field(16; CuryAdjdAmt; Decimal)
        {
            Caption = 'CuryAdjdAmt';
        }
        field(17; CuryAdjdBkupWthld; Decimal)
        {
            Caption = 'CuryAdjdBkupWthld';
        }
        field(18; CuryAdjdCuryId; Text[4])
        {
            Caption = 'CuryAdjdCuryId';
        }
        field(19; CuryAdjdDiscAmt; Decimal)
        {
            Caption = 'CuryAdjdDiscAmt';
        }
        field(20; CuryAdjdMultDiv; Text[1])
        {
            Caption = 'CuryAdjdMultDiv';
        }
        field(21; CuryAdjdRate; Decimal)
        {
            Caption = 'CuryAdjdRate';
        }
        field(22; CuryAdjgAmt; Decimal)
        {
            Caption = 'CuryAdjgAmt';
        }
        field(23; CuryAdjgBkupWthld; Decimal)
        {
            Caption = 'CuryAdjgBkupWthld';
        }
        field(24; CuryAdjgDiscAmt; Decimal)
        {
            Caption = 'CuryAdjgDiscAmt';
        }
        field(25; CuryRGOLAmt; Decimal)
        {
            Caption = 'CuryRGOLAmt';
        }
        field(26; DateAppl; DateTime)
        {
            Caption = 'DateAppl';
        }
        field(27; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(28; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(29; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(30; PerAppl; Text[6])
        {
            Caption = 'PerAppl';
        }
        field(31; PrePay_RefNbr; Text[10])
        {
            Caption = 'PrePay_RefNbr';
        }
        field(32; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(33; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(34; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(35; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(36; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(37; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(38; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(39; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(40; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(41; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(42; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(43; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(44; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(45; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(46; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(47; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(48; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(49; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(50; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(51; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(52; VendId; Text[15])
        {
            Caption = 'VendId';
        }
    }

    keys
    {
        key(PK; AdjdRefNbr, AdjdDocType, AdjgRefNbr, AdjgDocType, VendId, AdjgAcct, AdjgSub)
        {
            Clustered = true;
        }
    }
}