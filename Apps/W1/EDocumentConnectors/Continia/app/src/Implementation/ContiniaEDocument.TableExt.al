// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using Microsoft.eServices.EDocument;

tableextension 6391 "Continia E-Document" extends "E-Document"
{
    fields
    {
        field(6391; "Continia Document Id"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Continia Document Id';
            ToolTip = 'Specifies the unique identifier in the Continia Delivery Network.';
        }
    }

}