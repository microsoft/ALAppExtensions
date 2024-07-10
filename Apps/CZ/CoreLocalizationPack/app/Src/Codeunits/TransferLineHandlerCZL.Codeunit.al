// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

using Microsoft.Inventory.Item;

codeunit 31046 "Transfer Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure CopyFromItemOnAfterAssignItemValues(var TransferLine: Record "Transfer Line"; Item: Record Item)
    begin
        TransferLine."Tariff No. CZL" := Item."Tariff No.";
    end;
}
