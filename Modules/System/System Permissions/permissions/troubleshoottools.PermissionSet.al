// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 414 "TROUBLESHOOT TOOLS"
{
    Access = Public;
    Assignable = true;
    Caption = 'Troubleshoot Tools';

    IncludedPermissionSets = "Export Report Excel";

    Permissions = system "Run Table" = X,
                  system "Tools, Zoom" = X;
}
