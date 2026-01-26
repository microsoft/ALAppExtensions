// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Address;
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

    procedure IsIntrastatTransaction(): Boolean
    var
        CountryRegion: Record "Country/Region";
        IsHandled: Boolean;
        Result: Boolean;
    begin
        OnBeforeCheckIsIntrastatTransaction(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if "EU 3-Party Trade" then
            exit(false);

        exit(CountryRegion.IsIntrastat("VAT Country/Region Code", false));
    end;

    internal procedure ShipOrReceiveInventoriableTypeItems(): Boolean
    var
        ServiceLine: Record "Service Line";
    begin
        ServiceLine.Reset();
        ServiceLine.SetRange("Document Type", "Document Type");
        ServiceLine.SetRange("Document No.", "No.");
        ServiceLine.SetRange(Type, ServiceLine.Type::Item);
        if ServiceLine.FindSet() then
            repeat
                if (ServiceLine."Qty. to Ship" <> 0) and ServiceLine.IsInventoriableItem() then
                    exit(true);
            until ServiceLine.Next() = 0;
    end;

    internal procedure CheckIntrastatMandatoryFields()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        if Rec.IsTemporary() or (not IntrastatReportSetup.ReadPermission) then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        if IsIntrastatTransaction() and ShipOrReceiveInventoriableTypeItems() then begin
            if IntrastatReportSetup."Transaction Type Mandatory" then
                TestField("Transaction Type");
            if IntrastatReportSetup."Transaction Spec. Mandatory" then
                TestField("Transaction Specification");
            if IntrastatReportSetup."Transport Method Mandatory" then
                TestField("Transport Method");
            if IntrastatReportSetup."Shipment Method Mandatory" then
                TestField("Shipment Method Code");
        end;
    end;

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

        case true of
            (IntrastatReportSetup."Sales Intrastat Info Based On" = IntrastatReportSetup."Sales Intrastat Info Based On"::"Sell-to Customer") and
            (FieldNo = FieldNo("Customer No.")):
                CustomerNo := "Customer No.";
            (IntrastatReportSetup."Sales Intrastat Info Based On" = IntrastatReportSetup."Sales Intrastat Info Based On"::"Bill-to Customer") and
            (FieldNo = FieldNo("Bill-to Customer No.")):
                CustomerNo := "Bill-to Customer No.";
            else
                exit;
        end;

        if Customer.Get(CustomerNo) then begin
            Validate("Transport Method", Customer."Def. Transport Method");
            if "Document Type" = "Document Type"::"Credit Memo" then
                if Customer."Default Trans. Type - Return" <> '' then
                    Validate("Transaction Type", Customer."Default Trans. Type - Return")
                else
                    Validate("Transaction Type", IntrastatReportSetup."Default Trans. - Return")
            else
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

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCheckIsIntrastatTransaction(ServiceHeader: Record "Service Header"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
}