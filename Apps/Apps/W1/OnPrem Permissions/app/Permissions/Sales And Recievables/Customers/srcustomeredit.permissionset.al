// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 9222 "S&R-CUSTOMER, EDIT"
{
    Access = Public;
    Assignable = true;
    Caption = 'Edit customers';

    IncludedPermissionSets = "Customer - Edit";
}
