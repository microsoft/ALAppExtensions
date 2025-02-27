namespace Microsoft.EServices.EDocument.IO.Peppol;

using System.Utilities;
using Microsoft.Sales.Document;
using Microsoft.Sales.Reminder;
using Microsoft.Sales.Peppol;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Sales.FinanceCharge;

xmlport 6100 "Reminder - PEPPOL BIS 3.0"
{
    Caption = 'Reminder PEPPOL BIS 3.0';
    Direction = Export;
    Encoding = UTF8;
    Namespaces = "" = 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2', cac = 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2', cbc = 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2', ccts = 'urn:un:unece:uncefact:documentation:2', qdt = 'urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2', udt = 'urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2';

    schema
    {
        tableelement(reminderheaderloop; Integer)
        {
            MaxOccurs = Once;
            XmlName = 'Invoice';
            SourceTableView = sorting(Number) where(Number = filter(1 ..));
            textelement(CustomizationID)
            {
                NamespacePrefix = 'cbc';
            }
            textelement(ProfileID)
            {
                NamespacePrefix = 'cbc';
            }
            textelement(ID)
            {
                NamespacePrefix = 'cbc';
            }
            textelement(IssueDate)
            {
                NamespacePrefix = 'cbc';
            }
            textelement(DueDate)
            {
                NamespacePrefix = 'cbc';

                trigger OnBeforePassVariable()
                begin
                    DueDate := Format(SalesHeader."Due Date", 0, 9);
                    if DueDate = '' then
                        currXMLport.Skip();
                end;
            }
            textelement(InvoiceTypeCode)
            {
                NamespacePrefix = 'cbc';
            }
            textelement(DocumentCurrencyCode)
            {
                NamespacePrefix = 'cbc';
            }
            textelement(BuyerReference)
            {
                NamespacePrefix = 'cbc';

                trigger OnBeforePassVariable()
                begin
                    BuyerReference := this.SalesHeader."Your Reference";
                    if BuyerReference = '' then
                        currXMLport.Skip();
                end;
            }
            textelement(AccountingSupplierParty)
            {
                NamespacePrefix = 'cac';
                textelement(supplierparty)
                {
                    NamespacePrefix = 'cac';
                    XmlName = 'Party';
                    textelement(supplierendpointid)
                    {
                        NamespacePrefix = 'cbc';
                        XmlName = 'EndpointID';
                        textattribute(supplierschemeid)
                        {
                            XmlName = 'schemeID';
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if SupplierEndpointID = '' then
                                currXMLport.Skip();
                        end;
                    }
                    textelement(PartyIdentification)
                    {
                        NamespacePrefix = 'cac';
                        textelement(partyidentificationid)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'ID';
                            textattribute(supplierpartyidschemeid)
                            {
                                XmlName = 'schemeID';
                            }
                        }

                        trigger OnBeforePassVariable()
                        begin
                            this.PEPPOLMgt.GetAccountingSupplierPartyIdentificationID(this.SalesHeader, PartyIdentificationID);
                            if PartyIdentificationID = '' then
                                currXMLport.Skip();
                        end;
                    }
                    textelement(supplierpartyname)
                    {
                        NamespacePrefix = 'cac';
                        XmlName = 'PartyName';
                        textelement(suppliername)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'Name';
                        }
                    }
                    textelement(supplierpostaladdress)
                    {
                        NamespacePrefix = 'cac';
                        XmlName = 'PostalAddress';
                        textelement(StreetName)
                        {
                            NamespacePrefix = 'cbc';

                            trigger OnBeforePassVariable()
                            begin
                                if StreetName = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(supplieradditionalstreetname)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'AdditionalStreetName';

                            trigger OnBeforePassVariable()
                            begin
                                if SupplierAdditionalStreetName = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(CityName)
                        {
                            NamespacePrefix = 'cbc';

                            trigger OnBeforePassVariable()
                            begin
                                if CityName = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(PostalZone)
                        {
                            NamespacePrefix = 'cbc';

                            trigger OnBeforePassVariable()
                            begin
                                if PostalZone = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(CountrySubentity)
                        {
                            NamespacePrefix = 'cbc';

                            trigger OnBeforePassVariable()
                            begin
                                if CountrySubentity = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(Country)
                        {
                            NamespacePrefix = 'cac';
                            textelement(IdentificationCode)
                            {
                                NamespacePrefix = 'cbc';
                            }
                        }
                    }
                    textelement(PartyTaxScheme)
                    {
                        NamespacePrefix = 'cac';
                        textelement(CompanyID)
                        {
                            NamespacePrefix = 'cbc';
                            textattribute(companyidschemeid)
                            {
                                XmlName = 'schemeID';

                                trigger OnBeforePassVariable()
                                begin
                                    if CompanyIDSchemeID = '' then
                                        currXMLport.Skip();
                                end;
                            }
                        }
                        textelement(ExemptionReason)
                        {
                            NamespacePrefix = 'cbc';

                            trigger OnBeforePassVariable()
                            begin
                                if ExemptionReason = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(suppliertaxscheme)
                        {
                            NamespacePrefix = 'cac';
                            XmlName = 'TaxScheme';
                            textelement(taxschemeid)
                            {
                                NamespacePrefix = 'cbc';
                                XmlName = 'ID';
                            }
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if CompanyID = '' then
                                currXMLport.Skip();
                        end;
                    }
                    textelement(PartyLegalEntity)
                    {
                        NamespacePrefix = 'cac';
                        textelement(partylegalentityregname)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'RegistrationName';

                            trigger OnBeforePassVariable()
                            begin
                                if PartyLegalEntityRegName = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(partylegalentitycompanyid)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'CompanyID';
                            textattribute(partylegalentityschemeid)
                            {
                                XmlName = 'schemeID';

                                trigger OnBeforePassVariable()
                                begin
                                    if PartyLegalEntitySchemeID = '' then
                                        currXMLport.Skip();
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if PartyLegalEntityCompanyID = '' then
                                    currXMLport.Skip();
                            end;
                        }
                    }
                    textelement(Contact)
                    {
                        NamespacePrefix = 'cac';
                        textelement(contactname)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'Name';

                            trigger OnBeforePassVariable()
                            begin
                                if ContactName = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(Telephone)
                        {
                            NamespacePrefix = 'cbc';

                            trigger OnBeforePassVariable()
                            begin
                                if Telephone = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(Telefax)
                        {
                            NamespacePrefix = 'cbc';

                            trigger OnBeforePassVariable()
                            begin
                                if Telefax = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(ElectronicMail)
                        {
                            NamespacePrefix = 'cbc';

                            trigger OnBeforePassVariable()
                            begin
                                if ElectronicMail = '' then
                                    currXMLport.Skip();
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if (ContactName = '') and (Telephone = '') and (Telefax = '') and (ElectronicMail = '') then
                                currXMLport.Skip();
                        end;
                    }
                }

                trigger OnBeforePassVariable()
                var
                    SupplierRegAddrCityName: Text;
                    SupplierRegAddrCountryIdCode: Text;
                    SupplRegAddrCountryIdListId: Text;
                begin
                    this.PEPPOLMgt.GetAccountingSupplierPartyInfoBIS(
                      SupplierEndpointID,
                      SupplierSchemeID,
                      SupplierName);

                    this.PEPPOLMgt.GetAccountingSupplierPartyPostalAddr(
                      this.SalesHeader,
                      StreetName,
                      SupplierAdditionalStreetName,
                      CityName,
                      PostalZone,
                      CountrySubentity,
                      IdentificationCode,
                      this.DummyVar);

                    this.PEPPOLMgt.GetAccountingSupplierPartyTaxSchemeBIS(
                      this.TempVATAmtLine,
                      CompanyID,
                      CompanyIDSchemeID,
                      TaxSchemeID);

                    this.PEPPOLMgt.GetAccountingSupplierPartyLegalEntityBIS(
                      PartyLegalEntityRegName,
                      PartyLegalEntityCompanyID,
                      PartyLegalEntitySchemeID,
                      SupplierRegAddrCityName,
                      SupplierRegAddrCountryIdCode,
                      SupplRegAddrCountryIdListId);

                    this.PEPPOLMgt.GetAccountingSupplierPartyContact(
                      this.SalesHeader,
                      this.DummyVar,
                      ContactName,
                      Telephone,
                      Telefax,
                      ElectronicMail);
                end;
            }
            textelement(AccountingCustomerParty)
            {
                NamespacePrefix = 'cac';
                textelement(customerparty)
                {
                    NamespacePrefix = 'cac';
                    XmlName = 'Party';
                    textelement(customerendpointid)
                    {
                        NamespacePrefix = 'cbc';
                        XmlName = 'EndpointID';
                        textattribute(customerschemeid)
                        {
                            XmlName = 'schemeID';
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if CustomerEndpointID = '' then
                                currXMLport.Skip();
                        end;
                    }
                    textelement(customerpartyidentification)
                    {
                        NamespacePrefix = 'cac';
                        XmlName = 'PartyIdentification';
                        textelement(customerpartyidentificationid)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'ID';
                            textattribute(customerpartyidschemeid)
                            {
                                XmlName = 'schemeID';
                            }
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if CustomerPartyIdentificationID = '' then
                                currXMLport.Skip();
                        end;
                    }
                    textelement(custoemerpartyname)
                    {
                        NamespacePrefix = 'cac';
                        XmlName = 'PartyName';
                        textelement(customername)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'Name';
                        }
                    }
                    textelement(customerpostaladdress)
                    {
                        NamespacePrefix = 'cac';
                        XmlName = 'PostalAddress';
                        textelement(customerstreetname)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'StreetName';
                        }
                        textelement(customeradditionalstreetname)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'AdditionalStreetName';

                            trigger OnBeforePassVariable()
                            begin
                                if CustomerAdditionalStreetName = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(customercityname)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'CityName';
                        }
                        textelement(customerpostalzone)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'PostalZone';
                        }
                        textelement(customercountrysubentity)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'CountrySubentity';

                            trigger OnBeforePassVariable()
                            begin
                                if CustomerCountrySubentity = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(customercountry)
                        {
                            NamespacePrefix = 'cac';
                            XmlName = 'Country';
                            textelement(customeridentificationcode)
                            {
                                NamespacePrefix = 'cbc';
                                XmlName = 'IdentificationCode';
                            }
                        }
                    }
                    textelement(customerpartytaxscheme)
                    {
                        NamespacePrefix = 'cac';
                        XmlName = 'PartyTaxScheme';
                        textelement(custpartytaxschemecompanyid)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'CompanyID';
                            textattribute(custpartytaxschemecompidschid)
                            {
                                XmlName = 'schemeID';

                                trigger OnBeforePassVariable()
                                begin
                                    if CustPartyTaxSchemeCompIDSchID = '' then
                                        currXMLport.Skip();
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if CustPartyTaxSchemeCompanyID = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(custtaxscheme)
                        {
                            NamespacePrefix = 'cac';
                            XmlName = 'TaxScheme';
                            textelement(custtaxschemeid)
                            {
                                NamespacePrefix = 'cbc';
                                XmlName = 'ID';
                            }
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if CustTaxSchemeID = '' then
                                currXMLport.Skip();
                        end;
                    }
                    textelement(custpartylegalentity)
                    {
                        NamespacePrefix = 'cac';
                        XmlName = 'PartyLegalEntity';
                        textelement(custpartylegalentityregname)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'RegistrationName';

                            trigger OnBeforePassVariable()
                            begin
                                if CustPartyLegalEntityRegName = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(custpartylegalentitycompanyid)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'CompanyID';
                            textattribute(custpartylegalentityidschemeid)
                            {
                                XmlName = 'schemeID';

                                trigger OnBeforePassVariable()
                                begin
                                    if CustPartyLegalEntityIDSchemeID = '' then
                                        currXMLport.Skip();
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if CustPartyLegalEntityCompanyID = '' then
                                    currXMLport.Skip();
                            end;
                        }
                    }
                    textelement(custcontact)
                    {
                        NamespacePrefix = 'cac';
                        XmlName = 'Contact';
                        textelement(custcontactname)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'Name';
                        }
                        textelement(custcontacttelephone)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'Telephone';

                            trigger OnBeforePassVariable()
                            begin
                                if CustContactTelephone = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(custcontacttelefax)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'Telefax';

                            trigger OnBeforePassVariable()
                            begin
                                if CustContactTelefax = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(custcontactelectronicmail)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'ElectronicMail';

                            trigger OnBeforePassVariable()
                            begin
                                if CustContactElectronicMail = '' then
                                    currXMLport.Skip();
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if (CustContactName = '') and (CustContactElectronicMail = '') and
                               (CustContactTelephone = '') and (CustContactTelefax = '')
                            then
                                currXMLport.Skip();
                        end;
                    }
                }

                trigger OnBeforePassVariable()
                begin
                    this.PEPPOLMgt.GetAccountingCustomerPartyInfoBIS(
                      this.SalesHeader,
                      CustomerEndpointID,
                      CustomerSchemeID,
                      CustomerPartyIdentificationID,
                      CustomerPartyIDSchemeID,
                      CustomerName);

                    this.PEPPOLMgt.GetAccountingCustomerPartyPostalAddr(
                      this.SalesHeader,
                      CustomerStreetName,
                      CustomerAdditionalStreetName,
                      CustomerCityName,
                      CustomerPostalZone,
                      CustomerCountrySubentity,
                      CustomerIdentificationCode,
                      this.DummyVar);

                    this.PEPPOLMgt.GetAccountingCustomerPartyTaxSchemeBIS(
                      this.SalesHeader,
                      CustPartyTaxSchemeCompanyID,
                      CustPartyTaxSchemeCompIDSchID,
                      CustTaxSchemeID);

                    this.PEPPOLMgt.GetAccountingCustomerPartyLegalEntityBIS(
                      this.SalesHeader,
                      CustPartyLegalEntityRegName,
                      CustPartyLegalEntityCompanyID,
                      CustPartyLegalEntityIDSchemeID);

                    this.PEPPOLMgt.GetAccountingCustomerPartyContact(
                      this.SalesHeader,
                      this.DummyVar,
                      CustContactName,
                      CustContactTelephone,
                      CustContactTelefax,
                      CustContactElectronicMail);
                end;
            }
            textelement(PaymentMeans)
            {
                NamespacePrefix = 'cac';
                textelement(PaymentMeansCode)
                {
                    NamespacePrefix = 'cbc';
                }
                textelement(PaymentChannelCode)
                {
                    NamespacePrefix = 'cbc';

                    trigger OnBeforePassVariable()
                    begin
                        if PaymentChannelCode = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(PaymentID)
                {
                    NamespacePrefix = 'cbc';

                    trigger OnBeforePassVariable()
                    begin
                        if PaymentID = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(CardAccount)
                {
                    NamespacePrefix = 'cac';
                    textelement(PrimaryAccountNumberID)
                    {
                        NamespacePrefix = 'cbc';
                    }
                    textelement(NetworkID)
                    {
                        NamespacePrefix = 'cbc';
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if PrimaryAccountNumberID = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(PayeeFinancialAccount)
                {
                    NamespacePrefix = 'cac';
                    textelement(payeefinancialaccountid)
                    {
                        NamespacePrefix = 'cbc';
                        XmlName = 'ID';
                    }
                    textelement(FinancialInstitutionBranch)
                    {
                        NamespacePrefix = 'cac';
                        textelement(financialinstitutionbranchid)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'ID';
                        }
                    }
                }

                trigger OnBeforePassVariable()
                begin
                    this.PEPPOLMgt.GetPaymentMeansInfo(
                      this.SalesHeader,
                      PaymentMeansCode,
                      this.DummyVar,
                      this.DummyVar,
                      PaymentChannelCode,
                      PaymentID,
                      PrimaryAccountNumberID,
                      NetworkID);

                    this.PEPPOLMgt.GetPaymentMeansPayeeFinancialAccBIS(
                        this.SalesHeader,
                        PayeeFinancialAccountID,
                        FinancialInstitutionBranchID);
                end;
            }
            tableelement(pmttermsloop; Integer)
            {
                NamespacePrefix = 'cac';
                XmlName = 'PaymentTerms';
                SourceTableView = sorting(Number) where(Number = filter(1 ..));
                textelement(paymenttermsnote)
                {
                    NamespacePrefix = 'cbc';
                    XmlName = 'Note';
                }

                trigger OnAfterGetRecord()
                begin
                    this.PEPPOLMgt.GetPaymentTermsInfo(
                      this.SalesHeader,
                      PaymentTermsNote);

                    if PaymentTermsNote = '' then
                        currXMLport.Skip();
                end;

                trigger OnPreXmlItem()
                begin
                    PmtTermsLoop.SetRange(Number, 1, 1);
                end;
            }
            textelement(TaxTotal)
            {
                NamespacePrefix = 'cac';
                textelement(TaxAmount)
                {
                    NamespacePrefix = 'cbc';
                    textattribute(taxtotalcurrencyid)
                    {
                        XmlName = 'currencyID';
                    }
                }
                tableelement(taxsubtotalloop; Integer)
                {
                    NamespacePrefix = 'cac';
                    XmlName = 'TaxSubtotal';
                    SourceTableView = sorting(Number) where(Number = filter(1 ..));
                    textelement(TaxableAmount)
                    {
                        NamespacePrefix = 'cbc';
                        textattribute(taxsubtotalcurrencyid)
                        {
                            XmlName = 'currencyID';
                        }
                    }
                    textelement(subtotaltaxamount)
                    {
                        NamespacePrefix = 'cbc';
                        XmlName = 'TaxAmount';
                        textattribute(taxamountcurrencyid)
                        {
                            XmlName = 'currencyID';
                        }
                    }
                    textelement(subtotaltaxcategory)
                    {
                        NamespacePrefix = 'cac';
                        XmlName = 'TaxCategory';
                        textelement(taxtotaltaxcategoryid)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'ID';
                        }
                        textelement(taxcategorypercent)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'Percent';
                        }
                        textelement(TaxExemptionReason)
                        {
                            NamespacePrefix = 'cbc';

                            trigger OnBeforePassVariable()
                            begin
                                if TaxExemptionReason = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(taxsubtotaltaxscheme)
                        {
                            NamespacePrefix = 'cac';
                            XmlName = 'TaxScheme';
                            textelement(taxtotaltaxschemeid)
                            {
                                NamespacePrefix = 'cbc';
                                XmlName = 'ID';
                            }
                        }
                    }

                    trigger OnAfterGetRecord()
                    var
                        TransactionCurrencyTaxAmount: Text;
                        TransCurrTaxAmtCurrencyID: Text;
                    begin
                        if not this.FindNextVATAmtRec(this.TempVATAmtLine, TaxSubtotalLoop.Number) then
                            currXMLport.Break();

                        this.PEPPOLMgt.GetTaxSubtotalInfo(
                          this.TempVATAmtLine,
                          this.SalesHeader,
                          TaxableAmount,
                          TaxAmountCurrencyID,
                          SubtotalTaxAmount,
                          TaxSubtotalCurrencyID,
                          TransactionCurrencyTaxAmount,
                          TransCurrTaxAmtCurrencyID,
                          TaxTotalTaxCategoryID,
                          this.DummyVar,
                          TaxCategoryPercent,
                          TaxTotalTaxSchemeID);

                        this.PEPPOLMgt.GetTaxExemptionReason(this.TempVATProductPostingGroup, TaxExemptionReason, TaxTotalTaxCategoryID);
                    end;
                }

                trigger OnBeforePassVariable()
                begin
                    this.PEPPOLMgt.GetTaxTotalInfo(
                      this.SalesHeader,
                      this.TempVATAmtLine,
                      TaxAmount,
                      TaxTotalCurrencyID);
                end;
            }
            textelement(LegalMonetaryTotal)
            {
                NamespacePrefix = 'cac';
                textelement(LineExtensionAmount)
                {
                    NamespacePrefix = 'cbc';
                    textattribute(legalmonetarytotalcurrencyid)
                    {
                        XmlName = 'currencyID';
                    }
                }
                textelement(TaxExclusiveAmount)
                {
                    NamespacePrefix = 'cbc';
                    textattribute(taxexclusiveamountcurrencyid)
                    {
                        XmlName = 'currencyID';
                    }
                }
                textelement(TaxInclusiveAmount)
                {
                    NamespacePrefix = 'cbc';
                    textattribute(taxinclusiveamountcurrencyid)
                    {
                        XmlName = 'currencyID';
                    }
                }
                textelement(AllowanceTotalAmount)
                {
                    NamespacePrefix = 'cbc';
                    textattribute(allowancetotalamountcurrencyid)
                    {
                        XmlName = 'currencyID';
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if AllowanceTotalAmount = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(ChargeTotalAmount)
                {
                    NamespacePrefix = 'cbc';
                    textattribute(chargetotalamountcurrencyid)
                    {
                        XmlName = 'currencyID';
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if ChargeTotalAmount = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(PrepaidAmount)
                {
                    NamespacePrefix = 'cbc';
                    textattribute(prepaidcurrencyid)
                    {
                        XmlName = 'currencyID';
                    }
                }
                textelement(PayableRoundingAmount)
                {
                    NamespacePrefix = 'cbc';
                    textattribute(payablerndingamountcurrencyid)
                    {
                        XmlName = 'currencyID';
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if PayableRoundingAmount = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(PayableAmount)
                {
                    NamespacePrefix = 'cbc';
                    textattribute(payableamountcurrencyid)
                    {
                        XmlName = 'currencyID';
                    }
                }

                trigger OnBeforePassVariable()
                begin
                    this.PEPPOLMgt.GetLegalMonetaryInfo(
                      this.SalesHeader,
                      this.TempSalesLineRounding,
                      this.TempVATAmtLine,
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
                end;
            }
            tableelement(invoicelineloop; Integer)
            {
                NamespacePrefix = 'cac';
                XmlName = 'InvoiceLine';
                SourceTableView = sorting(Number) where(Number = filter(1 ..));
                textelement(invoicelineid)
                {
                    NamespacePrefix = 'cbc';
                    XmlName = 'ID';
                }
                textelement(InvoicedQuantity)
                {
                    NamespacePrefix = 'cbc';
                    textattribute(unitCode)
                    {
                    }
                }
                textelement(invoicelineextensionamount)
                {
                    NamespacePrefix = 'cbc';
                    XmlName = 'LineExtensionAmount';
                    textattribute(lineextensionamountcurrencyid)
                    {
                        XmlName = 'currencyID';
                    }
                }
                textelement(Item)
                {
                    NamespacePrefix = 'cac';
                    textelement(Description)
                    {
                        NamespacePrefix = 'cbc';

                        trigger OnBeforePassVariable()
                        begin
                            if Description = '' then
                                currXMLport.Skip();
                        end;
                    }
                    textelement(Name)
                    {
                        NamespacePrefix = 'cbc';
                    }
                    textelement(ClassifiedTaxCategory)
                    {
                        NamespacePrefix = 'cac';
                        textelement(classifiedtaxcategoryid)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'ID';
                        }
                        textelement(invoicelinetaxpercent)
                        {
                            NamespacePrefix = 'cbc';
                            XmlName = 'Percent';

                            trigger OnBeforePassVariable()
                            begin
                                if InvoiceLineTaxPercent = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(classifiedtaxcategorytaxscheme)
                        {
                            NamespacePrefix = 'cac';
                            XmlName = 'TaxScheme';
                            textelement(classifiedtaxcategoryschemeid)
                            {
                                NamespacePrefix = 'cbc';
                                XmlName = 'ID';
                            }
                        }

                        trigger OnBeforePassVariable()
                        begin
                            this.PEPPOLMgt.GetLineItemClassfiedTaxCategoryBIS(
                              this.SalesLine,
                              ClassifiedTaxCategoryID,
                              this.DummyVar,
                              InvoiceLineTaxPercent,
                              ClassifiedTaxCategorySchemeID);
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        this.PEPPOLMgt.GetLineItemInfo(
                          this.SalesLine,
                          Description,
                          Name,
                          this.DummyVar,
                          this.DummyVar,
                          this.DummyVar,
                          this.DummyVar,
                          this.DummyVar);
                    end;
                }
                textelement(invoicelineprice)
                {
                    NamespacePrefix = 'cac';
                    XmlName = 'Price';
                    textelement(invoicelinepriceamount)
                    {
                        NamespacePrefix = 'cbc';
                        XmlName = 'PriceAmount';
                        textattribute(invlinepriceamountcurrencyid)
                        {
                            XmlName = 'currencyID';
                        }
                    }
                    textelement(BaseQuantity)
                    {
                        NamespacePrefix = 'cbc';
                        textattribute(unitcodebaseqty)
                        {
                            XmlName = 'unitCode';
                        }
                    }

                    trigger OnBeforePassVariable()
                    begin
                        this.PEPPOLMgt.GetLinePriceInfo(
                          this.SalesLine,
                          this.SalesHeader,
                          InvoiceLinePriceAmount,
                          InvLinePriceAmountCurrencyID,
                          BaseQuantity,
                          UnitCodeBaseQty);
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if this.IsReminder then
                        if not this.FindNextReminderLineRec(InvoiceLineLoop.Number) then
                            currXMLport.Break();

                    if this.IsFinChargeMemo then
                        if not this.FindNextFinChargeMemoLineRec(InvoiceLineLoop.Number) then
                            currXMLport.Break();

                    this.PEPPOLMgt.GetLineGeneralInfo(
                      this.SalesLine,
                      this.SalesHeader,
                      InvoiceLineID,
                      this.DummyVar,
                      InvoicedQuantity,
                      InvoiceLineExtensionAmount,
                      lineextensionamountcurrencyid,
                      this.DummyVar);

                    this.PEPPOLMgt.GetLineUnitCodeInfo(this.SalesLine, unitCode, this.DummyVar);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if this.IsReminder then
                    if not this.FindNextIssuedReminderRec(this.IssuedReminderHeader, this.SalesHeader, ReminderHeaderLoop.Number) then
                        currXMLport.Break();

                if this.IsFinChargeMemo then
                    if not this.FindNextIssuedFinChargeMemoRec(this.IssuedFinChargeMemoHeader, this.SalesHeader, ReminderHeaderLoop.Number) then
                        currXMLport.Break();

                this.GetTotals();

                this.PEPPOLMgt.GetGeneralInfoBIS(
                  this.SalesHeader,
                  ID,
                  IssueDate,
                  InvoiceTypeCode,
                  this.DummyVar,
                  this.DummyVar,
                  DocumentCurrencyCode,
                  this.DummyVar);

                CustomizationID := this.GetCustomizationID();
                ProfileID := this.GetProfileID();
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    ShowCaption = false;
#pragma warning disable AA0100
                    field("IssuedReminderHeader.""No."""; IssuedReminderHeader."No.")
#pragma warning restore AA0100
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Issued Reminder No.';
                        TableRelation = "Issued Reminder Header";
                    }
                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }

    var
        TempVATAmtLine: Record "VAT Amount Line" temporary;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TempSalesLineRounding: Record "Sales Line" temporary;
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedReminderLine: Record "Issued Reminder Line";
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        IssuedFinChargeMemoLine: Record "Issued Fin. Charge Memo Line";
        TempVATProductPostingGroup: Record "VAT Product Posting Group" temporary;
        PEPPOLMgt: Codeunit "PEPPOL Management";
        SourceRecRef: RecordRef;
        DummyVar: Text;
        IsReminder: Boolean;
        IsFinChargeMemo: Boolean;
        SpecifyAReminderNoErr: Label 'You must specify an issued reminder number.';
        UnSupportedTableTypeErr: Label 'The %1 table is not supported.', Comment = '%1 is the table.';

    local procedure GetTotals()
    begin
        if this.IsReminder then begin
            this.IssuedReminderLine.SetRange("Reminder No.", this.IssuedReminderHeader."No.");
            if this.IssuedReminderLine.FindSet() then
                repeat
                    this.CopyDocumentLineToSalesLine(this.SalesLine, this.IssuedReminderHeader, this.IssuedReminderLine);
                    this.PEPPOLMgt.GetTotals(this.SalesLine, this.TempVATAmtLine);
                    this.PEPPOLMgt.GetTaxCategories(this.SalesLine, this.TempVATProductPostingGroup);
                until this.IssuedReminderLine.Next() = 0;
        end;

        if this.IsFinChargeMemo then begin
            this.IssuedFinChargeMemoLine.SetRange("Finance Charge Memo No.", this.IssuedFinChargeMemoHeader."No.");
            if this.IssuedFinChargeMemoLine.FindSet() then
                repeat
                    this.CopyDocumentLineToSalesLine(this.SalesLine, this.IssuedFinChargeMemoHeader, this.IssuedFinChargeMemoLine);
                    this.PEPPOLMgt.GetTotals(this.SalesLine, this.TempVATAmtLine);
                    this.PEPPOLMgt.GetTaxCategories(this.SalesLine, this.TempVATProductPostingGroup);
                until this.IssuedFinChargeMemoLine.Next() = 0;
        end;
    end;

    local procedure FindNextVATAmtRec(var VATAmtLine: Record "VAT Amount Line"; Position: Integer): Boolean
    begin
        if Position = 1 then
            exit(VATAmtLine.Find('-'));
        exit(VATAmtLine.Next() <> 0);
    end;

    procedure Initialize(DocVariant: Variant)
    begin
        this.SourceRecRef.GetTable(DocVariant);
        case this.SourceRecRef.Number of
            Database::"Issued Reminder Header":
                begin
                    this.SourceRecRef.SetTable(this.IssuedReminderHeader);
                    if this.IssuedReminderHeader."No." = '' then
                        Error(this.SpecifyAReminderNoErr);
                    this.IssuedReminderHeader.SetRecFilter();
                    this.IssuedReminderLine.SetRange("Reminder No.", this.IssuedReminderHeader."No.");
                    this.IssuedReminderLine.SetFilter(Type, '<>%1', this.IssuedReminderLine.Type::" ");

                    if this.IssuedReminderLine.FindSet() then
                        repeat
                            this.CopyDocumentLineToSalesLine(this.SalesLine, this.IssuedReminderHeader, this.IssuedReminderLine);
                        until this.IssuedReminderLine.Next() = 0;

                    this.IsReminder := true;
                end;
            Database::"Issued Fin. Charge Memo Header":
                begin
                    this.SourceRecRef.SetTable(this.IssuedFinChargeMemoHeader);
                    if this.IssuedFinChargeMemoHeader."No." = '' then
                        Error(this.SpecifyAReminderNoErr);
                    this.IssuedFinChargeMemoHeader.SetRecFilter();
                    this.IssuedFinChargeMemoLine.SetRange("Finance Charge Memo No.", this.IssuedFinChargeMemoHeader."No.");
                    this.IssuedFinChargeMemoLine.SetFilter(Type, '<>%1', this.IssuedFinChargeMemoLine.Type::" ");

                    if this.IssuedFinChargeMemoLine.FindSet() then
                        repeat
                            this.CopyDocumentLineToSalesLine(this.SalesLine, this.IssuedFinChargeMemoHeader, this.IssuedFinChargeMemoLine);
                        until this.IssuedFinChargeMemoLine.Next() = 0;

                    this.IsFinChargeMemo := true;
                end;
            else
                Error(this.UnSupportedTableTypeErr, this.SourceRecRef.Number);
        end;
    end;

    local procedure CopyDocumentToSalesHeader(var SalesHeader: Record "Sales Header"; DocumentToCopy: Variant)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(DocumentToCopy);

        Clear(SalesHeader);
        SalesHeader."No." := RecRef.Field(this.IssuedReminderHeader.FieldNo("No.")).Value;
        SalesHeader."Document Date" := RecRef.Field(this.IssuedReminderHeader.FieldNo("Document Date")).Value;
        SalesHeader."Due Date" := RecRef.Field(this.IssuedReminderHeader.FieldNo("Due Date")).Value;
        SalesHeader."Posting Date" := RecRef.Field(this.IssuedReminderHeader.FieldNo("Posting Date")).Value;
        SalesHeader."Currency Code" := RecRef.Field(this.IssuedReminderHeader.FieldNo("Currency Code")).Value;
        SalesHeader.Validate("Sell-to Customer No.", RecRef.Field(this.IssuedReminderHeader.FieldNo("Customer No.")).Value);
        SalesHeader.Validate("Sell-to Contact", RecRef.Field(this.IssuedReminderHeader.FieldNo(Contact)).Value);
        SalesHeader."Your Reference" := RecRef.Field(this.IssuedReminderHeader.FieldNo("Your Reference")).Value;
        SalesHeader."Customer Posting Group" := RecRef.Field(this.IssuedReminderHeader.FieldNo("Customer Posting Group")).Value;
        SalesHeader."Gen. Bus. Posting Group" := RecRef.Field(this.IssuedReminderHeader.FieldNo("Gen. Bus. Posting Group")).Value;
        SalesHeader."VAT Bus. Posting Group" := RecRef.Field(this.IssuedReminderHeader.FieldNo("VAT Bus. Posting Group")).Value;
        SalesHeader."Reason Code" := RecRef.Field(this.IssuedReminderHeader.FieldNo("Reason Code")).Value;
        SalesHeader."Company Bank Account Code" := RecRef.Field(this.IssuedReminderHeader.FieldNo("Company Bank Account Code")).Value;
    end;

    local procedure CopyDocumentLineToSalesLine(var SalesLine: Record "Sales Line"; DocumentToCopy: Variant; DocumentLineToCopy: Variant)
    var
        RecRef: RecordRef;
        DocRecRef: RecordRef;
    begin
        DocRecRef.GetTable(DocumentToCopy);
        RecRef.GetTable(DocumentLineToCopy);

        Clear(SalesLine);
        SalesLine."Document No." := RecRef.Field(this.IssuedReminderLine.FieldNo("Reminder No.")).Value;
        SalesLine."Line No." := RecRef.Field(this.IssuedReminderLine.FieldNo("Line No.")).Value;
        SalesLine."Type" := SalesLine."Type"::"G/L Account";
        SalesLine."No." := RecRef.Field(this.IssuedReminderLine.FieldNo("No.")).Value;
        SalesLine."VAT %" := RecRef.Field(this.IssuedReminderLine.FieldNo("VAT %")).Value;
        SalesLine.Quantity := 1;
        SalesLine.Validate(Amount, RecRef.Field(this.IssuedReminderLine.FieldNo(Amount)).Value);
        SalesLine.Description := RecRef.Field(this.IssuedReminderLine.FieldNo(Description)).Value;
        SalesLine."Unit Price" := RecRef.Field(this.IssuedReminderLine.FieldNo(Amount)).Value;
        SalesLine."VAT Prod. Posting Group" := RecRef.Field(this.IssuedReminderLine.FieldNo("VAT Prod. Posting Group")).Value;
        SalesLine."VAT Bus. Posting Group" := DocRecRef.Field(this.IssuedReminderHeader.FieldNo("VAT Bus. Posting Group")).Value;
    end;

    local procedure FindNextIssuedReminderRec(var IssuedReminderHeader: Record "Issued Reminder Header"; var SalesHeader: Record "Sales Header"; Position: Integer) Found: Boolean
    begin
        if Position = 1 then
            Found := IssuedReminderHeader.Find('-')
        else
            Found := IssuedReminderHeader.Next() <> 0;
        if Found then
            this.CopyDocumentToSalesHeader(SalesHeader, IssuedReminderHeader);
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
    end;

    local procedure FindNextReminderLineRec(Position: Integer) Found: Boolean
    begin
        if Position = 1 then
            Found := this.IssuedReminderLine.Find('-')
        else
            Found := this.IssuedReminderLine.Next() <> 0;
        if Found then
            this.CopyDocumentLineToSalesLine(this.SalesLine, this.IssuedReminderHeader, this.IssuedReminderLine);
    end;

    local procedure FindNextIssuedFinChargeMemoRec(var IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header"; var SalesHeader: Record "Sales Header"; Position: Integer) Found: Boolean
    begin
        if Position = 1 then
            Found := IssuedFinChargeMemoHeader.Find('-')
        else
            Found := IssuedFinChargeMemoHeader.Next() <> 0;
        if Found then
            this.CopyDocumentToSalesHeader(SalesHeader, IssuedFinChargeMemoHeader);
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
    end;

    local procedure FindNextFinChargeMemoLineRec(Position: Integer) Found: Boolean
    begin
        if Position = 1 then
            Found := this.IssuedFinChargeMemoLine.Find('-')
        else
            Found := this.IssuedFinChargeMemoLine.Next() <> 0;
        if Found then
            this.CopyDocumentLineToSalesLine(this.SalesLine, this.IssuedFinChargeMemoHeader, this.IssuedFinChargeMemoLine);
    end;

    local procedure GetCustomizationID(): Text
    begin
        exit('urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0')
    end;

    local procedure GetProfileID(): Text
    begin
        exit('urn:fdc:peppol.eu:2017:poacc:billing:01:1.0');
    end;
}
