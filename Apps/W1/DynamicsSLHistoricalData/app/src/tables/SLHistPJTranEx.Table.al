// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

table 42831 "SL Hist. PJTranEx"
{
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; batch_id; Text[10])
        {
            Caption = 'batch_id';
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
        field(5; detail_num; Integer)
        {
            Caption = 'detail_num';
        }
        field(6; equip_id; Text[10])
        {
            Caption = 'equip_id';
        }
        field(7; fiscalno; Text[6])
        {
            Caption = 'fiscalno';
        }
        field(8; invtid; Text[30])
        {
            Caption = 'invtid';
        }
        field(9; lotsernbr; Text[25])
        {
            Caption = 'lotsernbr';
        }
        field(10; lupd_datetime; DateTime)
        {
            Caption = 'lupd_datetime';
        }
        field(11; lupd_prog; Text[8])
        {
            Caption = 'lupd_prog';
        }
        field(12; lupd_user; Text[10])
        {
            Caption = 'lupd_user';
        }
        field(13; orderlineref; Text[5])
        {
            Caption = 'orderlineref';
        }
        field(14; ordnbr; Text[15])
        {
            Caption = 'ordnbr';
        }
        field(15; shipperid; Text[15])
        {
            Caption = 'shipperid';
        }
        field(16; shipperlineref; Text[5])
        {
            Caption = 'shipperlineref';
        }
        field(17; siteid; Text[10])
        {
            Caption = 'siteid';
        }
        field(18; system_cd; Text[2])
        {
            Caption = 'system_cd';
        }
        field(19; tr_id11; Text[30])
        {
            Caption = 'tr_id11';
        }
        field(20; tr_id12; Text[30])
        {
            Caption = 'tr_id12';
        }
        field(21; tr_id13; Text[30])
        {
            Caption = 'tr_id13';
        }
        field(22; tr_id14; Text[16])
        {
            Caption = 'tr_id14';
        }
        field(23; tr_id15; Text[16])
        {
            Caption = 'tr_id15';
        }
        field(24; tr_id16; Text[16])
        {
            Caption = 'tr_id16';
        }
        field(25; tr_id17; Text[4])
        {
            Caption = 'tr_id17';
        }
        field(26; tr_id18; Text[4])
        {
            Caption = 'tr_id18';
        }
        field(27; tr_id19; Text[4])
        {
            Caption = 'tr_id19';
        }
        field(28; tr_id20; Text[40])
        {
            Caption = 'tr_id20';
        }
        field(29; tr_id21; Text[40])
        {
            Caption = 'tr_id21';
        }
        field(30; tr_id22; Date)
        {
            Caption = 'tr_id22';
        }
        field(31; tr_status2; Text[1])
        {
            Caption = 'tr_status2';
        }
        field(32; tr_status3; Text[1])
        {
            Caption = 'tr_status3';
        }
        field(33; whseloc; Text[10])
        {
            Caption = 'whseloc';
        }
    }

    keys
    {
        key(PK; fiscalno, system_cd, batch_id, detail_num)
        {
            Clustered = true;
        }
    }
}