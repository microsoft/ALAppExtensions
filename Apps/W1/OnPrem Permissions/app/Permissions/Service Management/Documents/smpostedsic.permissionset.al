// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 5541 "SM-POSTED S/I/C"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read posted service documents';

    IncludedPermissionSets = "Service Documents - View";
}
