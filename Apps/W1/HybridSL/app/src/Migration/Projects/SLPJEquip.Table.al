#if not CLEANSCHEMA31
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47067 "SL PJEquip"
{
    Access = Internal;
    Caption = 'SL PJEquip';
    DataClassification = CustomerContent;
    ObsoleteReason = 'Replaced by table SL PJEquip Buffer.';
#if not CLEAN28
    ObsoleteState = Pending;
    ObsoleteTag = '28.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '31.0';
#endif

    fields
    {
        field(1; cpnyId; Text[10])
        {
            Caption = 'cpnyId';
        }
        field(2; crtd_datetime; DateTime)
        {
            Caption = 'crtd_datetime';
        }
        field(3; crtd_prog; Text[8])
        {
            Caption = 'crtd_prog';
        }
        field(4; crtd_user; Text[10])
        {
            Caption = 'crtd_user';
        }
        field(5; eq_id01; Text[30])
        {
            Caption = 'eq_id01';
        }
        field(6; eq_id02; Text[30])
        {
            Caption = 'eq_id02';
        }
        field(7; eq_id03; Text[16])
        {
            Caption = 'eq_id03';
        }
        field(8; eq_id04; Text[16])
        {
            Caption = 'eq_id04';
        }
        field(9; eq_id05; Text[4])
        {
            Caption = 'eq_id05';
        }
        field(10; eq_id06; Decimal)
        {
            Caption = 'eq_id06';
        }
        field(11; eq_id07; Decimal)
        {
            Caption = 'eq_id07';
        }
        field(12; eq_id08; DateTime)
        {
            Caption = 'eq_id08';
        }
        field(13; eq_id09; DateTime)
        {
            Caption = 'eq_id09';
        }
        field(14; eq_id10; Integer)
        {
            Caption = 'eq_id10';
        }
        field(15; eq_id11; Text[30])
        {
            Caption = 'eq_id11';
        }
        field(16; eq_id12; Text[30])
        {
            Caption = 'eq_id12';
        }
        field(17; eq_id13; Text[4])
        {
            Caption = 'eq_id13';
        }
        field(18; eq_id14; Text[4])
        {
            Caption = 'eq_id14';
        }
        field(19; eq_id15; Text[4])
        {
            Caption = 'eq_id15';
        }
        field(20; eq_id16; Text[4])
        {
            Caption = 'eq_id16';
        }
        field(21; eq_id17; Text[2])
        {
            Caption = 'eq_id17';
        }
        field(22; eq_id18; Text[2])
        {
            Caption = 'eq_id18';
        }
        field(23; eq_id19; Text[2])
        {
            Caption = 'eq_id19';
        }
        field(24; eq_id20; Text[2])
        {
            Caption = 'eq_id20';
        }
        field(25; er_id01; Text[30])
        {
            Caption = 'er_id01';
        }
        field(26; er_id02; Text[30])
        {
            Caption = 'er_id02';
        }
        field(27; er_id03; Text[16])
        {
            Caption = 'er_id03';
        }
        field(28; er_id04; Text[16])
        {
            Caption = 'er_id04';
        }
        field(29; er_id05; Text[4])
        {
            Caption = 'er_id05';
        }
        field(30; er_id06; Decimal)
        {
            Caption = 'er_id06';
        }
        field(31; er_id07; Decimal)
        {
            Caption = 'er_id07';
        }
        field(32; er_id08; DateTime)
        {
            Caption = 'er_id08';
        }
        field(33; er_id09; DateTime)
        {
            Caption = 'er_id09';
        }
        field(34; er_id10; Integer)
        {
            Caption = 'er_id10';
        }
        field(35; equip_desc; Text[60])
        {
            Caption = 'equip_desc';
        }
        field(36; equip_id; Text[10])
        {
            Caption = 'equip_id';
        }
        field(37; equip_type; Text[10])
        {
            Caption = 'equip_type';
        }
        field(38; gl_subacct; Text[24])
        {
            Caption = 'gl_subacct';
        }
        field(39; lupd_datetime; DateTime)
        {
            Caption = 'lupd_datetime';
        }
        field(40; lupd_prog; Text[8])
        {
            Caption = 'lupd_prog';
        }
        field(41; lupd_user; Text[10])
        {
            Caption = 'lupd_user';
        }
        field(42; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(43; project_costbasis; Text[16])
        {
            Caption = 'project_costbasis';
        }
        field(44; status; Text[1])
        {
            Caption = 'status';
        }
    }

    keys
    {
        key(PK; equip_id)
        {
            Clustered = true;
        }
    }
}
#endif
