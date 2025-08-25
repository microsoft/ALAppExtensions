// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using System;
using Microsoft.Finance.VAT.Reporting;

#pragma warning disable AA0247
codeunit 10519 "EC Sales List Submit GB"
{
    TableNo = "VAT Report Header";
    trigger OnRun()
    var
        GovTalkMessageParts: Record "GovTalk Msg. Parts";
        ECSalesListPopulateXML: Codeunit "EC Sales List XML";
        GovTalkMessageManagement: Codeunit "GovTalk Message Management";
        GovTalkRequestXMLNode: DotNet XmlNode;
    begin
        DefaltPartMaxLines := 9999;
        SplitLines(Rec);

        SetGovTalkPartsFilter(GovTalkMessageParts, Rec);
        if not GovTalkMessageParts.FindSet() then
            exit;

        repeat
            if not ECSalesListPopulateXML.GetECSLDeclarationRequestMessage(GovTalkRequestXMLNode, Rec, GovTalkMessageParts."Part Id") then
                exit;

            GovTalkMessageManagement.SubmitECSLGovTalkRequest(Rec, GovTalkRequestXMLNode, GovTalkMessageParts."Part Id");
        until GovTalkMessageParts.Next() = 0;
    end;

    var
        DefaltPartMaxLines: Integer;

    local procedure SplitLines(VATReportHeader: Record "VAT Report Header")
    var
        GovTalkMessageParts: Record "GovTalk Msg. Parts";
        ECSLVATReportLine: Record "ECSL VAT Report Line";
        ModifyECSLVATReportLine: Record "ECSL VAT Report Line";
        Counter: Integer;
        MaxLineNo: Integer;
    begin
        MaxLineNo := GetMaxLineNo(VATReportHeader);

        SetGovTalkPartsFilter(GovTalkMessageParts, VATReportHeader);
        if not GovTalkMessageParts.IsEmpty() then
            exit;
        InitGovTalkMessagePart(GovTalkMessageParts, VATReportHeader);

        ECSLVATReportLine.SetRange("Report No.", VATReportHeader."No.");
        if not ECSLVATReportLine.FindSet() then
            exit;

        GetGovTalkMessagePart(GovTalkMessageParts);
        ModifyECSLVATReportLine.SetRange("Report No.", VATReportHeader."No.");
        ModifyECSLVATReportLine.ModifyAll("XML Part Id GB", GovTalkMessageParts."Part Id");

        Counter := 0;
        repeat
            if Counter = MaxLineNo then begin
                GetGovTalkMessagePart(GovTalkMessageParts);
                ModifyECSLVATReportLine.SetFilter("Line No.", '>=%1', ECSLVATReportLine."Line No.");
                ModifyECSLVATReportLine.ModifyAll("XML Part Id GB", GovTalkMessageParts."Part Id");
                Counter := 0;
            end;
            Counter += 1;
        until ECSLVATReportLine.Next() = 0;

        ModifyECSLVATReportLine.Reset();
        ModifyECSLVATReportLine.SetRange("XML Part Id GB", GovTalkMessageParts."Part Id");
        if ModifyECSLVATReportLine.IsEmpty() then
            GovTalkMessageParts.Delete(true);
    end;

    local procedure GetGovTalkMessagePart(var GovTalkMessageParts: Record "GovTalk Msg. Parts")
    begin
        GovTalkMessageParts."Part Id" := CreateGuid();
        GovTalkMessageParts.Insert();
    end;

    local procedure GetMaxLineNo(VATReportHeader: Record "VAT Report Header"): Integer
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        VATReportsConfiguration.SetRange("VAT Report Type", VATReportHeader."VAT Report Config. Code");
        VATReportsConfiguration.SetRange("VAT Report Version", VATReportHeader."VAT Report Version");
        if VATReportsConfiguration.FindFirst() then;
        if VATReportsConfiguration."Content Max Lines GB" = 0 then
            exit(DefaltPartMaxLines);

        exit(VATReportsConfiguration."Content Max Lines GB");
    end;

    local procedure InitGovTalkMessagePart(var GovTalkMessageParts: Record "GovTalk Msg. Parts"; VATReportHeader: Record "VAT Report Header")
    begin
        GovTalkMessageParts.Validate("Report No.", VATReportHeader."No.");
        GovTalkMessageParts.Validate("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code"::"EC Sales List");
        GovTalkMessageParts.Validate(Status, GovTalkMessageParts.Status::Released);
    end;

    local procedure SetGovTalkPartsFilter(var GovTalkMessageParts: Record "GovTalk Msg. Parts"; VATReportHeader: Record "VAT Report Header")
    begin
        GovTalkMessageParts.SetRange("Report No.", VATReportHeader."No.");
        GovTalkMessageParts.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code"::"EC Sales List");
    end;
}

