// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the status of an email when it is in the outbox.
/// </summary>
enum 8888 "Email Status"
{
    Extensible = false;

    /// <summary>
    /// An uninitialized email.
    /// </summary>
    value(0; " ")
    {
    }

    /// <summary>
    /// An email waiting to be queued up for sending.
    /// </summary>
    value(1; Draft)
    {
    }

    /// <summary>
    /// An email queued up and waiting to be processed.
    /// </summary>
    value(2; Queued)
    {
        Caption = 'Pending';
    }

    /// <summary>
    /// An email that is currently being processed and sent.
    /// </summary>
    value(3; Processing)
    {
    }

    /// <summary>
    /// An email that had an error occur during processing.
    /// </summary>
    value(4; Failed)
    {
    }
}