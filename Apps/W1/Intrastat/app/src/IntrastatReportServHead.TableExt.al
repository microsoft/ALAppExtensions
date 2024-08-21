// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Sales.Customer;
using Microsoft.Service.Document;

tableextension 4816 "Intrastat Report Serv. Head." extends "Service Header"
{
    fields
    {
        modify("Customer No.")
        {
            trigger OnAfterValidate()
            begin
                UpdateIntrastatFields(FieldNo("Customer No."));
            end;
        }
        modify("Bill-to Customer No.")
        {
            trigger OnAfterValidate()
            begin
                UpdateIntrastatFields(FieldNo("Bill-to Customer No."));
            end;
        }
    }

    local procedure UpdateIntrastatFields(FieldNo: Integer)
    var
        Customer: Record Customer;
        IntrastatReportSetup: Record "Intrastat Report Setup";
        CustomerNo: Code[20];
        IsHandled: Boolean;
    begin
        OnBeforeUpdateIntrastatFields(Rec, FieldNo, IsHandled);
        if IsHandled then
            exit;

        if Rec.IsTemporary() then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        if FieldNo = FieldNo("Customer No.") then
            CustomerNo := IntrastatReportSetup.GetPartnerNo("Customer No.", "Bill-to Customer No.", IntrastatReportSetup."VAT No. Based On"::"Sell-to VAT");

        if FieldNo = FieldNo("Bill-to Customer No.") then
            CustomerNo := IntrastatReportSetup.GetPartnerNo("Customer No.", "Bill-to Customer No.", IntrastatReportSetup."VAT No. Based On"::"Bill-to VAT");

        if CustomerNo = '' then
            exit;

        if Customer.Get(CustomerNo) then begin
            Validate("Transport Method", Customer."Def. Transport Method");

            if "Document Type" = "Document Type"::"Credit Memo" then
                if Customer."Default Trans. Type - Return" <> '' then
                    Validate("Transaction Type", Customer."Default Trans. Type - Return")
                else
                    Validate("Transaction Type", IntrastatReportSetup."Default Trans. - Return");

            if "Document Type" in ["Document Type"::Invoice, "Document Type"::Order] then
                if Customer."Default Trans. Type" <> '' then
                    Validate("Transaction Type", Customer."Default Trans. Type")
                else
                    Validate("Transaction Type", IntrastatReportSetup."Default Trans. - Purchase");
        end else begin
            Validate("Transport Method", '');
            Validate("Transaction Type", '');
        end;

        OnAfterUpdateIntrastatFields(Rec, Customer, IntrastatReportSetup, FieldNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateIntrastatFields(var ServiceHeader: Record "Service Header"; FieldNo: Integer; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateIntrastatFields(var ServiceHeader: Record "Service Header"; var Customer: Record Customer; var IntrastatReportSetup: Record "Intrastat Report Setup"; FieldNo: Integer);
    begin
    end;
}