// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Vendor;

table 10036 "IRS 1099 Form Doc. Line"
{
    DataClassification = CustomerContent;
    Caption = 'IRS 1099 Form Document Line';

    fields
    {
        field(1; "Document ID"; Integer)
        {
        }
        field(2; "Period No."; Code[20])
        {
            TableRelation = "IRS Reporting Period";
            Editable = false;
        }
        field(3; "Vendor No."; Code[20])
        {
            TableRelation = Vendor;
            Editable = false;
        }
        field(4; "Form No."; Code[20])
        {
            TableRelation = "IRS 1099 Form"."No." where("Period No." = field("Period No."));
            Editable = false;
        }
        field(5; "Line No."; Integer)
        {
            Editable = false;
        }
        field(6; "Form Box No."; Code[20])
        {
            TableRelation = "IRS 1099 Form Box"."No." where("Period No." = field("Period No."), "Form No." = field("Form No."));
            NotBlank = true;

            trigger OnValidate()
            begin
                TestStatusOpen();
                CheckFormBoxCanBeChanged();
                CheckFormBoxUniqueness();
            end;
        }
        field(10; "Calculated Amount"; Decimal)
        {
            Editable = false;
        }
        field(11; Amount; Decimal)
        {

            trigger OnValidate()
            begin
                TestStatusOpen();
                Validate("Include In 1099", Rec.Amount > Rec."Minimum Reportable Amount");
            end;
        }
        field(20; "Manually Changed"; Boolean)
        {
            Editable = false;
        }
        field(30; "Include In 1099"; Boolean)
        {
            Editable = false;
        }
        field(100; "Minimum Reportable Amount"; Decimal)
        {
            Editable = false;
        }
        field(101; "Adjustment Amount"; Decimal)
        {
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Period No.", "Vendor No.", "Form No.", "Document ID", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        CannotChangeFormBoxWithCalculatedAmountErr: Label 'You cannot change the Form Box No. for the line with calculated amount.';
        CreateCreateFormDocLineSameFormBoxErr: Label 'You cannot create two form document lines with the same form box.';

    trigger OnDelete()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLineDetail: Record "IRS 1099 Form Doc. Line Detail";
    begin
        if IRS1099FormDocHeader.Get("Document ID") then
            IRS1099FormDocHeader.TestField(Status, IRS1099FormDocHeader.Status::Open);
        IRS1099FormDocLineDetail.SetRange("Document ID", "Document ID");
        IRS1099FormDocLineDetail.SetRange("Line No.", "Line No.");
        IRS1099FormDocLineDetail.DeleteAll(true);
    end;

    local procedure CheckFormBoxCanBeChanged()
    begin
        if xRec."Form Box No." = '' then
            exit;
        if "Calculated Amount" <> 0 then
            Error(CannotChangeFormBoxWithCalculatedAmountErr);
        Amount := 0;
        "Include In 1099" := false;
    end;

    local procedure TestStatusOpen()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
    begin
        if "Document ID" <> 0 then
            if IRS1099FormDocHeader.Get("Document ID") then
                IRS1099FormDocHeader.TestField(Status, IRS1099FormDocHeader.Status::Open);
    end;

    local procedure CheckFormBoxUniqueness()
    var
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
    begin
        if Rec."Form Box No." = '' then
            exit;
        IRS1099FormDocLine.SetRange("Document ID", "Document ID");
        IRS1099FormDocLine.SetFilter("Line No.", '<>%1', Rec."Line No.");
        IRS1099FormDocLine.SetRange("Form Box No.", Rec."Form Box No.");
        if not IRS1099FormDocLine.IsEmpty() then
            Error(CreateCreateFormDocLineSameFormBoxErr);
    end;
}
