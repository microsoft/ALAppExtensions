// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.CRM.Contact;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Vendor;
using System.IO;
using System.Utilities;

codeunit 11029 IntrastatReportManagementDE
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
        IntrastatReportChecklist.Validate("Filter Expression", 'Supplementary Units: True');
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 24);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 26);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 29);
        IntrastatReportChecklist.Validate("Filter Expression", 'Type: Shipment');
        IntrastatReportChecklist.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeDefineFileNames', '', true, true)]
    local procedure OnBeforeDefineFileNames(var IntrastatReportHeader: Record "Intrastat Report Header"; var FileName: Text; var ReceptFileName: Text; var ShipmentFileName: Text; var ZipFileName: Text; var IsHandled: Boolean)
    begin
        IsHandled := false;
        OnBeforeDefineFileNamesDE(IntrastatReportHeader, FileName, ReceptFileName, ShipmentFileName, ZipFileName, IsHandled);
        if not IsHandled then begin
            FileName := StrSubstNo(FileNameLbl, MessageID);
            ReceptFileName := FileName;
            ShipmentFileName := FileName;
            ZipFileName := StrSubstNo(ZipFileNameLbl, IntrastatReportHeader."Statistics Period");
        end;

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Report Line", 'OnBeforeGetPartnerIDForCountry', '', true, true)]
    local procedure OnBeforeGetPartnerIDForCountry(CountryRegionCode: Code[10]; VATRegistrationNo: Text[50]; IsPrivatePerson: Boolean; IsThirdPartyTrade: Boolean; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
        IsHandled := true;
        PartnerID := GetPartnerIDForCountry(CountryRegionCode, VATRegistrationNo, IsPrivatePerson, IsThirdPartyTrade);
    end;

    local procedure GetPartnerIDForCountry(CountryRegionCode: Code[10]; VATRegistrationNo: Text[50]; IsPrivatePerson: Boolean; IsThirdPartyTrade: Boolean): Text[50]
    var
        CountryRegion: Record "Country/Region";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        PartnerID: Text[50];
        IsHandled: Boolean;
    begin
        OnBeforeGetPartnerIDForCountryDE(CountryRegionCode, VATRegistrationNo, IsPrivatePerson, IsThirdPartyTrade, PartnerID, IsHandled);
        if IsHandled then
            exit(PartnerID);

        IntrastatReportSetup.Get();
        if IsPrivatePerson then
            exit(IntrastatReportSetup."Def. Private Person VAT No.");

        if IsThirdPartyTrade then begin
            if CountryRegionCode <> '' then
                if CountryRegion.Get(CountryRegionCode) then
                    if CountryRegion."Intrastat Code" <> '' then
                        exit(CountryRegion."Intrastat Code" + UnknownCountryVATNoLbl);
            exit(IntrastatReportSetup."Def. 3-Party Trade VAT No.");
        end;

        if (CountryRegionCode <> '') and CountryRegion.Get(CountryRegionCode) then
            if CountryRegion.IsEUCountry(CountryRegionCode) then
                if VATRegistrationNo <> '' then
                    exit(VATRegistrationNo);

        exit(IntrastatReportSetup."Def. VAT for Unknown State");
    end;

    local procedure GetMaterialNumber(): Text
    var
        CompanyInformation: Record "Company Information";
    begin
        if TestIndicator then
            exit('XGTEST');

        CompanyInformation.Get();
        exit(CompanyInformation."Company No.");
    end;

    local procedure GetReceiverInfo(FieldNo: Integer): Text
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        Contact: Record Contact;
        Vendor: Record Vendor;
        Country: Record "Country/Region";
        recRef: RecordRef;
        fldRef: FieldRef;
    begin
        IntrastatReportSetup.Get();
        IntrastatReportSetup.TestField("Intrastat Contact Type");

        if IntrastatReportSetup."Intrastat Contact Type" = IntrastatReportSetup."Intrastat Contact Type"::Contact then begin
            Contact.Get(IntrastatReportSetup."Intrastat Contact No.");
            recRef.GetTable(Contact);
        end;
        if IntrastatReportSetup."Intrastat Contact Type" = IntrastatReportSetup."Intrastat Contact Type"::Vendor then begin
            Vendor.Get(IntrastatReportSetup."Intrastat Contact No.");
            recRef.GetTable(Vendor);
        end;
        fldRef := recRef.Field(FieldNo);
        if FieldNo = Contact.FieldNo("Country/Region Code") then begin
            if Country.Get(fldRef.Value) then
                exit(Country.Name);
        end else
            exit(fldRef.Value);
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Generic XML", 'OnBeforeCreateXMLNodeWithoutAttributes', '', true, true)]
    local procedure OnBeforeCreateXMLNodeWithoutAttributes(var xmlNodeName: Text; var xmlNodeValue: Text; var DataExchColumnDef: Record "Data Exch. Column Def"; var DefaultNameSpace: Text; var IsHandled: Boolean)
    var
        CompanyInformation: Record "Company Information";
        Contact: Record Contact;
        DataExchLineDef, DataExchLineDef2 : Record "Data Exch. Line Def";
    begin
        if IsIntrastatExport(DataExchColumnDef."Data Exch. Def Code") then
            case DataExchColumnDef.Path of
                '/INSTAT/Envelope/envelopeId':
                    xmlNodeValue := MessageID;
                '/INSTAT/Envelope/DateTime/date':
                    xmlNodeValue := Format(CreationDate, 0, 9);
                '/INSTAT/Envelope/DateTime/time':
                    xmlNodeValue := Format(CreationTime, 0, '<Hours24>:<Minutes,2>:<Seconds,2>');
                '/Declaration/declarationId':
                    xmlNodeValue := MessageID;
                '/Declaration/DateTime/date':
                    xmlNodeValue := Format(CreationDate, 0, 9);
                '/Declaration/DateTime/time':
                    xmlNodeValue := Format(CreationTime, 0, '<Hours24>:<Minutes,2>:<Seconds,2>');
                '/Declaration/referencePeriod':
                    xmlNodeValue := Format(StartDate, 0, '<Year4>-<Month,2>');
                '/Declaration/PSIId':
                    xmlNodeValue := VATIDNo;
                '/Declaration/currencyCode':
                    xmlNodeValue := CurrencyIdentifier;
                '/Declaration/totalNetMass':
                    begin
                        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportHeader."No.");
                        DataExchLineDef.Get(DataExchColumnDef."Data Exch. Def Code", DataExchColumnDef."Data Exch. Line Def Code");
                        DataExchLineDef2.SetRange("Data Exch. Def Code", DataExchLineDef."Data Exch. Def Code");
                        DataExchLineDef2.SetRange("Parent Code", DataExchLineDef.Code);
                        DataExchLineDef2.FindFirst();
                        if StrPos(DataExchLineDef2."Data Line Tag", '[flowCode ="A"]') <> 0 then
                            xmlNodeValue := Format(TotalWeightRcpt, 0, '<Integer>')
                        else
                            xmlNodeValue := Format(TotalWeightShpt, 0, '<Integer>');
                    end;
                '/Declaration/totalInvoicedAmount':
                    begin
                        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportHeader."No.");
                        DataExchLineDef.Get(DataExchColumnDef."Data Exch. Def Code", DataExchColumnDef."Data Exch. Line Def Code");
                        DataExchLineDef2.SetRange("Data Exch. Def Code", DataExchLineDef."Data Exch. Def Code");
                        DataExchLineDef2.SetRange("Parent Code", DataExchLineDef.Code);
                        DataExchLineDef2.FindFirst();
                        if StrPos(DataExchLineDef2."Data Line Tag", '[flowCode ="A"]') <> 0 then
                            xmlNodeValue := Format(TotalAmtRcpt, 0, '<Integer>')
                        else
                            xmlNodeValue := Format(TotalAmtShpt, 0, '<Integer>');
                    end;
                '/Declaration/totalStatisticalValue':
                    begin
                        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportHeader."No.");
                        DataExchLineDef.Get(DataExchColumnDef."Data Exch. Def Code", DataExchColumnDef."Data Exch. Line Def Code");
                        DataExchLineDef2.SetRange("Data Exch. Def Code", DataExchLineDef."Data Exch. Def Code");
                        DataExchLineDef2.SetRange("Parent Code", DataExchLineDef.Code);
                        DataExchLineDef2.FindFirst();
                        if StrPos(DataExchLineDef2."Data Line Tag", '[flowCode ="A"]') <> 0 then
                            xmlNodeValue := Format(TotalStatValueRcpt, 0, '<Integer>')
                        else
                            xmlNodeValue := Format(TotalStatValueShpt, 0, '<Integer>');
                    end;
                '/Party[@partyType="PSI" and @partyRole="sender"]/partyId':
                    begin
                        CompanyInformation.Get();
                        xmlNodeValue := Format(CompanyInformation.Area, 2) +
                            PadStr(CopyStr(DelChr(UpperCase(CompanyInformation."Registration No."), '=', RegNoExcludeCharsTxt), 1, 11), 11, '0') +
                            Format(CompanyInformation."Agency No.", 3);
                    end;
                '/Party[@partyType="CC" and @partyRole="receiver"]/partyName':
                    xmlNodeValue := GetReceiverInfo(Contact.FieldNo(Name));
                '/Party[@partyType="CC" and @partyRole="receiver"]/Address/streetName':
                    xmlNodeValue := GetReceiverInfo(Contact.FieldNo(Address));
                '/Party[@partyType="CC" and @partyRole="receiver"]/Address/postalCode':
                    xmlNodeValue := GetReceiverInfo(Contact.FieldNo("Post Code"));
                '/Party[@partyType="CC" and @partyRole="receiver"]/Address/cityName':
                    xmlNodeValue := GetReceiverInfo(Contact.FieldNo(City));
                '/Party[@partyType="CC" and @partyRole="receiver"]/Address/countryName':
                    xmlNodeValue := GetReceiverInfo(Contact.FieldNo("Country/Region Code"));
                '/Party[@partyType="CC" and @partyRole="receiver"]/Address/phoneNumber':
                    xmlNodeValue := GetReceiverInfo(Contact.FieldNo("Phone No."));
                '/Party[@partyType="CC" and @partyRole="receiver"]/Address/faxNumber':
                    xmlNodeValue := GetReceiverInfo(Contact.FieldNo("Fax No."));
                '/Party[@partyType="CC" and @partyRole="receiver"]/Address/e-mail':
                    xmlNodeValue := GetReceiverInfo(Contact.FieldNo("E-Mail"));
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeExportIntrastatHeader', '', true, true)]
    local procedure OnBeforeExportIntrastatHeader(var IntrastatReportHeader: Record "Intrastat Report Header"; var IsHandled: Boolean)
    begin
        SetDataExchExportParameters(IntrastatReportHeader);
    end;

    procedure SetDataExchExportParameters(var IntrastatReportHeader2: Record "Intrastat Report Header")
    var
        CompanyInformation: Record "Company Information";
    begin
        IntrastatReportHeader := IntrastatReportHeader2;
        TestIndicator := IntrastatReportHeader."Test Submission";
        CurrencyIdentifier := IntrastatReportHeader."Currency Identifier";
        StartDate := IntrastatReportHeader.GetStatisticsStartDate();

        IntrastatReportHeader.TestField("Currency Identifier");

        CompanyInformation.Get();
        CompanyInformation.TestField("Registration No.");
        CompanyInformation.TestField(Area);
        CompanyInformation.TestField("Agency No.");
        CompanyInformation.TestField("Company No.");
        CompanyInformation.TestField(Address);
        CompanyInformation.TestField("Post Code");
        CompanyInformation.TestField(City);
        CompanyInformation.TestField("Country/Region Code");

        CreationDate := DT2Date(CurrentDateTime);
        CreationTime := DT2Time(CurrentDateTime);
        MessageID :=
          GetMaterialNumber() + '-' +
          Format(StartDate, 0, '<Year4><Month,2>') + '-' +
          Format(CreationDate, 0, '<Year4><Month,2><Day,2>') + '-' +
          Format(CreationTime, 0, '<Hours2><Minutes>');
        VATIDNo :=
            Format(CompanyInformation.Area, 2) +
            PadStr(CopyStr(DelChr(UpperCase(CompanyInformation."Registration No."), '=', RegNoExcludeCharsTxt), 1, 11), 11, '0') +
            Format(CompanyInformation."Agency No.", 3);

        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportHeader."No.");
        IntrastatReportLine.SetRange(Type, IntrastatReportLine.Type::Receipt);
        IntrastatReportLine.CalcSums(Amount, "Total Weight", "Statistical Value");
        TotalAmtRcpt := Round(IntrastatReportLine.Amount, 1);
        TotalWeightRcpt := Round(IntrastatReportLine."Total Weight", 1);
        TotalStatValueRcpt := Round(IntrastatReportLine."Statistical Value", 1);

        IntrastatReportLine.SetRange(Type, IntrastatReportLine.Type::Shipment);
        IntrastatReportLine.CalcSums(Amount, "Total Weight", "Statistical Value");
        TotalAmtShpt := Round(IntrastatReportLine.Amount, 1);
        TotalWeightShpt := Round(IntrastatReportLine."Total Weight", 1);
        TotalStatValueShpt := Round(IntrastatReportLine."Statistical Value", 1);
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
    local procedure OnBeforeExportDetails(var DataExch: Record "Data Exch."; var IsHandled: Boolean)
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Mapping", 'OnBeforeCheckRecRefCount', '', true, true)]
    local procedure OnBeforeCheckRecRefCount(var IsHandled: Boolean)
    begin
        IsHandled := true;
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
        if DataExchDef.Get('INTRA-2022-DE') then
            DataExchDef.Delete(true);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLP1Txt + DataExchangeXMLP2Txt + DataExchangeXMLP3Txt + DataExchangeXMLP4Txt + DataExchangeXMLP5Txt + DataExchangeXMLP6Txt + DataExchangeXMLP7Txt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);

        IntrastatReportSetup.Get();
        IntrastatReportSetup."Zip Files" := true;
        IntrastatReportSetup."Data Exch. Def. Code" := 'INTRA-2022-DE';
        IntrastatReportSetup.Modify();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPartnerIDForCountryDE(CountryRegionCode: Code[10]; VATRegistrationNo: Text[50]; IsPrivatePerson: Boolean; IsThirdPartyTrade: Boolean; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeDefineFileNamesDE(var IntrastatReportHeader: Record "Intrastat Report Header"; var FileName: Text; var ReceptFileName: Text; var ShipmentFileName: Text; var ZipFileName: Text; var IsHandled: Boolean)
    begin
    end;

    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportLine: Record "Intrastat Report Line";
        DefPrivatePersonVATNoLbl: TextConst ENU = 'QN999999999999';
        Def3DPartyTradeVATNoLbl: TextConst ENU = 'QV999999999999';
        DefUnknowVATNoLbl: TextConst ENU = 'QV999999999999';
        UnknownCountryVATNoLbl: TextConst ENU = '999999999999';
        FileNameLbl: Label '%1.xml', Locked = true;
        ZipFileNameLbl: Label 'Intrastat-%1.zip', Comment = '%1 - Statistics Period';
        RegNoExcludeCharsTxt: Label 'ABCDEFGHIJKLMNOPQRSTUVWXYZ/-.+', Comment = 'Locked. Do not translate.';
        LocalNamespaceURILbl: Label 'http://www.w3.org/2001/XMLSchema-instance', Locked = true;
        StartDate, CreationDate : Date;
        CreationTime: Time;
        TestIndicator: Boolean;
        MessageID, VATIDNo, CurrencyIdentifier : Text;
        TotalAmtRcpt, TotalAmtShpt, TotalWeightRcpt, TotalWeightShpt, TotalStatValueRcpt, TotalStatValueShpt : Decimal;
        DataExchangeXMLP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-DE" Name="Intrastat 2022 DE" Type="5" ExternalDataHandlingCodeunit="4813" FileType="0" ReadingWritingCodeunit="1283"><DataExchLineDef LineType="1" Code="1-HEADER" ColumnCount="6"><DataExchColumnDef ColumnNo="1" Name="INSTAT" Show="false" DataType="0" Path="/INSTAT" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="Envelope" Show="false" DataType="0" Path="/INSTAT/Envelope" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="envelopeId" Show="false" DataType="0" Path="/INSTAT/Envelope/envelopeId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="DateTime" Show="false" DataType="0" Path="/INSTAT/Envelope/DateTime" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="date" Show="false" DataType="0" Path="/INSTAT/Envelope/DateTime/date" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="time" Show="false" DataType="0" Path="/INSTAT/Envelope/DateTime/time" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchMapping TableId="79" Name="" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="3" UseDefaultValue="true" DefaultValue="x" /></DataExchMapping></DataExchLineDef><DataExchLineDef LineType="1" Code="2-SENDER" ColumnCount="12" DataLineTag="/INSTAT/Envelope" ParentCode="1-HEADER"><DataExchColumnDef ColumnNo="1" Name="Party" Show="false" DataType="0" Path="/Party[@partyType=&quot;PSI&quot; and @partyRole=&quot;sender&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="partyId" Show="false" DataType="0" Path="/Party[@partyType=&quot;PSI&quot; and @partyRole=&quot;sender&quot;]/partyId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="partyName" Show="false" DataType="0" Path="/Party[@partyType=&quot;PSI&quot; and @partyRole=&quot;sender&quot;]/partyName" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="interchangeAgreementId" Show="false" DataType="0" Path="/Party[@partyType=&quot;PSI&quot; and @partyRole=&quot;sender&quot;]/interchangeAgreementId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="Address" Show="false" DataType="0" Path="/Party[@partyType=&quot;PSI&quot; and @partyRole=&quot;sender&quot;]/Address" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="streetName" Show="false" DataType="0" Path="/Party[@partyType=&quot;PSI&quot; and @partyRole=&quot;sender&quot;]/Address/streetName" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="7" Name="postalCode" Show="false" DataType="0" Path="/Party[@partyType=&quot;PSI&quot; and @partyRole=&quot;sender&quot;]/Address/postalCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="cityName" Show="false" DataType="0" Path="/Party[@partyType=&quot;PSI&quot; and @partyRole=&quot;sender&quot;]/Address/cityName" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="countryName" Show="false" DataType="0" Path="/Party[@partyType=&quot;PSI&quot; and @partyRole=&quot;sender&quot;]/Address/countryName" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="10" Name="phoneNumber" Show="false" DataType="0" Path="/Party[@partyType=&quot;PSI&quot; and @partyRole=&quot;sender&quot;]/Address/phoneNumber" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="11" Name="faxNumber" Show="false" DataType="0" Path="/Party[@partyType=&quot;PSI&quot; and @partyRole=&quot;sender&quot;]/Address/faxNumber" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="12" Name="e-mail" Show="false" DataType="0" Path="/Party[@partyType=&quot;PSI&quot; and @partyRole=&quot;sender&quot;]/Address/e-mail" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchMapping TableId="79" Name="" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="3" FieldID="2" Optional="true" /><DataExchFieldMapping ColumnNo="4" FieldID="11005" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="4" Optional="true" /><DataExchFieldMapping ColumnNo="7" FieldID="30" Optional="true" /><DataExchFieldMapping ColumnNo="8" FieldID="6" Optional="true" /><DataExchFieldMapping ColumnNo="9" FieldID="36" Optional="true" TransformationRule="LOOKUPCOUNTRYNAME"><TransformationRules><Code>LOOKUPCOUNTRYNAME</Code><Description>Lookup Country Name</Description><TransformationType>13</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>9</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>2</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLP2Txt: Label '<DataExchFieldMapping ColumnNo="10" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="11" FieldID="10" Optional="true" /><DataExchFieldMapping ColumnNo="12" FieldID="34" Optional="true" /></DataExchMapping></DataExchLineDef><DataExchLineDef LineType="1" Code="3-RECEIVER" ColumnCount="11" DataLineTag="/INSTAT/Envelope" ParentCode="1-HEADER"><DataExchColumnDef ColumnNo="1" Name="Party" Show="false" DataType="0" Path="/Party[@partyType=&quot;CC&quot; and @partyRole=&quot;receiver&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="partyId" Show="false" DataType="0" Path="/Party[@partyType=&quot;CC&quot; and @partyRole=&quot;receiver&quot;]/partyId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="partyName" Show="false" DataType="0" Path="/Party[@partyType=&quot;CC&quot; and @partyRole=&quot;receiver&quot;]/partyName" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="Address" Show="false" DataType="0" Path="/Party[@partyType=&quot;CC&quot; and @partyRole=&quot;receiver&quot;]/Address" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="streetName" Show="false" DataType="0" Path="/Party[@partyType=&quot;CC&quot; and @partyRole=&quot;receiver&quot;]/Address/streetName" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="postalCode" Show="false" DataType="0" Path="/Party[@partyType=&quot;CC&quot; and @partyRole=&quot;receiver&quot;]/Address/postalCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="7" Name="cityName" Show="false" DataType="0" Path="/Party[@partyType=&quot;CC&quot; and @partyRole=&quot;receiver&quot;]/Address/cityName" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="countryName" Show="false" DataType="0" Path="/Party[@partyType=&quot;CC&quot; and @partyRole=&quot;receiver&quot;]/Address/countryName" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="phoneNumber" Show="false" DataType="0" Path="/Party[@partyType=&quot;CC&quot; and @partyRole=&quot;receiver&quot;]/Address/phoneNumber" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="10" Name="faxNumber" Show="false" DataType="0" Path="/Party[@partyType=&quot;CC&quot; and @partyRole=&quot;receiver&quot;]/Address/faxNumber" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="11" Name="e-mail" Show="false" DataType="0" Path="/Party[@partyType=&quot;CC&quot; and @partyRole=&quot;receiver&quot;]/Address/e-mail" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchMapping TableId="79" Name="" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="2" UseDefaultValue="true" DefaultValue="00" /></DataExchMapping></DataExchLineDef><DataExchLineDef LineType="1" Code="4-ADDITIONAL" ColumnCount="1" DataLineTag="/INSTAT/Envelope" ParentCode="1-HEADER"><DataExchColumnDef ColumnNo="1" Name="softwareUsed" Show="false" DataType="0" Path="/softwareUsed" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchMapping TableId="79" Name="" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="1" UseDefaultValue="true" DefaultValue="Dynamics 365 Business Central" /></DataExchMapping></DataExchLineDef><DataExchLineDef LineType="1" Code="5-RCPTHEADER" ColumnCount="15" DataLineTag="/INSTAT/Envelope" ParentCode="1-HEADER"><DataExchColumnDef ColumnNo="1" Name="Declaration" Show="false" DataType="0" Path="/Declaration" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="declarationId" Show="false" DataType="0" Path="/Declaration/declarationId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="DateTime" Show="false" DataType="0" Path="/Declaration/DateTime" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="date" Show="false" DataType="0" Path="/Declaration/DateTime/date" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="time" Show="false" DataType="0" Path="/Declaration/DateTime/time" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="referencePeriod" Show="false" DataType="0" Path="/Declaration/referencePeriod" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="7" Name="PSIId" Show="false" DataType="0" Path="/Declaration/PSIId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="Function" Show="false" DataType="0" Path="/Declaration/Function" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="functionCode" Show="false" DataType="0" Path="/Declaration/Function/functionCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="10" Name="declarationTypeCode" Show="false" DataType="0" Path="/Declaration/declarationTypeCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" />',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLP3Txt: Label '<DataExchColumnDef ColumnNo="11" Name="flowCode" Show="false" DataType="0" Path="/Declaration/flowCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="12" Name="currencyCode" Show="false" DataType="0" Path="/Declaration/currencyCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="13" Name="totalNetMass" Show="false" DataType="0" Path="/Declaration/totalNetMass" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="14" Name="totalInvoicedAmount" Show="false" DataType="0" Path="/Declaration/totalInvoicedAmount" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="15" Name="totalStatisticalValue" Show="false" DataType="0" Path="/Declaration/totalStatisticalValue" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchMapping TableId="79" Name="" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="9" UseDefaultValue="true" DefaultValue="O" /><DataExchFieldMapping ColumnNo="11" UseDefaultValue="true" DefaultValue="A" /></DataExchMapping></DataExchLineDef><DataExchLineDef LineType="1" Code="6-SHPTHEADER" ColumnCount="15" DataLineTag="/INSTAT/Envelope" ParentCode="1-HEADER"><DataExchColumnDef ColumnNo="1" Name="Declaration" Show="false" DataType="0" Path="/Declaration" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="declarationId" Show="false" DataType="0" Path="/Declaration/declarationId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="DateTime" Show="false" DataType="0" Path="/Declaration/DateTime" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="date" Show="false" DataType="0" Path="/Declaration/DateTime/date" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="time" Show="false" DataType="0" Path="/Declaration/DateTime/time" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="referencePeriod" Show="false" DataType="0" Path="/Declaration/referencePeriod" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="7" Name="PSIId" Show="false" DataType="0" Path="/Declaration/PSIId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="Function" Show="false" DataType="0" Path="/Declaration/Function" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="functionCode" Show="false" DataType="0" Path="/Declaration/Function/functionCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="10" Name="declarationTypeCode" Show="false" DataType="0" Path="/Declaration/declarationTypeCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="11" Name="flowCode" Show="false" DataType="0" Path="/Declaration/flowCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="12" Name="currencyCode" Show="false" DataType="0" Path="/Declaration/currencyCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="13" Name="totalNetMass" Show="false" DataType="0" Path="/Declaration/totalNetMass" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="14" Name="totalInvoicedAmount" Show="false" DataType="0" Path="/Declaration/totalInvoicedAmount" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="15" Name="totalStatisticalValue" Show="false" DataType="0" Path="/Declaration/totalStatisticalValue" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchMapping TableId="79" Name="" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="9" UseDefaultValue="true" DefaultValue="O" /><DataExchFieldMapping ColumnNo="11" UseDefaultValue="true" DefaultValue="D" /></DataExchMapping></DataExchLineDef><DataExchLineDef LineType="0" Code="7-RCPTDETAIL" ColumnCount="18" DataLineTag="/INSTAT/Envelope/Declaration[flowCode =&quot;A&quot;]" ParentCode="5-RCPTHEADER"><DataExchColumnDef ColumnNo="1" Name="Item" Show="false" DataType="0" Path="/Item" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="itemNumber" Show="false" DataType="0" Path="/Item/itemNumber" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="CN8" Show="false" DataType="0" Path="/Item/CN8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="CN8Code" Show="false" DataType="0" Path="/Item/CN8/CN8Code" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="goodsDescription" Show="false" DataType="0" Path="/Item/goodsDescription" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="MSConsDestCode" Show="false" DataType="0" Path="/Item/MSConsDestCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" />',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLP4Txt: Label '<DataExchColumnDef ColumnNo="7" Name="countryOfOriginCode" Show="false" DataType="0" Path="/Item/countryOfOriginCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="netMass" Show="false" DataType="0" Path="/Item/netMass" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="quantityInSU" Show="false" DataType="0" Path="/Item/quantityInSU" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="10" Name="invoicedAmount" Show="false" DataType="0" Path="/Item/invoicedAmount" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="11" Name="statisticalValue" Show="false" DataType="0" Path="/Item/statisticalValue" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="12" Name="invoiceNumber" Show="false" DataType="0" Path="/Item/invoiceNumber" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="13" Name="partnerId" Show="false" DataType="0" Path="/Item/partnerId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="14" Name="NatureOfTransaction" Show="false" DataType="0" Path="/Item/NatureOfTransaction" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="15" Name="natureOfTransactionACode" Show="false" DataType="0" Path="/Item/NatureOfTransaction/natureOfTransactionACode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="16" Name="natureOfTransactionBCode" Show="false" DataType="0" Path="/Item/NatureOfTransaction/natureOfTransactionBCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="17" Name="modeOfTransportCode" Show="false" DataType="0" Path="/Item/modeOfTransportCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="18" Name="regionCode" Show="false" DataType="0" Path="/Item/regionCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="7" MappingCodeunit="1269" PreMappingCodeunit="11031" PostMappingCodeunit="11033"><DataExchFieldMapping ColumnNo="2" FieldID="23" Optional="true" /><DataExchFieldMapping ColumnNo="4" FieldID="5" Optional="true" TransformationRule="ALPHANUM_ONLY" /><DataExchFieldMapping ColumnNo="5" FieldID="6" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="7" FieldID="24" Optional="true" /><DataExchFieldMapping ColumnNo="8" FieldID="21" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="35" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="10" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLP5Txt: Label '<TransformationType>14</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="11" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="12" FieldID="18" Optional="true" /><DataExchFieldMapping ColumnNo="13" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="15" FieldID="8" Optional="true" TransformationRule="TRANSACTIONACODE"><TransformationRules><Code>TRANSACTIONACODE</Code><Description>Transaction A Code</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="16" FieldID="8" Optional="true" TransformationRule="TRANSACTIONBCODE"><TransformationRules><Code>TRANSACTIONBCODE</Code><Description>Transaction B Code</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>2</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="17" FieldID="9" Optional="true" /><DataExchFieldMapping ColumnNo="18" FieldID="26" Optional="true" /><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="26" /><DataExchFieldGrouping FieldID="27" /></DataExchMapping></DataExchLineDef><DataExchLineDef LineType="0" Code="8-SHPTDETAIL" ColumnCount="18" DataLineTag="/INSTAT/Envelope/Declaration[flowCode =&quot;D&quot;]" ParentCode="6-SHPTHEADER"><DataExchColumnDef ColumnNo="1" Name="Item" Show="false" DataType="0" Path="/Item" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="itemNumber" Show="false" DataType="0" Path="/Item/itemNumber" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="CN8" Show="false" DataType="0" Path="/Item/CN8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="CN8Code" Show="false" DataType="0" Path="/Item/CN8/CN8Code" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="goodsDescription" Show="false" DataType="0" Path="/Item/goodsDescription" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="MSConsDestCode" Show="false" DataType="0" Path="/Item/MSConsDestCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="7" Name="countryOfOriginCode" Show="false" DataType="0" Path="/Item/countryOfOriginCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="netMass" Show="false" DataType="0" Path="/Item/netMass" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="quantityInSU" Show="false" DataType="0" Path="/Item/quantityInSU" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="10" Name="invoicedAmount" Show="false" DataType="0" Path="/Item/invoicedAmount" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="11" Name="statisticalValue" Show="false" DataType="0" Path="/Item/statisticalValue" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="12" Name="invoiceNumber" Show="false" DataType="0" Path="/Item/invoiceNumber" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" />',
                            Locked = true; // will be replaced with file import when available                            
        DataExchangeXMLP6Txt: Label '<DataExchColumnDef ColumnNo="13" Name="partnerId" Show="false" DataType="0" Path="/Item/partnerId" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="14" Name="NatureOfTransaction" Show="false" DataType="0" Path="/Item/NatureOfTransaction" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="15" Name="natureOfTransactionACode" Show="false" DataType="0" Path="/Item/NatureOfTransaction/natureOfTransactionACode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="16" Name="natureOfTransactionBCode" Show="false" DataType="0" Path="/Item/NatureOfTransaction/natureOfTransactionBCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="17" Name="modeOfTransportCode" Show="false" DataType="0" Path="/Item/modeOfTransportCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="18" Name="regionCode" Show="false" DataType="0" Path="/Item/regionCode" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="7" MappingCodeunit="1269" PreMappingCodeunit="11032" PostMappingCodeunit="11033"><DataExchFieldMapping ColumnNo="2" FieldID="23" Optional="true" /><DataExchFieldMapping ColumnNo="4" FieldID="5" Optional="true" TransformationRule="ALPHANUM_ONLY" /><DataExchFieldMapping ColumnNo="5" FieldID="6" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="7" FieldID="24" Optional="true" /><DataExchFieldMapping ColumnNo="8" FieldID="21" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="35" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="10" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="11" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue /><ReplaceValue />',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLP7Txt: Label '<StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="12" FieldID="18" Optional="true" /><DataExchFieldMapping ColumnNo="13" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="15" FieldID="8" Optional="true" TransformationRule="TRANSACTIONACODE"><TransformationRules><Code>TRANSACTIONACODE</Code><Description>Transaction A Code</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="16" FieldID="8" Optional="true" TransformationRule="TRANSACTIONBCODE"><TransformationRules><Code>TRANSACTIONBCODE</Code><Description>Transaction B Code</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>2</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="17" FieldID="9" Optional="true" /><DataExchFieldMapping ColumnNo="18" FieldID="26" Optional="true" /><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="26" /><DataExchFieldGrouping FieldID="27" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available     
}
