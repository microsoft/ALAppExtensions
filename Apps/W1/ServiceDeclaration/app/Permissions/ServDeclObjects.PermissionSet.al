// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

permissionset 5017 "Serv. Decl. - Objects"
{
    Access = Public;
    Assignable = false;

    Permissions = table "Service Declaration Setup" = X,
                  table "Service Transaction Type" = X,
                  table "Service Declaration Header" = X,
                  table "Service Declaration Line" = X,
                  table "Service Declaration Buffer" = X,
                  page "Service Declaration" = X,
                  page "Service Declaration Overview" = X,
                  page "Service Declarations" = X,
                  page "Service Declaration Subform" = X,
                  page "Service Transaction Types" = X,
                  page "Serv. Decl. Setup Wizard" = X,
                  page "Service Declaration Setup" = X,
                  codeunit "Export Service Declaration" = X,
                  codeunit "Get Service Declaration Lines" = X,
                  codeunit "Service Declaration Mgt." = X,
                  codeunit "Serv. Decl. Installation" = X,
                  codeunit "Service Declaration Upgrade" = X;
}
