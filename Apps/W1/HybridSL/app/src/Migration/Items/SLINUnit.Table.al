// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47098 "SL INUnit"
{
    Access = Internal;
    Caption = 'SL INUnit';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ClassID; Text[6])
        {
            Caption = 'ClassID';
        }
        field(2; CnvFact; Decimal)
        {
            Caption = 'CnvFact';
            AutoFormatType = 0;
        }
        field(3; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(4; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(5; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(6; FromUnit; Text[6])
        {
            Caption = 'FromUnit';
        }
        field(7; InvtId; Text[30])
        {
            Caption = 'InvtId';
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
        field(11; MultDiv; Text[1])
        {
            Caption = 'MultDiv';
        }
        field(12; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(13; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(14; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(15; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
            AutoFormatType = 0;
        }
        field(16; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
            AutoFormatType = 0;
        }
        field(17; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
            AutoFormatType = 0;
        }
        field(18; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
            AutoFormatType = 0;
        }
        field(19; S4Future07; Date)
        {
            Caption = 'S4Future07';
        }
        field(20; S4Future08; Date)
        {
            Caption = 'S4Future08';
        }
        field(21; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(22; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(23; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(24; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(25; ToUnit; Text[6])
        {
            Caption = 'ToUnit';
        }
        field(26; UnitType; Text[1])
        {
            Caption = 'UnitType';
        }
        field(27; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(28; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(29; User3; Decimal)
        {
            Caption = 'User3';
            AutoFormatType = 0;
        }
        field(30; User4; Decimal)
        {
            Caption = 'User4';
            AutoFormatType = 0;
        }
        field(31; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(32; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(33; User7; Date)
        {
            Caption = 'User7';
        }
        field(34; User8; Date)
        {
            Caption = 'User8';
        }
    }

    keys
    {
        key(PK; UnitType, ClassID, InvtId, FromUnit, ToUnit)
        {
            Clustered = true;
        }
    }
}
