// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.EServices.EDocument;

tableextension 6382 "E-Doc. TE Ext. EDocument" extends "E-Document"
{
    fields
    {
        field(6380; "Bill-to/Pay-to Id"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(6381; "Message Id"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(6382; "Message Profile Id"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(6383; "Message Document Id"; Text[200])
        {
            DataClassification = CustomerContent;
        }
        field(6384; "Receiving Company Id"; Text[100])
        {
            DataClassification = CustomerContent;
        }
    }
}