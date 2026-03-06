// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Automation;

page 2146 "APIV2 - Workflow Resp. Options"
{
    APIGroup = 'auditing';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'Workflow Response Option';
    EntitySetCaption = 'Workflow Response Options';
    EntityName = 'workflowResponseOption';
    EntitySetName = 'workflowResponseOptions';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DataAccessIntent = ReadOnly;
    PageType = API;
    SourceTable = "Workflow step argument";
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
                field(type; Rec."Type")
                {
                    Caption = 'Type';
                }
                field(generalJournalTemplateName; Rec."General Journal Template Name")
                {
                    Caption = 'General Journal Template Name';
                }
                field(generalJournalBatchName; Rec."General Journal Batch Name")
                {
                    Caption = 'General Journal Batch Name';
                }
                field(notificationUserId; Rec."Notification User ID")
                {
                    Caption = 'Notification User Id';
                }
                field(notificationUserLicenseType; Rec."Notification User License Type")
                {
                    Caption = 'Notification User License Type';
                }
                field(responseFunctionName; Rec."Response Function Name")
                {
                    Caption = 'Response Function Name';
                }
                field(notifySender; Rec."Notify Sender")
                {
                    Caption = 'Notify Sender';
                }
                field(linkTargetPage; Rec."Link Target Page")
                {
                    Caption = 'Link Target Page';
                }
                field(customLink; Rec."Custom Link")
                {
                    Caption = 'Custom Link';
                }
                field(eventConditions; Rec."Event Conditions")
                {
                    Caption = 'Event Conditions';
                }
                field(approverType; Rec."Approver Type")
                {
                    Caption = 'Approver Type';
                }
                field(approverLimitType; Rec."Approver Limit Type")
                {
                    Caption = 'Approver Limit Type';
                }
                field(workflowUserGroupCode; Rec."Workflow User Group Code")
                {
                    Caption = 'Workflow User Group Code';
                }
                field(dueDateFormula; Rec."Due Date Formula")
                {
                    Caption = 'Due Date Formula';
                }
                field(message; Rec.Message)
                {
                    Caption = 'Message';
                }
                field(delegateAfter; Rec."Delegate After")
                {
                    Caption = 'Delegate After';
                }
                field(showConfirmationMessage; Rec."Show Confirmation Message")
                {
                    Caption = 'Show Confirmation Message';
                }
                field(tableNumber; Rec."Table No.")
                {
                    Caption = 'Table No.';
                }
                field(fieldNumber; Rec."Field No.")
                {
                    Caption = 'Field No.';
                }
                field(fieldCaption; Rec."Field Caption")
                {
                    Caption = 'Field Caption';
                }
                field(approverUserId; Rec."Approver User ID")
                {
                    Caption = 'Approver User Id';
                }
                field(responseType; Rec."Response Type")
                {
                    Caption = 'Response Type';
                }
                field(responseUserId; Rec."Response User ID")
                {
                    Caption = 'Response User Id';
                }
                field(notificationEntryType; Rec."Notification Entry Type")
                {
                    Caption = 'Notification Entry Type';
                }
                field(responseOptionGroup; Rec."Response Option Group")
                {
                    Caption = 'Response Option Group';
                }
            }
        }
    }
}