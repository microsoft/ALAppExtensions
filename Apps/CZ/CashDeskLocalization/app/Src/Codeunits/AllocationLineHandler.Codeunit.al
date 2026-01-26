// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.AllocationAccount;

codeunit 31154 "Allocation Line Handler CZP"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Allocation Line", 'OnGetOrGenerateAllocationLines', '', false, false)]
    local procedure HandleCashDocumentsOnGetOrGenerateAllocationLines(ParentTableId: Integer; ParentSystemId: Guid; var AllocationLine: Record "Allocation Line"; var AmountToAllocate: Decimal; var PostingDate: Date)
    var
        CashDocAllocAccMgtCZP: Codeunit "Cash Doc. Alloc. Acc. Mgt. CZP";
    begin
        if ParentTableId = Database::"Cash Document Line CZP" then
            CashDocAllocAccMgtCZP.GetOrGenerateAllocationLines(AllocationLine, ParentSystemId, AmountToAllocate, PostingDate);
    end;
}