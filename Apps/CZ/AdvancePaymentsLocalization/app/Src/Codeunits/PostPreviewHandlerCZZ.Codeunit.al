// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Foundation.Navigate;

codeunit 31068 "Post Preview Handler CZZ"
{
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterBindSubscription', '', false, false)]
    local procedure GenJnlPostPreviewOnAfterBindSubscription()
    begin
        PostPreviewEventHandlerCZZ.ClearBuffer();
        BindSubscription(PostPreviewEventHandlerCZZ);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterUnbindSubscription', '', false, false)]
    local procedure GenJnlPostPreviewOnAfterUnbindSubscription()
    begin
        UnbindSubscription(PostPreviewEventHandlerCZZ);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterFillDocumentEntry', '', false, false)]
    local procedure PostingPreviewEventHandlerOnAfterFillDocumentEntry(var DocumentEntry: Record "Document Entry")
    begin
        PostPreviewEventHandlerCZZ.InsertAllDocumentEntry(DocumentEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterShowEntries', '', false, false)]
    local procedure PostingPreviewEventHandlerOnAfterShowEntries(TableNo: Integer)
    begin
        PostPreviewEventHandlerCZZ.ShowEntries(TableNo);
    end;

    var
        PostPreviewEventHandlerCZZ: Codeunit "Post.Preview Event Handler CZZ";
}
