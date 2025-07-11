// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 10048 "IRS 1099 Print Params"
{
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Report Type"; Enum "IRS 1099 Form Report Type")
        {

        }
    }
}
