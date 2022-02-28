// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Sampling-based in-client performance profiler
/// </summary>
page 24 "Performance Profiler"
{
    Caption = 'Performance Profiler';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    AboutTitle = 'About performance profiling';
    AboutText = 'Use the performance profiler to record a slow scenario that you can then analyze to see what took a long time. The profiler uses sampling technology, so the results may differ slightly between recordings of the same scenario.';

    layout
    {
        area(Content)
        {
            group(Info)
            {
                Visible = not (IsDataPresent or IsRecordingInProgress);
                ShowCaption = false;

                group(VerticalAlignmentInfo)
                {
                    ShowCaption = false;

                    label("Troubleshoot slow operations")
                    {
                        ApplicationArea = All;
                        Caption = 'Troubleshoot slow operations';
                        Style = Strong;
                    }
                    label("Use Start and Stop")
                    {
                        ApplicationArea = All;
                        Caption = 'Use the Start and Stop buttons to record a process that you think is slow. The charts will show how much time each app used.';
                    }
                }
            }
            group(ProfilingIsRunning)
            {
                Visible = IsRecordingInProgress;
                ShowCaption = false;

                group(VerticalAlignmentProfilingIsRunning)
                {
                    ShowCaption = false;

                    label("Profiling is running")
                    {
                        ApplicationArea = All;
                        Caption = 'The performance profiler is now running';
                        Style = Strong;
                    }
                    label(Instructions)
                    {
                        ApplicationArea = All;
                        Caption = 'You can record your business process.';
                    }
                }
            }
            part("Profiling Full Time Chart"; "Profiling Full Time Chart")
            {
                ApplicationArea = All;
                Visible = IsDataPresent;
            }
            group("Technical Information")
            {
                Caption = '';
                Visible = IsDataPresent;

                field(ShowTechnicalInformation; ShowTechnicalInformation)
                {
                    ApplicationArea = All;
                    Editable = true;
                    Enabled = true;
                    Caption = 'Show technical information';
                    ToolTip = 'Show details about the time each app took during the performance profiling.';
                }
            }
            part("Profiling Self Time Chart"; "Profiling Self Time Chart")
            {
                ApplicationArea = All;
                Visible = IsDataPresent and ShowTechnicalInformation;
            }
            part("Profiling Duration By Object"; "Profiling Duration By Object")
            {
                ApplicationArea = All;
                Visible = IsDataPresent and ShowTechnicalInformation;
            }
            part("Profiling Call Tree"; "Profiling Call Tree")
            {
                ApplicationArea = All;
                Visible = IsDataPresent and ShowTechnicalInformation;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Start)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Start;
                Enabled = IsStartEnabled;
                Caption = 'Start';
                ToolTip = 'Start the performance profiler recording.';
                AboutTitle = 'Starting the recording';
                AboutText = 'The most convenient way of interacting with the performance profiler is by having it in a separate browser window next to your main Business Central browser window. Once your windows are conveniently docked, you can start the performance profiler recording.';

                trigger OnAction()
                begin
                    FeatureTelemetry.LogUptake('0000GMN', PerformanceProfilingFeatureTxt, Enum::"Feature Uptake Status"::"Set up");
                    SamplingPerformanceProfiler.Start();
                    UpdateControlProperties();
                end;
            }
            action(Stop)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Stop;
                Enabled = IsRecordingInProgress;
                Caption = 'Stop';
                ToolTip = 'Stop the performance profiler recording.';
                AboutTitle = 'Stopping the recording';
                AboutText = 'After you have run the scenario, stop the recording. The page is updated with information about which apps were taking time during the process. Use this information to reach out to the relevant extension publisher for help with your performance issue, for example.';

                trigger OnAction()
                begin
                    UpdateControlProperties();
                    SamplingPerformanceProfiler.Stop();
                    UpdateData();
                end;
            }
            action(Clear)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = ClearLog;
                Enabled = IsClearEnabled;
                Caption = 'Clear';
                ToolTip = 'Clear the performance profiler recording data.';

                trigger OnAction()
                begin
                    ProfilingDataProcessor.ClearData();
                    Clear(SamplingPerformanceProfiler);
                    UpdateControlProperties();
                end;
            }
            action(Download)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Download;
                Enabled = IsDownloadEnabled;
                Caption = 'Download';
                ToolTip = 'Download the performance profile file of the recording performed.';

                trigger OnAction()
                var
                    ToFile: Text;
                begin
                    if not Confirm(PrivacyNoticeMsg) then
                        exit;
                    ToFile := StrSubstNo(ProfileFileNameTxt, SessionId()) + ProfileFileExtensionTxt;
                    DownloadFromStream(SamplingPerformanceProfiler.GetData(), '', '', '', ToFile);
                end;
            }
            action(ShareToOneDrive)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Share;
                Enabled = IsDownloadEnabled;
                Caption = 'Share';
                ToolTip = 'Copy the profile file to your Business Central folder in OneDrive and share the file. You can also see who it''s already shared with.', Comment = 'OneDrive should not be translated';
                AboutTitle = 'Sharing the results';
                AboutText = 'You can share the results of performance profiling with your partner through OneDrive. Or download the file directly.';

                trigger OnAction()
                var
                    DocumentSharing: Codeunit "Document Sharing";
                begin
                    DocumentSharing.Share(StrSubstNo(ProfileFileNameTxt, SessionID()), ProfileFileExtensionTxt, SamplingPerformanceProfiler.GetData(), Enum::"Document Sharing Intent"::Share);
                end;
            }
            action(Upload)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Import;
                Enabled = IsUploadEnabled;
                Caption = 'Upload';
                ToolTip = 'Upload the performance profile file to be processed.';

                trigger OnAction()
                var
                    UploadedFileName: Text;
                    FileContentInstream: Instream;
                begin
                    if not UploadIntoStream(UploadProfileLbl, '', ProfileFileTypeTxt, UploadedFileName, FileContentInstream) then
                        exit;

                    FeatureTelemetry.LogUptake('0000GMO', PerformanceProfilingFeatureTxt, Enum::"Feature Uptake Status"::"Set up");
                    SamplingPerformanceProfiler.SetData(FileContentInstream);
                    UpdateData();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        FeatureTelemetry.LogUptake('0000GMP', PerformanceProfilingFeatureTxt, Enum::"Feature Uptake Status"::Discovered);
        UpdateControlProperties();
    end;

    local procedure UpdateSubPages()
    begin
        CurrPage."Profiling Self Time Chart".Page.UpdateData();
        CurrPage."Profiling Full Time Chart".Page.UpdateData();
        CurrPage."Profiling Duration By Object".Page.UpdateData();
        CurrPage."Profiling Call Tree".Page.UpdateData();
    end;

    local procedure UpdateControlProperties()
    begin
        IsDataPresent := ProfilingDataProcessor.IsInitialized();
        IsRecordingInProgress := SamplingPerformanceProfiler.IsRecordingInProgress();
        IsStartEnabled := not (IsDataPresent or IsRecordingInProgress);
        IsClearEnabled := IsDataPresent;
        IsDownloadEnabled := IsDataPresent;
        IsUploadEnabled := not (IsDataPresent or IsRecordingInProgress);
    end;

    local procedure UpdateData()
    var
        RawProfilingNodes: Record "Profiling Node";
        CallTreeProfilingNodes: Record "Profiling Node";
    begin
        FeatureTelemetry.LogUptake('0000GMQ', PerformanceProfilingFeatureTxt, Enum::"Feature Uptake Status"::Used);
        UpdateControlProperties(); // update controls in case the following lines throw an error
        SamplingPerformanceProfiler.GetProfilingNodes(RawProfilingNodes);
        SamplingPerformanceProfiler.GetProfilingCallTree(CallTreeProfilingNodes);
        ProfilingDataProcessor.Initialize(RawProfilingNodes, CallTreeProfilingNodes);
        UpdateControlProperties();
        if not IsDataPresent then
            exit;

        UpdateSubPages();
        FeatureTelemetry.LogUsage('0000GMR', PerformanceProfilingFeatureTxt, 'Performance Profiling results shown');
    end;

    var
        SamplingPerformanceProfiler: Codeunit "Sampling Performance Profiler";
        ProfilingDataProcessor: Codeunit "Profiling Data Processor";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        IsDataPresent: Boolean;
        ShowTechnicalInformation: Boolean;
        IsStartEnabled: Boolean;
        IsRecordingInProgress: Boolean;
        IsClearEnabled: Boolean;
        IsUploadEnabled: Boolean;
        IsDownloadEnabled: Boolean;
        UploadProfileLbl: Label 'Upload a previously recorded performance profile';
        ProfileFileTypeTxt: Label 'CPU profile |*.alcpuprofile';
        ProfileFileNameTxt: Label 'PerformanceProfile_Session%1', Locked = true;
        ProfileFileExtensionTxt: Label '.alcpuprofile', Locked = true;
        PerformanceProfilingFeatureTxt: Label 'Performance Profiling', Locked = true;
        PrivacyNoticeMsg: Label 'The file might contain sensitive data, so be sure to handle it securely and according to privacy requirements. Do you want to continue?';
}