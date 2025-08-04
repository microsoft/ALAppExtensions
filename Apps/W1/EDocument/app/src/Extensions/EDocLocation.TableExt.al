// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Location;

using Microsoft.Foundation.Reporting;

tableextension 6102 "E-Doc. Location" extends Location
{
    fields
    {
        field(6100; "Transfer Doc. Sending Profile"; Code[20])
        {
            Caption = 'Transfer Doc. Sending Profile';
            ToolTip = 'Specifies the document sending profile that is used for transfer shipment documents.';
            DataClassification = CustomerContent;
            TableRelation = "Document Sending Profile";
        }
    }
}