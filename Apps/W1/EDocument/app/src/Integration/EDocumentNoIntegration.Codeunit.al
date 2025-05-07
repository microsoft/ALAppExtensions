
#pragma warning disable AS0018
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Integration.Send;
using Microsoft.eServices.EDocument.Integration.Receive;
using System.Utilities;

#if not CLEAN26
codeunit 6128 "E-Document No Integration" implements "E-Document Integration", IDocumentSender, IDocumentReceiver, ISentDocumentActions, IConsentManager
#else
codeunit 6128 "E-Document No Integration" implements IDocumentSender, IDocumentReceiver, ISentDocumentActions, IConsentManager
#endif
{

#if not CLEAN26
    procedure Send(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var http: HttpResponseMessage)
    begin
        IsAsync := false;
    end;

    procedure ReceiveDocument(var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var http: HttpResponseMessage)
    begin
    end;

    procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer
    begin
    end;

    procedure SendBatch(var EDocuments: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var http: HttpResponseMessage)
    begin
        IsAsync := false;
    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var http: HttpResponseMessage): Boolean
    begin
    end;

    procedure GetApproval(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var http: HttpResponseMessage): Boolean
    begin
    end;

    procedure Cancel(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var http: HttpResponseMessage): Boolean
    begin
    end;

    procedure GetIntegrationSetup(var SetupPage: Integer; var SetupTable: Integer)
    begin
        SetupPage := 0;
        SetupTable := 0;
    end;
#endif

    #region IDocumentSender

    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    begin
    end;

    procedure SendBatch(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    begin
    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext): Boolean
    begin
    end;

    #endregion

    #region IDocumentReceiver

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; DocumentsMetadata: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    begin

    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    begin

    end;

    #endregion

    #region ISentDocumentActions

    procedure GetApprovalStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean
    begin
        Message(NoSentDocumentApprovalActionLbl);
        exit(false);
    end;

    procedure GetCancellationStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean
    begin
        Message(NoSentDocumentCancellationActionLbl);
        exit(false);
    end;

    #endregion

    #region IConsentManager

    procedure ObtainPrivacyConsent(): Boolean
    begin
        exit(true);
    end;

    #endregion

    var
        NoSentDocumentApprovalActionLbl: Label 'No Sent document approval action is available for this integration.';
        NoSentDocumentCancellationActionLbl: Label 'No Sent document cancellation action is available for this integration.';

}
#pragma warning restore AS0018