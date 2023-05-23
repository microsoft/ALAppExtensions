// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1927 "Data Cleanup - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = codeunit "Media Cleanup" = X,
                  page "Detached Media Cleanup" = X,
                  page "Media Cleanup FactBox" = X;
}
