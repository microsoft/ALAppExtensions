// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 31108 "VAT Ctrl. Report Section CZL"
{
    Caption = 'VAT Control Report Section';
    DrillDownPageId = "VAT Ctrl. Report Sections CZL";
    LookupPageId = "VAT Ctrl. Report Sections CZL";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Group By"; Option)
        {
            Caption = 'Group By';
            OptionCaption = 'Document No.,External Document No.,Section Code';
            OptionMembers = "Document No.","External Document No.","Section Code";
            DataClassification = CustomerContent;
        }
        field(10; "Simplified Tax Doc. Sect. Code"; Code[20])
        {
            Caption = 'Simplified Tax Document Section Code';
            TableRelation = "VAT Ctrl. Report Section CZL".Code;
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }
}
