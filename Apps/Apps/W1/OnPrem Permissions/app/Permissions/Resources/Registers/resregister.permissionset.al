// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 655 "RES-REGISTER"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read resource registers';

    IncludedPermissionSets = "Resources Registers - Read";
}
