// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1752 "Data Classification - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Data Classification Mgt. Impl." = X,
                  Codeunit "Data Classification Mgt." = X,
                  Codeunit "Data Privacy Entities Mgt." = X,
                  Codeunit "Fields Sync Status Management" = X,
                  Page "Data Classification Wizard" = X,
                  Page "Data Classification Worksheet" = X,
                  Page "Field Content Buffer" = X,
                  Page "Field Data Classification" = X,
                  Table "Data Privacy Entities" = X,
                  Table "Field Content Buffer" = X,
                  Table "Fields Sync Status" = X;
}
