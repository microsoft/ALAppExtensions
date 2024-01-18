// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

enum 11740 "EET Cash Register Type CZL" implements "EET Cash Register CZL"
{
    Extensible = true;

    value(0; Default)
    {
        Caption = 'Default';
        Implementation = "EET Cash Register CZL" = "EET Cash Register Default CZL";
    }
}
