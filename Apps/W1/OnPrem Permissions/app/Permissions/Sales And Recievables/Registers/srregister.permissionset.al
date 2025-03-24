// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 2817 "S&R-REGISTER"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read G/L registers (S&R)';

    IncludedPermissionSets = "Recievables Reg. - Read";
}
