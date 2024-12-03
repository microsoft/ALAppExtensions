// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47002 "SL Period List Work Table"
{
    Access = Internal;
    Caption = 'SL Period List Work Table';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Period; Integer)
        {
        }
        field(2; MonthDay; Text[4])
        {
        }
        field(3; Year; Text[4])
        {
        }
    }
    keys
    {
        key(Key1; period)
        {
            Clustered = true;
        }
    }
}
