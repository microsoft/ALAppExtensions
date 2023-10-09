// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

tableextension 10686 "Elec. VAT Reporting Code" extends "VAT Reporting Code"
{
    fields
    {
        field(10680; "VAT Rate For Reporting"; Decimal) { }
        field(10681; "Report VAT Rate"; Boolean) { }
    }
}
