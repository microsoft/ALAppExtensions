// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Sales.Document;

pageextension 5586 "Incoming Doc. Sales Order" extends "Sales Order"
{
    layout
    {
        modify(IncomingDocAttachFactBox)
        {
            Visible = true;
        }
    }
}
