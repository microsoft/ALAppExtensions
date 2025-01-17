// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

enum 31245 "FA History Type CZF"
{
    Extensible = true;

    value(0; " ")
    {
    }
    value(1; "FA Location")
    {
        Caption = 'FA Location';
    }
    value(2; "Responsible Employee")
    {
        Caption = 'Responsible Employee';
    }
}
