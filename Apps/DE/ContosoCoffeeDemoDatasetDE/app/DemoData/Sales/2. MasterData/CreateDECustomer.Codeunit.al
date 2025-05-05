// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.Sales.Customer;
using Microsoft.DemoData.Foundation;

codeunit 11108 "Create DE Customer"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    //TODO -Hard coded values pending to replace - Post Code,Vat Registration No

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsert', '', false, false)]
    local procedure OnBeforeInsertCustomer(var Customer: Record Customer)
    var
        CreateLanguage: Codeunit "Create Language";
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        CreateCustomer: Codeunit "Create Customer";
    begin
        case Customer."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateCustomer(Customer, CreateLanguage.DEU(), CreatePaymentTerms.PaymentTermsDAYS14(), '', '48436', '789456278', DomesticAdatumCorporationCityLbl);
            CreateCustomer.DomesticTreyResearch():
                ValidateCustomer(Customer, CreateLanguage.DEU(), CreatePaymentTerms.PaymentTermsDAYS14(), '', '80997', '254687456', DomesticTreyResearchCityLbl);
            CreateCustomer.ExportSchoolofArt():
                ValidateCustomer(Customer, CreateLanguage.ENU(), CreatePaymentTerms.PaymentTermsCM(), '', 'FL 37125', '733495789', ExportSchoolofArtCityLbl);
            CreateCustomer.EUAlpineSkiHouse():
                ValidateCustomer(Customer, CreateLanguage.ENG(), CreatePaymentTerms.PaymentTermsDAYS14(), CreateCountryRegion.GB(), 'B68 5TT', '609458790', EUAlpineSkiHouseCityLbl);
            CreateCustomer.DomesticRelecloud():
                ValidateCustomer(Customer, CreateLanguage.DEU(), CreatePaymentTerms.PaymentTermsDAYS14(), '', '20097', '582048936', DomesticRelecloudCityLbl);
        end;
    end;

    local procedure ValidateCustomer(var Customer: Record Customer; LanguageCode: Code[10]; PaymentTermCode: Code[10]; CountryRegionCode: Code[10]; PostCode: Code[20]; VatRegistraionNo: Text[20]; City: Text[30])
    begin
        Customer."Format Region" := ''; // Format Region will be automatically set basing on the Language Code
        Customer.Validate("Language Code", LanguageCode);
        Customer.Validate("Payment Terms Code", PaymentTermCode);
        Customer.Validate("VAT Registration No.", VatRegistraionNo);
        Customer.Validate("Post Code", PostCode);
        Customer.Validate(City, City);
        if CountryRegionCode <> '' then
            Customer."Country/Region Code" := CountryRegionCode;
    end;

    var
        DomesticAdatumCorporationCityLbl: Label 'Dusseldorf', MaxLength = 30;
        DomesticTreyResearchCityLbl: Label 'Munchen', MaxLength = 30;
        ExportSchoolofArtCityLbl: Label 'Miami', MaxLength = 30;
        EUAlpineSkiHouseCityLbl: Label 'Bromsgrove', MaxLength = 30;
        DomesticRelecloudCityLbl: Label 'Hamburg', MaxLength = 30;

}
