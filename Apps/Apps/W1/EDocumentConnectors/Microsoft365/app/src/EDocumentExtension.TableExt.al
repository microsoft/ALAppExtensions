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
#pragma warning disable AS0125
#pragma warning disable AS0005
        field(6381; "Outlook Mail Message Id"; Text[2048])
        {
            DataClassification = CustomerContent;
        }
        field(6383; "Outlook Message Attachment Id"; Text[2048])
        {
            DataClassification = CustomerContent;
        }
#pragma warning restore AS0125
#pragma warning restore AS0005
        field(6384; "Drive Item Id"; Text[2048])
        {
            DataClassification = CustomerContent;
        }
        field(6385; "Mail Message Id"; Guid)
        {
            DataClassification = CustomerContent;
        }
    }
}