#if not CLEANSCHEMA31
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47069 "SL PJProj"
{
    Access = Internal;
    Caption = 'SL PJProj';
    DataClassification = CustomerContent;
    ObsoleteReason = 'Replaced by table SL PJProj Buffer.';
#if not CLEAN28
    ObsoleteState = Pending;
    ObsoleteTag = '28.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '31.0';
#endif

    fields
    {
        field(1; alloc_method_cd; Text[4])
        {
            Caption = 'alloc_method_cd';
        }
        field(2; alloc_method2_cd; Text[4])
        {
            Caption = 'alloc_method2_cd';
        }
        field(3; BaseCuryId; Text[4])
        {
            Caption = 'BaseCuryId';
        }
        field(4; bf_values_switch; Text[1])
        {
            Caption = 'bf_values_switch';
        }
        field(5; billcuryfixedrate; Decimal)
        {
            Caption = 'billcuryfixedrate';
        }
        field(6; billcuryid; Text[4])
        {
            Caption = 'billcuryid';
        }
        field(7; billing_setup; Text[1])
        {
            Caption = 'billing_setup';
        }
        field(8; billratetypeid; Text[6])
        {
            Caption = 'billratetypeid';
        }
        field(9; budget_type; Text[1])
        {
            Caption = 'budget_type';
        }
        field(10; budget_version; Text[2])
        {
            Caption = 'budget_version';
        }
        field(11; contract; Text[16])
        {
            Caption = 'contract';
        }
        field(12; contract_type; Text[4])
        {
            Caption = 'contract_type';
        }
        field(13; CpnyId; Text[10])
        {
            Caption = 'CpnyId';
        }
        field(14; crtd_datetime; DateTime)
        {
            Caption = 'crtd_datetime';
        }
        field(15; crtd_prog; Text[8])
        {
            Caption = 'crtd_prog';
        }
        field(16; crtd_user; Text[10])
        {
            Caption = 'crtd_user';
        }
        field(17; CuryId; Text[4])
        {
            Caption = 'CuryId';
        }
        field(18; CuryRateType; Text[6])
        {
            Caption = 'CuryRateType';
        }
        field(19; customer; Text[15])
        {
            Caption = 'customer';
        }
        field(20; end_date; DateTime)
        {
            Caption = 'end_date';
        }
        field(21; EndDateChk; Integer)
        {
            Caption = 'EndDateChk';
        }
        field(22; gl_subacct; Text[24])
        {
            Caption = 'gl_subacct';
        }
        field(23; labor_gl_acct; Text[10])
        {
            Caption = 'labor_gl_acct';
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
        field(27; manager1; Text[10])
        {
            Caption = 'manager1';
        }
        field(28; manager2; Text[10])
        {
            Caption = 'manager2';
        }
        field(29; MSPData; Text[50])
        {
            Caption = 'MSPData';
        }
        field(30; MSPInterface; Text[1])
        {
            Caption = 'MSPInterface';
        }
        field(31; MSPProj_ID; Integer)
        {
            Caption = 'MSPProj_ID';
        }
        field(32; noteid; Integer)
        {
            Caption = 'noteid';
        }
        field(33; opportunityID; Text[36])
        {
            Caption = 'opportunityID';
        }
        field(34; pm_id01; Text[30])
        {
            Caption = 'pm_id01';
        }
        field(35; pm_id02; Text[30])
        {
            Caption = 'pm_id02';
        }
        field(36; pm_id03; Text[16])
        {
            Caption = 'pm_id03';
        }
        field(37; pm_id04; Text[16])
        {
            Caption = 'pm_id04';
        }
        field(38; pm_id05; Text[4])
        {
            Caption = 'pm_id05';
        }
        field(39; pm_id06; Decimal)
        {
            Caption = 'pm_id06';
        }
        field(40; pm_id07; Decimal)
        {
            Caption = 'pm_id07';
        }
        field(41; pm_id08; DateTime)
        {
            Caption = 'pm_id08';
        }
        field(42; pm_id09; DateTime)
        {
            Caption = 'pm_id09';
        }
        field(43; pm_id10; Integer)
        {
            Caption = 'pm_id10';
        }
        field(44; pm_id31; Text[30])
        {
            Caption = 'pm_id31';
        }
        field(45; pm_id32; Text[30])
        {
            Caption = 'pm_id32';
        }
        field(46; pm_id33; Text[20])
        {
            Caption = 'pm_id33';
        }
        field(47; pm_id34; Text[20])
        {
            Caption = 'pm_id34';
        }
        field(48; pm_id35; Text[10])
        {
            Caption = 'pm_id35';
        }
        field(49; pm_id36; Text[10])
        {
            Caption = 'pm_id36';
        }
        field(50; pm_id37; Text[4])
        {
            Caption = 'pm_id37';
        }
        field(51; pm_id38; Decimal)
        {
            Caption = 'pm_id38';
        }
        field(52; pm_id39; DateTime)
        {
            Caption = 'pm_id39';
        }
        field(53; pm_id40; Integer)
        {
            Caption = 'pm_id40';
        }
        field(54; probability; Integer)
        {
            Caption = 'probability';
        }
        field(55; ProjCuryId; Text[4])
        {
            Caption = 'ProjCuryId';
        }
        field(56; ProjCuryRateType; Text[6])
        {
            Caption = 'ProjCuryRateType';
        }
        field(57; ProjCuryBudEffDate; DateTime)
        {
            Caption = 'ProjCuryBudEffDate';
        }
        field(58; ProjCuryBudMultiDiv; Text[1])
        {
            Caption = 'ProjCuryBudMultiDiv';
        }
        field(59; ProjCuryBudRate; Decimal)
        {
            Caption = 'ProjCuryBudRate';
        }
        field(60; ProjCuryRevenueRec; Text[1])
        {
            Caption = 'ProjCuryRevenueRec';
        }
        field(61; project; Text[16])
        {
            Caption = 'project';
        }
        field(62; project_desc; Text[60])
        {
            Caption = 'project_desc';
        }
        field(63; purchase_order_num; Text[20])
        {
            Caption = 'purchase_order_num';
        }
        field(64; rate_table_id; Text[4])
        {
            Caption = 'rate_table_id';
        }
        field(65; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(66; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(67; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(68; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(69; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(70; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(71; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(72; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(73; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(74; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(75; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(76; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(77; shiptoid; Text[10])
        {
            Caption = 'shiptoid';
        }
        field(78; slsperid; Text[10])
        {
            Caption = 'slsperid';
        }
        field(79; start_date; DateTime)
        {
            Caption = 'start_date';
        }
        field(80; status_08; Text[1])
        {
            Caption = 'status_08';
        }
        field(81; status_09; Text[1])
        {
            Caption = 'status_09';
        }
        field(82; status_10; Text[1])
        {
            Caption = 'status_10';
        }
        field(83; status_11; Text[1])
        {
            Caption = 'status_11';
        }
        field(84; status_12; Text[1])
        {
            Caption = 'status_12';
        }
        field(85; status_13; Text[1])
        {
            Caption = 'status_13';
        }
        field(86; status_14; Text[1])
        {
            Caption = 'status_14';
        }
        field(87; status_15; Text[1])
        {
            Caption = 'status_15';
        }
        field(88; status_16; Text[1])
        {
            Caption = 'status_16';
        }
        field(89; status_17; Text[1])
        {
            Caption = 'status_17';
        }
        field(90; status_18; Text[1])
        {
            Caption = 'status_18';
        }
        field(91; status_19; Text[1])
        {
            Caption = 'status_19';
        }
        field(92; status_20; Text[1])
        {
            Caption = 'status_20';
        }
        field(93; status_ap; Text[1])
        {
            Caption = 'status_ap';
        }
        field(94; status_ar; Text[1])
        {
            Caption = 'status_ar';
        }
        field(95; status_gl; Text[1])
        {
            Caption = 'status_gl';
        }
        field(96; status_in; Text[1])
        {
            Caption = 'status_in';
        }
        field(97; status_lb; Text[1])
        {
            Caption = 'status_lb';
        }
        field(98; status_pa; Text[1])
        {
            Caption = 'status_pa';
        }
        field(99; status_po; Text[1])
        {
            Caption = 'status_po';
        }
        field(100; user1; Text[30])
        {
            Caption = 'user1';
        }
        field(101; user2; Text[30])
        {
            Caption = 'user2';
        }
        field(102; user3; Decimal)
        {
            Caption = 'user3';
        }
        field(103; user4; Decimal)
        {
            Caption = 'user4';
        }
    }

    keys
    {
        key(PK; project)
        {
            Clustered = true;
        }
    }
}
#endif
