// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using System.IO;
using System.Utilities;

codeunit 11298 IntrastatReportManagementSE
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeInitSetup', '', true, true)]
    local procedure OnBeforeInitSetup(var IntrastatReportSetup: Record "Intrastat Report Setup"; var IsHandled: Boolean)
    begin
        IsHandled := true;

        IntrastatReportSetup."Shipments Based On" := IntrastatReportSetup."Shipments Based On"::"Ship-to Country";
        IntrastatReportSetup."Get Partner VAT For" := IntrastatReportSetup."Get Partner VAT For"::Shipment;
        IntrastatReportSetup."Def. Private Person VAT No." := DefPrivatePersonVATNoLbl;
        IntrastatReportSetup."Def. 3-Party Trade VAT No." := Def3DPartyTradeVATNoLbl;
        IntrastatReportSetup."Def. VAT for Unknown State" := DefUnknowVATNoLbl;
        IntrastatReportSetup.Modify();

        CreateDefaultDataExchangeDef();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeCreateDefaultDataExchangeDef', '', true, true)]
    local procedure OnBeforeCreateDefaultDataExchangeDef(var IsHandled: Boolean);
    begin
        CreateDefaultDataExchangeDef();
        IsHandled := true;
    end;

    procedure CreateDefaultDataExchangeDef()
    var
        DataExchDef: Record "Data Exch. Def";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        TempBlob: Codeunit "Temp Blob";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
    begin
        if DataExchDef.Get('INTRA-2022') then
            DataExchDef.Delete(true);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLTxt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);

        IntrastatReportSetup.Get();
        IntrastatReportSetup."Split Files" := true;
        IntrastatReportSetup."Data Exch. Def. Code - Receipt" := 'INTRA-2022';
        IntrastatReportSetup."Data Exch. Def. Code - Shpt." := 'INTRA-2022';
        IntrastatReportSetup.Modify();
    end;

    var
        DefPrivatePersonVATNoLbl: Label 'QV999999999999', Locked = true;
        Def3DPartyTradeVATNoLbl: Label 'QV999999999999', Locked = true;
        DefUnknowVATNoLbl: Label 'QV999999999999', Locked = true;
        DataExchangeXMLTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022" Name="Intrastat Report 2022" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="4813" ColumnSeparator="1" FileType="1" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="1" Code="DEFAULT" Name="DEFAULT" ColumnCount="9"><DataExchColumnDef ColumnNo="1" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="2" Name="Country/Region Code" Show="false" DataType="0" Length="3" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="3" Name="Transaction Type" Show="false" DataType="0" Length="2" TextPaddingRequired="true" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="4" Name="Quantity" Show="false" DataType="0" Length="11" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="5" Name="Total Weight" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="6" Name="Statistical Value" Show="false" DataType="0" Length="11" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="7" Name="Internal Ref. No." Show="false" DataType="0" Length="30" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="8" Name="Partner Tax ID" Show="false" DataType="0" Length="20" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="9" Name="Country/Region of Origin Code" Show="false" DataType="0" Length="3" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="5" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="1" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="2" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="8" Optional="true" /><DataExchFieldMapping ColumnNo="4" FieldID="14" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="5" FieldID="21" Optional="true" TransformationRule="ROUNDUPTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDUPTOINT</Code><Description>Round up to integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>&gt;</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="6" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="7" FieldID="23" Optional="true" /><DataExchFieldMapping ColumnNo="8" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="9" FieldID="24" Optional="true" TransformationRule="EUCOUNTRYCODELOOKUP"><TransformationRules><Code>EUCOUNTRYCODELOOKUP</Code><Description>EU Country Lookup</Description><TransformationType>13</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>9</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>7</TargetFieldID><FieldLookupRule>1</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="24" /><DataExchFieldGrouping FieldID="29" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available

}