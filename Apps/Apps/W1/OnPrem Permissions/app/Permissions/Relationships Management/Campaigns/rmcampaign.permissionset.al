// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 9599 "RM-CAMPAIGN"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read campaigns and segments';

    IncludedPermissionSets = "Campaign - Read";
}
