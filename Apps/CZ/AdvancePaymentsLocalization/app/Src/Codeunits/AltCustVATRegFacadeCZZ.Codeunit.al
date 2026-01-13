// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Sales.Customer;

codeunit 11730 "Alt. Cust. VAT Reg. Facade CZZ"
{
    Access = Public;

    var
        AltCustVATRegOrchCZZ: Codeunit "Alt. Cust. VAT Reg. Orch. CZZ";

    procedure UpdateSetupOnVATCountryChangeInSalesAdvLetterHeader(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        AltCustVATRegOrchCZZ.GetAltCustVATRegDocImpl().UpdateSetupOnVATCountryChangeInSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ, xSalesAdvLetterHeaderCZZ);
    end;

    procedure Init(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        AltCustVATRegOrchCZZ.GetAltCustVATRegDocImpl().Init(SalesAdvLetterHeaderCZZ, xSalesAdvLetterHeaderCZZ);
    end;

    procedure UpdateVATRegNoInCustFromSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; Customer: Record Customer) ShouldUpdate: Boolean
    var
        IsHandled: Boolean;
    begin
        OnBeforeUpdateVATRegNoInCustFromSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ, Customer, ShouldUpdate, IsHandled);
        if IsHandled then
            exit(ShouldUpdate);
        exit((Customer."VAT Registration No." = '') and (not SalesAdvLetterHeaderCZZ."Alt. VAT Registration No."));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateVATRegNoInCustFromSalesAdvLetterHeader(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; Customer: Record Customer; var ShouldUpdate: Boolean; var IsHandled: Boolean)
    begin
    end;
}