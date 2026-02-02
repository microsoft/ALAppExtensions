// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

permissionset 47201 "SL Migration US - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'SL Migration US - Read';

    IncludedPermissionSets = "SL Migration US - Objects";
    Permissions = tabledata "SL Supported Tax Year" = R,
                  tabledata "SL 1099 Box Mapping" = R,
                  tabledata "SL 1099 Migration Log" = R;
}