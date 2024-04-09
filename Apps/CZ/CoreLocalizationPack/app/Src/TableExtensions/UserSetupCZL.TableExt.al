// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.User;

using Microsoft.Finance.Dimension;
#if not CLEAN24
using Microsoft.Finance.GeneralLedger.Setup;
#endif
using Microsoft.HumanResources.Employee;

tableextension 11717 "User Setup CZL" extends "User Setup"
{
    fields
    {
        field(11770; "Check Doc. Date(work date) CZL"; Boolean)
        {
            Caption = 'Check Document Date(work date)';
            DataClassification = CustomerContent;
        }
        field(11771; "Check Doc. Date(sys. date) CZL"; Boolean)
        {
            Caption = 'Check Document Date(sys. date)';
            DataClassification = CustomerContent;
        }
        field(11772; "Check Post.Date(work date) CZL"; Boolean)
        {
            Caption = 'Check Posting Date (work date)';
            DataClassification = CustomerContent;
        }
        field(11773; "Check Post.Date(sys. date) CZL"; Boolean)
        {
            Caption = 'Check Posting Date (sys. date)';
            DataClassification = CustomerContent;
        }
        field(11774; "Check Bank Accounts CZL"; Boolean)
        {
            Caption = 'Check Bank Accounts';
            DataClassification = CustomerContent;
        }
        field(11775; "Check Journal Templates CZL"; Boolean)
        {
            Caption = 'Check Journal Templates';
            DataClassification = CustomerContent;
        }
        field(11776; "Check Dimension Values CZL"; Boolean)
        {
            Caption = 'Check Dimension Values';
            DataClassification = CustomerContent;
        }
        field(11777; "Allow Post.toClosed Period CZL"; Boolean)
        {
            Caption = 'Allow Posting to Closed Period';
            DataClassification = CustomerContent;
        }
        field(11778; "Allow VAT Posting From CZL"; Date)
        {
            Caption = 'Allow VAT Posting From';
            DataClassification = CustomerContent;
#if not CLEAN24
            ObsoleteState = Pending;
            ObsoleteTag = '24.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '27.0';
#endif
            ObsoleteReason = 'Replaced by "Allow VAT Date From" field.';
#if not CLEAN24

            trigger OnValidate()
            var
                GLSetup: Record "General Ledger Setup";
            begin
                GLSetup.Get();
                GLSetup.TestIsVATDateEnabledCZL();
            end;
#endif
        }
        field(11779; "Allow VAT Posting To CZL"; Date)
        {
            Caption = 'Allow VAT Posting To';
            DataClassification = CustomerContent;
#if not CLEAN24
            ObsoleteState = Pending;
            ObsoleteTag = '24.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '27.0';
#endif
            ObsoleteReason = 'Replaced by "Allow VAT Date To" field.';
#if not CLEAN24

            trigger OnValidate()
            var
                GLSetup: Record "General Ledger Setup";
            begin
                GLSetup.Get();
                GLSetup.TestIsVATDateEnabledCZL();
            end;
#endif
        }
        field(11780; "Allow Complete Job CZL"; Boolean)
        {
            Caption = 'Allow Complete Job';
            DataClassification = CustomerContent;
        }
        field(11781; "Employee No. CZL"; Code[20])
        {
            Caption = 'Employee No.';
            TableRelation = Employee;
            DataClassification = CustomerContent;
        }
        field(11782; "User Name CZL"; Text[100])
        {
            Caption = 'User Name';
            DataClassification = CustomerContent;
        }
        field(11783; "Allow Item Unapply CZL"; Boolean)
        {
            Caption = 'Allow Item Unapply';
            DataClassification = CustomerContent;
        }
        field(11784; "Check Location Code CZL"; Boolean)
        {
            Caption = 'Check Location Code';
            DataClassification = CustomerContent;
        }
        field(11785; "Check Release LocationCode CZL"; Boolean)
        {
            Caption = 'Check Release Location Code';
            DataClassification = CustomerContent;
        }
        field(11786; "Check Invt. Movement Temp. CZL"; Boolean)
        {
            Caption = 'Check Invt. Movement Templates';
            DataClassification = CustomerContent;
        }
        field(11787; "Allow VAT Date Changing CZL"; Boolean)
        {
            Caption = 'Allow VAT Date Changing';
            DataClassification = CustomerContent;
        }
    }
    procedure CopyToCZL(ToUserId: Code[50])
    var
        FromUserSetupLine: Record "User Setup Line CZL";
        FromSelectedDimension: Record "Selected Dimension";
        OldUserSetup: Record "User Setup";
        UserSetup: Record "User Setup";
        UserSetupLine: Record "User Setup Line CZL";
        SelectedDimension: Record "Selected Dimension";
        SelfCopyErr: Label 'You cannot copy a user setup into itself.';
    begin
        if ToUserId = '' then
            exit;

        if "User ID" = ToUserId then
            Error(SelfCopyErr);

        if UserSetup.Get(ToUserId) then
            OldUserSetup := UserSetup;

        UserSetup.Init();
        UserSetup := Rec;
        UserSetup."User Name CZL" := OldUserSetup."User Name CZL";
        UserSetup."User ID" := ToUserId;
        if not UserSetup.Insert() then
            UserSetup.Modify();

        UserSetupLine.SetRange("User ID", ToUserId);
        UserSetupLine.DeleteAll();

        FromUserSetupLine.SetRange("User ID", "User ID");
        if FromUserSetupLine.FindSet() then
            repeat
                UserSetupLine := FromUserSetupLine;
                UserSetupLine."User ID" := ToUserId;
                UserSetupLine.Insert();
            until FromUserSetupLine.Next() = 0;

        SelectedDimension.SetRange("User ID", ToUserId);
        SelectedDimension.SetRange("Object Type", 1);
        SelectedDimension.SetRange("Object ID", DATABASE::"User Setup");
        SelectedDimension.DeleteAll();

        FromSelectedDimension.SetRange("User ID", "User ID");
        FromSelectedDimension.SetRange("Object Type", 1);
        FromSelectedDimension.SetRange("Object ID", DATABASE::"User Setup");
        if FromSelectedDimension.FindSet() then
            repeat
                SelectedDimension := FromSelectedDimension;
                SelectedDimension."User ID" := ToUserId;
                SelectedDimension.Insert();
            until FromSelectedDimension.Next() = 0;

        OnAfterCopyUserSetupCZL(Rec, UserSetup);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyUserSetupCZL(FromUserSetup: Record "User Setup"; ToUserSetup: Record "User Setup")
    begin
    end;
}
