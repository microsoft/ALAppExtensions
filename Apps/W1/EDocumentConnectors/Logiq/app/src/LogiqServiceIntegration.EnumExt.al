// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.Integration.Interfaces;

enumextension 6432 "Logiq Service Integration" extends "Service Integration"
{
    value(6432; "Logiq")
    {
        Caption = 'Logiq';
        Implementation = IDocumentSender = "Logiq Integration Impl.", IDocumentReceiver = "Logiq Integration Impl.";
    }
}