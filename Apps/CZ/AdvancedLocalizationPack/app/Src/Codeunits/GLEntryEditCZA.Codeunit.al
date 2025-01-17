#if not CLEAN26
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Ledger;

codeunit 31381 "G/L Entry - Edit CZA"
{
    Permissions = tabledata "G/L Entry" = rim;
    TableNo = "G/L Entry";
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';
    ObsoleteReason = 'Use the standard G/L Entry-Edit codeunit instead. The same funcionality of this codeunit is available in codeunit 31177 G/L Entry Edit Handler CZA.';

    trigger OnRun()
    begin
        GLEntry := Rec;
        GLEntry.LockTable();
        GLEntry.Find();
        GLEntry."Applies-to ID CZA" := Rec."Applies-to ID CZA";
        GLEntry.Validate("Amount to Apply CZA", Rec."Amount to Apply CZA");
        GLEntry.Modify();
        Rec := GLEntry;
    end;

    var
        GLEntry: Record "G/L Entry";
}

#endif