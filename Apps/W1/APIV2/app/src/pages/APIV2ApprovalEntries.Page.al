// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.API.V2;

using System.Automation;

page 30094 "APIV2 - Approval Entries"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Approval Entry';
    EntitySetCaption = 'Approval Entries';
    EntityName = 'approvalEntry';
    EntitySetName = 'approvalEntries';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DataAccessIntent = ReadOnly;
    PageType = API;
    SourceTable = "Approval Entry";
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
                field(entryNumber; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                }
                field(tableId; Rec."Table ID")
                {
                    Caption = 'Table Id';
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type';
                }
                field(documentNumber; Rec."Document No.")
                {
                    Caption = 'Document No.';
                }
                field(sequenceNumber; Rec."Sequence No.")
                {
                    Caption = 'Sequence No.';
                }
                field(senderId; Rec."Sender ID")
                {
                    Caption = 'Sender Id';
                }
                field(senderName; Rec."Sender Full Name")
                {
                    Caption = 'Sender Full Name';
                }
                field(approvalCode; Rec."Approval Code")
                {
                    Caption = 'Approval Code';
                }
                field(salespersonPurchaserCode; Rec."Salespers./Purch. Code")
                {
                    Caption = 'Salesperson/Purchaser Code';
                }
                field(salespersonPurchaserName; Rec."Salespers./Purch. Name")
                {
                    Caption = 'Salesperson/Purchaser Name';
                }
                field(approverId; Rec."Approver ID")
                {
                    Caption = 'Approver Id';
                }
                field(approverName; Rec."Approver Full Name")
                {
                    Caption = 'Approver Full Name';
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(dateTimeSentForApproval; Rec."Date-Time Sent for Approval")
                {
                    Caption = 'Date-Time Sent for Approval';
                }
                field(lastDateTimeModified; Rec."Last Date-Time Modified")
                {
                    Caption = 'Last Date-Time Modified';
                }
                field(comment; Rec.Comment)
                {
                    Caption = 'Comment';
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date';
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount';
                }
                field(amountLCY; Rec."Amount (LCY)")
                {
                    Caption = 'Amount (LCY)';
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                }
                field(approvalType; Rec."Approval Type")
                {
                    Caption = 'Approval Type';
                }
                field(limitType; Rec."Limit Type")
                {
                    Caption = 'Limit Type';
                }
                field(availableCreditLimitLCY; Rec."Available Credit Limit (LCY)")
                {
                    Caption = 'Available Credit Limit (LCY)';
                }
                field(pendingApprovals; Rec."Pending Approvals")
                {
                    Caption = 'Pending Approvals';
                }
                field(recordIdToApprove; Rec."Record ID to Approve")
                {
                    Caption = 'Record Id to Approve';
                }
                field(delegationDateFormula; Rec."Delegation Date Formula")
                {
                    Caption = 'Delegation Date Formula';
                }
                field(numberOfApprovedRequests; Rec."Number of Approved Requests")
                {
                    Caption = 'Number of Approved Requests';
                }
                field(numberOfRejectedRequests; Rec."Number of Rejected Requests")
                {
                    Caption = 'Number of Rejected Requests';
                }
                field(relatedToChange; Rec."Related to Change")
                {
                    Caption = 'Related to Change';
                }
                field(workflowStepInstanceId; Rec."Workflow Step Instance ID")
                {
                    Caption = 'Workflow Step Instance Id';
                }
            }
        }
    }
}