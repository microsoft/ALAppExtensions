// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using Microsoft.Finance.VAT.Reporting;
using System.IO;
using System.Utilities;

codeunit 10890 "Local Service Declaration Mgt."
{
    var
        ServDeclDataExchCodeLbl: Label 'SERVDECLFR-2022', Locked = true;
        DataExchangeXMLTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root>  <DataExchDef Code="SERVDECLFR-2022" Name="Service declaration" Type="5" ExternalDataHandlingCodeunit="10892" FileType="0" ReadingWritingCodeunit="1283">    <DataExchLineDef LineType="1" Code="HEADER" ColumnCount="0">      <DataExchColumnDef ColumnNo="1" Name="RootElement" Show="false" DataType="0" Path="/fichier_des" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" />      <DataExchColumnDef ColumnNo="2" Name="DeclNumber" Show="false" DataType="0" Path="/fichier_des/num_des" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" />      <DataExchColumnDef ColumnNo="3" Name="Month" Show="false" DataType="0" Path="/fichier_des/an_des" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" />      <DataExchColumnDef ColumnNo="4" Name="Year" Show="false" DataType="0" Path="/fichier_des/mois_des" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" />      <DataExchMapping TableId="5023" Name="" MappingCodeunit="1269">        <DataExchFieldMapping ColumnNo="2" FieldID="1" />        <DataExchFieldMapping ColumnNo="3" FieldID="51" TransformationRule="MONTHFROMDATE">          <TransformationRules>            <Code>MONTHFROMDATE</Code>            <Description>Month from date</Description>            <TransformationType>15</TransformationType>            <FindValue />            <ReplaceValue />            <StartPosition>0</StartPosition>            <Length>0</Length>            <DataFormat />            <DataFormattingCulture />            <NextTransformationRule />            <TableID>0</TableID>            <SourceFieldID>0</SourceFieldID>            <TargetFieldID>0</TargetFieldID>            <FieldLookupRule>0</FieldLookupRule>            <Precision>0.00</Precision>            <Direction />            <ExportFromDateType>2</ExportFromDateType>          </TransformationRules>        </DataExchFieldMapping>        <DataExchFieldMapping ColumnNo="4" FieldID="51" TransformationRule="YEARFROMDATE">          <TransformationRules>            <Code>YEARFROMDATE</Code>            <Description>Year from date</Description>            <TransformationType>15</TransformationType>            <FindValue />            <ReplaceValue />            <StartPosition>0</StartPosition>            <Length>0</Length>            <DataFormat />            <DataFormattingCulture />            <NextTransformationRule />            <TableID>0</TableID>            <SourceFieldID>0</SourceFieldID>            <TargetFieldID>0</TargetFieldID>            <FieldLookupRule>0</FieldLookupRule>            <Precision>0.00</Precision>            <Direction />            <ExportFromDateType>3</ExportFromDateType>          </TransformationRules>        </DataExchFieldMapping>      </DataExchMapping>    </DataExchLineDef>    <DataExchLineDef LineType="1" Code="HEADERCOMPANY" ColumnCount="0" DataLineTag="/fichier_des">      <DataExchColumnDef ColumnNo="1" Name="CompanyVATRegNo" Show="false" DataType="0" Path="/num_tvaFr" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" />      <DataExchMapping TableId="79" Name="" MappingCodeunit="1269">        <DataExchFieldMapping ColumnNo="1" FieldID="19" />      </DataExchMapping>    </DataExchLineDef>    <DataExchLineDef LineType="0" Code="LINE" ColumnCount="0" DataLineTag="/fichier_des">      <DataExchColumnDef ColumnNo="1" Name="LineRoot" Show="false" DataType="0" Path="/ligne_des" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" />      <DataExchColumnDef ColumnNo="2" Name="LineNo" Show="true" DataType="0" Description="numlin_des" Path="/ligne_des/numlin_des" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" />      <DataExchColumnDef ColumnNo="3" Name="VATRegNo" Show="true" DataType="0" Description="partner_des" Path="/ligne_des/partner_des" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" />      <DataExchColumnDef ColumnNo="4" Name="Amount" Show="true" DataType="2" Description="valeur" Path="/ligne_des/valeur" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="true" ExportIfNotBlank="true" />      <DataExchColumnDef ColumnNo="5" Name="Amount" Show="false" DataType="2" Description="valeur" Path="/ligne_des/valeur" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="true" ExportIfNotBlank="true" />      <DataExchMapping TableId="5024" Name="" MappingCodeunit="1269">        <DataExchFieldMapping ColumnNo="2" FieldID="2" />        <DataExchFieldMapping ColumnNo="3" FieldID="15" Optional="true" />        <DataExchFieldMapping ColumnNo="4" FieldID="10" Optional="true" />        <DataExchFieldMapping ColumnNo="5" FieldID="11" Optional="true" />      </DataExchMapping>    </DataExchLineDef>  </DataExchDef></root>', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service Declaration Mgt.", 'OnBeforeAssignExchDefToServDeclSetup', '', false, false)]
    local procedure OnBeforeAssignExchDefToServDeclSetup(var HandledDataExchDefCode: Code[20])
    begin
        InitSetup(HandledDataExchDefCode);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service Declaration Mgt.", 'OnBeforeCreateDefaultDataExchangeDef', '', false, false)]
    local procedure OnBeforeCreateDefaultDataExchangeDef(var IsHandled: Boolean);
    var
        ServDeclSetup: Record "Service Declaration Setup";
        HandledDataExchDefCode: Code[20];
    begin
        if not ServDeclSetup.Get() then
            ServDeclSetup.Insert();

        InitSetup(HandledDataExchDefCode);
        ServDeclSetup.Validate("Data Exch. Def. Code", HandledDataExchDefCode);
        ServDeclSetup.Modify();
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service Declaration Mgt.", 'OnAfterInitServDeclSetup', '', false, false)]
    local procedure OnAfterInitServDeclSetup(var ServDeclSetup: Record "Service Declaration Setup")
    begin
        ServDeclSetup."Enable VAT Registration No." := true;
        ServDeclSetup."Enable Serv. Trans. Types" := false;
        ServDeclSetup."Show Serv. Decl. Overview" := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service Declaration Mgt.", 'OnBeforeInsertVATReportsConfiguration', '', false, false)]
    local procedure OnBeforeInsertVATReportsConfiguration(var IsHandled: Boolean)
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
        ServDeclMgt: Codeunit "Service Declaration Mgt.";
    begin
        VATReportsConfiguration.Validate("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"Service Declaration");
        VATReportsConfiguration.Validate("VAT Report Version", ServDeclMgt.GetVATReportVersion());
        VATReportsConfiguration.Validate("Suggest Lines Codeunit ID", CODEUNIT::"Get Service Declaration Lines");
        VATReportsConfiguration.Validate("Submission Codeunit ID", CODEUNIT::"Local Export Serv. Decl.");
        if VATReportsConfiguration.Insert(true) then;
        IsHandled := true;
    end;

    local procedure InitSetup(var HandledDataExchDefCode: Code[20])
    var
        DataExchDef: Record "Data Exch. Def";
        TempBlob: Codeunit "Temp Blob";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
    begin
        HandledDataExchDefCode := ServDeclDataExchCodeLbl;
        if not DataExchDef.Get(HandledDataExchDefCode) then begin
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(DataExchangeXMLTxt);
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        end;
    end;
}
