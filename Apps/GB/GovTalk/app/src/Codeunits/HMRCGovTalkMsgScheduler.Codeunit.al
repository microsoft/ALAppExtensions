// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using System.Threading;
using System.Xml;
using Microsoft.Finance.VAT.Reporting;
using System;

codeunit 10511 "HMRC GovTalk Msg. Scheduler"
{
    TableNo = "Job Queue Entry";
    trigger OnRun()
    var
        VATReportHeader: Record "VAT Report Header";
        RecRef: RecordRef;
    begin
        if RecRef.Get(Rec."Record ID to Process") then begin
            RecRef.SetTable(VATReportHeader);
            SendPollMessage(VATReportHeader, Rec."Parameter String");
        end;
    end;

    var
        GovTalkMessageManagement: Codeunit "GovTalk Message Management";
        XMLDOMManagement: Codeunit "XML DOM Management";
        GovTalkNameSpaceTxt: Label 'http://www.govtalk.gov.uk/CM/envelope', Locked = true;
        XMLPartMissingErr: Label 'A section of the XML document is missing.';

    local procedure SendPollMessage(var VATReportHeader: Record "VAT Report Header"; XMLPartID: Text)
    var
        GovTalkMessage: Record "GovTalk Message";
        GovTalkMessageParts: Record "GovTalk Msg. Parts";
        GovTalkMessageXMLNode: DotNet XmlNode;
        CorrelationXMLNode: DotNet XmlNode;
        PartIDGuid: Guid;
    begin
        GovTalkMessageManagement.CreateGovTalkPollMessage(GovTalkMessageXMLNode, VATReportHeader);
        if VATReportHeader."VAT Report Config. Code" = VATReportHeader."VAT Report Config. Code"::"EC Sales List" then begin
            if not GovTalkMessageParts.Get(XMLPartID) then
                Error('');
            if XMLDOMManagement.FindNodeWithNamespace(GovTalkMessageXMLNode, '//x:CorrelationID', 'x', GovTalkNameSpaceTxt, CorrelationXMLNode) then
                CorrelationXMLNode.InnerText := GovTalkMessageParts."Correlation Id"
            else
                Error(XMLPartMissingErr);
        end;

        Evaluate(PartIDGuid, XMLPartID);
        if GovTalkMessage.Get(VATReportHeader."VAT Report Config. Code", VATReportHeader."No.") then
            if not GovTalkMessageManagement.ProcessGovTalkSubmission(
                 VATReportHeader, GovTalkMessage.ResponseEndPoint, GovTalkMessageXMLNode, true, true, PartIDGuid)
            then
                GovTalkMessageManagement.RegisterGovTalkPolling(VATReportHeader, XMLPartID);
    end;
}

