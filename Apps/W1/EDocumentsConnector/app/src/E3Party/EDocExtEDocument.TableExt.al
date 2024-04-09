// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.EServices.EDocument;

tableextension 6367 "E-Doc. Ext. EDocument" extends "E-Document"
{
    fields
    {
        field(6361; "File Id"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(6362; "Filepart Id"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(6363; "Document Id"; Text[50])
        {
            DataClassification = CustomerContent;
        }
    }
}