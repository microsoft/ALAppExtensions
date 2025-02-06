// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

permissionset 6390 ContEDocConnObjects
{
    Access = Public;
    Assignable = false;
    Caption = 'Continia E-Document Connector - Objects';

    Permissions = table "Connection Setup" = X,
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