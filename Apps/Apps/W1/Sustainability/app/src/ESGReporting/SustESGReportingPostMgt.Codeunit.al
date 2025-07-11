// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using Microsoft.Foundation.NoSeries;
using Microsoft.Sustainability.Setup;
using System.Utilities;

codeunit 6261 "Sust. ESG Reporting Post. Mgt"
{
    TableNo = "Sust. ESG Reporting Line";
    EventSubscriberInstance = Manual;

    trigger OnRun()
    var
        ESGReportingLine: Record "Sust. ESG Reporting Line";
    begin
        ESGReportingLine.Copy(Rec);
        ESGReportingLine.SetAutoCalcFields();
        RunWithCheck(ESGReportingLine);
    end;

    internal procedure RunWithCheck(var ESGReportingLine: Record "Sust. ESG Reporting Line")
    begin
        SustainabilitySetup.GetRecordOnce();
        ESGReportingName.Get(ESGReportingLine."ESG Reporting Template Name", ESGReportingLine."ESG Reporting Name");

        ESGReportingLine.SetRange("ESG Reporting Template Name", ESGReportingLine."ESG Reporting Template Name");
        ESGReportingLine.SetRange("ESG Reporting Name", ESGReportingLine."ESG Reporting Name");

        CheckAndCreatePostedDocument(ESGReportingLine);
    end;

    internal procedure PostESGReport(var ESGReportingLine: Record "Sust. ESG Reporting Line")
    var
        ESGReportingLine2: Record "Sust. ESG Reporting Line";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(CanPostESGReportQst, ESGReportingLine."ESG Reporting Template Name", ESGReportingLine."ESG Reporting Name"), true) then
            exit;

        ESGReportingLine2.Copy(ESGReportingLine);
        ESGReportingLine2.SetAutoCalcFields();

        RunWithCheck(ESGReportingLine2);

        if PostedESGReportHeader."No." <> '' then begin
            UpdateESGReportingName(ESGReportingName);

            if GuiAllowed() then
                Message(PostedESGReportNoHasBeenCreatedMsg, PostedESGReportHeader."No.");
        end;
    end;

    local procedure CheckAndCreatePostedDocument(var ESGReportingLine: Record "Sust. ESG Reporting Line")
    begin
        ValidateESGReporting(ESGReportingLine);

        InsertPostedHeader();
        ProcessPostLines(ESGReportingLine);
    end;

    local procedure ValidateESGReporting(var ESGReportingLine: Record "Sust. ESG Reporting Line")
    begin
        SustainabilitySetup.TestField("Posted ESG Reporting Nos.");
        ESGReportingName.TestField(Posted, false);
        ESGReportingName.TestField(Period);

        if ESGReportingLine.IsEmpty() then
            Error(NothingToPostErr);
    end;

    local procedure InsertPostedHeader()
    var
        NoSeries: Codeunit "No. Series";
    begin
        PostedESGReportHeader.Init();
        PostedESGReportHeader.TransferFields(ESGReportingName);
        PostedESGReportHeader."No." := NoSeries.GetNextNo(SustainabilitySetup."Posted ESG Reporting Nos.", Today);
        PostedESGReportHeader.Insert();
    end;

    local procedure ProcessPostLines(var ESGReportingLine: Record "Sust. ESG Reporting Line")
    var
        ESGReportingHelperMgt: Codeunit "Sust. ESG Reporting Helper Mgt";
    begin
        SetDateFilter(ESGReportingLine, ESGReportingName);
        ESGReportingHelperMgt.InitializeRequest(ESGReportingName, ESGReportingLine, ESGReportingName."Country/Region Code");

        if ESGReportingLine.FindSet() then
            repeat
                PostedESGReportLine.Init();
                PostedESGReportLine.TransferFields(ESGReportingLine);
                PostedESGReportLine."Document No." := PostedESGReportHeader."No.";

                ESGReportingHelperMgt.CalcLineTotal(ESGReportingLine, PostedESGReportLine."Posted Amount", 0);
                PostedESGReportLine.Insert();
            until ESGReportingLine.Next() = 0;
    end;

    local procedure UpdateESGReportingName(var ESGReportingName: Record "Sust. ESG Reporting Name")
    begin
        ESGReportingName.Validate(Posted, true);
        ESGReportingName.Modify();
    end;

    local procedure SetDateFilter(var ESGReportingLine: Record "Sust. ESG Reporting Line"; ESGReportingName: Record "Sust. ESG Reporting Name")
    var
        Period: Record Date;
    begin
        Period.SetRange("Period Type", Period."Period Type"::Year);
        Period.SetRange("Period No.", ESGReportingName.Period);
        if Period.FindFirst() then
            ESGReportingLine.SetRange("Date Filter", Period."Period Start", Period."Period End");
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        PostedESGReportHeader: Record "Sust. Posted ESG Report Header";
        PostedESGReportLine: Record "Sust. Posted ESG Report Line";
        CanPostESGReportQst: Label 'Do you want to post ESG Report with Template Name %1, Batch Name %2 ?', Comment = '%1 = ESG Reporting Template Name, %2 = ESG Reporting Name';
        PostedESGReportNoHasBeenCreatedMsg: Label 'Posted ESG Reporting no. %1 has been created.', Comment = '%1 = Posted ESG Reporting No. ';
        NothingToPostErr: Label 'There is nothing to post to ESG reporting.';
}