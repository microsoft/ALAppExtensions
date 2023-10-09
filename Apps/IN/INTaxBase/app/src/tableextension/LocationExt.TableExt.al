// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Location;

using Microsoft.Finance.TaxBase;


tableextension 18546 "LocationExt" extends Location
{
    fields
    {
        field(18543; "State Code"; Code[10])
        {
            TableRelation = "State";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18544; "T.A.N. No."; Code[10])
        {
            TableRelation = "TAN Nos.";
            DataClassification = EndUserIdentifiableInformation;
        }
    }
}
