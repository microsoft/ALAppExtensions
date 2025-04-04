// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Location;

using Microsoft.Foundation.Reporting;

tableextension 6101 "E-Document Location" extends Location
{
    fields
    {
        field(6100; "E-Document Sending Profile"; Code[10])
        {
            Caption = 'Document Sending Profile';
            ToolTip = 'The document sending profile to use for this location.';
            DataClassification = CustomerContent;
            TableRelation = "Document Sending Profile";
        }
    }
}
