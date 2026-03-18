// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

permissionset 47200 "SL Migration US - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'SL Migration US - Edit';

    IncludedPermissionSets = "SL Migration US - Read";
    Permissions = tabledata "SL Supported Tax Year" = IMD,
                  tabledata "SL 1099 Box Mapping" = IMD,
                  tabledata "SL 1099 Migration Log" = IMD;
}