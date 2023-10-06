// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18035 "GST Vehicle Type"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Regular)
    {
        Caption = 'Regular';
    }
    value(2; ODC)
    {
        Caption = 'ODC';
    }
}
