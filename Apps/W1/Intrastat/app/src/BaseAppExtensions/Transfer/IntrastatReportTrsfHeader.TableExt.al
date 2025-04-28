// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Transfer;

tableextension 4826 "Intrastat Report Trsf. Header" extends "Transfer Header"
{
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

    procedure IsIntrastatTransaction(): Boolean
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
        IsHandled: Boolean;
        Result: Boolean;
    begin
        OnBeforeCheckIsIntrastatTransaction(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if "Trsf.-from Country/Region Code" = "Trsf.-to Country/Region Code" then
            exit(false);

        CompanyInformation.Get();

        if "Trsf.-from Country/Region Code" in ['', CompanyInformation."Country/Region Code"] then
            exit(CountryRegion.IsIntrastat("Trsf.-to Country/Region Code", false));

        if "Trsf.-to Country/Region Code" in ['', CompanyInformation."Country/Region Code"] then
            exit(CountryRegion.IsIntrastat("Trsf.-from Country/Region Code", false));

        exit(false);
    end;

    internal procedure ShipOrReceiveInventoriableTypeItems(): Boolean
    var
        TransferLine: Record "Transfer Line";
        Item: Record Item;
    begin
        TransferLine.SetRange("Document No.", "No.");
        TransferLine.SetFilter("Item No.", '<>%1', '');
        if TransferLine.FindSet() then
            repeat
                if Item.Get(TransferLine."Item No.") then
                    if ((TransferLine."Qty. to Receive" <> 0) or (TransferLine."Qty. to Ship" <> 0)) and Item.IsInventoriableType() then
                        exit(true);
            until TransferLine.Next() = 0;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCheckIsIntrastatTransaction(TransferHeader: Record "Transfer Header"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
}