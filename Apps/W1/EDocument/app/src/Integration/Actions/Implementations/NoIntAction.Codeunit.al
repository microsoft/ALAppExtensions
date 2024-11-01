// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Action;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;

/// <summary>
/// This codeunit is used to implement the Integration Action interface. It is used to provide a default implementation for the Integration Action interface.
/// </summary>
codeunit 6176 "No Int. Action" implements "Action Invoker"
{
    Access = Internal;

    procedure InvokeAction(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; var Status: Enum "E-Document Service Status"): Boolean
    begin
    end;

    procedure GetFallbackStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"): Enum "E-Document Service Status"
    begin
    end;

}