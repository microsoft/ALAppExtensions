// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9048 "Plan Configuration - Objects"
{
    Assignable = false;
    Access = Internal;
    Caption = 'License Configuration - Objects';

    Permissions = page "Custom User Groups In Plan" = X,
                  page "Default User Groups In Plan" = X,
                  table "Custom User Group In Plan" = X,
                  codeunit "Custom User Group In Plan" = X,
                  codeunit "Plan Configuration Install" = X;
}
