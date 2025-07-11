// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

permissionsetextension 148121 "Intrastat IT - Objects" extends "Intrastat Core - Objects"
{
    Permissions =
        codeunit "Intrastat Report Management IT" = X,
        codeunit "Intrastat Report Exp. Ext. IT" = X,
        codeunit "Intrastat Report Get Totals" = X;
}