// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.API.V2;

using System.Automation;

page 30093 "APIV2 - Pstd. Approval Entries"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Posted Approval Entry';
    EntitySetCaption = 'Posted Approval Entries';
    EntityName = 'postedApprovalEntry';
    EntitySetName = 'postedApprovalEntries';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DataAccessIntent = ReadOnly;
    PageType = API;
    SourceTable = "Posted Approval Entry";
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
                field(salespersonPurchCode; Rec."Salespers./Purch. Code")
                {
                    Caption = 'Salespers./Purch. Code';
                }
                field(salespersonPurchName; Rec."Salespers./Purch. Name")
                {
                    Caption = 'Salespers./Purch. Name';
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
                field(lastModifiedById; Rec."Last Modified By ID")
                {
                    Caption = 'Last Modified By Id';
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
                field(recordId; Rec."Posted Record ID")
                {
                    Caption = 'Posted Record Id';
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
                field(iterationNumber; Rec."Iteration No.")
                {
                    Caption = 'Iteration No.';
                }
            }
        }
    }
}