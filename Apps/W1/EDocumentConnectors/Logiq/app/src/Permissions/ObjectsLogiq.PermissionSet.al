// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

permissionset 6430 "Objects - Logiq"
{
    Assignable = false;
    Caption = 'Logiq Connector Objects';
    Permissions =
        table "Connection Setup" = X,
        table "Connection User Setup" = X,
        page "Connection Setup" = X,
        page "Connection User Setup" = X,
        codeunit Auth = X,
        codeunit "E-Document Integration" = X,
        codeunit "E-Document Management" = X;
}
