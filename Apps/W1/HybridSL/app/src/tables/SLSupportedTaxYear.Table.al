// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47090 "SL Supported Tax Year"
{
    DataPerCompany = false;
    Caption = 'Supported Tax Year';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Tax Year"; Integer)
        {
            Caption = 'Tax Year';
            NotBlank = true;
        }
    }
    keys
    {
        key(PK; "Tax Year")
        {
            Clustered = true;
        }
    }
}