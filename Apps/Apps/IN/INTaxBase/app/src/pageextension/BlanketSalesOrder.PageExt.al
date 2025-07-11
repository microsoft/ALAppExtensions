// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

pageextension 18559 "Blanket Sales Order" extends "Blanket Sales Order"
{
    layout
    {
        addafter("Foreign Trade")
        {
            group("Tax Info")
            {
                Caption = 'Tax Information';
            }
        }
    }
}
