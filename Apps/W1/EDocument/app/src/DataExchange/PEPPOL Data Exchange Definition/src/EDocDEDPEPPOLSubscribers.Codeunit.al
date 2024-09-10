// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.IO.Peppol;

using Microsoft.EServices.EDocument;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Peppol;
using Microsoft.Service.History;
using Microsoft.Foundation.Attachment;
using System.IO;
using System.Utilities;

codeunit 6162 "E-Doc. DED PEPPOL Subscribers"
{
    Access = Internal;
    SingleInstance = true;
    procedure ClearInstance()
    begin
        ClearAll();
        TempVATAmtLine.DeleteAll();
        TempVATProductPostingGroup.DeleteAll();
    end;

    procedure InitInstance(DataExchEntryNo2: Integer; ProcessedDocType2: Enum "E-Document Type")
    begin
        TaxSubtotalLoopNumber := 1;
        AllowanceChargeLoopNumber := 1;
        DataExchEntryNo := DataExchEntryNo2;
        ProcessedDocType := ProcessedDocType2;
        DocumentAttachmentNumber := 1;
    end;

    procedure IsRoundingLine(SalesLine2: Record "Sales Line"): Boolean;
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        if SalesLine2.Type = SalesLine2.Type::"G/L Account" then begin
            Customer.Get(SalesLine2."Bill-to Customer No.");
            CustomerPostingGroup.SetFilter(Code, Customer."Customer Posting Group");
            if CustomerPostingGroup.FindFirst() then
                if SalesLine2."No." = CustomerPostingGroup."Invoice Rounding Account" then
                    exit(true);
        end;
        exit(false);
    end;

    local procedure IsEDocExport(DataExchDefCode: Code[20]): Boolean
    var
        EDocumentDataExchDef: Record "E-Doc. Service Data Exch. Def.";
    begin
        EDocumentDataExchDef.SetRange("Expt. Data Exchange Def. Code", DataExchDefCode);
        exit(not EDocumentDataExchDef.IsEmpty());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Data Exchange Impl.", 'OnAfterDataExchangeInsert', '', true, true)]
    local procedure OnAfterDataExchangeInsert(var DataExch: Record "Data Exch."; EDocumentFormat: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef)
    begin
        ClearInstance();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Data Exchange Impl.", 'OnBeforeDataExchangeExport', '', true, true)]
    local procedure OnBeforeDataExchangeExport(var DataExch: Record "Data Exch."; EDocumentFormat: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef)
    begin
        InitInstance(DataExch."Entry No.", EDocument."Document Type");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Generic XML", 'OnBeforeCreateRootElement', '', true, true)]
    local procedure OnBeforeCreateRootElement(DataExchDef: Record "Data Exch. Def"; var xmlElem: XmlElement; var nName: Text; var nVal: Text; DefaultNameSpace: Text; var xmlNamespaceManager: XmlNamespaceManager; var IsHandled: Boolean)
    begin
        if IsEDocExport(DataExchDef.Code) then begin
            xmlElem := xmlElement.Create(nName, DefaultNameSpace, nVal);
            xmlElem.Add(XmlAttribute.CreateNamespaceDeclaration('cac', CacNamespaceURILbl));
            xmlElem.Add(XmlAttribute.CreateNamespaceDeclaration('cbc', CbcNamespaceURILbl));
            xmlElem.Add(XmlAttribute.CreateNamespaceDeclaration('ccts', CctsNamespaceURILbl));
            xmlElem.Add(XmlAttribute.CreateNamespaceDeclaration('qdt', QdtNamespaceURILbl));
            xmlElem.Add(XmlAttribute.CreateNamespaceDeclaration('udt', UdtNamespaceURILbl));

            xmlNamespaceManager.AddNamespace('cac', CacNamespaceURILbl);
            xmlNamespaceManager.AddNamespace('cbc', CbcNamespaceURILbl);
            xmlNamespaceManager.AddNamespace('ccts', CctsNamespaceURILbl);
            xmlNamespaceManager.AddNamespace('qdt', QdtNamespaceURILbl);
            xmlNamespaceManager.AddNamespace('udt', UdtNamespaceURILbl);
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Generic XML", 'OnBeforeCreateXMLNodeWithoutAttributes', '', true, true)]
    local procedure OnBeforeCreateXMLNodeWithoutAttributes(var xmlNodeName: Text; var xmlNodeValue: Text; var DataExchColumnDef: Record "Data Exch. Column Def"; var DefaultNameSpace: Text; var IsHandled: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if IsEDocExport(DataExchColumnDef."Data Exch. Def Code") then
            case DataExchColumnDef.Path of
                '/Invoice/cbc:ID', '/CreditNote/cbc:ID':
                    PrepareHeaderAndVAT(xmlNodeValue);
                '/Invoice/cbc:DocumentCurrencyCode', '/CreditNote/cbc:DocumentCurrencyCode':
                    begin
                        if xmlNodeValue = '' then begin
                            GLSetup.Get();
                            GLSetup.TestField("LCY Code");
                            xmlNodeValue := GLSetup."LCY Code";
                        end;
                        DocCurrencyCode := xmlNodeValue;
                    end;
                '/Invoice/cbc:TaxCurrencyCode', '/CreditNote/cbc:TaxCurrencyCode':
                    PEPPOLMgt.GetTaxTotalInfoLCY(SalesHeader, TaxAmountLCY, TaxCurrencyCodeLCY, TaxTotalCurrencyIDLCY);
                '/cac:BillingReference':
                    PEPPOLMgt.GetCrMemoBillingReferenceInfo(
                        SalesCrMemoHeader,
                        InvoiceDocRefID,
                        InvoiceDocRefIssueDate);
                '/cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID':
                    xmlNodeValue := InvoiceDocRefID;
                '/cac:BillingReference/cac:InvoiceDocumentReference/cbc:IssueDate':
                    xmlNodeValue := InvoiceDocRefIssueDate;
                '/cac:AccountingSupplierParty':
                    begin
                        PEPPOLMgt.GetAccountingSupplierPartyInfoBIS(
                            SupplierEndpointID,
                            SupplierSchemeID,
                            SupplierName);

                        PEPPOLMgt.GetAccountingSupplierPartyPostalAddr(
                            SalesHeader,
                            StreetName,
                            AdditionalStreetName,
                            CityName,
                            PostalZone,
                            CountrySubentity,
                            IdentificationCode,
                            DummyVar);

                        PEPPOLMgt.GetAccountingSupplierPartyTaxSchemeBIS(
                            TempVATAmtLine,
                            CompanyID,
                            CompanyIDSchemeID,
                            TaxSchemeID);

                        PEPPOLMgt.GetAccountingSupplierPartyLegalEntityBIS(
                            PartyLegalEntityRegName,
                            PartyLegalEntityCompanyID,
                            PartyLegalEntitySchemeID,
                            SupplierRegAddrCityName,
                            SupplierRegAddrCountryIdCode,
                            SupplRegAddrCountryIdListId);

                        PEPPOLMgt.GetAccountingSupplierPartyContact(
                            SalesHeader,
                            DummyVar,
                            ContactName,
                            Telephone,
                            Telefax,
                            ElectronicMail);
                    end;
                '/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID':
                    xmlNodeValue := SupplierEndpointID;
                '/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName':
                    xmlNodeValue := StreetName;
                '/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName':
                    xmlNodeValue := AdditionalStreetName;
                '/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:CityName':
                    xmlNodeValue := CityName;
                '/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:PostalZone':
                    xmlNodeValue := PostalZone;
                '/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:CountrySubentity':
                    xmlNodeValue := CountrySubentity;
                '/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode':
                    xmlNodeValue := IdentificationCode;
                '/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID':
                    xmlNodeValue := CompanyID;
                '/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:ID':
                    xmlNodeValue := TaxSchemeID;
                '/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID':
                    xmlNodeValue := PartyLegalEntityCompanyID;
                '/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Name':
                    xmlNodeValue := ContactName;
                '/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Telephone':
                    xmlNodeValue := Telephone;
                '/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Telefax':
                    xmlNodeValue := Telefax;
                '/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:ElectronicMail':
                    xmlNodeValue := ElectronicMail;
                '/cac:AccountingCustomerParty':
                    begin
                        PEPPOLMgt.GetAccountingCustomerPartyInfoBIS(
                            SalesHeader,
                            CustomerEndpointID,
                            CustomerSchemeID,
                            CustomerPartyIdentificationID,
                            CustomerPartyIDSchemeID,
                            CustomerName);

                        PEPPOLMgt.GetAccountingCustomerPartyTaxSchemeBIS(
                            SalesHeader,
                            CustPartyTaxSchemeCompanyID,
                            CustPartyTaxSchemeCompIDSchID,
                            CustTaxSchemeID);

                        PEPPOLMgt.GetAccountingCustomerPartyLegalEntityBIS(
                            SalesHeader,
                            CustPartyLegalEntityRegName,
                            CustPartyLegalEntityCompanyID,
                            CustPartyLegalEntityIDSchemeID);

                        PEPPOLMgt.GetAccountingCustomerPartyContact(
                            SalesHeader,
                            DummyVar,
                            CustContactName,
                            CustContactTelephone,
                            CustContactTelefax,
                            CustContactElectronicMail);
                    end;
                '/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID':
                    xmlNodeValue := CustomerEndpointID;
                '/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID':
                    xmlNodeValue := CustomerPartyIdentificationID;
                '/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID':
                    xmlNodeValue := CustPartyTaxSchemeCompanyID;
                '/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:ID':
                    xmlNodeValue := CustTaxSchemeID;
                '/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName':
                    xmlNodeValue := CustPartyLegalEntityRegName;
                '/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID':
                    xmlNodeValue := CustPartyLegalEntityCompanyID;
                '/cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:Name':
                    xmlNodeValue := CustContactName;
                '/cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:Telephone':
                    xmlNodeValue := CustContactTelephone;
                '/cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:Telefax':
                    xmlNodeValue := CustContactTelefax;
                '/cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:ElectronicMail':
                    xmlNodeValue := CustContactElectronicMail;
                '/cac:TaxRepresentativeParty':
                    PEPPOLMgt.GetTaxRepresentativePartyInfo(
                        TaxRepPartyNameName,
                        PayeePartyTaxSchemeCompanyID,
                        PayeePartyTaxSchCompIDSchemeID,
                        PayeePartyTaxSchemeTaxSchemeID);
                '/cac:TaxRepresentativeParty/cac:PartyName/cbc:Name':
                    xmlNodeValue := TaxRepPartyNameName;
                '/cac:TaxRepresentativeParty/cac:PartyTaxScheme/cbc:CompanyID':
                    xmlNodeValue := PayeePartyTaxSchemeCompanyID;
                '/cac:TaxRepresentativeParty/cac:PartyTaxScheme/cac:TaxScheme/cbc:ID':
                    xmlNodeValue := PayeePartyTaxSchemeTaxSchemeID;
                '/cac:Delivery':
                    PEPPOLMgt.GetGLNDeliveryInfo(
                        SalesHeader,
                        ActualDeliveryDate,
                        DeliveryID,
                        DeliveryIDSchemeID);
                '/cac:Delivery/cbc:ActualDeliveryDate':
                    xmlNodeValue := ActualDeliveryDate;
                '/cac:Delivery/cac:DeliveryLocation/cbc:ID':
                    xmlNodeValue := DeliveryID;
                '/cac:PaymentMeans':
                    begin
                        PEPPOLMgt.GetPaymentMeansInfo(
                            SalesHeader,
                            PaymentMeansCode,
                            DummyVar,
                            DummyVar,
                            PaymentChannelCode,
                            PaymentID,
                            PrimaryAccountNumberID,
                            NetworkID);

                        PEPPOLMgt.GetPaymentMeansPayeeFinancialAccBIS(
                            SalesHeader,
                            PayeeFinancialAccountID,
                            FinancialInstitutionBranchID);
                    end;
                '/cac:PaymentMeans/cbc:PaymentMeansCode':
                    xmlNodeValue := PaymentMeansCode;
                '/cac:PaymentMeans/cbc:PaymentChannelCode':
                    xmlNodeValue := PaymentChannelCode;
                '/cac:PaymentMeans/cbc:PaymentID':
                    xmlNodeValue := PaymentID;
                '/cac:PaymentMeans/cac:CardAccount/cbc:PrimaryAccountNumberID':
                    xmlNodeValue := PrimaryAccountNumberID;
                '/cac:PaymentMeans/cac:CardAccount/cbc:NetworkID':
                    xmlNodeValue := NetworkID;
                '/cac:PaymentMeans/cac:PayeeFinancialAccount/cbc:ID':
                    xmlNodeValue := PayeeFinancialAccountID;
                '/cac:PaymentMeans/cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID':
                    xmlNodeValue := FinancialInstitutionBranchID;
                '/cac:PaymentTerms':
                    PEPPOLMgt.GetPaymentTermsInfo(
                        SalesHeader,
                        PaymentTermsNote);
                '/cac:PaymentTerms/cbc:Note':
                    xmlNodeValue := PaymentTermsNote;
                '/cac:AllowanceCharge':
                    begin
                        if AllowanceChargeLoopNumber = 1 then
                            TempVATAmtLine.FindSet()
                        else
                            TempVATAmtLine.Next();
                        AllowanceChargeLoopNumber += 1;

                        PEPPOLMgt.GetAllowanceChargeInfo(
                            TempVATAmtLine,
                            SalesHeader,
                            ChargeIndicator,
                            AllowanceChargeReasonCode,
                            DummyVar,
                            AllowanceChargeReason,
                            Amount,
                            AllowanceChargeCurrencyID,
                            TaxCategoryID,
                            DummyVar,
                            Percent,
                            AllowanceChargeTaxSchemeID);
                    end;
                '/cac:AllowanceCharge/cbc:ChargeIndicator':
                    xmlNodeValue := ChargeIndicator;
                '/cac:AllowanceCharge/cbc:AllowanceChargeReasonCode':
                    xmlNodeValue := AllowanceChargeReasonCode;
                '/cac:AllowanceCharge/cbc:AllowanceChargeReason':
                    xmlNodeValue := AllowanceChargeReason;
                '/cac:AllowanceCharge/cbc:Amount':
                    xmlNodeValue := Amount;
                '/cac:AllowanceCharge/cac:TaxCategory/cbc:ID':
                    xmlNodeValue := TaxCategoryID;
                '/cac:AllowanceCharge/cac:TaxCategory/cbc:Percent':
                    xmlNodeValue := Percent;
                '/cac:AllowanceCharge/cac:TaxCategory/cac:TaxScheme/cbc:ID':
                    xmlNodeValue := AllowanceChargeTaxSchemeID;
                '/cac:TaxTotal':
                    PEPPOLMgt.GetTaxTotalInfo(
                        SalesHeader,
                        TempVATAmtLine,
                        TaxAmount,
                        TaxTotalCurrencyID);
                '/cac:TaxTotal/cbc:TaxAmount':
                    if TaxSubtotalLoopNumber = 1 then
                        xmlNodeValue := TaxAmount
                    else
                        xmlNodeValue := TaxAmountLCY;
                '/cac:TaxSubtotal':
                    begin
                        if TaxSubtotalLoopNumber = 1 then
                            TempVATAmtLine.FindSet()
                        else
                            TempVATAmtLine.Next();
                        TaxSubtotalLoopNumber += 1;

                        PEPPOLMgt.GetTaxSubtotalInfo(
                            TempVATAmtLine,
                            SalesHeader,
                            TaxableAmount,
                            TaxAmountCurrencyID,
                            SubtotalTaxAmount,
                            TaxSubtotalCurrencyID,
                            TransactionCurrencyTaxAmount,
                            TransCurrTaxAmtCurrencyID,
                            TaxTotalTaxCategoryID,
                            DummyVar,
                            TaxCategoryPercent,
                            TaxTotalTaxSchemeID);

                        PEPPOLMgt.GetTaxExemptionReason(TempVATProductPostingGroup, TaxExemptionReason, TaxTotalTaxCategoryID);
                    end;
                '/cac:TaxSubtotal/cbc:TaxableAmount':
                    xmlNodeValue := TaxableAmount;
                '/cac:TaxSubtotal/cbc:TaxAmount':
                    xmlNodeValue := SubtotalTaxAmount;
                '/cac:TaxSubtotal/cac:TaxCategory/cbc:ID':
                    xmlNodeValue := TaxTotalTaxCategoryID;
                '/cac:TaxSubtotal/cac:TaxCategory/cbc:Percent':
                    xmlNodeValue := TaxCategoryPercent;
                '/cac:TaxSubtotal/cac:TaxCategory/cbc:TaxExemptionReason':
                    xmlNodeValue := TaxExemptionReason;
                '/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:ID':
                    xmlNodeValue := TaxTotalTaxSchemeID;
                '/cac:LegalMonetaryTotal':
                    PEPPOLMgt.GetLegalMonetaryInfo(
                        SalesHeader,
                        TempSalesLineRounding,
                        TempVATAmtLine,
                        LineExtensionAmount,
                        LegalMonetaryTotalCurrencyID,
                        TaxExclusiveAmount,
                        TaxExclusiveAmountCurrencyID,
                        TaxInclusiveAmount,
                        TaxInclusiveAmountCurrencyID,
                        AllowanceTotalAmount,
                        AllowanceTotalAmountCurrencyID,
                        ChargeTotalAmount,
                        ChargeTotalAmountCurrencyID,
                        PrepaidAmount,
                        PrepaidCurrencyID,
                        PayableRoundingAmount,
                        PayableRndingAmountCurrencyID,
                        PayableAmount,
                        PayableAmountCurrencyID);
                '/cac:LegalMonetaryTotal/cbc:LineExtensionAmount':
                    xmlNodeValue := LineExtensionAmount;
                '/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount':
                    xmlNodeValue := TaxExclusiveAmount;
                '/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount':
                    xmlNodeValue := TaxInclusiveAmount;
                '/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount':
                    xmlNodeValue := AllowanceTotalAmount;
                '/cac:LegalMonetaryTotal/cbc:ChargeTotalAmount':
                    xmlNodeValue := ChargeTotalAmount;
                '/cac:LegalMonetaryTotal/cbc:PrepaidAmount':
                    xmlNodeValue := PrepaidAmount;
                '/cac:LegalMonetaryTotal/cbc:PayableRoundingAmount':
                    xmlNodeValue := PayableRoundingAmount;
                '/cac:LegalMonetaryTotal/cbc:PayableAmount':
                    xmlNodeValue := PayableAmount;
                '/cac:InvoiceLine/cac:AllowanceCharge',
                '/cac:CreditNoteLine/cac:AllowanceCharge':
                    PEPPOLMgt.GetLineAllowanceChargeInfo(
                        SalesLine,
                        SalesHeader,
                        LnAllowanceChargeIndicator,
                        LnAllowanceChargeReason,
                        LnAllowanceChargeAmount,
                        LnAllowanceChargeAmtCurrID);
                '/cac:InvoiceLine/cac:AllowanceCharge/cbc:ChargeIndicator',
                '/cac:CreditNoteLine/cac:AllowanceCharge/cbc:ChargeIndicator':
                    xmlNodeValue := LnAllowanceChargeIndicator;
                '/cac:InvoiceLine/cac:AllowanceCharge/cbc:AllowanceChargeReason',
                '/cac:CreditNoteLine/cac:AllowanceCharge/cbc:AllowanceChargeReason':
                    xmlNodeValue := LnAllowanceChargeReason;
                '/cac:InvoiceLine/cac:AllowanceCharge/cbc:Amount',
                '/cac:CreditNoteLine/cac:AllowanceCharge/cbc:Amount':
                    xmlNodeValue := LnAllowanceChargeAmount;
                '/cac:InvoiceLine/cbc:ID',
                '/cac:CreditNoteLine/cbc:ID':
                    PrepareLine(xmlNodeValue);
                '/cac:InvoiceLine/cac:Item',
                '/cac:CreditNoteLine/cac:Item':
                    begin
                        PEPPOLMgt.GetLineItemInfo(
                            SalesLine,
                            Description,
                            Name,
                            SellersItemIdentificationID,
                            StandardItemIdentificationID,
                            StdItemIdIDSchemeID,
                            OriginCountryIdCode,
                            OriginCountryIdCodeListID);

                        PEPPOLMgt.GetLineItemClassfiedTaxCategoryBIS(
                            SalesLine,
                            ClassifiedTaxCategoryID,
                            DummyVar,
                            InvoiceLineTaxPercent,
                            ClassifiedTaxCategorySchemeID);

                        PEPPOLMgt.GetLineAdditionalItemPropertyInfo(
                            SalesLine,
                            AdditionalItemPropertyName,
                            AdditionalItemPropertyValue);
                    end;
                '/cac:InvoiceLine/cac:Item/cac:SellersItemIdentification/cbc:ID',
                '/cac:CreditNoteLine/cac:Item/cac:SellersItemIdentification/cbc:ID':
                    xmlNodeValue := SellersItemIdentificationID;
                '/cac:InvoiceLine/cac:Item/cac:StandardItemIdentification/cbc:ID',
                '/cac:CreditNoteLine/cac:Item/cac:StandardItemIdentification/cbc:ID':
                    xmlNodeValue := StandardItemIdentificationID;
                '/cac:InvoiceLine/cac:Item/cac:OriginCountry/cbc:IdentificationCode',
                '/cac:CreditNoteLine/cac:Item/cac:OriginCountry/cbc:IdentificationCode':
                    xmlNodeValue := OriginCountryIdCode;
                '/cac:InvoiceLine/cac:Item/cac:ClassifiedTaxCategory/cbc:ID',
                '/cac:CreditNoteLine/cac:Item/cac:ClassifiedTaxCategory/cbc:ID':
                    xmlNodeValue := ClassifiedTaxCategoryID;
                '/cac:InvoiceLine/cac:Item/cac:ClassifiedTaxCategory/cbc:Percent',
                '/cac:CreditNoteLine/cac:Item/cac:ClassifiedTaxCategory/cbc:Percent':
                    xmlNodeValue := InvoiceLineTaxPercent;
                '/cac:InvoiceLine/cac:Item/cac:ClassifiedTaxCategory/cac:TaxScheme/cbc:ID',
                '/cac:CreditNoteLine/cac:Item/cac:ClassifiedTaxCategory/cac:TaxScheme/cbc:ID':
                    xmlNodeValue := ClassifiedTaxCategorySchemeID;
                '/cac:InvoiceLine/cac:Item/cac:AdditionalItemProperty/cbc:Name',
                '/cac:CreditNoteLine/cac:Item/cac:AdditionalItemProperty/cbc:Name':
                    xmlNodeValue := AdditionalItemPropertyName;
                '/cac:InvoiceLine/cac:Item/cac:AdditionalItemProperty/cbc:Value',
                '/cac:CreditNoteLine/cac:Item/cac:AdditionalItemProperty/cbc:Value':
                    xmlNodeValue := AdditionalItemPropertyValue;
                '/cac:InvoiceLine/cac:Price',
                '/cac:CreditNoteLine/cac:Price':
                    PEPPOLMgt.GetLinePriceInfo(
                        SalesLine,
                        SalesHeader,
                        InvoiceLinePriceAmount,
                        InvLinePriceAmountCurrencyID,
                        BaseQuantity,
                        UnitCodeBaseQty);
                '/cac:InvoiceLine/cac:Price/cbc:PriceAmount',
                '/cac:CreditNoteLine/cac:Price/cbc:PriceAmount':
                    xmlNodeValue := InvoiceLinePriceAmount;
                '/cac:InvoiceLine/cac:Price/cbc:BaseQuantity',
                '/cac:CreditNoteLine/cac:Price/cbc:BaseQuantity':
                    xmlNodeValue := BaseQuantity;
                '/cac:AdditionalDocumentReference':
                    begin
                        if ProcessedDocType = ProcessedDocType::"Sales Invoice" then
                            ProcessedDocTypeInt := 0
                        else
                            ProcessedDocTypeInt := 1;

                        PEPPOLMgt.GetAdditionalDocRefInfo(
                            DocumentAttachmentNumber,
                            DocumentAttachment,
                            SalesHeader,
                            AdditionalDocumentReferenceID,
                            AdditionalDocRefDocumentType,
                            URI,
                            filename,
                            mimeCode,
                            EmbeddedDocumentBinaryObject,
                            ProcessedDocTypeInt
                        );

                        DocumentAttachmentNumber += 1;
                    end;
                '/cac:AdditionalDocumentReference/cbc:ID':
                    xmlNodeValue := AdditionalDocumentReferenceID;
                '/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject':
                    xmlNodeValue := EmbeddedDocumentBinaryObject;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Generic XML", 'OnBeforeCreateXMLAttribute', '', true, true)]
    local procedure OnBeforeCreateXMLAttribute(var xmlAttributeName: Text; var xmlAttributeValue: Text; var DataExchColumnDef: Record "Data Exch. Column Def"; var DefaultNameSpace: Text; var IsHandled: Boolean)
    begin
        if IsEDocExport(DataExchColumnDef."Data Exch. Def Code") then
            case DataExchColumnDef.Path of
                '/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID[@schemeID]':
                    xmlAttributeValue := SupplierSchemeID;
                '/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID[@schemeID]':
                    xmlAttributeValue := CompanyIDSchemeID;
                '/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID[@schemeID]':
                    xmlAttributeValue := PartyLegalEntitySchemeID;
                '/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID[@schemeID]':
                    xmlAttributeValue := CustomerSchemeID;
                '/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID]':
                    xmlAttributeValue := CustomerPartyIDSchemeID;
                '/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID[@schemeID]':
                    xmlAttributeValue := CustPartyTaxSchemeCompIDSchID;
                '/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID[@schemeID]':
                    xmlAttributeValue := CustPartyLegalEntityIDSchemeID;
                '/cac:TaxRepresentativeParty/cac:PartyTaxScheme/cbc:CompanyID[@schemeID]':
                    xmlAttributeValue := PayeePartyTaxSchCompIDSchemeID;
                '/cac:Delivery/cac:DeliveryLocation/cbc:ID[@schemeID]':
                    xmlAttributeValue := DeliveryIDSchemeID;
                '/cac:AllowanceCharge/cbc:Amount[@currencyID]':
                    xmlAttributeValue := AllowanceChargeCurrencyID;
                '/cac:TaxTotal/cbc:TaxAmount[@currencyID]':
                    if TaxSubtotalLoopNumber = 1 then
                        xmlAttributeValue := TaxTotalCurrencyID
                    else
                        xmlAttributeValue := TaxTotalCurrencyIDLCY;
                '/cac:TaxSubtotal/cbc:TaxableAmount[@currencyID]':
                    xmlAttributeValue := TaxSubtotalCurrencyID;
                '/cac:TaxSubtotal/cbc:TaxAmount[@currencyID]':
                    xmlAttributeValue := TaxAmountCurrencyID;
                '/cac:LegalMonetaryTotal/cbc:LineExtensionAmount[@currencyID]':
                    xmlAttributeValue := LegalMonetaryTotalCurrencyID;
                '/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount[@currencyID]':
                    xmlAttributeValue := TaxExclusiveAmountCurrencyID;
                '/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount[@currencyID]':
                    xmlAttributeValue := TaxInclusiveAmountCurrencyID;
                '/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount[@currencyID]':
                    xmlAttributeValue := AllowanceTotalAmountCurrencyID;
                '/cac:LegalMonetaryTotal/cbc:ChargeTotalAmount[@currencyID]':
                    xmlAttributeValue := ChargeTotalAmountCurrencyID;
                '/cac:LegalMonetaryTotal/cbc:PrepaidAmount[@currencyID]':
                    xmlAttributeValue := PrepaidCurrencyID;
                '/cac:LegalMonetaryTotal/cbc:PayableRoundingAmount[@currencyID]':
                    xmlAttributeValue := PayableRndingAmountCurrencyID;
                '/cac:LegalMonetaryTotal/cbc:PayableAmount[@currencyID]':
                    xmlAttributeValue := PayableAmountCurrencyID;
                '/cac:InvoiceLine/cbc:LineExtensionAmount[@currencyID]',
                '/cac:CreditNoteLine/cbc:LineExtensionAmount[@currencyID]':
                    xmlAttributeValue := DocCurrencyCode;
                '/cac:InvoiceLine/cbc:InvoicedQuantity[@unitCode]',
                '/cac:CreditNoteLine/cbc:CreditedQuantity[@unitCode]':
                    if xmlAttributeValue = '' then
                        xmlAttributeValue := UoMforPieceINUNECERec20ListIDTxt;
                '/cac:InvoiceLine/cac:AllowanceCharge/cbc:Amount[@currencyID]',
                '/cac:CreditNoteLine/cac:AllowanceCharge/cbc:Amount[@currencyID]':
                    xmlAttributeValue := LnAllowanceChargeAmtCurrID;
                '/cac:InvoiceLine/cac:Item/cac:StandardItemIdentification/cbc:ID[@schemeID]',
                '/cac:CreditNoteLine/cac:Item/cac:StandardItemIdentification/cbc:ID[@schemeID]':
                    xmlAttributeValue := StdItemIdIDSchemeID;
                '/cac:InvoiceLine/cac:Item/cac:OriginCountry/cbc:IdentificationCode[@listID]',
                '/cac:CreditNoteLine/cac:Item/cac:OriginCountry/cbc:IdentificationCode[@listID]':
                    xmlAttributeValue := OriginCountryIdCodeListID;
                '/cac:InvoiceLine/cac:Price/cbc:PriceAmount[@currencyID]',
                '/cac:CreditNoteLine/cac:Price/cbc:PriceAmount[@currencyID]':
                    xmlAttributeValue := InvLinePriceAmountCurrencyID;
                '/cac:InvoiceLine/cac:Price/cbc:BaseQuantity[@unitCode]',
                '/cac:CreditNoteLine/cac:Price/cbc:BaseQuantity[@unitCode]':
                    xmlAttributeValue := UnitCodeBaseQty;
                '/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject[@filename]':
                    xmlAttributeValue := Filename;
                '/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject[@mimeCode]':
                    xmlAttributeValue := MimeCode;
            end;
    end;

    local procedure PrepareHeaderAndVAT(DocumentNo: Code[20])
    var
        DataExchTableFilter: Record "Data Exch. Table Filter";
        IntegerRec: Record Integer;
        OutStreamFilters: OutStream;
    begin
        case ProcessedDocType of
            ProcessedDocType::"Sales Invoice":
                begin
                    SalesInvoiceHeader.Get(DocumentNo);
                    SalesHeader.TransferFields(SalesInvoiceHeader);

                    SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                    SalesInvoiceLine.SetFilter(Type, '<>%1', SalesInvoiceLine.Type::" ");
                    if SalesInvoiceLine.FindSet() then
                        repeat
                            SalesLine.TransferFields(SalesInvoiceLine);
                            if IsRoundingLine(SalesLine) then begin
                                TempSalesLineRounding.TransferFields(SalesLine);
                                TempSalesLineRounding.Insert();
                            end else begin
                                PEPPOLMgt.GetTotals(SalesLine, TempVATAmtLine);
                                PEPPOLMgt.GetTaxCategories(SalesLine, TempVATProductPostingGroup);
                            end;
                        until SalesInvoiceLine.Next() = 0;

                    DocumentAttachment.SetRange("No.", SalesInvoiceHeader."No.");
                    DocumentAttachment.SetRange("Table ID", Database::"Sales Invoice Header");
                end;

            ProcessedDocType::"Service Invoice":
                begin
                    ServiceInvoiceHeader.Get(DocumentNo);
                    PEPPOLMgt.TransferHeaderToSalesHeader(ServiceInvoiceHeader, SalesHeader);

                    ServiceInvoiceLine.SetRange("Document No.", ServiceInvoiceHeader."No.");
                    ServiceInvoiceLine.SetFilter(Type, '<>%1', ServiceInvoiceLine.Type::" ");
                    if ServiceInvoiceLine.FindSet() then
                        repeat
                            PEPPOLMgt.TransferLineToSalesLine(ServiceInvoiceLine, SalesLine);
                            SalesLine.Type := ServPEPPOLMgt.MapServiceLineTypeToSalesLineType(ServiceInvoiceLine.Type);
                            if IsRoundingLine(SalesLine) then begin
                                TempSalesLineRounding.TransferFields(SalesLine);
                                TempSalesLineRounding.Insert();
                            end else begin
                                PEPPOLMgt.GetTotals(SalesLine, TempVATAmtLine);
                                PEPPOLMgt.GetTaxCategories(SalesLine, TempVATProductPostingGroup);
                            end;
                        until ServiceInvoiceLine.Next() = 0;

                    DocumentAttachment.SetRange("No.", ServiceInvoiceHeader."No.");
                    DocumentAttachment.SetRange("Table ID", Database::"Service Invoice Header");
                end;

            ProcessedDocType::"Sales Credit Memo":
                begin
                    SalesCrMemoHeader.Get(DocumentNo);
                    SalesHeader.TransferFields(SalesCrMemoHeader);

                    SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                    SalesCrMemoLine.SetFilter(Type, '<>%1', SalesCrMemoLine.Type::" ");
                    if SalesCrMemoLine.FindSet() then
                        repeat
                            SalesLine.TransferFields(SalesCrMemoLine);
                            if IsRoundingLine(SalesLine) then begin
                                TempSalesLineRounding.TransferFields(SalesLine);
                                TempSalesLineRounding.Insert();
                            end else begin
                                PEPPOLMgt.GetTotals(SalesLine, TempVATAmtLine);
                                PEPPOLMgt.GetTaxCategories(SalesLine, TempVATProductPostingGroup);
                            end;
                        until SalesCrMemoLine.Next() = 0;

                    DocumentAttachment.SetRange("No.", SalesCrMemoHeader."No.");
                    DocumentAttachment.SetRange("Table ID", Database::"Sales Cr.Memo Header");
                end;

            ProcessedDocType::"Service Credit Memo":
                begin
                    ServiceCrMemoHeader.Get(DocumentNo);
                    PEPPOLMgt.TransferHeaderToSalesHeader(ServiceCrMemoHeader, SalesHeader);

                    ServiceCrMemoLine.SetRange("Document No.", ServiceCrMemoHeader."No.");
                    ServiceCrMemoLine.SetFilter(Type, '<>%1', ServiceCrMemoLine.Type::" ");
                    if ServiceCrMemoLine.FindSet() then
                        repeat
                            PEPPOLMgt.TransferLineToSalesLine(ServiceCrMemoLine, SalesLine);
                            SalesLine.Type := ServPEPPOLMgt.MapServiceLineTypeToSalesLineType(ServiceCrMemoLine.Type);
                            if IsRoundingLine(SalesLine) then begin
                                TempSalesLineRounding.TransferFields(SalesLine);
                                TempSalesLineRounding.Insert();
                            end else begin
                                PEPPOLMgt.GetTotals(SalesLine, TempVATAmtLine);
                                PEPPOLMgt.GetTaxCategories(SalesLine, TempVATProductPostingGroup);
                            end;
                        until ServiceCrMemoLine.Next() = 0;

                    DocumentAttachment.SetRange("No.", ServiceCrMemoHeader."No.");
                    DocumentAttachment.SetRange("Table ID", Database::"Service Cr.Memo Header");
                end;
        end;

        DataExchTableFilter.Init();
        DataExchTableFilter."Data Exch. No." := DataExchEntryNo;
        DataExchTableFilter."Table ID" := Database::Integer;
        DataExchTableFilter."Table Filters".CreateOutStream(OutStreamFilters);
        IntegerRec.SetFilter(Number, '1..%1', TempVATAmtLine.Count());
        OutStreamFilters.WriteText(IntegerRec.GetView());
        DataExchTableFilter.Insert();
    end;

    local procedure PrepareLine(LineNoFilter: Text)
    begin
        case ProcessedDocType of
            ProcessedDocType::"Sales Invoice":
                begin
                    SalesInvoiceLine.SetFilter("Document No.", SalesInvoiceHeader."No.");
                    SalesInvoiceLine.SetFilter("Line No.", LineNoFilter);
                    SalesInvoiceLine.FindFirst();
                    SalesLine.TransferFields(SalesInvoiceLine);
                end;
            ProcessedDocType::"Service Invoice":
                begin
                    ServiceInvoiceLine.SetFilter("Document No.", ServiceInvoiceHeader."No.");
                    ServiceInvoiceLine.SetFilter("Line No.", LineNoFilter);
                    ServiceInvoiceLine.FindFirst();

                    PEPPOLMgt.TransferLineToSalesLine(ServiceInvoiceLine, SalesLine);
                    SalesLine.Type := ServPEPPOLMgt.MapServiceLineTypeToSalesLineType(ServiceInvoiceLine.Type);
                end;
            ProcessedDocType::"Sales Credit Memo":
                begin
                    SalesCrMemoLine.SetFilter("Document No.", SalesCrMemoHeader."No.");
                    SalesCrMemoLine.SetFilter("Line No.", LineNoFilter);
                    SalesCrMemoLine.FindFirst();
                    SalesLine.TransferFields(SalesCrMemoLine);
                end;
            ProcessedDocType::"Service Credit Memo":
                begin
                    ServiceCrMemoLine.SetFilter("Document No.", ServiceCrMemoHeader."No.");
                    ServiceCrMemoLine.SetFilter("Line No.", LineNoFilter);
                    ServiceCrMemoLine.FindFirst();

                    PEPPOLMgt.TransferLineToSalesLine(ServiceCrMemoLine, SalesLine);
                    SalesLine.Type := ServPEPPOLMgt.MapServiceLineTypeToSalesLineType(ServiceCrMemoLine.Type);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"E-Document Service", 'OnAfterValidateEvent', 'Document Format', false, false)]
    local procedure OnAfterValidateDocumentFormat(var Rec: Record "E-Document Service"; var xRec: Record "E-Document Service"; CurrFieldNo: Integer)
    var
        EDocServiceSupportedType: Record "E-Doc. Service Supported Type";
    begin
        if Rec."Document Format" = Rec."Document Format"::"Data Exchange" then begin
            EDocServiceSupportedType.SetRange("E-Document Service Code", Rec.Code);
            if EDocServiceSupportedType.IsEmpty() then begin
                EDocServiceSupportedType.Init();
                EDocServiceSupportedType."E-Document Service Code" := Rec.Code;
                EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Sales Invoice";
                EDocServiceSupportedType.Insert();

                EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Sales Credit Memo";
                EDocServiceSupportedType.Insert();

                EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Service Invoice";
                EDocServiceSupportedType.Insert();

                EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Service Credit Memo";
                EDocServiceSupportedType.Insert();
            end;
        end;
    end;

    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceInvoiceLine: Record "Service Invoice Line";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentAttachment: Record "Document Attachment";
        TempVATAmtLine: Record "VAT Amount Line" temporary;
        TempSalesLineRounding: Record "Sales Line" temporary;
        TempVATProductPostingGroup: Record "VAT Product Posting Group" temporary;
        PEPPOLMgt: Codeunit "PEPPOL Management";
        ServPEPPOLMgt: Codeunit "Serv. PEPPOL Management";
        ProcessedDocType: Enum "E-Document Type";
        DocumentAttachmentNumber, ProcessedDocTypeInt : Integer;
        AdditionalDocumentReferenceID, AdditionalDocRefDocumentType, URI, Filename, MimeCode, EmbeddedDocumentBinaryObject : Text;
        TaxAmountLCY, TaxCurrencyCodeLCY, TaxTotalCurrencyIDLCY : Text;
        SupplierEndpointID, SupplierSchemeID, SupplierName : Text;
        StreetName, AdditionalStreetName, CityName, PostalZone, CountrySubentity, IdentificationCode, DummyVar : Text;
        CompanyID, CompanyIDSchemeID, TaxSchemeID : Text;
        CustPartyTaxSchemeCompanyID, CustPartyTaxSchemeCompIDSchID, CustTaxSchemeID : Text;
        PartyLegalEntityRegName, PartyLegalEntityCompanyID, PartyLegalEntitySchemeID, SupplierRegAddrCityName, SupplierRegAddrCountryIdCode, SupplRegAddrCountryIdListId : Text;
        CustPartyLegalEntityRegName, CustPartyLegalEntityCompanyID, CustPartyLegalEntityIDSchemeID : Text;
        CustomerEndpointID, CustomerSchemeID, CustomerPartyIdentificationID, CustomerPartyIDSchemeID, CustomerName : Text;
        ContactName, Telephone, Telefax, ElectronicMail : Text;
        CustContactName, CustContactTelephone, CustContactTelefax, CustContactElectronicMail : Text;
        TaxRepPartyNameName, PayeePartyTaxSchemeCompanyID, PayeePartyTaxSchCompIDSchemeID, PayeePartyTaxSchemeTaxSchemeID : Text;
        PaymentMeansCode, PaymentChannelCode, PaymentID, PrimaryAccountNumberID, NetworkID, PayeeFinancialAccountID, FinancialInstitutionBranchID : Text;
        ActualDeliveryDate, DeliveryID, DeliveryIDSchemeID : Text;
        PaymentTermsNote: Text;
        ChargeIndicator, AllowanceChargeReasonCode, AllowanceChargeReason, Amount, AllowanceChargeCurrencyID, TaxCategoryID, Percent, AllowanceChargeTaxSchemeID : Text;
        TaxAmount, TaxTotalCurrencyID : Text;
        TaxableAmount, TaxAmountCurrencyID, SubtotalTaxAmount, TaxSubtotalCurrencyID, TransactionCurrencyTaxAmount, TransCurrTaxAmtCurrencyID, TaxTotalTaxCategoryID, TaxCategoryPercent, TaxTotalTaxSchemeID, TaxExemptionReason : Text;
        LineExtensionAmount, LegalMonetaryTotalCurrencyID, TaxExclusiveAmount, TaxExclusiveAmountCurrencyID, TaxInclusiveAmount, TaxInclusiveAmountCurrencyID, AllowanceTotalAmount, AllowanceTotalAmountCurrencyID, ChargeTotalAmount, ChargeTotalAmountCurrencyID, PrepaidAmount, PrepaidCurrencyID, PayableRoundingAmount, PayableRndingAmountCurrencyID, PayableAmount, PayableAmountCurrencyID : Text;
        DocCurrencyCode: Text;
        LnAllowanceChargeIndicator, LnAllowanceChargeReason, LnAllowanceChargeAmount, LnAllowanceChargeAmtCurrID : Text;
        Description, Name, SellersItemIdentificationID, StandardItemIdentificationID, StdItemIdIDSchemeID, OriginCountryIdCode, OriginCountryIdCodeListID : Text;
        ClassifiedTaxCategoryID, InvoiceLineTaxPercent, ClassifiedTaxCategorySchemeID, AdditionalItemPropertyName, AdditionalItemPropertyValue : Text;
        InvoiceLinePriceAmount, InvLinePriceAmountCurrencyID, BaseQuantity, UnitCodeBaseQty : Text;
        InvoiceDocRefID, InvoiceDocRefIssueDate : Text;
        DataExchEntryNo: Integer;
        TaxSubtotalLoopNumber, AllowanceChargeLoopNumber : Integer;
        CacNamespaceURILbl: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2', Locked = true;
        CbcNamespaceURILbl: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2', Locked = true;
        CctsNamespaceURILbl: Label 'urn:un:unece:uncefact:documentation:2', Locked = true;
        QdtNamespaceURILbl: Label 'urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2', Locked = true;
        UdtNamespaceURILbl: Label 'urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2', Locked = true;
        UoMforPieceINUNECERec20ListIDTxt: Label 'EA', Locked = true;
}