// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47006 "SL Account"
{
    Access = Internal;
    Caption = 'SL Account';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Acct; Text[10])
        {
            Caption = 'Acct';
        }
        field(2; AcctType; Text[2])
        {
            Caption = 'AcctType';
        }
        field(3; Acct_Cat; Text[16])
        {
            Caption = 'Acct_Cat';
        }
        field(4; Acct_Cat_SW; Text[1])
        {
            Caption = 'Acct_Cat_SW';
        }
        field(5; Active; Integer)
        {
            Caption = 'Active';
        }
        field(6; ClassID; Text[10])
        {
            Caption = 'ClassID';
        }
        field(7; ConsolAcct; Text[10])
        {
            Caption = 'ConsolAcct';
        }
        field(8; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(9; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(10; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(11; CuryId; Text[4])
        {
            Caption = 'CuryId';
        }
        field(12; Descr; Text[30])
        {
            Caption = 'Descr';
        }
        field(13; Employ_Sw; Text[1])
        {
            Caption = 'Employ_Sw';
        }
        field(14; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(15; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(16; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(17; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(18; RatioGrp; Text[2])
        {
            Caption = 'RatioGrp';
        }
        field(19; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(20; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(21; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(22; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(23; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(24; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(25; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(26; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(27; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(28; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(29; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(30; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(31; SummPost; Text[1])
        {
            Caption = 'SummPost';
        }
        field(32; UnitofMeas; Text[6])
        {
            Caption = 'UnitofMeas';
        }
        field(33; Units_SW; Text[1])
        {
            Caption = 'Units_SW';
        }
        field(34; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(35; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(36; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(37; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(38; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(39; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(40; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(41; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(42; ValidateID; Text[1])
        {
            Caption = 'ValidateID';
        }
    }

    keys
    {
        key(Key1; Acct)
        {
            Clustered = true;
        }
    }
}