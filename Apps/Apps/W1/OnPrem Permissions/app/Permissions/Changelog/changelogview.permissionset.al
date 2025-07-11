// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 6432 "CHANGELOG-VIEW"
{
    Access = Public;
    Assignable = true;
    Caption = 'View Change Log Entries';

    IncludedPermissionSets = "Changelog - Read";
}
