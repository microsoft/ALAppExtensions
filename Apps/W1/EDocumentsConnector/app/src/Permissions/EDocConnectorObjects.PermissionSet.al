// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.EServices.EDocumentConnector.Logiq;

permissionset 6363 "EDoc. Connector Objects"
{
    Access = Public;
    Assignable = false;

    Permissions = table "E-Doc. Ext. Connection Setup" = X,
                  table "Logiq Connection Setup" = X,
                  table "Logiq Connection User Setup" = X,
                  page "EDoc Ext Connection Setup Card" = X,
                  page "Logiq Connection Setup" = X,
                  page "Logiq Connection User Setup" = X,
                  codeunit "Pagero API Requests" = X,
                  codeunit "Pagero Auth." = X,
                  codeunit "Pagero Connection" = X,
                  codeunit "Pagero Integration Impl." = X,
                  codeunit "Pagero Processing" = X,
                  codeunit "Pagero Application Response" = X,
                  codeunit "Logiq Auth" = X,
                  codeunit "Logiq E-Document Integration" = X,
                  codeunit "Logiq E-Document Management" = X;
}