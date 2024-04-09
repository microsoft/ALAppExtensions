// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;

tableextension 31327 "Sales Header CZ" extends "Sales Header"
{
    fields
    {
        field(31305; "Physical Transfer CZ"; Boolean)
        {
            Caption = 'Physical Transfer';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Physical Transfer CZ" then
                    if not IsCreditDocType() then
                        FieldError("Document Type");
                Validate("Transaction Type", GetDefaultTransactionType());
                UpdateSalesLinesByFieldNo(FieldNo("Physical Transfer CZ"), false);
            end;
        }
        field(31310; "Intrastat Exclude CZ"; Boolean)
        {
            Caption = 'Intrastat Exclude';
            DataClassification = CustomerContent;
        }
    }

    trigger OnBeforeInsert()
    begin
        "Physical Transfer CZ" := IntrastatReportSetup.GetDefaultPhysicalTransferCZ() and IsCreditDocType();
    end;

    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        IntrastatReportManagementCZ: Codeunit IntrastatReportManagementCZ;

    procedure CheckIntrastatMandatoryFieldsCZ()
    begin
        if not (Ship or Receive) then
            exit;
        if not IntrastatReportSetup.Get() then
            exit;
        if IsIntrastatTransactionCZL() and ShipOrReceiveInventoriableTypeItemsCZL() then begin
            if IntrastatReportSetup."Transaction Type Mandatory CZ" then
                TestField("Transaction Type");
            if IntrastatReportSetup."Transaction Spec. Mandatory CZ" then
                TestField("Transaction Specification");
            if IntrastatReportSetup."Transport Method Mandatory CZ" then
                TestField("Transport Method");
            if IntrastatReportSetup."Shipment Method Mandatory CZ" then
                TestField("Shipment Method Code");
        end;
    end;

    procedure GetPartnerBasedOnSetupCZ() Customer: Record Customer
    begin
        exit(IntrastatReportManagementCZ.GetCustomerBasedOnSetup("Sell-to Customer No.", "Bill-to Customer No."));
    end;

    local procedure GetDefaultTransactionType(): Code[10]
    begin
        exit(IntrastatReportManagementCZ.GetDefaultTransactionType(Rec));
    end;
}