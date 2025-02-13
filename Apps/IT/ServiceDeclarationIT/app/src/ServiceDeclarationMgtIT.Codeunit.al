// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using Microsoft.Bank.Payment;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Receivables;
using System.IO;
using System.Text;
using System.Utilities;

codeunit 12216 "Service Declaration Mgt. IT"
{
    Access = Internal;
    SingleInstance = true;

    var
        TotalRoundedAmount, LineCount : Integer;
        ServDeclDataExchPurchaseCodeLbl: Label 'SERVDECLITP-2023', Locked = true;
        ServDeclDataExchSaleCodeLbl: Label 'SERVDECLITS-2023', Locked = true;
        ServDeclDataExchPurchaseCorrectionCodeLbl: Label 'SERVDECLITPC-2023', Locked = true;
        ServDeclDataExchSaleCorrectionCodeLbl: Label 'SERVDECLITSC-2023', Locked = true;
        DataExchangePurchaseXMLTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="SERVDECLITP-2023" Name="Service declaration purchase" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="12214" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="15"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Line No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Source Currency Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Document No." Show="false" DataType="0" Length="15" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Document Date" Show="false" DataType="0" Length="6" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Service Tariff No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Transport Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Payment Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="15" Name="Country/Region of Payment Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="5024" Name="" KeyIndex="2" MappingCodeunit="1269" PostMappingCodeunit="12215"><DataExchFieldMapping ColumnNo="1" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="12214" /><DataExchFieldMapping ColumnNo="3" FieldID="12215" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" UseDefaultValue="true" DefaultValue="3" /><DataExchFieldMapping ColumnNo="5" FieldID="12216" /><DataExchFieldMapping ColumnNo="6" FieldID="6" /><DataExchFieldMapping ColumnNo="7" FieldID="15" /><DataExchFieldMapping ColumnNo="8" FieldID="12220" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="12221" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="10" FieldID="12222" Optional="true" /><DataExchFieldMapping ColumnNo="11" FieldID="12218" /><DataExchFieldMapping ColumnNo="12" FieldID="12224" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="12225" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="12226" TransformationRule="LOOKUPPAYMENTMETHOD"><TransformationRules><Code>LOOKUPPAYMENTMETHOD</Code><Description>Lookup Payment Method</Description><TransformationType>13</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>289</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>12173</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="15" FieldID="12227" /></DataExchMapping></DataExchLineDef></DataExchDef></root>', Locked = true;
        DataExchangeSaleXMLTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="SERVDECLITS-2023" Name="Service declaration sale" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="12214" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="14"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Line No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Document No." Show="false" DataType="0" Length="15" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Document Date" Show="false" DataType="0" Length="6" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Service Tariff No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Transport Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Payment Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Country/Region of Payment Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="5024" Name="" KeyIndex="2" MappingCodeunit="1269" PostMappingCodeunit="12215"><DataExchFieldMapping ColumnNo="1" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="12214" /><DataExchFieldMapping ColumnNo="3" FieldID="12215" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" UseDefaultValue="true" DefaultValue="3" /><DataExchFieldMapping ColumnNo="5" FieldID="12216" /><DataExchFieldMapping ColumnNo="6" FieldID="6" /><DataExchFieldMapping ColumnNo="7" FieldID="15" /><DataExchFieldMapping ColumnNo="8" FieldID="12220" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="32" /><DataExchFieldMapping ColumnNo="10" FieldID="12218" /><DataExchFieldMapping ColumnNo="11" FieldID="12224" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="12" FieldID="12225" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="12226" TransformationRule="LOOKUPPAYMENTMETHOD"><TransformationRules><Code>LOOKUPPAYMENTMETHOD</Code><Description>Lookup Payment Method</Description><TransformationType>13</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>289</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>12173</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="12227" /></DataExchMapping></DataExchLineDef></DataExchDef></root>', Locked = true;
        DataExchangePurchaseCorrectionXMLTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="SERVDECLITPC-2023" Name="Service declaration purchase correction" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="12214" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="19"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Line No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Custom Office No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Reference Period" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Reference File Disk No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Source Currency Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Document No." Show="false" DataType="0" Length="15" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="15" Name="Document Date" Show="false" DataType="0" Length="6" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="16" Name="Service Tariff No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="17" Name="Transport Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="18" Name="Payment Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="19" Name="Country/Region of Payment Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="5024" Name="" KeyIndex="2" MappingCodeunit="1269" PostMappingCodeunit="12215"><DataExchFieldMapping ColumnNo="1" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="12214" /><DataExchFieldMapping ColumnNo="3" FieldID="12215" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" UseDefaultValue="true" DefaultValue="4" /><DataExchFieldMapping ColumnNo="5" FieldID="12216" /><DataExchFieldMapping ColumnNo="6" FieldID="12229" /><DataExchFieldMapping ColumnNo="7" FieldID="12232" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First two characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="8" FieldID="12233" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="12234" /><DataExchFieldMapping ColumnNo="10" FieldID="6" /><DataExchFieldMapping ColumnNo="11" FieldID="15" /><DataExchFieldMapping ColumnNo="12" FieldID="12220" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="12221" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="32" /><DataExchFieldMapping ColumnNo="15" FieldID="12218" /><DataExchFieldMapping ColumnNo="16" FieldID="12224" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="17" FieldID="12225" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="18" FieldID="12226" TransformationRule="LOOKUPPAYMENTMETHOD"><TransformationRules><Code>LOOKUPPAYMENTMETHOD</Code><Description>Lookup Payment Method</Description><TransformationType>13</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>289</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>12173</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="19" FieldID="12227" /></DataExchMapping></DataExchLineDef></DataExchDef></root>', Locked = true;
        DataExchangeSaleCorrectionXMLTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="SERVDECLITSC-2023" Name="Service declaration sale correction" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="12214" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="18"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Line No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Custom Office No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Reference Period" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Reference File Disk No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Document No." Show="false" DataType="0" Length="15" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Document Date" Show="false" DataType="0" Length="6" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="15" Name="Service Tariff No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="16" Name="Transport Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="17" Name="Payment Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="18" Name="Country/Region of Payment Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="5024" Name="" KeyIndex="2" MappingCodeunit="1269" PostMappingCodeunit="12215"><DataExchFieldMapping ColumnNo="1" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="12214" /><DataExchFieldMapping ColumnNo="3" FieldID="12215" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" UseDefaultValue="true" DefaultValue="4" /><DataExchFieldMapping ColumnNo="5" FieldID="12216" /><DataExchFieldMapping ColumnNo="6" FieldID="12229" /><DataExchFieldMapping ColumnNo="7" FieldID="12232" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First two characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="8" FieldID="12233" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="12234" /><DataExchFieldMapping ColumnNo="10" FieldID="6" /><DataExchFieldMapping ColumnNo="11" FieldID="15" /><DataExchFieldMapping ColumnNo="12" FieldID="12220" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="32" /><DataExchFieldMapping ColumnNo="14" FieldID="12218" /><DataExchFieldMapping ColumnNo="15" FieldID="12224" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="16" FieldID="12225" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="17" FieldID="12226" TransformationRule="LOOKUPPAYMENTMETHOD"><TransformationRules><Code>LOOKUPPAYMENTMETHOD</Code><Description>Lookup Payment Method</Description><TransformationType>13</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>289</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>12173</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="18" FieldID="12227" /></DataExchMapping></DataExchLineDef></DataExchDef></root>', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service Declaration Mgt.", 'OnAfterInitServDeclSetup', '', false, false)]
    local procedure OnAfterInitServDeclSetup(var ServDeclSetup: Record "Service Declaration Setup")
    begin
        InitSetup(ServDeclSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service Declaration Mgt.", 'OnBeforeCreateDefaultDataExchangeDef', '', false, false)]
    local procedure OnBeforeCreateDefaultDataExchangeDef(var IsHandled: Boolean);
    var
        ServDeclSetup: Record "Service Declaration Setup";
    begin
        if not ServDeclSetup.Get() then
            ServDeclSetup.Insert();

        InitSetup(ServDeclSetup);
        ServDeclSetup.Modify();
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Get Service Declaration Lines", 'OnBeforeAddLines', '', false, false)]
    local procedure OnBeforeAddLines(ServiceDeclarationHeader: Record "Service Declaration Header"; var IsHandled: Boolean);
    var
        Country: Record "Country/Region";
        CompanyInfo: Record "Company Information";
        CustLedgEntry: Record "Cust. Ledger Entry";
        ServiceDeclarationLine: Record "Service Declaration Line";
        TempCustLedgEntry: Record "Cust. Ledger Entry" temporary;
        TempVendLedgEntry: Record "Vendor Ledger Entry" temporary;
        VendLedgEntry: Record "Vendor Ledger Entry";
        VATEntry: Record "VAT Entry";
        EntryNo, PrevEntryNo : Integer;
    begin
        VATEntry.SetCurrentKey(Type, "Country/Region Code", "VAT Registration No.", "VAT Bus. Posting Group", "VAT Prod. Posting Group", "Posting Date");
        VATEntry.SetRange("Operation Occurred Date", ServiceDeclarationHeader."Starting Date", ServiceDeclarationHeader."Ending Date");
        VATEntry.SetRange("EU Service", true);
        VATEntry.SetRange("Reverse Sales VAT", false);

        if ServiceDeclarationHeader.Type = ServiceDeclarationHeader.Type::Purchases then
            VATEntry.SetRange(Type, VATEntry.Type::Purchase)
        else
            VATEntry.SetRange(Type, VATEntry.Type::Sale);

        if ServiceDeclarationHeader."Corrective Entry" then
            VATEntry.SetRange("Document Type", VATEntry."Document Type"::"Credit Memo")
        else
            VATEntry.SetFilter("Document Type", '%1|%2', VATEntry."Document Type"::Invoice, VATEntry."Document Type"::"Credit Memo");

        CompanyInfo.Get();
        Country.SetFilter(Code, '<>%1', CompanyInfo."Country/Region Code");
        Country.SetFilter("Intrastat Code", '<>%1', '');
        if Country.FindSet() then
            repeat
                VATEntry.SetRange("Country/Region Code", Country.Code);
                if VATEntry.FindSet() then
                    repeat
                        ServiceDeclarationLine.SetRange("Source Entry No.", VATEntry."Entry No.");
                        if ServiceDeclarationLine.IsEmpty then
                            if ServiceDeclarationHeader."Corrective Entry" then
                                case VATEntry.Type of
                                    VATEntry.Type::Sale:
                                        begin
                                            EntryNo := GetCustLedgEntryNo(VATEntry);
                                            if not (EntryNo in [0, PrevEntryNo]) then begin
                                                PrevEntryNo := EntryNo;
                                                CustLedgEntry.Get(EntryNo);
                                                FindAppliedCustLedgEntries(CustLedgEntry, TempCustLedgEntry);

                                                TempCustLedgEntry.SetRange("Document Type", TempCustLedgEntry."Document Type"::Invoice);
                                                TempCustLedgEntry.SetFilter("Posting Date", '<%1', ServiceDeclarationHeader."Starting Date");
                                                if TempCustLedgEntry.FindSet() then
                                                    repeat
                                                        FilterVATEntryOnCustLedgEntry(VATEntry, TempCustLedgEntry);
                                                        if VATEntry.FindSet() then
                                                            repeat
                                                                InsertEUServiceLine(VATEntry, ServiceDeclarationHeader);
                                                            until VATEntry.Next() = 0;
                                                    until TempCustLedgEntry.Next() = 0;
                                            end;
                                        end;
                                    VATEntry.Type::Purchase:
                                        begin
                                            EntryNo := GetVendLedgEntryNo(VATEntry);
                                            if not (EntryNo in [0, PrevEntryNo]) then begin
                                                PrevEntryNo := EntryNo;
                                                VendLedgEntry.Get(EntryNo);
                                                FindAppliedVendLedgEntries(VendLedgEntry, TempVendLedgEntry);

                                                TempVendLedgEntry.SetRange("Document Type", TempVendLedgEntry."Document Type"::Invoice);
                                                TempVendLedgEntry.SetFilter("Posting Date", '<%1', ServiceDeclarationHeader."Starting Date");
                                                if TempVendLedgEntry.FindSet() then
                                                    repeat
                                                        FilterVATEntryOnVendLedgEntry(VATEntry, TempVendLedgEntry);
                                                        if VATEntry.FindSet() then
                                                            repeat
                                                                InsertEUServiceLine(VATEntry, ServiceDeclarationHeader);
                                                            until VATEntry.Next() = 0;
                                                    until TempVendLedgEntry.Next() = 0;
                                            end;
                                        end;
                                end
                            else
                                if not ((VatEntry."Document Type" = VatEntry."Document Type"::"Credit Memo") and DocumentHasApplications(VATEntry, ServiceDeclarationHeader)) then
                                    InsertEUServiceLine(VATEntry, ServiceDeclarationHeader);

                    until VATEntry.Next() = 0;
            until Country.Next() = 0;

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Service Declaration Overview", 'OnBeforeGetDataExchDefinition', '', false, false)]
    local procedure OnBeforeGetDataExchDefinition(var ServiceDeclarationHeader: Record "Service Declaration Header"; var DataExchDef: Record "Data Exch. Def"; var IsHandled: Boolean)
    begin
        GetDataExchDefinition(ServiceDeclarationHeader, DataExchDef);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Service Declaration", 'OnBeforeExportServiceDeclaration', '', false, false)]
    local procedure OnBeforeExportServiceDeclaration(var ServiceDeclarationHeader: Record "Service Declaration Header"; var IsHandled: Boolean)
    var
        ServiceDeclarationLine: Record "Service Declaration Line";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        DataExchMapping: Record "Data Exch. Mapping";
        RecRef: RecordRef;
        OutStr: OutStream;
        ExportLineNo: Integer;
    begin
        GetDataExchDefinition(ServiceDeclarationHeader, DataExchDef);

        DataExchMapping.SetRange("Data Exch. Def Code", DataExchDef.Code);
        DataExchMapping.SetRange("Table ID", Database::"Service Declaration Line");
        DataExchMapping.FindFirst();

        ExportLineNo := 0;
        if DataExchMapping."Key Index" <> 0 then begin
            RecRef.Open(Database::"Service Declaration Line");
            RecRef.CurrentKeyIndex(DataExchMapping."Key Index");
            ServiceDeclarationLine.SetView(RecRef.GetView());
        end;
        ServiceDeclarationLine.SetRange("Service Declaration No.", ServiceDeclarationHeader."No.");
        if ServiceDeclarationLine.FindSet() then
            repeat
                ExportLineNo += 1;
                ServiceDeclarationLine."Export Line No." := Format(ExportLineNo);
                ServiceDeclarationLine.Modify();
            until ServiceDeclarationLine.Next() = 0;

        DataExch.Init();
        DataExch."Data Exch. Def Code" := DataExchMapping."Data Exch. Def Code";
        DataExch."Data Exch. Line Def Code" := DataExchMapping."Data Exch. Line Def Code";
        DataExch."Table Filters".CreateOutStream(OutStr);
        ServiceDeclarationLine.SetRange("Service Declaration No.", ServiceDeclarationHeader."No.");
        OutStr.WriteText(ServiceDeclarationLine.GetView());
        DataExch.Insert(true);
        DataExch.ExportFromDataExch(DataExchMapping);
        DataExch.Modify();

        IsHandled := true;
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

    internal procedure InitSetup(var ServDeclSetup: Record "Service Declaration Setup")
    var
        DataExchDef: Record "Data Exch. Def";
        TempBlob: Codeunit "Temp Blob";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
    begin
        if not DataExchDef.Get(ServDeclDataExchPurchaseCodeLbl) then begin
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(DataExchangePurchaseXMLTxt);
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
            Clear(TempBlob);
        end;
        ServDeclSetup.Validate("Data Exch. Def. Purch. Code", ServDeclDataExchPurchaseCodeLbl);

        if not DataExchDef.Get(ServDeclDataExchSaleCodeLbl) then begin
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(DataExchangeSaleXMLTxt);
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
            Clear(TempBlob);
        end;
        ServDeclSetup.Validate("Data Exch. Def. Sale Code", ServDeclDataExchSaleCodeLbl);

        if not DataExchDef.Get(ServDeclDataExchPurchaseCorrectionCodeLbl) then begin
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(DataExchangePurchaseCorrectionXMLTxt);
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
            Clear(TempBlob);
        end;
        ServDeclSetup.Validate("Data Exch. Def. P. Corr. Code", ServDeclDataExchPurchaseCorrectionCodeLbl);

        if not DataExchDef.Get(ServDeclDataExchSaleCorrectionCodeLbl) then begin
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(DataExchangeSaleCorrectionXMLTxt);
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
            Clear(TempBlob);
        end;
        ServDeclSetup.Validate(ServDeclSetup."Data Exch. Def. S. Corr. Code", ServDeclDataExchSaleCorrectionCodeLbl);

        ServDeclSetup."Enable VAT Registration No." := true;
        ServDeclSetup."Enable Serv. Trans. Types" := false;
        ServDeclSetup."Show Serv. Decl. Overview" := false;
    end;

    internal procedure GetCompanyRepresentativeVATNo(): Text[20]
    var
        CompanyInfo: Record "Company Information";
        Vendor: Record Vendor;
    begin
        CompanyInfo.Get();
        if (CompanyInfo."Tax Representative No." <> '') and Vendor.Get(CompanyInfo."Tax Representative No.") and (Vendor."VAT Registration No." <> '')
        then
            exit(Format(RemoveLeadingCountryCode(Vendor."VAT Registration No.", CompanyInfo."Country/Region Code")).PadRight(11, '0'))
        else
            exit(Format(RemoveLeadingCountryCode(CompanyInfo."VAT Registration No.", CompanyInfo."Country/Region Code")).PadRight(11, '0'));
    end;

    internal procedure RemoveLeadingCountryCode(CodeParameter: Text[50]; CountryCode: Text[10]): Text[50]
    begin
        CountryCode := CountryCode.Trim();
        if CopyStr(CodeParameter, 1, StrLen(CountryCode)) = CountryCode then
            exit(CopyStr(CodeParameter, StrLen(CountryCode) + 1))
        else
            exit(CodeParameter);
    end;

    internal procedure SetTotals(TotalRoundedAmount2: Integer; LineCount2: Integer)
    begin
        TotalRoundedAmount := TotalRoundedAmount2;
        LineCount := LineCount2;
    end;

    internal procedure GetTotals(var TotalRoundedAmount2: Integer; var LineCount2: Integer)
    begin
        TotalRoundedAmount2 := TotalRoundedAmount;
        LineCount2 := LineCount;
    end;

    local procedure GetDataExchDefinition(ServiceDeclarationHeader: Record "Service Declaration Header"; var DataExchDef: Record "Data Exch. Def")
    var
        ServiceDeclarationSetup: Record "Service Declaration Setup";
    begin
        ServiceDeclarationSetup.Get();
        case true of
            (ServiceDeclarationHeader.Type = ServiceDeclarationHeader.Type::Purchases) and not ServiceDeclarationHeader."Corrective Entry":
                begin
                    ServiceDeclarationSetup.TestField("Data Exch. Def. Purch. Code");
                    DataExchDef.Get(ServiceDeclarationSetup."Data Exch. Def. Purch. Code");
                end;
            (ServiceDeclarationHeader.Type = ServiceDeclarationHeader.Type::Purchases) and ServiceDeclarationHeader."Corrective Entry":
                begin
                    ServiceDeclarationSetup.TestField("Data Exch. Def. P. Corr. Code");
                    DataExchDef.Get(ServiceDeclarationSetup."Data Exch. Def. P. Corr. Code");
                end;
            (ServiceDeclarationHeader.Type = ServiceDeclarationHeader.Type::Sales) and not ServiceDeclarationHeader."Corrective Entry":
                begin
                    ServiceDeclarationSetup.TestField("Data Exch. Def. Sale Code");
                    DataExchDef.Get(ServiceDeclarationSetup."Data Exch. Def. Sale Code");
                end;
            (ServiceDeclarationHeader.Type = ServiceDeclarationHeader.Type::Sales) and ServiceDeclarationHeader."Corrective Entry":
                begin
                    ServiceDeclarationSetup.TestField("Data Exch. Def. S. Corr. Code");
                    DataExchDef.Get(ServiceDeclarationSetup."Data Exch. Def. S. Corr. Code");
                end;
        end;
    end;

    local procedure GetCustLedgEntryNo(VATEntry: Record "VAT Entry"): Integer
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetCurrentKey("Transaction No.");
        CustLedgerEntry.SetRange("Transaction No.", VATEntry."Transaction No.");
        CustLedgerEntry.SetRange("Document No.", VATEntry."Document No.");
        if CustLedgerEntry.FindFirst() then
            exit(CustLedgerEntry."Entry No.");
    end;

    local procedure FindAppliedCustLedgEntries(CustLedgerEntry: Record "Cust. Ledger Entry"; var TempAppliedCustLedgEntry: Record "Cust. Ledger Entry" temporary)
    var
        DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        DtldCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
        CustLedgEntry2: Record "Cust. Ledger Entry";
    begin
        TempAppliedCustLedgEntry.Reset();
        TempAppliedCustLedgEntry.DeleteAll();

        DtldCustLedgEntry.SetCurrentKey("Cust. Ledger Entry No.");
        DtldCustLedgEntry.SetRange("Cust. Ledger Entry No.", CustLedgerEntry."Entry No.");
        DtldCustLedgEntry.SetRange(Unapplied, false);
        if DtldCustLedgEntry.FindSet() then
            repeat
                if DtldCustLedgEntry."Cust. Ledger Entry No." = DtldCustLedgEntry."Applied Cust. Ledger Entry No." then begin
                    DtldCustLedgEntry2.SetCurrentKey("Applied Cust. Ledger Entry No.", "Entry Type");
                    DtldCustLedgEntry2.SetRange("Applied Cust. Ledger Entry No.", DtldCustLedgEntry."Applied Cust. Ledger Entry No.");
                    DtldCustLedgEntry2.SetRange("Entry Type", DtldCustLedgEntry2."Entry Type"::Application);
                    DtldCustLedgEntry2.SetRange(Unapplied, false);
                    if DtldCustLedgEntry2.FindSet() then
                        repeat
                            if DtldCustLedgEntry2."Cust. Ledger Entry No." <> DtldCustLedgEntry2."Applied Cust. Ledger Entry No." then begin
                                CustLedgEntry2.SetRange("Entry No.", DtldCustLedgEntry2."Cust. Ledger Entry No.");
                                if CustLedgEntry2.FindFirst() then begin
                                    TempAppliedCustLedgEntry := CustLedgEntry2;
                                    TempAppliedCustLedgEntry.Insert();
                                end;
                            end;
                        until DtldCustLedgEntry2.Next() = 0;
                end else begin
                    CustLedgEntry2.SetRange("Entry No.", DtldCustLedgEntry."Applied Cust. Ledger Entry No.");
                    if CustLedgEntry2.FindFirst() then begin
                        TempAppliedCustLedgEntry := CustLedgEntry2;
                        TempAppliedCustLedgEntry.Insert();
                    end;
                end;
            until DtldCustLedgEntry.Next() = 0;
    end;

    local procedure FilterVATEntryOnCustLedgEntry(var VATEntry: Record "VAT Entry"; CustLedgEntry: Record "Cust. Ledger Entry")
    begin
        VATEntry.Reset();
        VATEntry.SetCurrentKey("Transaction No.");
        VATEntry.SetRange("Transaction No.", CustLedgEntry."Transaction No.");
        VATEntry.SetRange("Document No.", CustLedgEntry."Document No.");
        VATEntry.SetRange(Type, VATEntry.Type::Sale);
    end;

    local procedure GetVendLedgEntryNo(VATEntry: Record "VAT Entry"): Integer
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetCurrentKey("Transaction No.");
        VendorLedgerEntry.SetRange("Transaction No.", VATEntry."Transaction No.");
        VendorLedgerEntry.SetRange("Document No.", VATEntry."Document No.");
        if VendorLedgerEntry.FindFirst() then
            exit(VendorLedgerEntry."Entry No.");
    end;

    local procedure FindAppliedVendLedgEntries(VendLedgEntry: Record "Vendor Ledger Entry"; var TempAppliedVendLedgEntry: Record "Vendor Ledger Entry" temporary)
    var
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        DtldVendLedgEntry2: Record "Detailed Vendor Ledg. Entry";
        VendLedgEntry2: Record "Vendor Ledger Entry";
    begin
        TempAppliedVendLedgEntry.Reset();
        TempAppliedVendLedgEntry.DeleteAll();

        DtldVendLedgEntry.SetCurrentKey("Vendor Ledger Entry No.");
        DtldVendLedgEntry.SetRange("Vendor Ledger Entry No.", VendLedgEntry."Entry No.");
        DtldVendLedgEntry.SetRange(Unapplied, false);
        if DtldVendLedgEntry.FindSet() then
            repeat
                if DtldVendLedgEntry."Vendor Ledger Entry No." = DtldVendLedgEntry."Applied Vend. Ledger Entry No." then begin
                    DtldVendLedgEntry2.SetCurrentKey("Applied Vend. Ledger Entry No.", "Entry Type");
                    DtldVendLedgEntry2.SetRange("Applied Vend. Ledger Entry No.", DtldVendLedgEntry."Applied Vend. Ledger Entry No.");
                    DtldVendLedgEntry2.SetRange("Entry Type", DtldVendLedgEntry2."Entry Type"::Application);
                    DtldVendLedgEntry2.SetRange(Unapplied, false);
                    if DtldVendLedgEntry2.FindSet() then
                        repeat
                            if DtldVendLedgEntry2."Vendor Ledger Entry No." <> DtldVendLedgEntry2."Applied Vend. Ledger Entry No." then begin
                                VendLedgEntry2.SetRange("Entry No.", DtldVendLedgEntry2."Vendor Ledger Entry No.");
                                if VendLedgEntry2.FindFirst() then begin
                                    TempAppliedVendLedgEntry := VendLedgEntry2;
                                    TempAppliedVendLedgEntry.Insert();
                                end;
                            end;
                        until DtldVendLedgEntry2.Next() = 0;
                end else begin
                    VendLedgEntry2.SetRange("Entry No.", DtldVendLedgEntry."Applied Vend. Ledger Entry No.");
                    if VendLedgEntry2.FindFirst() then begin
                        TempAppliedVendLedgEntry := VendLedgEntry2;
                        TempAppliedVendLedgEntry.Insert();
                    end;
                end;
            until DtldVendLedgEntry.Next() = 0;
    end;

    local procedure FilterVATEntryOnVendLedgEntry(var VATEntry: Record "VAT Entry"; VendLedgEntry: Record "Vendor Ledger Entry")
    begin
        VATEntry.Reset();
        VATEntry.SetCurrentKey("Transaction No.");
        VATEntry.SetRange("Transaction No.", VendLedgEntry."Transaction No.");
        VATEntry.SetRange("Document No.", VendLedgEntry."Document No.");
        VATEntry.SetRange(Type, VATEntry.Type::Purchase);
    end;

    local procedure DocumentHasApplications(VATEntry: Record "VAT Entry"; ServiceDeclarationHeader: Record "Service Declaration Header"): Boolean
    begin
        case VATEntry.Type of
            VATEntry.Type::Purchase:
                exit(DocumentHasVendApplications(VATEntry, ServiceDeclarationHeader));
            VATEntry.Type::Sale:
                exit(DocumentHasCustApplications(VATEntry, ServiceDeclarationHeader));
        end;
    end;

    local procedure DocumentHasVendApplications(VATEntry: Record "VAT Entry"; ServiceDeclarationHeader: Record "Service Declaration Header"): Boolean
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        DetailedVendorLedgEntry.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type", "Posting Date");
        DetailedVendorLedgEntry.SetRange("Vendor Ledger Entry No.", GetVendLedgEntryNo(VATEntry));
        DetailedVendorLedgEntry.SetFilter("Posting Date", '..%1', ServiceDeclarationHeader."Ending Date");
        DetailedVendorLedgEntry.SetFilter("Document Type", '%1|%2', DetailedVendorLedgEntry."Document Type"::"Credit Memo", DetailedVendorLedgEntry."Document Type"::Invoice);
        DetailedVendorLedgEntry.SetRange("Entry Type", DetailedVendorLedgEntry."Entry Type"::Application);
        DetailedVendorLedgEntry.SetRange(Unapplied, false);
        exit(not DetailedVendorLedgEntry.IsEmpty);
    end;

    local procedure DocumentHasCustApplications(VATEntry: Record "VAT Entry"; ServiceDeclarationHeader: Record "Service Declaration Header"): Boolean
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        DetailedCustLedgEntry.SetCurrentKey("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
        DetailedCustLedgEntry.SetRange("Cust. Ledger Entry No.", GetCustLedgEntryNo(VATEntry));
        DetailedCustLedgEntry.SetFilter("Posting Date", '..%1', ServiceDeclarationHeader."Ending Date");
        DetailedCustLedgEntry.SetFilter("Document Type", '%1|%2', DetailedCustLedgEntry."Document Type"::"Credit Memo", DetailedCustLedgEntry."Document Type"::Invoice);
        DetailedCustLedgEntry.SetRange("Entry Type", DetailedCustLedgEntry."Entry Type"::Application);
        DetailedCustLedgEntry.SetRange(Unapplied, false);
        exit(not DetailedCustLedgEntry.IsEmpty);
    end;

    local procedure InsertEUServiceLine(VATEntry: Record "VAT Entry"; ServiceDeclarationHeader: Record "Service Declaration Header")
    var
        ServiceDeclarationLine, ServiceDeclarationLine2 : Record "Service Declaration Line";
        LineNo: Integer;
        HasApplications: Boolean;
    begin
        HasApplications := DocumentHasApplications(VATEntry, ServiceDeclarationHeader);

        ServiceDeclarationLine2.SetRange("Service Declaration No.", ServiceDeclarationHeader."No.");
        ServiceDeclarationLine2.SetRange("Document No.", VATEntry."Document No.");
        if not HasApplications then
            ServiceDeclarationLine2.SetRange("Service Tariff No.", VATEntry."Service Tariff No.");
        if not ServiceDeclarationLine2.FindFirst() then begin
            LineNo := 10000;
            ServiceDeclarationLine.Reset();
            ServiceDeclarationLine.SetRange("Service Declaration No.", ServiceDeclarationHeader."No.");
            if ServiceDeclarationLine.FindLast() then
                LineNo += ServiceDeclarationLine."Line No.";

            ServiceDeclarationLine.Init();
            ServiceDeclarationLine."Service Declaration No." := ServiceDeclarationHeader."No.";
            ServiceDeclarationLine."Line No." := LineNo;
            ServiceDeclarationLine."Source Entry No." := VATEntry."Entry No.";
            ServiceDeclarationLine.ValidateSourceEntryNo(ServiceDeclarationLine."Source Entry No.");
            if not HasApplications then
                ServiceDeclarationLine.Amount := GetVATEntryAmount(VATEntry)
            else
                ServiceDeclarationLine.Amount -= GetAmountSign(ServiceDeclarationLine.Amount) * Abs(NonEUServiceLineAmount(ServiceDeclarationHeader.Type, ServiceDeclarationLine."Document No."));

            if ServiceDeclarationHeader."Corrective Entry" then begin
                ServiceDeclarationLine."Custom Office No." := CopyStr(ServiceDeclarationHeader."Customs Office No.", 1, MaxStrLen(ServiceDeclarationLine."Custom Office No."));
                ServiceDeclarationLine.Validate("Corrected Service Declaration No.", ServiceDeclarationHeader."Corrected Serv. Decl. No.");
                ServiceDeclarationLine."Corrective entry" := true;
                ServiceDeclarationLine.Amount := Abs(ServiceDeclarationLine.Amount);
            end;

            if (ServiceDeclarationLine.Amount <> 0) or ServiceDeclarationHeader."Corrective Entry" then
                ServiceDeclarationLine.Insert();
        end else
            if not HasApplications then begin
                ServiceDeclarationLine2.Amount += GetVATEntryAmount(VATEntry);
                ServiceDeclarationLine2.Modify();
            end
    end;

    local procedure NonEUServiceLineAmount(BatchType: Enum "Serv. Decl. Report Type IT"; DocumentNo: Code[20]): Decimal
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetRange("Document No.", DocumentNo);
        VATEntry.SetRange("EU Service", false);
        case BatchType of
            BatchType::Purchases:
                VATEntry.SetRange(Type, VATEntry.Type::Purchase);
            BatchType::Sales:
                VATEntry.SetRange(Type, VATEntry.Type::Sale);
        end;
        VATEntry.CalcSums(Base);
        exit(VATEntry.Base);
    end;

    local procedure GetVATEntryAmount(VATEntry: Record "VAT Entry"): Decimal
    begin
        exit(VATEntry.Base + VATEntry."Nondeductible Base");
    end;

    local procedure GetAmountSign(Amount: Decimal): Integer
    begin
        if Amount > 0 then
            exit(1);
        exit(-1);
    end;
}
