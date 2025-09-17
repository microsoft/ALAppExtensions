// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Foundation.Company;
using System.Integration;
using System.Threading;
using System.Utilities;
using System.Xml;
using Microsoft.Finance.VAT.Reporting;
using System;

codeunit 10569 "GovTalk Message Management"
{
    trigger OnRun()
    begin
    end;

    var
        GovTalkSetup: Record "Gov Talk Setup";
        CompanyInformation: Record "Company Information";
        XMLDOMManagement: Codeunit "XML DOM Management";
        GovTalkNameSpaceTxt: Label 'http://www.govtalk.gov.uk/CM/envelope', Locked = true;
        VATDeclarationMessageClassTxt: Label 'HMRC-VAT-DEC', Locked = true;
        ECSLDeclarationMessageClassTxt: Label 'HMCE-ECSL-ORG-V101', Locked = true;
        ErrorResponseNameSpaceTxt: Label 'http://www.govtalk.gov.uk/CM/errorresponse', Locked = true;
        SuccessResponseNameSpaceTxt: Label 'http://www.inlandrevenue.gov.uk/SuccessResponse', Locked = true;
        VATDeclarationNameSpaceTxt: Label 'http://www.govtalk.gov.uk/taxation/vat/vatdeclaration/2', Locked = true;
        ECSLDeclarationNameSpaceTxt: Label 'http://www.govtalk.gov.uk/taxation/vat/europeansalesdeclaration/1', Locked = true;
        VATCoreNameSpaceTxt: Label 'http://www.govtalk.gov.uk/taxation/vat/core/1', Locked = true;
        InvalidGovTalkMessagePartIDErr: Label 'The XML part id is invalid.';
        MessageClassTxt: Label '%1-TIL', Comment = '%1 = message class';
        NotificationTxt: Label 'Line No. %1 Acknowledged', Comment = '%1 = response node';
        ErrorTxt: Label 'Line No. %1 failed with error: %2', Comment = '%1 = response node, %2 = status node';


    [Scope('OnPrem')]
    [NonDebuggable]
    procedure CreateBlankGovTalkXmlMessage(var GovTalkMessageXMLNode: DotNet XmlNode; var BodyXMLNode: DotNet XmlNode; VATReportHeader: Record "VAT Report Header"; Qualifier: Text; Fn: Text; IncludeSenderDetails: Boolean): Boolean
    var
        GovTalkMessage: Record "GovTalk Message";
        GovTalkVATReportValidate: Codeunit "GovTalk Validate VAT Report";
        XmlDoc: DotNet XmlDocument;
        HeaderXMLNode: DotNet XmlNode;
        MessageDetailsXMLNode: DotNet XmlNode;
        SenderDetailsXMLNode: DotNet XmlNode;
        IDAuthenticationXMLNode: DotNet XmlNode;
        AuthenticationXMLNode: DotNet XmlNode;
        GovTalkDetailsXMLNode: DotNet XmlNode;
        KeysXMLNode: DotNet XmlNode;
        VATRegNoXMLNode: DotNet XmlNode;
        BranchNoXMLNode: DotNet XmlNode;
        PostCodeXMLNode: DotNet XmlNode;
        ChannelRoutingXMLNode: DotNet XmlNode;
        ChannelXMLNode: DotNet XmlNode;
        DummyXMLNode: DotNet XmlNode;
    begin
        if not GovTalkVATReportValidate.ValidateGovTalkPrerequisites(VATReportHeader) then
            exit(false);

        GovTalkSetup.FindFirst();
        CompanyInformation.Get();

        XmlDoc := XmlDoc.XmlDocument();

        if not GovTalkMessage.Get(VATReportHeader."VAT Report Config. Code", VATReportHeader."No.") then
            InitGovTalkMessage(GovTalkMessage, VATReportHeader);

        // QUCIK XML SCHEMA BREIF
        // GovTalkMessage
        // -EnvelopeVersion
        // -Header
        // --MessageDetails
        // ---Class
        // ---Qualifier
        // ---Function
        // ---CorrelationID
        // ---Transformation
        // --SenderDetails
        // ---IDAuthentication
        // ----SenderID
        // ----Authentication
        // -----Method
        // -----Value
        // -GovTalkDetails
        // --Keys
        // ---Key (Type=VATRegNo)
        // --ChannelRouting
        // ---Channel
        // ----URI (VendorID)
        // -Body
        XMLDOMManagement.AddRootElementWithPrefix(XmlDoc, 'GovTalkMessage', '', GovTalkNameSpaceTxt, GovTalkMessageXMLNode);
        XMLDOMManagement.AddElement(GovTalkMessageXMLNode, 'EnvelopeVersion', '2.0', GovTalkNameSpaceTxt, DummyXMLNode);
        XMLDOMManagement.AddElement(GovTalkMessageXMLNode, 'Header', '', GovTalkNameSpaceTxt, HeaderXMLNode);
        XMLDOMManagement.AddElement(GovTalkMessageXMLNode, 'GovTalkDetails', '', GovTalkNameSpaceTxt, GovTalkDetailsXMLNode);
        XMLDOMManagement.AddElement(GovTalkMessageXMLNode, 'Body', '', GovTalkNameSpaceTxt, BodyXMLNode);

        XMLDOMManagement.AddElement(HeaderXMLNode, 'MessageDetails', '', GovTalkNameSpaceTxt, MessageDetailsXMLNode);

        if GovTalkSetup."Test Mode" then
            XMLDOMManagement.AddElement(MessageDetailsXMLNode, 'Class',
              StrSubstNo(MessageClassTxt, GovTalkMessage."Message Class"), GovTalkNameSpaceTxt, DummyXMLNode)
        else
            XMLDOMManagement.AddElement(MessageDetailsXMLNode, 'Class', GovTalkMessage."Message Class", GovTalkNameSpaceTxt, DummyXMLNode);
        XMLDOMManagement.AddElement(MessageDetailsXMLNode, 'Qualifier', Qualifier, GovTalkNameSpaceTxt, DummyXMLNode);
        XMLDOMManagement.AddElement(MessageDetailsXMLNode, 'Function', Fn, GovTalkNameSpaceTxt, DummyXMLNode);
        XMLDOMManagement.AddElement(MessageDetailsXMLNode, 'CorrelationID', VATReportHeader."Message Id", GovTalkNameSpaceTxt, DummyXMLNode);
        XMLDOMManagement.AddElement(MessageDetailsXMLNode, 'Transformation', 'XML', GovTalkNameSpaceTxt, DummyXMLNode);

        if IncludeSenderDetails then begin
            XMLDOMManagement.AddElement(HeaderXMLNode, 'SenderDetails', '', GovTalkNameSpaceTxt, SenderDetailsXMLNode);
            XMLDOMManagement.AddElement(SenderDetailsXMLNode, 'IDAuthentication', '', GovTalkNameSpaceTxt, IDAuthenticationXMLNode);
            XMLDOMManagement.AddElement(IDAuthenticationXMLNode, 'SenderID', GovTalkSetup.Username, GovTalkNameSpaceTxt, DummyXMLNode);
            XMLDOMManagement.AddElement(IDAuthenticationXMLNode, 'Authentication', '', GovTalkNameSpaceTxt, AuthenticationXMLNode);
            XMLDOMManagement.AddElement(AuthenticationXMLNode, 'Method', 'clear', GovTalkNameSpaceTxt, DummyXMLNode);
            XMLDOMManagement.AddElement(AuthenticationXMLNode, 'Value', GovTalkSetup.GetPassword(), GovTalkNameSpaceTxt, DummyXMLNode);
        end;

        XMLDOMManagement.AddElement(GovTalkDetailsXMLNode, 'Keys', '', GovTalkNameSpaceTxt, KeysXMLNode);
        if IncludeSenderDetails then begin
            // EC Sales List specifics
            if VATReportHeader."VAT Report Config. Code" = VATReportHeader."VAT Report Config. Code"::"EC Sales List" then begin
                XMLDOMManagement.AddElement(KeysXMLNode, 'Key', CompanyInformation."Branch Number GB", GovTalkNameSpaceTxt, BranchNoXMLNode);
                XMLDOMManagement.AddAttribute(BranchNoXMLNode, 'Type', 'BranchNo');
                XMLDOMManagement.AddElement(KeysXMLNode, 'Key', DelChr(CompanyInformation."Post Code", '=', '- '), GovTalkNameSpaceTxt, PostCodeXMLNode);
                XMLDOMManagement.AddAttribute(PostCodeXMLNode, 'Type', 'Postcode');
            end;
            XMLDOMManagement.AddElement(KeysXMLNode, 'Key',
              FormatVATRegNo(CompanyInformation."Country/Region Code", CompanyInformation."VAT Registration No."),
              GovTalkNameSpaceTxt, VATRegNoXMLNode);
            XMLDOMManagement.AddAttribute(VATRegNoXMLNode, 'Type', 'VATRegNo');
        end;
        XMLDOMManagement.AddElement(GovTalkDetailsXMLNode, 'ChannelRouting', '', GovTalkNameSpaceTxt, ChannelRoutingXMLNode);
        XMLDOMManagement.AddElement(ChannelRoutingXMLNode, 'Channel', '', GovTalkNameSpaceTxt, ChannelXMLNode);
        XMLDOMManagement.AddElement(ChannelXMLNode, 'URI', GovTalkSetup.GetVendorID(), GovTalkNameSpaceTxt, DummyXMLNode);

        exit(true);
    end;

    [Scope('OnPrem')]
    procedure CreateGovTalkPollMessage(var GovTalkMessageXMLNode: DotNet XmlNode; VATReportHeader: Record "VAT Report Header")
    var
        DummyXMLNode: DotNet XmlNode;
    begin
        CreateBlankGovTalkXmlMessage(GovTalkMessageXMLNode, DummyXMLNode, VATReportHeader, 'poll', 'submit', false);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure CreateGovTalkDeleteMessage(var GovTalkMessageXMLNode: DotNet XmlNode; VATReportHeader: Record "VAT Report Header")
    var
        DummyXMLNode: DotNet XmlNode;
    begin
        CreateBlankGovTalkXmlMessage(GovTalkMessageXMLNode, DummyXMLNode, VATReportHeader, 'request', 'delete', false);
    end;

    [Scope('OnPrem')]
    procedure SendHttpRequest(var GovTalkMessageXMLNode: DotNet XmlNode; SubmitURL: Text; var SubmitResponseXMLNode: DotNet XmlNode): Boolean
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        XmlDoc: DotNet XmlDocument;
        HttpWebRequest: DotNet HttpWebRequest;
        HttpStatusCode: DotNet HttpStatusCode;
        ResponseHeaders: DotNet NameValueCollection;
        HttpWebResponse: DotNet HttpWebResponse;
        ResponseInStream: InStream;
    begin
        HttpWebRequest := HttpWebRequest.Create(SubmitURL);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.AllowAutoRedirect := true;
        HttpWebRequest.ContentType := 'text/xml';
        HttpWebRequest.Headers.Add('Accept-Encoding', 'utf-8');

        XmlDoc := GovTalkMessageXMLNode.ParentNode;

        HttpWebRequestMgt.CreateInstream(ResponseInStream);
        XmlDoc.Save(HttpWebRequest.GetRequestStream());
        if WebRequestHelper.GetWebResponse(HttpWebRequest, HttpWebResponse, ResponseInStream,
             HttpStatusCode, ResponseHeaders, true)
        then begin
            if HttpStatusCode.Equals(HttpStatusCode.OK) then begin
                XMLDOMManagement.LoadXMLNodeFromInStream(ResponseInStream, SubmitResponseXMLNode);
                exit(true);
            end;
            exit(false);
        end;
        exit(false);
    end;

    [Scope('OnPrem')]
    procedure ReadGatewayErrors(var VATReportHeader: Record "VAT Report Header"; SubmitResponseXMLNode: DotNet XmlNode)
    var
        GovTalkMessageParts: Record "GovTalk Msg. Parts";
        ErrorsXMLNode: DotNet XmlNode;
        CorrelationXMLNode: DotNet XmlNode;
        ChildNodes: DotNet XmlNodeList;
        BusinessErrorExists: Boolean;
        i: Integer;
    begin
        if
           XMLDOMManagement.FindNodeWithNamespace(SubmitResponseXMLNode, '//x:GovTalkErrors', 'x', GovTalkNameSpaceTxt, ErrorsXMLNode)
        then begin
            ChildNodes := ErrorsXMLNode.ChildNodes;
            for i := 0 to ChildNodes.Count - 1 do
                if LowerCase(
                     XMLDOMManagement.FindNodeTextWithNamespace(ChildNodes.Item(i), 'x:RaisedBy', 'x', GovTalkNameSpaceTxt)) = 'department'
                then
                    BusinessErrorExists := true
                else
                    LogErrorEntry(VATReportHeader, XMLDOMManagement.FindNodeTextWithNamespace(
                        ChildNodes.Item(i), 'x:Text', 'x', GovTalkNameSpaceTxt));
            if BusinessErrorExists then
                ReadBusinessErrors(VATReportHeader, SubmitResponseXMLNode);

            if VATReportHeader."VAT Report Config. Code" = VATReportHeader."VAT Report Config. Code"::"EC Sales List" then begin
                if not XMLDOMManagement.FindNodeWithNamespace(
                     SubmitResponseXMLNode, '//x:CorrelationID', 'x', GovTalkNameSpaceTxt, CorrelationXMLNode)
                then
                    Error('');
                SetPartStatus(CorrelationXMLNode.InnerText, GovTalkMessageParts.Status::Rejected);
                UpdateVATReportStatus(VATReportHeader);
            end else begin
                VATReportHeader.Validate(Status, VATReportHeader.Status::Rejected);
                VATReportHeader.Modify(true);
            end;
        end;
    end;

    local procedure ReadBusinessErrors(VATReportHeader: Record "VAT Report Header"; SubmitResponseXMLNode: DotNet XmlNode)
    var
        ErrorsXMLNode: DotNet XmlNode;
        ChildNodes: DotNet XmlNodeList;
        i: Integer;
    begin
        if XMLDOMManagement.FindNodeWithNamespace(SubmitResponseXMLNode, '//x:ErrorResponse', 'x', ErrorResponseNameSpaceTxt, ErrorsXMLNode) then begin
            XMLDOMManagement.FindNodesWithNamespace(ErrorsXMLNode, 'x:Error', 'x', ErrorResponseNameSpaceTxt, ChildNodes);
            for i := 0 to ChildNodes.Count - 1 do
                LogErrorEntry(VATReportHeader, XMLDOMManagement.FindNodeTextWithNamespace(
                    ChildNodes.Item(i), 'x:Text', 'x', ErrorResponseNameSpaceTxt));
            ReadECSLDeclarationResponse(VATReportHeader, ErrorsXMLNode);
        end;
    end;

    local procedure LogErrorEntry(VATReportHeader: Record "VAT Report Header"; ErrorText: Text)
    var
        ErrorMessageLog: Record "Error Message";
    begin
        ErrorMessageLog.LockTable();
        ErrorMessageLog.SetContext(VATReportHeader);
        ErrorMessageLog.LogMessage(VATReportHeader, VATReportHeader.FieldNo("No."), ErrorMessageLog."Message Type"::Error, ErrorText);
    end;

    local procedure LogNotificationEntry(VATReportHeader: Record "VAT Report Header"; NotificationText: Text)
    var
        ErrorMessageLog: Record "Error Message";
    begin
        ErrorMessageLog.LockTable();
        ErrorMessageLog.SetContext(VATReportHeader);
        ErrorMessageLog.LogMessage(VATReportHeader,
          VATReportHeader.FieldNo("No."), ErrorMessageLog."Message Type"::Information, NotificationText);
    end;

    [Scope('OnPrem')]
    procedure ReadSuccessResponse(var VATReportHeader: Record "VAT Report Header"; SubmitResponseXMLNode: DotNet XmlNode)
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
        SuccessResponseXMLNode: DotNet XmlNode;
        CorrelationXMLNode: DotNet XmlNode;
    begin
        if XMLDOMManagement.FindNodeWithNamespace(
             SubmitResponseXMLNode, '//suc:SuccessResponse', 'suc', SuccessResponseNameSpaceTxt, SuccessResponseXMLNode)
        then begin
            ReadVATDeclarationResponse(VATReportHeader, SuccessResponseXMLNode);
            ReadECSLDeclarationResponse(VATReportHeader, SuccessResponseXMLNode);
            if VATReportHeader."VAT Report Config. Code" = VATReportHeader."VAT Report Config. Code"::"VAT Return" then begin
                VATReportHeader.Validate(Status, VATReportHeader.Status::Accepted);
                VATReportHeader.Modify(true);
            end else begin
                if not XMLDOMManagement.FindNodeWithNamespace(
                     SuccessResponseXMLNode, '//x:CorrelationID', 'x', GovTalkNameSpaceTxt, CorrelationXMLNode)
                then
                    Error('');
                SetPartStatus(CorrelationXMLNode.InnerText, VATReportHeader.Status::Accepted.AsInteger());
                UpdateVATReportStatus(VATReportHeader);
            end;
            if VATReportsConfiguration.Get(VATReportHeader."VAT Report Config. Code", VATReportHeader."VAT Report Version") then
                if VATReportsConfiguration."Response Handler Codeunit ID" <> 0 then
                    CODEUNIT.Run(VATReportsConfiguration."Response Handler Codeunit ID");
        end;
    end;

    local procedure ReadVATDeclarationResponse(VATReportHeader: Record "VAT Report Header"; SuccessResponseXMLNode: DotNet XmlNode)
    var
        PaymentNotificationXMLNode: DotNet XmlNode;
        InformationNotificationXMLNodes: DotNet XmlNodeList;
        i: Integer;
    begin
        if XMLDOMManagement.FindNodeWithNamespace(
             SuccessResponseXMLNode, '//x:PaymentNotification', 'x', VATDeclarationNameSpaceTxt, PaymentNotificationXMLNode)
        then
            LogNotificationEntry(VATReportHeader, XMLDOMManagement.FindNodeTextWithNamespace(
                PaymentNotificationXMLNode, 'x:Narrative', 'x', VATDeclarationNameSpaceTxt));
        XMLDOMManagement.FindNodesWithNamespace(SuccessResponseXMLNode,
          '//x:InformationNotification', 'x', VATDeclarationNameSpaceTxt, InformationNotificationXMLNodes);
        for i := 0 to InformationNotificationXMLNodes.Count - 1 do
            LogNotificationEntry(VATReportHeader, XMLDOMManagement.FindNodeTextWithNamespace(
                InformationNotificationXMLNodes.Item(i), 'x:Narrative', 'x', VATDeclarationNameSpaceTxt));
    end;

    local procedure ReadECSLDeclarationResponse(VATReportHeader: Record "VAT Report Header"; SuccessResponseXMLNode: DotNet XmlNode)
    var
        EuropeanSaleResponseXMLNodes: DotNet XmlNodeList;
        LineResponseXMLNode: DotNet XmlNode;
        LineStatusXMLNode: DotNet XmlNode;
        DummyXMLNode: DotNet XmlNode;
        i: Integer;
    begin
        if XMLDOMManagement.FindNodesWithNamespace(
                 SuccessResponseXMLNode, '//ns:EuropeanSaleResponse', 'ns', ECSLDeclarationNameSpaceTxt, EuropeanSaleResponseXMLNodes)
            then
            for i := 0 to EuropeanSaleResponseXMLNodes.Count - 1 do
                if XMLDOMManagement.FindNodeWithNamespace(EuropeanSaleResponseXMLNodes.Item(i),
                     'ns1:EuropeanSale', 'ns1', VATCoreNameSpaceTxt, LineResponseXMLNode) and
                   XMLDOMManagement.FindNodeWithNamespace(EuropeanSaleResponseXMLNodes.Item(i), 'ns1:Status', 'ns1', VATCoreNameSpaceTxt, LineStatusXMLNode)
                then
                    if XMLDOMManagement.FindNodeWithNamespace(LineStatusXMLNode, 'ns1:Acknowledged', 'ns1', VATCoreNameSpaceTxt, DummyXMLNode) then
                        LogNotificationEntry(VATReportHeader, StrSubstNo(
                            NotificationTxt,
                            XMLDOMManagement.FindNodeTextWithNamespace(LineResponseXMLNode, 'ns1:SubmittersReference', 'ns1', VATCoreNameSpaceTxt)))
                    else
                        LogErrorEntry(VATReportHeader, StrSubstNo(ErrorTxt,
                            XMLDOMManagement.FindNodeTextWithNamespace(LineResponseXMLNode, 'ns1:SubmittersReference', 'ns1', VATCoreNameSpaceTxt),
                            XMLDOMManagement.FindNodeTextWithNamespace(LineStatusXMLNode, 'ns1:Error', 'ns1', VATCoreNameSpaceTxt)));
    end;

    [Scope('OnPrem')]
    procedure SubmitGovTalkRequest(var VATReportHeader: Record "VAT Report Header"; GovTalkMessageXMLNode: DotNet XmlNode): Boolean
    var
        DummyGuid: Guid;
    begin
        GovTalkSetup.FindFirst();
        ArchiveXMLMessage(VATReportHeader, GovTalkMessageXMLNode, 0, DummyGuid);
        exit(ProcessGovTalkSubmission(VATReportHeader, GovTalkSetup.Endpoint, GovTalkMessageXMLNode, true, true, DummyGuid));
    end;

    [Scope('OnPrem')]
    procedure SubmitGovTalkCancelRequest(var VATReportHeader: Record "VAT Report Header")
    begin
        if SubmitGovTalkDeleteRequest(VATReportHeader, true) then begin
            VATReportHeader.Validate(Status, VATReportHeader.Status::Canceled);
            VATReportHeader.Modify(true);
        end;
    end;

    [Scope('OnPrem')]
    procedure RegisterGovTalkPolling(var VATReportHeader: Record "VAT Report Header"; XMLPartID: Guid)
    var
        JobQueueEntry: Record "Job Queue Entry";
        GovTalkMessage: Record "GovTalk Message";
    begin
        GovTalkMessage.Get(VATReportHeader."VAT Report Config. Code", VATReportHeader."No.");
        if GovTalkMessage."Polling Count" = 0 then begin
            VATReportHeader.Status := VATReportHeader.Status::Rejected;
            VATReportHeader.Modify();
            exit;
        end;
        GovTalkMessage."Polling Count" -= 1;
        GovTalkMessage.Modify();

        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := CODEUNIT::"HMRC GovTalk Msg. Scheduler";
        JobQueueEntry."Record ID to Process" := VATReportHeader.RecordId;
        JobQueueEntry."Parameter String" := Format(XMLPartID);
        JobQueueEntry."Rerun Delay (sec.)" := GovTalkMessage.PollInterval;
        JobQueueEntry."Maximum No. of Attempts to Run" := 100;
        JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime + (GovTalkMessage.PollInterval * 1000);
        CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue", JobQueueEntry);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure SubmitGovTalkDeleteRequest(var VATReportHeader: Record "VAT Report Header"; LogMessage: Boolean): Boolean
    var
        GovTalkMessage: Record "GovTalk Message";
        GovTalkMessageXMLNode: DotNet XmlNode;
        DummyGuid: Guid;
    begin
        if VATReportHeader."Message Id" = '' then
            exit(true);
        CreateGovTalkDeleteMessage(GovTalkMessageXMLNode, VATReportHeader);
        if GovTalkMessage.Get(VATReportHeader."VAT Report Config. Code", VATReportHeader."No.") then begin
            if GovTalkMessage.ResponseEndPoint = '' then
                exit(false);
            if LogMessage then
                ArchiveXMLMessage(VATReportHeader, GovTalkMessageXMLNode, 0, DummyGuid);
            if ProcessGovTalkSubmission(VATReportHeader, GovTalkMessage.ResponseEndPoint, GovTalkMessageXMLNode, LogMessage, false, DummyGuid) then begin
                VATReportHeader."Message Id" := '';
                VATReportHeader.Modify(true);
                exit(true);
            end;
        end;
        exit(false);
    end;

    [Scope('OnPrem')]
    procedure ArchiveXMLMessage(var VATReportHeader: Record "VAT Report Header"; GovTalkMessageXMLNode: DotNet XmlNode; MessageType: Option Submission,Response; XMLPartID: Guid)
    var
        VATReportArchive: Record "VAT Report Archive";
        TempBlob: Codeunit "Temp Blob";
        XmlDoc: DotNet XmlDocument;
        BlobOutStream: OutStream;
        MemoryStream: DotNet MemoryStream;
    begin
        XmlDoc := GovTalkMessageXMLNode.ParentNode;
        MemoryStream := MemoryStream.MemoryStream();
        XmlDoc.Save(MemoryStream);
        TempBlob.CreateOutStream(BlobOutStream);
        MemoryStream.WriteTo(BlobOutStream);
        MemoryStream.Close();
#if not CLEAN27
#pragma warning disable AL0432
        if MessageType = MessageType::Submission then
            VATReportArchive.ArchiveSubmissionMessage(
                VATReportHeader."VAT Report Config. Code".AsInteger(), VATReportHeader."No.", TempBlob, XMLPartID)
        else
            VATReportArchive.ArchiveResponseMessage(
                VATReportHeader."VAT Report Config. Code".AsInteger(), VATReportHeader."No.", TempBlob, XMLPartID);
#else
        if VATReportArchive.Get(VATReportHeader."VAT Report Config. Code".AsInteger(), VATReportHeader."No.", XMLPartID) then
            if MessageType = MessageType::Submission then begin
                VATReportArchive.SetXMLPartID(XMLPartID);
                VATReportArchive.ArchiveSubmissionMessage(
                    VATReportHeader."VAT Report Config. Code".AsInteger(), VATReportHeader."No.", TempBlob)
            end else
                VATReportArchive.ArchiveResponseMessage(
                    VATReportHeader."VAT Report Config. Code".AsInteger(), VATReportHeader."No.", TempBlob);
#pragma warning restore AL0432                    
#endif
    end;

    [Scope('OnPrem')]
    procedure ProcessGovTalkSubmission(var VATReportHeader: Record "VAT Report Header"; SubmissionEndPoint: Text; GovTalkMessageXMLNode: DotNet XmlNode; LogResponse: Boolean; FlushGateway: Boolean; XMlPartId: Guid): Boolean
    var
        GovTalkMessage: Record "GovTalk Message";
        SubmitResponseXMLNode: DotNet XmlNode;
        ResponseQualifierXMLNode: DotNet XmlNode;
        CorrelationIDXMLNode: DotNet XmlNode;
        ResponseEndPointXMLNode: DotNet XmlNode;
        PollIntervalAttribute: DotNet XmlAttribute;
        CorrelationXMLNode: DotNet XmlNode;
        PollInterval: Integer;
    begin
        if SendHttpRequest(GovTalkMessageXMLNode, SubmissionEndPoint, SubmitResponseXMLNode) then begin
            if LogResponse then
                ArchiveXMLMessage(VATReportHeader, SubmitResponseXMLNode, 1, XMlPartId);
            if XMLDOMManagement.FindNodeWithNamespace(
                 SubmitResponseXMLNode, '//x:CorrelationID', 'x', GovTalkNameSpaceTxt, CorrelationIDXMLNode)
            then
                PersistCorrelationID(VATReportHeader, XMlPartId, CorrelationIDXMLNode.InnerText);

            if XMLDOMManagement.FindNodeWithNamespace(
                 SubmitResponseXMLNode, '//x:ResponseEndPoint', 'x', GovTalkNameSpaceTxt, ResponseEndPointXMLNode)
            then begin
                XMLDOMManagement.FindAttribute(ResponseEndPointXMLNode, PollIntervalAttribute, 'PollInterval');
                Evaluate(PollInterval, PollIntervalAttribute.Value);
                if GovTalkMessage.Get(VATReportHeader."VAT Report Config. Code", VATReportHeader."No.") then begin
                    GovTalkMessage.Validate(ResponseEndPoint, ResponseEndPointXMLNode.InnerText);
                    GovTalkMessage.Validate(PollInterval, PollInterval);
                    GovTalkMessage.Modify();
                end;
            end;
            if XMLDOMManagement.FindNodeWithNamespace(
                 SubmitResponseXMLNode, '//x:Qualifier', 'x', GovTalkNameSpaceTxt, ResponseQualifierXMLNode)
            then
                if (ResponseQualifierXMLNode.InnerText = 'error') and
                   (FlushGateway = true)
                then begin
                    ReadGatewayErrors(VATReportHeader, SubmitResponseXMLNode);
                    SubmitGovTalkDeleteRequest(VATReportHeader, false);
                end else
                    if (ResponseQualifierXMLNode.InnerText = 'response') and
                       (FlushGateway = true)
                    then begin
                        ReadSuccessResponse(VATReportHeader, SubmitResponseXMLNode);
                        SubmitGovTalkDeleteRequest(VATReportHeader, false);
                    end else
                        if ResponseQualifierXMLNode.InnerText = 'acknowledgement' then begin
                            if VATReportHeader."VAT Report Config. Code" = VATReportHeader."VAT Report Config. Code"::"EC Sales List" then begin
                                if not XMLDOMManagement.FindNodeWithNamespace(
                                     SubmitResponseXMLNode, '//x:CorrelationID', 'x', GovTalkNameSpaceTxt, CorrelationXMLNode)
                                then
                                    Error('');
                                SetPartStatus(CorrelationXMLNode.InnerText, VATReportHeader.Status::Submitted.AsInteger());
                                UpdateVATReportStatus(VATReportHeader);
                            end else begin
                                VATReportHeader.Validate(Status, VATReportHeader.Status::Submitted);
                                VATReportHeader.Modify(true);
                            end;
                            RegisterGovTalkPolling(VATReportHeader, XMlPartId);
                        end;
            exit(true);
        end;
        exit(false);
    end;

    [Scope('OnPrem')]
    procedure InitGovTalkMessage(var GovTalkMessage: Record "GovTalk Message"; VATReportHeader: Record "VAT Report Header")
    begin
        GovTalkMessage.ReportConfigCode := VATReportHeader."VAT Report Config. Code".AsInteger();
        GovTalkMessage.ReportNo := VATReportHeader."No.";
        GovTalkMessage.PeriodID := GetPeriodID(VATReportHeader."End Date");
        GovTalkMessage.PeriodStart := VATReportHeader."Start Date";
        GovTalkMessage.PeriodEnd := VATReportHeader."End Date";
        GovTalkMessage."Polling Count" := 1000;
        if VATReportHeader."VAT Report Config. Code" = VATReportHeader."VAT Report Config. Code"::"VAT Return" then
            GovTalkMessage."Message Class" := VATDeclarationMessageClassTxt
        else
            GovTalkMessage."Message Class" := ECSLDeclarationMessageClassTxt;
        GovTalkMessage.Insert();
    end;

    local procedure GetPeriodID(PeriodEnd: Date): Code[10]
    begin
        exit(Format(PeriodEnd, 0, '<Year4>-<Month,2>'));
    end;

    [Scope('OnPrem')]
    procedure FormatVATRegNo(CountryCode: Code[10]; VATRegNo: Text): Text
    begin
        if StrPos(VATRegNo, CountryCode) = 1 then
            exit(DelStr(VATRegNo, 1, StrLen(CountryCode)));
        exit(VATRegNo);
    end;

    [Scope('OnPrem')]
    procedure SubmitECSLGovTalkRequest(var VATReportHeader: Record "VAT Report Header"; GovTalkMessageXMLNode: DotNet XmlNode; XMLPartID: Guid)
    begin
        GovTalkSetup.FindFirst();
        ArchiveXMLMessage(VATReportHeader, GovTalkMessageXMLNode, 0, XMLPartID);
        ProcessGovTalkSubmission(VATReportHeader, GovTalkSetup.Endpoint, GovTalkMessageXMLNode, true, true, XMLPartID)
    end;

    local procedure PersistCorrelationID(var VATReportHeader: Record "VAT Report Header"; XmlPartID: Guid; CorrelationID: Text[250])
    var
        GovTalkMessageParts: Record "GovTalk Msg. Parts";
    begin
        if VATReportHeader."VAT Report Config. Code" = VATReportHeader."VAT Report Config. Code"::"VAT Return" then begin
            VATReportHeader."Message Id" := CorrelationID;
            VATReportHeader.Modify();
            exit;
        end;

        if not GovTalkMessageParts.Get(XmlPartID) then
            Error(InvalidGovTalkMessagePartIDErr);

        GovTalkMessageParts.TestField("Report No.", VATReportHeader."No.");
        GovTalkMessageParts.TestField("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code"::"EC Sales List");

        GovTalkMessageParts."Correlation Id" := CorrelationID;
        GovTalkMessageParts.Modify();
    end;

    local procedure SetPartStatus(CorrelationId: Text; NewStatus: Option)
    var
        GovTalkMessageParts: Record "GovTalk Msg. Parts";
    begin
        GovTalkMessageParts.SetFilter("Correlation Id", CorrelationId);
        if not GovTalkMessageParts.FindFirst() then
            Error('');
        GovTalkMessageParts.Validate(Status, NewStatus);
        GovTalkMessageParts.Modify(true);
    end;

    local procedure UpdateVATReportStatus(var VATReportHeader: Record "VAT Report Header")
    var
        GovTalkMessageParts: Record "GovTalk Msg. Parts";
        PartsCount: Integer;
    begin
        GovTalkMessageParts.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        GovTalkMessageParts.SetRange("Report No.", VATReportHeader."No.");
        PartsCount := GovTalkMessageParts.Count();

        GovTalkMessageParts.SetFilter(Status, '<>%1', GovTalkMessageParts.Status::Released);
        if not (GovTalkMessageParts.Count = PartsCount) then
            exit;

        if ConditionalUpdateVATRepStatus(
             VATReportHeader, GovTalkMessageParts.Status::Submitted, VATReportHeader.Status::Submitted.AsInteger(), PartsCount)
        then
            exit;
        if ConditionalUpdateVATRepStatus(
             VATReportHeader, GovTalkMessageParts.Status::Accepted, VATReportHeader.Status::Accepted.AsInteger(), PartsCount)
        then
            exit;
        if ConditionalUpdateVATRepStatus(
             VATReportHeader, GovTalkMessageParts.Status::Rejected, VATReportHeader.Status::Rejected.AsInteger(), PartsCount)
        then
            exit;

        GovTalkMessageParts.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        GovTalkMessageParts.SetRange("Report No.", VATReportHeader."No.");
        GovTalkMessageParts.SetRange(Status, VATReportHeader.Status::Accepted);
        if GovTalkMessageParts.Count > 0 then begin
            VATReportHeader.Validate(Status, VATReportHeader.Status::"Part. Accepted");
            VATReportHeader.Modify(true);
            exit;
        end;
    end;

    local procedure ConditionalUpdateVATRepStatus(var VATReportHeader: Record "VAT Report Header"; ExpectedPartStatus: Option; UpdateToStatus: Option; TotalPartCount: Integer): Boolean
    var
        GovTalkMessageParts: Record "GovTalk Msg. Parts";
    begin
        GovTalkMessageParts.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        GovTalkMessageParts.SetRange("Report No.", VATReportHeader."No.");
        GovTalkMessageParts.SetRange(Status, ExpectedPartStatus);

        if GovTalkMessageParts.Count = TotalPartCount then begin
            VATReportHeader.Validate(Status, UpdateToStatus);
            VATReportHeader.Modify(true);
            exit(true);
        end;
        exit(false);
    end;

    [EventSubscriber(ObjectType::Page, Page::"VAT Report", 'OnAfterInitPageControllers', '', false, false)]
    local procedure OnAfterInitPageControllers(VATReportHeader: Record "VAT Report Header"; var SubmitControllerStatus: Boolean; var MarkAsSubmitControllerStatus: Boolean)
    var
        GovSetup: Record "Gov Talk Setup";
    begin
        if not IsGovTalk(VATReportHeader) then
            exit;

        if GovSetup.IsConfigured() then begin
            SubmitControllerStatus := VATReportHeader.Status = VATReportHeader.Status::Released;
            MarkAsSubmitControllerStatus := false;
        end else begin
            MarkAsSubmitControllerStatus := VATReportHeader.Status = VATReportHeader.Status::Released;
            SubmitControllerStatus := false;
        end;
    end;

    local procedure IsGovTalk(VATReportHeader: Record "VAT Report Header"): Boolean
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        if not VATReportsConfiguration.Get(VATReportHeader."VAT Report Config. Code", VATReportsConfiguration."VAT Report Version") then
            exit(false);

        exit(VATReportsConfiguration."Submission Codeunit ID" = CODEUNIT::"Submit VAT Declaration Req.")
    end;
}

