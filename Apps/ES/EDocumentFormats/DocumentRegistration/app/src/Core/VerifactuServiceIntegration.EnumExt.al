// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Verifactu;

using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.Integration.Interfaces;

enumextension 10777 "Verifactu Service Integration" extends "Service Integration"
{
    value(10779; "Verifactu Service")
    {
        Implementation = IDocumentSender = "Verifactu Sender",
                        IDocumentReceiver = "Verifactu Sender";
        Caption = 'Verifactu Service';
    }
}