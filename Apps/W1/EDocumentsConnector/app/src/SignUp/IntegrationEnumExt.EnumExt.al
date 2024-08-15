// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.EServices.EDocument;

enumextension 6370 SignUpIntegrationEnumExt extends "E-Document Integration"
{
    value(6370; "ExFlow E-Invoicing")
    {
        Caption = 'ExFlow E-Invoicing';
        Implementation = "E-Document Integration" = SignUpIntegrationImpl;
    }
}