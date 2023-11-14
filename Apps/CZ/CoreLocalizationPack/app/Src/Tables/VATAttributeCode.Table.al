// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 11752 "VAT Attribute Code CZL"
{
    Caption = 'VAT Attribute Code';
    DrillDownPageId = "VAT Attribute Codes CZL";
    LookupPageId = "VAT Attribute Codes CZL";

    fields
    {
        field(1; "VAT Statement Template Name"; Code[10])
        {
            Caption = 'VAT Statement Template Name';
            NotBlank = true;
            TableRelation = "VAT Statement Template";
            DataClassification = CustomerContent;
        }
        field(2; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(4; "XML Code"; Code[20])
        {
            Caption = 'XML Code';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "VAT Statement Template Name", "Code")
        {
            Clustered = true;
        }
        key(Key2; "XML Code")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description)
        {
        }
    }
}
