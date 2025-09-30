// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47083 "SL PJPent Buffer"
{
    Access = Internal;
    Caption = 'SL PJPent';
    DataClassification = CustomerContent;

    fields
    {
        field(1; contract_type; Text[4])
        {
            Caption = 'contract_type';
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
        field(5; end_date; Date)
        {
            Caption = 'end_date';
        }
        field(6; fips_num; Text[10])
        {
            Caption = 'fips_num';
        }
        field(7; labor_class_cd; Text[4])
        {
            Caption = 'labor_class_cd';
        }
        field(8; lupd_datetime; DateTime)
        {
            Caption = 'lupd_datetime';
        }
        field(9; lupd_prog; Text[8])
        {
            Caption = 'lupd_prog';
        }
        field(10; lupd_user; Text[10])
        {
            Caption = 'lupd_user';
        }
        field(11; manager1; Text[10])
        {
            Caption = 'manager1';
        }
        field(12; MSPData; Text[50])
        {
            Caption = 'MSPData';
        }
        field(13; MSPInterface; Text[1])
        {
            Caption = 'MSPInterface';
        }
        field(14; MSPSync; Text[1])
        {
            Caption = 'MSPSync';
        }
        field(15; MSPTask_UID; Integer)
        {
            Caption = 'MSPTask_UID';
        }
        field(16; noteid; Integer)
        {
            Caption = 'noteid';
        }
        field(17; opportunityProduct; Text[36])
        {
            Caption = 'opportunityProduct';
        }
        field(18; pe_id01; Text[30])
        {
            Caption = 'pe_id01';
        }
        field(19; pe_id02; Text[30])
        {
            Caption = 'pe_id02';
        }
        field(20; pe_id03; Text[16])
        {
            Caption = 'pe_id03';
        }
        field(21; pe_id04; Text[16])
        {
            Caption = 'pe_id04';
        }
        field(22; pe_id05; Text[4])
        {
            Caption = 'pe_id05';
        }
        field(23; pe_id06; Decimal)
        {
            Caption = 'pe_id06';
        }
        field(24; pe_id07; Decimal)
        {
            Caption = 'pe_id07';
        }
        field(25; pe_id08; Date)
        {
            Caption = 'pe_id08';
        }
        field(26; pe_id09; Date)
        {
            Caption = 'pe_id09';
        }
        field(27; pe_id10; Integer)
        {
            Caption = 'pe_id10';
        }
        field(28; pe_id31; Text[30])
        {
            Caption = 'pe_id31';
        }
        field(29; pe_id32; Text[30])
        {
            Caption = 'pe_id32';
        }
        field(30; pe_id33; Text[20])
        {
            Caption = 'pe_id33';
        }
        field(31; pe_id34; Text[20])
        {
            Caption = 'pe_id34';
        }
        field(32; pe_id35; Text[10])
        {
            Caption = 'pe_id35';
        }
        field(33; pe_id36; Text[10])
        {
            Caption = 'pe_id36';
        }
        field(34; pe_id37; Text[4])
        {
            Caption = 'pe_id37';
        }
        field(35; pe_id38; Decimal)
        {
            Caption = 'pe_id38';
        }
        field(36; pe_id39; Date)
        {
            Caption = 'pe_id39';
        }
        field(37; pe_id40; Integer)
        {
            Caption = 'pe_id40';
        }
        field(38; pjt_entity; Text[32])
        {
            Caption = 'pjt_entity';
        }
        field(39; pjt_entity_desc; Text[60])
        {
            Caption = 'pjt_entity_desc';
        }
        field(40; project; Text[16])
        {
            Caption = 'project';
        }
        field(41; start_date; Date)
        {
            Caption = 'start_date';
        }
        field(42; status_08; Text[1])
        {
            Caption = 'status_08';
        }
        field(43; status_09; Text[1])
        {
            Caption = 'status_09';
        }
        field(44; status_10; Text[1])
        {
            Caption = 'status_10';
        }
        field(45; status_11; Text[1])
        {
            Caption = 'status_11';
        }
        field(46; status_12; Text[1])
        {
            Caption = 'status_12';
        }
        field(47; status_13; Text[1])
        {
            Caption = 'status_13';
        }
        field(48; status_14; Text[1])
        {
            Caption = 'status_14';
        }
        field(49; status_15; Text[1])
        {
            Caption = 'status_15';
        }
        field(50; status_16; Text[1])
        {
            Caption = 'status_16';
        }
        field(51; status_17; Text[1])
        {
            Caption = 'status_17';
        }
        field(52; status_18; Text[1])
        {
            Caption = 'status_18';
        }
        field(53; status_19; Text[1])
        {
            Caption = 'status_19';
        }
        field(54; status_20; Text[1])
        {
            Caption = 'status_20';
        }
        field(55; status_ap; Text[1])
        {
            Caption = 'status_ap';
        }
        field(56; status_ar; Text[1])
        {
            Caption = 'status_ar';
        }
        field(57; status_gl; Text[1])
        {
            Caption = 'status_gl';
        }
        field(58; status_in; Text[1])
        {
            Caption = 'status_in';
        }
        field(59; status_lb; Text[1])
        {
            Caption = 'status_lb';
        }
        field(60; status_pa; Text[1])
        {
            Caption = 'status_pa';
        }
        field(61; status_po; Text[1])
        {
            Caption = 'status_po';
        }
        field(62; user1; Text[30])
        {
            Caption = 'user1';
        }
        field(63; user2; Text[30])
        {
            Caption = 'user2';
        }
        field(64; user3; Decimal)
        {
            Caption = 'user3';
        }
        field(65; user4; Decimal)
        {
            Caption = 'user4';
        }
    }

    keys
    {
        key(PK; project, pjt_entity)
        {
            Clustered = true;
        }
    }
}