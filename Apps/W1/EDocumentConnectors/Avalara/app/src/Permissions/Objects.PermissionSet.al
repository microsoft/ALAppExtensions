#if not CLEAN26
#pragma warning disable AS0072 // Obsolete permission set
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

using Microsoft.EServices.EDocumentConnector.Avalara.Models;

permissionset 6370 Objects
{
    Access = Public;
    Assignable = false;
    Caption = 'Avalara E-Document Connector - Objects';
    ObsoleteReason = 'This permission set is obsolete. Use permission set 6375 "Avalara Objects" instead.';
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';

    Permissions =
                table "Connection Setup" = X,
                page "Mandate List" = X,
                page "Connection Setup Card" = X,
                page "Company List" = X,
                codeunit "Integration Impl." = X,
                codeunit Processing = X,
                codeunit Authenticator = X,
                codeunit Requests = X,
                codeunit "Http Executor" = X,
                codeunit Metadata = X;
}
#pragma warning restore AS0072 // Obsolete permission set
#endif