// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 408 "MFG-PROD.ORDER"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read production order';

    IncludedPermissionSets = "Manufacturing Pr. Order - View";
}
