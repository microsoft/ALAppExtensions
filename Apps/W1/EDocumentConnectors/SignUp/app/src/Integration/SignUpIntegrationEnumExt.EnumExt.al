// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.Integration.Interfaces;

enumextension 6440 "SignUp Integration Enum Ext" extends "Service Integration"
{
    value(6440; "ExFlow E-Invoicing")
    {
        Caption = 'ExFlow E-Invoicing';
        Implementation = IDocumentSender = "SignUp Integration Impl.", IDocumentReceiver = "SignUp Integration Impl.";
    }
}