// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.B2Brouter;

enumextension 71107793 "B2Brouter Integration" extends Microsoft.eServices.EDocument.Integration."Service Integration"
{
    value(71107792; "B2Brouter")
    {
        Caption = 'B2Brouter';
        Implementation =
         Microsoft.eServices.EDocument.Integration.Interfaces.IDocumentSender = "B2Brouter Integration",
         Microsoft.eServices.EDocument.Integration.Interfaces.IDocumentReceiver = "B2Brouter Integration";
    }
}