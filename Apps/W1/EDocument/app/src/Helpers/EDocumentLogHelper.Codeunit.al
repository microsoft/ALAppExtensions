// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Utilities;
codeunit 6131 "E-Document Log Helper"
{
    /// <summary>
    /// Use it to insert integration log when you need to send more than one request to the service.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="EDocumentService">The E-Document service record.</param>
    /// <param name="HttpRequest">The HTTP request message object that you should use when sending the request.</param>
    /// <param name="HttpResponse">The HTTP response object that you should use when sending the request.</param>
    procedure InsertIntegrationLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    begin
        EDocumentLog.InsertIntegrationLog(EDocument, EDocumentService, HttpRequest, HttpResponse);
    end;

    /// <summary>
    /// Inserts a log entry for the E-Document.
    /// </summary>
    /// <param name="EDocument">The record representing the E-Document for which the log entry is being inserted.</param>
    /// <param name="EDocumentService">The record representing the E-Document Service associated with the E-Document.</param>
    /// <param name="EDocumentServiceStatus">The status of the E-Document Service at the time of log insertion.</param>
    procedure InsertLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocumentServiceStatus: Enum "E-Document Service Status")
    begin
        EDocumentLog.InsertLog(EDocument, EDocumentService, EDocumentServiceStatus);
    end;

    /// <summary>
    /// Inserts a log entry for the E-Document with a blob.
    /// </summary>
    /// <param name="EDocument">The record representing the E-Document for which the log entry is being inserted.</param>
    /// <param name="EDocumentService">The record representing the E-Document Service associated with the E-Document.</param>
    /// <param name="TempBlob">Temp blob codeunit instance representing document blob data.</param>
    /// <param name="EDocumentServiceStatus">The status of the E-Document Service at the time of log insertion.</param>
    procedure InsertLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocumentServiceStatus: Enum "E-Document Service Status"): Integer
    begin
        exit(EDocumentLog.InsertLog(EDocument, EDocumentService, TempBlob, EDocumentServiceStatus)."Entry No.");
    end;

    var
        EDocumentLog: Codeunit "E-Document Log";
}