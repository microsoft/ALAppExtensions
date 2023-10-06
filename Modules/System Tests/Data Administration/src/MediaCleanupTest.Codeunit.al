// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.DataAdministration;

using System.DataAdministration;
using System.Environment;
using System.Utilities;
using System.TestLibraries.Utilities;
using System.TestLibraries.Security.AccessControl;

codeunit 135018 "Media Cleanup Test"
{
    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        Any: Codeunit Any;

    [Test]
    procedure EnsureNoDetachedMediaByDefault()
    var
        TempTenantMedia: Record "Tenant Media" temporary;
    begin
        PermissionsMock.Set('Data Cleanup - Admin');
        GetDetachedTenantMedia(TempTenantMedia);
        LibraryAssert.IsTrue(TempTenantMedia.IsEmpty(), 'Tenant media contains unreferenced media by default.');
    end;

    [Test]
    procedure EnsureDetachedMediaIsDetected()
    var
        TempTenantMedia: Record "Tenant Media" temporary;
        MediaCleanup: Codeunit "Media Cleanup";
    begin
        PermissionsMock.ClearAssignments();
        CreateDetachedMedia(1000, 100 * 1024); // 1000 media of 100 kb
        PermissionsMock.Set('Data Cleanup - Admin');
        GetDetachedTenantMedia(TempTenantMedia);
        LibraryAssert.AreEqual(1000, TempTenantMedia.Count(), 'Tenant media does not contain all detached media.');

        MediaCleanup.DeleteDetachedTenantMedia(TempTenantMedia);
        GetDetachedTenantMedia(TempTenantMedia);
        LibraryAssert.IsTrue(TempTenantMedia.IsEmpty(), 'Detached Tenant media was not cleaned up properly.');
    end;

    [Test]
    procedure EnsureLargeDetachedMediaIsDetected()
    var
        TempTenantMedia: Record "Tenant Media" temporary;
        MediaCleanup: Codeunit "Media Cleanup";
    begin
        PermissionsMock.ClearAssignments();
        CreateDetachedMedia(10, 100 * 1024 * 1024); // 10 media of 100 MB
        PermissionsMock.Set('Data Cleanup - Admin');
        GetDetachedTenantMedia(TempTenantMedia);
        LibraryAssert.AreEqual(10, TempTenantMedia.Count(), 'Tenant media does not contain all detached media.');

        MediaCleanup.DeleteDetachedTenantMedia(TempTenantMedia);
        GetDetachedTenantMedia(TempTenantMedia);
        LibraryAssert.IsTrue(TempTenantMedia.IsEmpty(), 'Detached Tenant media was not cleaned up properly.');
    end;

    [Test]
    procedure EnsureManyDetachedMediaIsDetected()
    var
        TempTenantMedia: Record "Tenant Media" temporary;
        MediaCleanup: Codeunit "Media Cleanup";
    begin
        PermissionsMock.ClearAssignments();
        CreateDetachedMedia(10000, 100); // 10000 media of 100 bytes
        PermissionsMock.Set('Data Cleanup - Admin');
        GetDetachedTenantMedia(TempTenantMedia);
        LibraryAssert.AreEqual(10000, TempTenantMedia.Count(), 'Tenant media does not contain all detached media.');

        MediaCleanup.DeleteDetachedTenantMedia(TempTenantMedia);
        GetDetachedTenantMedia(TempTenantMedia);
        LibraryAssert.IsTrue(TempTenantMedia.IsEmpty(), 'Detached Tenant media was not cleaned up properly.');
    end;

    [Test]
    procedure EnsureDetachedMediaThroughMediaSetIsDetected()
    var
        TempTenantMedia: Record "Tenant Media" temporary;
        MediaCleanup: Codeunit "Media Cleanup";
    begin
        PermissionsMock.ClearAssignments();
        CreateDetachedMediaThroughMediaSet(1000, 100 * 1024); // 1000 media of 100 kb
        PermissionsMock.Set('Data Cleanup - Admin');
        GetDetachedTenantMedia(TempTenantMedia);
        LibraryAssert.AreEqual(1000, TempTenantMedia.Count(), 'Tenant media does not contain all detached media.');

        MediaCleanup.DeleteDetachedTenantMedia(TempTenantMedia);
        GetDetachedTenantMedia(TempTenantMedia);
        LibraryAssert.IsTrue(TempTenantMedia.IsEmpty(), 'Detached Tenant media was not cleaned up properly.');
    end;

    [Test]
    procedure EnsureDetachedMediaAndMediaSetAreCleanedUp()
    var
        TempTenantMedia: Record "Tenant Media" temporary;
        MediaCleanup: Codeunit "Media Cleanup";
    begin
        PermissionsMock.ClearAssignments();
        CreateDetachedMediaThroughMediaSet(100, 100 * 1024); // 100 media of 100 kb
        CreateDetachedMedia(100, 100 * 1024); // 100 media of 100 kb
        PermissionsMock.Set('Data Cleanup - Admin');
        GetDetachedTenantMedia(TempTenantMedia);
        LibraryAssert.AreEqual(200, TempTenantMedia.Count(), 'Tenant media does not contain all detached media.');

        MediaCleanup.DeleteDetachedTenantMediaSet();
        MediaCleanup.DeleteDetachedTenantMedia();
        GetDetachedTenantMedia(TempTenantMedia);
        LibraryAssert.IsTrue(TempTenantMedia.IsEmpty(), 'Detached Tenant media was not cleaned up properly.');
    end;

    [Test]
    procedure EnsureDetachedMediaAndMediaSetAreCleanedUpThroughCodeunit()
    var
        TempTenantMedia: Record "Tenant Media" temporary;
    begin
        PermissionsMock.ClearAssignments();
        CreateDetachedMediaThroughMediaSet(100, 100 * 1024); // 100 media of 100 kb
        CreateDetachedMedia(100, 100 * 1024); // 100 media of 100 kb
        PermissionsMock.Set('Data Cleanup - Admin');
        GetDetachedTenantMedia(TempTenantMedia);
        LibraryAssert.AreEqual(200, TempTenantMedia.Count(), 'Tenant media does not contain all detached media.');

        Codeunit.Run(Codeunit::"Media Cleanup Runner");
        GetDetachedTenantMedia(TempTenantMedia);
        LibraryAssert.IsTrue(TempTenantMedia.IsEmpty(), 'Detached Tenant media was not cleaned up properly.');
    end;

    [Test]
    procedure EnsureViewPermissionsCannotCleanupMedia()
    var
        TempTenantMedia: Record "Tenant Media" temporary;
        MediaCleanup: Codeunit "Media Cleanup";
    begin
        PermissionsMock.ClearAssignments();
        CreateDetachedMediaThroughMediaSet(100, 100 * 1024); // 100 media of 100 kb
        CreateDetachedMedia(100, 100 * 1024); // 100 media of 100 kb
        PermissionsMock.Set('Data Cleanup - View');
        GetDetachedTenantMedia(TempTenantMedia);
        LibraryAssert.AreEqual(200, TempTenantMedia.Count(), 'Tenant media does not contain all detached media initially.');

        MediaCleanup.DeleteDetachedTenantMediaSet();
        MediaCleanup.DeleteDetachedTenantMedia();
        GetDetachedTenantMedia(TempTenantMedia);
        LibraryAssert.AreEqual(200, TempTenantMedia.Count(), 'Tenant media does not contain all detached media after view deletion attempt.');

        PermissionsMock.Set('Data Cleanup - Admin');
        MediaCleanup.DeleteDetachedTenantMediaSet();
        MediaCleanup.DeleteDetachedTenantMedia();
        GetDetachedTenantMedia(TempTenantMedia);
        LibraryAssert.AreEqual(0, TempTenantMedia.Count(), 'Tenant media does not contain all detached media.');
        LibraryAssert.IsTrue(TempTenantMedia.IsEmpty(), 'Detached Tenant media was not cleaned up properly.');
    end;

    local procedure GetDetachedTenantMedia(var TempTenantMedia: Record "Tenant Media" temporary)
    var
        MediaCleanup: Codeunit "Media Cleanup";
    begin
        TempTenantMedia.Reset();
        TempTenantMedia.DeleteAll();
        MediaCleanup.GetDetachedTenantMedia(TempTenantMedia, false);
        MediaCleanup.GetTenantMediaFromDetachedMediaSet(TempTenantMedia, false);
    end;

    procedure CreateDetachedMedia(OrphanCount: Integer; Size: Integer)
    var
        TenantMedia: Record "Tenant Media";
        MediaOutStream: OutStream;
        OrphanNo: Integer;
        i: Integer;
    begin
        for OrphanNo := 1 to OrphanCount do begin
            TenantMedia.ID := Any.GuidValue();
            TenantMedia.Content.CreateOutStream(MediaOutStream);
            for i := 1 to Round(Size / 100, 1) do
                MediaOutStream.Write('1234567890qwertyuiopåasdfghjklæøzxcvbnm,.-¨''-.<>\½1234567890qwertyuiopåasdfghjklæøzxcvbnm,.-¨''-.<>\½');
            TenantMedia.Insert();
        end;
    end;

    procedure CreateDetachedMediaThroughMediaSet(OrphanCount: Integer; Size: Integer)
    var
        TenantMediaSet: Record "Tenant Media Set";
        TempBlob: Codeunit "Temp Blob";
        MediaOutStream: OutStream;
        OrphanNo: Integer;
        i: Integer;
    begin
        TenantMediaSet.ID := Any.GuidValue();
        for OrphanNo := 1 to OrphanCount do begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(MediaOutStream);
            for i := 1 to Size / 100 do
                MediaOutStream.Write('1234567890qwertyuiopåasdfghjklæøzxcvbnm,.-¨''-.<>\½1234567890qwertyuiopåasdfghjklæøzxcvbnm,.-¨''-.<>\½');

            TenantMediaSet."Media ID".ImportStream(TempBlob.CreateInStream(), '');
            TenantMediaSet.Insert();
        end;
    end;

}
