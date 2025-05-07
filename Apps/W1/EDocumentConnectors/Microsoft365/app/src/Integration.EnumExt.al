// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.Integration.Interfaces;

enumextension 6381 "Integration" extends "Service Integration"
{
    value(6381; "OneDrive")
    {
        Implementation = IDocumentSender = "Drive Integration Impl.", IDocumentReceiver = "Drive Integration Impl.", IConsentManager = "Drive Integration Impl.";
    }
    value(6382; "SharePoint")
    {
        Implementation = IDocumentSender = "Drive Integration Impl.", IDocumentReceiver = "Drive Integration Impl.", IConsentManager = "Drive Integration Impl.";
    }
    value(6383; "Outlook")
    {
        Implementation = IDocumentSender = "Outlook Integration Impl.", IDocumentReceiver = "Outlook Integration Impl.", IConsentManager = "Drive Integration Impl.";
    }
}