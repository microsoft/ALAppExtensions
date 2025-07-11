// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47071 "SL CustClass"
{
    Access = Internal;
    Caption = 'SL CustClass';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ARAcct; Text[10])
        {
            Caption = 'ARAcct';
        }
        field(2; ARSub; Text[24])
        {
            Caption = 'ARSub';
        }
        field(3; ClassId; Text[6])
        {
            Caption = 'ClassId';
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
        field(7; Descr; Text[30])
        {
            Caption = 'Descr';
        }
        field(8; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(9; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(10; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(11; NoteId; Integer)
        {
            Caption = 'NoteId';
        }
        field(12; PrcLvlID; Text[10])
        {
            Caption = 'PrcLvlID';
        }
        field(13; PrePayAcct; Text[10])
        {
            Caption = 'PrePayAcct';
        }
        field(14; PrePaySub; Text[24])
        {
            Caption = 'PrePaySub';
        }
        field(15; PriceClass; Text[6])
        {
            Caption = 'PriceClass';
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
        }
        field(19; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(20; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(21; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(22; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(23; S4Future08; DateTime)
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
        field(28; SlsAcct; Text[10])
        {
            Caption = 'SlsAcct';
        }
        field(29; SlsSub; Text[24])
        {
            Caption = 'SlsSub';
        }
        field(30; Terms; Text[2])
        {
            Caption = 'Terms';
        }
        field(31; TradeDisc; Decimal)
        {
            Caption = 'TradeDisc';
        }
        field(32; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(33; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(34; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(35; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(36; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(37; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(38; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(39; User8; DateTime)
        {
            Caption = 'User8';
        }
    }

    keys
    {
        key(PK; ClassId)
        {
            Clustered = true;
        }
    }
}
