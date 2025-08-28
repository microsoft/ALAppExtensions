// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 10038 "Address Type IRIS"
{
    Extensible = true;

    value(0; "USAddress") { }
    value(1; "ForeignAddress") { }
}