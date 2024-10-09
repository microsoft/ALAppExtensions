// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.EServices.EDocumentConnector.Continia;

permissionset 6363 "EDoc. Connector Objects"
{
    Access = Public;
    Assignable = false;

    Permissions = table "E-Doc. Ext. Connection Setup" = X,
                  page "EDoc Ext Connection Setup Card" = X,
                  codeunit "Pagero API Requests" = X,
                  codeunit "Pagero Auth." = X,
                  codeunit "Pagero Connection" = X,
                  codeunit "Pagero Integration Impl." = X,
                  codeunit "Pagero Processing" = X,
                  codeunit "Pagero Application Response" = X,
                  table "Connection Setup" = X,
                  page "Ext. Connection Setup" = X,
                  codeunit "Integration Impl." = X,
                  codeunit "EDocument Processing" = X,
                  codeunit "Api Url Mgt." = X,
                  codeunit "Api Requests" = X,
                  codeunit "Onboarding Helper" = X,
                  codeunit "Credential Management" = X,
                  codeunit "Session Manager" = X,
                  codeunit "Subscription Mgt." = X;
}