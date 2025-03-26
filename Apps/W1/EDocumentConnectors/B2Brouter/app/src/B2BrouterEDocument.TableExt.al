// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.B2Brouter;
using Microsoft.EServices.EDocument;

tableextension 6490 "B2Brouter E-Document" extends "E-Document"
{
    fields
    {
        field(6490; "B2Brouter File Id"; Integer)
        {
            Caption = 'File Id';
            DataClassification = CustomerContent;
        }
    }
}