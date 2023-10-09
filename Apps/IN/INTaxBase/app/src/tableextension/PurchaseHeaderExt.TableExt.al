// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.TaxBase;

tableextension 18547 "Purchase Header Ext" extends "Purchase Header"
{
    fields
    {
        field(18543; "State"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = State;
        }
    }
}
