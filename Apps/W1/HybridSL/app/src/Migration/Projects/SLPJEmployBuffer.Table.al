// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47079 "SL PJEmploy Buffer"
{
    Access = Internal;
    Caption = 'SL PJEmploy';
    DataClassification = CustomerContent;

    fields
    {
        field(1; BaseCuryId; Text[4])
        {
            Caption = 'BaseCuryId';
        }
        field(2; CpnyId; Text[10])
        {
            Caption = 'CpnyId';
        }
        field(3; crtd_datetime; DateTime)
        {
            Caption = 'crtd_datetime';
        }
        field(4; crtd_prog; Text[8])
        {
            Caption = 'crtd_prog';
        }
        field(5; crtd_user; Text[10])
        {
            Caption = 'crtd_user';
        }
        field(6; CuryId; Text[4])
        {
            Caption = 'CuryId';
        }
        field(7; CuryRateType; Text[6])
        {
            Caption = 'CuryRateType';
        }
        field(8; date_hired; Date)
        {
            Caption = 'date_hired';
        }
        field(9; date_terminated; Date)
        {
            Caption = 'date_terminated';
        }
        field(10; employee; Text[10])
        {
            Caption = 'employee';
        }
        field(11; emp_name; Text[60])
        {
            Caption = 'emp_name';
        }
        field(12; emp_status; Text[1])
        {
            Caption = 'emp_status';
        }
        field(13; emp_type_cd; Text[4])
        {
            Caption = 'emp_type_cd';
        }
        field(14; em_id01; Text[30])
        {
            Caption = 'em_id01';
        }
        field(15; em_id02; Text[30])
        {
            Caption = 'em_id02';
        }
        field(16; em_id03; Text[50])
        {
            Caption = 'em_id03';
        }
        field(17; em_id04; Text[16])
        {
            Caption = 'em_id04';
        }
        field(18; em_id05; Text[4])
        {
            Caption = 'em_id05';
        }
        field(19; em_id06; Decimal)
        {
            Caption = 'em_id06';
        }
        field(20; em_id07; Decimal)
        {
            Caption = 'em_id07';
        }
        field(21; em_id08; Date)
        {
            Caption = 'em_id08';
        }
        field(22; em_id09; Date)
        {
            Caption = 'em_id09';
        }
        field(23; em_id10; Integer)
        {
            Caption = 'em_id10';
        }
        field(24; em_id11; Text[30])
        {
            Caption = 'em_id11';
        }
        field(25; em_id12; Text[30])
        {
            Caption = 'em_id12';
        }
        field(26; em_id13; Text[20])
        {
            Caption = 'em_id13';
        }
        field(27; em_id14; Text[20])
        {
            Caption = 'em_id14';
        }
        field(28; em_id15; Text[10])
        {
            Caption = 'em_id15';
        }
        field(29; em_id16; Text[10])
        {
            Caption = 'em_id16';
        }
        field(30; em_id17; Text[4])
        {
            Caption = 'em_id17';
        }
        field(31; em_id18; Decimal)
        {
            Caption = 'em_id18';
        }
        field(32; em_id19; Date)
        {
            Caption = 'em_id19';
        }
        field(33; em_id20; Integer)
        {
            Caption = 'em_id20';
        }
        field(34; em_id21; Text[10])
        {
            Caption = 'em_id21';
        }
        field(35; em_id22; Text[10])
        {
            Caption = 'em_id22';
        }
        field(36; em_id23; Text[10])
        {
            Caption = 'em_id23';
        }
        field(37; em_id24; Text[10])
        {
            Caption = 'em_id24';
        }
        field(38; em_id25; Text[10])
        {
            Caption = 'em_id25';
        }
        field(39; exp_approval_max; Decimal)
        {
            Caption = 'exp_approval_max';
        }
        field(40; gl_subacct; Text[24])
        {
            Caption = 'gl_subacct';
        }
        field(41; lupd_datetime; DateTime)
        {
            Caption = 'lupd_datetime';
        }
        field(42; lupd_prog; Text[8])
        {
            Caption = 'lupd_prog';
        }
        field(43; lupd_user; Text[10])
        {
            Caption = 'lupd_user';
        }
        field(44; manager1; Text[10])
        {
            Caption = 'manager1';
        }
        field(45; manager2; Text[10])
        {
            Caption = 'manager2';
        }
        field(46; MSPData; Text[50])
        {
            Caption = 'MSPData';
        }
        field(47; MSPInterface; Text[1])
        {
            Caption = 'MSPInterface';
        }
        field(48; MSPRes_UID; Integer)
        {
            Caption = 'MSPRes_UID';
        }
        field(49; MSPType; Text[1])
        {
            Caption = 'MSPType';
        }
        field(50; noteid; Integer)
        {
            Caption = 'noteid';
        }
        field(51; placeholder; Text[1])
        {
            Caption = 'placeholder';
        }
        field(52; projExec; Integer)
        {
            Caption = 'projExec';
        }
        field(53; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(54; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(55; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(56; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(57; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(58; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(59; S4Future07; Date)
        {
            Caption = 'S4Future07';
        }
        field(60; S4Future08; Date)
        {
            Caption = 'S4Future08';
        }
        field(61; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(62; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(63; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(64; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(65; stdday; Integer)
        {
            Caption = 'stdday';
        }
        field(66; Stdweek; Integer)
        {
            Caption = 'Stdweek';
        }
        field(67; Subcontractor; Text[1])
        {
            Caption = 'Subcontractor';
        }
        field(68; user1; Text[30])
        {
            Caption = 'user1';
        }
        field(69; user2; Text[30])
        {
            Caption = 'user2';
        }
        field(70; user3; Decimal)
        {
            Caption = 'user3';
        }
        field(71; user4; Decimal)
        {
            Caption = 'user4';
        }
        field(72; user_id; Text[50])
        {
            Caption = 'user_id';
        }
        field(73; VacaTot; Decimal)
        {
            Caption = 'VacaTot';
        }
        field(74; VacaBal; Decimal)
        {
            Caption = 'VacaBal';
        }
        field(75; VacaProjectID; Text[16])
        {
            Caption = 'VacaProjectID';
        }
        field(76; VacaTaskID; Text[32])
        {
            Caption = 'VacaTaskID';
        }
        field(77; VacaLUpd; Date)
        {
            Caption = 'VacaLUpd';
        }
    }

    keys
    {
        key(PK; employee)
        {
            Clustered = true;
        }
    }
}