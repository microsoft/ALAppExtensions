// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1907 "Camera and Media - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit Camera = X,
                  Page "Media Upload" = X,
                  Page Camera = X;
}
