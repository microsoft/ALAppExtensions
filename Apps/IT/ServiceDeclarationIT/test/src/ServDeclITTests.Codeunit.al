codeunit 144112 "Serv. Decl. IT Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Service Declaration IT]
        IsInitialized := false;
    end;

    var
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryServDecl: Codeunit "Library - IT Serv. Declaration";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        ServDeclMgtIT: Codeunit "Service Declaration Mgt. IT";
        IsInitialized: Boolean;
        Periodicity: Option Month,Quarter;
        Type: Option Purchase,Sales;
        FileNo: Code[10];
        ValidationErr: Label '%1 must be %2 in %3.', Comment = '%1 = FieldCaption(Quantity),%2 = SalesLine.Quantity,%3 = TableCaption(SalesShipmentLine).';
        LineNotExistErr: Label 'Service Declaration Lines incorrectly created.';
        DataExchFileContentMissingErr: Label 'Data Exch File Content must not be empty';
        ServDeclFileOutputErr: Label 'Service Declaration has exported incorrectly to file output.';
        EUROXLbl: Label 'EUROX', Locked = true;
        DataExchangePurchaseXMLTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="SERVDECLITP-2023" Name="Service declaration purchase" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="12214" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="15"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Line No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Source Currency Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Document No." Show="false" DataType="0" Length="15" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Document Date" Show="false" DataType="0" Length="6" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Service Tariff No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Transport Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Payment Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="15" Name="Country/Region of Payment Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="5024" Name="" KeyIndex="2" MappingCodeunit="1269" PostMappingCodeunit="12215"><DataExchFieldMapping ColumnNo="1" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="12214" /><DataExchFieldMapping ColumnNo="3" FieldID="12215" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" UseDefaultValue="true" DefaultValue="3" /><DataExchFieldMapping ColumnNo="5" FieldID="12216" /><DataExchFieldMapping ColumnNo="6" FieldID="6" /><DataExchFieldMapping ColumnNo="7" FieldID="15" /><DataExchFieldMapping ColumnNo="8" FieldID="12220" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="12221" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="10" FieldID="12222" Optional="true" /><DataExchFieldMapping ColumnNo="11" FieldID="12218" /><DataExchFieldMapping ColumnNo="12" FieldID="12224" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="12225" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="12226" TransformationRule="LOOKUPPAYMENTMETHOD"><TransformationRules><Code>LOOKUPPAYMENTMETHOD</Code><Description>Lookup Payment Method</Description><TransformationType>13</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>289</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>12173</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="15" FieldID="12227" /></DataExchMapping></DataExchLineDef></DataExchDef></root>', Locked = true;
        DataExchangeSaleXMLTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="SERVDECLITS-2023" Name="Service declaration sale" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="12214" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="14"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Line No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Document No." Show="false" DataType="0" Length="15" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Document Date" Show="false" DataType="0" Length="6" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Service Tariff No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Transport Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Payment Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Country/Region of Payment Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="5024" Name="" KeyIndex="2" MappingCodeunit="1269" PostMappingCodeunit="12215"><DataExchFieldMapping ColumnNo="1" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="12214" /><DataExchFieldMapping ColumnNo="3" FieldID="12215" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" UseDefaultValue="true" DefaultValue="3" /><DataExchFieldMapping ColumnNo="5" FieldID="12216" /><DataExchFieldMapping ColumnNo="6" FieldID="6" /><DataExchFieldMapping ColumnNo="7" FieldID="15" /><DataExchFieldMapping ColumnNo="8" FieldID="12220" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="32" /><DataExchFieldMapping ColumnNo="10" FieldID="12218" /><DataExchFieldMapping ColumnNo="11" FieldID="12224" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="12" FieldID="12225" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="12226" TransformationRule="LOOKUPPAYMENTMETHOD"><TransformationRules><Code>LOOKUPPAYMENTMETHOD</Code><Description>Lookup Payment Method</Description><TransformationType>13</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>289</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>12173</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="12227" /></DataExchMapping></DataExchLineDef></DataExchDef></root>', Locked = true;
        DataExchangePurchaseCorrectionXMLTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="SERVDECLITPC-2023" Name="Service declaration purchase correction" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="12214" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="19"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Line No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Custom Office No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Reference Period" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Reference File Disk No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Source Currency Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Document No." Show="false" DataType="0" Length="15" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="15" Name="Document Date" Show="false" DataType="0" Length="6" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="16" Name="Service Tariff No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="17" Name="Transport Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="18" Name="Payment Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="19" Name="Country/Region of Payment Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="5024" Name="" KeyIndex="2" MappingCodeunit="1269" PostMappingCodeunit="12215"><DataExchFieldMapping ColumnNo="1" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="12214" /><DataExchFieldMapping ColumnNo="3" FieldID="12215" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" UseDefaultValue="true" DefaultValue="4" /><DataExchFieldMapping ColumnNo="5" FieldID="12216" /><DataExchFieldMapping ColumnNo="6" FieldID="12229" /><DataExchFieldMapping ColumnNo="7" FieldID="12232" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First two characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="8" FieldID="12233" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="12234" /><DataExchFieldMapping ColumnNo="10" FieldID="6" /><DataExchFieldMapping ColumnNo="11" FieldID="15" /><DataExchFieldMapping ColumnNo="12" FieldID="12220" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="12221" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="32" /><DataExchFieldMapping ColumnNo="15" FieldID="12218" /><DataExchFieldMapping ColumnNo="16" FieldID="12224" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="17" FieldID="12225" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="18" FieldID="12226" TransformationRule="LOOKUPPAYMENTMETHOD"><TransformationRules><Code>LOOKUPPAYMENTMETHOD</Code><Description>Lookup Payment Method</Description><TransformationType>13</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>289</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>12173</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="19" FieldID="12227" /></DataExchMapping></DataExchLineDef></DataExchDef></root>', Locked = true;
        DataExchangeSaleCorrectionXMLTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="SERVDECLITSC-2023" Name="Service declaration sale correction" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="12214" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="18"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Line No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Custom Office No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Reference Period" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Reference File Disk No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Document No." Show="false" DataType="0" Length="15" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Document Date" Show="false" DataType="0" Length="6" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="15" Name="Service Tariff No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="16" Name="Transport Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="17" Name="Payment Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="18" Name="Country/Region of Payment Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="5024" Name="" KeyIndex="2" MappingCodeunit="1269" PostMappingCodeunit="12215"><DataExchFieldMapping ColumnNo="1" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="12214" /><DataExchFieldMapping ColumnNo="3" FieldID="12215" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" UseDefaultValue="true" DefaultValue="4" /><DataExchFieldMapping ColumnNo="5" FieldID="12216" /><DataExchFieldMapping ColumnNo="6" FieldID="12229" /><DataExchFieldMapping ColumnNo="7" FieldID="12232" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First two characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="8" FieldID="12233" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="12234" /><DataExchFieldMapping ColumnNo="10" FieldID="6" /><DataExchFieldMapping ColumnNo="11" FieldID="15" /><DataExchFieldMapping ColumnNo="12" FieldID="12220" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="32" /><DataExchFieldMapping ColumnNo="14" FieldID="12218" /><DataExchFieldMapping ColumnNo="15" FieldID="12224" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="16" FieldID="12225" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="17" FieldID="12226" TransformationRule="LOOKUPPAYMENTMETHOD"><TransformationRules><Code>LOOKUPPAYMENTMETHOD</Code><Description>Lookup Payment Method</Description><TransformationType>13</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>289</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>12173</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="18" FieldID="12227" /></DataExchMapping></DataExchLineDef></DataExchDef></root>', Locked = true;
        ServDeclDataExchPurchaseCodeLbl: Label 'SERVDECLITP-2023', Locked = true;
        ServDeclDataExchSaleCodeLbl: Label 'SERVDECLITS-2023', Locked = true;
        ServDeclDataExchPurchaseCorrectionCodeLbl: Label 'SERVDECLITPC-2023', Locked = true;
        ServDeclDataExchSaleCorrectionCodeLbl: Label 'SERVDECLITSC-2023', Locked = true;
        TaxCategoryPLbl: Label 'P', Locked = true;

    [Test]
    [Scope('OnPrem')]
    procedure ServiceEUVATEntryForPurchase()
    var
        VATEntry: Record "VAT Entry";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO] Check VAT Entry after posting Purchase Order.

        // [GIVEN] Posted Purchase Order
        Initialize();
        DocumentNo := LibraryServDecl.CreateAndPostPurchaseOrder(PurchaseLine, WorkDate());
        // [THEN] Verify Item Ledger Entry
        VerifyVATEntry(VATEntry.Type::Purchase, VATEntry."Document Type"::Invoice, DocumentNo, LibraryServDecl.GetCountryRegionCode(), PurchaseLine."Amount Including VAT" - PurchaseLine.Amount);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ServiceDeclarationLineForPurchase()
    var
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO] Check Service Declaration Line for posted Purchase Order.

        // [GIVEN] Posted Purchase Order
        Initialize();
        DocumentNo := LibraryServDecl.CreateAndPostPurchaseOrderWithInvoice(PurchaseLine, WorkDate());

        // [WHEN] Get Service Declaration Line for Purchase Order
        // [THEN] Verify Service Declaration Line
        CreateAndVerifyServDeclLine(DocumentNo, PurchaseLine."Service Tariff No.", PurchaseLine.Amount, Periodicity::Month, Type::Purchase);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ServiceEUVATEntryForSales()
    var
        VATEntry: Record "VAT Entry";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Sales] 
        // [SCENARIO] Check VAT Entry after posting Sales Order.

        // [GIVEN] Create and Post Sales Order
        Initialize();
        DocumentNo := LibraryServDecl.CreateAndPostSalesOrder(SalesLine, WorkDate());

        // [THEN] Verify VAT Entry
        VerifyVATEntry(VATEntry.Type::Sale, VATEntry."Document Type"::Invoice, DocumentNo, LibraryServDecl.GetCountryRegionCode(), -(SalesLine."Amount Including VAT" - SalesLine.Amount));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ServiceDeclarationLineForSales()
    var
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO] Check Service Declaration Line for posted Sales Order.

        // [GIVEN] Create and Post Sales Order
        Initialize();
        DocumentNo := LibraryServDecl.CreateAndPostSalesOrderWithInvoice(SalesLine, WorkDate());

        // [WHEN] Get Service Declaration Lines for Sales Order
        // [THEN] Verify Service Declaration Line
        CreateAndVerifyServDeclLine(DocumentNo, SalesLine."Service Tariff No.", -SalesLine.Amount, Periodicity::Month, Type::Sales);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ServiceDeclarationWithPurchaseOrder()
    var
        PurchaseLine: Record "Purchase Line";
        NewPostingDate: Date;
        ServDeclNo1: Code[20];
        ServDeclNo2: Code[20];
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Purchase] 
        // [SCENARIO] Check Service Declaration Entries after Posting Purchase Order and Get Entries with New Posting Date.

        // [GIVEN] Create Purchase Order with New Posting Date and Create New Service Declaration with difference with 1 Year.
        Initialize();

        NewPostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        WorkDate(NewPostingDate);
        DocumentNo := LibraryServDecl.CreateAndPostPurchaseOrderWithInvoice(PurchaseLine, NewPostingDate);
        WorkDate(Today);

        // [GIVEN] Two Service Declarations for the same period
        Commit();  // Commit is required to commit the posted entries.
        FileNo := IncStr(FileNo);
        CreateServDeclAndSuggestLines(NewPostingDate, ServDeclNo1, Periodicity::Month, Type::Purchase, false, FileNo);
        FileNo := IncStr(FileNo);
        CreateServDeclAndSuggestLines(NewPostingDate, ServDeclNo2, Periodicity::Month, Type::Purchase, false, FileNo);

        Commit();
        // [WHEN] Get Entries from Service Declaration pages for two Reports with the same period 
        // [THEN] Verify that Entry values on Service Declaration Page match Purchase Line values
        VerifyServDeclLine(DocumentNo, ServDeclNo1, LibraryServDecl.GetCountryRegionCode(), PurchaseLine."Service Tariff No.", PurchaseLine.Amount);

        // [THEN] No Entries suggested in a second Service Declaration
        VerifyServDeclLineExist(ServDeclNo2, PurchaseLine."No.", false);

        LibraryServDecl.DeleteServDecl(ServDeclNo1);
        LibraryServDecl.DeleteServDecl(ServDeclNo2);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ServiceDeclarationPurchaseIsEmptyAfterCorrectionInSamePeriod()
    var
        PurchaseLine: Record "Purchase Line";
        InvoiceDate: Date;
        ServDeclNo, InvoiceNo : Code[20];
    begin
        // [FEATURE] [Service Declaration IT] [File Validation]
        // [SCENARIO] Purchase order is cancelled within the same period
        // [GIVEN] Posted Purchase Order and Credit Memo for service declaration in same period
        Initialize();
        InvoiceDate := CalcDate('<5Y>', WorkDate());
        WorkDate(InvoiceDate);
        InvoiceNo := LibraryServDecl.CreateAndPostPurchaseOrderWithInvoice(PurchaseLine, InvoiceDate);
        CreateAndPostCorrectivePurchCrMemo(InvoiceNo, InvoiceDate);
        WorkDate(Today);
        FileNo := IncStr(FileNo);
        CreateServDeclAndSuggestLines(InvoiceDate, ServDeclNo, Periodicity::Month, Type::Purchase, true, FileNo);
        Commit();

        // [THEN] No Entries suggested in a Service Declaration
        VerifyServDeclLineExist(ServDeclNo, InvoiceNo, false);

        LibraryServDecl.DeleteServDecl(ServDeclNo);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ServiceDeclarationPurchaseIsNotEmptyAfterCorrectionInNextPeriod()
    var
        PurchaseLine: Record "Purchase Line";
        InvoiceDate: Date;
        ServDeclNo, InvoiceNo : Code[20];
    begin
        // [FEATURE] [Service Declaration IT] [File Validation]
        // [SCENARIO] Purchase order is cancelled within the same period
        // [GIVEN] Posted Purchase Order and Credit Memo for service declaration in same period
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        WorkDate(InvoiceDate);
        InvoiceNo := LibraryServDecl.CreateAndPostPurchaseOrderWithInvoice(PurchaseLine, InvoiceDate);
        CreateAndPostCorrectivePurchCrMemo(InvoiceNo, CalcDate('<+1M>', InvoiceDate));
        WorkDate(Today);
        FileNo := IncStr(FileNo);
        CreateServDeclAndSuggestLines(CalcDate('<+1M>', InvoiceDate), ServDeclNo, Periodicity::Month, Type::Purchase, true, FileNo);
        Commit();

        // [THEN] One entries suggested in a Service Declaration
        VerifyServDeclLineExist(ServDeclNo, InvoiceNo, true);

        LibraryServDecl.DeleteServDecl(ServDeclNo);
    end;


    [Test]
    [Scope('OnPrem')]
    procedure ServiceDeclarationSaleIsEmptyAfterCorrectionInSamePeriod()
    var
        SalesLine: Record "Sales Line";
        InvoiceDate: Date;
        ServDeclNo, InvoiceNo : Code[20];
    begin
        // [FEATURE] [Service Declaration IT] [File Validation]
        // [SCENARIO] Purchase order is cancelled within the same period
        // [GIVEN] Posted Purchase Order and Credit Memo for service declaration in same period
        Initialize();
        InvoiceDate := CalcDate('<5Y>', WorkDate());
        WorkDate(InvoiceDate);
        InvoiceNo := LibraryServDecl.CreateAndPostSalesOrderWithInvoice(SalesLine, InvoiceDate);
        CreateAndPostCorrectiveSalesCrMemo(InvoiceNo, InvoiceDate);
        WorkDate(Today);
        FileNo := IncStr(FileNo);
        CreateServDeclAndSuggestLines(InvoiceDate, ServDeclNo, Periodicity::Month, Type::Sales, true, FileNo);
        Commit();

        // [THEN] No Entries suggested in a Service Declaration
        VerifyServDeclLineExist(ServDeclNo, InvoiceNo, false);

        LibraryServDecl.DeleteServDecl(ServDeclNo);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ServiceDeclarationSaleIsNotEmptyAfterCorrectionInNextPeriod()
    var
        SalesLine: Record "Sales Line";
        InvoiceDate: Date;
        ServDeclNo, InvoiceNo : Code[20];
    begin
        // [FEATURE] [Service Declaration IT] [File Validation]
        // [SCENARIO] Purchase order is cancelled within the same period
        // [GIVEN] Posted Purchase Order and Credit Memo for service declaration in same period
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        WorkDate(InvoiceDate);
        InvoiceNo := LibraryServDecl.CreateAndPostSalesOrderWithInvoice(SalesLine, InvoiceDate);
        CreateAndPostCorrectiveSalesCrMemo(InvoiceNo, CalcDate('<+1M>', InvoiceDate));
        WorkDate(Today);
        FileNo := IncStr(FileNo);
        CreateServDeclAndSuggestLines(CalcDate('<+1M>', InvoiceDate), ServDeclNo, Periodicity::Month, Type::Sales, true, FileNo);
        Commit();

        // [THEN] One entries suggested in a Service Declaration
        VerifyServDeclLineExist(ServDeclNo, InvoiceNo, true);

        LibraryServDecl.DeleteServDecl(ServDeclNo);
    end;

    [Test]
    procedure E2EServDeclReportITFileCreationSale()
    var
        SalesLine: Record "Sales Line";
        ServDeclPage: TestPage "Service Declaration";
        InvoiceDate: Date;
        ServDeclNo: Code[20];
    begin
        // [FEATURE] [Service Declaration IT] [File Validation]
        // [SCENARIO] End to end file creation
        // [GIVEN] Posted Sales Order for service declaration
        Initialize();
        InvoiceDate := CalcDate('<6Y>');
        LibraryServDecl.CreateAndPostSalesOrderWithInvoice(SalesLine, InvoiceDate);
        FileNo := IncStr(FileNo);
        CreateServDeclAndSuggestLines(InvoiceDate, ServDeclNo, Periodicity::Month, Type::Sales, false, FileNo);
        Commit();

        // [GIVEN] A Service Declaration
        ServDeclPage.OpenEdit();
        ServDeclPage.Filter.SetFilter("No.", ServDeclNo);
        ValidateMissingFields(ServDeclPage);

        // [WHEN] Running Create File
        ServDeclPage.CreateFile.Invoke();

        // [THEN] Check file content for sales monthly invoice 
        CheckFileContentForNormalReporting(ServDeclPage, 'C', 'M');
        ServDeclPage.Close();

        LibraryServDecl.DeleteServDecl(ServDeclNo);
    end;

    [Test]
    procedure E2EServDeclReportITFileCreationPurchase()
    var
        PurchaseLine: Record "Purchase Line";
        ServDeclPage: TestPage "Service Declaration";
        InvoiceDate: Date;
        ServDeclNo: Code[20];
    begin
        // [FEATURE] [Service Declaration IT] [File Validation]
        // [SCENARIO] End to end file creation
        // [GIVEN] Posted Purchase Order for service declaration
        // [GIVEN] Report Template and Batch        
        Initialize();
        InvoiceDate := CalcDate('<6Y>');
        LibraryServDecl.CreateAndPostPurchaseOrderWithInvoice(PurchaseLine, InvoiceDate);
        FileNo := IncStr(FileNo);
        CreateServDeclAndSuggestLines(InvoiceDate, ServDeclNo, Periodicity::Month, Type::Purchase, false, FileNo);
        Commit();

        // [GIVEN] A Service Declaration
        ServDeclPage.OpenEdit();
        ServDeclPage.Filter.SetFilter("No.", ServDeclNo);
        ValidateMissingFields(ServDeclPage);

        // [WHEN] Running Create File
        ServDeclPage.CreateFile.Invoke();

        // [THEN] Check file content for purchase monthly invoice 
        CheckFileContentForNormalReporting(ServDeclPage, 'A', 'M');
        ServDeclPage.Close();

        LibraryServDecl.DeleteServDecl(ServDeclNo);
    end;

    [Test]
    procedure E2EServDeclITFileCreationSaleCorrection()
    var
        SalesLine: Record "Sales Line";
        CustomOffice: Record "Customs Office";
        ServDeclPage: TestPage "Service Declaration";
        InvoiceDate: Date;
        ServDeclNo1, ServDeclNo2, InvoiceNo : Code[20];
    begin
        // [FEATURE] [Service Declaration IT] [File Validation]
        // [SCENARIO] End to end file creation
        // [GIVEN] Posted Sales Order for Service Declaration

        Initialize();
        InvoiceDate := CalcDate('<7Y>');
        WorkDate(InvoiceDate);
        InvoiceNo := LibraryServDecl.CreateAndPostSalesOrderWithInvoice(SalesLine, InvoiceDate);

        FileNo := IncStr(FileNo);
        CreateServDeclAndSuggestLines(InvoiceDate, ServDeclNo1, Periodicity::Month, Type::Sales, false, FileNo);
        Commit();

        // [GIVEN] A Service Declaration
        ServDeclPage.OpenEdit();
        ServDeclPage.Filter.SetFilter("No.", ServDeclNo1);
        ValidateMissingFields(ServDeclPage);

        // [WHEN] Running Create File
        ServDeclPage.CreateFile.Invoke();

        FileNo := IncStr(FileNo);

        CreateAndPostCorrectiveSalesCrMemo(InvoiceNo, CalcDate('<+1M>', InvoiceDate));
        WorkDate(Today);
        FileNo := IncStr(FileNo);
        CreateServDeclAndSuggestLines(CalcDate('<+1M>', InvoiceDate), ServDeclNo2, Periodicity::Month, Type::Sales, true, FileNo);
        Commit();

        // [GIVEN] A Service Declaration

        ServDeclPage.Filter.SetFilter("No.", ServDeclNo2);
        ValidateMissingFields(ServDeclPage);

        CustomOffice.Init();
        CustomOffice.Code := 'CO1';
        if CustomOffice.Insert() then;

        ServDeclPage.Lines."Custom Office No.".SetValue(CustomOffice.Code);
        ServDeclPage.Lines."Corrected Service Declaration No.".SetValue(ServDeclNo1);
        ServDeclPage.Lines."Corrected Document No.".SetValue(InvoiceNo);
        ServDeclPage.Lines."Progressive No.".SetValue('12345');

        // [WHEN] Running Create File
        ServDeclPage.CreateFile.Invoke();

        // [THEN] Check file content for sales monthly correction
        CheckFileContentForCorrectionReporting(ServDeclPage, 'C', 'M');
        ServDeclPage.Close();

        LibraryServDecl.DeleteServDecl(ServDeclNo1);
        LibraryServDecl.DeleteServDecl(ServDeclNo2);
    end;

    [Test]
    procedure E2EServDeclITFileCreationPurchaseCorrection()
    var
        CustomOffice: Record "Customs Office";
        PurchaseLine: Record "Purchase Line";
        ServDeclPage: TestPage "Service Declaration";
        InvoiceDate: Date;
        ServDeclNo1, ServDeclNo2, InvoiceNo : Code[20];
    begin
        // [FEATURE] [Service Declaration IT] [File Validation]
        // [SCENARIO] End to end file creation
        // [GIVEN] Posted Sales Order for Service Declaration

        Initialize();
        InvoiceDate := CalcDate('<7Y>');
        WorkDate(InvoiceDate);
        InvoiceNo := LibraryServDecl.CreateAndPostPurchaseOrderWithInvoice(PurchaseLine, InvoiceDate);

        FileNo := IncStr(FileNo);
        CreateServDeclAndSuggestLines(InvoiceDate, ServDeclNo1, Periodicity::Month, Type::Purchase, false, FileNo);
        Commit();

        // [GIVEN] A Service Declaration
        ServDeclPage.OpenEdit();
        ServDeclPage.Filter.SetFilter("No.", ServDeclNo1);
        ValidateMissingFields(ServDeclPage);

        // [WHEN] Running Create File
        ServDeclPage.CreateFile.Invoke();

        FileNo := IncStr(FileNo);

        CreateAndPostCorrectivePurchCrMemo(InvoiceNo, CalcDate('<+1M>', InvoiceDate));
        WorkDate(Today);
        FileNo := IncStr(FileNo);
        CreateServDeclAndSuggestLines(CalcDate('<+1M>', InvoiceDate), ServDeclNo2, Periodicity::Month, Type::Purchase, true, FileNo);
        Commit();

        // [GIVEN] A Service Declaration

        ServDeclPage.Filter.SetFilter("No.", ServDeclNo2);
        ValidateMissingFields(ServDeclPage);

        CustomOffice.Init();
        CustomOffice.Code := 'CO1';
        if CustomOffice.Insert() then;

        ServDeclPage.Lines."Custom Office No.".SetValue(CustomOffice.Code);
        ServDeclPage.Lines."Corrected Service Declaration No.".SetValue(ServDeclNo1);
        ServDeclPage.Lines."Corrected Document No.".SetValue(InvoiceNo);
        ServDeclPage.Lines."Progressive No.".SetValue('12345');
        ServDeclPage.Lines.Amount.SetValue(123.45);

        // [WHEN] Running Create File
        ServDeclPage.CreateFile.Invoke();

        // [THEN] Check file content for sales monthly correction
        CheckFileContentForCorrectionReporting(ServDeclPage, 'A', 'M');
        ServDeclPage.Close();

        LibraryServDecl.DeleteServDecl(ServDeclNo1);
        LibraryServDecl.DeleteServDecl(ServDeclNo2);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ServiceDeclarationshowCorrectAmount()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EUServiceVATPostingSetup: Record "VAT Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        EUServiceVATProductPostingGroup: Record "VAT Product Posting Group";
        ServiceTariffNumber: Record "Service Tariff Number";
        InvoiceDate: Date;
        GLAccountCode, ServDeclNo, InvoiceNo, CreditMemoNo, VendorNo : Code[20];
    begin
        // [SCENARIO 555216] The Service Declaration suggest an Incorrect amount for both Purchase / Sales Invoice and Credit Memo in the same month in the Italian version.
        Initialize();

        // [GIVEN] Create VAT Business Posting Group
        LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);

        // [GIVEN] Create Non EU VAT Product Posting Group
        LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);

        // [GIVEN] Create EU Service VAT Product Posting Group
        LibraryERM.CreateVATProductPostingGroup(EUServiceVATProductPostingGroup);

        // [GIVEN] Create VAT Posting Setup with VAT Calculation Type as Reverse Charge VAT and Deductible as 100%
        LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, VATProductPostingGroup.Code);
        VATPostingSetup.Validate("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT");
        VATPostingSetup.Validate("VAT %", LibraryRandom.RandIntInRange(1, 25));
        VATPostingSetup.Validate("Purchase VAT Account", LibraryERM.CreateGLAccountNo());
        VATPostingSetup.Validate("Reverse Chrg. VAT Acc.", LibraryERM.CreateGLAccountNo());
        VATPostingSetup.Validate("Tax Category", TaxCategoryPLbl);
        VATPostingSetup."Deductible %" := 100;
        VATPostingSetup.Modify(true);

        // [GIVEN] Create VAT Posting Setup with EU Service, VAT Calculation Type as Reverse Charge VAT  and deductible as 100%
        LibraryERM.CreateVATPostingSetup(EUServiceVATPostingSetup, VATBusinessPostingGroup.Code, EUServiceVATProductPostingGroup.Code);
        EUServiceVATPostingSetup.Validate("VAT Calculation Type", EUServiceVATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT");
        EUServiceVATPostingSetup.Validate("VAT %", LibraryRandom.RandIntInRange(1, 25));
        EUServiceVATPostingSetup.Validate("Purchase VAT Account", LibraryERM.CreateGLAccountNo());
        EUServiceVATPostingSetup.Validate("Reverse Chrg. VAT Acc.", LibraryERM.CreateGLAccountNo());
        EUServiceVATPostingSetup.Validate("Tax Category", TaxCategoryPLbl);
        EUServiceVATPostingSetup."Deductible %" := 100;
        EUServiceVATPostingSetup.Validate("EU Service", true);
        EUServiceVATPostingSetup.Modify(true);

        // [GIVEN] Posted Purchase Order and Credit Memo for service declaration in same period
        InvoiceDate := CalcDate('<5Y>', WorkDate());
        WorkDate(InvoiceDate);

        // [GIVEN] Create new G/L Account
        GLAccountCode := LibraryERM.CreateGLAccountWithPurchSetup();

        // [GIVEN] Create and Post Purchase Order with two Purchase Lines, one line for EU Service and second line non EU Service
        VendorNo := LibraryServDecl.CreateVendor(LibraryServDecl.GetCountryRegionCode());
        LibraryServDecl.CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, InvoiceDate, VendorNo);
        PurchaseHeader.Validate("VAT Bus. Posting Group", VATBusinessPostingGroup.Code);
        PurchaseHeader.Modify(true);

        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccountCode, 1);
        PurchaseLine.Validate("VAT Prod. Posting Group", EUServiceVATPostingSetup."VAT Prod. Posting Group");
        ServiceTariffNumber.Init();
        ServiceTariffNumber."No." := '162534';
        if not ServiceTariffNumber.Insert() then;
        PurchaseLine.Validate("Service Tariff No.", ServiceTariffNumber."No.");
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(800, 1000, 2));
        PurchaseLine.Modify(true);

        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccountCode, 1);
        PurchaseLine.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(90, 100, 2));
        PurchaseLine.Modify(true);

        InvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [GIVEN] Create and Post Corrective Credit Memo with two lines
        CreditMemoNo := CreateAndPostMultipleLineCorrectivePurchCrMemo(InvoiceNo, InvoiceDate);

        // [WHEN] Create Service Declaration and suggest lines
        WorkDate(Today);
        FileNo := IncStr(FileNo);
        CreateServDeclAndSuggestLines(InvoiceDate, ServDeclNo, Periodicity::Month, Type::Purchase, false, FileNo);
        Commit();

        // [THEN] Verify Service Declaration Amount
        VerifyServDeclLineAmount(ServDeclNo, InvoiceNo, CreditMemoNo);

        LibraryServDecl.DeleteServDecl(ServDeclNo);
    end;

    local procedure Initialize()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        ServDeclMgt: Codeunit "Service Declaration Mgt.";
        GLSetupVATCalculation: Enum "G/L Setup VAT Calculation";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Serv. Decl. IT Tests");
        LibraryVariableStorage.Clear();
        ResetNoSeries();

        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Serv. Decl. IT Tests");
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();

        LibraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup,
            VATPostingSetup."VAT Calculation Type"::"Normal VAT", LibraryRandom.RandDecInDecimalRange(10, 25, 0));
        VATPostingSetup.Validate("EU Service", true);
        VATPostingSetup.Modify();

        LibraryERM.SetBillToSellToVATCalc(GLSetupVATCalculation::"Bill-to/Pay-to No.");

        ServDeclMgt.InsertVATReportsConfiguration();

        LibraryServDecl.CreateServDeclSetup();
        UpdateServDeclSetup();

        if FileNo = '' then
            FileNo := '000000';

        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Serv. Decl. IT Tests");
    end;

    local procedure UpdateServDeclSetup()
    var
        ServDeclSetup: Record "Service Declaration Setup";
        DataExchDef: Record "Data Exch. Def";
        TempBlob: Codeunit "Temp Blob";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
    begin
        ServDeclSetup.Get();
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
        ServDeclSetup.Validate("Data Exch. Def. S. Corr. Code", ServDeclDataExchSaleCorrectionCodeLbl);

        ServDeclSetup."Enable VAT Registration No." := true;
        ServDeclSetup."Enable Serv. Trans. Types" := false;
        ServDeclSetup."Show Serv. Decl. Overview" := false;
        ServDeclSetup.Modify();
    end;

    local procedure ResetNoSeries()
    var
        NoSeriesLine: Record "No. Series Line";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
    begin
        if VATBusinessPostingGroup.FindSet() then
            repeat
                NoSeriesLine.SetRange("No. Series Type", NoSeriesLine."No. Series Type"::Sales);
                NoSeriesLine.SetRange("Series Code", VATBusinessPostingGroup."Default Sales Operation Type");
                NoSeriesLine.ModifyAll("Last Date Used", 0D);

                NoSeriesLine.SetRange("No. Series Type", NoSeriesLine."No. Series Type"::Purchase);
                NoSeriesLine.SetRange("Series Code", VATBusinessPostingGroup."Default Purch. Operation Type");
                NoSeriesLine.ModifyAll("Last Date Used", 0D);
            until VATBusinessPostingGroup.Next() = 0;
    end;

    procedure CreateServDeclAndSuggestLines(ReportDate: Date; var ServDeclNo: Code[20]; Periodicity2: Option Month,Quarter; Type2: Option Purchase,Sales; Corrective: Boolean; FileDiskNo: Code[20])
    var
        ServDeclHeader: Record "Service Declaration Header";
    begin
        LibraryServDecl.CreateServDecl(ReportDate, ServDeclNo);
        ServDeclHeader.Get(ServDeclNo);
        if Periodicity2 = Periodicity2::Quarter then
            ServDeclHeader.Validate("Statistics Period", GetStatisticalPeriodQuarter(ReportDate));

        ServDeclHeader.Validate(Periodicity, Periodicity2);
        ServDeclHeader.Validate(Type, Type2);
        ServDeclHeader.Validate("Corrective Entry", Corrective);
        ServDeclHeader.Validate("File Disk No.", FileDiskNo);
        ServDeclHeader.Modify(true);
        InvokeSuggestLinesOnServDecl(ServDeclNo);
    end;

    procedure CreateAndVerifyServDeclLine(DocumentNo: Code[20]; ServiceTariffNo: Code[20]; Amount: Decimal; Periodicity2: Option Month,Quarter; Type2: Option Purchase,Sales)
    var
        ServDeclNo: Code[20];
    begin
        // Exercise: Run Get Entries. Take Report Date as WORKDATE
        FileNo := IncStr(FileNo);
        CreateServDeclAndSuggestLines(WorkDate(), ServDeclNo, Periodicity2, Type2, false, FileNo);
        // Verify
        VerifyServDeclLine(DocumentNo, ServDeclNo, LibraryServDecl.GetCountryRegionCode(), ServiceTariffNo, Amount);

        LibraryServDecl.DeleteServDecl(ServDeclNo);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ServiceDeclarationSumInvoiceAndCreditMemoAmount()
    var
        ServiceDeclarationLine: Record "Service Declaration Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        ItemNo: Code[20];
        DirectUnitCost: List of [Decimal];
        i: Integer;
        InvoiceDate: Date;
        ServDeclPage: TestPage "Service Declaration";
        ServDeclNo, InvoiceNo : Code[20];
    begin
        // [SCENARIO 555251] Service Declaration sums absolute values causing errors in total amount in the Italian version
        Initialize();

        // [GIVEN] Posted Purchase Order and Credit Memo for service declaration in same period
        InvoiceDate := CalcDate('<5Y>', WorkDate());
        WorkDate(InvoiceDate);

        // [GIVEN] Create and Post Purchase Order with DirectUnitCost as -300 and 1000   
        ItemNo := LibraryServDecl.CreateItem();
        DirectUnitCost.Add(-300);
        DirectUnitCost.Add(1000);
        LibraryServDecl.CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, InvoiceDate, LibraryServDecl.CreateVendor(LibraryServDecl.GetCountryRegionCode()));
        for i := 1 to DirectUnitCost.Count do begin
            LibraryServDecl.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, ItemNo);
            PurchaseLine.Validate("Direct Unit Cost", DirectUnitCost.Get(i));
            PurchaseLine.Modify();
        end;
        InvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [GIVEN] Create and Post Purchase Credit Memo with DirectUnitCost as 400
        PurchInvHeader.Get(InvoiceNo);
        LibraryServDecl.CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", InvoiceDate, PurchInvHeader."Buy-from Vendor No.");
        LibraryServDecl.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, ItemNo);
        PurchaseLine.Validate("Direct Unit Cost", 400);
        PurchaseLine.Modify();
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        // [GIVEN] Create Service Declaration
        FileNo := IncStr(FileNo);
        CreateServDeclAndSuggestLines(InvoiceDate, ServDeclNo, Periodicity::Month, Type::Purchase, false, FileNo);
        Commit();

        // [GIVEN] A Service Declaration
        ServDeclPage.OpenEdit();
        ServDeclPage.Filter.SetFilter("No.", ServDeclNo);
        ValidateMissingFields(ServDeclPage);

        // [WHEN] Running Create File
        ServDeclPage.CreateFile.Invoke();

        // [THEN] Check file content for purchase monthly invoice 
        ServiceDeclarationLine.SetRange("Service Declaration No.", ServDeclNo);
        ServiceDeclarationLine.CalcSums(Amount);
        CheckFileContentForAbsoluteSumReporting(ServDeclPage, 'A', 'M', ServiceDeclarationLine.Amount);
        ServDeclPage.Close();

        LibraryServDecl.DeleteServDecl(ServDeclNo);
    end;

    local procedure VerifyVATEntry(EntryType: Enum "General Posting Type"; DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]; CountryRegionCode: Code[10]; Amount: Decimal)
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetRange(Type, EntryType);
        VATEntry.SetRange("Document Type", DocumentType);
        VATEntry.SetRange("Document No.", DocumentNo);
        VATEntry.FindFirst();

        Assert.AreEqual(
          CountryRegionCode, VATEntry."Country/Region Code", StrSubstNo(ValidationErr,
            VATEntry.FieldCaption("Country/Region Code"), CountryRegionCode, VATEntry.TableCaption()));

        Assert.AreEqual(
          Amount, VATEntry.Amount,
          StrSubstNo(ValidationErr, VATEntry.FieldCaption(Amount), Amount, VATEntry.TableCaption()));

        Assert.AreEqual(
          true, VATEntry."EU Service",
          StrSubstNo(ValidationErr, VATEntry.FieldCaption("EU Service"), 0, VATEntry.TableCaption()));
    end;

    local procedure VerifyServDeclLine(DocumentNo: Code[20]; ServDeclNo: Code[20]; CountryRegionCode: Code[10]; ServiceTariffNo: Code[20]; Amount: Decimal)
    var
        ServDeclLine: Record "Service Declaration Line";
    begin
        LibraryServDecl.GetServDeclLine(DocumentNo, ServDeclNo, ServDeclLine);

        Assert.AreEqual(
            DocumentNo, ServDeclLine."Document No.", StrSubstNo(ValidationErr,
            ServDeclLine.FieldCaption("Document No."), DocumentNo, ServDeclLine.TableCaption()));

        Assert.AreEqual(
            ServiceTariffNo, ServDeclLine."Service Tariff No.", StrSubstNo(ValidationErr,
            ServDeclLine.FieldCaption("Service Tariff No."), ServiceTariffNo, ServDeclLine.TableCaption()));

        Assert.AreEqual(
            Amount, ServDeclLine.Amount,
            StrSubstNo(ValidationErr, ServDeclLine.FieldCaption(Amount), Amount, ServDeclLine.TableCaption()));

        Assert.AreEqual(
            CountryRegionCode, ServDeclLine."Country/Region Code", StrSubstNo(ValidationErr,
            ServDeclLine.FieldCaption("Country/Region Code"), CountryRegionCode, ServDeclLine.TableCaption()));
    end;

    local procedure VerifyServDeclLineExist(ServDeclNo: Code[20]; DocumentNo: Code[20]; MustExist: Boolean)
    var
        ServDeclLine: Record "Service Declaration Line";
    begin
        Commit();  // Commit is required to commit the posted entries.
        // Verify: Verify Service Declaration Line with No entires.
        ServDeclLine.SetFilter("Service Declaration No.", ServDeclNo);
        ServDeclLine.SetFilter("Document No.", DocumentNo);
        Assert.AreEqual(MustExist, ServDeclLine.FindFirst(), LineNotExistErr);
    end;

    local procedure VerifyServDeclLineAmount(ServDeclNo: Code[20]; DocumentNo: Code[20]; CreditMemoNo: code[20])
    var
        ServDeclLine: Record "Service Declaration Line";
        PurchaseInvLine: Record "Purch. Inv. Line";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        Commit();  // Commit is required to commit the posted entries.

        ServDeclLine.SetFilter("Service Declaration No.", ServDeclNo);
        ServDeclLine.SetFilter("Document No.", DocumentNo);
        ServDeclLine.FindFirst();

        // Purchase Invoice Amount
        PurchaseInvLine.SetRange("Document No.", DocumentNo);
        if not PurchaseInvLine.IsEmpty() then
            PurchaseInvLine.CalcSums("Amount Including VAT");

        // Purchase Credit Memo Amount
        PurchCrMemoLine.SetRange("Document No.", CreditMemoNo);
        if not PurchCrMemoLine.IsEmpty() then
            PurchCrMemoLine.CalcSums("Amount Including VAT");

        Assert.AreEqual(ServDeclLine.Amount, PurchaseInvLine."Amount Including VAT" - PurchCrMemoLine."Amount Including VAT", LineNotExistErr);
    end;

    local procedure ValidateMissingFields(var ServDeclPage: TestPage "Service Declaration")
    var
        TransportMethod: Record "Transport Method";
        PaymentMethod: Record "Payment Method";
    begin
        FileNo := IncStr(FileNo);
        ServDeclPage."File Disk No.".SetValue(FileNo);
        ServDeclPage.Lines.First();
        ServDeclPage.Lines."VAT Reg. No.".SetValue('111111111');

        TransportMethod.FindFirst();
        ServDeclPage.Lines."Transport Method".SetValue(TransportMethod.Code);

        PaymentMethod.FindFirst();
        PaymentMethod.Validate("Intrastat Payment Method", 'B');
        PaymentMethod.Modify();

        ServDeclPage.Lines."Payment Method".SetValue(PaymentMethod.Code);
    end;

    local procedure CreateAndPostCorrectivePurchCrMemo(PostedPurchInvoiceCode: Code[20]; PostingDate: Date): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchInvoiceHeader: Record "Purch. Inv. Header";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
    begin
        PurchInvoiceHeader.Get(PostedPurchInvoiceCode);
        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchInvoiceHeader, PurchaseHeader);
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Validate("Vendor Cr. Memo No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true));
    end;

    local procedure CreateAndPostMultipleLineCorrectivePurchCrMemo(PostedPurchInvoiceCode: Code[20]; PostingDate: Date): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchInvoiceHeader: Record "Purch. Inv. Header";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
    begin
        PurchInvoiceHeader.Get(PostedPurchInvoiceCode);
        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchInvoiceHeader, PurchaseHeader);
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Validate("Vendor Cr. Memo No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::"G/L Account");
        if PurchaseLine.FindSet() then
            repeat
                PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(50, 80, 2));
                PurchaseLine.Modify(true);
            until PurchaseLine.Next() = 0;
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true));
    end;

    local procedure CreateAndPostCorrectiveSalesCrMemo(PostedSalesInvoiceCode: Code[20]; PostingDate: Date): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
    begin
        SalesInvoiceHeader.Get(PostedSalesInvoiceCode);
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Modify(true);
        exit(LibrarySales.PostSalesDocument(SalesHeader, false, true));
    end;

    procedure InvokeSuggestLinesOnServDecl(ServDeclNo: Code[20])
    var
        ServDecl: TestPage "Service Declaration";
    begin
        ServDecl.OpenEdit();
        ServDecl.Filter.SetFilter("No.", ServDeclNo);
        ServDecl.GetEntries.Invoke();
    end;

    procedure GetStatisticalPeriodQuarter(ReportDate: Date): Code[20]
    var
        Quarter: Code[2];
        Year: Code[4];
    begin
        Quarter := Format((Date2DMY(ReportDate, 2) - 1) div 3 + 1).PadLeft(2, '0');
        Year := CopyStr(Format(Date2DMY(ReportDate, 3)), 3, 2);
        exit(Year + Quarter);
    end;

    local procedure CheckFileContentForNormalReporting(var ServDeclPage: TestPage "Service Declaration"; FileType: Char; Periodicity2: Char)
    var
        DataExch: Record "Data Exch.";
        CompanyInfo: Record "Company Information";
        PaymentMethod: Record "Payment Method";
        FileMgt: Codeunit "File Management";
        LibraryTextFileValidation: Codeunit "Library - Text File Validation";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        Header, Line1 : Text;
        DecVar: Decimal;
        ReadFromPosition: Integer;
        DocumentDate: Date;
    begin
        DataExch.FindLast();
        Assert.IsTrue(DataExch."File Content".HasValue(), DataExchFileContentMissingErr);

        DataExch.CalcFields("File Content");
        TempBlob.FromRecord(DataExch, DataExch.FieldNo("File Content"));

        FileName := FileMgt.ServerTempFileName('txt');
        FileMgt.BLOBExportToServerFile(TempBlob, FileName);

        Header := LibraryTextFileValidation.ReadLine(FileName, 1);
        CompanyInfo.Get();

        // Verify header line
        ReadFromPosition := 1;
        Assert.AreEqual(EUROXLbl, LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 5), ServDeclFileOutputErr);
        ReadFromPosition += 5;
        Assert.AreEqual(ServDeclMgtIT.GetCompanyRepresentativeVATNo(), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 11), ServDeclFileOutputErr);
        ReadFromPosition += 11;
        Assert.AreEqual(Format(ServDeclPage."File Disk No.").PadLeft(6, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 6), ServDeclFileOutputErr);
        ReadFromPosition += 6;
        Assert.AreEqual('000000', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 6), ServDeclFileOutputErr);
        ReadFromPosition += 6;
        Assert.AreEqual(FileType, LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 1), ServDeclFileOutputErr);
        ReadFromPosition += 1;
        Assert.AreEqual(CopyStr(Format(ServDeclPage."Statistics Period"), 1, 2).PadLeft(2, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 2), ServDeclFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual(Periodicity2, LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 1), ServDeclFileOutputErr);
        ReadFromPosition += 1;
        Assert.AreEqual(CopyStr(Format(ServDeclPage."Statistics Period"), 3, 2).PadLeft(2, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 2), ServDeclFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual(ServDeclMgtIT.RemoveLeadingCountryCode(CompanyInfo."VAT Registration No.", CompanyInfo."Country/Region Code").PadLeft(11, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 11), ServDeclFileOutputErr);
        ReadFromPosition += 11;
        Assert.AreEqual('00', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 2), ServDeclFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual('00000000000', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 11), ServDeclFileOutputErr);
        ReadFromPosition += 11;
        Assert.AreEqual('000000000000000000000000000000000000', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 36), ServDeclFileOutputErr);
        ReadFromPosition += 36;
        Assert.AreEqual('00001', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 5), ServDeclFileOutputErr);
        ReadFromPosition += 5;
        Evaluate(DecVar, ServDeclPage.Lines.Amount.Value);
        Assert.AreEqual(Format(Round(Abs(DecVar), 1)).PadLeft(13, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 13), ServDeclFileOutputErr);
        ReadFromPosition += 13;
        if FileType = 'A' then
            Assert.AreEqual(Format('').PadLeft(18, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 18), ServDeclFileOutputErr)
        else
            Assert.AreEqual(Format('').PadLeft(22, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 22), ServDeclFileOutputErr);

        // Verify Line
        Line1 := LibraryTextFileValidation.ReadLine(FileName, 2);
        ReadFromPosition := 1;
        Assert.AreEqual(EUROXLbl, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 5), ServDeclFileOutputErr);
        ReadFromPosition += 5;
        Assert.AreEqual(ServDeclMgtIT.GetCompanyRepresentativeVATNo(), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 11), ServDeclFileOutputErr);
        ReadFromPosition += 11;
        Assert.AreEqual(Format(ServDeclPage."File Disk No.").PadLeft(6, '0'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 6), ServDeclFileOutputErr);
        ReadFromPosition += 6;
        Assert.AreEqual('3', LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 1), ServDeclFileOutputErr);
        ReadFromPosition += 1;
        Assert.AreEqual('00001', LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 5), ServDeclFileOutputErr);
        ReadFromPosition += 5;
        Assert.AreEqual(ServDeclPage.Lines."Country/Region Code".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 2), ServDeclFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual(ServDeclPage.Lines."VAT Reg. No.".Value.PadRight(12, ' '), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 12), ServDeclFileOutputErr);
        ReadFromPosition += 12;
        Evaluate(DecVar, ServDeclPage.Lines.Amount.Value);
        Assert.AreEqual(Format(Round(Abs(DecVar), 1)).PadLeft(13, '0'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 13), ServDeclFileOutputErr);
        ReadFromPosition += 13;
        if FileType = 'A' then begin
            Assert.AreEqual(Format('0').PadLeft(13, '0'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 13), ServDeclFileOutputErr);
            ReadFromPosition += 13;
            Assert.AreEqual(ServDeclPage.Lines."External Document No.".Value.PadRight(15, ' '), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 15), ServDeclFileOutputErr);
            ReadFromPosition += 15;
        end else begin
            Assert.AreEqual(ServDeclPage.Lines."Document No.".Value.PadRight(15, ' '), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 15), ServDeclFileOutputErr);
            ReadFromPosition += 15;
        end;
        DocumentDate := ServDeclPage.Lines."Document Date".AsDate();
        Assert.AreEqual(Format(ServDeclPage.Lines."Document Date".AsDate(), 0, '<Day,2><Month,2><Year,2>'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 6), ServDeclFileOutputErr);
        ReadFromPosition += 6;
        Assert.AreEqual(ServDeclPage.Lines."Service Tariff No.".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 6), ServDeclFileOutputErr);
        ReadFromPosition += 6;
        Assert.AreEqual(ServDeclPage.Lines."Transport Method".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 1), ServDeclFileOutputErr);
        ReadFromPosition += 1;
        PaymentMethod.Get(ServDeclPage.Lines."Payment Method".Value);
        Assert.AreEqual(PaymentMethod."Intrastat Payment Method", LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 1), ServDeclFileOutputErr);
        ReadFromPosition += 1;
        Assert.AreEqual(ServDeclPage.Lines."Country/Region of Payment Code".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 2), ServDeclFileOutputErr);
        ReadFromPosition += 2;
    end;

    local procedure CheckFileContentForCorrectionReporting(var ServDeclPage: TestPage "Service Declaration"; FileType: Char; Periodicity2: Char)
    var
        DataExch: Record "Data Exch.";
        CompanyInfo: Record "Company Information";
        PaymentMethod: Record "Payment Method";
        FileMgt: Codeunit "File Management";
        LibraryTextFileValidation: Codeunit "Library - Text File Validation";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        Header, Line1 : Text;
        DecVar: Decimal;
        ReadFromPosition: Integer;
    begin
        DataExch.FindLast();
        Assert.IsTrue(DataExch."File Content".HasValue(), DataExchFileContentMissingErr);

        DataExch.CalcFields("File Content");
        TempBlob.FromRecord(DataExch, DataExch.FieldNo("File Content"));

        FileName := FileMgt.ServerTempFileName('txt');
        FileMgt.BLOBExportToServerFile(TempBlob, FileName);

        Header := LibraryTextFileValidation.ReadLine(FileName, 1);
        CompanyInfo.Get();

        // Verify header line
        ReadFromPosition := 1;
        Assert.AreEqual(EUROXLbl, LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 5), ServDeclFileOutputErr);
        ReadFromPosition += 5;
        Assert.AreEqual(ServDeclMgtIT.GetCompanyRepresentativeVATNo(), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 11), ServDeclFileOutputErr);
        ReadFromPosition += 11;
        Assert.AreEqual(Format(ServDeclPage."File Disk No.").PadLeft(6, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 6), ServDeclFileOutputErr);
        ReadFromPosition += 6;
        Assert.AreEqual('000000', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 6), ServDeclFileOutputErr);
        ReadFromPosition += 6;
        Assert.AreEqual(FileType, LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 1), ServDeclFileOutputErr);
        ReadFromPosition += 1;
        Assert.AreEqual(CopyStr(Format(ServDeclPage."Statistics Period"), 1, 2).PadLeft(2, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 2), ServDeclFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual(Periodicity2, LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 1), ServDeclFileOutputErr);
        ReadFromPosition += 1;
        Assert.AreEqual(CopyStr(Format(ServDeclPage."Statistics Period"), 3, 2).PadLeft(2, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 2), ServDeclFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual(ServDeclMgtIT.RemoveLeadingCountryCode(CompanyInfo."VAT Registration No.", CompanyInfo."Country/Region Code").PadLeft(11, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 11), ServDeclFileOutputErr);
        ReadFromPosition += 11;
        Assert.AreEqual('00', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 2), ServDeclFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual('00000000000', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 11), ServDeclFileOutputErr);
        ReadFromPosition += 11;
        if ServDeclPage."Corrective Entry".AsBoolean() then begin
            Assert.AreEqual(Format('').PadLeft(54, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 54), ServDeclFileOutputErr);
            ReadFromPosition += 54;
        end else begin
            Assert.AreEqual(Format('').PadLeft(36, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 36), ServDeclFileOutputErr);
            ReadFromPosition += 36;
        end;
        Assert.AreEqual('00001', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 5), ServDeclFileOutputErr);
        ReadFromPosition += 5;
        Evaluate(DecVar, ServDeclPage.Lines.Amount.Value);
        Assert.AreEqual(Format(Round(Abs(DecVar), 1)).PadLeft(13, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 13), ServDeclFileOutputErr);
        ReadFromPosition += 13;
        if ServDeclPage."Corrective Entry".AsBoolean() then
            Assert.AreEqual(Format('').PadLeft(5, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 5), ServDeclFileOutputErr)
        else
            if FileType = 'A' then
                Assert.AreEqual(Format('').PadLeft(18, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 18), ServDeclFileOutputErr)
            else
                Assert.AreEqual(Format('').PadLeft(22, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 22), ServDeclFileOutputErr);

        // Verify Line
        Line1 := LibraryTextFileValidation.ReadLine(FileName, 2);
        ReadFromPosition := 1;
        Assert.AreEqual(EUROXLbl, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 5), ServDeclFileOutputErr);
        ReadFromPosition += 5;
        Assert.AreEqual(ServDeclMgtIT.GetCompanyRepresentativeVATNo(), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 11), ServDeclFileOutputErr);
        ReadFromPosition += 11;
        Assert.AreEqual(Format(ServDeclPage."File Disk No.").PadLeft(6, '0'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 6), ServDeclFileOutputErr);
        ReadFromPosition += 6;
        if ServDeclPage."Corrective Entry".AsBoolean() then
            Assert.AreEqual('4', LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 1), ServDeclFileOutputErr)
        else
            Assert.AreEqual('3', LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 1), ServDeclFileOutputErr);
        ReadFromPosition += 1;
        Assert.AreEqual('00001', LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 5), ServDeclFileOutputErr);
        ReadFromPosition += 5;
        if ServDeclPage."Corrective Entry".AsBoolean() then begin
            Assert.AreEqual('000CO1', LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 6), ServDeclFileOutputErr);
            ReadFromPosition += 6;
            Assert.AreEqual(Format(ServDeclPage.Lines."Document Date".AsDate(), 0, '<Year,2>'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 2), ServDeclFileOutputErr);
            ReadFromPosition += 2;
            Assert.AreEqual(ServDeclPage.Lines."Ref. File Disk No.".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 6), ServDeclFileOutputErr);
            ReadFromPosition += 6;
            Assert.AreEqual(ServDeclPage.Lines."Progressive No.".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 5), ServDeclFileOutputErr);
            ReadFromPosition += 5;
        end;
        Assert.AreEqual(ServDeclPage.Lines."Country/Region Code".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 2), ServDeclFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual(ServDeclPage.Lines."VAT Reg. No.".Value.PadRight(12, ' '), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 12), ServDeclFileOutputErr);
        ReadFromPosition += 12;
        Evaluate(DecVar, ServDeclPage.Lines.Amount.Value);
        Assert.AreEqual(Format(Round(Abs(DecVar), 1)).PadLeft(13, '0'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 13), ServDeclFileOutputErr);
        ReadFromPosition += 13;
        if FileType = 'A' then begin
            Assert.AreEqual(Format('0').PadLeft(13, '0'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 13), ServDeclFileOutputErr);
            ReadFromPosition += 13;
            if ServDeclPage."Corrective Entry".AsBoolean() then
                Assert.AreEqual(ServDeclPage.Lines."Document No.".Value.PadRight(15, ' '), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 15), ServDeclFileOutputErr)
            else
                Assert.AreEqual(ServDeclPage.Lines."External Document No.".Value.PadRight(15, ' '), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 15), ServDeclFileOutputErr);
            ReadFromPosition += 15;
        end else begin
            Assert.AreEqual(ServDeclPage.Lines."Document No.".Value.PadRight(15, ' '), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 15), ServDeclFileOutputErr);
            ReadFromPosition += 15;
        end;
        Assert.AreEqual(Format(ServDeclPage.Lines."Document Date".AsDate(), 0, '<Day,2><Month,2><Year,2>'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 6), ServDeclFileOutputErr);
        ReadFromPosition += 6;
        Assert.AreEqual(ServDeclPage.Lines."Service Tariff No.".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 6), ServDeclFileOutputErr);
        ReadFromPosition += 6;
        Assert.AreEqual(ServDeclPage.Lines."Transport Method".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 1), ServDeclFileOutputErr);
        ReadFromPosition += 1;
        PaymentMethod.Get(ServDeclPage.Lines."Payment Method".Value);
        Assert.AreEqual(PaymentMethod."Intrastat Payment Method", LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 1), ServDeclFileOutputErr);
        ReadFromPosition += 1;
        Assert.AreEqual(ServDeclPage.Lines."Country/Region of Payment Code".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 2), ServDeclFileOutputErr);
        ReadFromPosition += 2;
    end;

    local procedure CheckFileContentForAbsoluteSumReporting(var ServDeclPage: TestPage "Service Declaration"; FileType: Char; Periodicity2: Char; ExpectedAmount: Decimal)
    var
        DataExch: Record "Data Exch.";
        CompanyInfo: Record "Company Information";
        FileMgt: Codeunit "File Management";
        LibraryTextFileValidation: Codeunit "Library - Text File Validation";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        Header: Text;
        ReadFromPosition: Integer;
    begin
        DataExch.FindLast();
        Assert.IsTrue(DataExch."File Content".HasValue(), DataExchFileContentMissingErr);

        DataExch.CalcFields("File Content");
        TempBlob.FromRecord(DataExch, DataExch.FieldNo("File Content"));

        FileName := FileMgt.ServerTempFileName('txt');
        FileMgt.BLOBExportToServerFile(TempBlob, FileName);

        Header := LibraryTextFileValidation.ReadLine(FileName, 1);
        CompanyInfo.Get();

        // Verify header line
        ReadFromPosition := 1;
        Assert.AreEqual(EUROXLbl, LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 5), ServDeclFileOutputErr);
        ReadFromPosition += 5;
        Assert.AreEqual(ServDeclMgtIT.GetCompanyRepresentativeVATNo(), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 11), ServDeclFileOutputErr);
        ReadFromPosition += 11;
        Assert.AreEqual(Format(ServDeclPage."File Disk No.").PadLeft(6, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 6), ServDeclFileOutputErr);
        ReadFromPosition += 6;
        Assert.AreEqual('000000', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 6), ServDeclFileOutputErr);
        ReadFromPosition += 6;
        Assert.AreEqual(FileType, LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 1), ServDeclFileOutputErr);
        ReadFromPosition += 1;
        Assert.AreEqual(CopyStr(Format(ServDeclPage."Statistics Period"), 1, 2).PadLeft(2, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 2), ServDeclFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual(Periodicity2, LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 1), ServDeclFileOutputErr);
        ReadFromPosition += 1;
        Assert.AreEqual(CopyStr(Format(ServDeclPage."Statistics Period"), 3, 2).PadLeft(2, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 2), ServDeclFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual(ServDeclMgtIT.RemoveLeadingCountryCode(CompanyInfo."VAT Registration No.", CompanyInfo."Country/Region Code").PadLeft(11, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 11), ServDeclFileOutputErr);
        ReadFromPosition += 11;
        Assert.AreEqual('00', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 2), ServDeclFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual('00000000000', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 11), ServDeclFileOutputErr);
        ReadFromPosition += 11;
        if ServDeclPage."Corrective Entry".AsBoolean() then begin
            Assert.AreEqual(Format('').PadLeft(54, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 54), ServDeclFileOutputErr);
            ReadFromPosition += 54;
        end else begin
            Assert.AreEqual(Format('').PadLeft(36, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 36), ServDeclFileOutputErr);
            ReadFromPosition += 36;
        end;
        ReadFromPosition += 5;
        Assert.AreEqual(Format(Round(Abs(ExpectedAmount), 1), 0, 9).PadLeft(13, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 13), ServDeclFileOutputErr);
    end;
}