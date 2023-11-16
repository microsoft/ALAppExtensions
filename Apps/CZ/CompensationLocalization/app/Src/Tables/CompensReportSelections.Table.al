// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.Foundation.Reporting;
using System.Reflection;

table 31271 "Compens. Report Selections CZC"
{
    Caption = 'Compensation Report Selections';
    LookupPageId = "Compens. Report Selections CZC";

    fields
    {
        field(1; Usage; Enum "Compens. Report Sel. Usage CZC")
        {
            Caption = 'Usage';
            DataClassification = CustomerContent;
        }
        field(2; Sequence; Code[10])
        {
            Caption = 'Sequence';
            Numeric = true;
            DataClassification = CustomerContent;
        }
        field(3; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            TableRelation = AllObj."Object ID" where("Object Type" = const(Report));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalcFields("Report Caption");
            end;
        }
        field(4; "Report Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Report), "Object ID" = field("Report ID")));
            Caption = 'Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; Usage, Sequence)
        {
            Clustered = true;
        }
        key(Key2; "Report ID")
        {
        }
    }

    var
        LastReportSelections: Record "Report Selections";

    procedure NewRecord()
    begin
        LastReportSelections.SetRange(Usage, Usage);
        if LastReportSelections.FindLast() and (LastReportSelections.Sequence <> '') then
            Sequence := IncStr(LastReportSelections.Sequence)
        else
            Sequence := '1';
    end;
}
