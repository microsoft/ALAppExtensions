// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.eServices.EDocument.Integration.Action;
using Microsoft.eServices.EDocument.Integration.Interfaces;

enumextension 6365 "Pagero Actions" extends "Sent Document Actions"
{
    value(6361; "Pagero")
    {
        Implementation = ISentDocumentActions = "Pagero Integration Impl.";
    }
}