// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.TaxBase;

tableextension 18548 "PurchaseLineExtension" extends "Purchase Line"
{
    fields
    {
        field(18543; "Work Tax Nature Of Deduction"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18544; "State Code"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = State;
        }
    }
}
