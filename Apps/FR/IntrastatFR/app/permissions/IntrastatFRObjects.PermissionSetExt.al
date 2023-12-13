// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

permissionsetextension 10851 "Intrastat FR - Objects" extends "Intrastat Core - Objects"
{
    Permissions =
        codeunit IntrastatReportManagementFR = X,
        codeunit "Intrastat Rep. Filter Rcpt. FR" = X,
        codeunit "Intrastat Rep. Filter Shpt. FR" = X,
        codeunit "Intrastat Rep. Reset Filter FR" = X;
}