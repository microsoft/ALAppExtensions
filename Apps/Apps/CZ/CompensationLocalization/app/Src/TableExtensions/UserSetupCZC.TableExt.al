// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using System.Security.User;

tableextension 31274 "User Setup CZC" extends "User Setup"
{
    fields
    {
        field(31272; "Compens. Amt. Appr. Limit CZC"; Integer)
        {
            BlankZero = true;
            Caption = 'Compensation Amt. Approval Limit';
            DataClassification = CustomerContent;
        }
        field(31273; "Unlimited Compens. Appr. CZC"; Boolean)
        {
            Caption = 'Unlimited Compensation Approval';
            DataClassification = CustomerContent;
        }
    }

    procedure GetDefaultCompensationApprovalLimitCZC(): Integer
    var
        UserSetup: Record "User Setup";
        DefaultApprovalLimit: Integer;
        LimitedApprovers: Integer;
    begin
        UserSetup.SetRange("Unlimited Compens. Appr. CZC", false);

        if UserSetup.FindFirst() then begin
            DefaultApprovalLimit := UserSetup."Compens. Amt. Appr. Limit CZC";
            LimitedApprovers := UserSetup.Count();
            UserSetup.SetRange("Compens. Amt. Appr. Limit CZC", DefaultApprovalLimit);
            if LimitedApprovers = UserSetup.Count() then
                exit(DefaultApprovalLimit);
        end;
        exit(0);
    end;
}
