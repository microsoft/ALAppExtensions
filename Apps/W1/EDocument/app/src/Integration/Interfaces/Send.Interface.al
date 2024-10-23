// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Interfaces;

using Microsoft.eServices.EDocument;
using System.Utilities;

#if not CLEAN26
interface Send extends "E-Document Integration"
#else
interface Send
#endif
{

    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var IsAsync: Boolean);

    procedure SendBatch(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var IsAsync: Boolean);

    procedure GetResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean;

}