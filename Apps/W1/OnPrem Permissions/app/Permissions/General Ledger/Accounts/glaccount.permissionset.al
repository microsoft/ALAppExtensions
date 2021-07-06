// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 4124 "G/L-ACCOUNT"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read G/L accounts and entries';
    
    IncludedPermissionSets = "General Ledger Accounts - View";
}
