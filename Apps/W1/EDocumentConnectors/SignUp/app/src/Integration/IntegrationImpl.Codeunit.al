// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using System.Utilities;
using Microsoft.EServices.EDocument;

codeunit 6386 IntegrationImpl implements "E-Document Integration"
{
    Access = Internal;

    var
        Processing: Codeunit Processing;
        BatchSendNotSupportedErr: Label 'Batch sending is not supported in this version';
        CancelNotSupportedErr: Label 'Cancel is not supported in this version';

    procedure Send(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    var
    begin
        this.Processing.SendEDocument(EDocument, TempBlob, IsAsync, HttpRequestMessage, HttpResponseMessage);
    end;

    procedure SendBatch(var EDocuments: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    begin
        IsAsync := false;
        Error(this.BatchSendNotSupportedErr);
    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(this.Processing.GetDocumentResponse(EDocument, HttpRequestMessage, HttpResponseMessage));
    end;

    procedure GetApproval(var EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(this.Processing.GetDocumentApproval(EDocument, HttpRequestMessage, HttpResponseMessage));
    end;

    procedure Cancel(var EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        Error(this.CancelNotSupportedErr);
    end;

    procedure ReceiveDocument(var TempBlob: Codeunit "Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    begin
        this.Processing.ReceiveDocument(TempBlob, HttpRequestMessage, HttpResponseMessage);
    end;

    procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer
    begin
        exit(this.Processing.GetDocumentCountInBatch(TempBlob));
    end;

    procedure GetIntegrationSetup(var SetupPage: Integer; var SetupTable: Integer)
    begin
        SetupPage := Page::ConnectionSetupCard;
        SetupTable := Database::ConnectionSetup;
    end;
}