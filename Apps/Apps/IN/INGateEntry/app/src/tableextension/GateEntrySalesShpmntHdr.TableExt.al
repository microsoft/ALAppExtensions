// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

tableextension 18604 "Gate Entry Sales Shpmnt Hdr" extends "Sales Shipment Header"
{
    fields
    {
        field(18601; "LR/RR No."; code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18602; "LR/RR Date"; Date)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
    }
}
