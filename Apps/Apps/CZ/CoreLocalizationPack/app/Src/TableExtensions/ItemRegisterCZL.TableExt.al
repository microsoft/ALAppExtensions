// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Ledger;

tableextension 31044 "Item Register CZL" extends "Item Register"
{
    procedure FindByEntryNoCZL(EntryNo: Integer): Boolean
    begin
        SetFilter("From Entry No.", '..%1', EntryNo);
        SetFilter("To Entry No.", '%1..', EntryNo);
        exit(FindFirst());
    end;
}
