// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using Microsoft.Inventory.Item;

codeunit 139562 "Shpfy Const to Return" implements "Shpfy Stock Calculation"
{
    var
        ConsttoReturn: Decimal;

    procedure GetStock(var Item: Record Item): Decimal;
    begin
        exit(ConsttoReturn);
    end;

    internal procedure SetConstToReturn(NewConst: Decimal)
    begin
        ConsttoReturn := NewConst;
    end;

}