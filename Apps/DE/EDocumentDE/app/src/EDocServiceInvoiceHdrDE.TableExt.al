// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;
using Microsoft.Service.History;

tableextension 11040 "E-Doc Service Invoice Hdr DE" extends "Service Invoice Header"
{
    fields
    {
#pragma warning disable AS0125
        field(11035; "Buyer Reference"; Text[100])
        {
            Caption = 'Buyer Reference';
            DataClassification = CustomerContent;
        }
#pragma warning restore AS0125
    }
}
