// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Integration.Action;

enumextension 6391 "Continia Sent Document Actions" extends "Sent Document Actions"
{
    value(6390; Continia)
    {
        Implementation = ISentDocumentActions = "Continia Integration Impl.";
    }
}