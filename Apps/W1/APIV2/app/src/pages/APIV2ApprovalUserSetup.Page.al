// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Automation;
using System.Security.AccessControl;
using System.Security.User;

page 30095 "APIV2 - Approval User Setup"
{
    APIGroup = 'auditing';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'Approval User Setup';
    EntitySetCaption = 'Approval User Setups';
    EntityName = 'approvalUserSetup';
    EntitySetName = 'approvalUserSetup';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DataAccessIntent = ReadOnly;
    PageType = API;
    SourceTable = "User Setup";
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
                field(userId; Rec."User ID")
                {
                    Caption = 'User Id';
                }
                field(userFullName; UserFullName)
                {
                    Caption = 'User Full Name';
                }
                field(salesPersonPurchaser; Rec."Salespers./Purch. Code")
                {
                    Caption = 'Salespers./Purch. Code';
                }
                field(approverId; Rec."Approver ID")
                {
                    Caption = 'Approver Id';
                }
                field(salesAmountApprovalLimit; Rec."Sales Amount Approval Limit")
                {
                    Caption = 'Sales Amount Approval Limit';
                }
                field(unlimitedSalesApproval; Rec."Unlimited Sales Approval")
                {
                    Caption = 'Unlimited Sales Approval';
                }
                field(purchaseAmountApprovalLimit; Rec."Purchase Amount Approval Limit")
                {
                    Caption = 'Purchase Amount Approval Limit';
                }
                field(unlimitedPurchaseApproval; Rec."Unlimited Purchase Approval")
                {
                    Caption = 'Unlimited Purchase Approval';
                }
                field(requestApprovalAmountLimit; Rec."Request Amount Approval Limit")
                {
                    Caption = 'Request Amount Approval Limit';
                }
                field(unlimitedRequestApprovalAmount; Rec."Unlimited Request Approval")
                {
                    Caption = 'Unlimited Request Approval';
                }
                field(substitute; Rec.Substitute)
                {
                    Caption = 'Substitute';
                }
                field(email; Rec."E-Mail")
                {
                    Caption = 'E-Mail';
                }
                field(phoneNumber; Rec."Phone No.")
                {
                    Caption = 'Phone No.';
                }
                field(approvalAdmin; Rec."Approval Administrator")
                {
                    Caption = 'Approval Administrator';
                }
            }
        }
    }

    var
        UserFullName: Text;

    trigger OnAfterGetRecord()
    var
        User: Record User;
    begin
        User.SetRange("User Name", Rec."User ID");
        if User.FindFirst() then
            UserFullName := User."Full Name";
    end;
}