// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Integration;

enumextension 6391 IntegrationV2 extends "Service Integration"
{
    value(6390; "Tietoevry")
    {
        Implementation = IDocumentSender = "Integration Impl.", IDocumentReceiver = "Integration Impl.";
    }
}