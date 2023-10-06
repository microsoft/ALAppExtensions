// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

permissionset 774 "Azure AD Plan - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Page "Custom Permission Set In Plan" = X,
#if not CLEAN22
#pragma warning disable AL0432
#endif
                  Page "Default Permission Set In Plan" = X,
#if not CLEAN22
#pragma warning restore AL0432
#endif
                  Page "Plan Configuration Card" = X,
                  Page "Plan Configuration List" = X,
                  Page "Plan Configurations Part" = X,
                  Page "User Plan Members FactBox" = X,
                  Page "User Plan Members" = X,
                  Page "User Plans FactBox" = X;
}
