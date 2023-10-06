// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Bank.Payment;
using Microsoft.Foundation.Company;
using System.IO;
using System.Utilities;


codeunit 13406 "Intrastat Report Management FI"
{
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeInitSetup', '', true, true)]
    local procedure OnBeforeInitSetup(var IntrastatReportSetup: Record "Intrastat Report Setup"; var IsHandled: Boolean)
    var
#if not CLEAN22
        IntrastatFileSetup: Record "Intrastat - File Setup";
#endif
    begin
        IsHandled := true;

        IntrastatReportSetup."Shipments Based On" := IntrastatReportSetup."Shipments Based On"::"Ship-to Country";
        IntrastatReportSetup."Def. Private Person VAT No." := DefPrivatePersonVATNoLbl;
        IntrastatReportSetup."Def. 3-Party Trade VAT No." := Def3DPartyTradeVATNoLbl;
        IntrastatReportSetup."Def. VAT for Unknown State" := DefUnknowVATNoLbl;
#if not CLEAN22
        if IntrastatFileSetup.Get() then begin
            IntrastatReportSetup."Custom Code" := IntrastatFileSetup."Custom Code";
            IntrastatReportSetup."Company Serial No." := IntrastatFileSetup."Company Serial No.";
            IntrastatReportSetup."Last Transfer Date" := IntrastatFileSetup."Last Transfer Date";
            IntrastatReportSetup."File No." := IntrastatFileSetup."File No.";
        end;
#endif
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
        IntrastatReportChecklist.Validate("Field No.", 14);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 21);
        IntrastatReportChecklist.Validate("Filter Expression", 'Supplementary Units: False');
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 24);
        IntrastatReportChecklist.Validate("Filter Expression", 'Type: Shipment');
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 29);
        IntrastatReportChecklist.Validate("Filter Expression", 'Type: Shipment');
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeExportIntrastatHeader', '', true, true)]
    local procedure OnBeforeExportIntrastatHeader(var IntrastatReportHeader: Record "Intrastat Report Header"; var IsHandled: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.TestField("Business Identity Code");

        IntrastatReportSetup.Get();
        IntrastatReportSetup.TestField("Custom Code");
        IntrastatReportSetup.TestField("Company Serial No.");

        SetIntrastatHeader(IntrastatReportHeader);
        TotalRoundedAmount := 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeExportOneDataExchangeDef', '', true, true)]
    local procedure OnBeforeExportOneDataExchangeDef(var IntrastatReportHeader: Record "Intrastat Report Header"; DataExchDefCode: Code[20]; ExportType: Integer; var DataExch: Record "Data Exch."; var IsHandled: Boolean)
    begin
        TotalRoundedAmount := 0;
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
    end;

    procedure GetIntrastatHeader(): Record "Intrastat Report Header"
    begin
        exit(IntrastatReportHeader);
    end;

    procedure SetTotals(TotalRoundedAmount2: Integer; LineCount2: Integer)
    begin
        TotalRoundedAmount := TotalRoundedAmount2;
        LineCount := LineCount2;
    end;

    procedure GetTotals(var TotalRoundedAmount2: Integer; var LineCount2: Integer)
    begin
        TotalRoundedAmount2 := TotalRoundedAmount;
        LineCount2 := LineCount;
    end;

    procedure CreateDefaultDataExchangeDef()
    var
        DataExchDef: Record "Data Exch. Def";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        TempBlob: Codeunit "Temp Blob";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
    begin
        if DataExchDef.Get('INTRA-2022-FI-RCPT') then
            DataExchDef.Delete(true);

        if DataExchDef.Get('INTRA-2022-FI-SHPT') then
            DataExchDef.Delete(true);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeRcptXMLP1Txt + DataExchangeRcptXMLP2Txt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        Clear(TempBlob);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeShptXMLP1Txt + DataExchangeShptXMLP2Txt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        Clear(TempBlob);

        IntrastatReportSetup.Get();
        IntrastatReportSetup."Split Files" := true;
        IntrastatReportSetup."Data Exch. Def. Code - Receipt" := 'INTRA-2022-FI-RCPT';
        IntrastatReportSetup."Data Exch. Def. Code - Shpt." := 'INTRA-2022-FI-SHPT';
        IntrastatReportSetup.Modify();
    end;

    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        TotalRoundedAmount, LineCount : Integer;
        DefPrivatePersonVATNoLbl: Label 'QV999999999999', Locked = true;
        Def3DPartyTradeVATNoLbl: Label 'QV999999999999', Locked = true;
        DefUnknowVATNoLbl: Label 'QV999999999999', Locked = true;
        DataExchangeRcptXMLP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-FI-RCPT" Name="Intrastat Report 2022 Finland Receipt" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="13407" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="16"><DataExchColumnDef ColumnNo="1" Name="Line Prefix" Show="false" DataType="0" Length="3" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="Line No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="true" PadCharacter="0" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="Transaction Type" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="Country/Region of Origin Code" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="Country/Region" Show="false" DataType="0" Length="4" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="7" Name="Transport Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="Statistical Value" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="Internal Ref. No." Show="false" DataType="0" Length="15" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="10" Name="WT KGM" Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="11" Name="Total Weight" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="12" Name="Suppl. Qty. Code" Show="false" DataType="0" Length="3" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="13" Name="Suppl. UOM Code" Show="false" DataType="0" Length="3" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="14" Name="Supplementary Quantity" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="15" Name="Amount" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="16" Name="Partner VAT ID" Show="false" DataType="0" Length="14" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="5" MappingCodeunit="1269" PostMappingCodeunit="13408"><DataExchFieldMapping ColumnNo="1" Optional="true" UseDefaultValue="true" DefaultValue="NIM" /><DataExchFieldMapping ColumnNo="2" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" FieldID="8" Optional="true" /><DataExchFieldMapping ColumnNo="5" FieldID="24" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="7" FieldID="9" Optional="true" /><DataExchFieldMapping ColumnNo="8" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="23" Optional="true" /><DataExchFieldMapping ColumnNo="10" Optional="true" UseDefaultValue="true" DefaultValue="WT KGM" /><DataExchFieldMapping ColumnNo="11" FieldID="21" Optional="true" TransformationRule="ROUNDUPTOINT">',
                            Locked = true; // will be replaced with file import when available
        DataExchangeRcptXMLP2Txt: Label '<TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDUPTOINT</Code><Description>Round up to integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>&gt;</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="12" FieldID="33" Optional="true" TransformationRule="BLANKZERO"><TransformationRules><Code>ADDVALUEIFNOTEMPTY</Code><Description>Add value it source text is not empty</Description><TransformationType>6</TransformationType><FindValue>^.+</FindValue><ReplaceValue>AAE</ReplaceValue><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>BLANKZERO</Code><Description>Blank Zero</Description><TransformationType>6</TransformationType><FindValue>^0$</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ADDVALUEIFNOTEMPTY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="34" Optional="true" /><DataExchFieldMapping ColumnNo="14" FieldID="35" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="15" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="16" FieldID="29" Optional="true" /><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="24" /><DataExchFieldGrouping FieldID="29" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeShptXMLP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-FI-SHPT" Name="Intrastat Report 2022 Finland Shipment" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="13407" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="16"><DataExchColumnDef ColumnNo="1" Name="Line Prefix" Show="false" DataType="0" Length="3" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="Line No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="true" PadCharacter="0" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="Transaction Type" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="Country/Region of Origin Code" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="Country/Region" Show="false" DataType="0" Length="4" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="7" Name="Transport Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="Statistical Value" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="Internal Ref. No." Show="false" DataType="0" Length="15" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="10" Name="WT KGM" Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="11" Name="Total Weight" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="12" Name="Suppl. Qty. Code" Show="false" DataType="0" Length="3" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="13" Name="Suppl. UOM Code" Show="false" DataType="0" Length="3" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="14" Name="Supplementary Quantity" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="15" Name="Amount" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="16" Name="Partner VAT ID" Show="false" DataType="0" Length="14" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="5" MappingCodeunit="1269" PostMappingCodeunit="13408"><DataExchFieldMapping ColumnNo="1" Optional="true" UseDefaultValue="true" DefaultValue="NIM" /><DataExchFieldMapping ColumnNo="2" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" FieldID="8" Optional="true" /><DataExchFieldMapping ColumnNo="5" FieldID="24" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="7" FieldID="9" Optional="true" /><DataExchFieldMapping ColumnNo="8" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="23" Optional="true" /><DataExchFieldMapping ColumnNo="10" Optional="true" UseDefaultValue="true" DefaultValue="WT KGM" /><DataExchFieldMapping ColumnNo="11" FieldID="21" Optional="true" TransformationRule="ROUNDUPTOINT">',
                            Locked = true; // will be replaced with file import when available
        DataExchangeShptXMLP2Txt: Label '<TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDUPTOINT</Code><Description>Round up to integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>&gt;</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="12" FieldID="33" Optional="true" TransformationRule="BLANKZERO"><TransformationRules><Code>ADDVALUEIFNOTEMPTY</Code><Description>Add value it source text is not empty</Description><TransformationType>6</TransformationType><FindValue>^.+</FindValue><ReplaceValue>AAE</ReplaceValue><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>BLANKZERO</Code><Description>Blank Zero</Description><TransformationType>6</TransformationType><FindValue>^0$</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ADDVALUEIFNOTEMPTY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="34" Optional="true" /><DataExchFieldMapping ColumnNo="14" FieldID="35" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="15" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="16" FieldID="29" Optional="true" /><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="24" /><DataExchFieldGrouping FieldID="29" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available  
}
