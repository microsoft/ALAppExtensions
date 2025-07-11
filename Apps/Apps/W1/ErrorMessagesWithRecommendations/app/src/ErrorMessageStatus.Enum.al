// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Shared.Error;
enum 7900 "Error Message Status"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Fixed)
    {
        Caption = 'Fixed';
    }
    value(2; "Failed to fix")
    {
        Caption = 'Failed to fix';
    }
}