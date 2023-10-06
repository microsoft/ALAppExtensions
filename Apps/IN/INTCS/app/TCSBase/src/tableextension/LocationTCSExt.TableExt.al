// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Location;

using Microsoft.Finance.TCS.TCSBase;

tableextension 18809 "LocationTCSExt" extends Location
{
    fields
    {
        field(18807; "T.C.A.N. No."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "T.C.A.N. No.";
        }
    }
}
