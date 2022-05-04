// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135014 "Profiling Data Processor Test"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        PerfProfilerTestLibrary: Codeunit "Perf. Profiler Test Library";

    [Test]
    procedure TestIsInitialized()
    var
        EmptyProfilingNode: Record "Profiling Node";
    begin
        // [WHEN] The performance profiler processor has not been initialized.
        // [THEN] The performance profiler processor is not initialized.
        Assert.IsFalse(PerfProfilerTestLibrary.IsInitialized(), 'The performance profiler processor is initialized before Initialize was called.');

        // [WHEN] The performance profiler processor has been initialized with empty records.
        PerfProfilerTestLibrary.Initialize(EmptyProfilingNode, EmptyProfilingNode);
        // [THEN] The performance profiler processor is not initialized.
        Assert.IsFalse(PerfProfilerTestLibrary.IsInitialized(), 'The performance profiler processor is initialized, even though it has no data.');

        // [WHEN] The performance profiler processor has been initialized with a performance profile.
        PerfProfilerTestLibrary.Initialize();
        // [THEN] The performance profiler processor is initialized.
        Assert.IsTrue(PerfProfilerTestLibrary.IsInitialized(), 'The performance profiler processor is not initialized after the initialization has been completed.');
    end;

    [Test]
    procedure TestClearData()
    begin
        // [GIVEN] The performance profiler processor has been initialized with a performance profile.
        PerfProfilerTestLibrary.Initialize();

        // [WHEN] The data on the performance profiler processor is cleared
        PerfProfilerTestLibrary.ClearData();

        // [THEN] The performance profiler processor is not initialized.
        Assert.IsFalse(PerfProfilerTestLibrary.IsInitialized(), 'The performance profiler processor is initialized, even though it has been cleared.');
    end;

    [Test]
    procedure TestGetUniqueIdentifierByAggregationType()
    var
        ProfilingNode: Record "Profiling Node";
    begin
        // [GIVEN] A test profiler node.
        PerfProfilerTestLibrary.InsertProfilingNode(ProfilingNode,
            SessionId(), 1, 1, 'Codeunit', 1, 'CodeUnit_TestNode1', 'TestNode1App',
            'TestPublisher1', 0, 'TestNode1FunctionName', 0, 0, 0);

        // [THEN] Getting a unique identifier from the node returns the correct result for every supported aggregation type.
        Assert.AreEqual('TestNode1App', PerfProfilerTestLibrary.GetUniqueIdentifierByAggregationType(ProfilingNode, Enum::"Profiling Aggregation Type"::"App Name"), 'Incorrect app name.');
        Assert.AreEqual('TestPublisher1', PerfProfilerTestLibrary.GetUniqueIdentifierByAggregationType(ProfilingNode, Enum::"Profiling Aggregation Type"::"App Publisher"), 'Incorrect app publisher.');
        Assert.AreEqual('Codeunit1TestNode1FunctionName', PerfProfilerTestLibrary.GetUniqueIdentifierByAggregationType(ProfilingNode, Enum::"Profiling Aggregation Type"::Method), 'Incorrect method name.');
        Assert.AreEqual('Codeunit1', PerfProfilerTestLibrary.GetUniqueIdentifierByAggregationType(ProfilingNode, Enum::"Profiling Aggregation Type"::Object), 'Incorrect app object.');
    end;

    [Test]
    procedure TestGetSelfTimeAggregateAppName()
    var
        ProfilingNode: Record "Profiling Node";
        VerificationProfilingNode: Record "Profiling Node";
    begin
        // [GIVEN] Expected profile nodes
        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 2, 2, 'Codeunit', 2, 'CodeUnit_TestNode2', 'TestNode2App',
            'TestPublisher2', 0, 'TestNode2FunctionName', 200, 0, 0);

        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 3, 2, 'Codeunit', 3, 'CodeUnit_TestNode3', 'TestNode3App',
            'TestPublisher1', 0, 'TestNode3FunctionName', 1000, 0, 0);

        // [GIVEN] Performance profiler is initialized with the test profile 
        PerfProfilerTestLibrary.Initialize();

        // [WHEN] The self time aggregate is retrieved
        PerfProfilerTestLibrary.GetSelfTimeAggregate(ProfilingNode, Enum::"Profiling Aggregation Type"::"App Name");

        // [THEN] Every node is as expected
        Assert.IsTrue(PerfProfilerTestLibrary.AreEqual(VerificationProfilingNode, ProfilingNode), 'The profiling nodes are not equal to expected ones.');

        PerfProfilerTestLibrary.ClearData();
    end;

    [Test]
    procedure TestGetSelfTimeAggregateAppPublisher()
    var
        ProfilingNode: Record "Profiling Node";
        VerificationProfilingNode: Record "Profiling Node";
    begin
        // [GIVEN] Expected profile nodes
        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 2, 2, 'Codeunit', 2, 'CodeUnit_TestNode2', 'TestNode2App',
            'TestPublisher2', 0, 'TestNode2FunctionName', 200, 0, 0);

        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 3, 2, 'Codeunit', 3, 'CodeUnit_TestNode3', 'TestNode3App',
            'TestPublisher1', 0, 'TestNode3FunctionName', 1000, 0, 0);

        // [GIVEN] Performance profiler is initialized with the test profile 
        PerfProfilerTestLibrary.Initialize();

        // [WHEN] The self time aggregate is retrieved
        PerfProfilerTestLibrary.GetSelfTimeAggregate(ProfilingNode, Enum::"Profiling Aggregation Type"::"App Publisher");

        // [THEN] Every node is as expected
        Assert.IsTrue(PerfProfilerTestLibrary.AreEqual(VerificationProfilingNode, ProfilingNode), 'The profiling nodes are not equal to expected ones.');

        PerfProfilerTestLibrary.ClearData();
    end;

    [Test]
    procedure TestGetSelfTimeAggregateWithFilterAppName()
    var
        ProfilingNode: Record "Profiling Node";
        VerificationProfilingNode: Record "Profiling Node";
        TableViewFilter: text;
    begin
        // [GIVEN] Expected profile nodes
        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 3, 2, 'Codeunit', 3, 'CodeUnit_TestNode3', 'TestNode3App',
            'TestPublisher1', 0, 'TestNode3FunctionName', 1000, 0, 0);

        // [GIVEN] The table view filter for a specific app object
        TableViewFilter := 'WHERE(Object Type=Const(Codeunit),Object ID=Const(3))';

        // [GIVEN] Performance profiler is initialized with the test profile 
        PerfProfilerTestLibrary.Initialize();

        // [WHEN] The self time aggregate is retrieved
        PerfProfilerTestLibrary.GetSelfTimeAggregate(ProfilingNode, Enum::"Profiling Aggregation Type"::"App Name", TableViewFilter);

        // [THEN] Every node is as expected
        Assert.IsTrue(PerfProfilerTestLibrary.AreEqual(VerificationProfilingNode, ProfilingNode), 'The profiling nodes are not equal to expected ones.');

        PerfProfilerTestLibrary.ClearData();
    end;

    [Test]
    procedure TestGetFullTimeNoAggregate()
    var
        ProfilingNode: Record "Profiling Node";
        VerificationProfilingNode: Record "Profiling Node";
    begin
        // [GIVEN] Expected profile nodes
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

        // [WHEN] The self time aggregate is retrieved
        PerfProfilerTestLibrary.GetFullTimeAggregate(ProfilingNode, Enum::"Profiling Aggregation Type"::"None");

        // [THEN] Every node is as expected
        Assert.IsTrue(PerfProfilerTestLibrary.AreEqual(VerificationProfilingNode, ProfilingNode), 'The profiling nodes are not equal to expected ones.');

        PerfProfilerTestLibrary.ClearData();
    end;

    [Test]
    procedure TestGetFullTimeAggregateAppName()
    var
        ProfilingNode: Record "Profiling Node";
        VerificationProfilingNode: Record "Profiling Node";
    begin
        // [GIVEN] Expected profile nodes
        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 1, 1, 'Codeunit', 1, 'CodeUnit_TestNode1', 'TestNode1App',
            'TestPublisher1', 0, 'TestNode1FunctionName', 0, 600, 0);

        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 2, 1, 'Codeunit', 2, 'CodeUnit_TestNode2', 'TestNode2App',
            'TestPublisher2', 0, 'TestNode2FunctionName', 100, 1200, 1);

        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 3, 1, 'Codeunit', 3, 'CodeUnit_TestNode3', 'TestNode3App',
            'TestPublisher1', 0, 'TestNode3FunctionName', 500, 1000, 2);

        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 4, 1, 'Codeunit', 4, 'CodeUnit_TestNode4', 'TestNode4App',
            'TestPublisher2', 0, 'TestNode4FunctionName', 0, 600, 0);

        // [GIVEN] Performance profiler is initialized with the test profile 
        PerfProfilerTestLibrary.Initialize();

        // [WHEN] The self time aggregate is retrieved
        PerfProfilerTestLibrary.GetFullTimeAggregate(ProfilingNode, Enum::"Profiling Aggregation Type"::"App Name");

        // [THEN] Every node is as expected
        Assert.IsTrue(PerfProfilerTestLibrary.AreEqual(VerificationProfilingNode, ProfilingNode), 'The profiling nodes are not equal to expected ones.');

        PerfProfilerTestLibrary.ClearData();
    end;

    [Test]
    procedure TestGetFullTimeAggregateAppPublisher()
    var
        ProfilingNode: Record "Profiling Node";
        VerificationProfilingNode: Record "Profiling Node";
    begin
        // [GIVEN] Expected profile nodes
        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 1, 1, 'Codeunit', 1, 'CodeUnit_TestNode1', 'TestNode1App',
            'TestPublisher1', 0, 'TestNode1FunctionName', 0, 1100, 0);

        PerfProfilerTestLibrary.InsertProfilingNode(VerificationProfilingNode,
            SessionId(), 2, 1, 'Codeunit', 2, 'CodeUnit_TestNode2', 'TestNode2App',
            'TestPublisher2', 0, 'TestNode2FunctionName', 100, 1200, 1);

        // [GIVEN] Performance profiler is initialized with the test profile 
        PerfProfilerTestLibrary.Initialize();

        // [WHEN] The self time aggregate is retrieved
        PerfProfilerTestLibrary.GetFullTimeAggregate(ProfilingNode, Enum::"Profiling Aggregation Type"::"App Publisher");

        // [THEN] Every node is as expected
        Assert.IsTrue(PerfProfilerTestLibrary.AreEqual(VerificationProfilingNode, ProfilingNode), 'The profiling nodes are not equal to expected ones.');

        PerfProfilerTestLibrary.ClearData();
    end;
}

