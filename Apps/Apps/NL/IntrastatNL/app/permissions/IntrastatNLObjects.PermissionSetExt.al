// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

permissionsetextension 11426 "Intrastat NL - Objects" extends "Intrastat Core - Objects"
{
    Permissions =
        codeunit "Intrastat Report Management NL" = X,
        codeunit "Intrastat Report Exp. Ext. NL" = X;
}