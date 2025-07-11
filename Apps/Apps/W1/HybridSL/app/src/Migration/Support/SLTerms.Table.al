// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47045 "SL Terms"
{
    Access = Internal;
    Caption = 'SL Terms';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ApplyTo; Text[1])
        {
            Caption = 'ApplyTo';
        }
        field(2; COD; Integer)
        {
            Caption = 'COD';
        }
        field(3; CreditChk; Integer)
        {
            Caption = 'CreditChk';
        }
        field(4; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(5; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(6; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(7; Cycle; Integer)
        {
            Caption = 'Cycle';
        }
        field(8; Descr; Text[30])
        {
            Caption = 'Descr';
        }
        field(9; DiscIntrv; Integer)
        {
            Caption = 'DiscIntrv';
        }
        field(10; DiscPct; Decimal)
        {
            Caption = 'DiscPct';
        }
        field(11; DiscType; Text[1])
        {
            Caption = 'DiscType';
        }
        field(12; DueIntrv; Integer)
        {
            Caption = 'DueIntrv';
        }
        field(13; DueType; Text[1])
        {
            Caption = 'DueType';
        }
        field(14; Frequency; Text[1])
        {
            Caption = 'Frequency';
        }
        field(15; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(16; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(17; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(18; NbrInstall; Integer)
        {
            Caption = 'NbrInstall';
        }
        field(19; NoteId; Integer)
        {
            Caption = 'NoteId';
        }
        field(20; Options; Text[1])
        {
            Caption = 'Options';
        }
        field(21; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(22; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(23; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(24; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(25; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(26; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(27; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(28; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(29; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(30; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(31; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(32; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(33; TermsId; Text[2])
        {
            Caption = 'TermsId';
        }
        field(34; TermsType; Text[1])
        {
            Caption = 'TermsType';
        }
        field(35; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(36; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(37; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(38; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(39; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(40; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(41; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(42; User8; DateTime)
        {
            Caption = 'User8';
        }
    }

    keys
    {
        key(Key1; TermsId)
        {
            Clustered = true;
        }
    }
}