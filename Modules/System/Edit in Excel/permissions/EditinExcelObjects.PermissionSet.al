// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1488 "Edit in Excel - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Edit in Excel" = X,
                  Codeunit "Edit in Excel Workbook" = X,
                  Page "Excel Centralized Depl. Wizard" = X,
                  Table "Edit in Excel Settings" = X;
}
