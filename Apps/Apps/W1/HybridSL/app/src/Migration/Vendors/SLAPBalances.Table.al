// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47046 "SL AP_Balances"
{
    Access = Internal;
    Caption = 'SL AP_Balances';
    DataClassification = CustomerContent;

    fields
    {
        field(1; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(2; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(3; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(4; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(5; CurrBal; Decimal)
        {
            Caption = 'CurrBal';
        }
        field(6; CuryID; Text[4])
        {
            Caption = 'CuryID';
        }
        field(7; CYBox00; Decimal)
        {
            Caption = 'CYBox00';
        }
        field(8; CYBox01; Decimal)
        {
            Caption = 'CYBox01';
        }
        field(9; CYBox02; Decimal)
        {
            Caption = 'CYBox02';
        }
        field(10; CYBox03; Decimal)
        {
            Caption = 'CYBox03';
        }
        field(11; CYBox04; Decimal)
        {
            Caption = 'CYBox04';
        }
        field(12; CYBox05; Decimal)
        {
            Caption = 'CYBox05';
        }
        field(13; CYBox06; Decimal)
        {
            Caption = 'CYBox06';
        }
        field(14; CYBox07; Decimal)
        {
            Caption = 'CYBox07';
        }
        field(15; CYBox08; Decimal)
        {
            Caption = 'CYBox08';
        }
        field(16; CYBox09; Decimal)
        {
            Caption = 'CYBox09';
        }
        field(17; CYBox10; Decimal)
        {
            Caption = 'CYBox10';
        }
        field(18; CYBox11; Decimal)
        {
            Caption = 'CYBox11';
        }
        field(19; CYBox12; Decimal)
        {
            Caption = 'CYBox12';
        }
        field(20; CYBox13; Decimal)
        {
            Caption = 'CYBox13';
        }
        field(21; CYBox14; Decimal)
        {
            Caption = 'CYBox14';
        }
        field(22; CYBox15; Decimal)
        {
            Caption = 'CYBox15';
        }
        field(23; CYFor01; Text[3])
        {
            Caption = 'CYFor01';
        }
        field(24; CYInterest; Decimal)
        {
            Caption = 'CYInterest';
        }
        field(25; FutureBal; Decimal)
        {
            Caption = 'FutureBal';
        }
        field(26; LastChkDate; DateTime)
        {
            Caption = 'LastChkDate';
        }
        field(27; LastVODate; DateTime)
        {
            Caption = 'LastVODate';
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
        field(31; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(32; NYBox00; Decimal)
        {
            Caption = 'NYBox00';
        }
        field(33; NYBox01; Decimal)
        {
            Caption = 'NYBox01';
        }
        field(34; NYBox02; Decimal)
        {
            Caption = 'NYBox02';
        }
        field(35; NYBox03; Decimal)
        {
            Caption = 'NYBox03';
        }
        field(36; NYBox04; Decimal)
        {
            Caption = 'NYBox04';
        }
        field(37; NYBox05; Decimal)
        {
            Caption = 'NYBox05';
        }
        field(38; NYBox06; Decimal)
        {
            Caption = 'NYBox06';
        }
        field(39; NYBox07; Decimal)
        {
            Caption = 'NYBox07';
        }
        field(40; NYBox08; Decimal)
        {
            Caption = 'NYBox08';
        }
        field(41; NYBox09; Decimal)
        {
            Caption = 'NYBox09';
        }
        field(42; NYBox10; Decimal)
        {
            Caption = 'NYBox10';
        }
        field(43; NYBox11; Decimal)
        {
            Caption = 'NYBox11';
        }
        field(44; NYBox12; Decimal)
        {
            Caption = 'NYBox12';
        }
        field(45; NYBox13; Decimal)
        {
            Caption = 'NYBox13';
        }
        field(46; NYBox14; Decimal)
        {
            Caption = 'NYBox14';
        }
        field(47; NYBox15; Decimal)
        {
            Caption = 'NYBox15';
        }
        field(48; NYFor01; Text[3])
        {
            Caption = 'NYFor01';
        }
        field(49; NYInterest; Decimal)
        {
            Caption = 'NYInterest';
        }
        field(50; PerNbr; Text[6])
        {
            Caption = 'PerNbr';
        }
        field(51; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(52; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(53; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(54; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(55; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(56; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(57; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(58; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(59; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(60; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(61; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(62; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(63; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(64; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(65; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(66; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(67; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(68; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(69; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(70; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(71; VendID; Text[15])
        {
            Caption = 'VendID';
        }
    }

    keys
    {
        key(Key1; VendID, CpnyID)
        {
            Clustered = true;
        }
    }
}