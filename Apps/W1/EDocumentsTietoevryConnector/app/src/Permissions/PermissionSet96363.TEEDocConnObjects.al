// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

permissionset 96363 "TE EDoc. Conn. Objects"
{
    Access = Public;
    Assignable = false;

    Permissions = table "Tietoevry Connection Setup" = X,
                  page "Tietoevry Conn. Setup Card" = X,
                  codeunit "Tietoevry API Requests" = X,
                  codeunit "Tietoevry Auth." = X,
                  codeunit "Tietoevry Connection" = X,
                  codeunit "Tietoevry Integration Impl." = X,
                  codeunit "Tietoevry Processing" = X;
}