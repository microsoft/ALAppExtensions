// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Storage;

/// <summary>
/// Defines the possible permissions for account SAS.
/// See: https://go.microsoft.com/fwlink/?linkid=2211413
/// </summary>
enum 9064 "SAS Permission"
{
    Access = Public;
    Extensible = false;

    value(0; Read)
    {
        Caption = 'r', Locked = true;
    }

    value(1; Add)
    {
        Caption = 'a', Locked = true;
    }

    value(2; Create)
    {
        Caption = 'c', Locked = true;
    }

    value(3; Write)
    {
        Caption = 'w', Locked = true;
    }

    value(4; Delete)
    {
        Caption = 'd', Locked = true;
    }

    value(5; List)
    {
        Caption = 'l', Locked = true;
    }

    value(6; "Permanent Delete")
    {
        Caption = 'y', Locked = true;
    }

    value(7; Update)
    {
        Caption = 'u', Locked = true;
    }

    value(8; Process)
    {
        Caption = 'p', Locked = true;
    }

    /// <summary>
    /// Valid for the following Object resource type only: blobs. Permits blob tag operations.
    /// </summary>
    value(9; Tag)
    {
        Caption = 't', Locked = true;
    }

    /// <summary>
    /// Valid for the following Object resource type only: blob. Permits filtering by blob tag.
    /// </summary>
    value(10; Filter)
    {
        Caption = 'f', Locked = true;
    }

    /// <summary>
    /// Valid for the following Object resource type only: blob. Permits set/delete immutability policy and legal hold on a blob.
    /// </summary>
    value(11; "Set Immutability Policy")
    {
        Caption = 'i', Locked = true;
    }	
}