// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Journal;

codeunit 31438 "Std. Item Journal Handler CZA"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Report, Report::"Save as Standard Item Journal", 'OnBeforeInsertStandardItemJournalLine', '', false, false)]
    local procedure ClearNewLocationOnBeforeInsertStandardItemJournalLine(var StdItemJnlLine: Record "Standard Item Journal Line"; ItemJnlLine: Record "Item Journal Line")
    begin
        if ItemJnlLine."Entry Type" <> ItemJnlLine."Entry Type"::Transfer then
            StdItemJnlLine."New Location Code CZA" := '';
    end;
}
