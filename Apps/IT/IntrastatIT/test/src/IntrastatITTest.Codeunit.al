codeunit 139511 "Intrastat IT Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Intrastat IT]
        IsInitialized := false;
    end;

    var
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryIntrastat: Codeunit "Library - IT Intrastat";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryPatterns: Codeunit "Library - Patterns";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryMarketing: Codeunit "Library - Marketing";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        IntrastatReportMgtIT: Codeunit "Intrastat Report Management IT";
        IsInitialized: Boolean;
        Periodicity: Option Month,Quarter;
        Type: Option Purchase,Sales;
        FileNo: Code[10];
        ValidationErr: Label '%1 must be %2 in %3.', Comment = '%1 = FieldCaption(Quantity),%2 = SalesLine.Quantity,%3 = TableCaption(SalesShipmentLine).';
        LineNotExistErr: Label 'Intrastat Report Lines incorrectly created.';
        LineCountErr: Label 'The number of %1 entries is incorrect.', Comment = '%1 = Intrastat Report Line table';
        InternetURLTxt: Label 'www.microsoft.com';
        InvalidURLTxt: Label 'URL must be prefix with http.';
        PackageTrackingNoErr: Label 'Package Tracking No does not exist.';
        TariffItemInfoDifferentErr: Label '%1 on %2 and %3 is different.', Comment = '%1 - field name, %2 - Item Table Caption, %3 - Tariff Number Table Caption';
        HttpTxt: Label 'http://';
        OnDelIntrastatContactErr: Label 'You cannot delete contact number %1 because it is set up as an Intrastat contact in the Intrastat Setup window.', Comment = '%1 - Contact No';
        OnDelVendorIntrastatContactErr: Label 'You cannot delete vendor number %1 because it is set up as an Intrastat contact in the Intrastat Setup window.', Comment = '%1 - Vendor No';
        ShptMethodCodeErr: Label 'Wrong Shipment Method Code';
        StatPeriodFormatErr: Label '%1 must be 4 characters, for example, 9410 for October, 1994.', Comment = '%1 - field caption';
        StatPeriodMonthErr: Label 'Please check the month number.';
        DataExchFileContentMissingErr: Label 'Data Exch File Content must not be empty';
        IntrastatFileOutputErr: Label 'Intrastat has exported incorrectly to file output.';
        EUROXLbl: Label 'EUROX', Locked = true;
        DataExchangeXMLNPMP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-IT-NPM" Name="Intrastat Report 2022 IT (Normal Purchase Monthly)" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="148122" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="20"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Source Currency Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Total Weight" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Supplementary Quantity" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Statistical Value" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="15" Name="Group Code" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="16" Name="Transport Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="17" Name="Transaction Specification" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="18" Name="Country/Region of Origin Code" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="19" Name="Area" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="20" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="10" MappingCodeunit="1269" PostMappingCodeunit="148123"><DataExchFieldMapping ColumnNo="1" Optional="true" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="148121" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="148122" Optional="true" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only </Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="1" /><DataExchFieldMapping ColumnNo="5" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="7" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="8" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length>',
                            Locked = true;
        DataExchangeXMLNPMP2Txt: Label '<DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="38" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="10" FieldID="8" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="11" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="12" FieldID="21" Optional="true" TransformationRule="ROUNDTOINTWITHMIN1"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINTWITHMIN1</Code><Description>Round to Integer with minimal value equal to 1</Description><TransformationType>6</TransformationType><FindValue>^0[,.].*</FindValue><ReplaceValue>1</ReplaceValue><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ROUNDTOINT</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="35" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule>',
                            Locked = true;
        DataExchangeXMLNPMP3Txt: Label '<TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="15" FieldID="40" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="16" FieldID="9" Optional="true" TransformationRule="NUMBERSONLYFIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>NUMBERSONLYFIRSTCHAR</Code><Description>Numbers Only First Character</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>FIRSTCHAR</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="17" FieldID="27" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="18" FieldID="24" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="19" FieldID="26" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="20" FieldID="8" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="26" /><DataExchFieldGrouping FieldID="27" /><DataExchFieldGrouping FieldID="29" /><DataExchFieldGrouping FieldID="39" /><DataExchFieldGrouping FieldID="40" /><DataExchFieldGrouping FieldID="148123" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true;
        DataExchangeXMLNPQP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-IT-NPQ" Name="Intrastat Report 2022 IT (Normal Purchase Quarterly)" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="148122" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="11"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Source Currency Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="10" MappingCodeunit="1269" PostMappingCodeunit="148123"><DataExchFieldMapping ColumnNo="1" Optional="true" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="148121" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="148122" Optional="true" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only </Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="1" /><DataExchFieldMapping ColumnNo="5" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="7" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="8" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="38" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules>',
                            Locked = true;
        DataExchangeXMLNPQP2Txt: Label '<TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="10" FieldID="8" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="11" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="26" /><DataExchFieldGrouping FieldID="27" /><DataExchFieldGrouping FieldID="29" /><DataExchFieldGrouping FieldID="39" /><DataExchFieldGrouping FieldID="40" /><DataExchFieldGrouping FieldID="148123" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true;
        DataExchangeXMLNSMP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-IT-NSM" Name="Intrastat Report 2022 IT (Normal Sale Monthly)" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="148122" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="19"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Total Weight" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Supplementary Quantity" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Statistical Value" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Group Code" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="15" Name="Transport Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="16" Name="Transaction Specification" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="17" Name="Area" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="18" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="19" Name="Country/Region of Origin Code" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="10" MappingCodeunit="1269" PostMappingCodeunit="148123"><DataExchFieldMapping ColumnNo="1" Optional="true" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="148121" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="148122" Optional="true" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only </Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="1" /><DataExchFieldMapping ColumnNo="5" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="7" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="8" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules>',
                            Locked = true;
        DataExchangeXMLNSMP2Txt: Label '<TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="8" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="10" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="11" FieldID="21" Optional="true" TransformationRule="ROUNDTOINTWITHMIN1"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINTWITHMIN1</Code><Description>Round to Integer with minimal value equal to 1</Description><TransformationType>6</TransformationType><FindValue>^0[,.].*</FindValue><ReplaceValue>1</ReplaceValue><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ROUNDTOINT</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="12" FieldID="35" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="40" Optional="true" TransformationRule="FIRSTCHAR">',
                            Locked = true;
        DataExchangeXMLNSMP3Txt: Label '<TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="15" FieldID="9" Optional="true" TransformationRule="NUMBERSONLYFIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>NUMBERSONLYFIRSTCHAR</Code><Description>Numbers Only First Character</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>FIRSTCHAR</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="16" FieldID="27" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="17" FieldID="26" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="18" FieldID="8" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="19" FieldID="24" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="26" /><DataExchFieldGrouping FieldID="27" /><DataExchFieldGrouping FieldID="29" /><DataExchFieldGrouping FieldID="39" /><DataExchFieldGrouping FieldID="40" /><DataExchFieldGrouping FieldID="148123" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true;
        DataExchangeXMLNSQP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-IT-NSQ" Name="Intrastat Report 2022 IT (Normal Sale Quarterly)" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="148122" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="10"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="10" MappingCodeunit="1269" PostMappingCodeunit="148123"><DataExchFieldMapping ColumnNo="1" Optional="true" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="148121" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="148122" Optional="true" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only </Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="1" /><DataExchFieldMapping ColumnNo="5" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="7" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="8" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="8" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping>',
                            Locked = true;
        DataExchangeXMLNSQP2Txt: Label '<DataExchFieldMapping ColumnNo="10" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="26" /><DataExchFieldGrouping FieldID="27" /><DataExchFieldGrouping FieldID="29" /><DataExchFieldGrouping FieldID="39" /><DataExchFieldGrouping FieldID="40" /><DataExchFieldGrouping FieldID="148123" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true;
        DataExchangeXMLCPMP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-IT-CPM" Name="Intrastat Report 2022 IT (Correction Purchase Monthly)" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="148122" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="16"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Month" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Quarter" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Year" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Empty Partner VAT Number" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Sign" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Source Currency Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="15" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="16" Name="Statistical Value" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="8" MappingCodeunit="1269" PostMappingCodeunit="148123"><DataExchFieldMapping ColumnNo="1" Optional="true" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="148121" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="148122" Optional="true" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="2" /><DataExchFieldMapping ColumnNo="5" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="42" Optional="true" TransformationRule="SECOND2CHARS"><TransformationRules><Code>SECOND2CHARS</Code><Description>Gets characters 3d and 4th charachters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>3</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="7" Optional="true" UseDefaultValue="true" DefaultValue="0" /><DataExchFieldMapping ColumnNo="8" FieldID="42" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="11" FieldID="13" Optional="true" TransformationRule="GETAMOUNTSIGN"><TransformationRules>',
                            Locked = true;
        DataExchangeXMLCPMP2Txt: Label '<Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>GETAMOUNTSIGN</Code><Description>Get Amount Sign</Description><TransformationType>6</TransformationType><FindValue>^\d</FindValue><ReplaceValue>+</ReplaceValue><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>FIRSTCHAR</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="12" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="38" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="8" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="15" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="16" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true;
        DataExchangeXMLCSMP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-IT-CSM" Name="Intrastat Report 2022 IT (Correction Sales Monthly)" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="148122" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="15"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Month" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Quarter" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Year" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Empty Partner VAT Number" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Sign" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="15" Name="Statistical Value" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="10" MappingCodeunit="1269" PostMappingCodeunit="148123"><DataExchFieldMapping ColumnNo="1" Optional="true" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="148121" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="148122" Optional="true" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="2" /><DataExchFieldMapping ColumnNo="5" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="42" Optional="true" TransformationRule="SECOND2CHARS"><TransformationRules><Code>SECOND2CHARS</Code><Description>Gets characters 3d and 4th charachters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>3</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="7" Optional="true" UseDefaultValue="true" DefaultValue="0" /><DataExchFieldMapping ColumnNo="8" FieldID="42" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="11" FieldID="13" Optional="true" TransformationRule="GETAMOUNTSIGN"><TransformationRules>',
                            Locked = true;
        DataExchangeXMLCSMP2Txt: Label '<Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>GETAMOUNTSIGN</Code><Description>Get Amount Sign</Description><TransformationType>6</TransformationType><FindValue>^\d</FindValue><ReplaceValue>+</ReplaceValue><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>FIRSTCHAR</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="12" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="8" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="15" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true;
        DataExchangeXMLCPQP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-IT-CPQ" Name="Intrastat Report 2022 IT (Correction Purchase Quarterly)" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="148122" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="15"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Month" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Quarter" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Year" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Empty Partner VAT Number" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Sign" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Source Currency Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="15" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="8" MappingCodeunit="1269" PostMappingCodeunit="148123"><DataExchFieldMapping ColumnNo="1" Optional="true" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="148121" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="148122" Optional="true" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="2" /><DataExchFieldMapping ColumnNo="5" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="6" Optional="true" UseDefaultValue="true" DefaultValue="0" /><DataExchFieldMapping ColumnNo="7" FieldID="42" Optional="true" TransformationRule="FOURTHCHAR"><TransformationRules><Code>FOURTHCHAR</Code><Description>Fourth Character</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>4</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="8" FieldID="42" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="11" FieldID="13" Optional="true" TransformationRule="GETAMOUNTSIGN"><TransformationRules>',
                            Locked = true;
        DataExchangeXMLCPQP2Txt: Label '<Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>GETAMOUNTSIGN</Code><Description>Get Amount Sign</Description><TransformationType>6</TransformationType><FindValue>^\d</FindValue><ReplaceValue>+</ReplaceValue><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>FIRSTCHAR</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="12" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="38" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="8" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="15" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true;
        DataExchangeXMLCSQP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-IT-CSQ" Name="Intrastat Report 2022 IT (Correction Sales Quarterly)" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="148122" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="14"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Month" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Quarter" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Year" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Empty Partner VAT Number" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Sign" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="8" MappingCodeunit="1269" PostMappingCodeunit="148123"><DataExchFieldMapping ColumnNo="1" Optional="true" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="148121" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="148122" Optional="true" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="2" /><DataExchFieldMapping ColumnNo="5" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="6" Optional="true" UseDefaultValue="true" DefaultValue="0" /><DataExchFieldMapping ColumnNo="7" FieldID="42" Optional="true" TransformationRule="FOURTHCHAR"><TransformationRules><Code>FOURTHCHAR</Code><Description>Fourth Character</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>4</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="8" FieldID="42" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="11" FieldID="13" Optional="true" TransformationRule="GETAMOUNTSIGN"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules>',
                            Locked = true;
        DataExchangeXMLCSQP2Txt: Label '<TransformationRules><Code>GETAMOUNTSIGN</Code><Description>Get Amount Sign</Description><TransformationType>6</TransformationType><FindValue>^\d</FindValue><ReplaceValue>+</ReplaceValue><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>FIRSTCHAR</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="12" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="8" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true;

    [Test]
    [Scope('OnPrem')]
    procedure ItemLedgerEntryForPurchase()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO] Check Item Ledger Entry after posting Purchase Order.

        // [GIVEN] Posted Purchase Order
        Initialize();
        DocumentNo := LibraryIntrastat.CreateAndPostPurchaseOrder(PurchaseLine, WorkDate());

        // [THEN] Verify Item Ledger Entry
        VerifyItemLedgerEntry(ItemLedgerEntry."Document Type"::"Purchase Receipt", DocumentNo, LibraryIntrastat.GetCountryRegionCode(), PurchaseLine.Quantity);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure IntrastatReportLineForPurchase()
    var
        PurchaseLine: Record "Purchase Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO] Check Intrastat Report Line for posted Purchase Order.

        // [GIVEN] Posted Purchase Order
        Initialize();

        DocumentNo := LibraryIntrastat.CreateAndPostPurchaseOrderWithInvoice(PurchaseLine, WorkDate());

        // [WHEN] Get Intrastat Report Line for Purchase Order
        // [THEN] Verify Intrastat Report Line
        CreateAndVerifyIntrastatLine(DocumentNo, PurchaseLine."No.", PurchaseLine.Quantity, IntrastatReportLine.Type::Receipt, Periodicity::Month, Type::Purchase);
    end;

    [Test]
    [HandlerFunctions('UndoDocumentConfirmHandler,IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure IntrastatLineAfterUndoPurchase()
    var
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO] Check that no Intrastat Report Line exist for the Item for which Undo Purchase Receipt has done.

        // [GIVEN] Create and Post Purchase Order
        Initialize();
        DocumentNo := LibraryIntrastat.CreateAndPostPurchaseOrder(PurchaseLine, WorkDate());

        // [WHEN] Undo Purchase Receipt Line
        LibraryIntrastat.UndoPurchaseReceiptLine(DocumentNo, PurchaseLine."No.");

        // [WHEN] Create Intrastat Report and Get Entries for Intrastat Report Line
        // [THEN] Verify no entry exists for posted Item.
        GetEntriesAndVerifyNoItemLine(DocumentNo);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ItemLedgerEntryForSales()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Sales] 
        // [SCENARIO] Check Item Ledger Entry after posting Sales Order.

        // [GIVEN] Create and Post Sales Order
        Initialize();
        DocumentNo := LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, WorkDate());

        // [THEN] Verify Item Ledger Entry
        VerifyItemLedgerEntry(ItemLedgerEntry."Document Type"::"Sales Shipment", DocumentNo, LibraryIntrastat.GetCountryRegionCode(), -SalesLine.Quantity);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure IntrastatLineForSales()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO] Check Intrastat Report Line for posted Sales Order.

        // [GIVEN] Create and Post Sales Order
        Initialize();
        DocumentNo := LibraryIntrastat.CreateAndPostSalesOrderWithInvoice(SalesLine, WorkDate());

        // [WHEN] Get Intrastat Report Lines for Sales Order
        // [THEN] Verify Intrastat Report Line
        CreateAndVerifyIntrastatLine(DocumentNo, SalesLine."No.", SalesLine.Quantity, IntrastatReportLine.Type::Shipment, Periodicity::Month, Type::Sales);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    procedure NoIntrastatLineForSales()
    var
        SalesLine: Record "Sales Line";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO] Check no Intrastat Report Line exist after Deleting them for Sales Shipment.

        // [GIVEN] Take Starting Date as WORKDATE.
        Initialize();
        LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, WorkDate());

        // [WHEN] Intrastat Report Lines, Delete them
        // [THEN] Verify that no lines exist for Posted Sales Order.
        DeleteAndVerifyNoIntrastatLine(SalesLine."Document No.");
    end;

    [Test]
    [HandlerFunctions('UndoDocumentConfirmHandler')]
    [Scope('OnPrem')]
    procedure UndoSalesShipment()
    var
        SalesLine: Record "Sales Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO] Check Quantity on Sales Shipment Line after doing Undo Sales Shipment.

        // [GIVEN] Posted Sales Order
        Initialize();
        DocumentNo := LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, WorkDate());

        // [WHEN] Undo Sales Shipment Line
        LibraryIntrastat.UndoSalesShipmentLine(DocumentNo, SalesLine."No.");

        // [THEN] Verify Undone Quantity on Sales Shipment Line.
        SalesShipmentLine.SetRange("Document No.", DocumentNo);
        SalesShipmentLine.SetFilter("Appl.-from Item Entry", '<>0');
        SalesShipmentLine.FindFirst();
        Assert.AreEqual(
          -SalesLine.Quantity, SalesShipmentLine.Quantity,
          StrSubstNo(ValidationErr, SalesShipmentLine.FieldCaption(Quantity), -SalesLine.Quantity, SalesShipmentLine.TableCaption()));
    end;

    [Test]
    [HandlerFunctions('UndoDocumentConfirmHandler,IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure IntrastatLineAfterUndoSales()
    var
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO] Check that no Intrastat Line exist for the Item for which Undo Sales Shipment has done.

        // [GIVEN] Create and Post Sales Order and undo Sales Shipment Line.
        Initialize();
        DocumentNo := LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, WorkDate());
        LibraryIntrastat.UndoSalesShipmentLine(DocumentNo, SalesLine."No.");

        // [WHEN] Create Intrastat Journal Template, Batch and Get Entries for Intrastat Report Line
        // [THEN] Verify no entry exists for posted Item.
        GetEntriesAndVerifyNoItemLine(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure IntrastatReportWithPurchaseOrder()
    var
        PurchaseLine: Record "Purchase Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        NewPostingDate: Date;
        IntrastatReportNo1: Code[20];
        IntrastatReportNo2: Code[20];
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Purchase] 
        // [SCENARIO] Check Intrastat Report Entries after Posting Purchase Order and Get Entries with New Posting Date.

        // [GIVEN] Create Purchase Order with New Posting Date and Create New Intratsat Report with difference with 1 Year.
        Initialize();

        NewPostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        WorkDate(NewPostingDate);
        DocumentNo := LibraryIntrastat.CreateAndPostPurchaseOrderWithInvoice(PurchaseLine, NewPostingDate);
        WorkDate(Today);

        // [GIVEN] Two Intrastat Reports for the same period
        Commit();  // Commit is required to commit the posted entries.
        CreateIntrastatReportAndSuggestLines(NewPostingDate, IntrastatReportNo1, Periodicity::Month, Type::Purchase, false, IncStr(FileNo), false);
        CreateIntrastatReportAndSuggestLines(NewPostingDate, IntrastatReportNo2, Periodicity::Month, Type::Purchase, false, IncStr(FileNo), false);

        Commit();
        // [WHEN] Get Entries from Intrastat Report pages for two Reports with the same period 
        // [THEN] Verify that Entry values on Intrastat Report Page match Purchase Line values
        VerifyIntrastatReportLine(DocumentNo, IntrastatReportNo1, IntrastatReportLine.Type::Receipt,
            LibraryIntrastat.GetCountryRegionCode(), PurchaseLine."No.", PurchaseLine.Quantity);

        // [THEN] No Entries suggested in a second Intrastat Journal
        VerifyIntrastatReportLineExist(IntrastatReportNo2, PurchaseLine."No.", false);

        LibraryIntrastat.DeleteIntrastatReport(IntrastatReportNo1);
        LibraryIntrastat.DeleteIntrastatReport(IntrastatReportNo2);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure IntrastatReportWithItemChargeAssignmentAfterPurchaseCreditMemo()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ChargeIntrastatReportLine: Record "Intrastat Report Line";
        ChargePurchaseLine: Record "Purchase Line";
        NewPostingDate: Date;
        DocumentNo, ReceiptNo : Code[20];
        IntrastatReportNo1: Code[20];
        IntrastatReportNo2: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO] Check Intrastat Report Entries after Posting Purchase Order, Purchase Credit Memo with Item Charge Assignment and Get Entries with New Posting Date.
        Initialize();

        // [GIVEN] Create and Post Purchase Order on January with Amount = "X" and location code "Y"
        NewPostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        WorkDate(NewPostingDate);
        ReceiptNo := LibraryIntrastat.CreateAndPostPurchaseOrder(PurchaseLine, NewPostingDate);
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        WorkDate(Today);
        // [GIVEN] Create and Post Purchase Credit Memo with Item Charge Assignment on February.
        LibraryIntrastat.CreatePurchaseHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo",
          CalcDate('<1M>', NewPostingDate), LibraryIntrastat.CreateVendor(LibraryIntrastat.GetCountryRegionCode()));
        PurchaseHeader.Validate("Vendor Cr. Memo No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        LibraryIntrastat.CreatePurchaseLine(
          PurchaseHeader, ChargePurchaseLine, ChargePurchaseLine.Type::"Charge (Item)", LibraryInventory.CreateItemChargeNo());
        LibraryIntrastat.CreateItemChargeAssignmentForPurchaseCreditMemo(ChargePurchaseLine, ReceiptNo);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [GIVEN] Two Reports for January and February
        // [WHEN] User runs Get Entries in Intrastat Report for January and February
        CreateIntrastatReportAndSuggestLines(NewPostingDate, IntrastatReportNo1, Periodicity::Month, Type::Purchase, false, IncStr(FileNo), false);
        CreateIntrastatReportAndSuggestLines(PurchaseHeader."Posting Date", IntrastatReportNo2, Periodicity::Month, Type::Purchase, false, IncStr(FileNo), false);

        Commit();

        // [THEN] Item Charge Entry suggested for February, "Intrastat Report Line" has Amount = "X" for January
        VerifyIntrastatReportLine(DocumentNo, IntrastatReportNo1, ChargeIntrastatReportLine.Type::Receipt,
           LibraryIntrastat.GetCountryRegionCode(), PurchaseLine."No.", PurchaseLine.Quantity);

        LibraryIntrastat.GetIntrastatReportLine(DocumentNo, IntrastatReportNo1, ChargeIntrastatReportLine);
        Assert.AreEqual(PurchaseLine.Amount, ChargeIntrastatReportLine.Amount, '');

        // [THEN] "Location Code" is "Y" in the Intrastat Report Line
        // BUG 384736: "Location Code" copies to the Intrastat Report Line from the source documents
        Assert.AreEqual(PurchaseLine."Location Code", ChargeIntrastatReportLine."Location Code", '');

        LibraryIntrastat.DeleteIntrastatReport(IntrastatReportNo1);
        LibraryIntrastat.DeleteIntrastatReport(IntrastatReportNo2);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure IntrastatReportWithItemChargeAssignmentAfterSalesCreditMemo()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        NewPostingDate: Date;
        DocumentNo: Code[20];
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Sales] [Item Charge] 
        // [SCENARIO] Check Intrastat Report Lines after Posting Sales Order, Sales Credit Memo with Item Charge Assignment and Get Entries with New Posting Date.

        // [GIVEN] Create and Post Sales Order with New Posting Date with different 1 Year.
        Initialize();

        NewPostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        WorkDate(NewPostingDate);
        DocumentNo := LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, NewPostingDate);
        WorkDate(Today);
        // [GIVEN] Create and post Sales Credit Memo with Item Charge Assignment with different Posting Date. 1M is required for Sales Credit Memo.
        LibraryIntrastat.CreateSalesDocument(
            SalesHeader, SalesLine, LibraryIntrastat.CreateCustomer(), CalcDate('<1M>', NewPostingDate), SalesLine."Document Type"::"Credit Memo",
            SalesLine.Type::"Charge (Item)", LibraryInventory.CreateItemChargeNo(), 1);
        LibraryIntrastat.CreateItemChargeAssignmentForSalesCreditMemo(SalesLine, DocumentNo);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        CreateIntrastatReportAndSuggestLines(SalesHeader."Posting Date", IntrastatReportNo, Periodicity::Month, Type::Sales, true, IncStr(FileNo), false);

        // [WHEN] Open Intrastat Report Line Page and Get Entries
        // [THEN] Verify Intrastat Report Line does not exist
        VerifyIntrastatReportLineExist(IntrastatReportNo, DocumentNo, false);

        LibraryIntrastat.DeleteIntrastatReport(IntrastatReportNo);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatReportWithSalesOrder()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        NewPostingDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Sales] 
        // [SCENARIO] Check Intrastat Report Lines after Posting Sales Order and Get Entries with New Posting Date.

        // [GIVEN] Create Sales Order with New Posting Date and Create Intrastat Report.
        Initialize();
        NewPostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        WorkDate(NewPostingDate);
        LibraryIntrastat.CreateAndPostSalesOrderWithInvoice(SalesLine, NewPostingDate);
        WorkDate(Today);

        Commit();  // Commit is required to commit the posted entries.

        // [WHEN] Get Entries from Intrastat Report
        CreateIntrastatReportAndSuggestLines(NewPostingDate, IntrastatReportNo, Periodicity::Month, Type::Sales, false, IncStr(FileNo), false);

        // [THEN] Verify Intrastat Report Lines.
        IntrastatReportLine.SetRange("Item No.", SalesLine."No.");
        IntrastatReportLine.SetRange(Type, IntrastatReportLine.Type::Shipment);
        IntrastatReportLine.SetRange(Quantity, SalesLine.Quantity);
        IntrastatReportLine.SetRange(Date, NewPostingDate);

        Assert.IsTrue(IntrastatReportLine.FindFirst(), '');

        IntrastatReportLine.Delete(true);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TotalWeightOnIntrastatReportLine()
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        NetWeight: Decimal;
    begin
        // [SCENARIO] Check Intrastat Report Total Weight after entering Quantity on Intrastat Report Line.

        // [GIVEN] Intrastat Report Line 
        Initialize();
        LibraryIntrastat.CreateIntrastatReportLine(IntrastatReportLine);
        LibraryIntrastat.CreateIntrastatReportLine(IntrastatReportLine);

        // [WHEN] Create and Update Quantity on Intrastat Report Line.
        NetWeight := LibraryIntrastat.UseItemNonZeroNetWeight(IntrastatReportLine);

        // [THEN] Verify Total Weight correctly calculated on Intrastat Report Line.
        IntrastatReportLine.TestField("Total Weight", IntrastatReportLine.Quantity * NetWeight);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPackageNoIsIncludedInInternetAddressLink()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ShippingAgent: Record "Shipping Agent";
    begin
        Initialize();
        LibraryIntrastat.CreateSalesShipmentHeader(SalesShipmentHeader, '%1');
        ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code");
        Assert.AreEqual(
          SalesShipmentHeader."Package Tracking No.",
          CopyStr(ShippingAgent.GetTrackingInternetAddr(SalesShipmentHeader."Package Tracking No."), StrLen(HttpTxt) + 1),
          PackageTrackingNoErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInternetAddressWithoutHttp()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ShippingAgent: Record "Shipping Agent";
    begin
        Initialize();
        LibraryIntrastat.CreateSalesShipmentHeader(SalesShipmentHeader, InternetURLTxt);
        ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code");
        Assert.AreEqual(HttpTxt + InternetURLTxt, ShippingAgent.GetTrackingInternetAddr(SalesShipmentHeader."Package Tracking No."), InvalidURLTxt);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInternetAddressWithHttp()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ShippingAgent: Record "Shipping Agent";
    begin
        Initialize();
        LibraryIntrastat.CreateSalesShipmentHeader(SalesShipmentHeader, HttpTxt + InternetURLTxt);
        ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code");
        Assert.AreEqual(HttpTxt + InternetURLTxt, ShippingAgent.GetTrackingInternetAddr(SalesShipmentHeader."Package Tracking No."), InvalidURLTxt);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestNoPackageNoExistIfNoPlaceHolderExistInURL()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ShippingAgent: Record "Shipping Agent";
    begin
        Initialize();
        LibraryIntrastat.CreateSalesShipmentHeader(SalesShipmentHeader, InternetURLTxt);
        ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code");
        Assert.IsTrue(
          StrPos(ShippingAgent.GetTrackingInternetAddr(SalesShipmentHeader."Package Tracking No."), SalesShipmentHeader."Package Tracking No.") = 0, PackageTrackingNoErr);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure VerifyNoIntraLinesCreatedForCrossedBoardItemChargeInNextPeriod()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo1, ReceiptNo : Code[20];
        DocumentNo2: Code[20];
        InvoicePostingDate: Date;
        IntrastatNo1: Code[20];
        IntrastatNo2: Code[20];
    begin
        // [FEATURE] [Purchase] [Item Charge]
        // [SCENARIO 376161] Invoice and Item Charge suggested for Intrastat Report in different Periods - Cross-Border
        Initialize();

        // [GIVEN] Posted Purchase Invoice in "Y" period - Cross-border
        InvoicePostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        WorkDate(InvoicePostingDate);
        ReceiptNo := LibraryIntrastat.CreateAndPostPurchaseOrder(PurchaseLine, InvoicePostingDate);
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        DocumentNo1 := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        WorkDate(Today);

        // [GIVEN] Posted Item Charge in "F" period
        LibraryIntrastat.CreatePurchaseHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::Invoice,
          CalcDate('<1M>', InvoicePostingDate), LibraryIntrastat.CreateVendor(LibraryIntrastat.GetCountryRegionCode()));
        LibraryIntrastat.CreatePurchaseLine(
          PurchaseHeader, PurchaseLine, PurchaseLine.Type::"Charge (Item)", LibraryInventory.CreateItemChargeNo());
        LibraryIntrastat.CreateItemChargeAssignmentForPurchaseCreditMemo(PurchaseLine, ReceiptNo);
        WorkDate(CalcDate('<1M>', InvoicePostingDate));
        DocumentNo2 := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        WorkDate(Today);
        // [GIVEN] Intrastat Batches for "Y" and "F" period
        CreateIntrastatReportAndSuggestLines(InvoicePostingDate, IntrastatNo1, Periodicity::Month, Type::Purchase, false, IncStr(FileNo), false);
        CreateIntrastatReportAndSuggestLines(PurchaseHeader."Posting Date", IntrastatNo2, Periodicity::Month, Type::Purchase, false, IncStr(FileNo), false);

        // [WHEN] Entries suggested to Intrastat Report "J" and "F"
        // [THEN] Intrastat Report "J" contains 1 line for Posted Invoice
        // [THEN] Intrastat Report "F" contains no lines for Posted Item Charge
        VerifyIntrastatReportLineExist(IntrastatNo1, DocumentNo1, true);
        VerifyIntrastatReportLineExist(IntrastatNo2, DocumentNo2, false);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure VerifyIntrastatReportLineSuggestedForNonCrossedBoardItemChargeInNextPeriod()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ItemCharge: Record "Item Charge";
        CompanyInformation: Record "Company Information";
        DocumentNo1: Code[20];
        DocumentNo2: Code[20];
        InvoicePostingDate: Date;
        IntrastatNo1: Code[20];
        IntrastatNo2: Code[20];
    begin
        // [FEATURE] [Purchase] [Item Charge]
        // [SCENARIO 376161] Invoice and Item Charge not suggested for Intrastat Report in different Periods - Not Cross-Border
        Initialize();
        InvoicePostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());

        // [GIVEN] Posted Purchase Invoice in "Y" period - Not Cross-border
        CompanyInformation.Get();
        LibraryIntrastat.CreatePurchaseHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::Order, InvoicePostingDate,
          LibraryIntrastat.CreateVendor(CompanyInformation."Country/Region Code"));
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, LibraryIntrastat.CreateItem());
        DocumentNo1 := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        // [GIVEN] Posted Item Charge in "F" period
        LibraryIntrastat.CreatePurchaseHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::Invoice, CalcDate('<1M>', InvoicePostingDate),
          PurchaseHeader."Buy-from Vendor No.");
        LibraryInventory.CreateItemCharge(ItemCharge);
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::"Charge (Item)", ItemCharge."No.");
        LibraryIntrastat.CreateItemChargeAssignmentForPurchaseCreditMemo(PurchaseLine, DocumentNo1);
        DocumentNo2 := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        // [GIVEN] Intrastat Batches for "Y" and "F" period
        CreateIntrastatReportAndSuggestLines(InvoicePostingDate, IntrastatNo1, Periodicity::Month, Type::Purchase, false, IncStr(FileNo), false);
        CreateIntrastatReportAndSuggestLines(PurchaseHeader."Posting Date", IntrastatNo2, Periodicity::Month, Type::Purchase, false, IncStr(FileNo), false);

        // [WHEN] Entries suggested to Intrastat Report "J" and "F" 
        // [THEN] Intrastat Report "J" contains no lines
        // [THEN] Intrastat Report "F" contains no lines
        VerifyIntrastatReportLineExist(IntrastatNo1, DocumentNo1, false);
        VerifyIntrastatReportLineExist(IntrastatNo2, DocumentNo2, false);
    end;

    [Test]
    [HandlerFunctions('UndoDocumentConfirmHandler,IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatGetEntriesUndoReceiptSameItem()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        DocumentNo, ReceiptNo : Code[20];
        NoOfPurchaseLines: Integer;
        IntrastatReportNo: Code[20];
        QtySum: Decimal;
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 121966] Get Entries for Intrastat doesn't suggest Purchase Receipt lines that were Corrected
        Initialize();

        // [GIVEN] Posted(Receipt) Purchase Order with lines for the same Item
        NoOfPurchaseLines := LibraryRandom.RandIntInRange(2, 10);
        ReceiptNo :=
          LibraryIntrastat.CreateAndPostPurchaseDocumentMultiLine(
            PurchaseLine, PurchaseHeader."Document Type"::Order, WorkDate(), PurchaseLine.Type::Item, LibraryIntrastat.CreateItem(), NoOfPurchaseLines);

        // [GIVEN] Undo Receipt for one of the lines (random) and finally post Purchase Order
        LibraryIntrastat.UndoPurchaseReceiptLineByLineNo(ReceiptNo, LibraryRandom.RandInt(NoOfPurchaseLines));

        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseLine."Document No.");
        PurchaseLine.CalcSums("Quantity Invoiced");
        QtySum := PurchaseLine."Quantity Invoiced";

        // [WHEN] User runs Get Entries for Intrastat Report
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo, Periodicity::Month, Type::Purchase, false, IncStr(FileNo), false);

        // [THEN] Line with asum of only lines for which Undo Receipt was not done is suggested
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.IntrastatLines.Filter.SetFilter("Document No.", DocumentNo);
        IntrastatReportPage.IntrastatLines.Quantity.AssertEquals(QtySum);
    end;

    [Test]
    [HandlerFunctions('UndoDocumentConfirmHandler,IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatGetEntriesUndoShipmentSameItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        DocumentNo, ShipmentNo : Code[20];
        NoOfSalesLines: Integer;
        IntrastatReportNo: Code[20];
        QtySum: Decimal;
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 121966] Get Entries for Intrastat doesn't suggest Sales Shipment lines that were Corrected
        Initialize();
        NoOfSalesLines := LibraryRandom.RandIntInRange(2, 10);

        // [GIVEN] Posted(Shipment) Sales Order with lines for the same Item
        ShipmentNo :=
          LibraryIntrastat.CreateAndPostSalesDocumentMultiLine(
            SalesLine, SalesLine."Document Type"::Order, WorkDate(), SalesLine.Type::Item, LibraryIntrastat.CreateItem(), NoOfSalesLines);

        // [GIVEN] Undo Receipt for one of the lines (random) and finally post Sales Order
        LibraryIntrastat.UndoSalesShipmentLineByLineNo(ShipmentNo, LibraryRandom.RandInt(NoOfSalesLines));
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);

        SalesLine.SetRange("Document Type", SalesLine."Document Type");
        SalesLine.SetRange("Document No.", SalesLine."Document No.");
        SalesLine.CalcSums("Quantity Invoiced");
        QtySum := SalesLine."Quantity Invoiced";

        // [WHEN] User runs Get Entries for Intrastat Report
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo, Periodicity::Month, Type::Sales, false, IncStr(FileNo), false);

        // [THEN] Line with asum of only lines for which Undo Receipt was not done is suggested
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.IntrastatLines.Filter.SetFilter("Document No.", DocumentNo);
        IntrastatReportPage.IntrastatLines.Quantity.AssertEquals(QtySum);
    end;

    [Test]
    [HandlerFunctions('UndoDocumentConfirmHandler,IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatGetEntriesUndoReturnShipmentSameItem()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        DocumentNo, ReceiptNo : Code[20];
        NoOfPurchaseLines: Integer;
        IntrastatReportNo: Code[20];
        QtySum: Decimal;
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 121966] Get Entries for Intrastat doesn't suggest Return Shipment lines that were Corrected
        Initialize();

        // [GIVEN] Posted(Shipment) Purchase Order with lines for the same Item
        NoOfPurchaseLines := LibraryRandom.RandIntInRange(2, 10);
        ReceiptNo :=
          LibraryIntrastat.CreateAndPostPurchaseDocumentMultiLine(
            PurchaseLine, PurchaseHeader."Document Type"::"Return Order", WorkDate(), PurchaseLine.Type::Item, LibraryIntrastat.CreateItem(), NoOfPurchaseLines);

        // [GIVEN] Undo Receipt for one of the lines (random) and finally post Return Order
        LibraryIntrastat.UndoReturnShipmentLineByLineNo(ReceiptNo, LibraryRandom.RandInt(NoOfPurchaseLines));
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        PurchaseHeader.Validate("Vendor Cr. Memo No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseLine."Document No.");
        PurchaseLine.CalcSums("Quantity Invoiced");
        QtySum := PurchaseLine."Quantity Invoiced";

        // [WHEN] User runs Get Entries for Intrastat Report
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo, Periodicity::Month, Type::Purchase, true, IncStr(FileNo), false);

        // [THEN] Only lines for which Undo Receipt was not done are summed up
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.IntrastatLines.Filter.SetFilter("Document No.", DocumentNo);
        IntrastatReportPage.IntrastatLines.Quantity.AssertEquals(-QtySum);
    end;

    [Test]
    [HandlerFunctions('UndoDocumentConfirmHandler,IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatGetEntriesUndoReturnReceiptSameItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        DocumentNo, ShipmentNo : Code[20];
        NoOfSalesLines: Integer;
        IntrastatReportNo: Code[20];
        QtySum: Decimal;
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 121966] Get Entries for Intrastat doesn't suggest Return Receipt lines that were Corrected
        Initialize();
        // [GIVEN] Posted(Receipt) Sales Return Order with lines for the same Item
        NoOfSalesLines := LibraryRandom.RandIntInRange(2, 10);
        ShipmentNo :=
          LibraryIntrastat.CreateAndPostSalesDocumentMultiLine(
            SalesLine, SalesLine."Document Type"::"Return Order", WorkDate(), SalesLine.Type::Item, LibraryIntrastat.CreateItem(), NoOfSalesLines);

        // [GIVEN] Undo Receipt for one of the lines (random) and finally post Return Order
        LibraryIntrastat.UndoReturnReceiptLineByLineNo(ShipmentNo, LibraryRandom.RandInt(NoOfSalesLines));
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);

        SalesLine.SetRange("Document Type", SalesLine."Document Type");
        SalesLine.SetRange("Document No.", SalesLine."Document No.");
        SalesLine.CalcSums("Quantity Invoiced");
        QtySum := SalesLine."Quantity Invoiced";

        // [WHEN] User runs Get Entries for Intrastat Report
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo, Periodicity::Month, Type::Sales, true, IncStr(FileNo), false);

        // [THEN] Only lines for which Undo Receipt was not done are summed up
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.IntrastatLines.Filter.SetFilter("Document No.", DocumentNo);
        IntrastatReportPage.IntrastatLines.Quantity.AssertEquals(-QtySum);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure IntrastatReportWithItemChargeOnStartDate()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        IntrastatReportNo: Code[20];
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Purchase] [Item Charge]
        // [SCENARIO] GetEntries for Intrastat should not create line for National Purchase order with Item Charge posted on StartDate of Period
        Initialize();

        // [GIVEN] Purchase Order with empty Country/Region Code on 01.Jan with Item "X"
        LibraryPurchase.CreatePurchHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::Order, LibraryIntrastat.CreateVendor(LibraryIntrastat.GetCountryRegionCode()));
        with PurchaseHeader do begin
            Validate("Posting Date", CalcDate('<+1Y-CM>', WorkDate()));
            Validate("Buy-from Country/Region Code", '');
            Modify(true);
        end;
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, LibraryIntrastat.CreateItem());

        // [GIVEN] Item Charge Purchase Line
        LibraryPatterns.ASSIGNPurchChargeToPurchaseLine(PurchaseHeader, PurchaseLine, 1, LibraryRandom.RandDecInRange(100, 200, 2));

        // [GIVEN] Purchase Order is Received and Invoiced on 01.Jan
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        // [WHEN] Run Get Entries on Intrastat Report
        // [THEN] No Intrastat Report Lines should be created for Item "X"
        CreateIntrastatReportAndSuggestLines(PurchaseHeader."Posting Date", IntrastatReportNo, Periodicity::Month, Type::Purchase, false, IncStr(FileNo), false);
        VerifyIntrastatLineForItemExist(DocumentNo, IntrastatReportNo);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure NotToShowItemCharges()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ItemCharge: Record "Item Charge";
        DocumentNo: Code[20];
        InvoicePostingDate: Date;
        IntrastatReportNo1: Code[20];
        IntrastatReportNo2: Code[20];
    begin
        // [FEATURE] [Purchase] [Item Charge]
        // [SCENARIO 377846] No Item Charge entries should be suggested to Intrastat Report

        Initialize();

        // [GIVEN] Posted Purchase Invoice in "Y" period
        InvoicePostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        DocumentNo := LibraryIntrastat.CreateAndPostPurchaseOrder(PurchaseLine, InvoicePostingDate);

        // [GIVEN] Posted Item Charge in "F" period
        LibraryIntrastat.CreatePurchaseHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::Invoice, CalcDate('<1M>', InvoicePostingDate),
          LibraryIntrastat.CreateVendor(LibraryIntrastat.GetCountryRegionCode()));
        LibraryInventory.CreateItemCharge(ItemCharge);
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::"Charge (Item)", ItemCharge."No.");
        LibraryIntrastat.CreateItemChargeAssignmentForPurchaseCreditMemo(PurchaseLine, DocumentNo);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        // [GIVEN] Intrastat Reports for "Y" and "F" period

        // [WHEN] Suggest Entries to Intrastat Report "Y" and "F"
        // [THEN] Intrastat Report "Y" contains 1 line for Posted Invoice
        // [THEN] Intrastat Report "F" does not contain lines for Posted Item Charge
        CreateIntrastatReportAndSuggestLines(InvoicePostingDate, IntrastatReportNo1, Periodicity::Month, Type::Purchase, false, IncStr(FileNo), false);
        CreateIntrastatReportAndSuggestLines(PurchaseHeader."Posting Date", IntrastatReportNo2, Periodicity::Month, Type::Purchase, false, IncStr(FileNo), false);

        VerifyIntrastatReportLineExist(IntrastatReportNo2, DocumentNo, false)
    end;

    [Test]
    [Scope('OnPrem')]
    procedure IntrastatReportHeader_GetStatisticsStartDate()
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 255730] TAB 262 "Intrastat Report Header".GetStatisticsStartDate() returns statistics period ("YYMM") start date ("01MMYY")
        Initialize();

        // TESTFIELD("Statistics Period")
        IntrastatReportHeader.Init();
        asserterror IntrastatReportHeader.GetStatisticsStartDate();
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError(IntrastatReportHeader.FieldName("Statistics Period"));

        // 01-01-00
        IntrastatReportHeader."Statistics Period" := '0001';
        Assert.AreEqual(DMY2Date(1, 1, 2000), IntrastatReportHeader.GetStatisticsStartDate(), '');

        // 01-01-18
        IntrastatReportHeader."Statistics Period" := '1801';
        Assert.AreEqual(DMY2Date(1, 1, 2018), IntrastatReportHeader.GetStatisticsStartDate(), '');

        // 01-12-18
        IntrastatReportHeader."Statistics Period" := '1812';
        Assert.AreEqual(DMY2Date(1, 12, 2018), IntrastatReportHeader.GetStatisticsStartDate(), '');

        // 01-12-99
        IntrastatReportHeader."Statistics Period" := '9912';
        Assert.AreEqual(DMY2Date(1, 12, 2099), IntrastatReportHeader.GetStatisticsStartDate(), '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure IntrastatContact_ChangeType()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        Contact: Record Contact;
        Vendor: Record Vendor;
    begin
        // [FEATURE] [Intrastat Report Setup] [UT]
        // [SCENARIO 255730] "Intrastat Contact No." is blanked when change "Intrastat Contact Type" field value
        Initialize();

        LibraryMarketing.CreateCompanyContact(Contact);
        LibraryPurchase.CreateVendor(Vendor);
        with IntrastatReportSetup do begin
            Validate("Intrastat Contact Type", "Intrastat Contact Type"::Contact);
            Validate("Intrastat Contact No.", Contact."No.");
            Validate("Intrastat Contact Type", "Intrastat Contact Type"::Vendor);
            TestField("Intrastat Contact No.", '');
            Validate("Intrastat Contact No.", Vendor."No.");
            Validate("Intrastat Contact Type", "Intrastat Contact Type"::Contact);
            TestField("Intrastat Contact No.", '');
            Validate("Intrastat Contact No.", Contact."No.");
            Validate("Intrastat Contact Type", "Intrastat Contact Type"::" ");
            TestField("Intrastat Contact No.", '');
            Validate("Intrastat Contact Type", "Intrastat Contact Type"::Vendor);
            Validate("Intrastat Contact No.", Vendor."No.");
            Validate("Intrastat Contact Type", "Intrastat Contact Type"::" ");
            TestField("Intrastat Contact No.", '');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure IntrastatContact_UI_Set()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        Contact: Record Contact;
        Vendor: Record Vendor;
        IntrastatContactNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report Setup] [UT] [UI]
        // [SCENARIO 255730] Set "Intrastat Contact Type" and "Intrastat Contact No." fields via "Intrastat Report Setup" page
        Initialize();

        // Set "Intrastat Contact Type" = "Contact"
        IntrastatContactNo := LibraryIntrastat.CreateIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact);
        LibraryIntrastat.SetIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact, IntrastatContactNo);
        VerifyIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact, IntrastatContactNo);

        // Set "Intrastat Contact Type" = "Vendor"
        IntrastatContactNo := LibraryIntrastat.CreateIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor);
        LibraryIntrastat.SetIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor, IntrastatContactNo);
        VerifyIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor, IntrastatContactNo);

        // Trying to set "Intrastat Contact Type" = "Contact" with vendor
        Vendor.Get(LibraryPurchase.CreateIntrastatContact(''));
        asserterror LibraryIntrastat.SetIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact, Vendor."No.");
        Assert.ExpectedErrorCode('DB:PrimRecordNotFound');
        Assert.ExpectedError(Contact.TableCaption());

        // Trying to set "Intrastat Contact Type" = "Vendor" with contact
        Contact.Get(LibraryMarketing.CreateIntrastatContact(''));
        asserterror LibraryIntrastat.SetIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor, Contact."No.");
        Assert.ExpectedErrorCode('DB:PrimRecordNotFound');
        Assert.ExpectedError(Vendor.TableCaption());
    end;

    [Test]
    [HandlerFunctions('ContactList_MPH,VendorList_MPH')]
    [Scope('OnPrem')]
    procedure IntrastatContact_UI_Lookup()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        IntrastatContactNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report Setup] [UT] [UI]
        // [SCENARIO 255730] Lookup "Intrastat Contact No." via "Intrastat Report Setup" page
        Initialize();

        // Lookup "Intrastat Contact Type" = "" do nothing
        LookupIntrastatContactViaPage(IntrastatReportSetup."Intrastat Contact Type"::" ");

        // Lookup "Intrastat Contact Type" = "Contact" opens "Contact List" page
        IntrastatContactNo := LibraryIntrastat.CreateIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact);
        LibraryVariableStorage.Enqueue(IntrastatContactNo);
        LookupIntrastatContactViaPage(IntrastatReportSetup."Intrastat Contact Type"::Contact);
        VerifyIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact, IntrastatContactNo);

        // Lookup "Intrastat Contact Type" = "Vendor" opens "Vendor List" page
        IntrastatContactNo := LibraryIntrastat.CreateIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor);
        LibraryVariableStorage.Enqueue(IntrastatContactNo);
        LookupIntrastatContactViaPage(IntrastatReportSetup."Intrastat Contact Type"::Vendor);
        VerifyIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor, IntrastatContactNo);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure IntrastatContact_DeleteContact()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        Contact: array[2] of Record Contact;
    begin
        // [FEATURE] [Intrastat Report Setup] [UT]
        // [SCENARIO 255730] An error has been shown trying to delete contact specified in the Intrastat Report Setup as an intrastat contact
        Initialize();

        // Empty setup record
        IntrastatReportSetup.Delete();
        Assert.RecordIsEmpty(IntrastatReportSetup);
        LibraryMarketing.CreateCompanyContact(Contact[1]);
        Contact[1].Delete(true);

        // Existing setup with other contact
        LibraryIntrastat.IntrastatSetupEnableReportReceipts();
        LibraryMarketing.CreateCompanyContact(Contact[1]);
        LibraryMarketing.CreateCompanyContact(Contact[2]);
        ValidateIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact, Contact[1]."No.");
        Contact[2].Delete(true);

        // Existing setup with the same contact
        asserterror Contact[1].Delete(true);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo(OnDelIntrastatContactErr, Contact[1]."No."));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure IntrastatContact_DeleteVendor()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        Vendor: array[2] of Record Vendor;
    begin
        // [FEATURE] [Intrastat Report Setup] [UT]
        // [SCENARIO 255730] An error has been shown trying to delete vendor specified in the Intrastat Report Setup as an intrastat contact
        Initialize();

        // Empty setup record
        IntrastatReportSetup.Delete();
        LibraryPurchase.CreateVendor(Vendor[1]);
        Vendor[1].Delete(true);

        // Existing setup with other contact
        LibraryIntrastat.IntrastatSetupEnableReportReceipts();
        LibraryPurchase.CreateVendor(Vendor[1]);
        LibraryPurchase.CreateVendor(Vendor[2]);
        IntrastatReportSetup.Get();
        ValidateIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor, Vendor[1]."No.");
        Vendor[2].Delete(true);

        // Existing setup with the same contact
        asserterror Vendor[1].Delete(true);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo(OnDelVendorIntrastatContactErr, Vendor[1]."No."));
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestEmptyTariffNoIsBlocking()
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - Error in case of empty "Tariff No."
        // [GIVEN] Posted Sales Order for intrastat without "Tariff No."
        // [GIVEN] Intrastat Report
        Initialize();

        InvoiceDate := CalcDate('<5Y>');
        WorkDate(InvoiceDate);
        LibraryIntrastat.CreateAndPostSalesOrderWithInvoice(SalesLine, InvoiceDate);
        WorkDate(Today);

        Item.Get(SalesLine."No.");
        Item.Validate("Tariff No.", '');
        Item.Modify(true);

        // [GIVEN] A Intrastat Report with empty "Tariff No."
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo, Periodicity::Month, Type::Sales, false, IncStr(FileNo), false);
        Commit();

        // [WHEN] Running Checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You got an error on Tariff no.
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldName("Tariff No."));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals(IntrastatReportLine.FieldName("Tariff No."));
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestEmptyCountryCodeIsBlocking()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - Error in case of empty "Country/Region Code"
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Intrastat Report
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        WorkDate(InvoiceDate);
        LibraryIntrastat.CreateAndPostSalesOrderWithInvoice(SalesLine, InvoiceDate);
        WorkDate(Today);
        Commit();

        // [GIVEN] A Intrastat Report with empty "Country/Region Code" line
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo, Periodicity::Month, Type::Sales, false, IncStr(FileNo), false);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.ModifyAll("Country/Region Code", '');

        // [WHEN] Running Checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You got a error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldName("Country/Region Code"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals(IntrastatReportLine.FieldName("Country/Region Code"));
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestEmptyTransactionTypeIsBlocking()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - Error in case of empty "Transaction Type"
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Intrastat Report
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        WorkDate(InvoiceDate);
        LibraryIntrastat.CreateAndPostSalesOrderWithInvoice(SalesLine, InvoiceDate);
        WorkDate(Today);
        Commit();

        // [GIVEN] A Intrastat Report with empty "Transaction Type" line
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo, Periodicity::Month, Type::Sales, false, IncStr(FileNo), false);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.ModifyAll("Transaction Type", '');

        // [WHEN] Running Checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You got a error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldCaption("Transaction Type"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals(IntrastatReportLine.FieldCaption("Transaction Type"));
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestEmptyQtyIsBlocking()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - Error in case of empty "Quantity" and "Supplementary Units" = true
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Intrastat Report
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        WorkDate(InvoiceDate);
        LibraryIntrastat.CreateAndPostSalesOrderWithInvoice(SalesLine, InvoiceDate);
        WorkDate(Today);
        Commit();

        // [GIVEN] A Intrastat Report with empty Quantity and "Supplementary Units" = false
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo, Periodicity::Month, Type::Sales, false, IncStr(FileNo), false);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.ModifyAll(Quantity, 0);
        IntrastatReportLine.ModifyAll("Supplementary Units", false);

        // [WHEN] Running checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] Check no error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldName(Quantity));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [GIVEN] A Intrastat Report with empty Quantity and "Supplementary Units" = true
        IntrastatReportLine.ModifyAll("Supplementary Units", true);
        // [WHEN] Running Create File
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You got a error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldName(Quantity));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals(IntrastatReportLine.FieldName(Quantity));
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestEmptyTotalWeightIsBlocking()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - Error in case of empty "Total Weight" and "Supplementary Units" = false
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Intrastat Report
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        WorkDate(InvoiceDate);
        LibraryIntrastat.CreateAndPostSalesOrderWithInvoice(SalesLine, InvoiceDate);
        WorkDate(Today);
        Commit();

        // [GIVEN] A Intrastat Report with empty "Total Weight" and "Supplementary Units" = true
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo, Periodicity::Month, Type::Sales, false, IncStr(FileNo), false);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.ModifyAll("Total Weight", 0);
        IntrastatReportLine.ModifyAll("Supplementary Units", true);

        // [WHEN] Running checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] Check no error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldName("Total Weight"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [GIVEN] A Intrastat Report with empty "Total Weight" and "Supplementary Units" = false
        IntrastatReportLine.ModifyAll("Supplementary Units", false);
        // [WHEN] Running Create File
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You got a error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldName("Total Weight"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals(IntrastatReportLine.FieldName("Total Weight"));
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestEmptyCountryOfOriginIsBlocking()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - Error in case of empty "Country/Region of Origin Code" and Type = Shipment
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Intrastat Report
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        WorkDate(InvoiceDate);
        LibraryIntrastat.CreateAndPostSalesOrderWithInvoice(SalesLine, InvoiceDate);
        WorkDate(Today);
        Commit();

        // [GIVEN] A Intrastat Report with empty "Country/Region of Origin Code" and Type = Receipt
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo, Periodicity::Month, Type::Sales, false, IncStr(FileNo), false);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.ModifyAll("Country/Region of Origin Code", '');
        IntrastatReportLine.ModifyAll(Type, IntrastatReportLine.Type::Receipt);

        // [WHEN] Running checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] Check no error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldName("Country/Region of Origin Code"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [GIVEN] A Intrastat Report with empty "Country/Region of Origin Code" and Type = Shipment
        IntrastatReportLine.ModifyAll(Type, IntrastatReportLine.Type::Shipment);
        // [WHEN] Running Create File
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You got a error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldName("Country/Region of Origin Code"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals(IntrastatReportLine.FieldName("Country/Region of Origin Code"));
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestEmptyPartnerVATIDIsBlocking()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - Error in case of empty "Partner VAT ID" and Type = Shipment
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Intrastat Report
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        WorkDate(InvoiceDate);
        LibraryIntrastat.CreateAndPostSalesOrderWithInvoice(SalesLine, InvoiceDate);
        WorkDate(Today);
        Commit();

        // [GIVEN] A Intrastat Report with empty "Partner VAT ID" and Type = Receipt
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo, Periodicity::Month, Type::Sales, false, IncStr(FileNo), false);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.ModifyAll("Partner VAT ID", '');
        IntrastatReportLine.ModifyAll(Type, IntrastatReportLine.Type::Receipt);

        // [WHEN] Running checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] Check no error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldCaption("Partner VAT ID"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [GIVEN] A Intrastat Report with empty "Total Weight" and "Supplementary Units" = false
        IntrastatReportLine.ModifyAll(Type, IntrastatReportLine.Type::Shipment);
        // [WHEN] Running Create File
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You got a error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldCaption("Partner VAT ID"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals(IntrastatReportLine.FieldCaption("Partner VAT ID"));
        IntrastatReportPage.Close();
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure CreateFileMessageHandler(Message: Text)
    begin
        Assert.AreEqual('One or more errors were found. You must resolve all the errors before you can proceed.', Message, '');
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure E2EErrorHandlingOfIntrastatReport()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - End to end error handling
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Report Template and Batch 
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        WorkDate(InvoiceDate);
        LibraryIntrastat.CreateAndPostSalesOrderWithInvoice(SalesLine, InvoiceDate);
        WorkDate(Today);
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo, Periodicity::Month, Type::Sales, false, IncStr(FileNo), false);
        Commit();

        // [GIVEN] A Intrastat Report
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);

        // [WHEN] Running Checklist
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You got a error
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldName("Transaction Specification"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals(IntrastatReportLine.FieldName("Transaction Specification"));

        // [WHEN] Fixing the error
        ValidateMissingFields(IntrastatReportPage);

        // [WHEN] Running Checklist
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You no more errors
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [WHEN] Running Create File
        // [THEN] You do not get any errors
        IntrastatReportPage.CreateFile.Invoke();

        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [Scope('OnPrem')]
    procedure TestSupplementaryInfoFromTariffNo()
    var
        TariffNumber: Record "Tariff Number";
        Item: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        ItemOUM: Record "Item Unit of Measure";
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 451276] Deliverable 451276: Test supplementary info validation between Tariff number and item 

        // Create Unit of Measure
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        // Create Tariff Number 
        TariffNumber.Get(LibraryUtility.CreateCodeRecord(DATABASE::"Tariff Number"));
        // Validate Supplementary Info fields
        TariffNumber.Validate("Supplementary Units", true);
        TariffNumber.Validate("Suppl. Unit of Measure", UnitOfMeasure.Code);
        TariffNumber.Validate("Suppl. Conversion Factor", 3);
        TariffNumber.Modify(true);

        // Create Item with Tariff number
        LibraryInventory.CreateItemWithTariffNo(Item, TariffNumber."No.");
        // Get created Item Unit Of Measure 
        ItemOUM.Get(Item."No.", UnitOfMeasure.Code);

        // Compare Values
        Assert.AreEqual(Item."Supplementary Unit of Measure", TariffNumber."Suppl. Unit of Measure", StrSubstNo(TariffItemInfoDifferentErr, Item.FieldCaption("Supplementary Unit of Measure"), Item.TableCaption, TariffNumber.TableCaption));
        Assert.AreEqual(ItemOUM."Qty. per Unit of Measure", 0.33333, StrSubstNo(TariffItemInfoDifferentErr, ItemOUM.FieldCaption("Qty. per Unit of Measure"), ItemOUM.TableCaption, TariffNumber.TableCaption));

        // Update Supplementary Info on Tariff number
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        TariffNumber.Validate("Suppl. Unit of Measure", UnitOfMeasure.Code);
        TariffNumber.Validate("Suppl. Conversion Factor", 0.5);
        TariffNumber.Modify(true);

        // Get Item and Item Unit Of Measure
        Item.Get(Item."No.");
        ItemOUM.Get(Item."No.", UnitOfMeasure.Code);

        // Compare Values
        Assert.AreEqual(Item."Supplementary Unit of Measure", TariffNumber."Suppl. Unit of Measure", StrSubstNo(TariffItemInfoDifferentErr, Item.FieldCaption("Supplementary Unit of Measure"), Item.TableCaption, TariffNumber.TableCaption));
        Assert.AreEqual(ItemOUM."Qty. per Unit of Measure", 2, StrSubstNo(TariffItemInfoDifferentErr, ItemOUM.FieldCaption("Qty. per Unit of Measure"), ItemOUM.TableCaption, TariffNumber.TableCaption));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler,IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure ShptMethodCodeJobJournal()
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        ShipmentMethod: Record "Shipment Method";
        Location: Record Location;
        IntrastatReportNo: Code[20];
        ItemNo: Code[20];
    begin
        // [FEATURE] [Job]
        // [SCENARIO] User creates and posts job journal and fills Intrastat Report
        Initialize();
        // [GIVEN] Shipment Method "SMC"
        ShipmentMethod.FindFirst();
        // [GIVEN] Location "X"
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        // [GIVEN] Job Journal Line (posted) with item, "X" and "SMC"
        ItemNo := LibraryIntrastat.CreateAndPostJobJournalLine(ShipmentMethod.Code, Location.Code);
        // [WHEN] Run Intrastat Report, then Get Entries 
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo, Periodicity::Month, Type::Sales, false, IncStr(FileNo), false);

        // [THEN] "Shpt. Method Code" in the Intrastat Report Line = "SMC"
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.SetRange("Item No.", ItemNo);
        IntrastatReportLine.FindFirst();
        Assert.IsTrue(1 = 1, ShptMethodCodeErr);
        Assert.AreEqual(ShipmentMethod.Code, IntrastatReportLine."Shpt. Method Code", ShptMethodCodeErr);
        // [THEN] "Location Code" is "X" in the Intrastat Report Line = "SMC"
        // BUG 384736: "Location Code" copies to the Intrastat Report Line from the source documents
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,MessageHandlerEmpty')]
    [Scope('OnPrem')]
    procedure IntrastatReportWithItemChargeInvoiceRevoked()
    var
        PostingDate: Date;
        DocumentNo: Code[20];
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Corrective Credit Memo] [Item Charge]
        // [SCENARIO 286107] Item Charge entry posted by Credit Memo must not be reported in Intrastat Report
        Initialize();

        // [GIVEN] Sales Invoice with Item and Item Charge posted on 'X'
        PostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        DocumentNo := LibraryIntrastat.CreateAndPostSalesInvoiceWithItemAndItemCharge(PostingDate);
        // [GIVEN] Sales Credit Memo with Item Charge posted on 'Y'='X'+<1M>
        PostingDate := CalcDate('<1M>', PostingDate);
        DocumentNo := LibraryIntrastat.CreateAndPostSalesCrMemoForItemCharge(DocumentNo, PostingDate);

        // [WHEN] Get Intrastat Entries to include only Sales Credit Memo
        CreateIntrastatReportAndSuggestLines(PostingDate, IntrastatReportNo, Periodicity::Month, Type::Sales, true, IncStr(FileNo), false);

        // [THEN] Intrastat line for Item Charge from Sales Credit Memo does not exist        
        VerifyIntrastatReportLineExist(IntrastatReportNo, DocumentNo, false);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure IntrastatReportWithItemChargeInvoiced()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        PostingDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [SCENARIO 286107] Item Charge entry posted by Sales Invoice must not be reported in Intrastat Report
        Initialize();

        // [GIVEN] Item Ledger Entry with Quantity < 0
        PostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        LibraryIntrastat.CreateItemLedgerEntry(
          ItemLedgerEntry,
          PostingDate,
          LibraryInventory.CreateItemNo(),
          -LibraryRandom.RandInt(100),
          ItemLedgerEntry."Entry Type"::Sale);
        // [GIVEN] Value Entry with "Document Type" != "Sales Credit Memo" and "Item Charge No" posted in <1M>
        PostingDate := CalcDate('<1M>', PostingDate);

        LibraryIntrastat.CreateValueEntry(ValueEntry, ItemLedgerEntry, ValueEntry."Document Type"::"Sales Invoice", PostingDate);

        // [WHEN] Get Intrastat Entries on second posting date
        CreateIntrastatReportAndSuggestLines(PostingDate, IntrastatReportNo, Periodicity::Month, Type::Sales, false, IncStr(FileNo), false);

        // [THEN] Intrastat line for Item Charge from Sales Credit Memo does not exist        
        VerifyIntrastatReportLineExist(IntrastatReportNo, '', false);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatReportWithServiceItem()
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Item: Record Item;
        IntrastatReportNo: Code[20];
    begin
        // [SCENARIO 295736] Item Ledger Entry with Item Type = Service should not be suggested for Intrastat Report
        Initialize();

        // [GIVEN] Item Ledger Entry with Service Type Item
        LibraryInventory.CreateServiceTypeItem(Item);
        LibraryIntrastat.CreateItemLedgerEntry(
          ItemLedgerEntry,
          WorkDate(),
          Item."No.",
          LibraryRandom.RandInt(100),
          ItemLedgerEntry."Entry Type"::Sale);

        // [WHEN] Get Intrastat Entries
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo, Periodicity::Month, Type::Sales, false, IncStr(FileNo), false);

        // [THEN] There is no Intrastat Line with Item
        IntrastatReportLine.SetRange("Item No.", ItemLedgerEntry."Item No.");
        Assert.RecordIsEmpty(IntrastatReportLine);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatReportGetEntriesProcessesLinesWithoutLocation()
    var
        CountryRegion: Record "Country/Region";
        Location: Record Location;
        LocationEU: Record Location;
        TransferLine: Record "Transfer Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        ItemNo: Code[20];
        IntrastatReportNo: Code[20];
    begin
        // [SCENARIO 315430] "Get Item Ledger Entries" report generates Intrastat Jnl. Lines when transit Item Ledger Entries have no Location.
        Initialize();

        // [GIVEN] Posted sales order with "Location Code" = "X"
        LibraryIntrastat.CreateCountryRegion(CountryRegion, true);
        ItemNo := LibraryIntrastat.CreateItem();
        LibraryIntrastat.CreateFromToLocations(Location, LocationEU, CountryRegion.Code);
        LibraryIntrastat.CreateAndPostPurchaseItemJournalLine(Location.Code, ItemNo);
        LibraryIntrastat.CreateAndPostSalesOrderWithCountryAndLocation(CountryRegion.Code, Location.Code, ItemNo);
        // [GIVEN] Posted transfer order with blank transit location.
        LibraryIntrastat.CreateAndPostTransferOrder(TransferLine, Location.Code, LocationEU.Code, ItemNo);

        // [WHEN] Open "Intrastat Report" page.
        CreateIntrastatReportAndSuggestLines(CalcDate('<CM>', WorkDate()), IntrastatReportNo, Periodicity::Month, Type::Sales, false, IncStr(FileNo), false);

        // [THEN] "Intrastat Jnl. Line" is created for posted sales order.
        IntrastatReportLine.Reset();
        IntrastatReportLine.SetRange("Item No.", ItemNo);
        Assert.IsTrue(IntrastatReportLine.FindFirst(), '');

        // [THEN] "Intrastat Jnl. Line" has "Location Code" = "X"
        // BUG 384736: "Location Code" copies to the Intrastat Report Line from the source documents
        IntrastatReportLine.TestField("Location Code", Location.Code);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetCountryOfOriginFromItem()
    var
        Item: Record Item;
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 373278] GetCountryOfOriginCode takes value from Item when it is not blank
        Item."No." := LibraryUtility.GenerateGUID();
        Item."Country/Region of Origin Code" :=
          LibraryUtility.GenerateRandomCode(Item.FieldNo("Country/Region of Origin Code"), DATABASE::Item);
        Item.Insert();
        IntrastatReportLine.Init();
        IntrastatReportLine."Item No." := Item."No.";

        Assert.AreEqual(
          Item."Country/Region of Origin Code", IntrastatReportLine.GetCountryOfOriginCode(), '');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler,IntrastatReportGetLinesPageHandler')]
    procedure GetPartnerIDFromVATRegNoOfSalesInvoice()
    var
        SellToCustomer: Record Customer;
        BillToCustomer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentNo: Code[20];
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Sales] [Shipment]
        // [SCENARIO 422720] Partner VAT ID is taken as VAT Registration No from Sell-to Customer No. of Sales Invoice
        Initialize();

        // [GIVEN] G/L Setup "Bill-to/Sell-to VAT Calc." = "Bill-to/Pay-to No."
        // [GIVEN] Shipment on Sales Invoice = false
        LibraryIntrastat.UpdateShipmentOnInvoiceSalesSetup(false);

        // [GIVEN] Sell-to Customer with VAT Registration No = 'AT0123456'
        // [GIVEN] Bill-to Customer with VAT Registration No = 'DE1234567'
        // [GIVEN] Sales Invoice with different Sell-to and Bill-To customers
        SellToCustomer.Get(LibraryIntrastat.CreateCustomerWithVATRegNo(true));
        BillToCustomer.Get(LibraryIntrastat.CreateCustomerWithVATRegNo(true));
        LibraryIntrastat.CreateSalesDocument(
            SalesHeader, SalesLine, SellToCustomer."No.", WorkDate(), SalesLine."Document Type"::Invoice,
            SalesLine.Type::Item, LibraryIntrastat.CreateItem(), 1);
        SalesHeader.Validate("Bill-to Customer No.", BillToCustomer."No.");
        SalesHeader.Modify(true);

        // [GIVEN] Post the invoice
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Suggest Intrastat Report Lines
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo, Periodicity::Month, Type::Sales, false, IncStr(FileNo), false);
        IntrastatReportHeader.Get(IntrastatReportNo);

        // [THEN] Posted Sales Invoice has VAT Registration No. = 'DE1234567'
        // [THEN] Partner VAT ID  = 'AT0123456' in Intrastat Report Line
        SalesInvoiceHeader.Get(DocumentNo);
        SalesInvoiceHeader.TestField("VAT Registration No.", BillToCustomer."VAT Registration No.");
        VerifyPartnerID(IntrastatReportHeader, SalesLine."No.", SellToCustomer."VAT Registration No.");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler,IntrastatReportGetLinesPageHandler')]
    procedure GetPartnerIDFromVATRegNoOfSalesShipment()
    var
        SellToCustomer: Record Customer;
        BillToCustomer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Sales] [Shipment]
        // [SCENARIO 422720] Partner VAT ID is taken as VAT Registration No from Sell-to Customer No. of Sales Shipment
        Initialize();

        // [GIVEN] G/L Setup "Bill-to/Sell-to VAT Calc." = "Bill-to/Pay-to No."
        // [GIVEN] Shipment on Sales Invoice = true
        LibraryIntrastat.UpdateShipmentOnInvoiceSalesSetup(true);

        // [GIVEN] Sell-to Customer with VAT Registration No = 'AT0123456'
        // [GIVEN] Bill-to Customer with VAT Registration No = 'DE1234567'
        // [GIVEN] Sales Invoice with different Sell-to and Bill-To customers
        SellToCustomer.Get(LibraryIntrastat.CreateCustomerWithVATRegNo(true));
        BillToCustomer.Get(LibraryIntrastat.CreateCustomerWithVATRegNo(true));
        LibraryIntrastat.CreateSalesDocument(
             SalesHeader, SalesLine, SellToCustomer."No.", WorkDate(), SalesLine."Document Type"::Invoice,
             SalesLine.Type::Item, LibraryIntrastat.CreateItem(), 1);
        SalesHeader.Validate("Bill-to Customer No.", BillToCustomer."No.");
        SalesHeader.Modify(true);

        // [GIVEN] Post the invoice
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Suggest Intrastat Report Lines
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo, Periodicity::Month, Type::Sales, false, IncStr(FileNo), false);
        IntrastatReportHeader.Get(IntrastatReportNo);

        // [THEN] Posted Sales Shipment has VAT Registration No. = 'DE1234567'
        // [THEN] Partner VAT ID  = 'AT0123456' in Intrastat Report Line
        SalesShipmentHeader.SetRange("Bill-to Customer No.", BillToCustomer."No.");
        SalesShipmentHeader.FindFirst();
        SalesShipmentHeader.TestField("VAT Registration No.", BillToCustomer."VAT Registration No.");
        VerifyPartnerID(IntrastatReportHeader, SalesLine."No.", SellToCustomer."VAT Registration No.");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure GetPartnerIDFromVATRegNoOfPurchaseCrMemo()
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Purchase] [Return Shipment]
        // [SCENARIO 373278] Partner VAT ID is taken as VAT Registration No from Pay-to Vendor No. of Purchase Credit Memo
        Initialize();

        // [GIVEN] Return Shipment on Credit Memo = false
        LibraryIntrastat.UpdateRetShpmtOnCrMemoPurchSetup(false);

        // [GIVEN] Pay-to Vendor with VAT Registration No = 'AT0123456'
        Vendor.Get(LibraryIntrastat.CreateVendorWithVATRegNo(true));
        LibraryIntrastat.CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", WorkDate(), Vendor."No.");
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, LibraryIntrastat.CreateItem());
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Intrastat Report Line is created
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo, Periodicity::Month, Type::Purchase, true, IncStr(FileNo), false);
        IntrastatReportHeader.Get(IntrastatReportNo);

        // [THEN] Partner VAT ID  = 'AT0123456' in Intrastat Report Line
        PurchCrMemoHdr.SetRange("Pay-to Vendor No.", Vendor."No.");
        PurchCrMemoHdr.FindFirst();
        VerifyPartnerID(IntrastatReportHeader, PurchaseLine."No.", Vendor."VAT Registration No.");
        VerifyPartnerID(IntrastatReportHeader, PurchaseLine."No.", PurchCrMemoHdr."VAT Registration No.");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure GetPartnerIDFromVATRegNoOfPurchaseReturnOrder()
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Purchase] [Return Shipment]
        // [SCENARIO 373278] Partner VAT ID is taken as VAT Registration No from Pay-to Vendor No. of Purchase Return Order
        Initialize();

        // [GIVEN] Return Shipment on Credit Memo = true
        LibraryIntrastat.UpdateRetShpmtOnCrMemoPurchSetup(true);

        // [GIVEN] Pay-to Vendor with VAT Registration No = 'AT0123456'
        Vendor.Get(LibraryIntrastat.CreateVendorWithVATRegNo(true));
        LibraryIntrastat.CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", WorkDate(), Vendor."No.");
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, LibraryIntrastat.CreateItem());
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Intrastat Report Line is created
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo, Periodicity::Month, Type::Purchase, true, IncStr(FileNo), false);
        IntrastatReportHeader.Get(IntrastatReportNo);

        // [THEN] Partner VAT ID  = 'AT0123456' in Intrastat Report Line
        ReturnShipmentHeader.SetRange("Buy-from Vendor No.", Vendor."No.");
        ReturnShipmentHeader.FindFirst();
        VerifyPartnerID(IntrastatReportHeader, PurchaseLine."No.", Vendor."VAT Registration No.");
        VerifyPartnerID(IntrastatReportHeader, PurchaseLine."No.", ReturnShipmentHeader."VAT Registration No.");
    end;

    [Test]
    procedure FieldReportedIsCheckedOnModify()
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [UT]
        // [SCENARIO 402692] Intrastat Report batch "Reported" should be False on Modify the journal line
        Initialize();
        // Positive
        LibraryIntrastat.CreateIntrastatReportLine(IntrastatReportLine);
        IntrastatReportLine.Modify(true);

        // Negative
        LibraryIntrastat.CreateIntrastatReport(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);
        LibraryIntrastat.CreateIntrastatReportLineinIntrastatReport(IntrastatReportLine, IntrastatReportNo);
        IntrastatReportHeader.Status := IntrastatReportHeader.Status::Released;
        IntrastatReportHeader.Modify();

        asserterror IntrastatReportLine.Modify(true);
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError(IntrastatReportHeader.FieldName(Status));
    end;

    [Test]
    procedure FieldReportedIsCheckedOnRename()
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [UT]
        // [SCENARIO 402692] Intrastat Report batch "Reported" should be False on Rename the journal line
        Initialize();
        // Positive
        LibraryIntrastat.CreateIntrastatReportLine(IntrastatReportLine);
        IntrastatReportLine.Rename(
          IntrastatReportLine."Intrastat No.", IntrastatReportLine."Line No." + 10000);

        // Negative
        LibraryIntrastat.CreateIntrastatReport(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);
        LibraryIntrastat.CreateIntrastatReportLineinIntrastatReport(IntrastatReportLine, IntrastatReportNo);
        IntrastatReportHeader.Status := IntrastatReportHeader.Status::Released;
        IntrastatReportHeader.Modify();

        asserterror IntrastatReportLine.Rename(
            IntrastatReportLine."Intrastat No.", IntrastatReportLine."Line No." + 10000);
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError(IntrastatReportHeader.FieldName(Status));
    end;

    [Test]
    procedure FieldReportedIsCheckedOnDelete()
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [UT]
        // [SCENARIO 402692] Intrastat Report batch "Reported" should be False on Delete the journal line
        Initialize();
        // Positive        
        LibraryIntrastat.CreateIntrastatReport(WorkDate(), IntrastatReportNo);
        LibraryIntrastat.CreateIntrastatReportLineinIntrastatReport(IntrastatReportLine, IntrastatReportNo);
        IntrastatReportLine.Delete(true);

        // Negative
        LibraryIntrastat.CreateIntrastatReport(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);
        LibraryIntrastat.CreateIntrastatReportLineinIntrastatReport(IntrastatReportLine, IntrastatReportNo);
        IntrastatReportHeader.Status := IntrastatReportHeader.Status::Released;
        IntrastatReportHeader.Modify();

        asserterror IntrastatReportLine.Delete(true);
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError(IntrastatReportHeader.FieldName(Status));
    end;

    [Test]
    procedure BatchStatisticsPeriodFormatValidation()
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
    begin
        // [FEATURE] [UI] [UT]
        // [SCENARIO 419963] Intrastat Report batch "Statistics Period" validation
        Initialize();

        asserterror IntrastatReportHeader.Validate("Statistics Period", '12345');
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo(StatPeriodFormatErr, IntrastatReportHeader.FieldCaption("Statistics Period")));

        asserterror IntrastatReportHeader.Validate("Statistics Period", '0122');
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StatPeriodMonthErr);

        IntrastatReportHeader.Validate("Statistics Period", '2201'); // YYMM
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure IntrastatReportLineForFixedAssetPurchase()
    var
        PurchaseLine: Record "Purchase Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO] Check Intrastat Report Line for Fixed Asset posted Purchase Order.

        // [GIVEN] Posted Purchase Order
        Initialize();
        DocumentNo := LibraryIntrastat.CreateAndPostFixedAssetPurchaseOrder(PurchaseLine, WorkDate());
        // [WHEN] Get Intrastat Report Line for Fixed Asset Purchase Order
        // [THEN] Verify Intrastat Report Line
        CreateAndVerifyIntrastatLine(DocumentNo, PurchaseLine."No.", PurchaseLine.Quantity, IntrastatReportLine.Type::Receipt, Periodicity::Month, Type::Purchase);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure IntrastatReportLineForFixedAssetSale()
    var
        PurchaseLine: Record "Purchase Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO] Check Intrastat Report Line for Fixed Asset for posted Sales Order.

        Initialize();
        // [GIVEN] Create and post Aquisition Purchase Order
        DocumentNo := LibraryIntrastat.CreateAndPostFixedAssetPurchaseOrder(PurchaseLine, WorkDate());
        // [GIVEN] Create and Post Disposal Sales Order
        DocumentNo := LibraryIntrastat.CreateAndPostSalesDocumentMultiLine(
            SalesLine, SalesHeader."Document Type"::Order, WorkDate(), SalesLine.Type::"Fixed Asset", PurchaseLine."No.", 1);

        // [WHEN] Get Intrastat Report Lines for Sales Order
        // [THEN] Verify Intrastat Report Line
        CreateAndVerifyIntrastatLine(DocumentNo, SalesLine."No.", SalesLine.Quantity, IntrastatReportLine.Type::Shipment, Periodicity::Month, Type::Sales);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure E2EIntrastatReportITFileCreationNSM()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report IT] [File Validation]
        // [SCENARIO] End to end file creation
        // [GIVEN] Posted Sales Order for intrastat
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        LibraryIntrastat.CreateAndPostSalesOrderWithInvoice(SalesLine, InvoiceDate);
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo, Periodicity::Month, Type::Sales, false, '111', false);
        Commit();

        // [GIVEN] A Intrastat Report
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        ValidateMissingFields(IntrastatReportPage);

        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] No errors surfaced from checklist
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [WHEN] Running Create File
        IntrastatReportPage.CreateFile.Invoke();

        // [THEN] Check file content for sales monthly invoice 
        CheckFileContentForNormalReporting(IntrastatReportPage, 'C', 'M');
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure E2EIntrastatReportITFileCreationNPM()
    var
        PurchaseLine: Record "Purchase Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report IT] [File Validation]
        // [SCENARIO] End to end file creation
        // [GIVEN] Posted Purchase Order for intrastat
        // [GIVEN] Report Template and Batch        
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        LibraryIntrastat.CreateAndPostPurchaseOrderWithInvoice(PurchaseLine, InvoiceDate);
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo, Periodicity::Month, Type::Purchase, false, '222', false);
        Commit();

        // [GIVEN] A Intrastat Report
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        ValidateMissingFields(IntrastatReportPage);

        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] No errors surfaced from checklist
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [WHEN] Running Create File
        IntrastatReportPage.CreateFile.Invoke();

        // [THEN] Check file content for purchase monthly invoice 
        CheckFileContentForNormalReporting(IntrastatReportPage, 'A', 'M');
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure E2EIntrastatReportITFileCreationNSQ()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report IT] [File Validation]
        // [SCENARIO] End to end file creation
        // [GIVEN] Posted Sales Order for intrastat
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        LibraryIntrastat.CreateAndPostSalesOrderWithInvoice(SalesLine, InvoiceDate);
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo, Periodicity::Quarter, Type::Sales, false, '333', false);
        Commit();

        // [GIVEN] A Intrastat Report
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        ValidateMissingFields(IntrastatReportPage);

        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] No errors surfaced from checklist
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [WHEN] Running Create File
        IntrastatReportPage.CreateFile.Invoke();

        // [THEN] Check file content for sales quarterly invoice 
        CheckFileContentForNormalReporting(IntrastatReportPage, 'C', 'T');
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure E2EIntrastatReportITFileCreationNPQ()
    var
        PurchaseLine: Record "Purchase Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report IT] [File Validation]
        // [SCENARIO] End to end file creation
        // [GIVEN] Posted Purchase Order for intrastat
        // [GIVEN] Report Template and Batch        
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        LibraryIntrastat.CreateAndPostPurchaseOrderWithInvoice(PurchaseLine, InvoiceDate);
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo, Periodicity::Quarter, Type::Purchase, false, '444', false);
        Commit();

        // [GIVEN] A Intrastat Report
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        ValidateMissingFields(IntrastatReportPage);

        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] No errors surfaced from checklist
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [WHEN] Running Create File
        IntrastatReportPage.CreateFile.Invoke();

        // [THEN] Check file content for purchase quaterly invoice 
        CheckFileContentForNormalReporting(IntrastatReportPage, 'A', 'T');
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure E2EIntrastatReportITFileCreationCSM()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report IT] [File Validation]
        // [SCENARIO] End to end file creation
        // [GIVEN] Posted Sales Order for intrastat
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        CreateAndPostCorrectiveSalesCrMemo(LibraryIntrastat.CreateAndPostSalesOrderWithInvoice(SalesLine, InvoiceDate), CalcDate('<+1M>', InvoiceDate));
        CreateIntrastatReportAndSuggestLines(CalcDate('<+1M>', InvoiceDate), IntrastatReportNo, Periodicity::Month, Type::Sales, true, '555', false);
        Commit();

        // [GIVEN] A Intrastat Report
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        ValidateMissingFields(IntrastatReportPage);

        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] No errors surfaced from checklist
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [WHEN] Running Create File
        IntrastatReportPage.CreateFile.Invoke();

        // [THEN] Check file content for sales monthly correction
        CheckFileContentForCorrectionReporting(IntrastatReportPage, 'C', 'M');
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure E2EIntrastatReportITFileCreationCPM()
    var
        PurchaseLine: Record "Purchase Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report IT] [File Validation]
        // [SCENARIO] End to end file creation
        // [GIVEN] Posted Sales Order for intrastat
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        WorkDate(InvoiceDate);
        CreateAndPostCorrectivePurchCrMemo(LibraryIntrastat.CreateAndPostPurchaseOrderWithInvoice(PurchaseLine, InvoiceDate), CalcDate('<+1M>', InvoiceDate));
        WorkDate(Today);
        CreateIntrastatReportAndSuggestLines(CalcDate('<+1M>', InvoiceDate), IntrastatReportNo, Periodicity::Month, Type::Purchase, true, '666', false);
        Commit();

        // [GIVEN] A Intrastat Report
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        ValidateMissingFields(IntrastatReportPage);

        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] No errors surfaced from checklist
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [WHEN] Running Create File
        IntrastatReportPage.CreateFile.Invoke();

        // [THEN] Check file content for purchase monthly correction
        CheckFileContentForCorrectionReporting(IntrastatReportPage, 'A', 'M');
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure E2EIntrastatReportITFileCreationCSQ()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report IT] [File Validation]
        // [SCENARIO] End to end file creation
        // [GIVEN] Posted Sales Order for intrastat
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        CreateAndPostCorrectiveSalesCrMemo(LibraryIntrastat.CreateAndPostSalesOrderWithInvoice(SalesLine, InvoiceDate), CalcDate('<+1Q>', InvoiceDate));
        CreateIntrastatReportAndSuggestLines(CalcDate('<+1Q>', InvoiceDate), IntrastatReportNo, Periodicity::Quarter, Type::Sales, true, '777', false);
        Commit();

        // [GIVEN] A Intrastat Report
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        ValidateMissingFields(IntrastatReportPage);

        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] No errors surfaced from checklist
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [WHEN] Running Create File
        IntrastatReportPage.CreateFile.Invoke();

        // [THEN] Check file content for sales quarterly correction
        CheckFileContentForCorrectionReporting(IntrastatReportPage, 'C', 'T');
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure E2EIntrastatReportITFileCreationCPQ()
    var
        PurchaseLine: Record "Purchase Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report IT] [File Validation]
        // [SCENARIO] End to end file creation
        // [GIVEN] Posted Sales Order for intrastat
        Initialize();
        InvoiceDate := CalcDate('<6Y>');
        WorkDate(InvoiceDate);
        CreateAndPostCorrectivePurchCrMemo(LibraryIntrastat.CreateAndPostPurchaseOrderWithInvoice(PurchaseLine, InvoiceDate), CalcDate('<+1Q>', InvoiceDate));
        WorkDate(Today);
        CreateIntrastatReportAndSuggestLines(CalcDate('<+1Q>', InvoiceDate), IntrastatReportNo, Periodicity::Quarter, Type::Purchase, true, '888', false);
        Commit();

        // [GIVEN] A Intrastat Report
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        ValidateMissingFields(IntrastatReportPage);

        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] No errors surfaced from checklist
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [WHEN] Running Create File
        IntrastatReportPage.CreateFile.Invoke();

        // [THEN] Check file content for purchase quarterly correction
        CheckFileContentForCorrectionReporting(IntrastatReportPage, 'A', 'T');
        IntrastatReportPage.Close();
    end;

    local procedure Initialize()
    var
        CompanyInformation: Record "Company Information";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        GLSetupVATCalculation: Enum "G/L Setup VAT Calculation";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Intrastat IT Test");
        LibraryVariableStorage.Clear();
        ResetNoSeries();

        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Intrastat IT Test");
        UpdateIntrastatCodeInCountryRegion();
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.CreateGeneralPostingSetupData();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERM.SetBillToSellToVATCalc(GLSetupVATCalculation::"Bill-to/Pay-to No.");
        LibraryIntrastat.CreateIntrastatReportSetup();
        CreateIntrastatReportChecklist();
        UpdateIntrastatReportSetup();

        CompanyInformation.Get();
        CompanyInformation.Validate("VAT Registration No.", '28051977200');
        CompanyInformation.Modify(true);

        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Intrastat IT Test");
    end;

    local procedure ResetNoSeries()
    var
        NoSeriesLinePurchase: Record "No. Series Line Purchase";
        NoSeriesLineSales: Record "No. Series Line Sales";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
    begin
        if VATBusinessPostingGroup.FindSet() then
            repeat
                NoSeriesLineSales.SetRange("Series Code", VATBusinessPostingGroup."Default Sales Operation Type");
                NoSeriesLineSales.ModifyAll("Last Date Used", 0D);

                NoSeriesLinePurchase.SetRange("Series Code", VATBusinessPostingGroup."Default Purch. Operation Type");
                NoSeriesLinePurchase.ModifyAll("Last Date Used", 0D);
            until VATBusinessPostingGroup.Next() = 0;
    end;

    procedure CreateAndVerifyIntrastatLine(DocumentNo: Code[20]; ItemNo: Code[20]; Quantity: Decimal; IntrastatReportLineType: Enum "Intrastat Report Line Type"; Periodicity: Option Month,Quarter; Type: Option Purchase,Sales)
    var
        IntrastatReportNo: Code[20];
    begin
        // Exercise: Run Get Item Entries. Take Report Date as WORKDATE
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo, Periodicity, Type, false, IncStr(FileNo), false);
        // Verify.
        VerifyIntrastatReportLine(DocumentNo, IntrastatReportNo, IntrastatReportLineType, LibraryIntrastat.GetCountryRegionCode(), ItemNo, Quantity);
    end;

    local procedure VerifyIntrastatReportLineExist(IntrastatReportNo: Code[20]; DocumentNo: Code[20]; MustExist: Boolean)
    var
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        Commit();  // Commit is required to commit the posted entries.
        // Verify: Verify Intrastat Report Line with No entires.
        IntrastatReportLine.SetFilter("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.SetFilter("Document No.", DocumentNo);
        Assert.AreEqual(MustExist, IntrastatReportLine.FindFirst(), LineNotExistErr);
    end;

    local procedure DeleteAndVerifyNoIntrastatLine(DocumentNo: Code[20])
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportNo: Code[20];
    begin
        // Create and Get Intrastat Report Lines. Take Random Ending Date based on WORKDATE.
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo, Periodicity::Month, Type::Purchase, false, IncStr(FileNo), false);

        // Exercise: Delete all entries from Intrastat Report Lines.
        IntrastatReportLine.SetRange("Document No.", DocumentNo);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        LibraryIntrastat.ClearIntrastatReportLines(IntrastatReportNo);

        // Verify.
        VerifyIntrastatLineForItemExist(DocumentNo, IntrastatReportNo);
    end;

    local procedure GetEntriesAndVerifyNoItemLine(DocumentNo: Code[20])
    var
        IntrastatReportNo: Code[20];
    begin
        // Exercise: Run Get Item Entries. Take Starting Date as WORKDATE and Random Ending Date based on WORKDATE.
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo, Periodicity::Month, Type::Purchase, false, IncStr(FileNo), false);
        // Verify:
        VerifyIntrastatLineForItemExist(DocumentNo, IntrastatReportNo);
    end;

    local procedure ValidateIntrastatContact(ContactType: Enum "Intrastat Report Contact Type"; ContactNo: Code[20])
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        with IntrastatReportSetup do begin
            Get();
            Validate("Intrastat Contact Type", ContactType);
            Validate("Intrastat Contact No.", ContactNo);
            Modify(true);
        end;
    end;

    local procedure LookupIntrastatContactViaPage(ContactType: Enum "Intrastat Report Contact Type")
    var
        IntrastatReportSetup: TestPage "Intrastat Report Setup";
    begin
        BindSubscription(LibraryIntrastat);
        IntrastatReportSetup.OpenEdit();
        IntrastatReportSetup."Intrastat Contact Type".SetValue(ContactType);
        IntrastatReportSetup."Intrastat Contact No.".Lookup();
        IntrastatReportSetup.Close();
        UnbindSubscription(LibraryIntrastat);
    end;



    local procedure VerifyIntrastatReportLine(DocumentNo: Code[20]; IntrastatReportNo: Code[20]; Type: Enum "Intrastat Report Line Type"; CountryRegionCode: Code[10];
                                                                                                           ItemNo: Code[20];
                                                                                                           Quantity: Decimal)
    var
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        LibraryIntrastat.GetIntrastatReportLine(DocumentNo, IntrastatReportNo, IntrastatReportLine);

        Assert.AreEqual(
          Type, IntrastatReportLine.Type,
          StrSubstNo(ValidationErr, IntrastatReportLine.FieldCaption(Type), Type, IntrastatReportLine.TableCaption()));

        Assert.AreEqual(
          Quantity, IntrastatReportLine.Quantity,
          StrSubstNo(ValidationErr, IntrastatReportLine.FieldCaption(Quantity), Quantity, IntrastatReportLine.TableCaption()));

        Assert.AreEqual(
            CountryRegionCode, IntrastatReportLine."Country/Region Code", StrSubstNo(ValidationErr,
            IntrastatReportLine.FieldCaption("Country/Region Code"), CountryRegionCode, IntrastatReportLine.TableCaption()));

        Assert.AreEqual(
            ItemNo, IntrastatReportLine."Item No.", StrSubstNo(ValidationErr,
            IntrastatReportLine.FieldCaption("Country/Region Code"), CountryRegionCode, IntrastatReportLine.TableCaption()));
    end;

    local procedure VerifyItemLedgerEntry(DocumentType: Enum "Item Ledger Document Type"; DocumentNo: Code[20];
                                                            CountryRegionCode: Code[10];
                                                            Quantity: Decimal)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetRange("Document Type", DocumentType);
        ItemLedgerEntry.SetRange("Document No.", DocumentNo);
        ItemLedgerEntry.FindFirst();

        Assert.AreEqual(
          CountryRegionCode, ItemLedgerEntry."Country/Region Code", StrSubstNo(ValidationErr,
            ItemLedgerEntry.FieldCaption("Country/Region Code"), CountryRegionCode, ItemLedgerEntry.TableCaption()));

        Assert.AreEqual(
          Quantity, ItemLedgerEntry.Quantity,
          StrSubstNo(ValidationErr, ItemLedgerEntry.FieldCaption(Quantity), Quantity, ItemLedgerEntry.TableCaption()));

        Assert.AreEqual(
          0, ItemLedgerEntry."Invoiced Quantity",
          StrSubstNo(ValidationErr, ItemLedgerEntry.FieldCaption("Invoiced Quantity"), 0, ItemLedgerEntry.TableCaption()));

        Assert.AreEqual(
          Quantity, ItemLedgerEntry."Remaining Quantity",
          StrSubstNo(ValidationErr, ItemLedgerEntry.FieldCaption("Remaining Quantity"), Quantity, ItemLedgerEntry.TableCaption()));
    end;

    local procedure VerifyIntrastatLineForItemExist(DocumentNo: Code[20]; IntrastatNo: Code[20])
    var
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        IntrastatReportLine.SetRange("Document No.", DocumentNo);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatNo);
        Assert.IsFalse(IntrastatReportLine.FindFirst(), LineNotExistErr);
    end;

    local procedure VerifyNoOfIntrastatLinesForDocumentNo(IntrastatReportNo: Code[20]; DocumentNo: Code[20]; LineCount: Integer)
    var
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        with IntrastatReportLine do begin
            SetRange("Intrastat No.", IntrastatReportNo);
            SetRange("Document No.", DocumentNo);
            Assert.AreEqual(
              LineCount, Count,
              StrSubstNo(LineCountErr, TableCaption));
        end;
    end;

    local procedure VerifyIntrastatContact(ContactType: Enum "Intrastat Report Contact Type"; ContactNo: Code[20])
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        with IntrastatReportSetup do begin
            Get();
            TestField("Intrastat Contact Type", ContactType);
            TestField("Intrastat Contact No.", ContactNo);
        end;
    end;

    local procedure VerifyPartnerID(IntrastatReportHeader: Record "Intrastat Report Header"; ItemNo: Code[20]; PartnerID: Text[50])
    var
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportHeader."No.");
        IntrastatReportLine.SetRange("Item No.", ItemNo);
        IntrastatReportLine.FindFirst();
        IntrastatReportLine.TestField("Partner VAT ID", PartnerID);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure IntrastatReportListPageHandler(var IntrastatReportList: TestPage "Intrastat Report List")
    var
        NoVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(NoVariant);
        IntrastatReportList.FILTER.SetFilter("No.", NoVariant);
        IntrastatReportList.OK().Invoke();
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure UndoDocumentConfirmHandler(Message: Text[1024]; var Reply: Boolean)
    begin
        // Send Reply = TRUE for Confirmation Message.
        Reply := true;
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure NoLinesMsgHandler(Message: Text[1024])
    begin
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ContactList_MPH(var ContactList: TestPage "Contact List")
    begin
        ContactList.FILTER.SetFilter("No.", LibraryVariableStorage.DequeueText());
        ContactList.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure VendorList_MPH(var VendorLookup: TestPage "Vendor Lookup")
    begin
        VendorLookup.FILTER.SetFilter("No.", LibraryVariableStorage.DequeueText());
        VendorLookup.OK().Invoke();
    end;

    local procedure CreateIntrastatReportChecklist()
    var
        IntrastatReportChecklist: Record "Intrastat Report Checklist";
    begin
        IntrastatReportChecklist.DeleteAll();

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
        IntrastatReportChecklist.Validate("Field No.", 14);
        IntrastatReportChecklist.Validate("Filter Expression", 'Supplementary Units: True');
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
        IntrastatReportChecklist.Validate("Field No.", 25);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 26);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 27);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 29);
        IntrastatReportChecklist.Validate("Filter Expression", 'Type: Shipment');
        IntrastatReportChecklist.Insert(true);
    end;

    local procedure UpdateIntrastatReportSetup()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        DataExchDef: Record "Data Exch. Def";
        TempBlob: Codeunit "Temp Blob";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
    begin
        IntrastatReportSetup.Get();
        IntrastatReportSetup.Validate("Report Receipts", true);
        IntrastatReportSetup.Validate("Report Shipments", true);

        if not DataExchDef.Get('INTRA-2022-IT-NPM') then begin
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(DataExchangeXMLNPMP1Txt + DataExchangeXMLNPMP2Txt + DataExchangeXMLNPMP3Txt);
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
            Clear(TempBlob);
        end;

        if not DataExchDef.Get('INTRA-2022-IT-NPQ') then begin
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(DataExchangeXMLNPQP1Txt + DataExchangeXMLNPQP2Txt);
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
            Clear(TempBlob);
        end;

        if not DataExchDef.Get('INTRA-2022-IT-NSM') then begin
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(DataExchangeXMLNSMP1Txt + DataExchangeXMLNSMP2Txt + DataExchangeXMLNSMP3Txt);
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
            Clear(TempBlob);
        end;

        if not DataExchDef.Get('INTRA-2022-IT-NSQ') then begin
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(DataExchangeXMLNSQP1Txt + DataExchangeXMLNSQP2Txt);
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
            Clear(TempBlob);
        end;

        if not DataExchDef.Get('INTRA-2022-IT-CPM') then begin
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(DataExchangeXMLCPMP1Txt + DataExchangeXMLCPMP2Txt);
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
            Clear(TempBlob);
        end;

        if not DataExchDef.Get('INTRA-2022-IT-CPQ') then begin
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(DataExchangeXMLCPQP1Txt + DataExchangeXMLCPQP2Txt);
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
            Clear(TempBlob);
        end;

        if not DataExchDef.Get('INTRA-2022-IT-CSM') then begin
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(DataExchangeXMLCSMP1Txt + DataExchangeXMLCSMP2Txt);
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
            Clear(TempBlob);
        end;

        if not DataExchDef.Get('INTRA-2022-IT-CSQ') then begin
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(DataExchangeXMLCSQP1Txt + DataExchangeXMLCSQP2Txt);
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
            Clear(TempBlob);
        end;

        IntrastatReportSetup."Shipments Based On" := IntrastatReportSetup."Shipments Based On"::"Ship-to Country";
        IntrastatReportSetup."Data Exch. Def. Code NPM" := 'INTRA-2022-IT-NPM';
        IntrastatReportSetup."Data Exch. Def. Code NSM" := 'INTRA-2022-IT-NSM';
        IntrastatReportSetup."Data Exch. Def. Code NPQ" := 'INTRA-2022-IT-NPQ';
        IntrastatReportSetup."Data Exch. Def. Code NSQ" := 'INTRA-2022-IT-NSQ';
        IntrastatReportSetup."Data Exch. Def. Code CPM" := 'INTRA-2022-IT-CPM';
        IntrastatReportSetup."Data Exch. Def. Code CSM" := 'INTRA-2022-IT-CSM';
        IntrastatReportSetup."Data Exch. Def. Code CPQ" := 'INTRA-2022-IT-CPQ';
        IntrastatReportSetup."Data Exch. Def. Code CSQ" := 'INTRA-2022-IT-CSQ';
        IntrastatReportSetup.Modify();
    end;

    local procedure CheckFileContent(var IntrastatReportPage: TestPage "Intrastat Report")
    var
        DataExch: Record "Data Exch.";
        FileMgt: Codeunit "File Management";
        LibraryTextFileValidation: Codeunit "Library - Text File Validation";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        Line: Text;
        TabChar: Char;
        DecVar: Decimal;
    begin
        DataExch.FindLast();
        if DataExch."File Content".HasValue then begin
            DataExch.CalcFields("File Content");
            TempBlob.FromRecord(DataExch, DataExch.FieldNo("File Content"));

            FileName := FileMgt.ServerTempFileName('txt');
            FileMgt.BLOBExportToServerFile(TempBlob, FileName);

            TabChar := 9;
            Line := LibraryTextFileValidation.ReadLine(FileName, 1);

            IntrastatReportPage.IntrastatLines."Tariff No.".AssertEquals(LibraryTextFileValidation.ReadField(Line, 1, TabChar).Trim());
            IntrastatReportPage.IntrastatLines."Country/Region Code".AssertEquals(LibraryTextFileValidation.ReadField(Line, 2, TabChar).Trim());
            IntrastatReportPage.IntrastatLines."Transaction Type".AssertEquals(LibraryTextFileValidation.ReadField(Line, 3, TabChar).Trim());
            Evaluate(DecVar, LibraryTextFileValidation.ReadField(Line, 4, TabChar).Trim());
            IntrastatReportPage.IntrastatLines.Quantity.AssertEquals(Format(DecVar));
            Evaluate(DecVar, LibraryTextFileValidation.ReadField(Line, 5, TabChar).Trim());
            IntrastatReportPage.IntrastatLines."Total Weight".AssertEquals(Format(DecVar));
            Evaluate(DecVar, LibraryTextFileValidation.ReadField(Line, 6, TabChar).Trim());
            IntrastatReportPage.IntrastatLines."Statistical Value".AssertEquals(Format(DecVar));
            IntrastatReportPage.IntrastatLines."Partner VAT ID".AssertEquals(LibraryTextFileValidation.ReadField(Line, 8, TabChar).Trim());
            IntrastatReportPage.IntrastatLines."Country/Region of Origin Code".AssertEquals(LibraryTextFileValidation.ReadField(Line, 9, TabChar).Trim());
        end;
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(Message: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(Msg: Text[1024])
    begin
        Assert.IsTrue(
          StrPos(Msg, 'The journal lines were successfully posted.') = 1,
          StrSubstNo('Unexpected Message: %1', Msg))
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandlerEmpty(Msg: Text[1024])
    begin
    end;

    procedure CreateIntrastatReportAndSuggestLines(ReportDate: Date; var IntrastatReportNo: Code[20]; Periodicity2: Option Month,Quarter; Type2: Option Purchase,Sales; Corrective: Boolean; FileDiskNo: Code[20]; IncludeIntraCommunity: Boolean)
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
    begin
        LibraryIntrastat.CreateIntrastatReport(ReportDate, IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);
        if Periodicity2 = Periodicity2::Quarter then
            IntrastatReportHeader.Validate("Statistics Period", GetStatisticalPeriodQuarter(ReportDate));

        IntrastatReportHeader.Validate(Periodicity, Periodicity2);
        IntrastatReportHeader.Validate(Type, Type2);
        IntrastatReportHeader.Validate("Corrective Entry", Corrective);
        IntrastatReportHeader.Validate("File Disk No.", FileDiskNo);
        IntrastatReportHeader.Validate("Include Community Entries", IncludeIntraCommunity);
        IntrastatReportHeader.Modify(true);
        InvokeSuggestLinesOnIntrastatReport(IntrastatReportNo);
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

    procedure InvokeSuggestLinesOnIntrastatReport(IntrastatReportNo: Code[20])
    var
        IntrastatReport: TestPage "Intrastat Report";
    begin
        IntrastatReport.OpenEdit();
        IntrastatReport.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReport.GetEntries.Invoke();
    end;

    local procedure ValidateMissingFields(var IntrastatReportPage: TestPage "Intrastat Report")
    var
        "Area": Record "Area";
        EntryExitPoint: Record "Entry/Exit Point";
        ShipmentMethod: Record "Shipment Method";
        TransactionType: Record "Transaction Type";
        TransactionSpecification: Record "Transaction Specification";
        TransportMethod: Record "Transport Method";
    begin
        TransactionType.FindFirst();
        IntrastatReportPage.IntrastatLines."Transaction Type".Value(TransactionType.Code);

        "Area".FindFirst();
        IntrastatReportPage.IntrastatLines."Area".Value("Area".Code);

        TransactionSpecification.FindFirst();
        IntrastatReportPage.IntrastatLines."Transaction Specification".Value(TransactionSpecification.Code);

        TransportMethod.FindFirst();
        IntrastatReportPage.IntrastatLines."Transport Method".Value(TransportMethod.Code);

        EntryExitPoint.FindFirst();
        IntrastatReportPage.IntrastatLines."Entry/Exit Point".Value(EntryExitPoint.Code);

        ShipmentMethod.FindFirst();
        IntrastatReportPage.IntrastatLines."Shpt. Method Code".Value(ShipmentMethod.Code);

        IntrastatReportPage.IntrastatLines.Quantity.Value(Format(LibraryRandom.RandInt(20)));
        IntrastatReportPage.IntrastatLines."Net Weight".Value(Format(LibraryRandom.RandInt(20)));
        IntrastatReportPage.IntrastatLines."Statistical Value".Value(Format(LibraryRandom.RandInt(100)));
        IntrastatReportPage.IntrastatLines."Partner VAT ID".Value('111111111');
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure IntrastatReportGetLinesPageHandler(var IntrastatReportGetLines: TestRequestPage "Intrastat Report Get Lines")
    begin
        IntrastatReportGetLines.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure IntrastatReportModalPageHandler(var IntrastatReport: TestPage "Intrastat Report")
    var
        IntrastatReportNoVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(IntrastatReportNoVariant);
        IntrastatReport."No.".SetValue(IntrastatReportNoVariant);
        IntrastatReport.First();
        IntrastatReport.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure IntrastatReportChecklistModalPageHandler(var IntrastatReportChecklist: TestPage "Intrastat Report Checklist")
    begin
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure IntrastatReportSetupModalPageHandler(var IntrastatReportSetupPage: TestPage "Intrastat Report Setup")
    begin
    end;

    local procedure UpdateIntrastatCodeInCountryRegion()
    var
        CompanyInformation: Record "Company Information";
        CountryRegion: Record "Country/Region";
    begin
        CompanyInformation.Get();
        CompanyInformation."Bank Account No." := '';
        CompanyInformation.Modify();
        CountryRegion.Get(CompanyInformation."Country/Region Code");
        if CountryRegion."Intrastat Code" = '' then begin
            CountryRegion.Validate("Intrastat Code", CountryRegion.Code);
            CountryRegion.Modify(true);
        end;
    end;

    local procedure CheckFileContentForNormalReporting(var IntrastatReportPage: TestPage "Intrastat Report"; FileType: Char; Periodicity2: Char)
    var
        DataExch: Record "Data Exch.";
        CompanyInfo: Record "Company Information";
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
        Assert.AreEqual(EUROXLbl, LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 5), IntrastatFileOutputErr);
        ReadFromPosition += 5;
        Assert.AreEqual(IntrastatReportMgtIT.GetCompanyRepresentativeVATNo(), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 11), IntrastatFileOutputErr);
        ReadFromPosition += 11;
        Assert.AreEqual(Format(IntrastatReportPage."File Disk No.").PadLeft(6, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 6), IntrastatFileOutputErr);
        ReadFromPosition += 6;
        Assert.AreEqual('000000', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 6), IntrastatFileOutputErr);
        ReadFromPosition += 6;
        Assert.AreEqual(FileType, LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 1), IntrastatFileOutputErr);
        ReadFromPosition += 1;
        Assert.AreEqual(CopyStr(Format(IntrastatReportPage."Statistics Period"), 1, 2).PadLeft(2, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 2), IntrastatFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual(Periodicity2, LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 1), IntrastatFileOutputErr);
        ReadFromPosition += 1;
        Assert.AreEqual(CopyStr(Format(IntrastatReportPage."Statistics Period"), 3, 2).PadLeft(2, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 2), IntrastatFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual(IntrastatReportMgtIT.RemoveLeadingCountryCode(CompanyInfo."VAT Registration No.", CompanyInfo."Country/Region Code").PadLeft(11, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 11), IntrastatFileOutputErr);
        ReadFromPosition += 11;
        Assert.AreEqual('00', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 2), IntrastatFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual('00000000000', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 11), IntrastatFileOutputErr);
        ReadFromPosition += 11;
        Assert.AreEqual('00001', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 5), IntrastatFileOutputErr);
        ReadFromPosition += 5;
        Evaluate(DecVar, IntrastatReportPage.IntrastatLines.Amount.Value);
        Assert.AreEqual(Format(Round(DecVar, 1)).PadLeft(13, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 13), IntrastatFileOutputErr);
        ReadFromPosition += 13;
        Assert.AreEqual(Format('').PadLeft(54, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 54), IntrastatFileOutputErr);

        // Verify Line
        Line1 := LibraryTextFileValidation.ReadLine(FileName, 2);
        ReadFromPosition := 1;
        Assert.AreEqual(EUROXLbl, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 5), IntrastatFileOutputErr);
        ReadFromPosition += 5;
        Assert.AreEqual(IntrastatReportMgtIT.GetCompanyRepresentativeVATNo(), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 11), IntrastatFileOutputErr);
        ReadFromPosition += 11;
        Assert.AreEqual(Format(IntrastatReportPage."File Disk No.").PadLeft(6, '0'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 6), IntrastatFileOutputErr);
        ReadFromPosition += 6;
        Assert.AreEqual('1', LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 1), IntrastatFileOutputErr);
        ReadFromPosition += 1;
        Assert.AreEqual('00001', LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 5), IntrastatFileOutputErr);
        ReadFromPosition += 5;
        Assert.AreEqual(IntrastatReportPage.IntrastatLines."Country/Region Code".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 2), IntrastatFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual(IntrastatReportPage.IntrastatLines."Partner VAT ID".Value.PadRight(12, ' '), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 12), IntrastatFileOutputErr);
        ReadFromPosition += 12;
        Evaluate(DecVar, IntrastatReportPage.IntrastatLines.Amount.Value);
        Assert.AreEqual(Format(Round(DecVar, 1)).PadLeft(13, '0'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 13), IntrastatFileOutputErr);
        ReadFromPosition += 13;
        if FileType = 'A' then begin
            Assert.AreEqual(Format('0').PadLeft(13, '0'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 13), IntrastatFileOutputErr);
            ReadFromPosition += 13;
        end;
        Assert.AreEqual(CopyStr(IntrastatReportPage.IntrastatLines."Transaction Type".Value, 1, 1), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 1), IntrastatFileOutputErr);
        ReadFromPosition += 1;
        Assert.AreEqual(IntrastatReportPage.IntrastatLines."Tariff No.".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 8), IntrastatFileOutputErr);

        if Periodicity2 = 'M' then begin
            ReadFromPosition += 8;
            Evaluate(DecVar, IntrastatReportPage.IntrastatLines."Total Weight".Value);
            Assert.AreEqual(Format(Round(DecVar, 1)).PadLeft(10, '0'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 10), IntrastatFileOutputErr);
            ReadFromPosition += 10;
            Evaluate(DecVar, IntrastatReportPage.IntrastatLines."Supplementary Quantity".Value);
            Assert.AreEqual(Format(Round(DecVar, 1)).PadLeft(10, '0'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 10), IntrastatFileOutputErr);
            ReadFromPosition += 10;
            Evaluate(DecVar, IntrastatReportPage.IntrastatLines."Statistical Value".Value);
            Assert.AreEqual(Format(Round(DecVar, 1)).PadLeft(13, '0'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 13), IntrastatFileOutputErr);
            ReadFromPosition += 13;
            Assert.AreEqual(IntrastatReportPage.IntrastatLines."Group Code".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 1), IntrastatFileOutputErr);
            ReadFromPosition += 1;
            Assert.AreEqual(IntrastatReportPage.IntrastatLines."Transport Method".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 1), IntrastatFileOutputErr);
            ReadFromPosition += 1;
            Assert.AreEqual(IntrastatReportPage.IntrastatLines."Transaction Specification".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 2), IntrastatFileOutputErr);
            ReadFromPosition += 2;
            if FileType = 'A' then begin
                Assert.AreEqual(IntrastatReportPage.IntrastatLines."Country/Region of Origin Code".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 2), IntrastatFileOutputErr);
                ReadFromPosition += 2;
                Assert.AreEqual(IntrastatReportPage.IntrastatLines."Area".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 2), IntrastatFileOutputErr);
                ReadFromPosition += 2;
                Assert.AreEqual(CopyStr(IntrastatReportPage.IntrastatLines."Transaction Type".Value, 2, 1), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 1), IntrastatFileOutputErr);
            end else begin
                Assert.AreEqual(IntrastatReportPage.IntrastatLines."Area".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 2), IntrastatFileOutputErr);
                ReadFromPosition += 2;
                Assert.AreEqual(CopyStr(IntrastatReportPage.IntrastatLines."Transaction Type".Value, 2, 1), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 1), IntrastatFileOutputErr);
                ReadFromPosition += 1;
                Assert.AreEqual(IntrastatReportPage.IntrastatLines."Country/Region of Origin Code".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 2), IntrastatFileOutputErr);
            end;
        end;
    end;

    local procedure CheckFileContentForCorrectionReporting(var IntrastatReportPage: TestPage "Intrastat Report"; FileType: Char; Periodicity2: Char)
    var
        DataExch: Record "Data Exch.";
        CompanyInfo: Record "Company Information";
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
        Assert.AreEqual(EUROXLbl, LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 5), IntrastatFileOutputErr);
        ReadFromPosition += 5;
        Assert.AreEqual(IntrastatReportMgtIT.GetCompanyRepresentativeVATNo(), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 11), IntrastatFileOutputErr);
        ReadFromPosition += 11;
        Assert.AreEqual(Format(IntrastatReportPage."File Disk No.").PadLeft(6, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 6), IntrastatFileOutputErr);
        ReadFromPosition += 6;
        Assert.AreEqual('000000', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 6), IntrastatFileOutputErr);
        ReadFromPosition += 6;
        Assert.AreEqual(FileType, LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 1), IntrastatFileOutputErr);
        ReadFromPosition += 1;
        Assert.AreEqual(CopyStr(Format(IntrastatReportPage."Statistics Period"), 1, 2).PadLeft(2, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 2), IntrastatFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual(Periodicity2, LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 1), IntrastatFileOutputErr);
        ReadFromPosition += 1;
        Assert.AreEqual(CopyStr(Format(IntrastatReportPage."Statistics Period"), 3, 2).PadLeft(2, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 2), IntrastatFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual(IntrastatReportMgtIT.RemoveLeadingCountryCode(CompanyInfo."VAT Registration No.", CompanyInfo."Country/Region Code").PadLeft(11, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 11), IntrastatFileOutputErr);
        ReadFromPosition += 11;
        Assert.AreEqual('00', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 2), IntrastatFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual('00000000000', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 11), IntrastatFileOutputErr);
        ReadFromPosition += 11;
        Assert.AreEqual(Format(Round(DecVar, 1)).PadLeft(18, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 18), IntrastatFileOutputErr);
        ReadFromPosition += 18;
        Assert.AreEqual('00001', LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 5), IntrastatFileOutputErr);
        ReadFromPosition += 5;
        Evaluate(DecVar, IntrastatReportPage.IntrastatLines.Amount.Value);
        Assert.AreEqual(ConvertLastDigit(Format(Round(Abs(DecVar), 1)).PadLeft(13, '0')), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 13), IntrastatFileOutputErr);
        ReadFromPosition += 13;
        Assert.AreEqual(Format('').PadLeft(41, '0'), LibraryTextFileValidation.ReadValue(Header, ReadFromPosition, 41), IntrastatFileOutputErr);

        // Verify Line
        Line1 := LibraryTextFileValidation.ReadLine(FileName, 2);
        ReadFromPosition := 1;
        Assert.AreEqual(EUROXLbl, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 5), IntrastatFileOutputErr);
        ReadFromPosition += 5;
        Assert.AreEqual(IntrastatReportMgtIT.GetCompanyRepresentativeVATNo(), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 11), IntrastatFileOutputErr);
        ReadFromPosition += 11;
        Assert.AreEqual(Format(IntrastatReportPage."File Disk No.").PadLeft(6, '0'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 6), IntrastatFileOutputErr);
        ReadFromPosition += 6;
        Assert.AreEqual('2', LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 1), IntrastatFileOutputErr);
        ReadFromPosition += 1;
        Assert.AreEqual('00001', LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 5), IntrastatFileOutputErr);
        ReadFromPosition += 5;
        if Periodicity2 = 'M' then begin
            Assert.AreEqual(CopyStr(IntrastatReportPage.IntrastatLines."Reference Period".Value, 3, 2), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 2), IntrastatFileOutputErr);
            ReadFromPosition += 2;
            Assert.AreEqual('0', LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 1), IntrastatFileOutputErr);
            ReadFromPosition += 1;
        end else begin
            Assert.AreEqual('00', LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 2), IntrastatFileOutputErr);
            ReadFromPosition += 2;
            Assert.AreEqual(CopyStr(IntrastatReportPage.IntrastatLines."Reference Period".Value, 4, 1), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 1), IntrastatFileOutputErr);
            ReadFromPosition += 1;
        end;
        Assert.AreEqual(CopyStr(IntrastatReportPage.IntrastatLines."Reference Period".Value, 1, 2), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 2), IntrastatFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual(IntrastatReportPage.IntrastatLines."Country/Region Code".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 2), IntrastatFileOutputErr);
        ReadFromPosition += 2;
        Assert.AreEqual(Format('').PadLeft(12, ' '), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 12), IntrastatFileOutputErr);
        ReadFromPosition += 12;
        Evaluate(DecVar, IntrastatReportPage.IntrastatLines.Amount.Value);
        if DecVar < 0 then
            Assert.AreEqual('-' + Format(Round(Abs(DecVar), 1)).PadLeft(13, '0'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 14), IntrastatFileOutputErr)
        else
            Assert.AreEqual('+' + Format(Round(Abs(DecVar), 1)).PadLeft(13, '0'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 14), IntrastatFileOutputErr);
        ReadFromPosition += 14;
        if FileType = 'A' then begin
            Assert.AreEqual(Format('').PadLeft(13, '0'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 13), IntrastatFileOutputErr);
            ReadFromPosition += 13;
        end;
        Assert.AreEqual(CopyStr(IntrastatReportPage.IntrastatLines."Transaction Type".Value, 1, 1), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 1), IntrastatFileOutputErr);
        ReadFromPosition += 1;
        Assert.AreEqual(IntrastatReportPage.IntrastatLines."Tariff No.".Value, LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 8), IntrastatFileOutputErr);
        if Periodicity2 = 'M' then begin
            ReadFromPosition += 8;
            Evaluate(DecVar, IntrastatReportPage.IntrastatLines."Statistical Value".Value);
            Assert.AreEqual(Format(Round(Abs(DecVar), 1)).PadLeft(13, '0'), LibraryTextFileValidation.ReadValue(Line1, ReadFromPosition, 13), IntrastatFileOutputErr);
        end;
    end;

    [StrMenuHandler]
    procedure StrMenuHandlerRcpt(Options: Text; var Choice: Integer; Instruction: Text)
    begin
        Choice := 1;
    end;

    [StrMenuHandler]
    procedure StrMenuHandlerShpt(Options: Text; var Choice: Integer; Instruction: Text)
    begin
        Choice := 2;
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

    local procedure ConvertLastDigit(TotalAmount: Text[13]): Text[13]
    var
        OutText: Text[13];
        LastDigit: Text[1];
    begin
        LastDigit := CopyStr(TotalAmount, 13, 1);
        OutText := CopyStr(TotalAmount, 1, 12);
        case LastDigit of
            '0':
                OutText += 'p';
            '1':
                OutText += 'q';
            '2':
                OutText += 'r';
            '3':
                OutText += 's';
            '4':
                OutText += 't';
            '5':
                OutText += 'u';
            '6':
                OutText += 'v';
            '7':
                OutText += 'w';
            '8':
                OutText += 'x';
            '9':
                OutText += 'y';
        end;
        exit(OutText);
    end;
}