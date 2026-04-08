// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Automation;

page 2148 "APIV2 - Workflow Approvers"
{
    APIGroup = 'auditing';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    EntityCaption = 'Workflow Approver';
    EntitySetCaption = 'Workflow Approvers';
    EntityName = 'workflowApprover';
    EntitySetName = 'workflowApprovers';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DataAccessIntent = ReadOnly;
    PageType = API;
    SourceTable = "Workflow Approvers Buffer";
    SourceTableTemporary = true;
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
                field(workflowCode; Rec.WorkflowCode)
                {
                    Caption = 'Workflow Code';
                }
                field(workflowDescription; Rec.WorkflowDescription)
                {
                    Caption = 'Workflow Description';
                }
                field(category; Rec.Category)
                {
                    Caption = 'Category';
                }
                field(enabled; Rec.Enabled)
                {
                    Caption = 'Enabled';
                }
                field(workflowStepId; Rec.WorkflowStepId)
                {
                    Caption = 'Workflow Step Id';
                }
                field(argumentId; Rec.ArgumentId)
                {
                    Caption = 'Argument Id';
                }
                field(approverType; Rec.ApproverType)
                {
                    Caption = 'Approver Type';
                }
                field(approverLimitType; Rec.ApproverLimitType)
                {
                    Caption = 'Approver Limit Type';
                }
                field(userGroupCode; Rec.UserGroupCode)
                {
                    Caption = 'User Group Code';
                }
                field(userGroupDescription; Rec.UserGroupDescription)
                {
                    Caption = 'User Group Description';
                }
                field(userId; Rec.UserId)
                {
                    Caption = 'User Id';
                }
                field(userName; Rec.UserName)
                {
                    Caption = 'User Name';
                }
                field(sequence; Rec.Sequence)
                {
                    Caption = 'Sequence';
                }
            }
        }
    }

    trigger OnInit()
    begin
        Rec.FillBuffer();
    end;
}