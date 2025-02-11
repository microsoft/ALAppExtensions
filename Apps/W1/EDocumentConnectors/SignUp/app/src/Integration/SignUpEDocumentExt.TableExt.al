// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.eServices.EDocument;

tableextension 6382 SignUpEDocumentExt extends "E-Document"
{
    fields
    {
        field(6381; "SignUp Document Id"; Text[50])
        {
            Caption = 'SignUp Document ID';
            ToolTip = 'This value is used by ExFlow E-Invoicing';
        }
    }
}