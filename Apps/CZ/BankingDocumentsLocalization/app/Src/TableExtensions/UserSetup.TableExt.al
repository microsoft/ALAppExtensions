// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using System.Security.User;

tableextension 31283 "UserSetup CZB" extends "User Setup"
{
    fields
    {
        field(11710; "Check Payment Orders CZB"; Boolean)
        {
            Caption = 'Check Payment Orders';
            DataClassification = CustomerContent;
        }
        field(11711; "Check Bank Statements CZB"; Boolean)
        {
            Caption = 'Check Bank Statements';
            DataClassification = CustomerContent;
        }
        field(11712; "Bank Amount Approval Limit CZB"; Integer)
        {
            BlankZero = true;
            Caption = 'Bank Amount Approval Limit';
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BothLimitErr: Label 'You cannot have both a %1 and %2.', Comment = '%1 = Approval Limit FieldCaption, %2 = Unlimited Approval FieldCaption';
            begin
                if "Unlimited Sales Approval" and ("Bank Amount Approval Limit CZB" <> 0) then
                    Error(BothLimitErr, FieldCaption("Bank Amount Approval Limit CZB"), FieldCaption("Unlimited Bank Approval CZB"));
            end;
        }
        field(11713; "Unlimited Bank Approval CZB"; Boolean)
        {
            Caption = 'Unlimited Bank Approval';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Unlimited Bank Approval CZB" then
                    "Bank Amount Approval Limit CZB" := 0;
            end;
        }
    }

    procedure GetDefaultBankApprovalLimitCZB(): Integer
    var
        UserSetup: Record "User Setup";
        DefaultApprovalLimit: Integer;
        LimitedApprovers: Integer;
    begin
        UserSetup.SetRange("Unlimited Bank Approval CZB", false);

        if UserSetup.FindFirst() then begin
            DefaultApprovalLimit := UserSetup."Bank Amount Approval Limit CZB";
            LimitedApprovers := UserSetup.Count();
            UserSetup.SetRange("Bank Amount Approval Limit CZB", DefaultApprovalLimit);
            if LimitedApprovers = UserSetup.Count then
                exit(DefaultApprovalLimit);
        end;
        exit(0);
    end;
}
