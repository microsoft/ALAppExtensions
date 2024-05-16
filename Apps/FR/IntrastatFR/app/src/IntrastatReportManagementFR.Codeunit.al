// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Company;
using System.IO;
using System.Utilities;

codeunit 10851 IntrastatReportManagementFR
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

    local procedure GetDeclarationId(): Integer
    var
        LastDeclarationId: Integer;
    begin
        CompanyInformation.Get();
        LastDeclarationId := CompanyInformation."Last Intr. Declaration ID";
        LastDeclarationId := LastDeclarationId + 1;
        CompanyInformation.Validate("Last Intr. Declaration ID", LastDeclarationId);
        CompanyInformation.Modify();
        exit(LastDeclarationId);
    end;

    local procedure FormatExtendNumberToXML(Value: Integer; Length: Integer): Text
    begin
        exit(
          Format(
            Value, 0, StrSubstNo('<Integer,%1><Filler Character,0>', Length)));
    end;

    local procedure FormatToXML(Number: Decimal): Text[30]
    begin
        exit(Format(Number, 0, 9));
    end;

    local procedure GetReferencePeriod(StatisticsPeriod: Code[10]): Text[30]
    begin
        exit('20' + CopyStr(StatisticsPeriod, 1, 2) + '-' + CopyStr(StatisticsPeriod, 3, 2));
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

    local procedure SetDataExchExportParameters(var IntrastatReportHeader2: Record "Intrastat Report Header")
    begin
        CompanyInformation.Get();
        CheckMandatoryCompanyInfo();
        IntrastatReportHeader := IntrastatReportHeader2;
        CurrencyIdentifier := IntrastatReportHeader."Currency Identifier";
        StatisticsPeriodFormatted := GetReferencePeriod(Format(IntrastatReportHeader."Statistics Period"));

        IntrastatReportHeader.TestField("Currency Identifier");
        ObligationLevel := IntrastatReportHeader."Obligation Level";
    end;

    local procedure CheckMandatoryCompanyInfo()
    begin
        CompanyInformation.Get();
        CompanyInformation.TestField(CISD);
        CompanyInformation.TestField("Registration No.");
        CompanyInformation.TestField("VAT Registration No.");
        CompanyInformation.TestField(Name);
    end;

    local procedure IsTransactionSimple(var IntrastatReportLine: Record "Intrastat Report Line"; IntrastatReportLineNo: Code[20]): Boolean
    begin
        IntrastatReportLine.Get(IntrastatReportHeader."No.", IntrastatReportLineNo);
        if IntrastatReportHeader."Obligation Level" = IntrastatReportHeader."Obligation Level"::"4" then
            exit(true);

        if (IntrastatReportHeader."Obligation Level" = IntrastatReportHeader."Obligation Level"::"5") and not (IntrastatReportLine."Transaction Specification" in ['21', '29']) then
            exit(true);

        exit(false);
    end;

    local procedure IsIntrastatExport(DataExchDefCode: Code[20]): Boolean
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
    begin
        if not IntrastatReportMgt.IsFeatureEnabled() then
            exit(false);

        if not IntrastatReportSetup.Get() then
            exit(false);

        if IntrastatReportSetup."Split Files" then
            exit(DataExchDefCode in [IntrastatReportSetup."Data Exch. Def. Code - Receipt", IntrastatReportSetup."Data Exch. Def. Code - Shpt."])
        else
            exit(DataExchDefCode = IntrastatReportSetup."Data Exch. Def. Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeDefineFileNames', '', true, true)]
    local procedure OnBeforeDefineFileNames(var IntrastatReportHeader: Record "Intrastat Report Header"; var FileName: Text; var ReceptFileName: Text; var ShipmentFileName: Text; var ZipFileName: Text; var IsHandled: Boolean)
    begin
        IsHandled := false;
        OnBeforeDefineFileNamesFR(IntrastatReportHeader, FileName, ReceptFileName, ShipmentFileName, ZipFileName, IsHandled);
        if not IsHandled then begin
            FileName := StrSubstNo(FileNameLbl, IntrastatReportHeader."Statistics Period");
            ReceptFileName := StrSubstNo(ReceptFileNameLbl, IntrastatReportHeader."Statistics Period");
            ShipmentFileName := StrSubstNo(ShipmentFileNameLbl, IntrastatReportHeader."Statistics Period");
            ZipFileName := StrSubstNo(ZipFileNameLbl, IntrastatReportHeader."Statistics Period");
        end;

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Generic XML", 'OnBeforeCreateXMLNodeWithoutAttributes', '', true, true)]
    local procedure OnBeforeCreateXMLNodeWithoutAttributes(var xmlNodeName: Text; var xmlNodeValue: Text; var DataExchColumnDef: Record "Data Exch. Column Def"; var DefaultNameSpace: Text; var IsHandled: Boolean)
    begin
        if IsIntrastatExport(DataExchColumnDef."Data Exch. Def Code") then
            case DataExchColumnDef.Path of
                // 1-HEADER
                '/INSTAT/Envelope/envelopeId':
                    xmlNodeValue := CompanyInformation.CISD;
                '/INSTAT/Envelope/DateTime/date':
                    xmlNodeValue := Format(Today, 0, 9);
                '/INSTAT/Envelope/DateTime/time':
                    xmlNodeValue := CopyStr(Format(Time, 0, 9), 1, 8);

                // 2-SENDER
                '/Party/partyId':
                    xmlNodeValue := CompanyInformation.GetPartyID();

                // 4-RCPTHEADER, 5-SHPTHEADER
                '/Declaration/declarationId':
                    xmlNodeValue := FormatExtendNumberToXML(GetDeclarationId(), 6);
                '/Declaration/referencePeriod':
                    xmlNodeValue := StatisticsPeriodFormatted;
                '/Declaration/PSIId':
                    xmlNodeValue := CompanyInformation.GetPartyID();
                '/Declaration/functionCode':
                    xmlNodeValue := 'O';
                '/Declaration/declarationTypeCode':
                    xmlNodeValue := Format(ObligationLevel);

                // 6-RCPTDETAIL, 7-SHPTDETAIL
                '/IntrastatReportLineNo':
                    begin
                        IntrastatReportLine.Get(IntrastatReportHeader."No.", xmlNodeValue);
                        IsTransactionSimpleValue := IsTransactionSimple(IntrastatReportLine, xmlNodeValue);
                        xmlNodeValue := '';
                    end;
                '/Item/CN8':
                    xmlNodeValue := '';
                '/Item/CN8/CN8Code',
                '/Item/MSConsDestCode',
                '/Item/countryOfOriginCode',
                '/Item/netMass',
                '/Item/quantityInSU',
                '/Item/NatureOfTransaction',
                '/Item/NatureOfTransaction/natureOfTransactionACode',
                '/Item/NatureOfTransaction/natureOfTransactionBCode',
                '/Item/modeOfTransportCode',
                '/Item/regionCode':
                    if IsTransactionSimpleValue then
                        xmlNodeValue := '';
                '/Item/itemNumber':
                    begin
                        ItemNumberXML += 1;
                        xmlNodeValue := FormatExtendNumberToXML(ItemNumberXML, 6);
                    end;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Generic XML", 'OnBeforeCreateXMLDeclaration', '', true, true)]
    local procedure OnBeforeCreateXMLDeclaration(DataExchDef: Record "Data Exch. Def"; var xmlDec: XmlDeclaration; var IsHandled: Boolean)
    begin
        if IsIntrastatExport(DataExchDef.Code) then begin
            xmlDec := xmlDeclaration.Create('1.0', 'ISO-8859-1', 'yes');
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Generic XML", 'OnBeforeCreateRootElement', '', true, true)]
    local procedure OnBeforeCreateRootElement(DataExchDef: Record "Data Exch. Def"; var xmlElem: XmlElement; var nName: Text; var nVal: Text; DefaultNameSpace: Text; var xmlNamespaceManager: XmlNamespaceManager; var IsHandled: Boolean)
    begin
        if IsIntrastatExport(DataExchDef.Code) then begin
            xmlElem := xmlElement.Create(nName, DefaultNameSpace, nVal);
            xmlElem.Add(XmlAttribute.CreateNamespaceDeclaration('xsi', LocalNamespaceURILbl));
            xmlElem.Add(XmlAttribute.Create('noNamespaceSchemaLocation', LocalNamespaceURILbl, 'instat62.xsd'));
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Generic XML", 'OnBeforeExportHeader', '', true, true)]
    local procedure OnBeforeExportHeader(var DataExch: Record "Data Exch."; var IsHandled: Boolean)
    var
        IntrastatReportLineRec: Record "Intrastat Report Line";
        InStreamFilters: InStream;
        FiltersText: Text;
    begin
        if IsIntrastatExport(DataExch."Data Exch. Def Code") then begin
            DataExch.CalcFields("Table Filters");
            DataExch."Table Filters".CreateInStream(InStreamFilters);
            InStreamFilters.ReadText(FiltersText);
            IntrastatReportLineRec.SetView(FiltersText);

            case true of
                StrPos(DataExch."Data Exch. Line Def Code", 'RCPTHEADER') <> 0:
                    IntrastatReportLineRec.SetRange(Type, IntrastatReportLine.Type::Receipt);
                StrPos(DataExch."Data Exch. Line Def Code", 'SHPTHEADER') <> 0:
                    IntrastatReportLineRec.SetRange(Type, IntrastatReportLine.Type::Shipment);
                else
                    IntrastatReportLineRec.SetRange(Type);
            end;

            if IntrastatReportLineRec.IsEmpty() then
                IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Generic XML", 'OnBeforeExportDetails', '', true, true)]
    local procedure OnBeforeExportDetails(var DataExch: Record "Data Exch."; var xmlDoc: XmlDocument; var IsHandled: Boolean)
    var
        IntrastatReportLineRec: Record "Intrastat Report Line";
        InStreamFilters: InStream;
        FiltersText: Text;
    begin
        if IsIntrastatExport(DataExch."Data Exch. Def Code") then begin
            ItemNumberXML := 0;
            DataExch.CalcFields("Table Filters");
            DataExch."Table Filters".CreateInStream(InStreamFilters);
            InStreamFilters.ReadText(FiltersText);
            IntrastatReportLineRec.SetView(FiltersText);

            case true of
                StrPos(DataExch."Data Exch. Line Def Code", 'RCPTDETAIL') <> 0:
                    IntrastatReportLineRec.SetRange(Type, IntrastatReportLineRec.Type::Receipt);
                StrPos(DataExch."Data Exch. Line Def Code", 'SHPTDETAIL') <> 0:
                    IntrastatReportLineRec.SetRange(Type, IntrastatReportLineRec.Type::Shipment)
                else
                    IntrastatReportLineRec.SetRange(Type);
            end;

            if IntrastatReportLineRec.IsEmpty() then
                IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeExportIntrastatHeader', '', true, true)]
    local procedure OnBeforeExportIntrastatHeader(var IntrastatReportHeader: Record "Intrastat Report Header"; var IsHandled: Boolean)
    begin
        SetDataExchExportParameters(IntrastatReportHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Mapping", 'OnBeforeCheckRecRefCount', '', true, true)]
    local procedure OnBeforeCheckRecRefCount(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeDefineFileNamesFR(var IntrastatReportHeader: Record "Intrastat Report Header"; var FileName: Text; var ReceptFileName: Text; var ShipmentFileName: Text; var ZipFileName: Text; var IsHandled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeValidateReportWithAdvancedChecklist', '', true, true)]
    local procedure OnBeforeValidateReportWithAdvancedChecklist(var IntrastatReportLine: Record "Intrastat Report Line"; IntrastatReportHeader: Record "Intrastat Report Header");
    begin
        IntrastatReportLine.SetFilter("Transaction Specification", IntrastatReportHeader."Trans. Spec. Filter");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeExportIntrastatReportLines', '', true, true)]
    local procedure OnBeforeExportIntrastatReportLines(var IntrastatReportLine: Record "Intrastat Report Line"; IntrastatReportHeader: Record "Intrastat Report Header");
    begin
        IntrastatReportLine.SetFilter("Transaction Specification", IntrastatReportHeader."Trans. Spec. Filter");
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
        if DataExchDef.Get('INTRA-2022-FR') then
            DataExchDef.Delete(true);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLP1Txt + DataExchangeXMLP2Txt + DataExchangeXMLP3Txt + DataExchangeXMLP4Txt + DataExchangeXMLP5Txt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);

        IntrastatReportSetup.Get();
        IntrastatReportSetup."Data Exch. Def. Code" := 'INTRA-2022-FR';
        IntrastatReportSetup.Modify();
    end;

    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportLine: Record "Intrastat Report Line";
        CompanyInformation: Record "Company Information";
        ObligationLevel: Enum "Obligation Level";
        DefPrivatePersonVATNoLbl: TextConst ENU = 'QN999999999999';
        Def3DPartyTradeVATNoLbl: TextConst ENU = 'QV999999999999';
        DefUnknowVATNoLbl: TextConst ENU = 'QV999999999999';
        FileNameLbl: Label 'Intrastat-%1.xml', Comment = '%1 - Statistics Period';
        ReceptFileNameLbl: Label 'Receipt-%1.xml', Comment = '%1 - Statistics Period';
        ShipmentFileNameLbl: Label 'Shipment-%1.xml', Comment = '%1 - Statistics Period';
        ZipFileNameLbl: Label 'Intrastat-%1.zip', Comment = '%1 - Statistics Period';
        LocalNamespaceURILbl: Label 'http://www.w3.org/2001/XMLSchema-instance', Locked = true;
        StatisticsPeriodFormatted: Text[30];
        MessageID, VATIDNo, CurrencyIdentifier : Text;
        IsTransactionSimpleValue: Boolean;
        ItemNumberXML: Integer;
        DataExchangeXMLP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-FR" Name="Intrastat 2022 France" Type="5" ExternalDataHandlingCodeunit="4813" FileType="0" ReadingWritingCodeunit="1283">  <DataExchLineDef LineType="1" Code="1-HEADER" Name="Parent Node for Intrastat XML" ColumnCount="6"><DataExchColumnDef ColumnNo="1" Name="INSTAT" Show="false" DataType="0" Path="/INSTAT" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Envelope" Show="false" DataType="0" Path="/INSTAT/Envelope" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="envelopeId" Show="false" DataType="0" Path="/INSTAT/Envelope/envelopeId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="DateTime" Show="false" DataType="0" Path="/INSTAT/Envelope/DateTime" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="date" Show="false" DataType="0" Path="/INSTAT/Envelope/DateTime/date" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="time" Show="false" DataType="0" Path="/INSTAT/Envelope/DateTime/time" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="79" Name="" MappingCodeunit="1269">  <DataExchFieldMapping ColumnNo="3" UseDefaultValue="true" /></DataExchMapping>  </DataExchLineDef>  <DataExchLineDef LineType="1" Code="2-SENDER" ColumnCount="0" DataLineTag="/INSTAT/Envelope" ParentCode="1-HEADER"><DataExchColumnDef ColumnNo="1" Name="Party" Show="false" DataType="0" Path="/Party[@partyType=&quot;PSI&quot; and @partyRole=&quot;sender&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="partyType" Show="false" DataType="0" Path="/Party[@partyType]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="partyRole" Show="false" DataType="0" Path="/Party[@partyRole]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="partyId" Show="false" DataType="0" Path="/Party/partyId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="partyName" Show="false" DataType="0" Path="/Party/partyName" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="79" Name="" MappingCodeunit="1269">  <DataExchFieldMapping ColumnNo="4" Optional="true" />  <DataExchFieldMapping ColumnNo="5" FieldID="2" /></DataExchMapping>  </DataExchLineDef>  <DataExchLineDef LineType="1" Code="3-ADDITIONAL" ColumnCount="0" DataLineTag="/INSTAT/Envelope" ParentCode="1-HEADER"><DataExchColumnDef ColumnNo="1" Name="softwareUsed" Show="false" DataType="0" Path="/softwareUsed" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="79" Name="" MappingCodeunit="1269">  <DataExchFieldMapping ColumnNo="1" UseDefaultValue="true" DefaultValue="DynamicsNAV" /></DataExchMapping>  </DataExchLineDef>  <DataExchLineDef LineType="1" Code="4-RCPTHEADER" ColumnCount="0" DataLineTag="/INSTAT/Envelope" ParentCode="1-HEADER"><DataExchColumnDef ColumnNo="1" Name="Declaration" Show="false" DataType="0" Path="/Declaration" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="declarationId" Show="false" DataType="0" Path="/Declaration/declarationId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="referencePeriod" Show="false" DataType="0" Path="/Declaration/referencePeriod" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="PSIId" Show="false" DataType="0" Path="/Declaration/PSIId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Function" Show="false" DataType="0" Path="/Declaration/Function" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="functionCode" Show="false" DataType="0" Path="/Declaration/Function/functionCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="declarationTypeCode" Show="false" DataType="0" Path="/Declaration/declarationTypeCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="flowCode" Show="false" DataType="0" Path="/Declaration/flowCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="currencyCode" Show="false" DataType="0" Path="/Declaration/currencyCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="79" Name="" MappingCodeunit="1269"> ',
                            Locked = true; // will be replaced with file import when available  
        DataExchangeXMLP2Txt: Label '<DataExchFieldMapping ColumnNo="6" UseDefaultValue="true" DefaultValue="O" />  <DataExchFieldMapping ColumnNo="8" UseDefaultValue="true" DefaultValue="A" />  <DataExchFieldMapping ColumnNo="9" UseDefaultValue="true" DefaultValue="EUR" /></DataExchMapping>  </DataExchLineDef>  <DataExchLineDef LineType="1" Code="5-SHPTHEADER" ColumnCount="0" DataLineTag="/INSTAT/Envelope" ParentCode="1-HEADER"><DataExchColumnDef ColumnNo="1" Name="Declaration" Show="false" DataType="0" Path="/Declaration" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="declarationId" Show="false" DataType="0" Path="/Declaration/declarationId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="referencePeriod" Show="false" DataType="0" Path="/Declaration/referencePeriod" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="PSIId" Show="false" DataType="0" Path="/Declaration/PSIId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Function" Show="false" DataType="0" Path="/Declaration/Function" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="functionCode" Show="false" DataType="0" Path="/Declaration/Function/functionCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="declarationTypeCode" Show="false" DataType="0" Path="/Declaration/declarationTypeCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="flowCode" Show="false" DataType="0" Path="/Declaration/flowCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="currencyCode" Show="false" DataType="0" Path="/Declaration/currencyCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="79" Name="" MappingCodeunit="1269">  <DataExchFieldMapping ColumnNo="6" UseDefaultValue="true" DefaultValue="O" />  <DataExchFieldMapping ColumnNo="8" UseDefaultValue="true" DefaultValue="D" />  <DataExchFieldMapping ColumnNo="9" UseDefaultValue="true" DefaultValue="EUR" /></DataExchMapping>  </DataExchLineDef>  <DataExchLineDef LineType="0" Code="6-RCPTDETAIL" ColumnCount="0" DataLineTag="/INSTAT/Envelope/Declaration[flowCode =&quot;A&quot;]" ParentCode="4-RCPTHEADER"><DataExchColumnDef ColumnNo="1" Name="IntrastatReportLineNo" Show="false" DataType="0" Path="/IntrastatReportLineNo" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="2" Name="Item" Show="false" DataType="0" Path="/Item" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="itemNumber" Show="false" DataType="0" Path="/Item/itemNumber" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="CN8" Show="false" DataType="0" Path="/Item/CN8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="5" Name="CN8Code" Show="false" DataType="0" Path="/Item/CN8/CN8Code" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="6" Name="MSConsDestCode" Show="false" DataType="0" Path="/Item/MSConsDestCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="true" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="7" Name="countryOfOriginCode" Show="false" DataType="0" Path="/Item/countryOfOriginCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="8" Name="netMass" Show="false" DataType="0" Path="/Item/netMass" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="9" Name="quantityInSU" Show="false" DataType="0" Path="/Item/quantityInSU" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="10" Name="invoicedAmount" Show="false" DataType="0" Path="/Item/invoicedAmount" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="partnerId" Show="false" DataType="0" Path="/Item/partnerId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="statisticalProcedureCode" Show="false" DataType="0" Path="/Item/statisticalProcedureCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="NatureOfTransaction" Show="false" DataType="0" Path="/Item/NatureOfTransaction" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="14" Name="natureOfTransactionACode" Show="false" DataType="0" Path="/Item/NatureOfTransaction/natureOfTransactionACode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" />',
                            Locked = true;
        DataExchangeXMLP3Txt: Label '<DataExchColumnDef ColumnNo="15" Name="natureOfTransactionBCode" Show="false" DataType="0" Path="/Item/NatureOfTransaction/natureOfTransactionBCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="16" Name="modeOfTransportCode" Show="false" DataType="0" Path="/Item/modeOfTransportCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="17" Name="regionCode" Show="false" DataType="0" Path="/Item/regionCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchMapping TableId="4812" Name="" MappingCodeunit="1269" PreMappingCodeunit="10853" PostMappingCodeunit="10855">  <DataExchFieldMapping ColumnNo="1" FieldID="2" Optional="true" />  <DataExchFieldMapping ColumnNo="3" FieldID="23" Optional="true" />  <DataExchFieldMapping ColumnNo="5" FieldID="5" Optional="true" TransformationRule="ALPHANUM_ONLY" />  <DataExchFieldMapping ColumnNo="6" FieldID="25" Optional="true" />  <DataExchFieldMapping ColumnNo="7" FieldID="24" Optional="true" />  <DataExchFieldMapping ColumnNo="8" FieldID="21" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules>  <Code>ALPHANUM_ONLY</Code>  <Description>Alphanumeric Text Only</Description>  <TransformationType>7</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules>  <Code>ROUNDTOINT</Code>  <Description>Round to integer</Description>  <TransformationType>14</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule>  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>1.00</Precision>  <Direction>=</Direction>  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="9" FieldID="14" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules>  <Code>ALPHANUM_ONLY</Code>  <Description>Alphanumeric Text Only</Description>  <TransformationType>7</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules>  <Code>ROUNDTOINT</Code>  <Description>Round to integer</Description>  <TransformationType>14</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule>  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>1.00</Precision>  <Direction>=</Direction>  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="10" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules>  <Code>ALPHANUM_ONLY</Code>  <Description>Alphanumeric Text Only</Description>  <TransformationType>7</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules>  <Code>ROUNDTOINT</Code>  <Description>Round to integer</Description>  <TransformationType>14</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule>  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>1.00</Precision>  <Direction>=</Direction>  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="11" FieldID="29" Optional="true" />  <DataExchFieldMapping ColumnNo="12" FieldID="27" Optional="true" />  <DataExchFieldMapping ColumnNo="14" FieldID="8" Optional="true" TransformationRule="FIRST_CHARACTER"><TransformationRules>  <Code>FIRST_CHARACTER</Code>  <Description>Extracts the first character of the string</Description>  <TransformationType>4</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>1</StartPosition>  <Length>1</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="15" FieldID="8" Optional="true" TransformationRule="SECOND_CHARACTER"><TransformationRules>  <Code>SECOND_CHARACTER</Code>  <Description>Extract the second character of the string</Description>  <TransformationType>4</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>2</StartPosition>  <Length>1</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="16" FieldID="9" Optional="true" />  <DataExchFieldMapping ColumnNo="17" FieldID="26" Optional="true" /></DataExchMapping>',
                            Locked = true;
        DataExchangeXMLP4Txt: Label '</DataExchLineDef>  <DataExchLineDef LineType="0" Code="7-SHPTDETAIL" ColumnCount="0" DataLineTag="/INSTAT/Envelope/Declaration[flowCode =&quot;D&quot;]" ParentCode="5-SHPTHEADER"><DataExchColumnDef ColumnNo="1" Name="IntrastatReportLineNo" Show="false" DataType="0" Path="/IntrastatReportLineNo" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="2" Name="Item" Show="false" DataType="0" Path="/Item" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="itemNumber" Show="false" DataType="0" Path="/Item/itemNumber" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="CN8" Show="false" DataType="0" Path="/Item/CN8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="CN8Code" Show="false" DataType="0" Path="/Item/CN8/CN8Code" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="6" Name="MSConsDestCode" Show="false" DataType="0" Path="/Item/MSConsDestCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="7" Name="countryOfOriginCode" Show="false" DataType="0" Path="/Item/countryOfOriginCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="8" Name="netMass" Show="false" DataType="0" Path="/Item/netMass" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="9" Name="quantityInSU" Show="false" DataType="0" Path="/Item/quantityInSU" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="10" Name="invoicedAmount" Show="false" DataType="0" Path="/Item/invoicedAmount" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="partnerId" Show="false" DataType="0" Path="/Item/partnerId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="statisticalProcedureCode" Show="false" DataType="0" Path="/Item/statisticalProcedureCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="NatureOfTransaction" Show="false" DataType="0" Path="/Item/NatureOfTransaction" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="14" Name="natureOfTransactionACode" Show="false" DataType="0" Path="/Item/NatureOfTransaction/natureOfTransactionACode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="15" Name="natureOfTransactionBCode" Show="false" DataType="0" Path="/Item/NatureOfTransaction/natureOfTransactionBCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="16" Name="modeOfTransportCode" Show="false" DataType="0" Path="/Item/modeOfTransportCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchColumnDef ColumnNo="17" Name="regionCode" Show="false" DataType="0" Path="/Item/regionCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="true" /><DataExchMapping TableId="4812" Name="" KeyIndex="7" MappingCodeunit="1269" PreMappingCodeunit="10854" PostMappingCodeunit="10855">  <DataExchFieldMapping ColumnNo="1" FieldID="2" Optional="true" />  <DataExchFieldMapping ColumnNo="3" FieldID="23" Optional="true" />  <DataExchFieldMapping ColumnNo="5" FieldID="5" Optional="true" TransformationRule="ALPHANUM_ONLY" />  <DataExchFieldMapping ColumnNo="6" FieldID="25" Optional="true" />  <DataExchFieldMapping ColumnNo="7" FieldID="24" Optional="true" />  <DataExchFieldMapping ColumnNo="8" FieldID="21" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules>  <Code>ALPHANUM_ONLY</Code>  <Description>Alphanumeric Text Only</Description>  <TransformationType>7</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules>  <Code>ROUNDTOINT</Code>  <Description>Round to integer</Description>  <TransformationType>14</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule>  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>1.00</Precision>  <Direction>=</Direction>  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="9" FieldID="14" Optional="true" TransformationRule="ROUNDTOINT">',
                            Locked = true;
        DataExchangeXMLP5Txt: Label '<TransformationRules>  <Code>ALPHANUM_ONLY</Code>  <Description>Alphanumeric Text Only</Description>  <TransformationType>7</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules>  <Code>ROUNDTOINT</Code>  <Description>Round to integer</Description>  <TransformationType>14</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule>  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>1.00</Precision>  <Direction>=</Direction>  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="10" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules>  <Code>ALPHANUM_ONLY</Code>  <Description>Alphanumeric Text Only</Description>  <TransformationType>7</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules>  <Code>ROUNDTOINT</Code>  <Description>Round to integer</Description>  <TransformationType>14</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>0</StartPosition>  <Length>0</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule>  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>1.00</Precision>  <Direction>=</Direction>  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="11" FieldID="29" Optional="true" />  <DataExchFieldMapping ColumnNo="12" FieldID="27" Optional="true" />  <DataExchFieldMapping ColumnNo="14" FieldID="8" Optional="true" TransformationRule="FIRST_CHARACTER"><TransformationRules>  <Code>FIRST_CHARACTER</Code>  <Description>Extracts the first character of the string</Description>  <TransformationType>4</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>1</StartPosition>  <Length>1</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="15" FieldID="8" Optional="true" TransformationRule="SECOND_CHARACTER"><TransformationRules>  <Code>SECOND_CHARACTER</Code>  <Description>Extract the second character of the string</Description>  <TransformationType>4</TransformationType>  <FindValue />  <ReplaceValue />  <StartPosition>2</StartPosition>  <Length>1</Length>  <DataFormat />  <DataFormattingCulture />  <NextTransformationRule />  <TableID>0</TableID>  <SourceFieldID>0</SourceFieldID>  <TargetFieldID>0</TargetFieldID>  <FieldLookupRule>0</FieldLookupRule>  <Precision>0.00</Precision>  <Direction />  <ExportFromDateType>0</ExportFromDateType></TransformationRules>  </DataExchFieldMapping>  <DataExchFieldMapping ColumnNo="16" FieldID="9" Optional="true" />  <DataExchFieldMapping ColumnNo="17" FieldID="26" Optional="true" /></DataExchMapping>  </DataExchLineDef></DataExchDef></root>',
                            Locked = true;
}