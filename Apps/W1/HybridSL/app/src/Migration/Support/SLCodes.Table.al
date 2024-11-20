// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47019 "SL Codes"
{
    Access = Internal;
    DataClassification = SystemMetadata;
    ReplicateData = false;

    fields
    {
        field(1; Id; Text[20])
        {
        }
        field(2; Name; Text[50])
        {
        }
        field(3; Description; Text[50])
        {
        }
    }

    keys
    {
        key(Key1; Id, Name)
        {
            Clustered = true;
        }
    }
}