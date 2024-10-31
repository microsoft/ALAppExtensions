// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Registration;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Ledger;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using System.IO;
using System.Utilities;

codeunit 11346 IntrastatReportManagementBE
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
        IntrastatReportChecklist.Validate("Field No.", 24);
        IntrastatReportChecklist.Validate("Filter Expression", 'Type: Shipment');
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 26);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 29);
        IntrastatReportChecklist.Validate("Filter Expression", 'Type: Shipment');
        IntrastatReportChecklist.Insert(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Report Line", 'OnBeforeGetCustomerPartnerIDFromItemEntry', '', true, true)]
    local procedure OnBeforeGetCustomerPartnerIDFromItemEntry(var Customer: Record Customer; EU3rdPartyTrade: Boolean; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
        IsHandled := true;
        IntrastatReportSetup.Get();
        PartnerID := GetPartnerIDForCountry(
            Customer."Country/Region Code",
            IntrastatReportMgt.GetVATRegNo(
                Customer."Country/Region Code", Customer."VAT Registration No.", IntrastatReportSetup."Cust. VAT No. on File"),
            Customer."Enterprise No.", IntrastatReportMgt.IsCustomerPrivatePerson(Customer), EU3rdPartyTrade);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Report Line", 'OnBeforeGetVendorPartnerIDFromItemEntry', '', true, true)]
    local procedure OnBeforeGetVendorPartnerIDFromItemEntry(var Vendor: Record Vendor; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
        IsHandled := true;
        IntrastatReportSetup.Get();
        PartnerID := GetPartnerIDForCountry(
            Vendor."Country/Region Code",
            IntrastatReportMgt.GetVATRegNo(
                Vendor."Country/Region Code", Vendor."VAT Registration No.", IntrastatReportSetup."Vend. VAT No. on File"),
            Vendor."Enterprise No.", IntrastatReportMgt.IsVendorPrivatePerson(Vendor), false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Report Line", 'OnBeforeGetCustomerPartnerIDFromJobEntry', '', true, true)]
    local procedure OnBeforeGetCustomerPartnerIDFromJobEntry(var Customer: Record Customer; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
        IsHandled := true;
        IntrastatReportSetup.Get();
        PartnerID := GetPartnerIDForCountry(
            Customer."Country/Region Code",
            IntrastatReportMgt.GetVATRegNo(
                Customer."Country/Region Code", Customer."VAT Registration No.", IntrastatReportSetup."Cust. VAT No. on File"),
            Customer."Enterprise No.", IntrastatReportMgt.IsCustomerPrivatePerson(Customer), false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Report Line", 'OnBeforeGetVendorPartnerIDFromFAEntry', '', true, true)]
    local procedure OnBeforeGetVendorPartnerIDFromFAEntry(var Vendor: Record Vendor; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
        IsHandled := true;
        IntrastatReportSetup.Get();
        PartnerID := GetPartnerIDForCountry(
            Vendor."Country/Region Code",
            IntrastatReportMgt.GetVATRegNo(
                Vendor."Country/Region Code", Vendor."VAT Registration No.", IntrastatReportSetup."Vend. VAT No. on File"),
            Vendor."Enterprise No.", IntrastatReportMgt.IsVendorPrivatePerson(Vendor), false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Report Line", 'OnAfterGetCountryOfOriginCode', '', true, true)]
    local procedure OnAfterGetCountryOfOriginCode(var IntrastatReportLine: Record "Intrastat Report Line"; var CountryOfOriginCode: Code[10])
    begin
        if CountryOfOriginCode = '' then
            CountryOfOriginCode := 'QU';
    end;

    [EventSubscriber(ObjectType::Report, report::"Intrastat Report Get Lines", 'OnCalculateTotalsOnBeforeSumTotals', '', true, true)]
    local procedure OnCalculateTotalsOnBeforeSumTotals(var ItemLedgerEntry: Record "Item Ledger Entry"; IntrastatReportHeader: Record "Intrastat Report Header"; var TotalAmt: Decimal; var TotalCostAmt: Decimal)
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        VATEntry: Record "VAT Entry";
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        if ValueEntry.FindFirst() and (ValueEntry.Count() = 1) then
            case ValueEntry."Document Type" of
                ValueEntry."Document Type"::"Purchase Invoice":
                    if PurchInvHeader.Get(ValueEntry."Document No.") then
                        if PurchInvHeader."VAT Base Discount %" <> 0 then begin
                            PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
                            PurchInvLine.SetRange(Type, PurchInvLine.Type::Item);
                            PurchInvLine.SetRange("No.", ItemLedgerEntry."Item No.");
                            if PurchInvLine.Count() = 1 then begin
                                VATEntry.SetRange(Type, VATEntry.Type::Purchase);
                                VATEntry.SetRange("Document Type", VATEntry."Document Type"::Invoice);
                                VATEntry.SetRange("Document No.", ValueEntry."Document No.");
                                VATEntry.SetRange("Posting Date", ValueEntry."Posting Date");
                                if VATEntry.Count() = 1 then begin
                                    VATEntry.FindFirst();
                                    TotalCostAmt := VATEntry.Base;
                                end;
                            end;
                        end;
                ValueEntry."Document Type"::"Sales Invoice":
                    if SalesInvoiceHeader.Get(ValueEntry."Document No.") then
                        if SalesInvoiceHeader."VAT Base Discount %" <> 0 then begin
                            SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                            SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
                            SalesInvoiceLine.SetRange("No.", ItemLedgerEntry."Item No.");
                            if SalesInvoiceLine.Count() = 1 then begin
                                VATEntry.SetRange(Type, VATEntry.Type::Sale);
                                VATEntry.SetRange("Document Type", VATEntry."Document Type"::Invoice);
                                VATEntry.SetRange("Document No.", ValueEntry."Document No.");
                                VATEntry.SetRange("Posting Date", ValueEntry."Posting Date");
                                if VATEntry.Count() = 1 then begin
                                    VATEntry.FindFirst();
                                    TotalCostAmt := -VATEntry.Base;
                                    TotalAmt := TotalCostAmt;
                                end;
                            end;
                        end;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeDefineFileNames', '', true, true)]
    local procedure OnBeforeDefineFileNames(var IntrastatReportHeader: Record "Intrastat Report Header"; var FileName: Text; var ReceptFileName: Text; var ShipmentFileName: Text; var ZipFileName: Text; var IsHandled: Boolean)
    begin
        IsHandled := false;
        OnBeforeDefineFileNamesBE(IntrastatReportHeader, FileName, ReceptFileName, ShipmentFileName, ZipFileName, IsHandled);
        if not IsHandled then begin
            FileName := StrSubstNo(FileNameLbl, IntrastatReportHeader."Statistics Period");
            ReceptFileName := StrSubstNo(ReceptFileNameLbl, IntrastatReportHeader."Statistics Period");
            ShipmentFileName := StrSubstNo(ShipmentFileNameLbl, IntrastatReportHeader."Statistics Period");
            ZipFileName := StrSubstNo(ZipFileNameLbl, IntrastatReportHeader."Statistics Period");
        end;

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeExportIntrastatHeader', '', true, true)]
    local procedure OnBeforeExportIntrastatHeader(var IntrastatReportHeader: Record "Intrastat Report Header"; var IsHandled: Boolean)
    begin
        SetDataExchExportParameters(IntrastatReportHeader."Statistics Period", IntrastatReportHeader."Nihil Declaration", IntrastatReportHeader."Enterprise No./VAT Reg. No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Generic XML", 'OnBeforeCreateXMLNodeWithoutAttributes', '', true, true)]
    local procedure OnBeforeCreateXMLNodeWithoutAttributes(var xmlNodeName: Text; var xmlNodeValue: Text; var DataExchColumnDef: Record "Data Exch. Column Def"; var DefaultNameSpace: Text; var IsHandled: Boolean)
    var
        CompanyInformation: Record "Company Information";
        VATLogicalTests: Codeunit VATLogicalTests;
    begin
        if IsIntrastatExport(DataExchColumnDef."Data Exch. Def Code") then
            case DataExchColumnDef.Path of
                '/DeclarationReport/Administration/From':
                    if ThirdPartyVatRegNo <> '' then
                        xmlNodeValue := DelChr(ThirdPartyVatRegNo, '=', DelChr(ThirdPartyVatRegNo, '=', '0123456789'))
                    else begin
                        CompanyInformation.Get();
                        if not VATLogicalTests.MOD97Check(CompanyInformation."Enterprise No.") then
                            Error(EnterpriseNoNotValidErr);
                        xmlNodeValue := DelChr(CompanyInformation."Enterprise No.", '=', DelChr(CompanyInformation."Enterprise No.", '=', '0123456789'));
                    end;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Generic XML", 'OnBeforeCreateXMLAttribute', '', true, true)]
    local procedure OnBeforeCreateXMLAttribute(var xmlAttributeName: Text; var xmlAttributeValue: Text; var DataExchColumnDef: Record "Data Exch. Column Def"; var DefaultNameSpace: Text; var IsHandled: Boolean)
    begin
        if IsIntrastatExport(DataExchColumnDef."Data Exch. Def Code") then
            case DataExchColumnDef.Path of
                '/DeclarationReport/Report[@action]':
                    if Nihil then
                        xmlAttributeValue := 'nihil'
                    else
                        xmlAttributeValue := 'replace';
                '/DeclarationReport/Report[@date]':
                    xmlAttributeValue := Format(ConvertPeriodToDate(StatisticPeriod), 0, '<Year4>-<Month,2>');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Generic XML", 'OnBeforeCreateXMLNodeWithAttributes', '', true, true)]
    local procedure OnBeforeCreateXMLNodeWithAttributes(var xmlNodeName: Text; var xmlNodeValue: Text; var DataExchColumnDef: Record "Data Exch. Column Def"; var DefaultNameSpace: Text; var IsHandled: Boolean)
    var
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        if IsIntrastatExport(DataExchColumnDef."Data Exch. Def Code") then
            case DataExchColumnDef.Path of
                '/Item/Dim[@prop="EXTRF"]':
                    begin
                        if xmlNodeValue = Format(IntrastatReportLine.Type::Receipt) then
                            xmlNodeValue := '19';
                        if xmlNodeValue = Format(IntrastatReportLine.Type::Shipment) then
                            xmlNodeValue := '29';
                    end;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Generic XML", 'OnBeforeExportDetails', '', true, true)]
    local procedure OnBeforeExportDetails(var DataExch: Record "Data Exch."; var xmlDoc: XmlDocument; var IsHandled: Boolean)
    begin
        if IsIntrastatExport(DataExch."Data Exch. Def Code") then
            if Nihil then
                IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intrastat Report Setup Wizard", 'OnBeforeFinishAction', '', true, true)]
    local procedure OnBeforeFinishAction()
    var
        TariffNumber: Record "Tariff Number";
        UOM: Record "Unit of Measure";
        Window: Dialog;
    begin
        TariffNumber.Reset();
        TariffNumber.SetRange("Supplementary Units", true);
        Window.Open(SupplUnitUpdateTariffLbl);
        if TariffNumber.FindSet() then
            repeat
                Window.Update(1, TariffNumber."No.");
                if not UOM.Get(TariffNumber."Unit of Measure") then begin
                    UOM.Init();
                    UOM.Validate(Code, TariffNumber."Unit of Measure");
                    UOM.Validate(Description, TariffNumber."Unit of Measure");
                    UOM.Insert(true);
                end;

                TariffNumber."Suppl. Unit of Measure" := TariffNumber."Unit of Measure";
                TariffNumber."Suppl. Conversion Factor" := TariffNumber."Conversion Factor";
                TariffNumber.Modify(true);
            until TariffNumber.Next() = 0;
        Window.Close();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeCreateDefaultDataExchangeDef', '', true, true)]
    local procedure OnBeforeCreateDefaultDataExchangeDef(var IsHandled: Boolean);
    begin
        CreateDefaultDataExchangeDef();
        IsHandled := true;
    end;

    procedure SetDataExchExportParameters(StatisticPeriod2: Code[10]; Nihil2: Boolean; ThirdPartyVatRegNo2: Text[30])
    begin
        StatisticPeriod := StatisticPeriod2;
        Nihil := Nihil2;
        ThirdPartyVatRegNo := ThirdPartyVatRegNo2;
    end;

    procedure GetDataExchExportParameters(var StatisticPeriod2: Code[10]; var Nihil2: Boolean; var ThirdPartyVatRegNo2: Text[30])
    begin
        StatisticPeriod2 := StatisticPeriod;
        Nihil2 := Nihil;
        ThirdPartyVatRegNo2 := ThirdPartyVatRegNo;
    end;

    local procedure GetPartnerIDForCountry(CountryRegionCode: Code[10]; VATRegistrationNo: Text[50]; EnterpriseNo: Text[50]; IsPrivatePerson: Boolean; IsThirdPartyTrade: Boolean): Text[50]
    var
        CountryRegion: Record "Country/Region";
        PartnerID: Text[50];
        IsHandled: Boolean;
    begin
        OnBeforeGetPartnerIDForCountryBE(CountryRegionCode, VATRegistrationNo, IsPrivatePerson, IsThirdPartyTrade, PartnerID, IsHandled);
        if IsHandled then
            exit(PartnerID);

        IntrastatReportSetup.Get();
        if IsPrivatePerson then
            exit(IntrastatReportSetup."Def. Private Person VAT No.");

        if CountryRegion.Get(CountryRegionCode) then
            if CountryRegion.IsEUCountry(CountryRegionCode) then begin
                if VATRegistrationNo <> '' then
                    exit(VATRegistrationNo);
                if EnterpriseNo <> '' then
                    exit(EnterpriseNo);
            end;

        if IsThirdPartyTrade then
            exit(IntrastatReportSetup."Def. 3-Party Trade VAT No.");

        exit(IntrastatReportSetup."Def. VAT for Unknown State");
    end;

    local procedure ConvertPeriodToDate(Period: Code[10]): Date
    var
        Month: Integer;
        Year: Integer;
        Century: Integer;
    begin
        Century := Date2DMY(WorkDate(), 3) div 100;
        Evaluate(Year, CopyStr(Period, 1, 2));
        Year := Year + Century * 100;
        Evaluate(Month, CopyStr(Period, 3, 2));
        exit(DMY2Date(1, Month, Year));
    end;

    local procedure IsIntrastatExport(DataExchDefCode: Code[20]): Boolean
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        if not IntrastatReportSetup.Get() then
            exit(false);

        if IntrastatReportSetup."Split Files" then
            exit(DataExchDefCode in [IntrastatReportSetup."Data Exch. Def. Code - Receipt", IntrastatReportSetup."Data Exch. Def. Code - Shpt."])
        else
            exit(DataExchDefCode = IntrastatReportSetup."Data Exch. Def. Code");
    end;

    procedure CreateDefaultDataExchangeDef()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        DataExchDef: Record "Data Exch. Def";
        TempBlob: Codeunit "Temp Blob";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
    begin
        if DataExchDef.Get('INTRA-2022-BE-RCPT-S') then
            DataExchDef.Delete(true);

        if DataExchDef.Get('INTRA-2022-BE-RCPT-E') then
            DataExchDef.Delete(true);

        if DataExchDef.Get('INTRA-2022-BE-SHPT-S') then
            DataExchDef.Delete(true);

        if DataExchDef.Get('INTRA-2022-BE-SHPT-E') then
            DataExchDef.Delete(true);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLRcptSmpP1Txt + DataExchangeXMLRcptSmpP2Txt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        Clear(TempBlob);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLRcptExtP1Txt + DataExchangeXMLRcptExtP2Txt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        Clear(TempBlob);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLShptSmpP1Txt + DataExchangeXMLShptSmpP2Txt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        Clear(TempBlob);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLShptExtP1Txt + DataExchangeXMLShptExtP2Txt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        Clear(TempBlob);

        IntrastatReportSetup.Get();
        IntrastatReportSetup."Split Files" := true;
        IntrastatReportSetup."Data Exch. Def. Code - Receipt" := 'INTRA-2022-BE-RCPT-S';
        IntrastatReportSetup."Data Exch. Def. Code - Shpt." := 'INTRA-2022-BE-SHPT-S';
        IntrastatReportSetup.Modify();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPartnerIDForCountryBE(CountryRegionCode: Code[10]; VATRegistrationNo: Text[50]; IsPrivatePerson: Boolean; IsThirdPartyTrade: Boolean; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeDefineFileNamesBE(var IntrastatReportHeader: Record "Intrastat Report Header"; var FileName: Text; var ReceptFileName: Text; var ShipmentFileName: Text; var ZipFileName: Text; var IsHandled: Boolean)
    begin
    end;

    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        StatisticPeriod: Code[10];
        Nihil: Boolean;
        ThirdPartyVatRegNo: Text[30];
        DefPrivatePersonVATNoLbl: Label 'QN999999999999', Locked = true;
        Def3DPartyTradeVATNoLbl: Label 'QV999999999999', Locked = true;
        DefUnknowVATNoLbl: Label 'QV999999999999', Locked = true;
        SupplUnitUpdateTariffLbl: Label 'Tariff Number #1##########';
        FileNameLbl: Label 'Intrastat-%1.xml', Comment = '%1 - Statistics Period';
        ReceptFileNameLbl: Label 'Receipt-%1.xml', Comment = '%1 - Statistics Period';
        ShipmentFileNameLbl: Label 'Shipment-%1.xml', Comment = '%1 - Statistics Period';
        ZipFileNameLbl: Label 'Intrastat-%1.zip', Comment = '%1 - Statistics Period';
        EnterpriseNoNotValidErr: Label 'The enterprise number in Company Information is not valid.';
        DataExchangeXMLRcptSmpP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-BE-RCPT-S" Name="Intrastat 2022 BE Receipt - Simple" Type="5" ExternalDataHandlingCodeunit="4813" FileType="0" ReadingWritingCodeunit="1283"><DataExchLineDef LineType="1" Code="HEADER" ColumnCount="13" Namespace="http://www.onegate.eu/2010-01-01"><DataExchColumnDef ColumnNo="1" Name="DeclarationReport" Show="false" DataType="0" Path="/DeclarationReport" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="Administration" Show="false" DataType="0" Path="/DeclarationReport/Administration" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="From" Show="false" DataType="0" Path="/DeclarationReport/Administration/From" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="declarerType" Show="false" DataType="0" Path="/DeclarationReport/Administration/From[@declarerType]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="To" Show="false" DataType="0" Path="/DeclarationReport/Administration/To" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="Domain" Show="false" DataType="0" Path="/DeclarationReport/Administration/Domain" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="7" Name="Report" Show="false" DataType="0" Path="/DeclarationReport/Report" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="action" Show="false" DataType="0" Path="/DeclarationReport/Report[@action]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="date" Show="false" DataType="0" Path="/DeclarationReport/Report[@date]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="10" Name="code" Show="false" DataType="0" Path="/DeclarationReport/Report[@code]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="11" Name="Data" Show="false" DataType="0" Path="/DeclarationReport/Report/Data" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="12" Name="close" Show="false" DataType="0" Path="/DeclarationReport/Report/Data[@close]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="13" Name="form" Show="false" DataType="0" Path="/DeclarationReport/Report/Data[@form]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="7" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="3" Optional="true" UseDefaultValue="true" DefaultValue="456" /><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="KBO" /><DataExchFieldMapping ColumnNo="5" Optional="true" UseDefaultValue="true" DefaultValue="NBB" /><DataExchFieldMapping ColumnNo="6" Optional="true" UseDefaultValue="true" DefaultValue="SXX" /><DataExchFieldMapping ColumnNo="10" Optional="true" UseDefaultValue="true" DefaultValue="EX19S" /><DataExchFieldMapping ColumnNo="12" Optional="true" UseDefaultValue="true" DefaultValue="true" /><DataExchFieldMapping ColumnNo="13" Optional="true" UseDefaultValue="true" DefaultValue="EXF19S" /></DataExchMapping></DataExchLineDef><DataExchLineDef LineType="0" Code="DETAIL" ColumnCount="9" DataLineTag="/DeclarationReport/Report/Data" ParentCode="HEADER"><DataExchColumnDef ColumnNo="1" Name="Item" Show="false" DataType="0" Path="/Item" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="EXTRF" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXTRF&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="EXCNT" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXCNT&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="EXTTA" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXTTA&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="EXREG" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXREG&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="EXTGO" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXTGO&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="7" Name="EXWEIGHT" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXWEIGHT&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="EXUNITS" Show="false" DataType="2" Path="/Item/Dim[@prop=&quot;EXUNITS&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="EXTXVAL" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXTXVAL&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" />',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLRcptSmpP2Txt: Label '<DataExchMapping TableId="4812" Name="" KeyIndex="7" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="2" FieldID="3" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="4" FieldID="8" Optional="true" /><DataExchFieldMapping ColumnNo="5" FieldID="26" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="5" Optional="true" TransformationRule="ALPHANUM_ONLY" /><DataExchFieldMapping ColumnNo="7" FieldID="21" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="8" FieldID="35" Optional="true" /><DataExchFieldMapping ColumnNo="9" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="26" /><DataExchFieldGrouping FieldID="27" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLRcptExtP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-BE-RCPT-E" Name="Intrastat 2022 BE Receipt - Extended" Type="5" ExternalDataHandlingCodeunit="4813" FileType="0" ReadingWritingCodeunit="1283"><DataExchLineDef LineType="1" Code="HEADER" ColumnCount="13" Namespace="http://www.onegate.eu/2010-01-01"><DataExchColumnDef ColumnNo="1" Name="DeclarationReport" Show="false" DataType="0" Path="/DeclarationReport" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="Administration" Show="false" DataType="0" Path="/DeclarationReport/Administration" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="From" Show="false" DataType="0" Path="/DeclarationReport/Administration/From" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="declarerType" Show="false" DataType="0" Path="/DeclarationReport/Administration/From[@declarerType]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="To" Show="false" DataType="0" Path="/DeclarationReport/Administration/To" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="Domain" Show="false" DataType="0" Path="/DeclarationReport/Administration/Domain" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="7" Name="Report" Show="false" DataType="0" Path="/DeclarationReport/Report" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="action" Show="false" DataType="0" Path="/DeclarationReport/Report[@action]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="date" Show="false" DataType="0" Path="/DeclarationReport/Report[@date]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="10" Name="code" Show="false" DataType="0" Path="/DeclarationReport/Report[@code]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="11" Name="Data" Show="false" DataType="0" Path="/DeclarationReport/Report/Data" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="12" Name="close" Show="false" DataType="0" Path="/DeclarationReport/Report/Data[@close]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="13" Name="form" Show="false" DataType="0" Path="/DeclarationReport/Report/Data[@form]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="7" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="3" Optional="true" UseDefaultValue="true" DefaultValue="456" /><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="KBO" /><DataExchFieldMapping ColumnNo="5" Optional="true" UseDefaultValue="true" DefaultValue="NBB" /><DataExchFieldMapping ColumnNo="6" Optional="true" UseDefaultValue="true" DefaultValue="SXX" /><DataExchFieldMapping ColumnNo="10" Optional="true" UseDefaultValue="true" DefaultValue="EX19E" /><DataExchFieldMapping ColumnNo="12" Optional="true" UseDefaultValue="true" DefaultValue="true" /><DataExchFieldMapping ColumnNo="13" Optional="true" UseDefaultValue="true" DefaultValue="EXF19E" /></DataExchMapping></DataExchLineDef><DataExchLineDef LineType="0" Code="DETAIL" ColumnCount="11" DataLineTag="/DeclarationReport/Report/Data" ParentCode="HEADER"><DataExchColumnDef ColumnNo="1" Name="Item" Show="false" DataType="0" Path="/Item" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="EXTRF" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXTRF&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="EXCNT" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXCNT&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="EXTTA" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXTTA&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="EXREG" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXREG&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="EXTGO" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXTGO&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="7" Name="EXWEIGHT" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXWEIGHT&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="EXUNITS" Show="false" DataType="2" Path="/Item/Dim[@prop=&quot;EXUNITS&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="EXTXVAL" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXTXVAL&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="10" Name="EXTPC" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXTPC&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="11" Name="EXDELTRM" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXDELTRM&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" />',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLRcptExtP2Txt: Label '<DataExchMapping TableId="4812" Name="" KeyIndex="7" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="2" FieldID="3" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="4" FieldID="8" Optional="true" /><DataExchFieldMapping ColumnNo="5" FieldID="26" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="5" Optional="true" TransformationRule="ALPHANUM_ONLY" /><DataExchFieldMapping ColumnNo="7" FieldID="21" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="8" FieldID="35" Optional="true" /><DataExchFieldMapping ColumnNo="9" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="10" FieldID="9" Optional="true" /><DataExchFieldMapping ColumnNo="11" FieldID="27" Optional="true" /><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="26" /><DataExchFieldGrouping FieldID="27" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLShptSmpP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-BE-SHPT-S" Name="Intrastat 2022 BE Shipment - Simple" Type="5" ExternalDataHandlingCodeunit="4813" FileType="0" ReadingWritingCodeunit="1283"><DataExchLineDef LineType="1" Code="HEADER" ColumnCount="13" Namespace="http://www.onegate.eu/2010-01-01"><DataExchColumnDef ColumnNo="1" Name="DeclarationReport" Show="false" DataType="0" Path="/DeclarationReport" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="Administration" Show="false" DataType="0" Path="/DeclarationReport/Administration" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="From" Show="false" DataType="0" Path="/DeclarationReport/Administration/From" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="declarerType" Show="false" DataType="0" Path="/DeclarationReport/Administration/From[@declarerType]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="To" Show="false" DataType="0" Path="/DeclarationReport/Administration/To" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="Domain" Show="false" DataType="0" Path="/DeclarationReport/Administration/Domain" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="7" Name="Report" Show="false" DataType="0" Path="/DeclarationReport/Report" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="action" Show="false" DataType="0" Path="/DeclarationReport/Report[@action]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="date" Show="false" DataType="0" Path="/DeclarationReport/Report[@date]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="10" Name="code" Show="false" DataType="0" Path="/DeclarationReport/Report[@code]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="11" Name="Data" Show="false" DataType="0" Path="/DeclarationReport/Report/Data" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="12" Name="close" Show="false" DataType="0" Path="/DeclarationReport/Report/Data[@close]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="13" Name="form" Show="false" DataType="0" Path="/DeclarationReport/Report/Data[@form]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="7" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="3" Optional="true" UseDefaultValue="true" DefaultValue="456" /><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="KBO" /><DataExchFieldMapping ColumnNo="5" Optional="true" UseDefaultValue="true" DefaultValue="NBB" /><DataExchFieldMapping ColumnNo="6" Optional="true" UseDefaultValue="true" DefaultValue="SXX" /><DataExchFieldMapping ColumnNo="10" Optional="true" UseDefaultValue="true" DefaultValue="INTRASTAT_X_S" /><DataExchFieldMapping ColumnNo="12" Optional="true" UseDefaultValue="true" DefaultValue="true" /><DataExchFieldMapping ColumnNo="13" Optional="true" UseDefaultValue="true" DefaultValue="INTRASTAT_X_SF" /></DataExchMapping></DataExchLineDef><DataExchLineDef LineType="0" Code="DETAIL" ColumnCount="13" DataLineTag="/DeclarationReport/Report/Data" ParentCode="HEADER"><DataExchColumnDef ColumnNo="1" Name="Item" Show="false" DataType="0" Path="/Item" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="EXTRF" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXTRF&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="EXCNT" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXCNT&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="EXTTA" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXTTA&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="EXREG" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXREG&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="EXTGO" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXTGO&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="7" Name="EXWEIGHT" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXWEIGHT&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="EXUNITS" Show="false" DataType="2" Path="/Item/Dim[@prop=&quot;EXUNITS&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="EXTXVAL" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXTXVAL&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="10" Name="EXCNTORI" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXCNTORI&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="11" Name="PARTNERID" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;PARTNERID&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" />',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLShptSmpP2Txt: Label '<DataExchMapping TableId="4812" Name="" KeyIndex="7" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="2" FieldID="3" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="4" FieldID="8" Optional="true" /><DataExchFieldMapping ColumnNo="5" FieldID="26" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="5" Optional="true" TransformationRule="ALPHANUM_ONLY" /><DataExchFieldMapping ColumnNo="7" FieldID="21" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="8" FieldID="35" Optional="true" /><DataExchFieldMapping ColumnNo="9" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="10" FieldID="24" Optional="true" /><DataExchFieldMapping ColumnNo="11" FieldID="29" Optional="true" /><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="24" /><DataExchFieldGrouping FieldID="26" /><DataExchFieldGrouping FieldID="27" /><DataExchFieldGrouping FieldID="29" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLShptExtP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-BE-SHPT-E" Name="Intrastat 2022 BE Shipment - Extended" Type="5" ExternalDataHandlingCodeunit="4813" FileType="0" ReadingWritingCodeunit="1283"><DataExchLineDef LineType="1" Code="HEADER" ColumnCount="13" Namespace="http://www.onegate.eu/2010-01-01"><DataExchColumnDef ColumnNo="1" Name="DeclarationReport" Show="false" DataType="0" Path="/DeclarationReport" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="Administration" Show="false" DataType="0" Path="/DeclarationReport/Administration" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="From" Show="false" DataType="0" Path="/DeclarationReport/Administration/From" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="declarerType" Show="false" DataType="0" Path="/DeclarationReport/Administration/From[@declarerType]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="To" Show="false" DataType="0" Path="/DeclarationReport/Administration/To" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="Domain" Show="false" DataType="0" Path="/DeclarationReport/Administration/Domain" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="7" Name="Report" Show="false" DataType="0" Path="/DeclarationReport/Report" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="action" Show="false" DataType="0" Path="/DeclarationReport/Report[@action]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="date" Show="false" DataType="0" Path="/DeclarationReport/Report[@date]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="10" Name="code" Show="false" DataType="0" Path="/DeclarationReport/Report[@code]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="11" Name="Data" Show="false" DataType="0" Path="/DeclarationReport/Report/Data" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="12" Name="close" Show="false" DataType="0" Path="/DeclarationReport/Report/Data[@close]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="13" Name="form" Show="false" DataType="0" Path="/DeclarationReport/Report/Data[@form]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="7" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="3" Optional="true" UseDefaultValue="true" DefaultValue="456" /><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="KBO" /><DataExchFieldMapping ColumnNo="5" Optional="true" UseDefaultValue="true" DefaultValue="NBB" /><DataExchFieldMapping ColumnNo="6" Optional="true" UseDefaultValue="true" DefaultValue="SXX" /><DataExchFieldMapping ColumnNo="10" Optional="true" UseDefaultValue="true" DefaultValue="INTRASTAT_X_E" /><DataExchFieldMapping ColumnNo="12" Optional="true" UseDefaultValue="true" DefaultValue="true" /><DataExchFieldMapping ColumnNo="13" Optional="true" UseDefaultValue="true" DefaultValue="INTRASTAT_X_EF" /></DataExchMapping></DataExchLineDef><DataExchLineDef LineType="0" Code="DETAIL" ColumnCount="13" DataLineTag="/DeclarationReport/Report/Data" ParentCode="HEADER"><DataExchColumnDef ColumnNo="1" Name="Item" Show="false" DataType="0" Path="/Item" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="2" Name="EXTRF" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXTRF&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="3" Name="EXCNT" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXCNT&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="4" Name="EXTTA" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXTTA&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="5" Name="EXREG" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXREG&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="6" Name="EXTGO" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXTGO&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="7" Name="EXWEIGHT" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXWEIGHT&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="8" Name="EXUNITS" Show="false" DataType="2" Path="/Item/Dim[@prop=&quot;EXUNITS&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="9" Name="EXTXVAL" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXTXVAL&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="10" Name="EXCNTORI" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXCNTORI&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="11" Name="PARTNERID" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;PARTNERID&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="12" Name="EXTPC" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXTPC&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" /><DataExchColumnDef ColumnNo="13" Name="EXDELTRM" Show="false" DataType="0" Path="/Item/Dim[@prop=&quot;EXDELTRM&quot;]" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" />',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLShptExtP2Txt: Label '<DataExchMapping TableId="4812" Name="" KeyIndex="7" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="2" FieldID="3" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="4" FieldID="8" Optional="true" /><DataExchFieldMapping ColumnNo="5" FieldID="26" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="5" Optional="true" TransformationRule="ALPHANUM_ONLY" /><DataExchFieldMapping ColumnNo="7" FieldID="21" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="8" FieldID="35" Optional="true" /><DataExchFieldMapping ColumnNo="9" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="10" FieldID="24" Optional="true" /><DataExchFieldMapping ColumnNo="11" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="12" FieldID="9" Optional="true" /><DataExchFieldMapping ColumnNo="13" FieldID="27" Optional="true" /><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="24" /><DataExchFieldGrouping FieldID="26" /><DataExchFieldGrouping FieldID="27" /><DataExchFieldGrouping FieldID="29" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available
}