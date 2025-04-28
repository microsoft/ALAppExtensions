// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 2346 "INTRASTAT-PERIODIC"
{
    Access = Public;
    Assignable = true;
    Caption = 'Intrastat periodic activities';
    
    IncludedPermissionSets = "Intrastat - Edit";
}
