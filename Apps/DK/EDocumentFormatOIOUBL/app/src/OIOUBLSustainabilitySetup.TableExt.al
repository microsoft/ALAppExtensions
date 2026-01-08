// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Sustainability.Setup;

tableextension 13910 "OIOUBL Sustainability Setup" extends "Sustainability Setup"
{
    fields
    {
        field(13910; "Use Sustainability in E-Doc."; Boolean)
        {
            Caption = 'Use Sustainability in eInvoicing';
            ToolTip = 'Specifies whether to include sustainability information in OIOUBL e-documents.';
            DataClassification = SystemMetadata;
        }
    }
}