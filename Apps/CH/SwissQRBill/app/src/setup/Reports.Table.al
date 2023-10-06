// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Foundation.Reporting;

table 11514 "Swiss QR-Bill Reports"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Report Type"; Enum "Swiss QR-Bill Reports")
        {
            Caption = 'Name';
            Editable = false;
        }
        field(2; Enabled; Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            begin
                ModifyReport();
            end;
        }
    }

    keys
    {
        key(PK; "Report Type")
        {
            Clustered = true;
        }
    }

    internal procedure InitBuffer()
    var
        Usage: Enum "Report Selection Usage";
    begin
        Add("Report Type"::"Posted Sales Invoice", Usage::"S.Invoice");
        Add("Report Type"::"Posted Service Invoice", Usage::"SM.Invoice");
    end;

    local procedure Add(ReportType: Enum "Swiss QR-Bill Reports"; UsageFilter: Enum "Report Selection Usage")
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.SetRange("Report ID", Report::"Swiss QR-Bill Print");
        ReportSelections.SetRange(Usage, UsageFilter);
        "Report Type" := ReportType;
        Enabled := not ReportSelections.IsEmpty();
        Insert();
    end;

    internal procedure MapReportTypeToReportUsage() Result: Enum "Report Selection Usage"
    begin
        case "Report Type" of
            "Report Type"::"Posted Sales Invoice":
                exit(Result::"S.Invoice");
            "Report Type"::"Posted Service Invoice":
                exit(Result::"SM.Invoice");
            "Report Type"::"Issued Reminder":
                exit(Result::Reminder);
            "Report Type"::"Issued Finance Charge Memo":
                exit(Result::"Fin.Charge");
        end;
    end;

    local procedure ModifyReport()
    var
        ReportSelections: Record "Report Selections";
        ReportUsage: Enum "Report Selection Usage";
        Exists: Boolean;
    begin
        ReportUsage := MapReportTypeToReportUsage();

        ReportSelections.SetRange(Usage, ReportUsage);
        ReportSelections.SetRange("Report ID", Report::"Swiss QR-Bill Print");
        Exists := ReportSelections.FindFirst();
        if not Exists and Enabled then begin
            ReportSelections.SetRange("Report ID");
            ReportSelections.NewRecord();
            ReportSelections.Validate(Usage, ReportUsage);
            ReportSelections.Validate("Report ID", Report::"Swiss QR-Bill Print");
            ReportSelections.Insert();
        end;
        if Exists and not Enabled then
            ReportSelections.Delete();
    end;
}
