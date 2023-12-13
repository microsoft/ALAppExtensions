// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 11775 "VAT Statement Comment Line CZL"
{
    Caption = 'VAT Statement Comment Line';
    DrillDownPageId = "VAT Statement Comments CZL";
    LookupPageId = "VAT Statement Comments CZL";

    fields
    {
        field(1; "VAT Statement Template Name"; Code[10])
        {
            Caption = 'VAT Statement Template Name';
            NotBlank = true;
            TableRelation = "VAT Statement Template";
            DataClassification = CustomerContent;
        }
        field(2; "VAT Statement Name"; Code[10])
        {
            Caption = 'VAT Statement Name';
            NotBlank = true;
            TableRelation = "VAT Statement Name".Name;
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(4; Date; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(5; Comment; Text[72])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "VAT Statement Template Name", "VAT Statement Name", "Line No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        CheckCommentsAllowed();
    end;

    procedure CheckCommentsAllowed()
    var
        VATStatementTemplate: Record "VAT Statement Template";
    begin
        VATStatementTemplate.Get("VAT Statement Template Name");
        VATStatementTemplate.TestField("Allow Comments/Attachments CZL");
    end;
}
