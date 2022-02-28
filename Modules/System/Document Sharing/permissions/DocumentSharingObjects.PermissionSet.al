// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9560 "Document Sharing - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Client Type Mgt. - Objects";
    Permissions = Codeunit "Document Sharing Impl." = X,
                  Codeunit "Document Sharing" = X,
                  Page "Document Sharing" = X,
                  Table "Document Sharing" = X;
}
