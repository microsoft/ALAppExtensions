// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11770 "CZ Compensation - Read CZC"
{
    Access = Internal;
    Assignable = false;
    Caption = 'CZ Compensation - Read';

    IncludedPermissionSets = "CZ Compensation - Objects CZC";

    Permissions = tabledata "Compens. Report Selections CZC" = R,
                  tabledata "Compensation Header CZC" = R,
                  tabledata "Compensation Line CZC" = R,
                  tabledata "Compensations Setup CZC" = R,
                  tabledata "Posted Compensation Header CZC" = R,
                  tabledata "Posted Compensation Line CZC" = R;
}
