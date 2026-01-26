// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 3424 "FA-INS REGISTER"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read insurance registers';
    
    IncludedPermissionSets = "Insurance Registers - Read";
}
