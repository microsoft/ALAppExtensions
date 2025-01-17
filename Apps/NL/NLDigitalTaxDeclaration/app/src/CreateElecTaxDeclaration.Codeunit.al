// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Utilities;
using System.Environment;
using System.Utilities;

codeunit 11421 "Create Elec. Tax Declaration"
{
    TableNo = "VAT Report Header";

    var
        XMLDoc: XmlDocument;

    trigger OnRun()
    var
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ElecTaxDeclarationSetup: Record "Elec. Tax Declaration Setup";
        ElecTaxDeclMgt: Codeunit "Elec. Tax Declaration Mgt.";
        RootElement: XmlElement;
        SchemaRef: XmlElement;
        ContextElement: XmlElement;
        EntityElement: XmlElement;
        Identifier: XmlElement;
        PeriodElement: XmlElement;
        UnitElement: XmlElement;
    begin
        CompanyInformation.Get();
        GeneralLedgerSetup.Get();
        ElecTaxDeclarationSetup.Get();

        XMLDoc := XmlDocument.Create();
        XMLDoc.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'yes'));
        RootElement := XmlElement.Create('xbrl', 'http://www.xbrl.org/2003/instance');
        RootElement.Add(XmlAttribute.Create('lang', 'http://www.w3.org/XML/1998/namespace', 'nl'));
        RootElement.Add(XmlAttribute.CreateNamespaceDeclaration('link', 'http://www.xbrl.org/2003/linkbase').AsXmlNode());
        RootElement.Add(XmlAttribute.CreateNamespaceDeclaration('bd-i', ElecTaxDeclMgt.GetBDDataEndpoint()).AsXmlNode());
        RootElement.Add(XmlAttribute.CreateNamespaceDeclaration('iso4217', 'http://www.xbrl.org/2003/iso4217'));
        RootElement.Add(XmlAttribute.CreateNamespaceDeclaration('xbrli', 'http://www.xbrl.org/2003/instance').AsXmlNode());
        RootElement.Add(XmlAttribute.CreateNamespaceDeclaration('xlink', 'http://www.w3.org/1999/xlink').AsXmlNode());
        SchemaRef := XmlElement.Create('schemaRef', 'http://www.xbrl.org/2003/linkbase');
        SchemaRef.Add(XmlAttribute.Create('type', 'http://www.w3.org/1999/xlink', 'simple').AsXmlNode());
        SchemaRef.Add(XmlAttribute.Create('href', 'http://www.w3.org/1999/xlink', ElecTaxDeclMgt.GetVATDeclarationSchemaEndpoint()).AsXmlNode());
        RootElement.Add(SchemaRef);

        ContextElement := XmlElement.Create('context', 'http://www.xbrl.org/2003/instance');
        ContextElement.Add(XmlAttribute.Create('id', 'Msg'));
        EntityElement := XmlElement.Create('entity', 'http://www.xbrl.org/2003/instance');
        Identifier := XmlElement.Create('identifier', 'http://www.xbrl.org/2003/instance', CompanyInformation.GetVATIdentificationNo(ElecTaxDeclarationSetup."Part of Fiscal Entity"));
        Identifier.Add(XmlAttribute.Create('scheme', 'www.belastingdienst.nl/omzetbelastingnummer').AsXmlNode());
        EntityElement.Add(Identifier);
        PeriodElement := XmlElement.Create('period', 'http://www.xbrl.org/2003/instance');
        PeriodElement.Add(XmlElement.Create('startDate', 'http://www.xbrl.org/2003/instance', Format("Start Date", 0, '<Year4>-<Month,2>-<Day,2>')).AsXmlNode());
        PeriodElement.Add(XmlElement.Create('endDate', 'http://www.xbrl.org/2003/instance', Format("End Date", 0, '<Year4>-<Month,2>-<Day,2>')).AsXmlNode());
        ContextElement.Add(EntityElement);
        ContextElement.Add(PeriodElement);
        RootElement.Add(ContextElement);
        UnitElement := XmlElement.Create('unit', 'http://www.xbrl.org/2003/instance');
        UnitElement.Add(XmlAttribute.Create('id', 'EUR'));
        UnitElement.Add(XmlElement.Create('measure', 'http://www.xbrl.org/2003/instance', 'iso4217:EUR'));
        RootElement.Add(UnitElement);
        AddContactInformation(RootElement, ElecTaxDeclarationSetup);
        AddContextElement(RootElement, 'DateTimeCreation', FormatDateTime("Created Date-Time"));
        AddAmounts(RootElement, Rec);

        XMLDoc.Add(RootElement);
        ArchiveXMLMessage(Rec);
    end;

    local procedure AddContactInformation(var RootElement: XmlElement; ElecTaxDeclarationSetup: Record "Elec. Tax Declaration Setup")
    begin
        case ElecTaxDeclarationSetup."VAT Contact Type" of
            ElecTaxDeclarationSetup."VAT Contact Type"::"Tax Payer":
                begin
                    AddContextElement(RootElement, 'ContactInitials', ExtractInitials(ElecTaxDeclarationSetup."Tax Payer Contact Name"));
                    AddContextElement(RootElement, 'ContactPrefix', ExtractNamePrefix(ElecTaxDeclarationSetup."Tax Payer Contact Name"));
                    AddContextElement(RootElement, 'ContactSurname', ExtractSurname(ElecTaxDeclarationSetup."Tax Payer Contact Name"));
                    AddContextElement(RootElement, 'ContactTelephoneNumber', ElecTaxDeclarationSetup."Tax Payer Contact Phone No.");
                end;
            ElecTaxDeclarationSetup."VAT Contact Type"::Agent:
                begin
                    AddContextElement(RootElement, 'ContactInitials', ExtractInitials(ElecTaxDeclarationSetup."Agent Contact Name"));
                    AddContextElement(RootElement, 'ContactPrefix', ExtractNamePrefix(ElecTaxDeclarationSetup."Agent Contact Name"));
                    AddContextElement(RootElement, 'ContactSurname', ExtractSurname(ElecTaxDeclarationSetup."Agent Contact Name"));
                    AddContextElement(RootElement, 'ContactTelephoneNumber', ElecTaxDeclarationSetup."Agent Contact Phone No.");
                    AddContextElement(RootElement, 'TaxConsultantNumber', ElecTaxDeclarationSetup."Agent Contact ID");
                end;
        end;
        case ElecTaxDeclarationSetup."VAT Contact Type" of
            ElecTaxDeclarationSetup."VAT Contact Type"::"Tax Payer":
                AddContextElement(RootElement, 'ContactType', 'BPL');
            ElecTaxDeclarationSetup."VAT Contact Type"::Agent:
                AddContextElement(RootElement, 'ContactType', 'INT');
        end;
    end;

    local procedure AddAmounts(var RootElement: XmlElement; VATReportHeader: Record "VAT Report Header")
    var
        TempNameValueBufferAmtCode: Record "Name/Value Buffer" temporary;
        VATStatementReportLine: Record "VAT Statement Report Line";
        DigitalTaxDeclMgt: Codeunit "Digital Tax. Decl. Mgt.";
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        VATStatementReportLine.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        VATStatementReportLine.SetRange("VAT Report No.", VATReportHeader."No.");

        DigitalTaxDeclMgt.AddInstallationDistanceSalesWithinTheEC(TempNameValueBufferAmtCode);
        AddAmount(RootElement, VATStatementReportLine, TempNameValueBufferAmtCode.Name, TempNameValueBufferAmtCode.Value);
        AddContextElement(RootElement, 'MessageReferenceSupplierVAT', VATReportHeader."Additional Information");
        AddContextElement(RootElement, 'SoftwarePackageName', 'Microsoft Dynamics NAV');
        AddContextElement(
          RootElement, 'SoftwarePackageVersion', GetStrippedAppVersion(CopyStr(ApplicationSystemConstants.ApplicationVersion(), 3, 250)));
        AddContextElement(RootElement, 'SoftwareVendorAccountNumber', 'SWO00638');
        CollectAmountCodes(TempNameValueBufferAmtCode);
        if not TempNameValueBufferAmtCode.FindSet() then
            exit;

        repeat
            AddAmount(RootElement, VATStatementReportLine, TempNameValueBufferAmtCode.Name, TempNameValueBufferAmtCode.Value);
        until TempNameValueBufferAmtCode.Next() = 0;
    end;

    local procedure AddAmount(var RootElement: XmlElement; var VATStatementReportLine: Record "VAT Statement Report Line"; BoxNo: Text; AmountNodeName: Text)
    begin
        VATStatementReportLine.SetRange("Box No.", BoxNo);
        if not VATStatementReportLine.FindFirst() then
            VATStatementReportLine.Amount := 0;

        AddAmountElement(RootElement, AmountNodeName, Format(VATStatementReportLine.Amount, 0, '<Sign><Integer>'));
    end;

    local procedure AddContextElement(var RootElement: XmlElement; ElementName: Text; ElementValue: Text)
    var
        ElecTaxDeclMgt: Codeunit "Elec. Tax Declaration Mgt.";
    begin
        RootElement.Add(XmlElement.Create(ElementName, ElecTaxDeclMgt.GetBDDataEndpoint(), XmlAttribute.Create('contextRef', 'Msg'), ElementValue));
    end;

    local procedure AddAmountElement(var RootElement: XmlElement; ElementName: Text; ElementValue: Text)
    var
        ElecTaxDeclMgt: Codeunit "Elec. Tax Declaration Mgt.";
    begin
        RootElement.Add(
            XmlElement.Create(
            ElementName, ElecTaxDeclMgt.GetBDDataEndpoint(),
            XmlAttribute.Create('decimals', 'INF'),
            XmlAttribute.Create('contextRef', 'Msg'),
            XmlAttribute.Create('unitRef', 'EUR'),
            ElementValue));
    end;

    local procedure GetStrippedAppVersion(AppVersion: Text[250]) Res: Text[250]
    begin
        Res := DelChr(AppVersion, '=', DelChr(AppVersion, '=', '0123456789'));
        exit(CopyStr(Res, 1, 2));
    end;

    local procedure ExtractInitials(FullName: Text) Initials: Text
    begin
        Initials := '';
        Initials += CopyStr(FullName, 1, 1);
        while StrPos(FullName, ' ') <> 0 do begin
            FullName := CopyStr(FullName, StrPos(FullName, ' ') + 1);
            Initials += CopyStr(FullName, 1, 1);
        end;
    end;

    local procedure ExtractNamePrefix(FullName: Text) Prefix: Text
    begin
        if StrPos(FullName, ' ') > 1 then
            Prefix := CopyStr(FullName, 1, StrPos(FullName, ' ') - 1);
    end;

    local procedure ExtractSurname(FullName: Text[35]) Surname: Text[35]
    begin
        Surname := copystr(CopyStr(FullName, StrPos(FullName, ' ') + 1), 1, MaxStrLen(Surname));
    end;

    local procedure FormatDateTime(DateTime: DateTime): Text[20]
    begin
        exit(Format(DateTime, 0, '<Year4><Month,2><Day,2><Hour,2><Filler Character,0><Minute,2>'));
    end;


    local procedure CollectAmountCodes(var TempNameValueBufferAmtCode: Record "Name/Value Buffer" temporary)
    var
        DigitalTaxDeclMgt: Codeunit "Digital Tax. Decl. Mgt.";
    begin
        TempNameValueBufferAmtCode.Reset();
        TempNameValueBufferAmtCode.DeleteAll();
        DigitalTaxDeclMgt.AddSuppliesServicesNotTaxed(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddSuppliesToCountriesOutsideTheEC(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddSuppliesToCountriesWithinTheEC(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddTaxedTurnoverPrivateUse(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddTaxedTurnoverSuppliesServicesGeneralTariff(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddTaxedTurnoverSuppliesServicesOtherRates(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddTaxedTurnoverSuppliesServicesReducedTariff(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddTurnoverFromTaxedSuppliesFromCountriesOutsideTheEC(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddTurnoverFromTaxedSuppliesFromCountriesWithinTheEC(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddTurnoverSuppliesServicesByWhichVATTaxationIsTransferred(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddValueAddedTaxOnInput(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddValueAddedTaxOnSuppliesFromCountriesOutsideTheEC(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddValueAddedTaxOnSuppliesFromCountriesWithinTheEC(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddValueAddedTaxOwed(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddValueAddedTaxOwedToBePaidBack(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddValueAddedTaxPrivateUse(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddValueAddedTaxSuppliesServicesByWhichVATTaxationIsTransferred(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddValueAddedTaxSuppliesServicesGeneralTariff(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddValueAddedTaxSuppliesServicesOtherRates(TempNameValueBufferAmtCode);
        DigitalTaxDeclMgt.AddValueAddedTaxSuppliesServicesReducedTariff(TempNameValueBufferAmtCode);
        OnAfterCollectAmountNodes(TempNameValueBufferAmtCode);
    end;

    local procedure ArchiveXMLMessage(VATReportHeader: Record "VAT Report Header")
    var
        VATReportArchive: Record "VAT Report Archive";
        TempBlob: Codeunit "Temp Blob";
        BlobOutStream: OutStream;
        XMLDocText: Text;
    begin
        TempBlob.CreateOutStream(BlobOutStream, TextEncoding::UTF8);
        XMLDoc.WriteTo(XMLDocText);
        BlobOutStream.WriteText(XMLDocText);
        VATReportArchive.ArchiveSubmissionMessage(VATReportHeader."VAT Report Config. Code", VATReportHeader."No.", TempBlob);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCollectAmountNodes(var TempNameValueBufferAmtCode: Record "Name/Value Buffer" temporary)
    begin
    end;
}

