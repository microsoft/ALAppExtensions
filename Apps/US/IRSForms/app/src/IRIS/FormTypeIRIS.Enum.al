// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 10040 "Form Type IRIS"
{
    Extensible = true;

    value(1; "DIV") { }
    value(2; "INT") { }
    value(3; "MISC") { }
    value(4; "NEC") { }
}