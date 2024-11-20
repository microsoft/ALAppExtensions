// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Ledger;

codeunit 31177 "G/L Entry Edit Handler CZA"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"G/L Entry-Edit", 'OnBeforeGLLedgEntryModify', '', false, false)]
    local procedure ModifyFieldsOnBeforeGLLedgEntryModify(var GLEntry: Record "G/L Entry"; FromGLEntry: Record "G/L Entry")
    begin
        GLEntry."Applying Entry CZA" := FromGLEntry."Applying Entry CZA";
        GLEntry."Applies-to ID CZA" := FromGLEntry."Applies-to ID CZA";
        GLEntry.Validate("Amount to Apply CZA", FromGLEntry."Amount to Apply CZA");
    end;
}

