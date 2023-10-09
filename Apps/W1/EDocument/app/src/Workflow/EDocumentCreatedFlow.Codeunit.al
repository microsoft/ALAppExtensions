// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Automation;
using System.Threading;

codeunit 6143 "E-Document Created Flow"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        Code(Rec);
    end;

    procedure Code(JobQueueEntry: Record "Job Queue Entry")
    var
        EDocument: Record "E-Document";
        WorkflowManagement: Codeunit "Workflow Management";
        EDocumentWorkflowSetup: Codeunit "E-Document Workflow Setup";
    begin
        EDocument.Get(JobQueueEntry."Record ID to Process");
        WorkflowManagement.HandleEvent(EDocumentWorkflowSetup.EDocCreated(), EDocument);
    end;
}
