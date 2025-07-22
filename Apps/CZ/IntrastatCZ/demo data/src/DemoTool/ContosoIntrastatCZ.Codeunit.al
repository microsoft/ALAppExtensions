// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.Inventory.Intrastat;
using Microsoft.Foundation.Shipping;

codeunit 31489 "Contoso Intrastat CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Intrastat Delivery Group CZ" = rim,
        tabledata "Shipment Method" = rm,
        tabledata "Transaction Type" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertIntrastatDeliveryGroup(Code: Code[10]; Description: Text[100])
    var
        IntrastatDeliveryGroupCZ: Record "Intrastat Delivery Group CZ";
        Exists: Boolean;
    begin
        if IntrastatDeliveryGroupCZ.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        IntrastatDeliveryGroupCZ.Validate(Code, Code);
        IntrastatDeliveryGroupCZ.Validate(Description, Description);

        if Exists then
            IntrastatDeliveryGroupCZ.Modify(true)
        else
            IntrastatDeliveryGroupCZ.Insert(true);
    end;

    procedure InsertTransactionType(Code: Code[10]; Description: Text[80])
    var
        TransactionType: Record "Transaction Type";
        Exists: Boolean;
    begin
        if TransactionType.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TransactionType.Validate(Code, Code);
        TransactionType.Validate(Description, Description);

        if Exists then
            TransactionType.Modify(true)
        else
            TransactionType.Insert(true);
    end;

    internal procedure UpdateShipmentMethod(Code: Code[10]; IntrastatDeliveryGroup: Code[10])
    var
        ShipmentMethod: Record "Shipment Method";
    begin
        if not ShipmentMethod.Get(Code) then
            exit;

        ShipmentMethod.Validate("Intrastat Deliv. Grp. Code CZ", IntrastatDeliveryGroup);
        ShipmentMethod.Modify(true);
    end;
}
