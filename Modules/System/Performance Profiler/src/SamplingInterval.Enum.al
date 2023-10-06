// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Tooling;

enum 1925 "Sampling Interval"
{
    Extensible = false;
    Access = Public;

    /// <summary>
    /// The sampling interval is not specified.
    /// </summary>
    value(0; None)
    {
        Caption = 'Not specified';
    }

    /// <summary>
    /// Sample every 50 milliseconds
    /// </summary>
    value(50; SampleEvery50ms)
    {
        Caption = '50 ms';
    }

    /// <summary>
    /// Sample every 100 milliseconds
    /// </summary>
    value(100; SampleEvery100ms)
    {
        Caption = '100 ms';
    }

    /// <summary>
    /// Sample every 150 milliseconds
    /// </summary>
    value(150; SampleEvery150ms)
    {
        Caption = '150 ms';
    }
}