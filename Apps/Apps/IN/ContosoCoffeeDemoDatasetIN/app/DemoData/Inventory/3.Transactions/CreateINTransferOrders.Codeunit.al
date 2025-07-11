// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.Inventory.Transfer;
using Microsoft.DemoTool.Helpers;

codeunit 19064 "Create IN Transfer Orders"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        TransferHeader: Record "Transfer Header";
        ContosoInventory: Codeunit "Contoso Inventory";
        CreateItem: Codeunit "Create Item";
        CreateLocation: Codeunit "Create Location";
        CreateINLocation: Codeunit "Create IN Location";
        CreateTransferOrder: Codeunit "Create Transfer Orders";
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        TransferHeader := ContosoInventory.InsertTransferHeader(CreateINLocation.RedLocation(), CreateINLocation.BlueLocation(), ContosoUtilities.AdjustDate(19030126D), CreateLocation.OwnLogLocation(), CreateTransferOrder.OpenExternalDocumentNo());
        ContosoInventory.InsertTransferLine(TransferHeader, CreateItem.BerlingGuestChairYellow(), 1, 1);
        ContosoInventory.InsertTransferLine(TransferHeader, CreateItem.MexicoSwivelChairBlack(), 1, 1);
        UpdateTransferPriceGST(TransferHeader."No.", 10000, 100);
        UpdateTransferPriceGST(TransferHeader."No.", 20000, 100);
    end;

    local procedure UpdateTransferPriceGST(DocumentNo: Code[20]; LineNo: Integer; TransferPrice: Decimal)
    var
        TransLine: Record "Transfer Line";
    begin
        if TransLine.Get(DocumentNo, LineNo) then begin
            TransLine.Validate("Transfer Price", TransferPrice);
            TransLine.Modify(true);
        end;
    end;
}
