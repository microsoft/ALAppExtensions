// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Bank.Payment;
using Microsoft.Inventory.Ledger;
using Microsoft.Projects.Project.Ledger;
using System.IO;
using System.Text;
using System.Utilities;

codeunit 11426 "Intrastat Report Management NL"
{
    Access = Internal;
    SingleInstance = true;

    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        ExportLineNo: Integer;
        DefPrivatePersonVATNoLbl: Label 'QW999999999999999', Locked = true;
        Def3DPartyTradeVATNoLbl: Label 'QV999999999999999', Locked = true;
        DefUnknowVATNoLbl: Label 'QV999999999999999', Locked = true;
        DataExchangeXMLP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-NL" Name="Intrastat Report 2022 NL" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="11427" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="28"><DataExchColumnDef ColumnNo="1" Name="Year" Show="false" DataType="0" Length="4" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="Month" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="Export Type Code" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="Company VAT Registration No." Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="Export Line No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="Country/Region of Origin Code" Show="false" DataType="0" Length="3" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="7" Name="Intrastat Country Code" Show="false" DataType="0" Length="3" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="Transport Method" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="0" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="Entry/Exit Point" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="10" Name="Zero" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="0" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="11" Name="Space" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="12" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="13" Name="Zero" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="14" Name="Plus" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="+" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="15" Name="Total Weight" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="16" Name="Plus" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="+" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="17" Name="Supplementary Quantity" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="18" Name="Plus" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="+" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="19" Name="Amount" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="20" Name="Plus" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="+" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="21" Name="Zero" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="22" Name="Document No." Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="23" Name="Space" Show="false" DataType="0" Length="4" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="24" Name="Zero" Show="false" DataType="0" Length="3" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="25" Name="Currency Identifier" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="26" Name="Space" Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="27" Name="Transaction Type" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="28" Name="Partner VAT ID" Show="false" DataType="0" Length="17" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="9" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="1" FieldID="4" Optional="true" TransformationRule="GETYEAR"><TransformationRules><Code>GETYEAR</Code><Description>Get Year From Date</Description><TransformationType>15</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>3</ExportFromDateType></TransformationRules></DataExchFieldMapping>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLP2Txt: Label '<DataExchFieldMapping ColumnNo="2" FieldID="4" Optional="true" TransformationRule="GETMONTH"><TransformationRules><Code>GETMONTH</Code><Description>Get Month From Date</Description><TransformationType>15</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>2</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="3" FieldID="3" Optional="true" TransformationRule="REPLACERECEIPT"><TransformationRules><Code>REPLACERECEIPT</Code><Description>Replace Receipt with 6</Description><TransformationType>6</TransformationType><FindValue>(Receipt|Ontvangstdocument)</FindValue><ReplaceValue>6</ReplaceValue><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>REPLACESHIPMENT</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>REPLACESHIPMENT</Code><Description>Replace Shipment with 7</Description><TransformationType>6</TransformationType><FindValue>(Shipment|Verzenddocument)</FindValue><ReplaceValue>7</ReplaceValue><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" FieldID="1" Optional="true" TransformationRule="CLEARFIELDANDLOOKUP"><TransformationRules><Code>CLEARFIELDANDLOOKUP</Code><Description>Clear field and lookup Company VAT Number</Description><TransformationType>6</TransformationType><FindValue>.*</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>LOOKUPCOMPANYVAT</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>FORMATCOPMANYVAT</Code><Description>Format Copmany VAT</Description><TransformationType>5</TransformationType><FindValue>NL</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>LOOKUPCOMPANYVAT</Code><Description>Lookup Company VAT Number</Description><TransformationType>13</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>FORMATCOPMANYVAT</NextTransformationRule><TableID>79</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>19</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="5" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="24" Optional="true" TransformationRule="LOOKUPINTRASTATCODE"><TransformationRules><Code>LOOKUPINTRASTATCODE</Code><Description>Lookup Intrastat Country Code</Description><TransformationType>13</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>9</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>7</TargetFieldID><FieldLookupRule>1</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="7" FieldID="7" Optional="true" TransformationRule="LOOKUPINTRASTATCODE"><TransformationRules><Code>LOOKUPINTRASTATCODE</Code><Description>Lookup Intrastat Country Code</Description><TransformationType>13</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>9</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>7</TargetFieldID><FieldLookupRule>1</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="8" FieldID="9" Optional="true" /><DataExchFieldMapping ColumnNo="9" FieldID="25" Optional="true" /><DataExchFieldMapping ColumnNo="10" Optional="true" UseDefaultValue="true" /><DataExchFieldMapping ColumnNo="11" Optional="true" UseDefaultValue="true" /><DataExchFieldMapping ColumnNo="12" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" Optional="true" UseDefaultValue="true" /><DataExchFieldMapping ColumnNo="14" Optional="true" UseDefaultValue="true" />',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLP3Txt: Label '<DataExchFieldMapping ColumnNo="15" FieldID="21" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="16" Optional="true" UseDefaultValue="true" /><DataExchFieldMapping ColumnNo="17" FieldID="35" Optional="true" TransformationRule="ROUNDTOINTWITHMIN1"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINTWITHMIN1</Code><Description>Round to Integer with minimal value equal to 1</Description><TransformationType>6</TransformationType><FindValue>^0[,.].*</FindValue><ReplaceValue>1</ReplaceValue><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ROUNDTOINT</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="18" Optional="true" UseDefaultValue="true" /><DataExchFieldMapping ColumnNo="19" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="20" Optional="true" UseDefaultValue="true" /><DataExchFieldMapping ColumnNo="21" Optional="true" UseDefaultValue="true" DefaultValue="0" /><DataExchFieldMapping ColumnNo="22" FieldID="18" Optional="true" /><DataExchFieldMapping ColumnNo="23" Optional="true" UseDefaultValue="true" /><DataExchFieldMapping ColumnNo="24" Optional="true" UseDefaultValue="true" /><DataExchFieldMapping ColumnNo="25" FieldID="1" Optional="true" TransformationRule="LOOKUPCURRCODE"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>LOOKUPCURRCODE</Code><Description>Lookup Currency Code</Description><TransformationType>13</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>FIRSTCHAR</NextTransformationRule><TableID>4811</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>16</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="26" Optional="true" UseDefaultValue="true" /><DataExchFieldMapping ColumnNo="27" FieldID="8" Optional="true" /><DataExchFieldMapping ColumnNo="28" FieldID="29" Optional="true" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available                                    

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeInitSetup', '', true, true)]
    local procedure OnBeforeInitSetup(var IntrastatReportSetup: Record "Intrastat Report Setup"; var IsHandled: Boolean)
    begin
        IsHandled := true;

        IntrastatReportSetup."Shipments Based On" := IntrastatReportSetup."Shipments Based On"::"Ship-to Country";
        IntrastatReportSetup."Def. Private Person VAT No." := DefPrivatePersonVATNoLbl;
        IntrastatReportSetup."Def. 3-Party Trade VAT No." := Def3DPartyTradeVATNoLbl;
        IntrastatReportSetup."Def. VAT for Unknown State" := DefUnknowVATNoLbl;
        IntrastatReportSetup.Modify();

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
        IntrastatReportChecklist.Validate("Field No.", 9);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 12);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 19);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 21);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 24);
        IntrastatReportChecklist.Validate("Filter Expression", 'Type: Shipment');
        IntrastatReportChecklist.Validate("Must Be Blank For Filter Expr.", 'Type: Receipt');
        IntrastatReportChecklist.Insert(true);


        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 29);
        IntrastatReportChecklist.Validate("Filter Expression", 'Type: Shipment');
        IntrastatReportChecklist.Validate("Must Be Blank For Filter Expr.", 'Type: Receipt');
        IntrastatReportChecklist.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Export Mgt", 'OnBeforeFormatToText', '', true, true)]
    local procedure OnBeforeFormatToText(ValueToFormat: Variant; DataExchDef: Record "Data Exch. Def"; DataExchColumnDef: Record "Data Exch. Column Def"; var ResultText: Text[250]; var IsHandled: Boolean)
    begin
        IsHandled := true;

        if (Format(ValueToFormat) = '0') and (DataExchColumnDef."Blank Zero") then
            ResultText := ''
        else
            if DataExchColumnDef."Data Format" <> '' then
                ResultText := Format(ValueToFormat, 0, DataExchColumnDef."Data Format")
            else
                if DataExchDef."File Type" in [DataExchDef."File Type"::Xml, DataExchDef."File Type"::Json] then
                    ResultText := Format(ValueToFormat, 0, 9)
                else
                    ResultText := Format(ValueToFormat);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Export Mgt", 'OnProcessColumnMappingOnBeforeCheckLength', '', true, true)]
    local procedure OnProcessColumnMappingOnBeforeCheckLength(var ValueAsString: Text[250]; DataExchFieldMapping: Record "Data Exch. Field Mapping"; DataExchColumnDef: Record "Data Exch. Column Def")
    var
        StringConversionManagement: Codeunit StringConversionManagement;
    begin
        if DataExchColumnDef."Text Padding Required" and (DataExchColumnDef."Pad Character" <> '') and (not DataExchColumnDef."Blank Zero") then
            ValueAsString :=
                StringConversionManagement.GetPaddedString(
                    ValueAsString,
                    DataExchColumnDef.Length,
                    DataExchColumnDef."Pad Character",
                    DataExchColumnDef.Justification);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeExportIntrastatHeader', '', true, true)]
    local procedure OnBeforeExportIntrastatHeader(var IntrastatReportHeader: Record "Intrastat Report Header"; var IsHandled: Boolean)
    begin
        SetIntrastatHeader(IntrastatReportHeader);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnBeforeInsertItemLedgerLine', '', false, false)]
    local procedure OnBeforeInsertItemLedgerLine(var IntrastatReportLine: Record "Intrastat Report Line"; ItemLedgerEntry: Record "Item Ledger Entry"; var IsHandled: Boolean)
    begin
        IntrastatLineCheckUpdate(IntrastatReportLine);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnBeforeInsertJobLedgerLine', '', false, false)]
    local procedure IntrastatOnBeforeInsertJobLedgerLine(var IntrastatReportLine: Record "Intrastat Report Line"; JobLedgerEntry: Record "Job Ledger Entry"; var IsHandled: Boolean)
    begin
        IntrastatLineCheckUpdate(IntrastatReportLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeCreateDefaultDataExchangeDef', '', true, true)]
    local procedure OnBeforeCreateDefaultDataExchangeDef(var IsHandled: Boolean);
    begin
        CreateDefaultDataExchangeDef();
        IsHandled := true;
    end;

    procedure SetIntrastatHeader(var IntrastatReportHeader2: Record "Intrastat Report Header")
    begin
        IntrastatReportHeader := IntrastatReportHeader2;
        IntrastatReportHeader.TestField("Currency Identifier");
        ExportLineNo := 0;
    end;

    procedure GetIntrastatHeader(): Record "Intrastat Report Header"
    begin
        exit(IntrastatReportHeader);
    end;

    procedure CheckIntrastatJournalLineForCorrection(IntrastatReportLine: Record "Intrastat Report Line"; var ItemDirectionType: Enum "Intrastat Report Line Type"): Boolean
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if ItemLedgerEntry.Get(IntrastatReportLine."Source Entry No.") then
            case ItemLedgerEntry."Document Type" of
                ItemLedgerEntry."Document Type"::"Purchase Return Shipment",
                ItemLedgerEntry."Document Type"::"Purchase Credit Memo":
                    begin
                        ItemDirectionType := IntrastatReportLine.Type::Receipt;
                        exit(true);
                    end;
                ItemLedgerEntry."Document Type"::"Sales Return Receipt",
                ItemLedgerEntry."Document Type"::"Sales Credit Memo",
                ItemLedgerEntry."Document Type"::"Service Credit Memo":
                    begin
                        ItemDirectionType := IntrastatReportLine.Type::Shipment;
                        exit(true);
                    end;
            end;
    end;

    procedure IntrastatLineCheckUpdate(var IntrastatReportLine: Record "Intrastat Report Line")
    begin
        if CheckIntrastatJournalLineForCorrection(IntrastatReportLine, IntrastatReportLine.Type) then begin
            IntrastatReportLine.Quantity := -IntrastatReportLine.Quantity;
            IntrastatReportLine."Total Weight" := -IntrastatReportLine."Total Weight";
            IntrastatReportLine."Statistical Value" := -IntrastatReportLine."Statistical Value";
            IntrastatReportLine.Amount := -IntrastatReportLine.Amount;
            IntrastatReportLine."Country/Region of Origin Code" := IntrastatReportLine.GetCountryOfOriginCode();
            IntrastatReportLine."Partner VAT ID" := IntrastatReportLine.GetPartnerID();
        end;
    end;

    procedure CreateDefaultDataExchangeDef()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        DataExchDef: Record "Data Exch. Def";
        TempBlob: Codeunit "Temp Blob";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
    begin
        if DataExchDef.Get('INTRA-2022-NL') then
            DataExchDef.Delete(true);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLP1Txt + DataExchangeXMLP2Txt + DataExchangeXMLP3Txt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);

        IntrastatReportSetup.Get();
        IntrastatReportSetup."Data Exch. Def. Code" := 'INTRA-2022-NL';
        IntrastatReportSetup.Modify();
    end;
}
