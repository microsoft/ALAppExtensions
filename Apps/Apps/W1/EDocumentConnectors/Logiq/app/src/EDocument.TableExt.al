// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

using Microsoft.eServices.EDocument;

tableextension 6430 "E-Document" extends "E-Document"
{
    fields
    {
        field(6430; "Logiq External Document Id"; Text[50])
        {
            Caption = 'External Document Id';
            DataClassification = SystemMetadata;
            Editable = false;
            ToolTip = 'Specifies document id in Logiq system';
        }
    }
}
