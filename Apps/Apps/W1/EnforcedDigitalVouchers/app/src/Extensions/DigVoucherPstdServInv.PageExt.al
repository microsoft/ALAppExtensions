// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Service.History;

pageextension 5591 "Dig. Voucher Pstd. Serv. Inv." extends "Posted Service Invoice"
{
    layout
    {
        modify(IncomingDocAttachFactBox)
        {
            Visible = true;
        }
    }
}