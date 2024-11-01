// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Receive;

using System.Utilities;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;

/// <summary>
/// Codeunit to run ReceiveDocuments from Receive Interface
/// </summary>
codeunit 6179 "Receive Documents"
{
    Access = Internal;

    trigger OnRun()
    begin
        EDocumentService.TestField(Code);
#if not CLEAN26
        EDocIntegration := this.EDocumentService."Service Integration";
        if EDocIntegration is Receiver then begin
            ReceiveInterface := this.EDocumentService."Service Integration";
            ReceiveInterface.ReceiveDocuments(this.EDocumentService, this.TempBlob, this.HttpRequestMessage, this.HttpResponseMessage, this.Count);
        end;
#else
        ReceiveInterface := this.EDocumentService."Service Integration";
        ReceiveInterface.ReceiveDocuments(this.EDocumentService, this.TempBlob, this.HttpRequestMessage, this.HttpResponseMessage, this.Count);
#endif
    end;

    procedure SetParameters(var Service: Record "E-Document Service"; var Blob: Codeunit "Temp Blob")
    begin
        this.EDocumentService.Copy(Service);
        this.TempBlob := Blob;
    end;

    procedure GetParameters(var Service: Record "E-Document Service"; var Blob: Codeunit "Temp Blob"; var RequestMessage: HttpRequestMessage; var ResponseMessage: HttpResponseMessage)
    begin
        Service.Copy(this.EDocumentService);
        Blob := this.TempBlob;
        RequestMessage := this.HttpRequestMessage;
        ResponseMessage := this.HttpResponseMessage;
    end;

    procedure GetCount(var Value: Integer)
    begin
        Value := this.Count;
    end;

    var
        EDocumentService: Record "E-Document Service";
        TempBlob: Codeunit "Temp Blob";
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ReceiveInterface: Interface Receiver;
#if not CLEAN26
        EDocIntegration: Interface "E-Document Integration";
#endif
        Count: Integer;
}
