// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.History;

using Microsoft.Finance.GST.Base;

tableextension 18601 "Gate Entry Return Shipment Hdr" extends "Return Shipment Header"
{
    fields
    {
        field(18601; "Vehicle No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18602; "Vehicle Type"; Enum "GST Vehicle Type")
        {
            DataClassification = EndUserIdentifiableInformation;
        }
    }
}
