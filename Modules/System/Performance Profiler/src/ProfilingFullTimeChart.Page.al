// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The chart showing the breakdown of time full spent by app name / app publisher on the performance profiler page.
/// </summary>
page 1925 "Profiling Full Time Chart"
{
    Caption = 'Active Apps';
    PageType = CardPart;

    layout
    {
        area(content)
        {
            usercontrol(BusinessChart; BusinessChartUserControl)
            {
                ApplicationArea = All;

                trigger AddInReady()
                begin
                    IsChartAddInReady := true;
                    UpdateData();
                end;

                trigger Refresh()
                begin
                    UpdateData();
                end;
            }

            label(Description)
            {
                ApplicationArea = All;
                Caption = 'Shows the apps that where active during the recording. They were either running or called other apps. The duration represents the time you might save by removing an app.';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group("Actions")
            {
                Caption = 'Actions';

                group("Aggregate By")
                {
                    Caption = 'Aggregate By';
                    Image = SelectChart;

                    action(Name)
                    {
                        ApplicationArea = All;
                        Image = Inventory;
                        Caption = 'App Name';
                        ToolTip = 'Aggregate the time spent during the performance profiling by app name.';

                        trigger OnAction()
                        begin
                            ChartAggregationType := ChartAggregationType::"App Name";
                            UpdateData();
                        end;
                    }
                    action(Publisher)
                    {
                        ApplicationArea = All;
                        Image = BusinessRelation;
                        Caption = 'App Publisher';
                        ToolTip = 'Aggregate the time spent during the performance profiling by app publisher.';

                        trigger OnAction()
                        begin
                            ChartAggregationType := ChartAggregationType::"App Publisher";
                            UpdateData();
                        end;
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        ChartAggregationType := ChartAggregationType::"App Name";
        UpdateData();
    end;

    internal procedure UpdateData()
    begin
        if not IsChartAddInReady then
            exit;

        ProfilingChartHelper.UpdateData(CurrPage.BusinessChart, ChartAggregationType, Enum::"Business Chart Type"::Column, false);
    end;

    var
        ProfilingChartHelper: Codeunit "Profiling Chart Helper";
        ChartAggregationType: Enum "Profiling Aggregation Type";
        IsChartAddInReady: Boolean;
}
