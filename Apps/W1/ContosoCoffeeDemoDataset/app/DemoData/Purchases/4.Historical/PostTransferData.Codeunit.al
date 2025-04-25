// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.Inventory.Transfer;
using Microsoft.DemoData.Inventory;

codeunit 5666 "Post Transfer Data"
{
    trigger OnRun()
    var
        TransferHeader: Record "Transfer Header";
        TransferOrderPostShipment: Codeunit "TransferOrder-Post Shipment";
        TransferOrderPostReceipt: Codeunit "TransferOrder-Post Receipt";
        CreateTransferOrders: Codeunit "Create Transfer Orders";
    begin
        TransferHeader.SetFilter("External Document No.", '<>%1', CreateTransferOrders.OpenExternalDocumentNo());
        if TransferHeader.FindSet() then
            repeat
                TransferOrderPostShipment.SetHideValidationDialog(true);
                TransferOrderPostShipment.Run(TransferHeader);

                TransferOrderPostReceipt.SetHideValidationDialog(true);
                TransferOrderPostReceipt.Run(TransferHeader);
            until TransferHeader.Next() = 0;
    end;
}
