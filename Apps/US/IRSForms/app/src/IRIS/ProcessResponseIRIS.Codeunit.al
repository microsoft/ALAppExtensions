// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;
using System.Telemetry;

codeunit 10047 "Process Response IRIS"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        Helper: Codeunit "Helper IRIS";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        AckNamespaceUriTxt: Label 'urn:us:gov:treasury:irs:ir', Locked = true;
        AckNamespacePrefixTxt: Label 'n1', Locked = true;
        ParseSubmitTransmResponseEventTxt: Label 'ParseSubmitTransmissionResponse', Locked = true;
        ReceiptIDNotFoundErr: Label 'Receipt ID was not found in the response.';
        ReceiptIDEmptyErr: Label 'Empty Receipt ID was found in the response.';

    procedure GetReceiptID(ResponseContentBlob: Codeunit "Temp Blob"; var ReceiptID: Text[100]): Boolean
    var
        XmlDoc: XmlDocument;
        CurrXmlNode: XmlNode;
        ResponseText: Text;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        ReceiptID := '';

        ResponseText := Helper.WriteTempBlobToText(ResponseContentBlob);
        if ResponseText = '' then
            exit(false);

        XmlDocument.ReadFrom(ResponseText, XmlDoc);

        if not XmlDoc.SelectSingleNode('/IntakeA2AResponse/receiptId', CurrXmlNode) then begin
            CustomDimensions.Add('ResponseText', ResponseText);
            FeatureTelemetry.LogError('0000PAL', Helper.GetIRISFeatureName(), ParseSubmitTransmResponseEventTxt, ReceiptIDNotFoundErr, GetLastErrorCallStack(), CustomDimensions);
            exit(false);
        end;

        ReceiptID := CopyStr(CurrXmlNode.AsXmlElement().InnerText(), 1, MaxStrLen(ReceiptID));
        if ReceiptID = '' then begin
            CustomDimensions.Add('ResponseText', ResponseText);
            FeatureTelemetry.LogError('0000PAL', Helper.GetIRISFeatureName(), ParseSubmitTransmResponseEventTxt, ReceiptIDEmptyErr, GetLastErrorCallStack(), CustomDimensions);
            exit(false);
        end;

        exit(true);
    end;

    procedure ParseGetStatusXmlResponse(AcknowledgContentBlob: Codeunit "Temp Blob"; var UniqueTransmissionId: Text[100]; var TransmissionStatus: Text): Boolean
    var
        TempDummyErrorInfo: Record "Error Information IRIS" temporary;
        XmlDoc: XmlDocument;
        NamespaceManager: XmlNamespaceManager;
        CurrXmlNode: XmlNode;
        AckText: Text;
        XPath: Text;
    begin
        Clear(TransmissionStatus);

        AckText := Helper.WriteTempBlobToText(AcknowledgContentBlob);
        if AckText = '' then
            exit(false);

        XmlDocument.ReadFrom(AckText, XmlDoc);

        NamespaceManager.NameTable(XmlDoc.NameTable());
        NamespaceManager.AddNamespace(AckNamespacePrefixTxt, AckNamespaceUriTxt);

        XPath := Helper.AddPrefixToXPath('//ResultGrp/TransmissionResultGrp', AckNamespacePrefixTxt);
        if XmlDoc.SelectSingleNode(XPath, NamespaceManager, CurrXmlNode) then
            ParseTransmissionResultGroup(CurrXmlNode, NamespaceManager, UniqueTransmissionId, TransmissionStatus, TempDummyErrorInfo);

        exit(TransmissionStatus <> '');
    end;

    procedure ParseAcknowledgementXmlResponse(AcknowledgContentBlob: Codeunit "Temp Blob"; var UniqueTransmissionId: Text[100]; var TransmissionStatus: Text; var SubmissionsStatus: Dictionary of [Text, Text]; var TempErrorInfo: Record "Error Information IRIS" temporary): Boolean
    var
        XmlDoc: XmlDocument;
        NamespaceManager: XmlNamespaceManager;
        CurrXmlNode: XmlNode;
        CurrNodeList: XmlNodeList;
        AckText: Text;
        XPath: Text;
    begin
        TempErrorInfo.Reset();
        TempErrorInfo.DeleteAll();

        AckText := Helper.WriteTempBlobToText(AcknowledgContentBlob);
        if AckText = '' then
            exit(false);

        XmlDocument.ReadFrom(AckText, XmlDoc);

        NamespaceManager.NameTable(XmlDoc.NameTable());
        NamespaceManager.AddNamespace(AckNamespacePrefixTxt, AckNamespaceUriTxt);

        // Transmission status and errors
        XPath := Helper.AddPrefixToXPath('//ResultGrp/TransmissionResultGrp', AckNamespacePrefixTxt);
        if XmlDoc.SelectSingleNode(XPath, NamespaceManager, CurrXmlNode) then
            ParseTransmissionResultGroup(CurrXmlNode, NamespaceManager, UniqueTransmissionId, TransmissionStatus, TempErrorInfo);

        // Submissions statuses and errors
        XPath := Helper.AddPrefixToXPath('//ResultGrp/SubmissionResultGrp', AckNamespacePrefixTxt);
        if XmlDoc.SelectNodes(XPath, NamespaceManager, CurrNodeList) then begin
            Clear(SubmissionsStatus);
            foreach CurrXmlNode in CurrNodeList do
                ParseSubmissionResultGroup(CurrXmlNode, NamespaceManager, SubmissionsStatus, TempErrorInfo);
        end;

        exit(TransmissionStatus <> '');
    end;

    local procedure ParseTransmissionResultGroup(TransmResultGrpNode: XmlNode; NamespaceManager: XmlNamespaceManager; var UniqueTransmissionId: Text[100]; var TransmissionStatus: Text; var TempErrorInfo: Record "Error Information IRIS" temporary)
    var
        CurrXmlNode: XmlNode;
        CurrNodeList: XmlNodeList;
        XPath: Text;
        ErrorCode: Text;
        ErrorMessage: Text;
        ErrorValue: Text;
        XmlElementPath: Text;
    begin
        Clear(UniqueTransmissionId);
        Clear(TransmissionStatus);

        if TransmResultGrpNode.AsXmlElement().IsEmpty() then
            exit;

        // UTID
        XPath := Helper.AddPrefixToXPath('UniqueTransmissionId', AckNamespacePrefixTxt);
        if TransmResultGrpNode.SelectSingleNode(XPath, NamespaceManager, CurrXmlNode) then
            UniqueTransmissionId := CopyStr(CurrXmlNode.AsXmlElement().InnerText(), 1, MaxStrLen(UniqueTransmissionId));

        // Transmission Status
        XPath := Helper.AddPrefixToXPath('TransmissionStatusCd', AckNamespacePrefixTxt);
        if TransmResultGrpNode.SelectSingleNode(XPath, NamespaceManager, CurrXmlNode) then
            TransmissionStatus := CurrXmlNode.AsXmlElement().InnerText();

        // Transmission Errors
        XPath := Helper.AddPrefixToXPath('ErrorInformationGrp', AckNamespacePrefixTxt);
        if TransmResultGrpNode.SelectNodes(XPath, NamespaceManager, CurrNodeList) then
            foreach CurrXmlNode in CurrNodeList do
                if ParseErrorInfoGroup(CurrXmlNode, NamespaceManager, ErrorCode, ErrorMessage, ErrorValue, XmlElementPath) then
                    CreateErrorInfoTempRec(TempErrorInfo, Enum::"Entity Type IRIS"::Transmission, '', '', ErrorCode, ErrorMessage, ErrorValue, XmlElementPath);
    end;

    local procedure ParseSubmissionResultGroup(SubmissionResultGrpNode: XmlNode; NamespaceManager: XmlNamespaceManager; var SubmissionsStatus: Dictionary of [Text, Text]; var TempErrorInfo: Record "Error Information IRIS" temporary)
    var
        CurrXmlNode: XmlNode;
        CurrNodeList: XmlNodeList;
        SubmissionId: Text[20];
        XPath: Text;
        ErrorCode: Text;
        ErrorMessage: Text;
        ErrorValue: Text;
        XmlElementPath: Text;
    begin
        if SubmissionResultGrpNode.AsXmlElement().IsEmpty() then
            exit;

        // Submission Id
        XPath := Helper.AddPrefixToXPath('SubmissionId', AckNamespacePrefixTxt);
        if SubmissionResultGrpNode.SelectSingleNode(XPath, NamespaceManager, CurrXmlNode) then
            SubmissionId := CopyStr(CurrXmlNode.AsXmlElement().InnerText(), 1, MaxStrLen(SubmissionId));

        // Submission Status
        XPath := Helper.AddPrefixToXPath('SubmissionStatusCd', AckNamespacePrefixTxt);
        if SubmissionResultGrpNode.SelectSingleNode(XPath, NamespaceManager, CurrXmlNode) then
            SubmissionsStatus.Add(SubmissionId, CurrXmlNode.AsXmlElement().InnerText());

        // Submission Errors
        XPath := Helper.AddPrefixToXPath('ErrorInformationGrp', AckNamespacePrefixTxt);
        if SubmissionResultGrpNode.SelectNodes(XPath, NamespaceManager, CurrNodeList) then
            foreach CurrXmlNode in CurrNodeList do
                if ParseErrorInfoGroup(CurrXmlNode, NamespaceManager, ErrorCode, ErrorMessage, ErrorValue, XmlElementPath) then
                    CreateErrorInfoTempRec(TempErrorInfo, Enum::"Entity Type IRIS"::Submission, SubmissionId, '', ErrorCode, ErrorMessage, ErrorValue, XmlElementPath);

        // Records errors
        XPath := Helper.AddPrefixToXPath('RecordResultGrp', AckNamespacePrefixTxt);
        if SubmissionResultGrpNode.SelectNodes(XPath, NamespaceManager, CurrNodeList) then
            foreach CurrXmlNode in CurrNodeList do
                ParseRecordResultGroup(CurrXmlNode, NamespaceManager, SubmissionId, TempErrorInfo);
    end;

    local procedure ParseRecordResultGroup(RecordResultGrpNode: XmlNode; NamespaceManager: XmlNamespaceManager; SubmissionId: Text[20]; var TempErrorInfo: Record "Error Information IRIS" temporary)
    var
        CurrXmlNode: XmlNode;
        CurrNodeList: XmlNodeList;
        RecordIdValue: Text[20];
        XPath: Text;
        ErrorCode: Text;
        ErrorMessage: Text;
        ErrorValue: Text;
        XmlElementPath: Text;
    begin
        if RecordResultGrpNode.AsXmlElement().IsEmpty() then
            exit;

        // Record Id
        XPath := Helper.AddPrefixToXPath('RecordId', AckNamespacePrefixTxt);
        if RecordResultGrpNode.SelectSingleNode(XPath, NamespaceManager, CurrXmlNode) then
            RecordIdValue := CopyStr(CurrXmlNode.AsXmlElement().InnerText(), 1, MaxStrLen(RecordIdValue));

        // Record Errors
        XPath := Helper.AddPrefixToXPath('ErrorInformationGrp', AckNamespacePrefixTxt);
        if RecordResultGrpNode.SelectNodes(XPath, NamespaceManager, CurrNodeList) then
            foreach CurrXmlNode in CurrNodeList do
                if ParseErrorInfoGroup(CurrXmlNode, NamespaceManager, ErrorCode, ErrorMessage, ErrorValue, XmlElementPath) then
                    CreateErrorInfoTempRec(TempErrorInfo, Enum::"Entity Type IRIS"::RecordType, SubmissionId, RecordIdValue, ErrorCode, ErrorMessage, ErrorValue, XmlElementPath);
    end;

    local procedure ParseErrorInfoGroup(ErrorInfoGrpNode: XmlNode; NamespaceManager: XmlNamespaceManager; var ErrorCode: Text; var ErrorMessage: Text; var ErrorValue: Text; var XmlElementPath: Text): Boolean
    var
        CurrXmlNode: XmlNode;
        XPath: Text;
    begin
        Clear(ErrorCode);
        Clear(ErrorMessage);
        Clear(ErrorValue);
        Clear(XmlElementPath);

        if ErrorInfoGrpNode.AsXmlElement().IsEmpty() then
            exit(false);

        // Error Code
        XPath := Helper.AddPrefixToXPath('ErrorMessageCd', AckNamespacePrefixTxt);
        if ErrorInfoGrpNode.SelectSingleNode(XPath, NamespaceManager, CurrXmlNode) then
            ErrorCode := CurrXmlNode.AsXmlElement().InnerText();

        // Error Message
        XPath := Helper.AddPrefixToXPath('ErrorMessageTxt', AckNamespacePrefixTxt);
        if ErrorInfoGrpNode.SelectSingleNode(XPath, NamespaceManager, CurrXmlNode) then
            ErrorMessage := CurrXmlNode.AsXmlElement().InnerText();

        // Error Value
        XPath := Helper.AddPrefixToXPath('ErrorValueTxt', AckNamespacePrefixTxt);
        if ErrorInfoGrpNode.SelectSingleNode(XPath, NamespaceManager, CurrXmlNode) then
            ErrorValue := CurrXmlNode.AsXmlElement().InnerText();

        // Xml Element Path
        XPath := Helper.AddPrefixToXPath('ElementPathTxt', AckNamespacePrefixTxt);
        if ErrorInfoGrpNode.SelectSingleNode(XPath, NamespaceManager, CurrXmlNode) then
            XmlElementPath := CurrXmlNode.AsXmlElement().InnerText();

        exit(ErrorMessage <> '');
    end;

    local procedure CreateErrorInfoTempRec(var TempErrorInfo: Record "Error Information IRIS" temporary; EntityType: Enum "Entity Type IRIS"; SubmissionId: Text[20]; RecordIdValue: Text[20]; ErrorCode: Text; ErrorMessage: Text; ErrorValue: Text; XmlElementPath: Text)
    begin
        TempErrorInfo.InitRecord();
        TempErrorInfo."Entity Type" := EntityType;
        TempErrorInfo."Submission ID" := SubmissionId;
        TempErrorInfo."Record ID" := RecordIdValue;
        TempErrorInfo."Error Code" := CopyStr(ErrorCode, 1, MaxStrLen(TempErrorInfo."Error Code"));
        TempErrorInfo."Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen(TempErrorInfo."Error Message"));
        TempErrorInfo."Error Value" := CopyStr(ErrorValue, 1, MaxStrLen(TempErrorInfo."Error Value"));
        TempErrorInfo."Xml Element Path" := CopyStr(XmlElementPath, 1, MaxStrLen(TempErrorInfo."Xml Element Path"));
        TempErrorInfo.Insert(true);
    end;
}