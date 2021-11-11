// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 3972 "Image - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Base64 Convert - Objects";

    Permissions = Codeunit "Image Impl." = X,
                  Codeunit Image = X;
}
