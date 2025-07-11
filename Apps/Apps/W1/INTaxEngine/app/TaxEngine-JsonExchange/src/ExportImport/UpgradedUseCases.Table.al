// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.JsonExchange;

table 20361 "Upgraded Use Cases"
{
    DataClassification = SystemMetadata;
    Extensible = false;

    fields
    {
        field(1; "Use Case ID"; Guid)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Use Case ID")
        {
            Clustered = true;
        }
    }
}
