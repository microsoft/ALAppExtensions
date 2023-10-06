// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

table 1998 "Primary Guided Experience Item"
{
    Caption = 'Primary Guided Experience Item';
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    ReplicateData = false;

    fields
    {
        field(1; "Extension ID"; Guid)
        {
            Caption = 'Extension';
            DataClassification = SystemMetadata;
        }
        field(2; "Primary Setup"; Guid)
        {
            Caption = 'Primary Setup';
            DataClassification = SystemMetadata;
            TableRelation = "Guided Experience Item".SystemId where("Extension ID" = field("Extension ID"));
        }
    }

    keys
    {
        key(Key1; "Extension ID")
        {
            Clustered = true;
        }
    }
}