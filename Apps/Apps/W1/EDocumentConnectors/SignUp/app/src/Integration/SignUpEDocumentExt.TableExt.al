// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.eServices.EDocument;

tableextension 6442 "SignUp E-Document Ext" extends "E-Document"
{
    fields
    {
        field(6440; "SignUp Document Id"; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'SignUp Document ID';
            ToolTip = 'Specifies document id used by ExFlow E-Invoicing';
        }
    }
}