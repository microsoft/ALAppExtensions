// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

permissionsetextension 13406 "Intrastat FI - Objects" extends "Intrastat Core - Objects"
{
    Permissions =
        codeunit "Intrastat Report Management FI" = X,
        codeunit "Intrastat Report Exp. Ext. FI" = X,
        codeunit "Intrastat Report Get Totals" = X;
}