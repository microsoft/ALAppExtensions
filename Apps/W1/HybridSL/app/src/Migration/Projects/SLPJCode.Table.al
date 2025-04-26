// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47060 "SL PJCode"
{
    Access = Internal;
    Caption = 'SL PJCode';
    DataClassification = CustomerContent;

    fields
    {
        field(1; code_type; Text[4])
        {
            Caption = 'code_type';
        }
        field(2; code_value; Text[30])
        {
            Caption = 'code_value';
        }
        field(3; code_value_desc; Text[30])
        {
            Caption = 'code_value_desc';
        }
        field(4; crtd_datetime; DateTime)
        {
            Caption = 'crtd_datetime';
        }
        field(5; crtd_prog; Text[8])
        {
            Caption = 'crtd_prog';
        }
        field(6; crtd_user; Text[10])
        {
            Caption = 'crtd_user';
        }
        field(7; data1; Text[30])
        {
            Caption = 'data1';
        }
        field(8; data2; Text[16])
        {
            Caption = 'data2';
        }
        field(9; data3; DateTime)
        {
            Caption = 'data3';
        }
        field(10; data4; Decimal)
        {
            Caption = 'data4';
        }
        field(11; lupd_datetime; DateTime)
        {
            Caption = 'lupd_datetime';
        }
        field(12; lupd_prog; Text[8])
        {
            Caption = 'lupd_prog';
        }
        field(13; lupd_user; Text[10])
        {
            Caption = 'lupd_user';
        }
        field(14; noteid; Integer)
        {
            Caption = 'noteid';
        }
    }

    keys
    {
        key(PK; code_type, code_value)
        {
            Clustered = true;
        }
    }
}