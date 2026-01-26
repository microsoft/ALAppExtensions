// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

permissionset 6430 "Objects - Logiq"
{
    Assignable = false;
    Caption = 'Logiq Connector - Objects';
    Permissions =
        table "Logiq Connection Setup" = X,
        table "Logiq Connection User Setup" = X,
        page "Logiq Connection Setup" = X,
        page "Logiq Connection User Setup" = X,
        codeunit "Logiq Auth" = X,
        codeunit "Logiq Integration Impl." = X,
        codeunit "Logiq Integration Management" = X;
}
