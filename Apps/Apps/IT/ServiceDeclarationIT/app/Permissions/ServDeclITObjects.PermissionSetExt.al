// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

permissionsetextension 12214 "Serv. Decl. IT - Objects" extends "Serv. Decl. - Objects"
{
    Permissions =
        page "Serv. Decl. Lines IT" = X,

        codeunit "Serv. Decl. Exp. Ext. IT" = X,
#if not CLEAN27
        codeunit "Serv. Decl. Get Totals IT" = X,
#endif
        codeunit "Service Declaration Mgt. IT" = X;
}
