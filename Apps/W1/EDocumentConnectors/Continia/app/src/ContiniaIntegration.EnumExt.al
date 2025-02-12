// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.Integration.Interfaces;

enumextension 6390 "Continia Integration" extends "Service Integration"
{
    value(6390; Continia)
    {
        Implementation = IDocumentSender = "Continia Integration Impl.", IDocumentReceiver = "Continia Integration Impl.";
    }
}