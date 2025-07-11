// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Preview;

codeunit 31402 "Show Preview Handler CZZ"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnBeforeShowAllEntries', '', false, false)]
    local procedure ShowAdvanceVATEntriesOnBeforeShowAllEntries(var IsHandled: Boolean; var PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler")
    var
        PreviewVAT: Page "Preview Adv. VAT Entries CZZ";
    begin
        PreviewVAT.Set(PostingPreviewEventHandler);
        PreviewVAT.Run();
        IsHandled := true;
    end;
}
