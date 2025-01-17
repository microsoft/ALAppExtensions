// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item.Substitution;

table 7339 "Search API Response"
{
    Access = Internal;
    TableType = Temporary;
    InherentEntitlements = X;
    InherentPermissions = X;

    fields
    {
        field(1; SysId; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(2; Score; Decimal)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; SysId)
        {
            Clustered = true;
        }
    }
}