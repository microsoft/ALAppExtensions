// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.EServices.EDocument;
using System.Threading;

codeunit 6369 "Pagero Processing"
{
    Access = Internal;

    trigger OnRun()
    begin
        RunRequestsJob();
    end;

    procedure RunRequestsJob()
    begin
        ProcessErrorsOnSend();
        ProcessSentDocuments();
        ProcessReceivedDocuments();
        ProcessGetTargetDocument();
        ProcessApplicationResponses();
    end;

    local procedure ProcessErrorsOnSend();
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        PageroConnection: Codeunit "Pagero Connection";
    begin
        // Read errors after the document has been sent to the service
        // Update status to Sending Error/Sent
        EDocumentService.Get(GetEDocServiceName());
        EDocumentServiceStatus.SetRange("E-Document Service Code", EDocumentService.Code);
        EDocumentServiceStatus.SetRange(Status, EDocumentServiceStatus."Status"::"Pending Response");
        if EDocumentServiceStatus.FindSet() then
            repeat
                EDocument.Get(EDocumentServiceStatus."E-Document Entry No");
                EDocument.Get(EDocumentServiceStatus."E-Document Entry No");
                PageroConnection.HandleErrors(EDocument);
            until EDocumentServiceStatus.Next() = 0;
    end;

    local procedure ProcessSentDocuments();
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        PageroConnection: Codeunit "Pagero Connection";
    begin
        EDocumentService.Get(GetEDocServiceName());
        EDocumentServiceStatus.SetRange("E-Document Service Code", EDocumentService.Code);
        EDocumentServiceStatus.SetRange(Status, EDocumentServiceStatus."Status"::Sent);
        if EDocumentServiceStatus.FindSet() then
            repeat
                EDocument.Get(EDocumentServiceStatus."E-Document Entry No");
                PageroConnection.GetADocument(EDocument);
            until EDocumentServiceStatus.Next() = 0;
    end;

    local procedure ProcessReceivedDocuments();
    var
        EDocumentService: Record "E-Document Service";
        PageroConnection: Codeunit "Pagero Connection";
    begin
        EDocumentService.Get(GetEDocServiceName());
        PageroConnection.GetCreateReceivedDocument(EDocumentService);
    end;

    local procedure ProcessGetTargetDocument();
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        PageroConnection: Codeunit "Pagero Connection";
    begin
        EDocumentService.Get(GetEDocServiceName());
        EDocumentServiceStatus.SetRange("E-Document Service Code", EDocumentService.Code);
        EDocumentServiceStatus.SetRange(Status, EDocumentServiceStatus."Status"::Created);
        if EDocumentServiceStatus.FindSet() then
            repeat
                EDocument.Get(EDocumentServiceStatus."E-Document Entry No");
                PageroConnection.GetTargetDocument(EDocument);
            until EDocumentServiceStatus.Next() = 0;
    end;

    local procedure ProcessApplicationResponses();
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        PageroConnection: Codeunit "Pagero Connection";
    begin
        EDocumentService.Get(GetEDocServiceName());
        EDocumentServiceStatus.SetRange("E-Document Service Code", EDocumentService.Code);
        EDocumentServiceStatus.SetRange(Status, EDocumentServiceStatus.Status::Sent);
        if EDocumentServiceStatus.FindSet() then
            repeat
                PageroConnection.ReceiveAppResponse(EDocument);
            until EDocumentServiceStatus.Next() = 0;
    end;

    procedure SetUpJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "Job Queue Management";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"Pagero Processing");
        if not JobQueueEntry.IsEmpty() then
            exit;

        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Earliest Start Date/Time" := CreateDateTime(Today, Time + 60000);
        JobQueueEntry."Object ID to Run" := CODEUNIT::"Pagero Processing";
        JobQueueManagement.CreateJobQueueEntry(JobQueueEntry);
        JobQueueEntry.Validate("Notify On Success", false);
        JobQueueEntry.Modify(true);
    end;

    local procedure GetEDocServices(var EDocumentService: Record "E-Document Service"): Boolean
    begin
        EDocumentService.SetRange("Service Integration", EDocumentService."Service Integration"::Pagero);
        exit(EDocumentService.FindSet());
    end;

    local procedure GetEDocServiceName(): Text
    var
        EDocumentService: Record "E-Document Service";
    begin
        if GetEDocServices(EDocumentService) then
            exit(EDocumentService.Code);
        exit('');
    end;
}
