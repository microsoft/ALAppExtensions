// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18027 "GST Jurisdiction Type"
{
    value(0; Intrastate)
    {
        Caption = 'Intrastate';
    }
    value(1; Interstate)
    {
        Caption = 'Interstate';
    }
}
