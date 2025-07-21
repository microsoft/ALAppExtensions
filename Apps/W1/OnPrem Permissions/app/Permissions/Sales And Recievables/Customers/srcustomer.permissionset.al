// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 4971 "S&R-CUSTOMER"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read customers and entries';

    IncludedPermissionSets = "Customer - View";
}
