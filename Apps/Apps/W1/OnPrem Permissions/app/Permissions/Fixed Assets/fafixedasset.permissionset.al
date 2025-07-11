// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 7053 "FA-FIXED ASSET"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read fixed assets and entries';
    
    IncludedPermissionSets = "Fixed Assets - Read";
}
