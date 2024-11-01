// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.EServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;

enumextension 6363 "E-Doc. Ext. Integration" extends "E-Document Integration"
{
    value(6361; "Pagero")
    {
        Implementation = Sender = "Pagero Integration Impl.", Receiver = "Pagero Integration Impl.", "Default Int. Actions" = "Pagero Integration Impl.";
    }
}