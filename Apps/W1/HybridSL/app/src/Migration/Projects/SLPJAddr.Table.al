// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47059 "SL PJAddr"
{
    Access = Internal;
    Caption = 'SL PJAddr';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ad_id01; Text[30])
        {
            Caption = 'ad_id01';
        }
        field(2; ad_id02; Text[30])
        {
            Caption = 'ad_id02';
        }
        field(3; ad_id03; Text[16])
        {
            Caption = 'ad_id03';
        }
        field(4; ad_id04; Text[16])
        {
            Caption = 'ad_id04';
        }
        field(5; ad_id05; Text[4])
        {
            Caption = 'ad_id05';
        }
        field(6; ad_id06; Text[4])
        {
            Caption = 'ad_id06';
        }
        field(7; ad_id07; Decimal)
        {
            Caption = 'ad_id07';
        }
        field(8; ad_id08; DateTime)
        {
            Caption = 'ad_id08';
        }
        field(9; addr_key; Text[48])
        {
            Caption = 'addr_key';
        }
        field(10; addr_key_cd; Text[2])
        {
            Caption = 'addr_key_cd';
        }
        field(11; addr_type_cd; Text[2])
        {
            Caption = 'addr_type_cd';
        }
        field(12; addr1; Text[60])
        {
            Caption = 'addr1';
        }
        field(13; addr2; Text[60])
        {
            Caption = 'addr2';
        }
        field(14; city; Text[30])
        {
            Caption = 'city';
        }
        field(15; comp_name; Text[60])
        {
            Caption = 'comp_name';
        }
        field(16; country; Text[3])
        {
            Caption = 'country';
        }
        field(17; crtd_datetime; DateTime)
        {
            Caption = 'crtd_datetime';
        }
        field(18; crtd_prog; Text[8])
        {
            Caption = 'crtd_prog';
        }
        field(19; crtd_user; Text[10])
        {
            Caption = 'crtd_user';
        }
        field(20; email; Text[80])
        {
            Caption = 'email';
        }
        field(21; fax; Text[15])
        {
            Caption = 'fax';
        }
        field(22; individual; Text[30])
        {
            Caption = 'individual';
        }
        field(23; lupd_datetime; DateTime)
        {
            Caption = 'lupd_datetime';
        }
        field(24; lupd_prog; Text[8])
        {
            Caption = 'lupd_prog';
        }
        field(25; lupd_user; Text[10])
        {
            Caption = 'lupd_user';
        }
        field(26; phone; Text[15])
        {
            Caption = 'phone';
        }
        field(27; state; Text[3])
        {
            Caption = 'state';
        }
        field(28; title; Text[30])
        {
            Caption = 'title';
        }
        field(29; zip; Text[10])
        {
            Caption = 'zip';
        }
        field(30; user1; Text[30])
        {
            Caption = 'user1';
        }
        field(31; user2; Text[30])
        {
            Caption = 'user2';
        }
        field(32; user3; Decimal)
        {
            Caption = 'user3';
        }
        field(33; user4; Decimal)
        {
            Caption = 'user4';
        }
    }

    keys
    {
        key(PK; addr_key_cd, addr_key, addr_type_cd)
        {
            Clustered = true;
        }
    }
}