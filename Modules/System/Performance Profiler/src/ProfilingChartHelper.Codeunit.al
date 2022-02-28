// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1926 "Profiling Chart Helper"
{
    Access = Internal;

    var
        BusinessChart: Codeunit "Business Chart";
        DurationTxt: Label 'Duration (milliseconds)';

    /// <summary>
    /// Gets the dictionary with aggregation type identifiers as keys, and aggregated self time / full time as values.
    /// </summary>
    /// <param name="ProfilingAggregationType">The aggregation type.</param>
    /// <param name="AggregateBySelfTime">True if aggregation should be performed over self time, false indicates that the aggregation should be made over full time.</param>
    /// <param name="ChartLabels">The labels for the chart.</param>
    /// <param name="ChartValues">The measure values associated with the labels.</param>
    /// <remarks>ProfilingDataProcessor must be initialized for this method to work.</remarks>
    procedure GetChartData(ProfilingAggregationType: Enum "Profiling Aggregation Type"; AggregateBySelfTime: Boolean; ChartLabels: List of [Text]; ChartValues: List of [Integer])
    var
        AggregatedProfilingNode: Record "Profiling Node";
        ProfilingDataProcessor: Codeunit "Profiling Data Processor";
        Identifier: Text;
    begin
        if AggregateBySelfTime then begin
            ProfilingDataProcessor.GetSelfTimeAggregate(AggregatedProfilingNode, ProfilingAggregationType);
            AggregatedProfilingNode.SetCurrentKey("Self Time");
        end else begin
            ProfilingDataProcessor.GetFullTimeAggregate(AggregatedProfilingNode, ProfilingAggregationType);
            AggregatedProfilingNode.SetCurrentKey("Full Time");
        end;
        AggregatedProfilingNode.Ascending(false);

        if AggregatedProfilingNode.FindSet() then
            repeat
                Identifier := ProfilingDataProcessor.GetUniqueIdentifierByAggregationType(AggregatedProfilingNode, ProfilingAggregationType);
                ChartLabels.Add(Identifier);
                if AggregateBySelfTime then
                    ChartValues.Add(AggregatedProfilingNode."Self Time")
                else
                    ChartValues.Add(AggregatedProfilingNode."Full Time")
            until AggregatedProfilingNode.Next() = 0;
    end;

    /// <summary>
    /// Updates the contents of the business chart control add-in for performance profiler charts.
    /// </summary>
    /// <param name="DotNetBusinessChartAddIn">The business chart control add-in</param>
    /// <param name="ProfilingAggregationType">The desired aggregation type for the chart.</param>
    /// <param name="BusinessChartType">The business chart type</param>
    /// <param name="AggregateBySelfTime">Specifies if the aggregation should be made over self-time or full time.</param>
    procedure UpdateData(DotNetBusinessChartAddIn: DotNet BusinessChartAddIn; ProfilingAggregationType: Enum "Profiling Aggregation Type"; BusinessChartType: Enum "Business Chart Type"; AggregateBySelfTime: Boolean)
    var
        Index: Integer;
        ChartLabels: List of [Text];
        ChartValues: List of [Integer];
    begin
        GetChartData(ProfilingAggregationType, AggregateBySelfTime, ChartLabels, ChartValues);

        BusinessChart.Initialize();
        BusinessChart.AddMeasure(DurationTxt, 1, Enum::"Business Chart Data Type"::Integer, BusinessChartType);
        BusinessChart.SetXDimension(Format(ProfilingAggregationType), Enum::"Business Chart Data Type"::String);

        for Index := 1 to ChartLabels.Count() do begin
            BusinessChart.AddDataRowWithXDimension(ChartLabels.Get(Index));
            BusinessChart.SetValue(0, Index - 1, ChartValues.Get(Index));
        end;

        BusinessChart.Update(DotNetBusinessChartAddIn);
    end;
}

