// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Address;
using System.IO;
using System.Utilities;

codeunit 11150 IntrastatReportManagementAT
{
    Access = Internal;
    SingleInstance = true;

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
        IntrastatReportChecklist.Validate("Field No.", 6);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 7);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 8);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 13);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 14);
        IntrastatReportChecklist.Validate("Filter Expression", 'Supplementary Units: True');
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 17);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 21);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 24);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 29);
        IntrastatReportChecklist.Validate("Filter Expression", 'Type: Shipment');
        IntrastatReportChecklist.Insert(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Report Line", 'OnBeforeGetPartnerIDForCountry', '', true, true)]
    local procedure OnBeforeGetPartnerIDForCountry(CountryRegionCode: Code[10]; VATRegistrationNo: Text[50]; IsPrivatePerson: Boolean; IsThirdPartyTrade: Boolean; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
        IsHandled := true;
        PartnerID := GetPartnerIDForCountry(CountryRegionCode, VATRegistrationNo, IsPrivatePerson, IsThirdPartyTrade);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeCreateDefaultDataExchangeDef', '', true, true)]
    local procedure OnBeforeCreateDefaultDataExchangeDef(var IsHandled: Boolean);
    begin
        CreateDefaultDataExchangeDef();
        IsHandled := true;
    end;

    local procedure GetPartnerIDForCountry(CountryRegionCode: Code[10]; VATRegistrationNo: Text[50]; IsPrivatePerson: Boolean; IsThirdPartyTrade: Boolean): Text[50]
    var
        CountryRegion: Record "Country/Region";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        PartnerID: Text[50];
        IsHandled: Boolean;
    begin
        OnBeforeGetPartnerIDForCountryAT(CountryRegionCode, VATRegistrationNo, IsPrivatePerson, IsThirdPartyTrade, PartnerID, IsHandled);
        if IsHandled then
            exit(PartnerID);

        IntrastatReportSetup.Get();
        if IsPrivatePerson then
            exit(IntrastatReportSetup."Def. Private Person VAT No.");

        if IsThirdPartyTrade then
            exit(IntrastatReportSetup."Def. 3-Party Trade VAT No.");

        if (CountryRegionCode <> '') and CountryRegion.Get(CountryRegionCode) then
            if CountryRegion.IsEUCountry(CountryRegionCode) then
                if VATRegistrationNo <> '' then
                    exit(VATRegistrationNo);

        if CountryRegion."Intrastat Code" <> '' then
            exit(CountryRegion."Intrastat Code" + UnknownCountryVATNoLbl);

        exit(IntrastatReportSetup."Def. VAT for Unknown State");
    end;

    procedure CreateDefaultDataExchangeDef()
    var
        DataExchDef: Record "Data Exch. Def";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        TempBlob: Codeunit "Temp Blob";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
    begin
        if DataExchDef.Get('INTRA-2022-AT') then
            DataExchDef.Delete(true);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLTxt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);

        IntrastatReportSetup.Get();
        IntrastatReportSetup."Split Files" := true;
        IntrastatReportSetup."Zip Files" := true;
        IntrastatReportSetup."Data Exch. Def. Code - Receipt" := 'INTRA-2022-AT';
        IntrastatReportSetup."Data Exch. Def. Code - Shpt." := 'INTRA-2022-AT';
        IntrastatReportSetup.Modify();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPartnerIDForCountryAT(CountryRegionCode: Code[10]; VATRegistrationNo: Text[50]; IsPrivatePerson: Boolean; IsThirdPartyTrade: Boolean; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
    end;

    var
        DefPrivatePersonVATNoLbl: Label 'QN999999999999', Locked = true;
        Def3DPartyTradeVATNoLbl: Label 'QV999999999999', Locked = true;
        DefUnknowVATNoLbl: Label 'QV999999999999', Locked = true;
        UnknownCountryVATNoLbl: Label '999999999999', Locked = true;
        DataExchangeXMLTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-AT" Name="Intrastat Report 2022" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="4813" ColumnSeparator="1" FileType="1" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="1" Code="DEFAULT" Name="DEFAULT" ColumnCount="10"><DataExchColumnDef ColumnNo="1" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="Tariff Description" Show="false" DataType="0" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="Country/Region Code" Show="false" DataType="0" TextPaddingRequired="false" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="Country/Region of Origin Code" Show="false" DataType="0" TextPaddingRequired="false" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="Nature of Transaction" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="1" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="Total Weight" Show="false" DataType="2" DataFormat="&lt;Integer&gt;&lt;Decimals,4&gt;&lt;Comma,,&gt;" DataFormattingCulture="en-US" Length="14" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="7" Name="Supplementary Quantity" Show="false" DataType="2" DataFormat="&lt;Integer&gt;&lt;Decimals,4&gt;&lt;Comma,,&gt;" DataFormattingCulture="en-US" Length="14" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="true" /><DataExchColumnDef ColumnNo="8" Name="Amount" Show="false" DataType="2" DataFormat="&lt;Integer&gt;&lt;Decimals,3&gt;&lt;Comma,,&gt;" DataFormattingCulture="en-US" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="Statistical Value" Show="false" DataType="2" DataFormat="&lt;Integer&gt;&lt;Decimals,3&gt;&lt;Comma,,&gt;" DataFormattingCulture="en-US" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="10" Name="Partner VAT ID" Show="false" DataType="0" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="5" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="1" FieldID="5" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="2" FieldID="6" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="4" FieldID="24" Optional="true" /><DataExchFieldMapping ColumnNo="5" FieldID="8" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="21" Optional="true" /><DataExchFieldMapping ColumnNo="7" FieldID="35" Optional="true" /><DataExchFieldMapping ColumnNo="8" FieldID="13" Optional="true" /><DataExchFieldMapping ColumnNo="9" FieldID="17" Optional="true" /><DataExchFieldMapping ColumnNo="10" FieldID="29" Optional="true" /><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="24" /><DataExchFieldGrouping FieldID="29" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available  
}