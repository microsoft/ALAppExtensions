// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes methods from "Profiling Data Processor" and "Profiling Chart Helper" codeunits
/// </summary>
codeunit 135104 "Perf. Profiler Test Library"
{
    var
        ProfilingDataProcessor: Codeunit "Profiling Data Processor";

    /// <summary>
    /// Initializes the profiling data processor with the test profiling data.
    /// </summary>
    procedure Initialize()
    var
        RawProfilingNode: Record "Profiling Node";
        CallTreeProfilingNode: Record "Profiling Node";
        SamplingPerformanceProfiler: Codeunit "Sampling Performance Profiler";
        TempBlob: Codeunit "Temp Blob";
        SetDataInStr: InStream;
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr);
        OutStr.Write(GetTestPerformanceProfile());
        TempBlob.CreateInStream(SetDataInStr);

        SamplingPerformanceProfiler.SetData(SetDataInStr);
        SamplingPerformanceProfiler.GetProfilingNodes(RawProfilingNode);
        SamplingPerformanceProfiler.GetProfilingCallTree(CallTreeProfilingNode);
        ProfilingDataProcessor.Initialize(RawProfilingNode, CallTreeProfilingNode);
    end;

    /// <summary>
    /// Initializes the profiling data processor with the profiling data.
    /// </summary>
    /// <param name="RawProfilingNode">The performance profiling data.</param>
    /// <remarks>The data processor will reference the provided data, not copy it.</remarks>
    procedure Initialize(var RawProfilingNode: Record "Profiling Node"; var CallTreeProfilingNode: Record "Profiling Node")
    begin
        ProfilingDataProcessor.Initialize(RawProfilingNode, CallTreeProfilingNode);
    end;

    /// <summary>
    /// Clears the previously initialized performance profiling data.
    /// </summary>
    procedure ClearData();
    var
        SamplingPerformanceProfiler: Codeunit "Sampling Performance Profiler";
        EmptyTempBlob: Codeunit "Temp Blob";
        InStr: InStream;
    begin
        EmptyTempBlob.CreateInStream(InStr);
        SamplingPerformanceProfiler.SetData(InStr);
        ProfilingDataProcessor.ClearData();
    end;

    /// <summary>
    /// Checks if the profiling data processor is initialized with <see cref="Initialize"/> method.
    /// </summary>
    /// <returns>True, if the profiling data processor is initialized, false otherwise.</returns>
    procedure IsInitialized(): Boolean
    begin
        exit(ProfilingDataProcessor.IsInitialized());
    end;

    /// <summary>
    /// Gets aggregate self time of profiling nodes using the provided aggregation type.
    /// </summary>
    /// <param name="AggregatedProfilingNode">The resulting aggregation.</param>
    /// <param name="ProfilingAggregationType">The value of what to aggregate self time by.</param>
    procedure GetSelfTimeAggregate(var AggregatedProfilingNode: Record "Profiling Node"; ProfilingAggregationType: Enum "Profiling Aggregation Type")
    begin
        ProfilingDataProcessor.GetSelfTimeAggregate(AggregatedProfilingNode, ProfilingAggregationType);
    end;

    /// <summary>
    /// Gets aggregate self time of profiling nodes using the provided aggregation type.
    /// </summary>
    /// <param name="AggregatedProfilingNode">The resulting aggregation.</param>
    /// <param name="ProfilingAggregationType">The value of what to aggregate self time by.</param>
    /// <param name="FilterText">The table view to indicate which profiling nodes should be included in aggregation.</param>
    procedure GetSelfTimeAggregate(var AggregatedProfilingNode: Record "Profiling Node"; ProfilingAggregationType: Enum "Profiling Aggregation Type"; FilterText: text)
    begin
        ProfilingDataProcessor.GetSelfTimeAggregate(AggregatedProfilingNode, ProfilingAggregationType, FilterText);
    end;

    /// <summary>
    /// Gets aggregate full time of profiling nodes using the provided aggregation type.
    /// </summary>
    /// <param name="AggregatedProfilingNode">The resulting aggregation.</param>
    /// <param name="ProfilingAggregationType">The value of what to aggregate full time by.</param>
    procedure GetFullTimeAggregate(var AggregatedProfilingNode: Record "Profiling Node"; ProfilingAggregationType: Enum "Profiling Aggregation Type")
    begin
        ProfilingDataProcessor.GetFullTimeAggregate(AggregatedProfilingNode, ProfilingAggregationType);
    end;

    /// <summary>
    /// Constructs and returns a unique string (with respect to aggregation type) from the provided profiling node.
    /// </summary>
    /// <param name="ProfilingNode">The node from which to construct a unique identifier.</param>
    /// <param name="ProfilingAggregationType">The aggregation type.</param>
    /// <returns>A unique (per aggregation type) string from the provided profiling node.</returns>
    procedure GetUniqueIdentifierByAggregationType(ProfilingNode: Record "Profiling Node"; ProfilingAggregationType: Enum "Profiling Aggregation Type"): Text
    begin
        exit(ProfilingDataProcessor.GetUniqueIdentifierByAggregationType(ProfilingNode, ProfilingAggregationType));
    end;

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
        ProfilingChartHelper: Codeunit "Profiling Chart Helper";
    begin
        ProfilingChartHelper.GetChartData(ProfilingAggregationType, AggregateBySelfTime, ChartLabels, ChartValues);
    end;

    /// <summary>
    /// Gets a test performance profile.
    /// </summary>
    /// <returns>A test performance profile.</returns>
    procedure GetTestPerformanceProfile(): Text
    var
        TextPerfProfileTextBuilder: TextBuilder;
    begin
        TextPerfProfileTextBuilder.Append('{"nodes":[{"id":1,"callFrame":{"functionName":"TestNode1FunctionName","scriptId":"CodeUnit_1","url":"TestNode1","lineNumber":0,"columnNumber":0},"hitCount":1,"children":[2],"declar');
        TextPerfProfileTextBuilder.Append('ingApplication":{"appName":"TestNode1App","appPublisher":"TestPublisher1","appVersion":"0.0.0.0"},"applicationDefinition":{"objectType":"CodeUnit","objectName":"CodeUnit_TestNode1"');
        TextPerfProfileTextBuilder.Append(',"objectId":1}},{"id":2,"callFrame":{"functionName":"TestNode2FunctionName","scriptId":"CodeUnit_2","url":"TestNode2","lineNumber":0,"columnNumber":0},"hitCount":1,"children":[3],"');
        TextPerfProfileTextBuilder.Append('declaringApplication":{"appName":"TestNode2App","appPublisher":"TestPublisher2","appVersion":"0.0.0.0"},"applicationDefinition":{"objectType":"CodeUnit","objectName":"CodeUnit_Test');
        TextPerfProfileTextBuilder.Append('Node2","objectId":2}},{"id":3,"callFrame":{"functionName":"TestNode3FunctionName","scriptId":"CodeUnit_3","url":"TestNode3","lineNumber":0,"columnNumber":0},"hitCount":1,"children"');
        TextPerfProfileTextBuilder.Append(':[],"declaringApplication":{"appName":"TestNode3App","appPublisher":"TestPublisher1","appVersion":"0.0.0.0"},"applicationDefinition":{"objectType":"CodeUnit","objectName":"CodeUnit');
        TextPerfProfileTextBuilder.Append('_TestNode3","objectId":3}},{"id":4,"callFrame":{"functionName":"TestNode4FunctionName","scriptId":"CodeUnit_4","url":"TestNode4","lineNumber":0,"columnNumber":0},"hitCount":1,"chil');
        TextPerfProfileTextBuilder.Append('dren":[5],"declaringApplication":{"appName":"TestNode4App","appPublisher":"TestPublisher2","appVersion":"0.0.0.0"},"applicationDefinition":{"objectType":"CodeUnit","objectName":"Co');
        TextPerfProfileTextBuilder.Append('deUnit_TestNode4","objectId":4}},{"id":5,"callFrame":{"functionName":"TestNode2FunctionName","scriptId":"CodeUnit_2","url":"TestNode2","lineNumber":0,"columnNumber":0},"hitCount":1');
        TextPerfProfileTextBuilder.Append(',"children":[6],"declaringApplication":{"appName":"TestNode2App","appPublisher":"TestPublisher2","appVersion":"0.0.0.0"},"applicationDefinition":{"objectType":"CodeUnit","objectNam');
        TextPerfProfileTextBuilder.Append('e":"CodeUnit_TestNode2","objectId":2}},{"id":6,"callFrame":{"functionName":"TestNode3FunctionName","scriptId":"CodeUnit_3","url":"TestNode3","lineNumber":0,"columnNumber":0},"hitCo');
        TextPerfProfileTextBuilder.Append('unt":1,"children":[],"declaringApplication":{"appName":"TestNode3App","appPublisher":"TestPublisher1","appVersion":"0.0.0.0"},"applicationDefinition":{"objectType":"CodeUnit","obje');
        TextPerfProfileTextBuilder.Append('ctName":"CodeUnit_TestNode3","objectId":3}}],"startTime":63780017494528714,"endTime":63780017556442928,"samples":[1,2,3,5,6],"timeDeltas":[0,100000,500000,100000,500000],"kind":1}');
        exit(TextPerfProfileTextBuilder.ToText());
    end;

    /// <summary>
    /// Inserts a value into the provided profiling node
    /// </summary>
    procedure InsertProfilingNode(var ProfilingNode: Record "Profiling Node"; SessionID: Integer; No: Integer; HitCount: Integer; ObjectTypeText: Text[250]; ObjectID: Integer;
            ObjectName: Text[250]; AppName: Text[250]; AppPublisher: Text[250]; LineNo: Integer; MethodName: Text[250]; SelfTime: Duration; FullTime: Duration; Indentation: Integer)
    begin
        ProfilingNode.Init();
        ProfilingNode."Session ID" := SessionID;
        ProfilingNode."No." := No;
        ProfilingNode."Hit Count" := HitCount;
        ProfilingNode."Object Type" := ObjectTypeText;
        ProfilingNode."Object ID" := ObjectID;
        ProfilingNode."Object Name" := ObjectName;
        ProfilingNode."App Name" := AppName;
        ProfilingNode."App Publisher" := AppPublisher;
        ProfilingNode."Line No" := LineNo;
        ProfilingNode."Method Name" := MethodName;
        ProfilingNode."Self Time" := SelfTime;
        ProfilingNode."Full Time" := FullTime;
        ProfilingNode.Indentation := Indentation;
        ProfilingNode.Insert();
    end;

    /// <summary>
    /// Checks if all the records in the two provided profiling node temporary tables are the same
    /// </summary>
    procedure AreEqual(var FirstProfilingNodes: Record "Profiling Node"; var SecondProfilingNodes: Record "Profiling Node"): Boolean
    begin
        if FirstProfilingNodes.Count() <> SecondProfilingNodes.Count() then
            exit(false);
        FirstProfilingNodes.FindSet();
        repeat
            if not SecondProfilingNodes.Get(FirstProfilingNodes."Session ID", FirstProfilingNodes."No.") then
                exit(false);
            if not (Format(FirstProfilingNodes) = Format(SecondProfilingNodes)) then
                exit(false);
        until FirstProfilingNodes.Next() = 0;

        exit(true)
    end;

}