// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;
using Microsoft.eServices.EDocument;

tableextension 13915 "XRechnung-Edocument Service" extends "E-Document Service"
{
    fields
    {
        field(13914; "Buyer Reference"; Enum "E-Document Buyer Reference")
        {
            Caption = 'Buyer Reference';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the buyer reference for the document export.';
        }
        field(13915; "Buyer Reference Mandatory"; Boolean)
        {
            Caption = 'Buyer Reference Mandatory';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies whether the buyer reference is mandatory for the document.';
        }
    }
}