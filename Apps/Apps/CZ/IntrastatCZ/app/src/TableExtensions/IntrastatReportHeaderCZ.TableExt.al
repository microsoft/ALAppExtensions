// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using System.Utilities;

tableextension 31330 "Intrastat Report Header CZ" extends "Intrastat Report Header"
{
    fields
    {
        field(31300; "Statement Type CZ"; Enum "Intrastat Statement Type CZ")
        {
            Caption = 'Statement Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Statement Type CZ" = xRec."Statement Type CZ" then
                    exit;
                if "Statement Type CZ" <> "Statement Type CZ"::Negative then
                    exit;
                if ConfirmManagement.GetResponseOrDefault(CreateNegativeLinesQst, true) then
                    InsertLinesForNegativeReport()
                else
                    "Statement Type CZ" := xRec."Statement Type CZ";
            end;
        }
    }

    var
        ConfirmManagement: Codeunit "Confirm Management";
        CreateNegativeLinesQst: Label 'Do you want to insert blank lines for negative intrastat report?';
        NegativeIntrastatReportLineTxt: Label 'Negative intrastat report line';

    local procedure InsertLinesForNegativeReport()
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportLineType: Enum "Intrastat Report Line Type";
    begin
        IntrastatReportLine.SetRange("Intrastat No.", "No.");
        IntrastatReportLine.DeleteAll();
        InsertNegativeLine(10000, IntrastatReportLineType::Receipt);
        InsertNegativeLine(20000, IntrastatReportLineType::Shipment);
    end;

    local procedure InsertNegativeLine(LineNo: Integer; IntrastatReportLineType: Enum "Intrastat Report Line Type")
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        SpecificMovementCZ: Record "Specific Movement CZ";
    begin
        SpecificMovementCZ.GetOrCreate(SpecificMovementCZ.GetNegativeCode());
        IntrastatReportLine.Init();
        IntrastatReportLine."Intrastat No." := "No.";
        IntrastatReportLine."Line No." := LineNo;
        IntrastatReportLine.Type := IntrastatReportLineType;
        IntrastatReportLine."Specific Movement CZ" := SpecificMovementCZ.Code;
        IntrastatReportLine."Internal Note 1 CZ" := NegativeIntrastatReportLineTxt;
        IntrastatReportLine.Insert(true);
    end;
}