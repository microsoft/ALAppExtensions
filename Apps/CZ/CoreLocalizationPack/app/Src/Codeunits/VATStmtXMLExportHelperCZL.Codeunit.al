// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Environment.Configuration;
using System.Reflection;
using System.Text;
using System.Utilities;

codeunit 11787 "VAT Stmt XML Export Helper CZL"
{
    Permissions = tabledata "Object Options" = imd;

    var
        OptionPathTxt: Label '/ReportParameters/Options/Field[@name="%1"]', Comment = '%1=name attribute', Locked = true;
        XmlNodesNotFoundErr: Label 'The XML Nodes at %1 cannot be found in the XML Document %2.', Comment = '%1=NodePath, %2=XMLDocRoot.InnerXml';
        ParamFormatErr: Label 'Incorrect XML parameter format.';
        InvalidXmlParameterErr: Label 'Invalid Xml Parameter.';
        LastUsedTxt: Label 'Last used options and filters', Comment = 'Translation must match RequestPageLatestSavedSettingsName from Lang.resx';
        ReportParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="%2" id="%1"><Options>%3</Options></ReportParameters>', Comment = '%1=ReportID, %2=ReportName, %2=Fields declaration', Locked = true;
        ExportVATStmtDialogPKFieldsTxt: Label '<Field name="%1"></Field><Field name="%2"></Field>', Comment = '%1=VATStatementTemplateNameTok, %2=VATStatementNameTok', Locked = true;
        ExportVATCtrlDialogPKFieldsTxt: Label '<Field name="%1"></Field>', Comment = '%1=VATControlReportNoTok', Locked = true;
        VATStatementTemplateNameTok: Label 'VATStatementTemplateName', Locked = true;
        VATStatementNameTok: Label 'VATStatementName', Locked = true;
        StartDateTok: Label 'StartDate', Locked = true;
        EndDateTok: Label 'EndDate', Locked = true;
        MonthTok: Label 'Month', Locked = true;
        QuarterTok: Label 'Quarter', Locked = true;
        YearTok: Label 'Year', Locked = true;
        SelectionTok: Label 'Selection', Locked = true;
        PeriodSelectionTok: Label 'PeriodSelection', Locked = true;
        PrintInIntegersTok: Label 'PrintInIntegers', Locked = true;
        RoundingDirectionTok: Label 'RoundingDirection', Locked = true;
        DeclarationTypeTok: Label 'DeclarationType', Locked = true;
        FilledByEmployeeNoTok: Label 'FilledByEmployeeNo', Locked = true;
        ReasonsObservedOnTok: Label 'ReasonsObservedOn', Locked = true;
        NextYearVATPeriodCodeTok: Label 'NextYearVATPeriodCode', Locked = true;
        SettlementNoFilterTok: Label 'SettlementNoFilter', Locked = true;
        NoTaxTok: Label 'NoTax', Locked = true;
        UseAmtsInAddCurrTok: Label 'UseAmtsInAddCurr', Locked = true;
        VATControlReportNoTok: Label 'VATControlReportNo', Locked = true;
        FastAppelReactionTok: Label 'FastAppelReaction', Locked = true;
        AppelDocumentNoTok: Label 'AppelDocumentNo', Locked = true;

    procedure GetParametersXmlDoc(Parameters: Text; var ParametersXmlDoc: XmlDocument);
    var
        XMLDocRoot: XmlElement;
    begin
        if not XmlDocument.ReadFrom(Parameters, ParametersXmlDoc) then
            Error(ParamFormatErr);
        if not ParametersXmlDoc.GetRoot(XMLDocRoot) then
            Error(ParamFormatErr);
    end;

    procedure GetRequestPageOptionXmlElement(OptionName: Text; ParametersXmlDoc: XmlDocument): XmlElement
    var
        FoundXmlNodeList: XmlNodeList;
        FoundXmlNode: XmlNode;
    begin
        if not FindNodes(FoundXmlNodeList, ParametersXmlDoc, StrSubstNo(OptionPathTxt, OptionName)) then
            Error(InvalidXmlParameterErr);
        foreach FoundXmlNode in FoundXmlNodeList do
            if FoundXmlNode.IsXmlElement() then
                break;
        if not FoundXmlNode.IsXmlElement() then
            Error(InvalidXmlParameterErr);
        exit(FoundXmlNode.AsXmlElement());
    end;

    procedure GetRequestPageOptionValue(OptionName: Text; ParametersXmlDoc: XmlDocument): Text
    begin
        exit(GetRequestPageOptionXmlElement(OptionName, ParametersXmlDoc).InnerText());
    end;

    procedure SetRequestPageOptionValue(OptionName: Text; var ParametersXmlDoc: XmlDocument; NewValue: Text)
    var
        XmlElem: XmlElement;
        NewXmlElem: XmlElement;
    begin
        XmlElem := GetRequestPageOptionXmlElement(OptionName, ParametersXmlDoc);
        NewXmlElem := XmlElement.Create('Field', '', NewValue);
        NewXmlElem.SetAttribute('name', OptionName);
        XmlElem.ReplaceWith(NewXmlElem);
    end;

    procedure FindNodes(var FoundXmlNodeList: XmlNodeList; XmlDoc: XmlDocument; NodePath: Text): Boolean
    var
        XMLDocRoot: XmlElement;
    begin
        if not XmlDoc.GetRoot(XMLDocRoot) then
            exit(false);
        if not XMLDocRoot.SelectNodes(NodePath, FoundXmlNodeList) then
            Error(XmlNodesNotFoundErr, NodePath, XMLDocRoot.InnerXml());
        exit(true);
    end;

    procedure GetReportRequestPageParameters(ReportID: Integer) XMLTxt: Text
    var
        ObjectOptions: Record "Object Options";
        XMLTxtInStream: InStream;
    begin
        if ObjectOptions.Get(LastUsedTxt, ReportID, ObjectOptions."Object Type"::Report, UserId, CompanyName) then begin
            ObjectOptions.CalcFields("Option Data");
            ObjectOptions."Option Data".CreateInStream(XMLTxtInStream);
            XMLTxtInStream.ReadText(XMLTxt);
        end else
            XMLTxt := CreateReportRequestPageParameters(ReportID);
        exit(XMLTxt);
    end;

    local procedure CreateReportRequestPageParameters(ReportID: Integer): Text
    var
        AllObjWithCaption: Record AllObjWithCaption;
        FieldsDeclaration: Text;
    begin
        AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Report, ReportID);
        case ReportID of
            Report::"Export VAT Stmt. Dialog CZL":
                FieldsDeclaration := StrSubstNo(ExportVATStmtDialogPKFieldsTxt, VATStatementTemplateNameTok, VATStatementNameTok);
            Report::"Export VAT Ctrl. Dialog CZL":
                FieldsDeclaration := StrSubstNo(ExportVATCtrlDialogPKFieldsTxt, VATControlReportNoTok);
        end;
        exit(StrSubstNo(ReportParametersTxt, ReportID, AllObjWithCaption."Object Name", FieldsDeclaration));
    end;

    procedure UpdateParamsVATStatementName(var XMLTxt: Text; VATStatementName: Record "VAT Statement Name")
    var
        ParamsXmlDoc: XmlDocument;
    begin
        GetParametersXmlDoc(XMLTxt, ParamsXmlDoc);
        SetRequestPageOptionValue(VATStatementTemplateNameTok, ParamsXmlDoc, VATStatementName."Statement Template Name");
        SetRequestPageOptionValue(VATStatementNameTok, ParamsXmlDoc, VATStatementName.Name);
        ParamsXmlDoc.WriteTo(XMLTxt);
    end;

    procedure SaveReportRequestPageParameters(ReportID: Integer; XMLText: Text)
    var
        ObjectOptions: Record "Object Options";
        ReportOutStream: OutStream;
    begin
        if XMLText = '' then
            exit;

        if ObjectOptions.Get(LastUsedTxt, ReportID, ObjectOptions."Object Type"::Report, UserId, CompanyName) then
            ObjectOptions.Delete();
        ObjectOptions.Init();
        ObjectOptions."Parameter Name" := LastUsedTxt;
        ObjectOptions."Object Type" := ObjectOptions."Object Type"::Report;
        ObjectOptions."Object ID" := ReportID;
        ObjectOptions."User Name" := CopyStr(UserId, 1, MaxStrLen(ObjectOptions."User Name"));
        ObjectOptions."Company Name" := CopyStr(CompanyName, 1, MaxStrLen(ObjectOptions."Company Name"));
        ObjectOptions."Created By" := CopyStr(UserId, 1, MaxStrLen(ObjectOptions."Created By"));
        ObjectOptions."Option Data".CreateOutStream(ReportOutStream);
        ReportOutStream.WriteText(XMLText);
        ObjectOptions.Insert();
    end;

    procedure GetVATStatementName(var VATStatementTemplateName: Code[10]; var VATStatementName: Code[10]; ParamsXmlDoc: XmlDocument)
    begin
        Evaluate(VATStatementTemplateName, GetRequestPageOptionValue(VATStatementTemplateNameTok, ParamsXmlDoc), 9);
        Evaluate(VATStatementName, GetRequestPageOptionValue(VATStatementNameTok, ParamsXmlDoc), 9);
    end;

    procedure GetPeriod(var StartDate: Date; var EndDate: Date; var Month: Integer; var Quarter: Integer; var Year: Integer; ParamsXmlDoc: XmlDocument)
    begin
        Evaluate(StartDate, GetRequestPageOptionValue(StartDateTok, ParamsXmlDoc), 9);
        Evaluate(EndDate, GetRequestPageOptionValue(EndDateTok, ParamsXmlDoc), 9);
        Evaluate(Month, GetRequestPageOptionValue(MonthTok, ParamsXmlDoc), 9);
        Evaluate(Quarter, GetRequestPageOptionValue(QuarterTok, ParamsXmlDoc), 9);
        Evaluate(Year, GetRequestPageOptionValue(YearTok, ParamsXmlDoc), 9);
    end;

    procedure GetSelection(var Selection: Enum "VAT Statement Report Selection"; var PeriodSelection: Enum "VAT Statement Report Period Selection"; ParamsXmlDoc: XmlDocument)
    begin
        Evaluate(Selection, GetRequestPageOptionValue(SelectionTok, ParamsXmlDoc), 9);
        Evaluate(PeriodSelection, GetRequestPageOptionValue(PeriodSelectionTok, ParamsXmlDoc), 9);
    end;

    procedure GetRounding(var PrintInIntegers: Boolean; var RoundingDirection: Option Nearest,Down,Up; ParamsXmlDoc: XmlDocument)
    begin
        Evaluate(PrintInIntegers, GetRequestPageOptionValue(PrintInIntegersTok, ParamsXmlDoc), 9);
        Evaluate(RoundingDirection, GetRequestPageOptionValue(RoundingDirectionTok, ParamsXmlDoc), 9);
    end;

    procedure GetDeclarationAndFilledBy(var DeclarationType: Enum "VAT Stmt. Declaration Type CZL"; var FilledByEmployeeCode: Code[20]; ParamsXmlDoc: XmlDocument)
    begin
        Evaluate(DeclarationType, GetRequestPageOptionValue(DeclarationTypeTok, ParamsXmlDoc), 9);
        Evaluate(FilledByEmployeeCode, GetRequestPageOptionValue(FilledByEmployeeNoTok, ParamsXmlDoc), 9);
    end;

    procedure GetAdditionalParams(var ReasonsObservedOnDate: Date; var NextYearVATPeriodCode: Text; var SettlementNoFilter: Text[50]; var NoTaxBoolean: Boolean; var UseAmtsInAddCurr: Boolean; ParamsXmlDoc: XmlDocument)
    begin
        Evaluate(ReasonsObservedOnDate, GetRequestPageOptionValue(ReasonsObservedOnTok, ParamsXmlDoc), 9);
        Evaluate(NextYearVATPeriodCode, GetRequestPageOptionValue(NextYearVATPeriodCodeTok, ParamsXmlDoc), 9);
        Evaluate(SettlementNoFilter, GetRequestPageOptionValue(SettlementNoFilterTok, ParamsXmlDoc), 9);
        Evaluate(NoTaxBoolean, GetRequestPageOptionValue(NoTaxTok, ParamsXmlDoc), 9);
        Evaluate(UseAmtsInAddCurr, GetRequestPageOptionValue(UseAmtsInAddCurrTok, ParamsXmlDoc), 9);
    end;

    procedure EncodeAttachmentsToXML(var TempBlob: Codeunit "Temp Blob"; AttachmentXPath: Text; AttachmentNodeName: Text; VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL")
    var
        XMLDoc: XmlDocument;
        XMLDocInStream: InStream;
        XMLDocOutStream: OutStream;
        ReadOptions: XmlReadOptions;
        WriteOptions: XmlWriteOptions;
    begin
        TempBlob.CreateInStream(XMLDocInStream, TextEncoding::UTF8);
        ReadOptions.PreserveWhitespace := true;
        XMLDocument.ReadFrom(XMLDocInStream, ReadOptions, XMLDoc);
        if FillAttachmentsContent(XMLDoc, AttachmentXPath, AttachmentNodeName, VATStatementAttachmentCZL) then begin
            Clear(TempBlob);
            WriteOptions.PreserveWhitespace := true;
            TempBlob.CreateOutStream(XMLDocOutStream, TextEncoding::UTF8);
            XMLDoc.WriteTo(WriteOptions, XMLDocOutStream);
        end;
    end;

    local procedure FillAttachmentsContent(var XMLDocument: XmlDocument; AttachmentXPath: Text; AttachmentNodeName: Text; VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL") Result: Boolean
    var
        AttachmentTempBlob: Codeunit "Temp Blob";
        XMLRootNode: XmlElement;
        AttachmentNode: XmlNode;
        XMLNodes: XmlNodeList;
    begin
        XMLDocument.GetRoot(XMLRootNode);
        if XMLRootNode.SelectNodes(AttachmentXPath, XMLNodes) then
            foreach AttachmentNode in XMLNodes do begin
                VATStatementAttachmentCZL.SetRange("File Name", GetNodeAttributeValue(AttachmentNode, AttachmentNodeName));
                if VATStatementAttachmentCZL.FindFirst() then
                    if VATStatementAttachmentCZL.Attachment.HasValue() then begin
                        VATStatementAttachmentCZL.CalcFields(Attachment);
                        AttachmentTempBlob.FromRecord(VATStatementAttachmentCZL, VATStatementAttachmentCZL.FieldNo(Attachment));
                        if AddEncodedFile(AttachmentNode, AttachmentTempBlob) then
                            Result := true;
                    end;
            end;
    end;

    local procedure AddEncodedFile(var AttachmentNode: XmlNode; var AttachmentTempBlob: Codeunit "Temp Blob") Result: Boolean
    var
        Base64Convert: Codeunit "Base64 Convert";
        InStream: InStream;
        XmlCDataSection: XmlCData;
    begin
        AttachmentTempBlob.CreateInStream(InStream);
        XmlCDataSection := XmlCData.Create(Base64Convert.ToBase64(InStream, true));
        AttachmentNode.AsXmlElement().Add(XMLCDATASection);
        Result := true;
    end;

    local procedure GetNodeAttributeValue(var SourceNode: XmlNode; AttributeName: Text) AttributeValue: Text;
    var
        SourceElement: XmlElement;
        SourceAttribute: XmlAttribute;
        SourceAttributes: XmlAttributeCollection;
    begin
        SourceElement := SourceNode.AsXmlElement();
        SourceAttributes := SourceElement.Attributes();
        AttributeValue := '';
        foreach SourceAttribute in SourceAttributes do
            if SourceAttribute.Name() = AttributeName then
                AttributeValue := SourceAttribute.Value();
    end;

    procedure ConvertToFormType(DeclarationType: Enum "VAT Stmt. Declaration Type CZL"): Code[1]
    begin
        case DeclarationType of
            DeclarationType::Recapitulative:
                exit('B');
            DeclarationType::Corrective:
                exit('O');
            DeclarationType::Supplementary:
                exit('D');
            DeclarationType::"Supplementary/Corrective":
                exit('E');
        end;
    end;

    procedure ConvertToSectionCode(DeclarationType: Enum "VAT Stmt. Declaration Type CZL"): Code[1]
    begin
        case DeclarationType of
            DeclarationType::Recapitulative,
            DeclarationType::Corrective:
                exit('O');
            DeclarationType::Supplementary,
            DeclarationType::"Supplementary/Corrective":
                exit('D');
        end;
    end;

    procedure ConvertTaxPayerStatus(TaxPayerStatus: Option Payer,"Non-payer",Other,"VAT Group"): Code[1]
    begin
        case TaxPayerStatus of
            TaxPayerStatus::Payer:
                exit('P');
            TaxPayerStatus::"Non-payer",
            TaxPayerStatus::Other:
                exit('I');
            TaxPayerStatus::"VAT Group":
                exit('S');
        end;
    end;

    procedure ConvertBoolean(BooleanValue: Boolean): Code[1]
    begin
        if BooleanValue then
            exit('A');
        exit('N');
    end;

    procedure ConvertSubjectType(SubjectType: Option " ",Individual,Corporate): Code[1]
    begin
        case SubjectType of
            SubjectType::" ":
                exit('');
            SubjectType::Corporate:
                exit('P');
            SubjectType::Individual:
                exit('F');
        end;
    end;

    procedure UpdateParamsVATCtrlReportHeader(var XMLTxt: Text; VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL")
    var
        ParamsXmlDoc: XmlDocument;
    begin
        GetParametersXmlDoc(XMLTxt, ParamsXmlDoc);
        SetRequestPageOptionValue(VATControlReportNoTok, ParamsXmlDoc, VATCtrlReportHeaderCZL."No.");
        ParamsXmlDoc.WriteTo(XMLTxt);
    end;

    procedure GetVATCtrlReportNo(var VATControlReportNo: Code[20]; ParamsXmlDoc: XmlDocument)
    begin
        Evaluate(VATControlReportNo, GetRequestPageOptionValue(VATControlReportNoTok, ParamsXmlDoc), 9);
    end;

    procedure GetSelection(var Selection: Enum "VAT Statement Report Selection"; ParamsXmlDoc: XmlDocument)
    begin
        Evaluate(Selection, GetRequestPageOptionValue(SelectionTok, ParamsXmlDoc), 9);
    end;

    procedure GetRounding(var PrintInIntegers: Boolean; ParamsXmlDoc: XmlDocument)
    begin
        Evaluate(PrintInIntegers, GetRequestPageOptionValue(PrintInIntegersTok, ParamsXmlDoc), 9);
    end;


    procedure GetDeclarationAndFilledBy(var DeclarationType: Enum "VAT Ctrl. Report Decl Type CZL"; var FilledByEmployeeCode: Code[20]; ParamsXmlDoc: XmlDocument)
    begin
        Evaluate(DeclarationType, GetRequestPageOptionValue(DeclarationTypeTok, ParamsXmlDoc), 9);
        Evaluate(FilledByEmployeeCode, GetRequestPageOptionValue(FilledByEmployeeNoTok, ParamsXmlDoc), 9);
    end;

    procedure GetVATControlReportAddParams(var ReasonsObservedOnDate: Date; var FastAppelReaction: Option " ",B,P; var AppelDocumentNo: Text; ParamsXmlDoc: XmlDocument)
    var
        UseAmtsInAddCurr: Boolean;
    begin
        GetVATControlReportAddParams(ReasonsObservedOnDate, FastAppelReaction, AppelDocumentNo, UseAmtsInAddCurr, ParamsXmlDoc);
    end;

    procedure GetVATControlReportAddParams(var ReasonsObservedOnDate: Date; var FastAppelReaction: Option " ",B,P; var AppelDocumentNo: Text; var UseAmtsInAddCurr: Boolean; ParamsXmlDoc: XmlDocument)
    begin
        Evaluate(ReasonsObservedOnDate, GetRequestPageOptionValue(ReasonsObservedOnTok, ParamsXmlDoc), 9);
        Evaluate(FastAppelReaction, GetRequestPageOptionValue(FastAppelReactionTok, ParamsXmlDoc), 9);
        Evaluate(AppelDocumentNo, GetRequestPageOptionValue(AppelDocumentNoTok, ParamsXmlDoc), 9);
        Evaluate(UseAmtsInAddCurr, GetRequestPageOptionValue(UseAmtsInAddCurrTok, ParamsXmlDoc), 9);
    end;
}
