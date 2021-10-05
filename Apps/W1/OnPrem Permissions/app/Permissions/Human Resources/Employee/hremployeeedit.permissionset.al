// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2699 "HR-EMPLOYEE, EDIT"
{
    Access = Public;
    Assignable = true;
    Caption = 'Edit employees';

    IncludedPermissionSets = "Employee - Edit";
}
