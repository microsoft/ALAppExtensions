// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Automation;

page 2145 "APIV2 - Workflows"
{
    APIGroup = 'auditing';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'Workflow';
    EntitySetCaption = 'Workflows';
    EntityName = 'workflow';
    EntitySetName = 'workflows';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DataAccessIntent = ReadOnly;
    PageType = API;
    SourceTable = Workflow;
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(code; Rec.Code)
                {
                    Caption = 'Code';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(enabled; Rec.Enabled)
                {
                    Caption = 'Enabled';
                }
                field(template; Rec.Template)
                {
                    Caption = 'Template';
                }
                field(category; Rec.Category)
                {
                    Caption = 'Category';
                }
                part(workflowSteps; "APIV2 - Workflow Steps")
                {
                    Caption = 'Workflow Steps';
                    EntityName = 'workflowStep';
                    EntitySetName = 'workflowSteps';
                    Multiplicity = Many;
                    SubPageLink = "Workflow Code" = field(Code);
                }
            }
        }
    }
}