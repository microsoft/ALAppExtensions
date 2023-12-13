// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

permissionsetextension 10500 "Intrastat GB - Objects" extends "Intrastat Core - Objects"
{
    Permissions =
        codeunit "Intrastat Report Management GB" = X,
        codeunit "Intrastat Report Exp. Ext. GB" = X;
}