// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 111 "Power BI - Read"
{
    Access = Public;
    Assignable = false;

    Permissions = tabledata "Power BI Blob" = R,
                  tabledata "Power BI Default Selection" = R;
}