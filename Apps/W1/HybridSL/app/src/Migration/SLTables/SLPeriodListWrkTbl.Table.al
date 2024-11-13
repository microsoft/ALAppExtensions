// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47002 SLPeriodListWrkTbl
{
    Access = Internal;
    Caption = 'SLPeriodListWrkTbl';
    DataClassification = CustomerContent;

    fields
    {
        field(1; period; Integer)
        {
            Caption = 'period';
        }
        field(2; md; Text[4])
        {
            Caption = 'md';
        }
        field(3; year; Text[4])
        {
            Caption = 'year';
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
