// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Word;

permissionset 9988 "Word Templates - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Word Template" = X,
                  Codeunit "Word Template Custom Field" = X,
                  Codeunit "Word Template Field Value" = X,
                  Page "Word Templates" = X,
                  Page "Word Template Creation Wizard" = X,
                  Page "Word Template Selection Wizard" = X,
                  Page "Word Template To Text Wizard" = X,
                  Table "Word Template" = X;
}
