#if not CLEANSCHEMA31
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47070 "SL PJEQRate"
{
    Access = Internal;
    Caption = 'SL PJEQRate';
    DataClassification = CustomerContent;
    ObsoleteReason = 'Replaced by table SL PJEQRate Buffer.';
#if not CLEAN28
    ObsoleteState = Pending;
    ObsoleteTag = '28.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '31.0';
#endif

    fields
    {
        field(1; crtd_datetime; DateTime)
        {
            Caption = 'crtd_datetime';
        }
        field(2; crtd_prog; Text[8])
        {
            Caption = 'crtd_prog';
        }
        field(3; crtd_user; Text[10])
        {
            Caption = 'crtd_user';
        }
        field(4; ec_id01; Text[30])
        {
            Caption = 'ec_id01';
        }
        field(5; ec_id02; Text[30])
        {
            Caption = 'ec_id02';
        }
        field(6; ec_id03; Text[16])
        {
            Caption = 'ec_id03';
        }
        field(7; ec_id04; Text[16])
        {
            Caption = 'ec_id04';
        }
        field(8; ec_id05; Text[4])
        {
            Caption = 'ec_id05';
        }
        field(9; ec_id06; Decimal)
        {
            Caption = 'ec_id06';
        }
        field(10; ec_id07; Decimal)
        {
            Caption = 'ec_id07';
        }
        field(11; ec_id08; DateTime)
        {
            Caption = 'ec_id08';
        }
        field(12; ec_id09; DateTime)
        {
            Caption = 'ec_id09';
        }
        field(13; ec_id10; Integer)
        {
            Caption = 'ec_id10';
        }
        field(14; ec_id11; Text[30])
        {
            Caption = 'ec_id11';
        }
        field(15; ec_id12; Text[30])
        {
            Caption = 'ec_id12';
        }
        field(16; ec_id13; Text[16])
        {
            Caption = 'ec_id13';
        }
        field(17; ec_id14; Text[16])
        {
            Caption = 'ec_id14';
        }
        field(18; ec_id15; Text[4])
        {
            Caption = 'ec_id15';
        }
        field(19; ec_id16; Decimal)
        {
            Caption = 'ec_id16';
        }
        field(20; ec_id17; Decimal)
        {
            Caption = 'ec_id17';
        }
        field(21; ec_id18; DateTime)
        {
            Caption = 'ec_id18';
        }
        field(22; ec_id19; DateTime)
        {
            Caption = 'ec_id19';
        }
        field(23; ec_id20; Integer)
        {
            Caption = 'ec_id20';
        }
        field(24; effect_date; DateTime)
        {
            Caption = 'effect_date';
        }
        field(25; equip_id; Text[10])
        {
            Caption = 'equip_id';
        }
        field(26; lupd_datetime; DateTime)
        {
            Caption = 'lupd_datetime';
        }
        field(27; lupd_prog; Text[8])
        {
            Caption = 'lupd_prog';
        }
        field(28; lupd_user; Text[10])
        {
            Caption = 'lupd_user';
        }
        field(29; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(30; project; Text[16])
        {
            Caption = 'project';
        }
        field(31; rate1; Decimal)
        {
            Caption = 'rate1';
        }
        field(32; rate2; Decimal)
        {
            Caption = 'rate2';
        }
        field(33; rate3; Decimal)
        {
            Caption = 'rate3';
        }
        field(34; unit_of_measure; Text[10])
        {
            Caption = 'unit_of_measure';
        }
    }

    keys
    {
        key(PK; equip_id, project, effect_date)
        {
            Clustered = true;
        }
    }
}
#endif
