// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Indicates the priority with which to rehydrate an archived blob.
/// The priority can be set on a blob only one time. This header will be ignored on subsequent requests to the same blob. The default priority without this header is Standard.
/// </summary>
enum 9046 "ABS Rehydrate Priority"
{
    Access = Public;
    Extensible = false;

    /// <summary>
    /// Standard priority. Default value.
    /// </summary>
    value(0; Standard)
    {
        Caption = 'Standard', Locked = true;
    }

    /// <summary>
    /// High priority
    /// </summary>
    value(1; High)
    {
        Caption = 'High', Locked = true;
    }
}