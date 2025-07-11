// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 7686 "ADCS ALL"
{
    Access = Public;
    Assignable = true;
    Caption = 'ADCS User';

    IncludedPermissionSets = "ADCS - Read";
}
