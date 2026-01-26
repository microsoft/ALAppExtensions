// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 5578 "FA-INS JOURNAL"
{
    Access = Public;
    Assignable = true;
    Caption = 'Create entries in ins. jnls.';

    IncludedPermissionSets = "Insurance Journals - Edit";
}
