// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Tooling;

dotnet
{
    assembly("Microsoft.Dynamics.Nav.Ncl")
    {
        type("Microsoft.Dynamics.Nav.Runtime.Debugger.SamplingProfiler"; "SamplingProfiler")
        {
        }
        type("Microsoft.Dynamics.Nav.Runtime.Debugger.V8ProfileContract.CpuProfile"; "CpuProfile")
        {
        }
        type("Microsoft.Dynamics.Nav.Runtime.Debugger.V8ProfileContract.CpuProfileNode"; "CpuProfileNode")
        {
        }
        type("Microsoft.Dynamics.Nav.Runtime.Debugger.ProfilerSamplingInterval"; "ProfilerSamplingInterval")
        {
        }
    }

    assembly("Microsoft.Dynamics.Nav.Client.BusinessChart")
    {
        type("Microsoft.Dynamics.Nav.Client.BusinessChart.BusinessChartAddIn"; "BusinessChartUserControl")
        {
            IsControlAddIn = true;
        }
    }
}