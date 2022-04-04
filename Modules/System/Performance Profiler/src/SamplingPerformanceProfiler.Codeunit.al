// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The interface for running performance profiling using sampling.
/// </summary>
codeunit 1924 "Sampling Performance Profiler"
{
    Access = Public;
    SingleInstance = true;

    var
        SamplingPerfProfilerImpl: Codeunit "Sampling Perf. Profiler Impl.";

    /// <summary>
    /// Starts performance profiling.
    /// </summary>
    procedure Start()
    begin
        SamplingPerfProfilerImpl.Start();
    end;

    /// <summary>
    /// Stops performance profiling.
    /// </summary>
    procedure Stop()
    begin
        SamplingPerfProfilerImpl.Stop();
    end;

    /// <summary>
    /// Checks if the performance profiler recording is in progress.
    /// </summary>
    /// <returns>True if the recording is in progress, false otherwise.</returns>
    procedure IsRecordingInProgress(): Boolean
    begin
        exit(SamplingPerfProfilerImpl.IsRecordingInProgress());
    end;

    /// <summary>
    /// Gets the performance profiling data after the recording (via Start and Stop methods) is finished
    /// </summary>
    /// <returns>The recorded performance profiling data in JSON format.</returns>
    /// <error>If there is no performance profiling data.</error>
    procedure GetData(): InStream;
    begin
        exit(SamplingPerfProfilerImpl.GetData());
    end;

    /// <summary>
    /// Sets the performance profiling data from stream.
    /// </summary>
    /// <param name="ProfilingResultsInStream">The stream containing performance profiling data.</param>
    procedure SetData(ProfilingResultsInStream: InStream)
    begin
        SamplingPerfProfilerImpl.SetData(ProfilingResultsInStream);
    end;

    /// <summary>
    /// Gets the results of performance profiling.
    /// </summary>
    /// <param name="ProfilingNode">The results of performance profiling.</param>
    /// <error>If there is no performance profiling data.</error>
    /// <remarks>"Indentation" and "Full Time" fields will not be populated.</remarks>
    procedure GetProfilingNodes(var ProfilingNode: Record "Profiling Node")
    begin
        SamplingPerfProfilerImpl.GetProfilingNodes(ProfilingNode);
    end;

    /// <summary>
    /// Gets the results of performance profiling into a call tree structure.
    /// </summary>
    /// <param name="ProfilingNode">The call tree from performance profiling.</param>
    /// <error>If there is no performance profiling data.</error>
    /// <remarks>CPU nodes with multiple parents will be copied for each parent.</remarks>
    procedure GetProfilingCallTree(var ProfilingNode: Record "Profiling Node")
    begin
        SamplingPerfProfilerImpl.GetProfilingCallTree(ProfilingNode);
    end;
}