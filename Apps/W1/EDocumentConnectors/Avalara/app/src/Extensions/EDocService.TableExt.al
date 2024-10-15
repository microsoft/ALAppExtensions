// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

using Microsoft.eServices.EDocument;

tableextension 6370 "E-Doc. Service" extends "E-Document Service"
{
    fields
    {
        field(6360; "Avalara Mandate"; Code[50])
        {
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }
}