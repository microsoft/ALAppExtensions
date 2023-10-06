// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Tooling;

using System.TestLibraries.Tooling;
using System.TestLibraries.Utilities;
codeunit 135015 "Perf. Profiler Chart Test"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        PerfProfilerTestLibrary: Codeunit "Perf. Profiler Test Library";
        WrongChartLabelErr: Label 'Incorrect chart label has been set.';
        WrongChartValueErr: Label 'Incorrect chart value has been set.';

    [Test]
    procedure GetChartDataSelfTimeAggregate()
    var
        ChartLabels: List of [Text];
        ChartValues: List of [Integer];
    begin
        // [SCENARIO] Get chart data from the performance profile. Retrieve self time aggregated by app publisher

        // [GIVEN] Performance profiler is initialized with the test profile
        Initialize();

        // [WHEN] Get chart data, retrieving self time aggregated by app publisher
        PerfProfilerTestLibrary.GetChartData(Enum::"Test Prof. Aggregation Type"::"App Publisher", true, ChartLabels, ChartValues);

        // [THEN] Chart labels are "TestPublisher1" and "TestPublisher2" with respective times 1000 and 200 ms
        Assert.AreEqual('TestPublisher1', ChartLabels.Get(1), WrongChartLabelErr);
        Assert.AreEqual('TestPublisher2', ChartLabels.Get(2), WrongChartLabelErr);
        Assert.AreEqual(1000, ChartValues.Get(1), WrongChartValueErr);
        Assert.AreEqual(200, ChartValues.Get(2), WrongChartValueErr);

        PerfProfilerTestLibrary.ClearData();
    end;

    [Test]
    procedure GetChartDataFullTimeAggregate()
    var
        ChartLabels: List of [Text];
        ChartValues: List of [Integer];
    begin
        // [SCENARIO] Get chart data from the performance profile. Retrieve full time aggregated by app publisher

        // [GIVEN] Performance profiler is initialized with the test profile
        Initialize();

        // [WHEN] Get chart data, retrieving full time aggregated by app publisher
        PerfProfilerTestLibrary.GetChartData(Enum::"Test Prof. Aggregation Type"::"App Publisher", false, ChartLabels, ChartValues);

        // [THEN] Chart labels are "TestPublisher2" and "TestPublisher1" with respective times 1200 and 1100 ms
        Assert.AreEqual('TestPublisher2', ChartLabels.Get(1), WrongChartLabelErr);
        Assert.AreEqual('TestPublisher1', ChartLabels.Get(2), WrongChartLabelErr);
        Assert.AreEqual(1200, ChartValues.Get(1), WrongChartValueErr);
        Assert.AreEqual(1100, ChartValues.Get(2), WrongChartValueErr);

        PerfProfilerTestLibrary.ClearData();
    end;

    local procedure Initialize()
    begin
        PerfProfilerTestLibrary.ClearData();
        PerfProfilerTestLibrary.Initialize();
    end;
}