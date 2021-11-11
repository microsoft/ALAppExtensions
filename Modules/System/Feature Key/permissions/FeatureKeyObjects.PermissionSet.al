// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2609 "Feature Key - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Date-Time Dialog - Objects",
                             "URI - Objects";

    Permissions = Codeunit "Feature Data Error Handler" = X,
                  Codeunit "Feature Management Facade" = X,
                  Codeunit "Feature Management Impl." = X,
                  Codeunit "Update Feature Data" = X,
                  Page "Feature Management" = X,
                  Page "Schedule Feature Data Update" = X,
                  Page "Upcoming Changes Factbox" = X,
                  Table "Feature Data Update Status" = X;
}
