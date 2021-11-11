// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1821 "Video - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Video Impl." = X,
                  Codeunit Video = X,
                  Page "Product Videos" = X,
                  Page "Video Link" = X,
                  Table "Product Video Buffer" = X;
}
