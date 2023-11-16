// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

codeunit 31477 "Direct Trans. Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Direct Trans. Line", 'OnAfterCopyFromTransferLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyFromTransferLine(var DirectTransLine: Record "Direct Trans. Line"; TransferLine: Record "Transfer Line")
    begin
        DirectTransLine."Tariff No. CZL" := TransferLine."Tariff No. CZL";
#if not CLEAN22
#pragma warning disable AL0432
        DirectTransLine."Statistic Indication CZL" := TransferLine."Statistic Indication CZL";
        DirectTransLine."Country/Reg. of Orig. Code CZL" := TransferLine."Country/Reg. of Orig. Code CZL";
#pragma warning restore AL0432
#endif
    end;
}
