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

    Permissions = table "Continia Connection Setup" = X,
                  page "Continia Ext. Connection Setup" = X,
                  codeunit "Continia Integration Impl." = X,
                  codeunit "Continia EDocument Processing" = X,
                  codeunit "Continia Api Url" = X,
                  codeunit "Continia Api Requests" = X,
                  codeunit "Continia Onboarding Helper" = X,
                  codeunit "Continia Credential Management" = X,
                  codeunit "Continia Session Manager" = X,
                  codeunit "Continia Subscription Mgt." = X;
}