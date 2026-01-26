// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 1084 "G/L-BANK ACC"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read bank accounts and entries';

    IncludedPermissionSets = "Bank Accounts - View";
}
