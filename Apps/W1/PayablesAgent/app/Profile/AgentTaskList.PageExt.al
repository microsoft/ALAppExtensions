// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.PayablesAgent;

using Microsoft.eServices.EDocument;
using System.Agents;

pageextension 3305 AgentTaskList extends "Agent Task List"
{
    actions
    {
        addlast(Processing)
        {
            group(PayablesAgentTasks)
            {
                Caption = 'Payables agent tasks';

                fileuploadaction(CreatePATaskFromPdf)
                {
                    ApplicationArea = All;
                    Caption = 'Create task for Payables Agent', Comment = 'Payables Agent is a term, and should not be translated.';
                    ToolTip = 'Create a new agent task by uploading pdf.';
                    AllowedFileExtensions = '.pdf';
                    AllowMultipleFiles = true;
                    Image = NewDocument;
                    Visible = true;

                    trigger OnAction(Files: List of [FileUpload])
                    begin
                        CreatePATask(Files);
                    end;
                }
            }
        }
    }

    local procedure CreatePATask(Files: List of [FileUpload])
    var
        EDocument: Record "E-Document";
        AgentCU: Codeunit Agent;
        PayablesAgentSetup: Codeunit "Payables Agent Setup";
        PASetupConfig: Codeunit "PA Setup Configuration";
        EDocImport: Codeunit "E-Doc. Import";
        FileUpload: FileUpload;
        InStream: InStream;
        AgentNotActiveErr: Label 'The Payables Agent is not active.', Comment = 'Payables Agent is a term, and should not be translated.';
        SourceDetailsTok: Label 'Local file %1', Comment = '%1 is the file name.';
    begin
        PayablesAgentSetup.LoadSetupConfiguration(PASetupConfig);
        if not AgentCU.IsActive(PASetupConfig.GetAgentSetupBuffer()."User Security ID") then
            Error(AgentNotActiveErr);

        foreach FileUpload in Files do begin
            FileUpload.CreateInStream(InStream);
            EDocImport.CreateFromType(EDocument, PASetupConfig.GetEDocumentService(), "E-Doc. File Format"::PDF, FileUpload.FileName, InStream);

            EDocument."Source Details" := StrSubstNo(SourceDetailsTok, FileUpload.FileName);
            EDocument.Modify();
            EDocImport.ProcessAutomaticallyIncomingEDocument(EDocument);
        end;
    end;

}