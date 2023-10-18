// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18019 "GST Credit"
{
     value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Availment)
    {
        Caption = 'Availment';
    }
    value(2; "Non-Availment")
    {
        Caption = 'Non-Availment';
    }
}
