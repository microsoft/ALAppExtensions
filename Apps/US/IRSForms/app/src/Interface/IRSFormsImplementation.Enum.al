// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 10031 "IRS Forms Implementation" implements "IRS 1099 Create Form Docs", "IRS 1099 Printing", "IRS 1099 Form Box Calc.", "IRS 1099 IRIS Transmission", "IRS 1099 IRIS Xml"
{
    Extensible = true;
    DefaultImplementation = "IRS 1099 Create Form Docs" = "IRS 1099 Form Docs Impl.",
                            "IRS 1099 Printing" = "IRS 1099 Printing Impl.",
                            "IRS 1099 Form Box Calc." = "IRS 1099 Form Box Calc. Impl.",
                            "IRS 1099 IRIS Transmission" = "IRS 1099 IRIS Impl.",
                            "IRS 1099 IRIS Xml" = "IRS 1099 IRIS Impl.";

    value(0; Standard)
    {
    }

}
