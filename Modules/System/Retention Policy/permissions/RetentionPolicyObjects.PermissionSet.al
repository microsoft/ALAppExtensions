// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 3906 "Retention Policy - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Environment Info. - Objects";

    Permissions = Codeunit "Apply Retention Policy Impl." = X,
                  Codeunit "Apply Retention Policy" = X,
                  Codeunit "PBT Expired Record Count" = X,
                  Codeunit "Reten. Pol. Allowed Tables" = X,
                  Codeunit "Reten. Pol. Allowed Tbl. Impl." = X,
                  Codeunit "Reten. Pol. Delete. Impl." = X,
                  Codeunit "Reten. Pol. Filtering Impl." = X,
                  Codeunit "Reten. Policy Telemetry Impl." = X,
                  Codeunit "Retention Period Custom Impl." = X,
                  Codeunit "Retention Period Impl." = X,
                  Codeunit "Retention Policy Installer" = X,
                  Codeunit "Retention Policy Log Impl." = X,
                  Codeunit "Retention Policy Log" = X,
                  Codeunit "Retention Policy Logs Delete" = X,
                  Codeunit "Retention Policy Setup Impl." = X,
                  Codeunit "Retention Policy Setup" = X,
                  Codeunit "Retention Policy Upgrade" = X,
                  Page "Reten. Policy Setup ListPart" = X,
                  Page "Retention Periods" = X,
                  Page "Retention Policy Log Entries" = X,
                  Page "Retention Policy Setup Card" = X,
                  Page "Retention Policy Setup Lines" = X,
                  Page "Retention Policy Setup List" = X,
                  Table "Reten. Pol. Deleting Param" = X,
                  Table "Reten. Pol. Filtering Param" = X,
                  Table "Retention Period" = X,
                  Table "Retention Policy Allowed Table" = X,
                  Table "Retention Policy Log Entry" = X,
                  Table "Retention Policy Setup Line" = X,
                  Table "Retention Policy Setup" = X;
}
