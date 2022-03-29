// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1566 "Priv. Notice - View"
{
    Access = Public;
    Assignable = false;
    Caption = 'Privacy Notice - View';
    
    IncludedPermissionSets = "Privacy Notice - Read";

    Permissions = tabledata "Privacy Notice" = im,
                  tabledata "Privacy Notice Approval" = im;
}
