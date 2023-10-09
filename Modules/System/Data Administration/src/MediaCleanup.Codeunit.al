// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.DataAdministration;

using System.Environment;

/// <summary>
/// Provides an interface for cleaning up Media
/// </summary>
codeunit 1927 "Media Cleanup"
{
    Access = Public;

    var
        MediaCleanupImpl: Codeunit "Media Cleanup Impl.";

    /// <summary>
    /// Returns a list of detached tenant media. This media may be detached by itself or have an detached Media Set pointing to them.
    /// </summary>
    /// <param name="TempTenantMedia">The detached media. Must be a temporary table.</param>
    /// <param name="LoadMediaContent">Whether to copy over all media content. This may cause the call to be very expensive.</param>
    /// <returns>Whether all detached media were loaded into the Tenant Media Record. To prevent excessive waiting times, at most 10.000 records are loaded.</returns>
    procedure GetDetachedTenantMedia(var TempTenantMedia: Record "Tenant Media" temporary; LoadMediaContent: Boolean) AllDetachedMediaLoaded: Boolean
    begin
        MediaCleanupImpl.GetDetachedTenantMedia(TempTenantMedia, LoadMediaContent, 10000);
    end;

    /// <summary>
    /// Returns a list of detached tenant media. This media may be detached by itself or have an detached Media Set pointing to them.
    /// </summary>
    /// <param name="TempTenantMedia">The detached media. Must be a temporary table.</param>
    /// <param name="LoadMediaContent">Whether to copy over all media content. This may cause the call to be very expensive.</param>
    /// <param name="RecordLimit">Specifies the maximum amount of records to load. It's recommended to not set this too high.</param>
    /// <returns>Whether all detached media were loaded into the Tenant Media Record.</returns>
    procedure GetDetachedTenantMedia(var TempTenantMedia: Record "Tenant Media" temporary; LoadMediaContent: Boolean; RecordLimit: Integer) AllDetachedMediaLoaded: Boolean
    begin
        MediaCleanupImpl.GetDetachedTenantMedia(TempTenantMedia, LoadMediaContent, RecordLimit);
    end;

    /// <summary>
    /// Returns a list of detached tenant media. This media may be detached by itself or have an detached Media Set pointing to them.
    /// </summary>
    /// <param name="TempTenantMedia">The detached media. Must be a temporary table.</param>
    /// <param name="LoadMediaContent">Whether to copy over all media content. This may cause the call to be very expensive.</param>
    /// <returns>Whether all detached media were loaded into the Tenant Media Record. To prevent excessive waiting times, at most 100.000 records are loaded.</returns>
    procedure GetTenantMediaFromDetachedMediaSet(var TempTenantMedia: Record "Tenant Media" temporary; LoadMediaContent: Boolean) AllDetachedMediaLoaded: Boolean
    begin
        MediaCleanupImpl.GetTenantMediaFromDetachedMediaSet(TempTenantMedia, LoadMediaContent, 100000);
    end;

    /// <summary>
    /// Returns a list of detached tenant media. This media may be detached by itself or have an detached Media Set pointing to them.
    /// </summary>
    /// <param name="TempTenantMedia">The detached media. Must be a temporary table.</param>
    /// <param name="LoadMediaContent">Whether to copy over all media content. This may cause the call to be very expensive.</param>
    /// <param name="RecordLimit">Specifies the maximum amount of records to load. It's recommended to not set this too high.</param>
    /// <returns>Whether all detached media were loaded into the Tenant Media Record.</returns>
    procedure GetTenantMediaFromDetachedMediaSet(var TempTenantMedia: Record "Tenant Media" temporary; LoadMediaContent: Boolean; RecordLimit: Integer) AllDetachedMediaLoaded: Boolean
    begin
        MediaCleanupImpl.GetTenantMediaFromDetachedMediaSet(TempTenantMedia, LoadMediaContent, RecordLimit);
    end;

    /// <summary>
    /// Downloads the content of the specified tenant media id.
    /// </summary>
    /// <param name="MediaId">ID of the tenant media.</param>
    procedure DownloadTenantMedia(MediaId: Guid): Boolean
    begin
        exit(MediaCleanupImpl.DownloadTenantMedia(MediaId));
    end;

    /// <summary>
    /// Deletes the specified Tenant Media records specified in the temporary record if it is detached.
    /// </summary>
    /// <param name="TempTenantMedia">The list of media that should be deleted. Must be a temporary table.</param>
    procedure DeleteDetachedTenantMedia(var TempTenantMedia: Record "Tenant Media" temporary)
    begin
        MediaCleanupImpl.DeleteTenantMedia(TempTenantMedia);
    end;

    /// <summary>
    /// Deletes all detached tenant media sets.
    /// </summary>
    procedure DeleteDetachedTenantMediaSet()
    begin
        MediaCleanupImpl.DeleteDetachedTenantMediaSet();
    end;

    /// <summary>
    /// Deletes all detached tenant media.
    /// </summary>
    procedure DeleteDetachedTenantMedia()
    begin
        MediaCleanupImpl.DeleteDetachedTenantMedia();
    end;

    /// <summary>
    /// Schedules a background task which will remove both detached Tenant Media and detached Tenant Media Set.
    /// If user cannot schedule tasks, will suggest running the task in the foreground.
    /// </summary>
    procedure ScheduleCleanupDetachedMedia()
    begin
        MediaCleanupImpl.ScheduleCleanupDetachedMedia();
    end;
}