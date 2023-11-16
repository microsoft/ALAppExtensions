// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11771 "CZ Compensation - Edit CZC"
{
    Access = Internal;
    Assignable = false;
    Caption = 'CZ Compensation - Edit';

    IncludedPermissionSets = "CZ Compensation - Read CZC";

    Permissions = tabledata "Compens. Report Selections CZC" = IMD,
                  tabledata "Compensation Header CZC" = IMD,
                  tabledata "Compensation Line CZC" = IMD,
                  tabledata "Compensations Setup CZC" = IMD,
                  tabledata "Posted Compensation Header CZC" = IMD,
                  tabledata "Posted Compensation Line CZC" = IMD;
}
