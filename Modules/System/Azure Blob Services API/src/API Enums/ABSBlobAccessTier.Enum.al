// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Azure storage offers different access tiers.
/// Azure Blog storage offers access tiers that let you manage the cost of storing large amounts of unstructured data, such as text or binary data.allowing you to store blob object data in the most cost-effective manner.
/// See: https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-storage-tiers
/// </summary>
enum 9042 "ABS Blob Access Tier"
{
    Access = Public;
    Extensible = false;

    /// <summary>
    /// Optimized for storing data that is accessed frequently.
    /// </summary>
    value(0; Hot)
    {
        Caption = 'Hot', Locked = true;
    }

    /// <summary>
    /// Optimized for storing data that is infrequently accessed and stored for at least 30 days.
    /// </summary>
    value(1; Cool)
    {
        Caption = 'Cool', Locked = true;
    }

    /// <summary>
    /// Optimized for storing data that is rarely accessed and stored for at least 180 days with flexible latency requirements, on the order of hours.
    /// </summary>
    value(3; Archive)
    {
        Caption = 'Archive', Locked = true;
    }
}