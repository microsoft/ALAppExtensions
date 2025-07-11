// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Ledger;

codeunit 31145 "VAT Amount Line Handler CZZ"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"VAT Amount Line", 'OnCopyDocumentVATEntriesToBufferOnAfterSetVATEntryFilterCZL', '', false, false)]
    local procedure SkipAdvanceLetterVATEntriesOnCopyDocumentVATEntriesToBufferOnAfterSetVATEntryFilterCZL(var VATEntry: Record "VAT Entry")
    begin
        VATEntry.SetRange("Advance Letter No. CZZ", '');
    end;
}