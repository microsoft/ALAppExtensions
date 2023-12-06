// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Transfer;

tableextension 31329 "Transfer Header CZ" extends "Transfer Header"
{
    fields
    {
        field(31310; "Intrastat Exclude CZ"; Boolean)
        {
            Caption = 'Intrastat Exclude';
            DataClassification = CustomerContent;
        }
    }

    procedure CheckIntrastatMandatoryFieldsCZ()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
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
}