codeunit 144081 "Intrastat FR Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Intrastat FR]
        IsInitialized := false;
    end;

    var
        CompanyInformation: Record "Company Information";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryIntrastat: Codeunit "Library - Intrastat";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LibraryXPathXMLReader: Codeunit "Library - XPath XML Reader";
        IsInitialized: Boolean;
        DataExchFileContentMissingErr: Label 'Data Exch File Content must not be empty';
        DataExchangeXMLP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-FR" Name="Intrastat 2022 France" Type="5" ExternalDataHandlingCodeunit="4813" FileType="0" ReadingWritingCodeunit="1283">  <DataExchLineDef LineType="1" Code="1-HEADER" Name="Parent Node for Intrastat XML" ColumnCount="6"><DataExchColumnDef ColumnNo="1" Name="INSTAT" Show="false" DataType="0" Path="/INSTAT" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Envelope" Show="false" DataType="0" Path="/INSTAT/Envelope" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="envelopeId" Show="false" DataType="0" Path="/INSTAT/Envelope/envelopeId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="DateTime" Show="false" DataType="0" Path="/INSTAT/Envelope/DateTime" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="date" Show="false" DataType="0" Path="/INSTAT/Envelope/DateTime/date" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="time" Show="false" DataType="0" Path="/INSTAT/Envelope/DateTime/time" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="79" Name="" MappingCodeunit="1269">  <DataExchFieldMapping ColumnNo="3" UseDefaultValue="true" /></DataExchMapping>  </DataExchLineDef>  <DataExchLineDef LineType="1" Code="2-SENDER" ColumnCount="0" DataLineTag="/INSTAT/Envelope" ParentCode="1-HEADER"><DataExchColumnDef ColumnNo="1" Name="Party" Show="false" DataType="0" Path="/Party[@partyType=&quot;PSI&quot; and @partyRole=&quot;sender&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="partyType" Show="false" DataType="0" Path="/Party[@partyType]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="partyRole" Show="false" DataType="0" Path="/Party[@partyRole]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="partyId" Show="false" DataType="0" Path="/Party/partyId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="partyName" Show="false" DataType="0" Path="/Party/partyName" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="79" Name="" MappingCodeunit="1269">  <DataExchFieldMapping ColumnNo="4" Optional="true" />  <DataExchFieldMapping ColumnNo="5" FieldID="2" /></DataExchMapping>  </DataExchLineDef>  <DataExchLineDef LineType="1" Code="3-ADDITIONAL" ColumnCount="0" DataLineTag="/INSTAT/Envelope" ParentCode="1-HEADER"><DataExchColumnDef ColumnNo="1" Name="softwareUsed" Show="false" DataType="0" Path="/softwareUsed" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="79" Name="" MappingCodeunit="1269">  <DataExchFieldMapping ColumnNo="1" UseDefaultValue="true" DefaultValue="DynamicsNAV" /></DataExchMapping>  </DataExchLineDef>  <DataExchLineDef LineType="1" Code="4-RCPTHEADER" ColumnCount="0" DataLineTag="/INSTAT/Envelope" ParentCode="1-HEADER"><DataExchColumnDef ColumnNo="1" Name="Declaration" Show="false" DataType="0" Path="/Declaration" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="declarationId" Show="false" DataType="0" Path="/Declaration/declarationId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="referencePeriod" Show="false" DataType="0" Path="/Declaration/referencePeriod" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="PSIId" Show="false" DataType="0" Path="/Declaration/PSIId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Function" Show="false" DataType="0" Path="/Declaration/Function" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="functionCode" Show="false" DataType="0" Path="/Declaration/Function/functionCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="declarationTypeCode" Show="false" DataType="0" Path="/Declaration/declarationTypeCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="flowCode" Show="false" DataType="0" Path="/Declaration/flowCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="currencyCode" Show="false" DataType="0" Path="/Declaration/currencyCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="79" Name="" MappingCodeunit="1269"> ',
                            Locked = true; // will be replaced with file import when available  
        DataExchangeXMLP2Txt: Label '<DataExchFieldMapping ColumnNo="6" UseDefaultValue="true" DefaultValue="O" />  <DataExchFieldMapping ColumnNo="8" UseDefaultValue="true" DefaultValue="A" />  <DataExchFieldMapping ColumnNo="9" UseDefaultValue="true" DefaultValue="EUR" /></DataExchMapping>  </DataExchLineDef>  <DataExchLineDef LineType="1" Code="5-SHPTHEADER" ColumnCount="0" DataLineTag="/INSTAT/Envelope" ParentCode="1-HEADER"><DataExchColumnDef ColumnNo="1" Name="Declaration" Show="false" DataType="0" Path="/Declaration" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="declarationId" Show="false" DataType="0" Path="/Declaration/declarationId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="referencePeriod" Show="false" DataType="0" Path="/Declaration/referencePeriod" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="PSIId" Show="false" DataType="0" Path="/Declaration/PSIId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Function" Show="false" DataType="0" Path="/Declaration/Function" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="functionCode" Show="false" DataType="0" Path="/Declaration/Function/functionCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="declarationTypeCode" Show="false" DataType="0" Path="/Declaration/declarationTypeCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="flowCode" Show="false" DataType="0" Path="/Declaration/flowCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="currencyCode" Show="false" DataType="0" Path="/Declaration/currencyCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="79" Name="" MappingCodeunit="1269">  <DataExchFieldMapping ColumnNo="6" UseDefaultValue="true" DefaultValue="O" />  <DataExchFieldMapping ColumnNo="8" UseDefaultValue="true" DefaultValue="D" />  <DataExchFieldMapping ColumnNo="9" UseDefaultValue="true" DefaultValue="EUR" /></DataExchMapping>  </DataExchLineDef>  <DataExchLineDef LineType="0" Code="6-RCPTDETAIL" ColumnCount="0" DataLineTag="/INSTAT/Envelope/Declaration[flowCode =&quot;A&quot;]" ParentCode="4-RCPTHEADER"><DataExchColumnDef ColumnNo="1" Name="IntrastatReportLineNo" Show="false" DataType="0" Path="/IntrastatReportLineNo" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="2" Name="Item" Show="false" DataType="0" Path="/Item" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="itemNumber" Show="false" DataType="0" Path="/Item/itemNumber" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="CN8" Show="false" DataType="0" Path="/Item/CN8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="5" Name="CN8Code" Show="false" DataType="0" Path="/Item/CN8/CN8Code" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="6" Name="MSConsDestCode" Show="false" DataType="0" Path="/Item/MSConsDestCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="true" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="7" Name="countryOfOriginCode" Show="false" DataType="0" Path="/Item/countryOfOriginCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="8" Name="netMass" Show="false" DataType="0" Path="/Item/netMass" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="9" Name="quantityInSU" Show="false" DataType="0" Path="/Item/quantityInSU" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="10" Name="invoicedAmount" Show="false" DataType="0" Path="/Item/invoicedAmount" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="partnerId" Show="false" DataType="0" Path="/Item/partnerId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="statisticalProcedureCode" Show="false" DataType="0" Path="/Item/statisticalProcedureCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="NatureOfTransaction" Show="false" DataType="0" Path="/Item/NatureOfTransaction" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="14" Name="natureOfTransactionACode" Show="false" DataType="0" Path="/Item/NatureOfTransaction/natureOfTransactionACode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" />',
                            Locked = true;
        DataExchangeXMLP3Txt: Label '<DataExchColumnDef ColumnNo="15" Name="natureOfTransactionBCode" Show="false" DataType="0" Path="/Item/NatureOfTransaction/natureOfTransactionBCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="16" Name="modeOfTransportCode" Show="false" DataType="0" Path="/Item/modeOfTransportCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="17" Name="regionCode" Show="false" DataType="0" Path="/Item/regionCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchMapping TableId="4812" Name="" MappingCodeunit="1269" PreMappingCodeunit="10853">  <DataExchFieldMapping ColumnNo="1" FieldID="2" Optional="true" />  <DataExchFieldMapping ColumnNo="3" FieldID="23" Optional="true" />  <DataExchFieldMapping ColumnNo="5" FieldID="5" Optional="true" TransformationRule="ALPHANUMERIC_ONLY" />  <DataExchFieldMapping ColumnNo="6" FieldID="25" Optional="true" />  <DataExchFieldMapping ColumnNo="7" FieldID="24" Optional="true" />  <DataExchFieldMapping ColumnNo="8" FieldID="21" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules>  <Code>ALPHANUMERIC_ONLY</Code>  <Description>Alphanumeric Text Only</Description>  <TransformationType>7</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules>  <Code>ROUNDTOINT</Code>  <Description>Round to integer</Description>  <TransformationType>14</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule>  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>1.00</Precision>  <Direction>=</Direction>  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="9" FieldID="14" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules>  <Code>ALPHANUMERIC_ONLY</Code>  <Description>Alphanumeric Text Only</Description>  <TransformationType>7</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules>  <Code>ROUNDTOINT</Code>  <Description>Round to integer</Description>  <TransformationType>14</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule>  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>1.00</Precision>  <Direction>=</Direction>  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="10" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules>  <Code>ALPHANUMERIC_ONLY</Code>  <Description>Alphanumeric Text Only</Description>  <TransformationType>7</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules>  <Code>ROUNDTOINT</Code>  <Description>Round to integer</Description>  <TransformationType>14</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule>  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>1.00</Precision>  <Direction>=</Direction>  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="11" FieldID="29" Optional="true" />  <DataExchFieldMapping ColumnNo="12" FieldID="27" Optional="true" />  <DataExchFieldMapping ColumnNo="14" FieldID="8" Optional="true" TransformationRule="FIRST_CHARACTER"><TransformationRules>  <Code>FIRST_CHARACTER</Code>  <Description>Extracts the first character of the string</Description>  <TransformationType>4</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>1</StartPosition>  <Length>1</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="15" FieldID="8" Optional="true" TransformationRule="SECOND_CHARACTER"><TransformationRules>  <Code>SECOND_CHARACTER</Code>  <Description>Extract the second character of the string</Description>  <TransformationType>4</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>2</StartPosition>  <Length>1</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="16" FieldID="9" Optional="true" />  <DataExchFieldMapping ColumnNo="17" FieldID="26" Optional="true" /></DataExchMapping>',
                            Locked = true;
        DataExchangeXMLP4Txt: Label '</DataExchLineDef>  <DataExchLineDef LineType="0" Code="7-SHPTDETAIL" ColumnCount="0" DataLineTag="/INSTAT/Envelope/Declaration[flowCode =&quot;D&quot;]" ParentCode="5-SHPTHEADER"><DataExchColumnDef ColumnNo="1" Name="IntrastatReportLineNo" Show="false" DataType="0" Path="/IntrastatReportLineNo" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="2" Name="Item" Show="false" DataType="0" Path="/Item" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="itemNumber" Show="false" DataType="0" Path="/Item/itemNumber" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="CN8" Show="false" DataType="0" Path="/Item/CN8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="CN8Code" Show="false" DataType="0" Path="/Item/CN8/CN8Code" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="6" Name="MSConsDestCode" Show="false" DataType="0" Path="/Item/MSConsDestCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="7" Name="countryOfOriginCode" Show="false" DataType="0" Path="/Item/countryOfOriginCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="8" Name="netMass" Show="false" DataType="0" Path="/Item/netMass" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="9" Name="quantityInSU" Show="false" DataType="0" Path="/Item/quantityInSU" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="10" Name="invoicedAmount" Show="false" DataType="0" Path="/Item/invoicedAmount" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="partnerId" Show="false" DataType="0" Path="/Item/partnerId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="statisticalProcedureCode" Show="false" DataType="0" Path="/Item/statisticalProcedureCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="NatureOfTransaction" Show="false" DataType="0" Path="/Item/NatureOfTransaction" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="14" Name="natureOfTransactionACode" Show="false" DataType="0" Path="/Item/NatureOfTransaction/natureOfTransactionACode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="15" Name="natureOfTransactionBCode" Show="false" DataType="0" Path="/Item/NatureOfTransaction/natureOfTransactionBCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="16" Name="modeOfTransportCode" Show="false" DataType="0" Path="/Item/modeOfTransportCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="17" Name="regionCode" Show="false" DataType="0" Path="/Item/regionCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchMapping TableId="4812" Name="" KeyIndex="7" MappingCodeunit="1269" PreMappingCodeunit="10854">  <DataExchFieldMapping ColumnNo="1" FieldID="2" Optional="true" />  <DataExchFieldMapping ColumnNo="3" FieldID="23" Optional="true" />  <DataExchFieldMapping ColumnNo="5" FieldID="5" Optional="true" TransformationRule="ALPHANUMERIC_ONLY" />  <DataExchFieldMapping ColumnNo="6" FieldID="25" Optional="true" />  <DataExchFieldMapping ColumnNo="7" FieldID="7" Optional="true" />  <DataExchFieldMapping ColumnNo="8" FieldID="21" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules>  <Code>ALPHANUMERIC_ONLY</Code>  <Description>Alphanumeric Text Only</Description>  <TransformationType>7</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules>  <Code>ROUNDTOINT</Code>  <Description>Round to integer</Description>  <TransformationType>14</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule>  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>1.00</Precision>  <Direction>=</Direction>  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="9" FieldID="14" Optional="true" TransformationRule="ROUNDTOINT">',
                            Locked = true;
        DataExchangeXMLP5Txt: Label '<TransformationRules>  <Code>ALPHANUMERIC_ONLY</Code>  <Description>Alphanumeric Text Only</Description>  <TransformationType>7</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules>  <Code>ROUNDTOINT</Code>  <Description>Round to integer</Description>  <TransformationType>14</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule>  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>1.00</Precision>  <Direction>=</Direction>  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="10" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules>  <Code>ALPHANUMERIC_ONLY</Code>  <Description>Alphanumeric Text Only</Description>  <TransformationType>7</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules>  <Code>ROUNDTOINT</Code>  <Description>Round to integer</Description>  <TransformationType>14</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule>  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>1.00</Precision>  <Direction>=</Direction>  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="11" FieldID="29" Optional="true" />  <DataExchFieldMapping ColumnNo="12" FieldID="27" Optional="true" />  <DataExchFieldMapping ColumnNo="14" FieldID="8" Optional="true" TransformationRule="FIRST_CHARACTER"><TransformationRules>  <Code>FIRST_CHARACTER</Code>  <Description>Extracts the first character of the string</Description>  <TransformationType>4</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>1</StartPosition>  <Length>1</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="15" FieldID="8" Optional="true" TransformationRule="SECOND_CHARACTER"><TransformationRules>  <Code>SECOND_CHARACTER</Code>  <Description>Extract the second character of the string</Description>  <TransformationType>4</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>2</StartPosition>  <Length>1</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="16" FieldID="9" Optional="true" />  <DataExchFieldMapping ColumnNo="17" FieldID="26" Optional="true" /></DataExchMapping>  </DataExchLineDef></DataExchDef></root>',
        Locked = true;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure IntrastatReportFileCreationShpt()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report FR] [File Validation]
        // [SCENARIO] End to end file creation for shipment line

        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Intrastat Report line created         
        Initialize();
        InvoiceDate := CalcDate('<5Y>');

        LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, InvoiceDate);
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        Commit();

        // [GIVEN] A Intrastat Report created and mandatory fields filled in
        UpdateIntrastatReport(IntrastatReportPage, IntrastatReportNo);
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] No errors are found when the checklist is run
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [WHEN] Running Create File
        IntrastatReportPage.CreateFile.Invoke();

        // [THEN] Check file content having one shipment
        VerifyIntrastatReportContent(Format(IntrastatReportPage."No."));
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure IntrastatReportFileCreationRcpt()
    var
        PurchaseLine: Record "Purchase Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report FR] [File Validation]
        // [SCENARIO] End to end file creation for receipt line

        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Intrastat Report line created         
        Initialize();
        InvoiceDate := CalcDate('<5Y>');

        LibraryIntrastat.CreateAndPostPurchaseOrder(PurchaseLine, WorkDate());
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        Commit();

        // [GIVEN] A Intrastat Report is created and checklist is run
        UpdateIntrastatReport(IntrastatReportPage, IntrastatReportNo);
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] No errors found
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [WHEN] Running Create File
        IntrastatReportPage.CreateFile.Invoke();

        // [THEN] Check file content for shipment
        VerifyIntrastatReportContent(Format(IntrastatReportPage."No."));
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure SimpleTransactionIntrastatReport()
    var
        PurchaseLine: Record "Purchase Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report FR] [File Validation]
        // [SCENARIO] FIle creation when transaction is qualified as Simple

        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Intrastat Report line created         
        Initialize();
        InvoiceDate := CalcDate('<5Y>');

        LibraryIntrastat.CreateAndPostPurchaseOrder(PurchaseLine, WorkDate());
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        Commit();

        // [GIVEN] A Intrastat Report with Obligation Level set to 4 (transaction = Simple)
        UpdateIntrastatReport(IntrastatReportPage, IntrastatReportNo);
        IntrastatReportPage."Obligation Level".SetValue('4');
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You no more errors
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [WHEN] Running Create File
        IntrastatReportPage.CreateFile.Invoke();

        // [THEN] Check file content for shipment
        VerifyIntrastatReportContent(Format(IntrastatReportPage."No."));
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure TransactionOutOfFilterNotExported()
    var
        PurchaseLine: Record "Purchase Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report FR] [File Validation]
        // [SCENARIO] FIle creation when transaction is out of Obligation Level filter 

        // [GIVEN] Posted Sales Order 
        // [GIVEN] Intrastat Report line created with Transaction Specification = 11    
        // [GIVEN] And Obligation Level = 1 (filter 11|19|21|29)
        Initialize();
        InvoiceDate := CalcDate('<5Y>');

        LibraryIntrastat.CreateAndPostPurchaseOrder(PurchaseLine, WorkDate());
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        Commit();

        // [GIVEN] A Intrastat Report with Obligation Level set to 4 (Transaction specification Level = <>29&<>11&<>19)
        UpdateIntrastatReport(IntrastatReportPage, IntrastatReportNo);
        IntrastatReportPage."Obligation Level".SetValue('4');
        IntrastatReportPage.IntrastatLines."Transaction Specification".Value('11');
        //IntrastatReportPage.IntrastatLines.Next();
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You no more errors
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [WHEN] Running Create File
        asserterror IntrastatReportPage.CreateFile.Invoke();

        // [THEN] File content is empty 
        Assert.ExpectedError('File Content is empty.');
        IntrastatReportPage.Close();
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        GLSetupVATCalculation: Enum "G/L Setup VAT Calculation";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Intrastat Report Test");

        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"Intrastat Report Test");
        LibraryIntrastat.UpdateIntrastatCodeInCountryRegion();
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.CreateGeneralPostingSetupData();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERM.SetBillToSellToVATCalc(GLSetupVATCalculation::"Bill-to/Pay-to No.");
        LibraryIntrastat.CreateIntrastatReportSetup();
        LibraryIntrastat.CreateIntrastatDataExchangeDefinition();
        CreateIntrastatReportChecklist();
        UpdateIntrastatReportSetup();

        CompanyInformation.Get();
        CompanyInformation.Validate(CISD, LibraryRandom.RandText(10));
        CompanyInformation.Modify(true);

        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Intrastat Report Test");
    end;

    local procedure UpdateIntrastatReportSetup()
    var
        Contact: Record Contact;
        DataExchDef: Record "Data Exch. Def";
        TempBlob: Codeunit "Temp Blob";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
    begin
        Contact.FindFirst();
        IntrastatReportSetup.Get();
        IntrastatReportSetup.Validate("Report Receipts", true);
        IntrastatReportSetup.Validate("Report Shipments", true);
        IntrastatReportSetup.Validate("Data Exch. Def. Code", 'INTRA-2022-FR');
        IntrastatReportSetup.Validate("Intrastat Contact Type", IntrastatReportSetup."Intrastat Contact Type"::Contact);
        IntrastatReportSetup.Validate("Intrastat Contact No.", Contact."No.");
        if not DataExchDef.Get('INTRA-2022-FR') then begin
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(DataExchangeXMLP1Txt + DataExchangeXMLP2Txt + DataExchangeXMLP3Txt + DataExchangeXMLP4Txt + DataExchangeXMLP5Txt);
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        end;

        IntrastatReportSetup.Modify();
    end;

    local procedure UpdateIntrastatReport(var IntrastatReportPage: TestPage "Intrastat Report"; IntrastatReportNo: Code[20])
    var
        ShipmentMethod: Record "Shipment Method";
        TransactionType: Record "Transaction Type";
        TariffNumber: Record "Tariff Number";
        CountryRegion: Record "Country/Region";
    begin
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        TransactionType.Code := CopyStr(LibraryUtility.GenerateGUID(), 3, 2);
        If TransactionType.Insert() then;
        IntrastatReportPage."Currency Identifier".SetValue('EUR');
        IntrastatReportPage."Obligation Level".SetValue('2');

        IntrastatReportPage.IntrastatLines."Transaction Type".Value(TransactionType.Code);

        IntrastatReportPage.IntrastatLines.Quantity.Value(Format(LibraryRandom.RandInt(100)));
        IntrastatReportPage.IntrastatLines."Total Weight".Value(Format(LibraryRandom.RandInt(1000)));
        IntrastatReportPage.IntrastatLines."Statistical Value".Value(Format(LibraryRandom.RandInt(1000)));

        TariffNumber.FindFirst();
        IntrastatReportPage.IntrastatLines."Tariff No.".Value(Format(TariffNumber."No."));

        CountryRegion.FindFirst();
        IntrastatReportPage.IntrastatLines."Country/Region of Origin Code".Value(Format(CountryRegion.Code));
        IntrastatReportPage.IntrastatLines."Country/Region Code".Value('FR');

        ShipmentMethod.FindFirst();
        IntrastatReportPage.IntrastatLines."Shpt. Method Code".Value(ShipmentMethod.Code);
        IntrastatReportPage.IntrastatLines."Partner VAT ID".Value(LibraryRandom.RandText(10));
    end;

    local procedure VerifyIntrastatReportContent(IntrastatReportNo: Code[20])
    var
        DataExch: Record "Data Exch.";
        IntrastatReportLine: Record "Intrastat Report Line";
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
    begin
        DataExch.FindLast();
        Assert.IsTrue(DataExch."File Content".HasValue(), DataExchFileContentMissingErr);

        DataExch.CalcFields("File Content");
        TempBlob.FromRecord(DataExch, DataExch.FieldNo("File Content"));

        FileName := FileMgt.ServerTempFileName('xml');
        FileMgt.BLOBExportToServerFile(TempBlob, FileName);

        LibraryXPathXMLReader.Initialize(FileName, '');

        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.FindSet();

        // verify header
        VerifyXMLHeader(LibraryXPathXMLReader);

        // verify lines (declaration + item)
        Repeat
            VerifyXMLDeclaration(LibraryXPathXMLReader, IntrastatReportNo);
            VerifyXMLItem(LibraryXPathXMLReader, IntrastatReportLine);
        until IntrastatReportLine.Next() = 0;
    end;

    local procedure VerifyXMLHeader(LibraryXPathXMLReader: Codeunit "Library - XPath XML Reader")
    var
        XMLNode: DotNet XmlNode;
    begin
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/envelopeId', CompanyInformation.CISD);
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/DateTime/date', Format(Today, 0, 9));
        LibraryXPathXMLReader.GetNodeByXPath('/INSTAT/Envelope//Party', XMLNode);
        LibraryXPathXMLReader.VerifyAttributeFromNode(XMLNode, 'partyType', 'PSI');
        LibraryXPathXMLReader.VerifyAttributeFromNode(XMLNode, 'partyRole', 'sender');
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/Party/partyId', CompanyInformation.GetPartyID());
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/Party/partyName', CompanyInformation.Name);
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/softwareUsed', 'DynamicsNAV');
    end;

    local procedure VerifyXMLDeclaration(LibraryXPathXMLReader: Codeunit "Library - XPath XML Reader"; IntrastatReportHeaderNo: Code[20])
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
    begin
        Commit();
        IntrastatReportHeader.Get(IntrastatReportHeaderNo);
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/Declaration/referencePeriod', GetReferencePeriod(Format(IntrastatReportHeader."Statistics Period")));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/Declaration/PSIId', CompanyInformation.GetPartyID());
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/Declaration/Function/functionCode', 'O');
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/Declaration/declarationTypeCode', Format(IntrastatReportHeader."Obligation Level"));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/Declaration/currencyCode', 'EUR');
    end;

    local procedure VerifyXMLItem(LibraryXPathXMLReader: Codeunit "Library - XPath XML Reader"; IntrastatReportLine: Record "Intrastat Report Line")
    var
        IsTransactionSimpleValue: Boolean;
    begin
        IsTransactionSimpleValue := IsTransactionSimple(IntrastatReportLine);
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/Declaration/flowCode', GetFlowCode(IntrastatReportLine.Type));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/Declaration/Item/itemNumber', FormatExtendNumberToXML(CompanyInformation."Last Intr. Declaration ID" + 1, 6));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/Declaration/Item/invoicedAmount', Format(IntrastatReportLine."Statistical Value", 0, 0));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/Declaration/Item/partnerId', IntrastatReportLine."Partner VAT ID");
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/Declaration/Item/statisticalProcedureCode', IntrastatReportLine."Transaction Specification");

        if not IsTransactionSimpleValue then begin
            LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/Declaration/Item/CN8/CN8Code', IntrastatReportLine."Tariff No.");
            LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/Declaration/Item/countryOfOriginCode', IntrastatReportLine."Country/Region of Origin Code");
            LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/Declaration/Item/netMass', Format(IntrastatReportLine."Total Weight"));
            LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/Declaration/Item/quantityInSU', Format(IntrastatReportLine.Quantity));
            LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/Declaration/Item/NatureOfTransaction/natureOfTransactionACode', CopyStr(IntrastatReportLine."Transaction Type", 1, 1));
            LibraryXPathXMLReader.VerifyNodeValueByXPath('/INSTAT/Envelope/Declaration/Item/NatureOfTransaction/natureOfTransactionACode', CopyStr(IntrastatReportLine."Transaction Type", 2, 1));
        end else begin
            LibraryXPathXMLReader.VerifyNodeAbsence('/INSTAT/Envelope/Declaration/Item/NatureOfTransaction/natureOfTransactionACode');
            LibraryXPathXMLReader.VerifyNodeAbsence('/INSTAT/Envelope/Declaration/Item/CN8/CN8Code');
            LibraryXPathXMLReader.VerifyNodeAbsence('/INSTAT/Envelope/Declaration/Item/countryOfOriginCode');
            LibraryXPathXMLReader.VerifyNodeAbsence('/INSTAT/Envelope/Declaration/Item/netMass');
            LibraryXPathXMLReader.VerifyNodeAbsence('/INSTAT/Envelope/Declaration/Item/quantityInSU');
            LibraryXPathXMLReader.VerifyNodeAbsence('/INSTAT/Envelope/Declaration/Item/NatureOfTransaction/natureOfTransactionACode');
            LibraryXPathXMLReader.VerifyNodeAbsence('/INSTAT/Envelope/Declaration/Item/NatureOfTransaction/natureOfTransactionACode');
        end;
    end;

    local procedure CreateIntrastatReportAndSuggestLines(ReportDate: Date; var IntrastatReportNo: Code[20])
    begin
        LibraryIntrastat.CreateIntrastatReport(ReportDate, IntrastatReportNo);
        InvokeSuggestLinesOnIntrastatReport(IntrastatReportNo);
    end;

    local procedure InvokeSuggestLinesOnIntrastatReport(IntrastatReportNo: Code[20])
    var
        IntrastatReport: TestPage "Intrastat Report";
    begin
        IntrastatReport.OpenEdit();
        IntrastatReport.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReport.GetEntries.Invoke();
    end;

    local procedure CreateIntrastatReportChecklist()
    var
        IntrastatReportChecklist: Record "Intrastat Report Checklist";
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        IntrastatReportChecklist.DeleteAll();

        LibraryIntrastat.CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo("Tariff No."), '');
        LibraryIntrastat.CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo("Country/Region Code"), '');
        LibraryIntrastat.CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo("Transaction Type"), '');
        LibraryIntrastat.CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo(Quantity), 'Supplementary Units: True');
        LibraryIntrastat.CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo("Total Weight"), 'Supplementary Units: False');
        LibraryIntrastat.CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo("Country/Region of Origin Code"), 'Type: Shipment');
        LibraryIntrastat.CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo("Partner VAT ID"), 'Type: Shipment');
    end;

    local procedure FormatExtendNumberToXML(Value: Integer; Length: Integer): Text
    begin
        exit(
          Format(
            Value, 0, StrSubstNo('<Integer,%1><Filler Character,0>', Length)));
    end;

    local procedure GetReferencePeriod(StatisticsPeriod: Code[10]): Text[30]
    begin
        exit('20' + CopyStr(StatisticsPeriod, 1, 2) + '-' + CopyStr(StatisticsPeriod, 3, 2));
    end;

    local procedure GetFlowCode(IntrastatReportLineType: Integer): Text[1]
    var
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        if IntrastatReportLineType = IntrastatReportLine.Type::Receipt then
            exit('A');
        exit('D');
    end;

    local procedure IsTransactionSimple(var IntrastatReportLine: Record "Intrastat Report Line"): Boolean
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
    begin
        IntrastatReportHeader.Get(IntrastatReportLine."Intrastat No.");

        if IntrastatReportHeader."Obligation Level" = IntrastatReportHeader."Obligation Level"::"4" then
            exit(true);

        if (IntrastatReportHeader."Obligation Level" = IntrastatReportHeader."Obligation Level"::"5") and not (IntrastatReportLine."Transaction Specification" in ['21', '29']) then
            exit(true);

        exit(false);
    end;

    [RequestPageHandler]
    procedure IntrastatReportGetLinesPageHandler(var RequestPage: TestRequestPage "Intrastat Report Get Lines")
    begin
        RequestPage.OK().Invoke();
    end;
}