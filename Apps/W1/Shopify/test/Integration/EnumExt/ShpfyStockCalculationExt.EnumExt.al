// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;

enumextension 139560 ShpfyStockCalculationExt extends "Shpfy Stock Calculation"
{
    value(139560; "Shpfy Return Const")
    {
        Caption = 'Return Const';
        Implementation = "Shpfy Stock Calculation" = "Shpfy Const to return";
    }
}