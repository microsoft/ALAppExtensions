// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47044 "SL SegDef"
{
    Access = Internal;
    Caption = 'SL SegDef';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Active; Integer)
        {
            Caption = 'Active';
        }
        field(2; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(3; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(4; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(5; Description; Text[30])
        {
            Caption = 'Description';
        }
        field(6; FieldClass; Text[3])
        {
            Caption = 'FieldClass';
        }
        field(7; FieldClassName; Text[15])
        {
            Caption = 'FieldClassName';
        }
        field(8; ID; Text[24])
        {
            Caption = 'ID';
        }
        field(9; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(10; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(11; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(12; SegNumber; Text[2])
        {
            Caption = 'SegNumber';
        }
        field(13; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(14; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(15; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(16; User4; Decimal)
        {
            Caption = 'User4';
        }
    }

    keys
    {
        key(Key1; FieldClassName, SegNumber, ID)
        {
            Clustered = true;
        }
    }
}