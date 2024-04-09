// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Inventory.Item.Catalog;

enumextension 31260 "Nonstock Item No. Format CZA" extends "Nonstock Item No. Format"
{
    value(31260; "Item No. Series CZA")
    {
        Caption = 'Item No. Series (Obsolete)';
        ObsoleteState = Pending;
        ObsoleteReason = 'Replaced by standard "Item No. Series"';
        ObsoleteTag = '22.0';
    }
}
#endif
