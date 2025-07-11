// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Services;

enum 18440 "GST Nature of Service"
{
    Extensible = true;
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Exempted)
    {
        Caption = 'Exempted';
    }
    value(2; Export)
    {
        Caption = 'Export';
    }
}
