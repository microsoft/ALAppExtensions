// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 10033 "IRS 1099 Form Box"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "IRS 1099 Form Boxes";
    LookupPageId = "IRS 1099 Form Boxes";

    fields
    {
        field(1; "Period No."; Code[20])
        {
            TableRelation = "IRS Reporting Period";
        }
        field(2; "Form No."; Code[20])
        {
            TableRelation = "IRS 1099 Form"."No." where("Period No." = field("Period No."));
        }
        field(3; "No."; Code[20])
        {
            NotBlank = true;
        }
        field(4; Description; Text[250])
        {
        }
        field(5; "Minimum Reportable Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = '';
        }
    }

    keys
    {
        key(PK; "Period No.", "Form No.", "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description)
        {
        }
        fieldgroup(Brick; "No.", Description)
        {
        }
    }

    var
        FormBoxCannotBeDeletedErr: Label 'The 1099 form box %1 cannot be deleted because it is used in the 1099 form document lines.', Comment = '%1 = Form box number';

    trigger OnDelete()
    var
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
    begin
        IRS1099FormDocLine.SetRange("Period No.", "Period No.");
        IRS1099FormDocLine.SetRange("Form No.", "Form No.");
        IRS1099FormDocLine.SetRange("Form Box No.", "No.");
        if not IRS1099FormDocLine.IsEmpty() then
            Error(FormBoxCannotBeDeletedErr, "No.");
    end;
}
