// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.TaxTypeHandler;

enum 20232 "Transaction Value Type"
{
    Extensible = true;

    value(0; " ") { }
    value(1; ATTRIBUTE) { }
    value(2; COMPONENT) { }
    value(3; COLUMN) { }
    value(4; "COMPONENT PERCENT") { }
}
