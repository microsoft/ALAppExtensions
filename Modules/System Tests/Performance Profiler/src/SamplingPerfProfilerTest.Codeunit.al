// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135013 "Sampling Perf. Profiler Test"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        SamplingPerformanceProfiler: Codeunit "Sampling Performance Profiler";
        PerfProfilerTestLibrary: Codeunit "Perf. Profiler Test Library";
        NoRecordingErr: Label 'There is no performance profiling data.';

    [Test]
    procedure TestGetDataFailsWhenNoDataIsSet()
    begin
        // [WHEN] GetData is called on Sampling Performance Profiler with no data.
        asserterror SamplingPerformanceProfiler.GetData();

        // [THEN] The no data error is thrown.
        Assert.ExpectedError(NoRecordingErr);
    end;

    [Test]
    procedure TestGetProfilingCallTreeFailsWhenNoDataIsSet()
    var
        ProfilingNode: Record "Profiling Node";
    begin
        // [WHEN] GetProfilingCallTree is called on Sampling Performance Profiler with no data.
        asserterror SamplingPerformanceProfiler.GetProfilingCallTree(ProfilingNode);

        // [THEN] The no data error is thrown.
        Assert.ExpectedError(NoRecordingErr);
    end;

    [Test]
    procedure TesGetProfilingNodesFailsWhenNoDataIsSet()
    var
        ProfilingNode: Record "Profiling Node";
    begin
        // [WHEN] GetProfilingCallTree is called on Sampling Performance Profiler with no data.
        asserterror SamplingPerformanceProfiler.GetProfilingNodes(ProfilingNode);

        // [THEN] The no data error is thrown.
        Assert.ExpectedError(NoRecordingErr);
    end;

    [Test]
    procedure TestIsRecordingInProgress()
    begin
        // [WHEN] The performance profiling has not been started.
        // [THEN] The recording is not in progress.
        Assert.IsFalse(SamplingPerformanceProfiler.IsRecordingInProgress(), 'The recording is in progress before it has been started.');

        // [WHEN] The performance profiling has been started.
        SamplingPerformanceProfiler.Start();
        // [THEN] The recording is in progress.
        Assert.IsTrue(SamplingPerformanceProfiler.IsRecordingInProgress(), 'The recording is not in progress after it has been started.');

        // [WHEN] The performance profiling has been stopped.
        SamplingPerformanceProfiler.Stop();
        // [THEN] The recording is not in progress.
        Assert.IsFalse(SamplingPerformanceProfiler.IsRecordingInProgress(), 'The recording is in progress after it has been stopped.');

        PerfProfilerTestLibrary.ClearData();
    end;

    [Test]
    procedure TestSetDataGetData()
    var
        TempBlob: Codeunit "Temp Blob";
        SetDataInStr: InStream;
        GetDataInStr: InStream;
        OutStr: OutStream;
        GetDataText: Text;
    begin
        // [GIVEN] Test performance profiling data
        TempBlob.CreateOutStream(OutStr);
        OutStr.Write(PerfProfilerTestLibrary.GetTestPerformanceProfile());
        TempBlob.CreateInStream(SetDataInStr);

        // [WHEN] The performance profiling data has been set.
        SamplingPerformanceProfiler.SetData(SetDataInStr);

        // [THEN] Getting the data returns the same result as the original data.
        GetDataInStr := SamplingPerformanceProfiler.GetData();
        GetDataInStr.Read(GetDataText);
        Assert.AreEqual(PerfProfilerTestLibrary.GetTestPerformanceProfile(), GetDataText, 'The performance profiler modified the underlying data.');

        PerfProfilerTestLibrary.ClearData();
    end;

    [Test]
    procedure TestGetProfilingNodes()
    var
        ProfilingNode: Record "Profiling Node";
        VerificationProfilingNode: Record "Profiling Node";
    begin
        // [GIVEN] Test profile nodes
        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 1, 1, 'Codeunit', 1, 'CodeUnit_TestNode1', 'TestNode1App',
            'TestPublisher1', 0, 'TestNode1FunctionName', 0, 0, 0);

        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 2, 1, 'Codeunit', 2, 'CodeUnit_TestNode2', 'TestNode2App',
            'TestPublisher2', 0, 'TestNode2FunctionName', 100, 0, 0);

        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 3, 1, 'Codeunit', 3, 'CodeUnit_TestNode3', 'TestNode3App',
            'TestPublisher1', 0, 'TestNode3FunctionName', 500, 0, 0);

        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 4, 1, 'Codeunit', 4, 'CodeUnit_TestNode4', 'TestNode4App',
            'TestPublisher2', 0, 'TestNode4FunctionName', 0, 0, 0);

        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 5, 1, 'Codeunit', 2, 'CodeUnit_TestNode2', 'TestNode2App',
            'TestPublisher2', 0, 'TestNode2FunctionName', 100, 0, 0);

        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 6, 1, 'Codeunit', 3, 'CodeUnit_TestNode3', 'TestNode3App',
            'TestPublisher1', 0, 'TestNode3FunctionName', 500, 0, 0);
        // [GIVEN] Performance profiler is initialized with the test profile 
        PerfProfilerTestLibrary.Initialize();

        // [WHEN] Profiling nodes are retrieved from the profiler
        SamplingPerformanceProfiler.GetProfilingNodes(ProfilingNode);

        // [THEN] Every node is as expected
        Assert.IsTrue(PerfProfilerTestLibrary.AreEqual(VerificationProfilingNode, ProfilingNode), 'The profiling nodes are not equal to expected ones.');

        PerfProfilerTestLibrary.ClearData();
    end;

    [Test]
    procedure TestGetProfilingCallTree()
    var
        CallTreeProfilingNode: Record "Profiling Node";
        VerificationProfilingNode: Record "Profiling Node";
    begin
        // [GIVEN] Test profile nodes (in the call tree form)
        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 1, 1, 'Codeunit', 1, 'CodeUnit_TestNode1', 'TestNode1App',
            'TestPublisher1', 0, 'TestNode1FunctionName', 0, 600, 0);

        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 2, 1, 'Codeunit', 2, 'CodeUnit_TestNode2', 'TestNode2App',
            'TestPublisher2', 0, 'TestNode2FunctionName', 100, 600, 1);

        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 3, 1, 'Codeunit', 3, 'CodeUnit_TestNode3', 'TestNode3App',
            'TestPublisher1', 0, 'TestNode3FunctionName', 500, 500, 2);

        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 4, 1, 'Codeunit', 4, 'CodeUnit_TestNode4', 'TestNode4App',
            'TestPublisher2', 0, 'TestNode4FunctionName', 0, 600, 0);

        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 5, 1, 'Codeunit', 2, 'CodeUnit_TestNode2', 'TestNode2App',
            'TestPublisher2', 0, 'TestNode2FunctionName', 100, 600, 1);

        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 6, 1, 'Codeunit', 3, 'CodeUnit_TestNode3', 'TestNode3App',
            'TestPublisher1', 0, 'TestNode3FunctionName', 500, 500, 2);

        // [GIVEN] Performance profiler is initialized with the test profile 
        PerfProfilerTestLibrary.Initialize();

        // [WHEN] Profiling call tree nodes are retrieved from the profiler
        SamplingPerformanceProfiler.GetProfilingCallTree(CallTreeProfilingNode);

        // [THEN] Every node is as expected
        Assert.IsTrue(PerfProfilerTestLibrary.AreEqual(VerificationProfilingNode, CallTreeProfilingNode), 'The profiling nodes are not equal to expected ones.');

        PerfProfilerTestLibrary.ClearData();
    end;

    [Test]
    procedure GetProfilingCallTreeWithMultipleChildNodes()
    var
        ProfilingNode: Record "Profiling Node";
    begin
        // [SCENARIO] GetProfilingCallTree with multiple child nodes belonging to the same parent node

        // [GIVEN] Initialize the profiler with the profile data containing multiple child nodes 
        PerfProfilerTestLibrary.Initialize(PerfProfilerTestLibrary.GetPerformanceProfileWithMultipleChildNodes());

        // [WHEN] Call GetProfilingCallTree
        SamplingPerformanceProfiler.GetProfilingCallTree(ProfilingNode);

        // [THEN] Call tree is propoerly aligned: 3 nodes are at the indentation level 1, 3 nodes at level 3
        ProfilingNode.SetRange(Indentation, 1);
        Assert.AreEqual(3, ProfilingNode.Count(), ProfilingNodeCountErr);

        ProfilingNode.FindSet();
        VerifyProfilingNode(ProfilingNode, 'TestNode2FunctionName', 0, 219, 1);

        ProfilingNode.Next();
        VerifyProfilingNode(ProfilingNode, 'TestNode5FunctionName', 210, 210, 2);

        ProfilingNode.Next();
        VerifyProfilingNode(ProfilingNode, 'TestNode7FunctionName', 0, 429, 1);

        ProfilingNode.SetRange(Indentation, 3);
        Assert.AreEqual(3, ProfilingNode.Count(), ProfilingNodeCountErr);

        ProfilingNode.FindSet();
        VerifyProfilingNode(ProfilingNode, 'TestNode4FunctionName', 0, 0, 1);

        ProfilingNode.Next();
        VerifyProfilingNode(ProfilingNode, 'TestNode5FunctionName', 219, 219, 2);

        ProfilingNode.Next();
        VerifyProfilingNode(ProfilingNode, 'TestNode9FunctionName', 0, 0, 1);

        ProfilingNode.SetRange(Indentation, 3);
        Assert.AreEqual(3, ProfilingNode.Count(), ProfilingNodeCountErr);

        PerfProfilerTestLibrary.ClearData();
    end;

    local procedure VerifyProfilingNode(ProfilingNode: Record "Profiling Node"; MethodName: Text; SelfTime: Duration; FullTime: Duration; HitCount: Integer)
    begin
        Assert.AreEqual(MethodName, ProfilingNode."Method Name", ProfilingNodeNotMatchErr);
        Assert.AreEqual(SelfTime, ProfilingNode."Self Time", ProfilingNodeNotMatchErr);
        Assert.AreEqual(FullTime, ProfilingNode."Full Time", ProfilingNodeNotMatchErr);
        Assert.AreEqual(HitCount, ProfilingNode."Hit Count", ProfilingNodeNotMatchErr);
    end;

    var
        ProfilingNodeCountErr: Label 'The number of profiling nodes does not match the expected value.';
        ProfilingNodeNotMatchErr: Label 'Profiling node does not match the expected value.';
}