// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using Microsoft.EServices.EDocument;

tableextension 6386 "E-Document Extension" extends "E-Document"
{
    fields
    {
        field(6381; "Mail Message Id"; Text[2048])
        {
            DataClassification = CustomerContent;
        }
        field(6383; "Mail Message Attachment Id"; Text[2048])
        {
            DataClassification = CustomerContent;
        }
        field(6384; "Drive Item Id"; Text[2048])
        {
            DataClassification = CustomerContent;
        }
    }
}