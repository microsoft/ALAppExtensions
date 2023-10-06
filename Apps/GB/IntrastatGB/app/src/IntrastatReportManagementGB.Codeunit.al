// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using System.IO;
using System.Utilities;

codeunit 10501 "Intrastat Report Management GB"
{

    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeInitSetup', '', true, true)]
    local procedure OnBeforeInitSetup(var IntrastatReportSetup: Record "Intrastat Report Setup"; var IsHandled: Boolean)
    begin
        IsHandled := true;
        CreateDefaultDataExchangeDef();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeInitCheckList', '', true, true)]
    local procedure OnBeforeInitCheckList(var IsHandled: Boolean)
    var
        IntrastatReportChecklist: Record "Intrastat Report Checklist";
    begin
        IsHandled := true;

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 5);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 7);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 8);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 12);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 14);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 24);
        IntrastatReportChecklist.Validate("Filter Expression", 'Type: Shipment');
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 28);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 29);
        IntrastatReportChecklist.Validate("Filter Expression", 'Type: Shipment');
        IntrastatReportChecklist.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeExportIntrastatHeader', '', true, true)]
    local procedure OnBeforeExportIntrastatHeader(var IntrastatReportHeader: Record "Intrastat Report Header"; var IsHandled: Boolean)
    begin
        IntrastatReportHeader2 := IntrastatReportHeader;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeCreateDefaultDataExchangeDef', '', true, true)]
    local procedure OnBeforeCreateDefaultDataExchangeDef(var IsHandled: Boolean);
    begin
        CreateDefaultDataExchangeDef();
        IsHandled := true;
    end;

    internal procedure GetIntrastatHeader(): Record "Intrastat Report Header"
    begin
        exit(IntrastatReportHeader2);
    end;

    procedure CreateDefaultDataExchangeDef()
    var
        DataExchDef: Record "Data Exch. Def";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        TempBlob: Codeunit "Temp Blob";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
    begin
        if DataExchDef.Get('INTRA-2022-GB-RCPT') then
            DataExchDef.Delete(true);

        if DataExchDef.Get('INTRA-2022-GB-SHPT') then
            DataExchDef.Delete(true);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeRcptTxt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        Clear(TempBlob);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeShptTxt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        Clear(TempBlob);

        IntrastatReportSetup.Get();
        IntrastatReportSetup."Split Files" := true;
        IntrastatReportSetup."Zip Files" := false;
        IntrastatReportSetup."Data Exch. Def. Code - Receipt" := 'INTRA-2022-GB-RCPT';
        IntrastatReportSetup."Data Exch. Def. Code - Shpt." := 'INTRA-2022-GB-SHPT';
        IntrastatReportSetup.Modify();
    end;

    var
        IntrastatReportHeader2: Record "Intrastat Report Header";
        DataExchangeRcptTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-GB-RCPT" Name="Intrastat 2022 GB Receipt" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="10502" FileType="1" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DETAIL" Name="DETAIL" ColumnCount="8"><DataExchColumnDef ColumnNo="1" Name="Tariff No." Show="false" DataType="0" Length="20" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="Statistical Value" Show="false" DataType="2" DataFormat="&lt;Precision,0:0&gt;&lt;Standard Format,1&gt;" DataFormattingCulture="en-GB" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="Shpt. Method Code" Show="false" DataType="0" Length="10" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="Transaction Type" Show="false" DataType="0" Length="10" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="Total Weight" Show="false" DataType="2" DataFormat="&lt;Precision,0:0&gt;&lt;Standard Format,1&gt;" DataFormattingCulture="en-GB" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="Supplementary Quantity" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="true" /><DataExchColumnDef ColumnNo="7" Name="Country/Region Code" Show="false" DataType="0" Length="10" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="Document No." Show="false" DataType="0" Length="20" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchMapping TableId="4812" Name="" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="1" FieldID="5" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="2" FieldID="17" /><DataExchFieldMapping ColumnNo="3" FieldID="28" /><DataExchFieldMapping ColumnNo="4" FieldID="8" /><DataExchFieldMapping ColumnNo="5" FieldID="21" /><DataExchFieldMapping ColumnNo="6" FieldID="35" Optional="true" /><DataExchFieldMapping ColumnNo="7" FieldID="7" /><DataExchFieldMapping ColumnNo="8" FieldID="18" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                                Locked = true; // will be replaced with file import when available   
        DataExchangeShptTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-GB-SHPT" Name="Intrastat 2022 GB Shipment" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="10502" FileType="1" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DETAIL" Name="DETAIL" ColumnCount="10"><DataExchColumnDef ColumnNo="1" Name="Tariff No." Show="false" DataType="0" Length="20" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="Statistical Value" Show="false" DataType="2" DataFormat="&lt;Precision,0:0&gt;&lt;Standard Format,1&gt;" DataFormattingCulture="en-GB" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="Shpt. Method Code" Show="false" DataType="0" Length="10" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="Transaction Type" Show="false" DataType="0" Length="10" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="Total Weight" Show="false" DataType="2" DataFormat="&lt;Precision,0:0&gt;&lt;Standard Format,1&gt;" DataFormattingCulture="en-GB" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="Supplementary Quantity" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="true" /><DataExchColumnDef ColumnNo="7" Name="Country/Region Code" Show="false" DataType="0" Length="10" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="Partner VAT ID" Show="false" DataType="0" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="Country/Region of Origin Code" Show="false" DataType="0" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="10" Name="Document No." Show="false" DataType="0" Length="20" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchMapping TableId="4812" Name="" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="1" FieldID="5" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="2" FieldID="17" /><DataExchFieldMapping ColumnNo="3" FieldID="28" /><DataExchFieldMapping ColumnNo="4" FieldID="8" /><DataExchFieldMapping ColumnNo="5" FieldID="21" /><DataExchFieldMapping ColumnNo="6" FieldID="35" Optional="true" /><DataExchFieldMapping ColumnNo="7" FieldID="7" /><DataExchFieldMapping ColumnNo="8" FieldID="29" /><DataExchFieldMapping ColumnNo="9" FieldID="24" TransformationRule="LOOKUPINTRASTATCODE"><TransformationRules><Code>LOOKUPINTRASTATCODE</Code><Description>Lookup Intrastat Country Code</Description><TransformationType>13</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>9</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>7</TargetFieldID><FieldLookupRule>1</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="10" FieldID="18" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                               Locked = true; // will be replaced with file import when available   
}