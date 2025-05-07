// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Transfer;

tableextension 31348 "Direct Trans. Header CZ" extends "Direct Trans. Header"
{
    fields
    {
        field(31310; "Intrastat Exclude CZ"; Boolean)
        {
            Caption = 'Intrastat Exclude';
            DataClassification = CustomerContent;
        }
    }

    procedure IsIntrastatTransactionCZ(): Boolean
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
        IsHandled: Boolean;
        Result: Boolean;
    begin
        OnBeforeIsIntrastatTransactionCZ(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if "Intrastat Exclude CZ" then
            exit(false);

        if "Trsf.-from Country/Region Code" = "Trsf.-to Country/Region Code" then
            exit(false);

        CompanyInformation.Get();
        if "Trsf.-from Country/Region Code" in ['', CompanyInformation."Country/Region Code"] then
            exit(CountryRegion.IsIntrastat("Trsf.-to Country/Region Code", false));

        if "Trsf.-to Country/Region Code" in ['', CompanyInformation."Country/Region Code"] then
            exit(CountryRegion.IsIntrastat("Trsf.-from Country/Region Code", false));

        exit(false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsIntrastatTransactionCZ(DirectTransHeader: Record "Direct Trans. Header"; Result: Boolean; var IsHandled: Boolean)
    begin
    end;
}