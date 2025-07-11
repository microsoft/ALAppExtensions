// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47005 "SL Fiscal Periods"
{
    Access = Internal;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; PeriodID; Integer)
        {
            Caption = 'Fiscal Period';
        }
        field(2; Year1; Integer)
        {
            Caption = 'Year';
        }
        field(3; PeriodDT; Date)
        {
            Caption = 'Period Start Date';
        }
        field(4; PerEndDT; Date)
        {
            Caption = 'Period End Date';
        }
    }

    keys
    {
        key(Key1; PeriodID, Year1)
        {
            Clustered = true;
        }
    }
}