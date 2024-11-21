// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Receive;

using System.Utilities;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;

/// <summary>
/// Codeunit to run DownloadDocument from IDocumentReceiver Interface
/// </summary>
codeunit 6180 "Download Document"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        this.EDocumentService.TestField(Code);
        IDocumentReceiver.DownloadDocument(this.EDocument, this.EDocumentService, this.DocumentMetadata, this.ReceiveContext);
    end;

    procedure SetContext(ReceiveContext: Codeunit ReceiveContext)
    begin
        this.ReceiveContext := ReceiveContext;
    end;

    procedure SetInstance(Reciver: Interface IDocumentReceiver)
    begin
        this.IDocumentReceiver := Reciver;
    end;

    procedure SetParameters(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: Codeunit "Temp Blob")
    begin
        this.EDocument.Copy(EDocument);
        this.EDocumentService.Copy(EDocumentService);
        this.DocumentMetadata := DocumentMetadata;
    end;

    procedure GetDocumentAndService(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service")
    begin
        EDocument.Copy(this.EDocument);
        EDocumentService.Copy(this.EDocumentService);
    end;

    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        DocumentMetadata: Codeunit "Temp Blob";
        ReceiveContext: Codeunit ReceiveContext;
        IDocumentReceiver: Interface IDocumentReceiver;
}
