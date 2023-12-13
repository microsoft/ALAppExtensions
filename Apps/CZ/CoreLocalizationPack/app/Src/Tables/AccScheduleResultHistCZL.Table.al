// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using System.Security.AccessControl;

table 31114 "Acc. Schedule Result Hist. CZL"
{
    Caption = 'Acc. Schedule Result History';

    fields
    {
        field(1; "Result Code"; Code[20])
        {
            Caption = 'Result Code';
            DataClassification = CustomerContent;
            TableRelation = "Acc. Schedule Result Hdr. CZL";
        }
        field(2; "Row No."; Integer)
        {
            Caption = 'Row No.';
            DataClassification = CustomerContent;
        }
        field(3; "Column No."; Integer)
        {
            Caption = 'Column No.';
            DataClassification = CustomerContent;
        }
        field(4; "Variant No."; Integer)
        {
            Caption = 'Variant No.';
            DataClassification = CustomerContent;
        }
        field(10; "New Value"; Decimal)
        {
            Caption = 'New Value';
            DataClassification = CustomerContent;
        }
        field(11; "Old Value"; Decimal)
        {
            Caption = 'Old Value';
            DataClassification = CustomerContent;
        }
        field(12; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(13; "Modified DateTime"; DateTime)
        {
            Caption = 'Modified DateTime';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Result Code", "Row No.", "Column No.", "Variant No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "User ID" := CopyStr(UserId, 1, MaxStrLen("User ID"));
        "Modified DateTime" := CurrentDateTime;
    end;
}
