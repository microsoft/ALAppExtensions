// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 99 "Reporting - Edit"
{
    Access = Public;
    Assignable = False;

#if not CLEAN22
#pragma warning disable AL0432 // Disabling deprecation warning since these tables are being moved on prem and hence still need permissions
#endif
    Permissions = tabledata "Report Layout" = RIMD,
#if not CLEAN22
#pragma warning restore AL0432
#endif
                  tabledata "Report Layout Definition" = R,
                  tabledata "Tenant Report Layout" = RIMD,
                  tabledata "Tenant Report Layout Selection" = RIMD;
}
