// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Represents all the available types of business charts
/// </summary>
enum 484 "Business Chart Type"
{
    Extensible = true;
    AssignmentCompatibility = true;

    /// <summary>
    /// Uses points to represent data points.
    /// </summary>
    value(0; "Point")
    {
        Caption = 'Point';
    }

    /// <summary>
    /// A variation of the Point chart type, where the data points are replaced by bubbles of different sizes.
    /// </summary>
    value(2; "Bubble")
    {
        Caption = 'Bubble';
    }

    /// <summary>
    /// Illustrates trends in data with the passing of time.
    /// </summary>
    value(3; "Line")
    {
        Caption = 'Line';
    }

    /// <summary>
    /// Similar to the Line chart type, but uses vertical and horizontal lines to connect the data points in a series forming a step-like progression.
    /// </summary>
    value(5; "StepLine")
    {
        Caption = 'StepLine';
    }

    /// <summary>
    /// Uses a sequence of columns to compare values across categories.
    /// </summary>
    value(10; "Column")
    {
        Caption = 'Column';
    }

    /// <summary>
    /// Used to compare the contribution of each value to a total across categories.
    /// </summary>
    value(11; "StackedColumn")
    {
        Caption = 'StackedColumn';
    }

    /// <summary>
    /// Displays multiple series of data as stacked columns. The cumulative proportion of each stacked element is always 100% of the Y axis.
    /// </summary>
    value(12; "StackedColumn100")
    {
        Caption = 'StackedColumn100';
    }

    /// <summary>
    /// Emphasizes the degree of change over time and shows the relationship of the parts to a whole.
    /// </summary>
    value(13; "Area")
    {
        Caption = 'Area';
    }

    /// <summary>
    /// An Area chart that stacks two or more data series on top of one another.
    /// </summary>
    value(15; "StackedArea")
    {
        Caption = 'StackedArea';
    }

    /// <summary>
    /// Displays multiple series of data as stacked areas. The cumulative proportion of each stacked element is always 100% of the Y axis.
    /// </summary>
    value(16; "StackedArea100")
    {
        Caption = 'StackedArea100';
    }

    /// <summary>
    /// Shows how proportions of data, shown as pie-shaped pieces, contribute to the data as a whole.
    /// </summary>
    value(17; "Pie")
    {
        Caption = 'Pie';
    }

    /// <summary>
    /// Similar to the Pie chart type, except that it has a hole in the center.
    /// </summary>
    value(18; "Doughnut")
    {
        Caption = 'Doughnut';
    }

    /// <summary>
    /// Displays a range of data by plotting two Y values per data point, with each Y value being drawn as a line chart.
    /// </summary>
    value(21; "Range")
    {
        Caption = 'Range';
    }

    /// <summary>
    /// A circular chart that is used primarily as a data comparison tool.
    /// </summary>
    value(25; "Radar")
    {
        Caption = 'Radar';
    }

    /// <summary>
    /// Displays in a funnel shape data that equals 100% when totaled.
    /// </summary>
    value(33; "Funnel")
    {
        Caption = 'Funnel';
    }
}