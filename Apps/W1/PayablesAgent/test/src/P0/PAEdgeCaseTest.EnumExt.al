// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.PayablesAgent;

using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.Integration.Interfaces;

enumextension 133710 "PA Edge Case Test" extends "Service Integration"
{
    value(133710; "TestPAEdgeCases")
    {
        Implementation = IDocumentSender = "PA Edge Case Test Impl.", IDocumentReceiver = "PA Edge Case Test Impl.";
    }
}