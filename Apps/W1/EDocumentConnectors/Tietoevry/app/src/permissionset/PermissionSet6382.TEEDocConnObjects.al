// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

permissionset 6382 "TE EDoc. Conn. Objects"
{
    Access = Public;
    Assignable = false;

    Permissions = table "Connection Setup" = X,
                  page "Connection Setup Card" = X,
                  codeunit "API Requests" = X,
                  codeunit "Authenticator" = X,
                  codeunit "Connection" = X,
                  codeunit "Integration Impl." = X,
                  codeunit "Processing" = X;
}