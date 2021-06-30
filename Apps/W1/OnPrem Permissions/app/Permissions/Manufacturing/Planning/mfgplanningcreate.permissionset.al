// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 514 "MFG-PLANNING, CREATE"
{
    Access = Public;
    Assignable = true;
    Caption = 'Make orders from Planning';

    IncludedPermissionSets = "Manufacturing Planning - View";
}
