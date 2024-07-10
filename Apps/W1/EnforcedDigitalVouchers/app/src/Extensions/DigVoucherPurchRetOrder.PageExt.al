// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Purchases.Document;

pageextension 5594 "Dig. Voucher Purch. Ret. Order" extends "Purchase Return Order"
{
    layout
    {
        modify(IncomingDocAttachFactBox)
        {
            Visible = true;
        }
    }
}
