// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using System.IO;

codeunit 5014 "Export Service Declaration"
{
    TableNo = "Service Declaration Header";

    trigger OnRun()
    var
        ServiceDeclarationSetup: Record "Service Declaration Setup";
        ServiceDeclarationLine: Record "Service Declaration Line";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        DataExchMapping: Record "Data Exch. Mapping";
        OutStr: OutStream;
        IsHandled: Boolean;
        PeriodAlreadyReportedQst: Label 'You''ve already submitted the report for this period.\Do you want to continue?';
    begin
        if Rec.Reported then
            if not Confirm(PeriodAlreadyReportedQst) then
                exit;

        IsHandled := false;
        OnBeforeExportServiceDeclaration(Rec, IsHandled);

        if not IsHandled then begin
            ServiceDeclarationSetup.Get();
            ServiceDeclarationSetup.TestField("Data Exch. Def. Code");
            DataExchDef.Get(ServiceDeclarationSetup."Data Exch. Def. Code");
            DataExchMapping.SetRange("Data Exch. Def Code", DataExchDef.Code);
            DataExchMapping.SetRange("Table ID", Database::"Service Declaration Line");
            DataExchMapping.FindFirst();

            DataExch.Init();
            DataExch."Data Exch. Def Code" := DataExchMapping."Data Exch. Def Code";
            DataExch."Data Exch. Line Def Code" := DataExchMapping."Data Exch. Line Def Code";
            DataExch."Table Filters".CreateOutStream(OutStr);
            ServiceDeclarationLine.SetRange("Service Declaration No.", Rec."No.");
            OutStr.WriteText(ServiceDeclarationLine.GetView());
            DataExch.Insert(true);
            DataExch.ExportFromDataExch(DataExchMapping);
        end;

        Rec.Reported := true;
        Rec."Export Date" := Today;
        Rec."Export Time" := Time;
        Rec.Modify();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportServiceDeclaration(var ServiceDeclarationHeader: Record "Service Declaration Header"; var IsHandled: Boolean)
    begin
    end;
}
