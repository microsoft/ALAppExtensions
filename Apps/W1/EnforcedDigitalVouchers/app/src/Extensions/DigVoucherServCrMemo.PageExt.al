// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Service.Document;

pageextension 5590 "Dig. Voucher Serv. Cr. Memo" extends "Service Credit Memo"
{
    layout
    {
        modify(IncomingDocAttachFactBox)
        {
            Visible = true;
        }
    }
}