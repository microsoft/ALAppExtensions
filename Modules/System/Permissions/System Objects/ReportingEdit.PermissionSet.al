// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 99 "Reporting - Edit"
{
    Access = Public;
    Assignable = False;

    Permissions = tabledata "Report Layout" = RIMD,
                  tabledata "Report Layout Definition" = R,
                  tabledata "Tenant Report Layout" = R,
                  tabledata "Tenant Report Layout Selection" = RIMD;
}
