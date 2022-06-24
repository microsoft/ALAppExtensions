// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9100 "SP API - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "URI - Objects";

    Permissions = Codeunit "SP Client" = X,
                  Codeunit "SP Client Impl." = X,
                  Codeunit "SP File" = X,
                  Codeunit "SP Folder" = X,
                  Codeunit "SP Http Content" = X,
                  Codeunit "SP List" = X,
                  Codeunit "SP List Item" = X,
                  Codeunit "SP List Item Attachment" = X,
                  Codeunit "SP Operation Response" = X,
                  Codeunit "SP Request Manager" = X,
                  Codeunit "SP Uri Builder" = X,
                  Table "SP File" = X,
                  Table "SP Folder" = X,
                  Table "SP List" = X,
                  Table "SP List Item" = X,
                  Table "SP List Item Attachment" = X;

}
