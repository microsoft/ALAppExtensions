// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Projects.Project.Ledger;
using System.IO;
using System.Utilities;

codeunit 10790 IntrastatReportManagementES
{
    Access = Internal;

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
        IntrastatReportChecklist.Validate("Field No.", 29);
        IntrastatReportChecklist.Validate("Filter Expression", 'Type: Shipment');
        IntrastatReportChecklist.Insert(true);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnBeforeInsertItemLedgerLine', '', true, true)]
    local procedure OnBeforeInsertItemLedgerLine(var IntrastatReportLine: Record "Intrastat Report Line"; ItemLedgerEntry: Record "Item Ledger Entry"; var IsHandled: Boolean)
    var
        Item: Record Item;
    begin
        if (IntrastatReportLine."Cost Regulation %" = 0) and
            (IntrastatReportLine."Source Type" in [IntrastatReportLine."Source Type"::"Item Entry", IntrastatReportLine."Source Type"::"Job Entry"])
        then begin
            Item.Get(IntrastatReportLine."Item No.");
            IntrastatReportLine.Validate(IntrastatReportLine."Cost Regulation %", Item."Cost Regulation %");
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnBeforeInsertJobLedgerLine', '', true, true)]
    local procedure OnBeforeInsertJobLedgerLine(var IntrastatReportLine: Record "Intrastat Report Line"; JobLedgerEntry: Record "Job Ledger Entry"; var IsHandled: Boolean)
    var
        Item: Record Item;
    begin
        if (IntrastatReportLine."Cost Regulation %" = 0) and
            (IntrastatReportLine."Source Type" in [IntrastatReportLine."Source Type"::"Item Entry", IntrastatReportLine."Source Type"::"Job Entry"])
        then begin
            Item.Get(IntrastatReportLine."Item No.");
            IntrastatReportLine.Validate(IntrastatReportLine."Cost Regulation %", Item."Cost Regulation %");
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnBeforeValidateJobLedgerLineFields', '', true, true)]
    local procedure OnBeforeValidateJobLedgerLineFields(var IntrastatReportLine: Record "Intrastat Report Line"; JobLedgerEntry: Record "Job Ledger Entry"; var IsHandled: Boolean)
    var
        UOMMgt: Codeunit "Unit of Measure Management";
    begin
        IsHandled := true;
        IntrastatReportLine.Validate("Item No.");
        IntrastatReportLine."Source Type" := IntrastatReportLine."Source Type"::"Job Entry";
        IntrastatReportLine.Validate(Quantity, Round(Abs(IntrastatReportLine.Quantity), UOMMgt.QtyRndPrecision()));
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
        if DataExchDef.Get('INTRA-2022-ES') then
            DataExchDef.Delete(true);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLTxt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);

        IntrastatReportSetup.Get();
        IntrastatReportSetup."Zip Files" := true;
        IntrastatReportSetup."Data Exch. Def. Code" := 'INTRA-2022-ES';
        IntrastatReportSetup.Modify();
    end;

    var
        DefPrivatePersonVATNoLbl: Label 'QV999999999999', Locked = true;
        Def3DPartyTradeVATNoLbl: Label 'QV999999999999', Locked = true;
        DefUnknowVATNoLbl: Label 'QV999999999999', Locked = true;
        DataExchangeXMLTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-ES" Name="Intrastat Report 2022" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="4813" ColumnSeparator="2" FileType="1" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="1" Code="DEFAULT" Name="DEFAULT" ColumnCount="14"><DataExchColumnDef ColumnNo="1" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="2" Name="Area" Show="false" DataType="0" Length="2" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="3" Name="Shpt. Method Code" Show="false" DataType="0" Length="3" TextPaddingRequired="false" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="4" Name="Transaction Type" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="5" Name="Transport Method" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="6" Name="Entry/Exit Point" Show="false" DataType="0" Length="4" TextPaddingRequired="false" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="7" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="8" Name="Country/Region of Origin Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="9" Name="Statistical System" Show="false" DataType="0" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="10" Name="Total Weight" Show="false" DataType="2" DataFormat="&lt;Precision,2:&gt;&lt;Integer&gt;&lt;Decimal&gt;" DataFormattingCulture="en-US" TextPaddingRequired="false" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="11" Name="Quantity" Show="false" DataType="2" DataFormat="&lt;Precision,2:&gt;&lt;Integer&gt;&lt;Decimal&gt;" DataFormattingCulture="en-US" TextPaddingRequired="false" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="12" Name="Amount" Show="false" DataType="2" DataFormat="&lt;Precision,2:&gt;&lt;Integer&gt;&lt;Decimal&gt;" DataFormattingCulture="en-US" TextPaddingRequired="false" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="13" Name="Statistical Value" Show="false" DataType="2" DataFormat="&lt;Precision,2:&gt;&lt;Integer&gt;&lt;Decimal&gt;" DataFormattingCulture="en-US" TextPaddingRequired="false" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="14" Name="Partner Tax ID" Show="false" DataType="0" TextPaddingRequired="false" Justification="1" UseNodeNameAsValue="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="1" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="1" FieldID="7" Optional="true" TransformationRule="EUCOUNTRYCODELOOKUP"><TransformationRules><Code>EUCOUNTRYCODELOOKUP</Code><Description>EU Country Lookup</Description><TransformationType>13</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>9</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>7</TargetFieldID><FieldLookupRule>1</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="2" FieldID="26" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="28" Optional="true" /><DataExchFieldMapping ColumnNo="4" FieldID="8" Optional="true" /><DataExchFieldMapping ColumnNo="5" FieldID="9" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="25" Optional="true" /><DataExchFieldMapping ColumnNo="7" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="8" FieldID="24" Optional="true" TransformationRule="EUCOUNTRYCODELOOKUP"><TransformationRules><Code>EUCOUNTRYCODELOOKUP</Code><Description>EU Country Lookup</Description><TransformationType>13</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>9</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>7</TargetFieldID><FieldLookupRule>1</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="36" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>Get first character</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>TRIMALL</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="10" FieldID="21" Optional="true" /><DataExchFieldMapping ColumnNo="11" FieldID="14" Optional="true" /><DataExchFieldMapping ColumnNo="12" FieldID="13" Optional="true" /><DataExchFieldMapping ColumnNo="13" FieldID="17" Optional="true" /><DataExchFieldMapping ColumnNo="14" FieldID="29" Optional="true" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available    
}