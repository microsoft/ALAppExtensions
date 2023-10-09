// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Utilities;

table 4151 "Persistent Blob"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    fields
    {
        field(1; "Primary Key"; BigInteger)
        {
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; Blob; BLOB)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

