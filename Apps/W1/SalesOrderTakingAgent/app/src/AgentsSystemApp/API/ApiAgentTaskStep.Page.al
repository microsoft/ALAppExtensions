// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

page 4324 "API - Agent Task Step"
{
    PageType = API;
    Caption = 'step', Locked = true;
    APIPublisher = 'microsoft';
    APIGroup = 'agent';
    APIVersion = 'v1.0';
    EntityName = 'step';
    EntitySetName = 'steps';
    SourceTable = "Agent Task Step";
    DelayedInsert = true;
    ODataKeyFields = "Task ID", "Step Number";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(taskId; Rec."Task ID")
                {
                    Caption = 'TaskId', Locked = true;
                }

                field(stepNumber; Rec."Step Number")
                {
                    Caption = 'StepNumber', Locked = true;
                }

                field(detailsText; DetailsText)
                {
                    Caption = 'Details', Locked = true;
                }

                field(type; Rec.Type)
                {
                    Caption = 'Type', Locked = true;
                }

                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }

                field(createdAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Created At', Locked = true;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        TextLine: Text;
        InStream: InStream;
    begin
        DetailsText := '';
        Rec.Details.CreateInStream(InStream);
        while not InStream.EOS() do begin
            InStream.ReadText(TextLine);
            DetailsText += TextLine;
        end;
    end;

    trigger OnOpenPage()
    begin
        Rec.SetAutoCalcFields(Details);
    end;

    var
        DetailsText: Text;
}