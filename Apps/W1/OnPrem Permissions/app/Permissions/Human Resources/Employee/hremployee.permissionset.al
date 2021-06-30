// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2085 "HR-EMPLOYEE"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read employees';

    IncludedPermissionSets = "Employee - Read";
}
