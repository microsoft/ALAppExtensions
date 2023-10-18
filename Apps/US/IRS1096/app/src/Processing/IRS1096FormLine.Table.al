// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Vendor;

table 10019 "IRS 1096 Form Line"
{
    Caption = 'IRS 1096 Form Line';

    fields
    {
        field(1; "Form No."; Code[20])
        {
            Caption = 'Form No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "IRS Code"; Code[20])
        {
            Caption = 'IRS Code';
            TableRelation = "IRS 1099 Form-Box";
        }
        field(4; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(5; "Calculated Amount"; Decimal)
        {
            Caption = 'Calculated Amount';
            Editable = false;
        }
        field(6; "Total Amount"; Decimal)
        {
            Caption = 'Amount';

            trigger OnValidate()
            begin
                UpdateHeaderTotals();
            end;
        }
        field(7; "Calculated Adjustment Amount"; Decimal)
        {
            Caption = 'Calculated Adjustment Amount';
            Editable = false;
        }
        field(20; "Manually Changed"; Boolean)
        {
            Caption = 'Manually Changed';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Form No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnModify()
    var
        IRS1096FormHeader: Record "IRS 1096 Form Header";
    begin
        "Manually Changed" := true;
        IRS1096FormHeader.Get("Form No.");
        IRS1096FormHeader."Changed By" := CopyStr(UserId(), 1, MaxStrLen(IRS1096FormHeader."Changed By"));
        IRS1096FormHeader."Changed Date-Time" := CurrentDateTime();
        IRS1096FormHeader.Modify();
    end;

    trigger OnDelete()
    var
        IRS1096FormLineRelation: Record "IRS 1096 Form Line Relation";
    begin
        IRS1096FormLineRelation.SetRange("Form No.", "Form No.");
        IRS1096FormLineRelation.SetRange("Line No.", "Line No.");
        IRS1096FormLineRelation.DeleteAll(true);
    end;

    procedure ShowAdjustments()
    var
        IRS1096FormHeader: Record "IRS 1096 Form Header";
        IRS1099Adjustment: Record "IRS 1099 Adjustment";
        IRS1099Adjustments: Page "IRS 1099 Adjustments";
    begin
        IRS1096FormHeader.Get("Form No.");
        IRS1099Adjustment.SetRange(Year, Date2DMY(IRS1096FormHeader."Starting Date", 3), Date2DMY(IRS1096FormHeader."Ending Date", 3));
        IRS1099Adjustment.SetRange("Vendor No.", "Vendor No.");
        IRS1099Adjustment.SetRange("IRS 1099 Code", "IRS Code");
        IRS1099Adjustments.Editable := false;
        IRS1099Adjustments.SetTableView(IRS1099Adjustment);
        IRS1099Adjustments.Run();
    end;

    local procedure UpdateHeaderTotals()
    var
        IRS1096FormLine: Record "IRS 1096 Form Line";
        IRS1096FormHeader: Record "IRS 1096 Form Header";
    begin
        IRS1096FormLine.SetRange("Form No.", "Form No.");
        IRS1096FormLine.SetFilter("Line No.", '<>%1', "Line No.");
        IRS1096FormLine.CalcSums("Total Amount");
        IRS1096FormHeader.Get("Form No.");
        IRS1096FormHeader."Total Amount To Report" := IRS1096FormLine."Total Amount" + "Total Amount";
        IRS1096FormHeader.Modify(true);
    end;
}
