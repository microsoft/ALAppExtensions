// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 4104 "G/L-JOURNAL"
{
    Access = Public;
    Assignable = true;
    Caption = 'Create entries in G/L journals';
    
    IncludedPermissionSets = "General Ledger Journals - Edit";
}
