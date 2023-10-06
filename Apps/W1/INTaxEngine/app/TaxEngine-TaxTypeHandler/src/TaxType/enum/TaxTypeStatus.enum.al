// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.TaxTypeHandler;

enum 20258 "Tax Type Status"
{
    Extensible = true;

    value(0; Draft)
    {
    }
    value(3; Released)
    {
    }
}
