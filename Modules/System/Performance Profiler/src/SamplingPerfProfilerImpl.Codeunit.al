// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1925 "Sampling Perf. Profiler Impl."
{
    Access = Internal;

    var
        TempBlob: Codeunit "Temp Blob";
        SamplingProfiler: Dotnet SamplingProfiler;
        CpuProfile: DotNet CpuProfile;
        IsRecordingRunning: Boolean;
        IdleTimeTok: Label 'IdleTime', Locked = true;
        NoRecordingErr: Label 'There is no performance profiling data.';
        NotSupportedCpuProfileKindErr: Label 'This type of .alcpuprofile file is not supported. Please upload a sampling-based CPU profile file.';

    procedure Start()
    begin
        IsRecordingRunning := true;
        SamplingProfiler.StartProfiling();
    end;

    procedure Stop()
    var
        ProfilingResultsMemoryStream: DotNet MemoryStream;
    begin
        ProfilingResultsMemoryStream := SamplingProfiler.StopProfiling();
        IsRecordingRunning := false;
        UpdateCpuProfile(ProfilingResultsMemoryStream);
        ProfilingResultsMemoryStream.Dispose();
    end;

    procedure IsRecordingInProgress(): Boolean
    begin
        exit(IsRecordingRunning);
    end;

    procedure GetData(): InStream;
    var
        ProfilingResultsInStream: InStream;
    begin
        if not TempBlob.HasValue() then
            Error(NoRecordingErr);

        TempBlob.CreateInStream(ProfilingResultsInStream);
        exit(ProfilingResultsInStream);
    end;

    procedure SetData(ProfilingResultsInStream: InStream)
    begin
        UpdateCpuProfile(ProfilingResultsInStream);
    end;

    local procedure UpdateCpuProfile(CpuProfileInStream: InStream)
    var
        ProfilingResultsOutStream: OutStream;
    begin
        Clear(TempBlob);
        TempBlob.CreateOutStream(ProfilingResultsOutStream);
        CopyStream(ProfilingResultsOutStream, CpuProfileInStream);
        InitializeCpuProfile();
    end;

    local procedure InitializeCpuProfile()
    var
        JsonSerializer: DotNet JsonSerializer;
        StreamReader: DotNet StreamReader;
        ProfilingResultsInStream: InStream;
    begin
        TempBlob.CreateInStream(ProfilingResultsInStream);
        JsonSerializer := JsonSerializer.JsonSerializer();
        StreamReader := StreamReader.StreamReader(ProfilingResultsInStream);
        CpuProfile := JsonSerializer.Deserialize(StreamReader, GetDotNetType(CpuProfile));
        if (not IsNull(CpuProfile)) then
            if CpuProfile.Kind <> CpuProfile.Kind::Sampling then
                Error(NotSupportedCpuProfileKindErr);
    end;

    procedure GetProfilingNodes(var ProfilingNode: Record "Profiling Node")
    var
        CpuProfileNode: DotNet CpuProfileNode;
        CpuProfileNodeArray: DotNet "Array";
        NodeIterator: Integer;
    begin
        CheckRecordingExists();

        CpuProfileNodeArray := CpuProfile.Nodes;
        foreach CpuProfileNode in CpuProfileNodeArray do
            AddCpuProfileNode(CpuProfileNode.Id, 0, CpuProfileNode, ProfilingNode);

        for NodeIterator := 0 to CpuProfile.Samples.Length() - 1 do
            AddCpuProfileNodeDuration(CpuProfile.Samples.GetValue(NodeIterator), CpuProfile.TimeDeltas.GetValue(NodeIterator), ProfilingNode);
    end;

    local procedure AddCpuProfileNode(NodeNumber: Integer; Indentation: Integer; CpuProfileNode: DotNet CpuProfileNode; var ProfilingNode: Record "Profiling Node")
    var
        ObjectTypeText: Text[250];
    begin
        if CpuProfileNode.CallFrame.FunctionName = IdleTimeTok then
            exit;

        ProfilingNode.Init();
        ProfilingNode."No." := NodeNumber;
        ProfilingNode."Session ID" := SessionId();
        ObjectTypeText := CpuProfileNode.ApplicationDefinition.ObjectType.ToString();
        if ObjectTypeText = 'CodeUnit' then
            ProfilingNode."Object Type" := 'Codeunit'
        else
            ProfilingNode."Object Type" := ObjectTypeText;
        ProfilingNode."Object ID" := CpuProfileNode.ApplicationDefinition.ObjectId;
        ProfilingNode."Object Name" := CpuProfileNode.ApplicationDefinition.ObjectName;
        ProfilingNode."App Name" := CpuProfileNode.DeclaringApplication.AppName;
        ProfilingNode."App Publisher" := CpuProfileNode.DeclaringApplication.AppPublisher;
        ProfilingNode."Line No" := CpuProfileNode.CallFrame.LineNumber;
        ProfilingNode."Method Name" := CpuProfileNode.CallFrame.FunctionName;
        ProfilingNode."Hit Count" := CpuProfileNode.HitCount;
        ProfilingNode.Indentation := Indentation;
        ProfilingNode.Insert();
    end;

    local procedure AddCpuProfileNodeDuration(NodeNumber: Integer; TimeDelta: BigInteger; var ProfilingNode: Record "Profiling Node")
    begin
        if ProfilingNode.Get(SessionId(), NodeNumber) then begin
            ProfilingNode."Self Time" := Round(TimeDelta / 1000, 1);
            ProfilingNode.Modify();
        end;
    end;

    procedure GetProfilingCallTree(var ProfilingNode: Record "Profiling Node")
    var
        CpuProfileNode: DotNet CpuProfileNode;
        CpuProfileNodeArray: DotNet "Array";
        NodeIterator: Integer;
        // using a dictionary here as there is no "Set" AL type 
        ChildNodes: Dictionary of [Integer, Boolean];
        NodeIdToSelfTimeMap: Dictionary of [Integer, BigInteger];
        ChildNodeId: Integer;
        NodeNumber: Integer;
        NodeIdToNodeMap: DotNet GenericDictionary2;
    begin
        CheckRecordingExists();

        // Find all call stack top nodes
        NodeIdToNodeMap := NodeIdToNodeMap.Dictionary();
        CpuProfileNodeArray := CpuProfile.Nodes;
        foreach CpuProfileNode in CpuProfileNodeArray do begin
            NodeIdToNodeMap.Add(CpuProfileNode.Id, CpuProfileNode);
            foreach ChildNodeId in CpuProfileNode.Children do
                ChildNodes.Set(ChildNodeId, true);
        end;

        // Populate the map of self times
        for NodeIterator := 0 to CpuProfile.Samples.Length() - 1 do
            NodeIdToSelfTimeMap.Add(CpuProfile.Samples.GetValue(NodeIterator), CpuProfile.TimeDeltas.GetValue(NodeIterator));

        // Iterate over the call stack top nodes (root nodes) and populate the trees in depth-first order
        NodeNumber := 1;
        foreach CpuProfileNode in CpuProfileNodeArray do
            if (not ChildNodes.ContainsKey(CpuProfileNode.Id)) and (CpuProfileNode.CallFrame.FunctionName <> IdleTimeTok) then
                PopulateDepthFirstTree(CpuProfileNode.Id, NodeIdToNodeMap, NodeIdToSelfTimeMap, NodeNumber, ProfilingNode);
    end;

    local procedure PopulateDepthFirstTree(RootCpuProfileNodeId: Integer; NodeIdToNodeMap: DotNet GenericDictionary2; NodeIdToSelfTimeMap: Dictionary of [Integer, BigInteger]; var NodeNumber: Integer; var ProfilingNode: Record "Profiling Node")
    var
        CpuProfileNode: DotNet CpuProfileNode;
        NodeStack: DotNet Stack;
        PostorderStack: DotNet Stack;
        NodeWithIndentation: DotNet GenericKeyValuePair2;
        NodeWithNodeNumber: DotNet GenericKeyValuePair2;
        ChildNodeId: Integer;
        CurrCpuProfileNodeId: Integer;
        Indentation: Integer;
        ChildNodeIndex: Integer;
    begin
        // Preorder depth-first traversal
        NodeStack := NodeStack.Stack();
        PostorderStack := PostorderStack.Stack();

        // push the root node on the stack
        NodeWithIndentation := NodeWithIndentation.KeyValuePair(RootCpuProfileNodeId, 0);
        NodeStack.Push(NodeWithIndentation);

        while NodeStack.Count() > 0 do begin
            // pop the current node from the stack and get all the information associated with it
            NodeWithIndentation := NodeStack.Pop();
            CurrCpuProfileNodeId := NodeWithIndentation."Key";
            Indentation := NodeWithIndentation.Value;

            // populate postorder stack, as full time needs to be computed bottom-up
            NodeWithNodeNumber := NodeWithNodeNumber.KeyValuePair(CurrCpuProfileNodeId, NodeNumber);
            PostorderStack.Push(NodeWithNodeNumber);

            // insert all the information about the node, except for self time and full time
            NodeIdToNodeMap.TryGetValue(CurrCpuProfileNodeId, CpuProfileNode);
            AddCpuProfileNode(NodeNumber, Indentation, CpuProfileNode, ProfilingNode);
            NodeNumber += 1;

            // push all the child nodes of the current node on the stack
            // iterate in reverse, so that the first child will be on top of the stack
            for ChildNodeIndex := CpuProfileNode.Children.Length() - 1 downto 0 do begin
                ChildNodeId := CpuProfileNode.Children.GetValue(ChildNodeIndex);
                NodeWithIndentation := NodeWithIndentation.KeyValuePair(ChildNodeId, Indentation + 1);
                NodeStack.Push(NodeWithIndentation);
            end;
        end;

        // use postorder stack to compute full times
        AddSelfAndFullTime(PostorderStack, NodeIdToNodeMap, NodeIdToSelfTimeMap, ProfilingNode);
    end;

    local procedure AddSelfAndFullTime(PostorderStack: DotNet Stack; NodeIdToNodeMap: DotNet GenericDictionary2; NodeIdToSelfTimeMap: Dictionary of [Integer, BigInteger]; var ProfilingNode: Record "Profiling Node")
    var
        NodeWithNodeNumber: DotNet GenericKeyValuePair2;
        CpuProfileNode: DotNet CpuProfileNode;
        NodeIdToFullTimeMap: Dictionary of [Integer, BigInteger];
        ChildrenFullTime: BigInteger;
        CurrNodeNumber: Integer;
        CurrCpuProfileNodeId: Integer;
        ChildNodeId: Integer;
    begin
        // the postorder stack is initialized, no need to add anything to it
        while PostorderStack.Count() > 0 do begin
            // pop the current node from the stack and get all the information associated with it
            NodeWithNodeNumber := PostorderStack.Pop();
            CurrCpuProfileNodeId := NodeWithNodeNumber."Key";
            CurrNodeNumber := NodeWithNodeNumber.Value;
            ProfilingNode.Get(SessionId(), CurrNodeNumber);

            // add self time, if present
            if NodeIdToSelfTimeMap.ContainsKey(CurrCpuProfileNodeId) then
                ProfilingNode."Self Time" := Round(NodeIdToSelfTimeMap.Get(CurrCpuProfileNodeId) / 1000, 1);

            // compute the sum of full times of all the child nodes (they have already been traversed)
            NodeIdToNodeMap.TryGetValue(CurrCpuProfileNodeId, CpuProfileNode);
            ChildrenFullTime := 0;
            foreach ChildNodeId in CpuProfileNode.Children do
                ChildrenFullTime += NodeIdToFullTimeMap.Get(ChildNodeId);

            // add full time
            ProfilingNode."Full Time" := ProfilingNode."Self Time" + ChildrenFullTime;
            NodeIdToFullTimeMap.Set(CurrCpuProfileNodeId, ProfilingNode."Full Time");

            ProfilingNode.Modify();
        end;
    end;

    local procedure CheckRecordingExists()
    begin
        if (IsNull(CpuProfile)) then
            Error(NoRecordingErr);

        if (IsNull(CpuProfile.Nodes)) then
            Error(NoRecordingErr);
    end;
}