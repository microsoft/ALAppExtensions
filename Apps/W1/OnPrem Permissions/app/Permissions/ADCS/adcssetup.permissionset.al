// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 389 "ADCS SETUP"
{
    Access = Public;
    Assignable = true;
    Caption = 'ADCS Set-up';
    
    IncludedPermissionSets = "ADCS - Admin";
}
