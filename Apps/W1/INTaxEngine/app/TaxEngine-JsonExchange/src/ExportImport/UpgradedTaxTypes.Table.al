// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.JsonExchange;

table 20363 "Upgraded Tax Types"
{
    DataClassification = SystemMetadata;
    Extensible = false;

    fields
    {
        field(1; "Tax Type"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Tax Type")
        {
            Clustered = true;
        }
    }
}
