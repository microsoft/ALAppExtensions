// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

enum 18631 "Depreciation Method"
{
    Extensible = true;
    value(0; "Straight-Line")
    {
    }
    value(1; "Declining-Balance 1")
    {
    }
    value(2; "Declining-Balance 2")
    {
    }
    value(3; "DB1/SL")
    {
    }
    value(4; "DB2/SL")
    {
    }
    value(5; "User-Defined")
    {
    }
    value(6; Manual)
    {
    }
    value(7; "BelowZero")
    {
    }
}
