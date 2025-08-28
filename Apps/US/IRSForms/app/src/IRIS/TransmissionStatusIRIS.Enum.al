// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 10041 "Transmission Status IRIS"
{
    Extensible = true;

    value(0; "None") { }
    value(1; "Accepted") { }
    value(2; "Rejected") { }
    value(3; "Processing") { }
    value(4; "Partially Accepted") { }
    value(5; "Accepted with Errors") { }
    value(6; "Not Found") { }
    value(100; "Unknown") { }
}