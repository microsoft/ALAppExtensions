// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.Purchases.Vendor;
using Microsoft.DemoData.Foundation;

codeunit 10516 "Create Vendor Template US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Templ.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Vendor Templ."; RunTrigger: Boolean)
    var
        CreateVendorTemplate: Codeunit "Create Vendor Template";
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        case Rec.Code of
            CreateVendorTemplate.VendorCompany():
                ValidateRecordFields(Rec, CreateCountryRegion.US(), false, '');
            CreateVendorTemplate.VendorPerson():
                ValidateRecordFields(Rec, CreateCountryRegion.US(), false, '');
        end;
    end;

    local procedure ValidateRecordFields(var VendorTempl: Record "Vendor Templ."; CountryRegionCode: Code[10]; PricesIncludingVAT: Boolean; VATBusPostingGroup: Code[20])
    begin
        VendorTempl.Validate("Country/Region Code", CountryRegionCode);
        VendorTempl.Validate("Prices Including VAT", PricesIncludingVAT);
        VendorTempl.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        VendorTempl.Validate("Bank Communication", VendorTempl."Bank Communication"::"E English");
        VendorTempl.Validate("FATCA filing requirement", false);
        VendorTempl.Validate("Tax Identification Type", VendorTempl."Tax Identification Type"::"Legal Entity")
    end;
}
