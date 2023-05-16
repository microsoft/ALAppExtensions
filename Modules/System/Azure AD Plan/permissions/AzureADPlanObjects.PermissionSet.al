// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 774 "Azure AD Plan - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Azure AD Plan" = X,
#if not CLEAN22
                  Codeunit "Default Permission Set In Plan" = X,
#endif
                  Codeunit "Plan Configuration" = X,
                  Codeunit "Microsoft 365 License" = X,
                  Page "Custom Permission Set In Plan" = X,
                  Page "Default Permission Set In Plan" = X,
                  Page Plans = X,
                  Page "Plan Configuration Card" = X,
                  Page "Plan Configuration List" = X,
                  Page "Plan Configurations Part" = X,
                  Page "Plans FactBox" = X,
                  Page "User Plan Members FactBox" = X,
                  Page "User Plan Members" = X,
                  Page "User Plans FactBox" = X,
                  Query Plan = X,
                  Query "Users in Plans" = X;
}
