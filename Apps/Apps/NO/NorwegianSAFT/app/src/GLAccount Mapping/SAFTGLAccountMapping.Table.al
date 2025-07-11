// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.GeneralLedger.Account;

table 10674 "SAF-T G/L Account Mapping"
{
    DataClassification = CustomerContent;
    Caption = 'SAF-T G/L Account Mapping';

    fields
    {
        field(1; "Mapping Range Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Mapping Range Code';
            TableRelation = "SAF-T Mapping Range";
            Editable = false;
            NotBlank = true;
        }
        field(2; "G/L Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account";
            Editable = false;
            NotBlank = true;
        }
        field(3; "Mapping Type"; Enum "SAF-T Mapping Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Mapping Type';
        }
        field(4; "Category No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Category No.';
            TableRelation = "SAF-T Mapping Category"."No." where("Mapping Type" = field("Mapping Type"));

            trigger OnValidate()
            begin
                "No." := '';
            end;
        }
        field(5; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
            TableRelation = "SAF-T Mapping"."No." where("Mapping Type" = field("Mapping Type"), "Category No." = field("Category No."));

            trigger OnValidate()
            begin
                if "No." <> '' then
                    TestField("Category No.");
            end;
        }
        field(6; "G/L Entries Exists"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'G/L Entries Exists';
            Editable = false;
        }
        field(50; "G/L Account Name"; Text[100])
        {
            Caption = 'G/L Account Name';
            FieldClass = FlowField;
            CalcFormula = lookup("G/L Account".Name where("No." = field("G/L Account No.")));
        }
    }

    keys
    {
        key(PK; "Mapping Range Code", "G/L Account No.")
        {
            Clustered = true;
        }
    }
}
