// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.PowerBIReports.Test;

enum 139792 "PowerBI Filter Scenarios"
{
    value(1; "Sales Date")
    {
        Caption = 'Sales Date';
    }
    value(2; "Manufacturing Date")
    {
        Caption = 'Manufacturing Date';
    }
    value(3; "Manufacturing Date Time")
    {
        Caption = 'Manufacturing Date Time';
    }
    value(4; "Project Date")
    {
        Caption = 'Project Date';
    }
    value(5; "Purchases Date")
    {
        Caption = 'Purchases Date';
    }
    value(6; "Finance Date")
    {
        Caption = 'Finance Date';
    }
#if not CLEAN27
    value(7; "Sustainability Date")
    {
        Caption = 'Sustainability Date';
        ObsoleteReason = 'Unused, tests for the configured filter in the sustainability tests app.';
        ObsoleteState = Pending;
        ObsoleteTag = '27.0';
    }
#endif
}