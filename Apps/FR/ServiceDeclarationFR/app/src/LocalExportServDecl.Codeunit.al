// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using Microsoft.Foundation.Company;
using System.IO;

codeunit 10891 "Local Export Serv. Decl."
{
    TableNo = "Service Declaration Header";

    trigger OnRun()
    var
        ServiceDeclarationSetup: Record "Service Declaration Setup";
        ServiceDeclarationHeader: Record "Service Declaration Header";
        ServiceDeclarationLine: Record "Service Declaration Line";
        CompanyInformation: Record "Company Information";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        DataExchMapping: Record "Data Exch. Mapping";
        DataExchTableFilter: Record "Data Exch. Table Filter";
        OutStr: OutStream;
    begin
        ServiceDeclarationSetup.Get();
        ServiceDeclarationSetup.TestField("Enable VAT Registration No.");
        ServiceDeclarationSetup.TestField("Data Exch. Def. Code");
        DataExchDef.Get(ServiceDeclarationSetup."Data Exch. Def. Code");

        DataExchMapping.SetRange("Data Exch. Def Code", DataExchDef.Code);
        DataExchMapping.SetRange("Table ID", DATABASE::"Service Declaration Line");
        DataExchMapping.FindFirst();

        DataExch."Data Exch. Def Code" := DataExchMapping."Data Exch. Def Code";
        DataExch."Data Exch. Line Def Code" := DataExchMapping."Data Exch. Line Def Code";
        DataExch."Table Filters".CreateOutStream(OutStr);
        ServiceDeclarationLine.SetRange("Service Declaration No.", Rec."No.");
        OutStr.WriteText(ServiceDeclarationLine.GetView(false));
        DataExch.Insert(true);

        DataExchTableFilter.Init();
        DataExchTableFilter."Data Exch. No." := DataExch."Entry No.";
        DataExchTableFilter."Table ID" := Database::"Service Declaration Header";
        DataExchTableFilter."Table Filters".CreateOutStream(OutStr);
        ServiceDeclarationHeader := Rec;
        ServiceDeclarationHeader.SetRecFilter();
        OutStr.WriteText(ServiceDeclarationHeader.GetView(false));
        DataExchTableFilter.Insert();

        DataExchTableFilter.Init();
        DataExchTableFilter."Data Exch. No." := DataExch."Entry No.";
        DataExchTableFilter."Table ID" := Database::"Company Information";
        DataExchTableFilter."Table Filters".CreateOutStream(OutStr);
        CompanyInformation.FindFirst();
        CompanyInformation.SetRecFilter();
        OutStr.WriteText(CompanyInformation.GetView(false));
        DataExchTableFilter.Insert();

        DataExch.ExportFromDataExch(DataExchMapping);

        DataExchTableFilter.SetRange("Data Exch. No.", DataExchTableFilter."Data Exch. No.");
        DataExchTableFilter.DeleteAll(true);
    end;
}
