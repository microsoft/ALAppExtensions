// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47040 "SL Payment Terms"
{
    Access = Internal;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; PYMTRMID; Text[22])
        {
            Caption = 'Payment Terms ID';
        }
        field(2; DUETYPE; Text[1])
        {
            Caption = 'Due Type';
        }
        field(3; DUEDTDS; Integer)
        {
            Caption = 'Due Date/Days';
        }
        field(4; DISCTYPE; Text[1])
        {
            Caption = 'Discount Type';
        }
        field(5; DISCDTDS; Integer)
        {
            Caption = 'Discount Date/Days';
        }
        field(6; DSCPCTAM; Decimal)
        {
            Caption = 'Discount Percent Amount';
        }
        field(7; Descr; Text[30])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; PYMTRMID)
        {
            Clustered = true;
        }
    }
}