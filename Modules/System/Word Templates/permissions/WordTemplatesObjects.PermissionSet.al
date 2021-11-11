// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9988 "Word Templates - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Data Compression - Objects",
                             "Regex - Objects";

    Permissions = Codeunit "Word Template Impl." = X,
                  Codeunit "Word Template" = X,
                  Page "Word Template Creation Wizard" = X,
                  Page "Word Template Selection Wizard" = X,
                  Page "Word Template To Text Wizard" = X,
                  Page "Word Templates Related Card" = X,
                  Page "Word Templates Related FactBox" = X,
                  Page "Word Templates Related List" = X,
                  Page "Word Templates Related Part" = X,
                  Page "Word Templates Table Lookup" = X,
                  Page "Word Templates" = X,
                  Table "Word Template" = X,
                  Table "Word Templates Related Table" = X,
                  Table "Word Templates Table" = X;
}
