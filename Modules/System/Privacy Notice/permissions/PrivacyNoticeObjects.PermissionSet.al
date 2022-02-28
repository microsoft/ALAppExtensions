// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1563 "Privacy Notice - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions =   codeunit "System Privacy Notice Reg." = X,
                    codeunit "System Upgrade Privacy Notices" = X,
                    codeunit "Privacy Notice" = X,
                    codeunit "Privacy Notice Impl." = X,
                    codeunit "Privacy Notice Approval" = X,
                    page "Privacy Notice" = X,
                    page "Privacy Notices" = X,
                    page "Privacy Notice Approvals" = X,
                    table "Privacy Notice" = X;
}
