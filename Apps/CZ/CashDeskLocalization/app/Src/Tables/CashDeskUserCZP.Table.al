// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using System.Security.AccessControl;
using System.Security.User;
using System.Utilities;

table 11745 "Cash Desk User CZP"
{
    Caption = 'Cash Desk User';
    LookupPageID = "Cash Desk Users CZP";

    fields
    {
        field(1; "Cash Desk No."; Code[20])
        {
            Caption = 'Cash Desk No.';
            NotBlank = true;
            TableRelation = "Cash Desk CZP";
            DataClassification = CustomerContent;
        }
        field(2; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                User: Record User;
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID");
                if "User ID" <> '' then begin
                    User.SetRange("User Name", "User ID");
                    User.FindFirst();
                    "User Full Name" := User."Full Name";
                end else
                    "User Full Name" := '';
            end;
        }
        field(10; Create; Boolean)
        {
            Caption = 'Create';
            DataClassification = CustomerContent;
        }
        field(11; Issue; Boolean)
        {
            Caption = 'Issue';
            DataClassification = CustomerContent;
        }
        field(12; Post; Boolean)
        {
            Caption = 'Post';
            DataClassification = CustomerContent;
        }
        field(13; "Post EET Only"; Boolean)
        {
            Caption = 'Post EET Only';
            DataClassification = CustomerContent;
        }
        field(22; "User Full Name"; Text[100])
        {
            Caption = 'User Full Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Cash Desk No.", "User ID")
        {
            Clustered = true;
        }
    }

    trigger OnInsert();
    var
        MyAccountIsMissingCreateQst: Label 'Current user is not %1.\Cash Desk %2 will not be accessible for you.\\Do you want create %1 for %3?', Comment = '%1 = TableCaption, %2 = Cash Desk No., %3 = UserId';
    begin
        if "User ID" = UserId() then
            exit;
        CashDeskUserCZP.SetRange("Cash Desk No.", "Cash Desk No.");
        CashDeskUserCZP.SetRange("User ID", UserId());
        if CashDeskUserCZP.IsEmpty() then
            if ConfirmManagement.GetResponseOrDefault(StrSubstNo(MyAccountIsMissingCreateQst, TableCaption(), "Cash Desk No.", ConvertStr(UserId(), '\', '/')), true) then begin
                CashDeskUserCZP.Init();
                CashDeskUserCZP."Cash Desk No." := "Cash Desk No.";
                CashDeskUserCZP."User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
                CashDeskUserCZP.Insert();
            end;
    end;

    trigger OnDelete();
    var
        MyAccountIsMissingStayQst: Label 'Cash Desk %2 will not be accessible for you.\\Do you want stay %1 for %3?', Comment = '%1 = TableCaption, %2 = Cash Desk No., %3 = UserId';
    begin
        if "User ID" <> UserId() then
            exit;
        CashDeskUserCZP.SetRange("Cash Desk No.", "Cash Desk No.");
        CashDeskUserCZP.SetFilter("User ID", '<>%1', UserId());
        if not CashDeskUserCZP.IsEmpty() then
            if ConfirmManagement.GetResponseOrDefault(StrSubstNo(MyAccountIsMissingStayQst, TableCaption(), "Cash Desk No.", ConvertStr(UserId(), '\', '/')), true) then
                Error('');
    end;

    var
        CashDeskUserCZP: Record "Cash Desk User CZP";
        ConfirmManagement: Codeunit "Confirm Management";
}
