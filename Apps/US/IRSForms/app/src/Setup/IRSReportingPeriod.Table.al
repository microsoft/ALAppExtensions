// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 10031 "IRS Reporting Period"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "IRS Reporting Periods";
    LookupPageId = "IRS Reporting Periods";

    fields
    {
        field(1; "No."; Code[20])
        {
            NotBlank = true;
        }
        field(2; "Starting Date"; Date)
        {
            NotBlank = true;

            trigger OnValidate()
            begin
                CheckStartingAndEndingDatesConsistency();
                CheckNoConnectedFormDocuments(FieldCaption("Starting Date"));
            end;
        }
        field(3; "Ending Date"; Date)
        {
            NotBlank = true;

            trigger OnValidate()
            begin
                CheckStartingAndEndingDatesConsistency();
                CheckNoConnectedFormDocuments(FieldCaption("Ending Date"));
            end;
        }
        field(4; Description; Text[250])
        {
        }
        field(100; "Forms In Period"; Integer)
        {
            CalcFormula = count("IRS 1099 Form" where("Period No." = field("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    var
        StartingEndingDateOverlapErr: Label 'The starting date and ending date overlap with an existing reporting period.';
        CannotChangeWhenOpenFormDocumentConnectedErr: Label 'Cannot change %1 when one or more open form documents are connected', Comment = '%1 - field caption';
        StartingDateMoreThanEndingDateErr: Label 'Starting date cannot be greater than ending date';

    trigger OnDelete()
    var
        IRS1099Form: Record "IRS 1099 Form";
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
        IRS1099VendorFormBoxAdj: Record "IRS 1099 Vendor Form Box Adj.";
    begin
        IRS1099Form.SetRange("Period No.", "No.");
        IRS1099Form.DeleteAll(true);
        IRS1099VendorFormBoxSetup.SetRange("Period No.", "No.");
        IRS1099VendorFormBoxSetup.DeleteAll(true);
        IRS1099VendorFormBoxAdj.SetRange("Period No.", "No.");
        IRS1099VendorFormBoxAdj.DeleteAll(true);
    end;

    local procedure CheckNoConnectedFormDocuments(ChangedFieldCaption: Text)
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
    begin
        IRS1099FormDocHeader.SetRange("Period No.", "No.");
        if not IRS1099FormDocHeader.IsEmpty() then
            Error(CannotChangeWhenOpenFormDocumentConnectedErr, ChangedFieldCaption);
    end;

    local procedure CheckStartingAndEndingDatesConsistency()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        if (Rec."Starting Date" <> 0D) and (Rec."Ending Date" <> 0D) then begin
            if Rec."Starting Date" > Rec."Ending Date" then
                Error(StartingDateMoreThanEndingDateErr);
            IRSReportingPeriod.SetFilter("No.", '<>%1', Rec."No.");
            if not IRSReportingPeriod.FindSet() then
                exit;
            repeat
                if ("Starting Date" in [IRSReportingPeriod."Starting Date" .. IRSReportingPeriod."Ending Date"]) or
                   ("Ending Date" in [IRSReportingPeriod."Starting Date" .. IRSReportingPeriod."Ending Date"])
                then
                    Error(StartingEndingDateOverlapErr);
            until IRSReportingPeriod.Next() = 0;
        end;
    end;
}
