// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Interfaces;

using System.Utilities;
using Microsoft.eServices.EDocument;

#if not CLEAN26
interface Receive extends "E-Document Integration"
#else
interface Receive
#endif
{

    /// <summary>
    /// Get 1 or list of documents from API. Return the count of documents you want to create 
    /// </summary>
    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; var Count: Integer)

    /// <summary>
    /// For each document created, we run this to download the data (XML, PDF, etc) from the API.
    /// </summary>
    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentsBlob: Codeunit "Temp Blob"; var DocumentBlob: Codeunit "Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)


}