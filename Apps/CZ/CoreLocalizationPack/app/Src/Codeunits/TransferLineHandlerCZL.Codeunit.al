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
#if not CLEAN22
#pragma warning disable AL0432
        TransferLine."Statistic Indication CZL" := Item."Statistic Indication CZL";
        TransferLine."Country/Reg. of Orig. Code CZL" := Item."Country/Region of Origin Code";
#pragma warning restore AL0432
#endif
    end;
}
