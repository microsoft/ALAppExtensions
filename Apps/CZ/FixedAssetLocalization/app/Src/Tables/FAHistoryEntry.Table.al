// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Setup;
using Microsoft.HumanResources.Employee;
using System.Security.AccessControl;

table 31248 "FA History Entry CZF"
{
    Caption = 'FA History Entry';
    LookupPageID = "FA History Entries CZF";
    Permissions = tabledata "FA History Entry CZF" = i;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(11; Type; Enum "FA History Type CZF")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(12; "FA No."; Code[20])
        {
            Caption = 'FA No.';
            DataClassification = CustomerContent;
            TableRelation = "Fixed Asset"."No.";
        }
        field(21; "Old Value"; Code[20])
        {
            Caption = 'Old Value';
            TableRelation = if (Type = const("FA Location")) "FA Location".Code else
            if (Type = const("Responsible Employee")) Employee."No.";
            DataClassification = CustomerContent;
        }
        field(22; "New Value"; Code[20])
        {
            Caption = 'New Value';
            DataClassification = CustomerContent;
            TableRelation = if (Type = const("FA Location")) "FA Location".Code else
            if (Type = const("Responsible Employee")) Employee."No.";
        }
        field(30; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(31; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(35; "Closed by Entry No."; Integer)
        {
            Caption = 'Closed by Entry No.';
            DataClassification = CustomerContent;
        }
        field(40; Disposal; Boolean)
        {
            Caption = 'Disposal';
            DataClassification = CustomerContent;
        }
        field(50; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "FA No.", Type, "Posting Date")
        {
        }
    }

    trigger OnInsert()
    begin
        TestField("FA No.");
        TestField(Type);
        TestField("Posting Date");
        TestField("Document No.");
        "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
    end;
}
