// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

enum 40020 "Migration Mapping Type"
{
    Extensible = false;

    value(0; "Replication")
    {
        Caption = 'Replication';
    }
    value(1; "Migration Setup")
    {
        Caption = 'Migration Setup';
    }
}
