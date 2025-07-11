// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 10500 "Making Tax Digital - Full"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Making Tax Digital - RM";

    Permissions = tabledata "MTD Liability" = ID,
                  tabledata "MTD Payment" = ID,
                  tabledata "MTD Return Details" = ID,
                  tabledata "MTD Missing Fraud Prev. Hdr" = ID,
                  tabledata "MTD Session Fraud Prev. Hdr" = ID,
                  tabledata "MTD Default Fraud Prev. Hdr" = ID;
}
