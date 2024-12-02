// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using Microsoft.eServices.EDocument;

tableextension 6390 "E-Document" extends "E-Document"
{
    fields
    {
        field(6390; "Bill-to/Pay-to Id"; Text[100])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6391; "Tietoevry Document Id"; Text[50])
        {
            DataClassification = SystemMetadata;
        }
        field(6392; "Message Profile Id"; Text[50])
        {
            DataClassification = SystemMetadata;
        }
        field(6393; "Message Document Id"; Text[200])
        {
            DataClassification = SystemMetadata;
        }
    }
}