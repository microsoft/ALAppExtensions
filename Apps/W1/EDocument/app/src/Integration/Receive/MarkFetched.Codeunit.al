// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Receive;

using System.Utilities;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;

/// <summary>
/// Executes the MarkFetched operation using the IReceivedDocumentMarker interface.
/// </summary>
codeunit 6181 "Mark Fetched"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        if IDocumentReceiver is IReceivedDocumentMarker then
            (IDocumentReceiver as IReceivedDocumentMarker).MarkFetched(this.EDocument, this.EDocumentService, this.DownloadedBlob, this.ReceiveContext);
    end;

    procedure SetInstance(IDocumentReceiver: Interface IDocumentReceiver)
    begin
        this.IDocumentReceiver := IDocumentReceiver;
    end;

    procedure SetContext(ReceiveContext: Codeunit ReceiveContext)
    begin
        this.ReceiveContext := ReceiveContext;
    end;

    procedure SetParameters(var EDoc: Record "E-Document"; var EDocService: Record "E-Document Service"; TempBlob: Codeunit "Temp Blob")
    begin
        this.EDocument.Copy(EDoc);
        this.EDocumentService.Copy(EDocService);
        this.DownloadedBlob := TempBlob;
    end;

    procedure GetParameters(var EDoc: Record "E-Document"; var EDocService: Record "E-Document Service")
    begin
        EDoc.Copy(this.EDocument);
        EDocService.Copy(this.EDocumentService);
    end;

    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        DownloadedBlob: Codeunit "Temp Blob";
        ReceiveContext: Codeunit ReceiveContext;
        IDocumentReceiver: Interface IDocumentReceiver;

}
