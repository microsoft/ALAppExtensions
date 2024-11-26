// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

permissionset 6390 "Tietoevry Objects"
{
    Access = Public;
    Assignable = false;
    Caption = 'Tietoevry E-Document Connector - Objects';

    Permissions =
                table "Connection Setup" = X,
                page "Connection Setup Card" = X,
                codeunit "Integration Impl." = X,
                codeunit Processing = X,
                codeunit Authenticator = X,
                codeunit Requests = X,
                codeunit Events = X,
                codeunit "Http Executor" = X,
                codeunit "Tietoevry E-Document" = X,
                codeunit "Tietoevry E-Document Import" = X;
}