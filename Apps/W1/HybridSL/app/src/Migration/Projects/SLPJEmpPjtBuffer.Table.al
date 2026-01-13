// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47081 "SL PJEmpPjt Buffer"
{
    Access = Internal;
    Caption = 'SL PJEmpPjt';
    DataClassification = CustomerContent;

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
        field(4; employee; Text[10])
        {
            Caption = 'employee';
        }
        field(5; ep_id01; Text[30])
        {
            Caption = 'ep_id01';
        }
        field(6; ep_id02; Text[30])
        {
            Caption = 'ep_id02';
        }
        field(7; ep_id03; Text[16])
        {
            Caption = 'ep_id03';
        }
        field(8; ep_id04; Text[16])
        {
            Caption = 'ep_id04';
        }
        field(9; ep_id05; Text[4])
        {
            Caption = 'ep_id05';
        }
        field(10; ep_id06; Decimal)
        {
            Caption = 'ep_id06';
        }
        field(11; ep_id07; Decimal)
        {
            Caption = 'ep_id07';
        }
        field(12; ep_id08; Date)
        {
            Caption = 'ep_id08';
        }
        field(13; ep_id09; Date)
        {
            Caption = 'ep_id09';
        }
        field(14; ep_id10; Integer)
        {
            Caption = 'ep_id10';
        }
        field(15; effect_date; Date)
        {
            Caption = 'effect_date';
        }
        field(16; labor_class_cd; Text[4])
        {
            Caption = 'labor_class_cd';
        }
        field(17; labor_rate; Decimal)
        {
            Caption = 'labor_rate';
        }
        field(18; lupd_datetime; DateTime)
        {
            Caption = 'lupd_datetime';
        }
        field(19; lupd_prog; Text[8])
        {
            Caption = 'lupd_prog';
        }
        field(20; lupd_user; Text[10])
        {
            Caption = 'lupd_user';
        }
        field(21; noteid; Integer)
        {
            Caption = 'noteid';
        }
        field(22; project; Text[16])
        {
            Caption = 'project';
        }
        field(23; user1; Text[30])
        {
            Caption = 'user1';
        }
        field(24; user2; Text[30])
        {
            Caption = 'user2';
        }
        field(25; user3; Decimal)
        {
            Caption = 'user3';
        }
        field(26; user4; Decimal)
        {
            Caption = 'user4';
        }
    }

    keys
    {
        key(PK; employee, project, effect_date)
        {
            Clustered = true;
        }
    }
}