// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.eServices;

using Microsoft.EServices.EDocument;

codeunit 5231 "Create Incoming Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        IncomingDocument: Record "Incoming Document";
        EServiceDemoDataSetup: Record "EService Demo Data Setup";
        IncomingDocumentsFolderTok: Label 'IncomingDocuments', Locked = true;
        DocumentInStream: InStream;
    begin
        EServiceDemoDataSetup.Get();

        if EServiceDemoDataSetup."Invoice Field Name" = '' then begin
            EServiceDemoDataSetup."Invoice Field Name" := DefaultIncomingDocument();
            EServiceDemoDataSetup.Modify();
        end;

        NavApp.GetResource(IncomingDocumentsFolderTok + '/' + EServiceDemoDataSetup."Invoice Field Name" + '.PDF', DocumentInStream);
        IncomingDocument.CreateIncomingDocument(DocumentInStream, EServiceDemoDataSetup."Invoice Field Name" + '.pdf');
    end;

    procedure DefaultIncomingDocument(): Text[100]
    begin
        exit(W1IncomingDocDescriptionLbl);
    end;

    var
        W1IncomingDocDescriptionLbl: Label 'London Postmaster Invoice W1', Locked = true;
}
