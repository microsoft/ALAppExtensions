// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 8323 "SM-Q/O/I/C,POST"
{
    Access = Public;
    Assignable = true;
    Caption = 'Post service orders etc.';

    IncludedPermissionSets = "Service Documents - Post";
}
