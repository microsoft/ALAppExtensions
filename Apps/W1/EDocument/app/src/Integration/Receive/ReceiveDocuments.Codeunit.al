// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Receive;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;
using System.Utilities;

/// <summary>
/// Codeunit to run ReceiveDocuments from Receive Interface
/// </summary>
codeunit 6179 "Receive Documents"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        EDocumentService.TestField(Code);
        IDocumentReceiver.ReceiveDocuments(this.EDocumentService, this.DocumentsMetadata, this.ReceiveContext);
    end;

    procedure SetInstance(Reciver: Interface IDocumentReceiver)
    begin
        this.IDocumentReceiver := Reciver;
    end;

    procedure SetContext(ReceiveContext: Codeunit ReceiveContext)
    begin
        this.ReceiveContext := ReceiveContext;
    end;

    procedure SetDocuments(DocumentsMetadata: Codeunit "Temp Blob List")
    begin
        this.DocumentsMetadata := DocumentsMetadata
    end;

    procedure SetService(var EDocumentService: Record "E-Document Service")
    begin
        this.EDocumentService.Copy(EDocumentService);
    end;

    procedure GetService(var EDocumentService: Record "E-Document Service")
    begin
        EDocumentService.Copy(this.EDocumentService);
    end;

    var
        EDocumentService: Record "E-Document Service";
        DocumentsMetadata: Codeunit "Temp Blob List";
        ReceiveContext: Codeunit ReceiveContext;
        IDocumentReceiver: Interface IDocumentReceiver;

}
