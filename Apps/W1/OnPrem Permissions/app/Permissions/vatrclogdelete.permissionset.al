// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2544 "VAT-RC-LOG, DELETE"
{
    Access = Public;
    Assignable = true;
    Caption = 'Delete VAT Rate Change Log';

    IncludedPermissionSets = "VAT Rate Change Log - Edit";
}
