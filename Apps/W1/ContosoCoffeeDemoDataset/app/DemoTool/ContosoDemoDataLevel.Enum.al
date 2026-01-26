// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool;

enum 5123 "Contoso Demo Data Level"
{
    Extensible = false;
    // The value of the enum needs to follow the layering of the data. e.g. All > "Setup Data" > " "

    value(0; " ")
    {
    }
    value(1; "Setup Data")
    {
        Caption = 'Setup Data';
    }
    value(2; "Master Data")
    {
        Caption = 'Master Data';
    }
    value(3; "Transactional Data")
    {
        Caption = 'Transactional Data';
    }
    value(4; "Historical Data")
    {
        Caption = 'Historical Data';
    }
    value(10; All)
    {
        Caption = 'All';
    }
}
