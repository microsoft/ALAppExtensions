// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Address;

tableextension 10030 "Country/Region IRS" extends "Country/Region"
{
    fields
    {
        field(10030; "IRS Country Code"; Code[2])
        {
            DataClassification = CustomerContent;
        }
    }
}