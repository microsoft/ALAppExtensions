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
    DataClassification = CustomerContent;

    fields
    {
        field(1; "VAT Statement Template Name"; Code[10])
        {
            Caption = 'VAT Statement Template Name';
            NotBlank = true;
            TableRelation = "VAT Statement Template";
        }
        field(2; "Code"; Code[20])
        {
            Caption = 'Code';
            ToolTip = 'Specifies a VAT attribute code.';
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the VAT attribute description.';
        }
        field(4; "XML Code"; Code[20])
        {
            Caption = 'XML Code';
            ToolTip = 'Specifies the XML code for VAT statement reporting.';
        }
        field(5; "VAT Report Amount Type"; Enum "VAT Report Amount Type CZL")
        {
            Caption = 'VAT Return Amount Type';
            ToolTip = 'Specifies the attribute code value to display amounts in corresponding columns of VAT Return.';
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
