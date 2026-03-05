// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47095 "SL Address"
{
    Caption = 'SL Address';
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
        field(3; AddrId; Text[10])
        {
            Caption = 'AddrId';
        }
        field(4; Attn; Text[30])
        {
            Caption = 'Attn';
        }
        field(5; City; Text[30])
        {
            Caption = 'City';
        }
        field(6; Country; Text[3])
        {
            Caption = 'Country';
        }
        field(7; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(8; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(9; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(10; Fax; Text[30])
        {
            Caption = 'Fax';
        }
        field(11; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(12; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(13; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(14; Name; Text[60])
        {
            Caption = 'Name';
        }
        field(15; Phone; Text[30])
        {
            Caption = 'Phone';
        }
        field(16; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(17; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(18; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
            AutoFormatType = 0;
        }
        field(19; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
            AutoFormatType = 0;
        }
        field(20; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
            AutoFormatType = 0;
        }
        field(21; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
            AutoFormatType = 0;
        }
        field(22; S4Future07; Date)
        {
            Caption = 'S4Future07';
        }
        field(23; S4Future08; Date)
        {
            Caption = 'S4Future08';
        }
        field(24; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(25; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(26; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(27; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(28; Salut; Text[30])
        {
            Caption = 'Salut';
        }
        field(29; State; Text[3])
        {
            Caption = 'State';
        }
        field(30; TaxId00; Text[10])
        {
            Caption = 'TaxId00';
        }
        field(31; TaxId01; Text[10])
        {
            Caption = 'TaxId01';
        }
        field(32; TaxId02; Text[10])
        {
            Caption = 'TaxId02';
        }
        field(33; TaxId03; Text[10])
        {
            Caption = 'TaxId03';
        }
        field(34; TaxLocId; Text[15])
        {
            Caption = 'TaxLocId';
        }
        field(35; TaxRegNbr; Text[15])
        {
            Caption = 'TaxRegNbr';
        }
        field(36; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(37; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(38; User3; Decimal)
        {
            Caption = 'User3';
            AutoFormatType = 0;
        }
        field(39; User4; Decimal)
        {
            Caption = 'User4';
            AutoFormatType = 0;
        }
        field(40; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(41; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(42; User7; Date)
        {
            Caption = 'User7';
        }
        field(43; User8; Date)
        {
            Caption = 'User8';
        }
        field(44; User9; Text[45])
        {
            Caption = 'User9';
        }
        field(45; User10; Text[30])
        {
            Caption = 'User10';
        }
        field(46; Zip; Text[10])
        {
            Caption = 'Zip';
        }
    }

    keys
    {
        key(PK; AddrId)
        {
            Clustered = true;
        }
    }
}