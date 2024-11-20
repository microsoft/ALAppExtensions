// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.Integration.Interfaces;

enumextension 6364 "Pagero Integration" extends "Service Integration"
{
    value(6361; "Pagero")
    {
        Implementation = IDocumentSender = "Pagero Integration Impl.", IDocumentReceiver = "Pagero Integration Impl.";
    }
}