// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 10032 "IRS 1099 Form"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "IRS 1099 Forms";
    LookupPageId = "IRS 1099 Forms";

    fields
    {
        field(1; "Period No."; Code[20])
        {
            TableRelation = "IRS Reporting Period";
        }
        field(2; "No."; Code[20])
        {
            NotBlank = true;
        }
        field(3; Description; Text[250])
        {
        }
        field(100; "Boxes Count"; Integer)
        {
            CalcFormula = count("IRS 1099 Form Box" where("Period No." = field("Period No."), "Form No." = field("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "Period No.", "No.")
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
        FormIsUsedErr: Label 'The 1099 form %1 is used in the 1099 form document header.', Comment = '%1 = Form number'; 

    trigger OnDelete()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormBox: Record "IRS 1099 Form Box";
        IRSForm1099StatementLine: Record "IRS 1099 Form Statement Line";
        IRS1099FormInstruction: Record "IRS 1099 Form Instruction";
    begin
        IRS1099FormDocHeader.SetRange("Period No.", "Period No.");
        IRS1099FormDocHeader.SetRange("Form No.", "No.");
        if not IRS1099FormDocHeader.IsEmpty() then
            Error(FormIsUsedErr, "No.");
        IRS1099FormBox.SetRange("Period No.", "Period No.");
        IRS1099FormBox.SetRange("Form No.", "No.");
        IRS1099FormBox.DeleteAll(true);
        IRSForm1099StatementLine.SetRange("Period No.", "Period No.");
        IRSForm1099StatementLine.SetRange("Form No.", "No.");
        IRSForm1099StatementLine.DeleteAll(true);
        IRS1099FormInstruction.SetRange("Period No.", "Period No.");
        IRS1099FormInstruction.SetRange("Form No.", "No.");
        IRS1099FormInstruction.DeleteAll(true);
    end;
}
