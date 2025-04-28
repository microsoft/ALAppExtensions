#if not CLEAN26
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

using Microsoft.Foundation.Company;

tableextension 11798 "Country/Region CZL" extends "Country/Region"
{
    [Obsolete('Pending removal. Use IsIntrastat from Intrastat Core extension instead.', '26.0')]
    procedure IsIntrastatCZL(CountryRegionCode: Code[10]; ShipTo: Boolean): Boolean
    var
        CompanyInformation: Record "Company Information";
    begin
        if CountryRegionCode = '' then
            exit(false);

        Get(CountryRegionCode);
        if "Intrastat Code" = '' then
            exit(false);

        CompanyInformation.Get();
        if ShipTo then
            exit(CountryRegionCode <> CompanyInformation."Ship-to Country/Region Code");
        exit(CountryRegionCode <> CompanyInformation."Country/Region Code");
    end;

    [Obsolete('Pending removal. Use IsLocalCountry from Intrastat Core extension instead.', '26.0')]
    procedure IsLocalCountryCZL(CountryRegionCode: Code[10]; ShipTo: Boolean): Boolean
    var
        CompanyInformation: Record "Company Information";
    begin
        if CountryRegionCode = '' then
            exit(true);

        CompanyInformation.Get();
        if ShipTo then
            exit(CountryRegionCode = CompanyInformation."Ship-to Country/Region Code");
        exit(CountryRegionCode = CompanyInformation."Country/Region Code");
    end;
}
#endif