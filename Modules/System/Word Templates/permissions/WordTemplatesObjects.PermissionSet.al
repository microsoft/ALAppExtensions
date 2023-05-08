// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9988 "Word Templates - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Word Template" = X,
                  Codeunit "Word Template Custom Field" = X,
                  Codeunit "Word Template Field Value" = X,
                  Page "Word Template Creation Wizard" = X,
                  Page "Word Templates Field Selection" = X,
                  Page "Word Template Selection Wizard" = X,
                  Page "Word Template To Text Wizard" = X,
                  Page "Word Templates Related Card" = X,
                  Page "Word Templates Related Edit" = X,
                  Page "Word Templates Related FactBox" = X,
#if not CLEAN22
                  Page "Word Templates Related List" = X,
#endif
                  Page "Word Templates Related Part" = X,
                  Page "Word Templates Tables Part" = X,
                  Page "Word Templates Table Lookup" = X,
                  Page "Word Templates" = X,
                  Table "Word Template" = X;
}
