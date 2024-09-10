// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.EServices.EDocument;

tableextension 96367 "E-Doc. TE Ext. EDocument" extends "E-Document"
{
    fields
    {
        field(96360; "Bill-to/Pay-to Id"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(96361; "Message Id"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(96362; "Message Profile Id"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(96363; "Message Document Id"; Text[200])
        {
            DataClassification = CustomerContent;
        }
        field(96364; "Receiving Company Id"; Text[50])
        {
            DataClassification = CustomerContent;
        }
    }
}