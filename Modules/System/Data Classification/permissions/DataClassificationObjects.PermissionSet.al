// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Privacy;

permissionset 1752 "Data Classification - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Data Classification Mgt." = X,
                  Page "Data Classification Wizard" = X,
                  Page "Data Classification Worksheet" = X,
                  Page "Field Data Classification" = X;
}
