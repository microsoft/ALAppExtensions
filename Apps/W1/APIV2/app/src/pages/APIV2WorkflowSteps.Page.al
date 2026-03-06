// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Automation;

page 2147 "APIV2 - Workflow Steps"
{
    APIGroup = 'auditing';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'Workflow Step';
    EntitySetCaption = 'Workflow Steps';
    EntityName = 'workflowStep';
    EntitySetName = 'workflowSteps';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DataAccessIntent = ReadOnly;
    PageType = API;
    SourceTable = "Workflow Step";
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'System Id';
                }
                field(id; Rec.ID)
                {
                    Caption = 'Id';
                }
                field(workflowCode; Rec."Workflow Code")
                {
                    Caption = 'Workflow Code';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(entryPoint; Rec."Entry Point")
                {
                    Caption = 'Entry Point';
                }
                field(previousWorkflowStepId; Rec."Previous Workflow Step ID")
                {
                    Caption = 'Previous Workflow Step Id';
                }
                field(nextWorkflowStepId; Rec."Next Workflow Step ID")
                {
                    Caption = 'Next Workflow Step Id';
                }
                field(type; Rec.Type)
                {
                    Caption = 'Type';
                }
                field(functionName; Rec."Function Name")
                {
                    Caption = 'Function Name';
                }
                field(argument; Rec.Argument)
                {
                    Caption = 'Argument';
                }
                field(sequenceNo; Rec."Sequence No.")
                {
                    Caption = 'Sequence No.';
                }
                part(workflowResponseOptions; "APIV2 - Workflow Resp. Options")
                {
                    Caption = 'Workflow Response Options';
                    EntityName = 'workflowResponseOption';
                    EntitySetName = 'workflowResponseOptions';
                    Multiplicity = Many;
                    SubPageLink = ID = field(Argument);
                }
            }
        }
    }
}