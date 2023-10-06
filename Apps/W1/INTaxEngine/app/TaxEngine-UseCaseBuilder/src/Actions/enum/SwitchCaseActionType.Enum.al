// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.UseCaseBuilder;

enum 20283 "Switch Case Action Type"
{
    Extensible = true;
    value(0; Lookup) { }
    value(1; Relation) { }
    value(3; "Insert Record") { }
}
