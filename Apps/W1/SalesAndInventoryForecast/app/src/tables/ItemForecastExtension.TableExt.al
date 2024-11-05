namespace Microsoft.Inventory.InventoryForecast;

using Microsoft.Inventory.Item;
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 1854 ItemForecastExtension extends Item
{
    fields
    {
        field(21850; "Has Sales Forecast"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
            FieldClass = Normal;
        }
    }
}

