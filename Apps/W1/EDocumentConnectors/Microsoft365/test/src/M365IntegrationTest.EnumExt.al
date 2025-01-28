// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.Integration.Interfaces;

enumextension 148195 "M365 Integration Test" extends "Service Integration"
{
    value(148195; "TestOneDrive")
    {
        Implementation = IDocumentSender = "Drive Int. Test Impl.", IDocumentReceiver = "Drive Int. Test Impl.";
    }
    value(148196; "TestSharepoint")
    {
        Implementation = IDocumentSender = "Drive Int. Test Impl.", IDocumentReceiver = "Drive Int. Test Impl.";
    }
    value(148197; "TestOutlook")
    {
        Implementation = IDocumentSender = "Outlook Int. Test Impl.", IDocumentReceiver = "Outlook Int. Test Impl.";
    }
}