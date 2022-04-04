// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The object providing functionality for processing perfrormance profiling data.
/// </summary>
codeunit 1923 "Profiling Data Processor"
{
    Access = Internal;
    SingleInstance = true;

    var
        RawProfilingNodes: Record "Profiling Node";
        CallTreeProfilingNodes: Record "Profiling Node";

    /// <summary>
    /// Initializes the profiling data processor with the profiling data.
    /// </summary>
    /// <param name="RawProfilingNode">The performance profiling data.</param>
    /// <remarks>The data processor will reference the provided data, not copy it.</remarks>
    procedure Initialize(var RawProfilingNode: Record "Profiling Node"; var CallTreeProfilingNode: Record "Profiling Node")
    begin
        RawProfilingNodes.Copy(RawProfilingNode, true);
        CallTreeProfilingNodes.Copy(CallTreeProfilingNode, true);
    end;

    /// <summary>
    /// Clears the previously initialized performance profiling data.
    /// </summary>
    procedure ClearData();
    begin
        RawProfilingNodes.DeleteAll();
        CallTreeProfilingNodes.DeleteAll();
    end;

    /// <summary>
    /// Checks if the profiling data processor is initialized with <see cref="Initialize"/> method.
    /// </summary>
    /// <returns>True, if the profiling data processor is initialized, false otherwise.</returns>
    procedure IsInitialized(): Boolean
    begin
        if RawProfilingNodes.IsEmpty() then
            exit(false);

        if CallTreeProfilingNodes.IsEmpty() then
            exit(false);

        RawProfilingNodes.CalcSums("Self Time");
        if RawProfilingNodes."Self Time" = 0 then
            exit(false);

        exit(true);
    end;

    /// <summary>
    /// Gets aggregate self time of profiling nodes using the provided aggregation type.
    /// </summary>
    /// <param name="AggregatedProfilingNode">The resulting aggregation.</param>
    /// <param name="ProfilingAggregationType">The value of what to aggregate self time by.</param>
    procedure GetSelfTimeAggregate(var AggregatedProfilingNode: Record "Profiling Node"; ProfilingAggregationType: Enum "Profiling Aggregation Type")
    begin
        GetSelfTimeAggregate(AggregatedProfilingNode, ProfilingAggregationType, '');
    end;

    /// <summary>
    /// Gets aggregate self time of profiling nodes using the provided aggregation type.
    /// </summary>
    /// <param name="AggregatedProfilingNode">The resulting aggregation.</param>
    /// <param name="ProfilingAggregationType">The value of what to aggregate self time by.</param>
    /// <param name="FilterText">The table view to indicate which profiling nodes should be included in aggregation.</param>
    procedure GetSelfTimeAggregate(var AggregatedProfilingNode: Record "Profiling Node"; ProfilingAggregationType: Enum "Profiling Aggregation Type"; FilterText: text)
    begin
        RawProfilingNodes.SetView(FilterText);
        RawProfilingNodes.SetFilter("Self Time", '>%1', 0);
        if RawProfilingNodes.FindSet() then
            repeat
                SetAggregationFilter(AggregatedProfilingNode, RawProfilingNodes, ProfilingAggregationType);
                if AggregatedProfilingNode.FindFirst() then begin
                    AggregatedProfilingNode."Self Time" += RawProfilingNodes."Self Time";
                    AggregatedProfilingNode."Hit Count" += RawProfilingNodes."Hit Count";
                    AggregatedProfilingNode.Modify();
                end else begin
                    AggregatedProfilingNode := RawProfilingNodes;
                    AggregatedProfilingNode.Insert();
                end;
            until RawProfilingNodes.Next() = 0;
        RawProfilingNodes.Reset();
        AggregatedProfilingNode.Reset();
    end;

    /// <summary>
    /// Gets aggregate full time of profiling nodes using the provided aggregation type.
    /// </summary>
    /// <param name="AggregatedProfilingNode">The resulting aggregation.</param>
    /// <param name="ProfilingAggregationType">The value of what to aggregate full time by.</param>
    procedure GetFullTimeAggregate(var AggregatedProfilingNode: Record "Profiling Node"; ProfilingAggregationType: Enum "Profiling Aggregation Type")
    begin
        if ProfilingAggregationType = ProfilingAggregationType::None then begin
            // just copy the contents of the call tree if no aggregation is needed
            if CallTreeProfilingNodes.FindSet() then
                repeat
                    AggregatedProfilingNode := CallTreeProfilingNodes;
                    AggregatedProfilingNode.Insert();
                until CallTreeProfilingNodes.Next() = 0;
            exit;
        end;

        // Run for all call stack top nodes
        CallTreeProfilingNodes.SetRange(Indentation, 0);
        CallTreeProfilingNodes.SetFilter("Full Time", '>%1', 0);
        if CallTreeProfilingNodes.FindSet() then
            repeat
                ComputeFullTimeAggregate(CallTreeProfilingNodes, ProfilingAggregationType, AggregatedProfilingNode);
            until CallTreeProfilingNodes.Next() = 0;
        CallTreeProfilingNodes.Reset();
        AggregatedProfilingNode.Reset();
    end;

    /// <summary>
    /// Constructs and returns a unique string (with respect to aggregation type) from the provided profiling node.
    /// </summary>
    /// <param name="ProfilingNode">The node from which to construct a unique identifier.</param>
    /// <param name="ProfilingAggregationType">The aggregation type.</param>
    /// <returns>A unique (per aggregation type) string from the provided profiling node.</returns>
    procedure GetUniqueIdentifierByAggregationType(ProfilingNode: Record "Profiling Node"; ProfilingAggregationType: Enum "Profiling Aggregation Type"): Text
    begin
        case ProfilingAggregationType of
            ProfilingAggregationType::"App Publisher":
                exit(ProfilingNode."App Publisher");
            ProfilingAggregationType::"App Name":
                exit(ProfilingNode."App Name");
            ProfilingAggregationType::Object:
                exit(ProfilingNode."Object Type" + Format(ProfilingNode."Object ID"));
            ProfilingAggregationType::Method:
                exit(ProfilingNode."Object Type" + Format(ProfilingNode."Object ID") + ProfilingNode."Method Name");
        end;
    end;

    local procedure GetChildrenFilterView(var RootProfilingNode: Record "Profiling Node"): Text
    var
        NextNonChildProfilingNode: Record "Profiling Node";
        ChildrenProfilingNodes: Record "Profiling Node";
    begin
        ChildrenProfilingNodes.SetRange(Indentation, RootProfilingNode.Indentation + 1);

        NextNonChildProfilingNode.Copy(RootProfilingNode, true);
        NextNonChildProfilingNode.SetFilter(Indentation, '<=%1', RootProfilingNode.Indentation);
        NextNonChildProfilingNode.SetFilter("No.", '>%1', RootProfilingNode."No.");
        if NextNonChildProfilingNode.FindFirst() then
            ChildrenProfilingNodes.SetFilter("No.", '>%1&<%2', RootProfilingNode."No.", NextNonChildProfilingNode."No.")
        else
            ChildrenProfilingNodes.SetFilter("No.", '>%1', RootProfilingNode."No.");

        exit(ChildrenProfilingNodes.GetView());
    end;

    local procedure ComputeFullTimeAggregate(var RootProfilingNode: Record "Profiling Node"; ProfilingAggregationType: Enum "Profiling Aggregation Type"; var AggregatedProfilingNode: Record "Profiling Node")
    var
        ChildProfilingNodes: Record "Profiling Node";
        CurrProfilingNode: Record "Profiling Node";
        ExclusionSet: DotNet GenericHashSet1;
        ChildExclusionSet: DotNet GenericHashSet1;
        NodeStack: DotNet Stack;
        NodeNumberWithExclusionSet: DotNet GenericKeyValuePair2;
        CurrProfilingNodeNumber: Integer;
    begin
        // Depth-first traversal
        NodeStack := NodeStack.Stack();
        CurrProfilingNode.Copy(RootProfilingNode, true);

        // push the root node on the stack
        ExclusionSet := ExclusionSet.HashSet();
        NodeNumberWithExclusionSet := NodeNumberWithExclusionSet.KeyValuePair(RootProfilingNode."No.", ExclusionSet);
        NodeStack.Push(NodeNumberWithExclusionSet);

        while NodeStack.Count() > 0 do begin
            // pop the current node from the stack and get all the information associated with it
            NodeNumberWithExclusionSet := NodeStack.Pop();
            CurrProfilingNodeNumber := NodeNumberWithExclusionSet."Key";
            ExclusionSet := NodeNumberWithExclusionSet.Value;
            CurrProfilingNode.Get(SessionId(), CurrProfilingNodeNumber);

            // process the current node
            AddNodeToAggregation(CurrProfilingNode, ProfilingAggregationType, ExclusionSet, AggregatedProfilingNode);

            // push all the child nodes of the current node on the stack
            ChildProfilingNodes.Copy(CurrProfilingNode, true);
            ChildProfilingNodes.SetView(GetChildrenFilterView(CurrProfilingNode));
            if ChildProfilingNodes.FindSet() then
                repeat
                    ChildExclusionSet := ChildExclusionSet.HashSet(ExclusionSet);
                    NodeNumberWithExclusionSet := NodeNumberWithExclusionSet.KeyValuePair(ChildProfilingNodes."No.", ChildExclusionSet);
                    NodeStack.Push(NodeNumberWithExclusionSet);
                until ChildProfilingNodes.Next() = 0;
        end;
    end;

    local procedure AddNodeToAggregation(CurrProfilingNode: Record "Profiling Node"; ProfilingAggregationType: Enum "Profiling Aggregation Type"; ExclusionSet: DotNet GenericHashSet1; var AggregatedProfilingNode: Record "Profiling Node")
    var
        AggregationTypeUniqueIdentifier: Text;
    begin
        // If the current AggregationTypeUniqueIdentifier has not been encountered yet (in the current branch of the tree), then add the full time of the current node to the aggregation.
        AggregationTypeUniqueIdentifier := GetUniqueIdentifierByAggregationType(CurrProfilingNode, ProfilingAggregationType);
        if not ExclusionSet.Contains(AggregationTypeUniqueIdentifier) then begin
            ExclusionSet.Add(AggregationTypeUniqueIdentifier);
            SetAggregationFilter(AggregatedProfilingNode, CurrProfilingNode, ProfilingAggregationType);
            if AggregatedProfilingNode.FindFirst() then begin
                AggregatedProfilingNode."Full Time" += CurrProfilingNode."Full Time";
                AggregatedProfilingNode.Modify();
            end else begin
                AggregatedProfilingNode := CurrProfilingNode;
                AggregatedProfilingNode.Insert();
            end;
        end;
    end;

    local procedure SetAggregationFilter(var AggregatedProfilingNode: Record "Profiling Node"; SourceProfilingNode: Record "Profiling Node"; ProfilingAggregationType: Enum "Profiling Aggregation Type")
    begin
        case ProfilingAggregationType of
            ProfilingAggregationType::"App Publisher":
                AggregatedProfilingNode.SetRange("App Publisher", SourceProfilingNode."App Publisher");
            ProfilingAggregationType::"App Name":
                begin
                    AggregatedProfilingNode.SetRange("App Publisher", SourceProfilingNode."App Publisher");
                    AggregatedProfilingNode.SetRange("App Name", SourceProfilingNode."App Name");
                end;
            ProfilingAggregationType::Object:
                begin
                    AggregatedProfilingNode.SetRange("Object Type", SourceProfilingNode."Object Type");
                    AggregatedProfilingNode.SetRange("Object ID", SourceProfilingNode."Object ID");
                end;
            ProfilingAggregationType::Method:
                begin
                    AggregatedProfilingNode.SetRange("Object Type", SourceProfilingNode."Object Type");
                    AggregatedProfilingNode.SetRange("Object ID", SourceProfilingNode."Object ID");
                    AggregatedProfilingNode.SetRange("Method Name", SourceProfilingNode."Method Name");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'GetPerformanceTroubleshooterPageId', '', false, false)]
    local procedure GetPerformanceTroubleshooterPageId(var PageId: Integer)
    begin
        PageId := Page::"Performance Profiler";
    end;
}