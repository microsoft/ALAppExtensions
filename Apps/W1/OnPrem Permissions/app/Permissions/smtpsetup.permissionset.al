// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2271 "SMTP-SETUP"
{
    Access = Public;
    Assignable = true;
    Caption = 'SMTP Mail Setup';

    IncludedPermissionSets = "SMTP Mail - Admin";
}
