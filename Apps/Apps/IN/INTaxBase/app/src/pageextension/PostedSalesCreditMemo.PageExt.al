// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

pageextension 18562 "Posted Sales Credit Memo" extends "Posted Sales Credit Memo"
{
    layout
    {
        addafter("Invoice Details")
        {
            group("Tax Info")
            {
                Caption = 'Tax Information';
            }
        }
    }
}
