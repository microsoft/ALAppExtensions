// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

permissionsetextension 11029 "Intrastat DE - Objects" extends "Intrastat Core - Objects"
{
    Permissions =
        codeunit IntrastatReportManagementDE = X,
        codeunit "Intrastat Report Filter Rcpt." = X,
        codeunit "Intrastat Report Filter Shpt." = X,
        codeunit "Intrastat Report Reset Filter" = X;
}
