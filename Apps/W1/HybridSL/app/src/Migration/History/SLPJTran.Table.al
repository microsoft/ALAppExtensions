// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace MSFT.DataMigration.SL;

table 47105 "SL PJTran"
{
    Access = Internal;
    Caption = 'SL PJTran';
    DataClassification = CustomerContent;

    fields
    {
        field(1; acct; Text[16])
        {
            Caption = 'acct';
        }
        field(2; alloc_flag; Text[1])
        {
            Caption = 'alloc_flag';
        }
        field(3; amount; Decimal)
        {
            Caption = 'amount';
            AutoFormatType = 0;
        }
        field(4; BaseCuryId; Text[4])
        {
            Caption = 'BaseCuryId';
        }
        field(5; batch_id; Text[10])
        {
            Caption = 'batch_id';
        }
        field(6; batch_type; Text[4])
        {
            Caption = 'batch_type';
        }
        field(7; bill_batch_id; Text[10])
        {
            Caption = 'bill_batch_id';
        }
        field(8; CpnyId; Text[10])
        {
            Caption = 'CpnyId';
        }
        field(9; crtd_datetime; DateTime)
        {
            Caption = 'crtd_datetime';
        }
        field(10; crtd_prog; Text[8])
        {
            Caption = 'crtd_prog';
        }
        field(11; crtd_user; Text[10])
        {
            Caption = 'crtd_user';
        }
        field(12; CuryEffDate; Date)
        {
            Caption = 'CuryEffDate';
        }
        field(13; CuryId; Text[4])
        {
            Caption = 'CuryId';
        }
        field(14; CuryMultDiv; Text[1])
        {
            Caption = 'CuryMultDiv';
        }
        field(15; CuryRate; Decimal)
        {
            Caption = 'CuryRate';
            AutoFormatType = 0;
        }
        field(16; CuryRateType; Text[6])
        {
            Caption = 'CuryRateType';
        }
        field(17; CuryTranamt; Decimal)
        {
            Caption = 'CuryTranamt';
            AutoFormatType = 0;
        }
        field(18; data1; Text[16])
        {
            Caption = 'data1';
        }
        field(19; detail_num; Integer)
        {
            Caption = 'detail_num';
        }
        field(20; employee; Text[10])
        {
            Caption = 'employee';
        }
        field(21; fiscalno; Text[6])
        {
            Caption = 'fiscalno';
        }
        field(22; gl_acct; Text[10])
        {
            Caption = 'gl_acct';
        }
        field(23; gl_subacct; Text[24])
        {
            Caption = 'gl_subacct';
        }
        field(24; lupd_datetime; DateTime)
        {
            Caption = 'lupd_datetime';
        }
        field(25; lupd_prog; Text[8])
        {
            Caption = 'lupd_prog';
        }
        field(26; lupd_user; Text[10])
        {
            Caption = 'lupd_user';
        }
        field(27; noteid; Integer)
        {
            Caption = 'noteid';
        }
        field(28; pjt_entity; Text[32])
        {
            Caption = 'pjt_entity';
        }
        field(29; post_date; Date)
        {
            Caption = 'post_date';
        }
        field(30; ProjCury_amount; Decimal)
        {
            Caption = 'ProjCury_amount';
            AutoFormatType = 0;
        }
        field(31; ProjCuryEffDate; Date)
        {
            Caption = 'ProjCuryEffDate';
        }
        field(32; ProjCuryId; Text[4])
        {
            Caption = 'ProjCuryId';
        }
        field(33; ProjCuryMultiDiv; Text[1])
        {
            Caption = 'ProjCuryMultiDiv';
        }
        field(34; ProjCuryRate; Decimal)
        {
            Caption = 'ProjCuryRate';
            AutoFormatType = 0;
        }
        field(35; ProjCuryRateType; Text[6])
        {
            Caption = 'ProjCuryRateType';
        }
        field(36; project; Text[16])
        {
            Caption = 'project';
        }
        field(37; Subcontract; Text[16])
        {
            Caption = 'Subcontract';
        }
        field(38; SubTask_Name; Text[50])
        {
            Caption = 'SubTask_Name';
        }
        field(39; system_cd; Text[2])
        {
            Caption = 'system_cd';
        }
        field(40; TranProjCuryEffDate; Date)
        {
            Caption = 'TranProjCuryEffDate';
        }
        field(41; TranProjCuryId; Text[4])
        {
            Caption = 'TranProjCuryId';
        }
        field(42; TranProjCuryMultiDiv; Text[1])
        {
            Caption = 'TranProjCuryMultiDiv';
        }
        field(43; TranProjCuryRate; Decimal)
        {
            Caption = 'TranProjCuryRate';
            AutoFormatType = 0;
        }
        field(44; TranProjCuryRateType; Text[6])
        {
            Caption = 'TranProjCuryRateType';
        }
        field(45; trans_date; Date)
        {
            Caption = 'trans_date';
        }
        field(46; tr_comment; Text[100])
        {
            Caption = 'tr_comment';
        }
        field(47; tr_id01; Text[30])
        {
            Caption = 'tr_id01';
        }
        field(48; tr_id02; Text[30])
        {
            Caption = 'tr_id02';
        }
        field(49; tr_id03; Text[16])
        {
            Caption = 'tr_id03';
        }
        field(50; tr_id04; Text[16])
        {
            Caption = 'tr_id04';
        }
        field(51; tr_id05; Text[4])
        {
            Caption = 'tr_id05';
        }
        field(52; tr_id06; Decimal)
        {
            Caption = 'tr_id06';
            AutoFormatType = 0;
        }
        field(53; tr_id07; Decimal)
        {
            Caption = 'tr_id07';
            AutoFormatType = 0;
        }
        field(54; tr_id08; Date)
        {
            Caption = 'tr_id08';
        }
        field(55; tr_id09; Date)
        {
            Caption = 'tr_id09';
        }
        field(56; tr_id10; Integer)
        {
            Caption = 'tr_id10';
        }
        field(57; tr_id23; Text[30])
        {
            Caption = 'tr_id23';
        }
        field(58; tr_id24; Text[20])
        {
            Caption = 'tr_id24';
        }
        field(59; tr_id25; Text[20])
        {
            Caption = 'tr_id25';
        }
        field(60; tr_id26; Text[10])
        {
            Caption = 'tr_id26';
        }
        field(61; tr_id27; Text[4])
        {
            Caption = 'tr_id27';
        }
        field(62; tr_id28; Decimal)
        {
            Caption = 'tr_id28';
            AutoFormatType = 0;
        }
        field(63; tr_id29; Date)
        {
            Caption = 'tr_id29';
        }
        field(64; tr_id30; Integer)
        {
            Caption = 'tr_id30';
        }
        field(65; tr_id31; Decimal)
        {
            Caption = 'tr_id31';
            AutoFormatType = 0;
        }
        field(66; tr_id32; Decimal)
        {
            Caption = 'tr_id32';
            AutoFormatType = 0;
        }
        field(67; tr_status; Text[10])
        {
            Caption = 'tr_status';
        }
        field(68; unit_of_measure; Text[10])
        {
            Caption = 'unit_of_measure';
        }
        field(69; units; Decimal)
        {
            Caption = 'units';
            AutoFormatType = 0;
        }
        field(70; user1; Text[30])
        {
            Caption = 'user1';
        }
        field(71; user2; Text[30])
        {
            Caption = 'user2';
        }
        field(72; user3; Decimal)
        {
            Caption = 'user3';
            AutoFormatType = 0;
        }
        field(73; user4; Decimal)
        {
            Caption = 'user4';
            AutoFormatType = 0;
        }
        field(74; vendor_num; Text[15])
        {
            Caption = 'vendor_num';
        }
        field(75; voucher_line; Integer)
        {
            Caption = 'voucher_line';
        }
        field(76; voucher_num; Text[10])
        {
            Caption = 'voucher_num';
        }
    }

    keys
    {
        key(Key1; fiscalno, system_cd, batch_id, detail_num)
        {
            Clustered = true;
        }
    }
}