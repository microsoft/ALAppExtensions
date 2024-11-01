// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;

enumextension 6370 Integration extends "E-Document Integration"
{
    value(6370; "Avalara")
    {
        Implementation = Sender = "Integration Impl.", Receiver = "Integration Impl.", "Default Int. Actions" = "Integration Impl.";
    }
}