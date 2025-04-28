// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.Inventory.Transfer;
using Microsoft.DemoTool.Helpers;

codeunit 5381 "Create Transfer Orders"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        TransferHeader: Record "Transfer Header";
        ContosoInventory: Codeunit "Contoso Inventory";
        CreateItem: Codeunit "Create Item";
        CreateLocation: Codeunit "Create Location";
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        TransferHeader := ContosoInventory.InsertTransferHeader(CreateLocation.MainLocation(), CreateLocation.WestLocation(), ContosoUtilities.AdjustDate(19030401D), CreateLocation.OutLogLocation(), '');
        ContosoInventory.InsertTransferLine(TransferHeader, CreateItem.MexicoSwivelChairBlack(), 1, 1);

        TransferHeader := ContosoInventory.InsertTransferHeader(CreateLocation.WestLocation(), CreateLocation.EastLocation(), ContosoUtilities.AdjustDate(19030401D), CreateLocation.OwnLogLocation(), OpenExternalDocumentNo());
        ContosoInventory.InsertTransferLine(TransferHeader, CreateItem.MexicoSwivelChairBlack(), 3, 3);

        TransferHeader := ContosoInventory.InsertTransferHeader(CreateLocation.EastLocation(), CreateLocation.MainLocation(), ContosoUtilities.AdjustDate(19030401D), CreateLocation.OwnLogLocation(), OpenExternalDocumentNo());
        ContosoInventory.InsertTransferLine(TransferHeader, CreateItem.MexicoSwivelChairBlack(), 2, 1);
    end;

    procedure OpenExternalDocumentNo(): Code[35]
    begin
        exit(OpenExternalDocumentNoTok);
    end;

    var
        OpenExternalDocumentNoTok: Label 'OPEN', MaxLength = 35;
}
