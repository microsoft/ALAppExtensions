// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

permissionset 4007 "HBD - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'HybridBaseDeployment - Read';

    IncludedPermissionSets = "HBD - Objects";

    Permissions = tabledata "Hybrid Company Status" = R,
                    tabledata "Hybrid DA Approval" = R;
}
