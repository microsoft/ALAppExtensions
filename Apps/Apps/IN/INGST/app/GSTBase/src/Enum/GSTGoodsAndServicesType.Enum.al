// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18022 "GST Goods And Services Type"
{
    value(0; HSN)
    {
        Caption = 'HSN';
    }
    value(1; SAC)
    {
        Caption = 'SAC';
    }
}
