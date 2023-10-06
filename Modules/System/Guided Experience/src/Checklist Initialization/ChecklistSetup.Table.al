// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

table 1996 "Checklist Setup"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    ReplicateData = false;

    fields
    {
        field(1; "Is Setup Done"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Is Setup Done';
        }

        field(2; "Is Setup in Progress"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Is Setup in Progress';
        }

        field(3; "DateTime when Setup Started"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Date when Setup Started';
        }
    }

    keys
    {
        key(key1; "Is Setup Done")
        {
            Clustered = true;
        }
    }
}