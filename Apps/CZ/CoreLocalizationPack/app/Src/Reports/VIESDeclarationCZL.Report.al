// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;

report 31058 "VIES Declaration CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/VIESDeclaration.rdl';
    Caption = 'VIES Declaration';

    dataset
    {
        dataitem(CompanyInfo; "Company Information")
        {
            DataItemTableView = sorting("Primary Key");
            column(CompanyInfo_VATRegistrationNo; "VAT Registration No.")
            {
                IncludeCaption = true;
            }
            column(CompanyInfo_RegistrationNo; "Registration No.")
            {
                IncludeCaption = true;
            }
            column(CompanyInfo_TaxRegistrationNo; "Tax Registration No. CZL")
            {
                IncludeCaption = true;
            }
            dataitem(VIESDeclarationHeaderCZL; "VIES Declaration Header CZL")
            {
                column(VIESDeclarationHeader_No; "No.")
                {
                }
                column(VIESDeclarationHeader_DeclarationPeriod; Format("Declaration Period"))
                {
                }
                column(VIESDeclarationHeader_Year; Year)
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationHeader_PeriodNo; "Period No.")
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationHeader_Name; Name)
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationHeader_Name2; "Name 2")
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationHeader_CountryRegionName; "Country/Region Name")
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationHeader_County; County)
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationHeader_MunicipalityNo; "Municipality No.")
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationHeader_Street; Street)
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationHeader_HouseNo; "House No.")
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationHeader_ApartmentNo; "Apartment No.")
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationHeader_City; City)
                {
                }
                column(VIESDeclarationHeader_PostCode; "Post Code")
                {
                }
                dataitem(VIESDeclarationLineCZL; "VIES Declaration Line CZL")
                {
                    DataItemLink = "VIES Declaration No." = field("No.");
                    DataItemTableView = sorting("VAT Registration No.");
                    column(TotalValueEU3rdPartyItemSale; TotalValueEU3rdPartyItemSale)
                    {
                    }
                    column(TotalValueServiceSalSupplies; TotalValueServiceSalSupplies)
                    {
                    }
                    column(TotalValueofItemPurchSupplies; TotalValueofItemPurchSupplies)
                    {
                    }
                    column(TotalValueItemSaleSupplies; TotalValueItemSaleSupplies)
                    {
                    }
                    column(VIESDeclarationLine_VATRegistrationNo; "VAT Registration No.")
                    {
                        IncludeCaption = true;
                    }
                    column(VIESDeclarationLine_CountryRegionCode; "Country/Region Code")
                    {
                        IncludeCaption = true;
                    }
                    column(VIESDeclarationLine_TradeType; "Trade Type")
                    {
                    }
                    column(VIESDeclarationLine_RecordCode; "Record Code")
                    {
                        IncludeCaption = true;
                    }
                    column(VIESDeclarationLine_VATRegNoOriginalCust; "VAT Reg. No. of Original Cust.")
                    {
                        IncludeCaption = true;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Clear(TotalValueItemSaleSupplies);
                        Clear(TotalValueEU3rdPartyItemSale);
                        Clear(TotalValueServiceSalSupplies);
                        Clear(TotalValueofItemPurchSupplies);

                        case "Trade Type" of
                            "Trade Type"::Purchase:
                                TotalValueofItemPurchSupplies := "Amount (LCY)";
                            "Trade Type"::Sales:
                                if "EU Service" then
                                    TotalValueServiceSalSupplies := "Amount (LCY)"
                                else
                                    if "EU 3-Party Trade" then
                                        TotalValueEU3rdPartyItemSale := "Amount (LCY)"
                                    else
                                        TotalValueItemSaleSupplies := "Amount (LCY)";
                        end;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    TestField("Authorized Employee No.");
                    CompanyOfficialCZL.Get("Authorized Employee No.");
                    FormatAddress.FormatAddr(ViesDeclAddr, Name, "Name 2", '', Street, CopyStr(DelChr("House No.", '<>', ' ') +
                        DelChr("Apartment No.", '<>', ' '), 1, 50), City, "Post Code", County, CompanyInfo."Country/Region Code");
                end;
            }
        }
    }
    labels
    {
        ReportCaptionLbl = 'VIES Declaration';
        PageLbl = 'Page';
        NameAddressLbl = 'Name and Address:';
        RegistrationNosLbl = 'Registration Nos.:';
        DeclarationPeriodLbl = 'Declaration Period:';
        CountryCodeLbl = 'Country Code';
        PostCodeCityLbl = 'Post Code/City';
        TotalValueItemSaleSuppliesCaptionLbl = 'Value of Item Sale';
        TotalValueEU3rdPartyItemSaleCaptionLbl = 'Value of EU 3-Party Item Sale';
        TotalValueofItemPurchSuppliesCaptionLbl = 'Value of Item Purchase';
        TotalValueServiceSalSuppliesCaptionLbl = 'Value of Service Sale';
        SectionBLbl = 'SECTION B';
        SectionCLbl = 'SECTION C';
    }

    var
        CompanyOfficialCZL: Record "Company Official CZL";
        FormatAddress: Codeunit "Format Address";
        ViesDeclAddr: array[8] of Text[100];
        TotalValueServiceSalSupplies: Decimal;
        TotalValueItemSaleSupplies: Decimal;
        TotalValueofItemPurchSupplies: Decimal;
        TotalValueEU3rdPartyItemSale: Decimal;
}
