// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool;

table 5169 "Contoso Module Dependency"
{
    DataClassification = CustomerContent;
    InherentEntitlements = RimdX;
    InherentPermissions = RimdX;
    Access = Internal;
    Extensible = false;
    DataPerCompany = true;
    ReplicateData = false;

    fields
    {
        field(1; Name; Enum "Contoso Demo Data Module")
        {
            TableRelation = "Contoso Demo Data Module";
        }
        field(2; DependsOn; Enum "Contoso Demo Data Module")
        {
            TableRelation = "Contoso Demo Data Module";
        }
    }

    keys
    {
        key(Key1; Name, DependsOn)
        {
            Clustered = true;
        }
        key(Key2; Name)
        {
        }
    }
}
