// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Security.AccessControl;

using System.Security.AccessControl;
using System.Utilities;
using System.TestLibraries.Utilities;

codeunit 132437 "Permission Import Export Tests"
{
    // [FEATURE] [Permission Sets] [UT]

    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";
        Scope: Option System,Tenant;

    [Test]
    [Scope('OnPrem')]
    procedure ExportImportSingleSystemPermissions()
    var
        TenantPermission: Record "Tenant Permission";
        TenantPermissionSet: Record "Tenant Permission Set";
        MetadataPermissionSet: Record "Metadata Permission Set";
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        ZeroGuid: Guid;
    begin
        // [FEATURE] [Import] [XMLPORT] [Permission Set] [Tenant Permission Set]
        // [SCENARIO] System permission set is exported and imported as tenant permission set

        Initialize();

        // [GIVEN] System PS "Permission Set B" and "Permission Set A". B includes A. A and B includes permission to "Test Permission Table"
        MetadataPermissionSet.SetFilter("Role ID", 'Permission Set B');

        TempBlob.CreateOutStream(OutStr);
        // [WHEN] Export System permission set
        Xmlport.Export(Xmlport::"Export Permission Sets System", OutStr, MetadataPermissionSet);

        // [GIVEN] System PS are not found in Tenant permission tables
        TenantPermissionSet.SetFilter("Role ID", 'Permission Set B');
        LibraryAssert.RecordIsEmpty(TenantPermissionSet);
        TenantPermissionSetRel.SetFilter("Role ID", 'Permission Set B');
        LibraryAssert.RecordIsEmpty(TenantPermissionSetRel);

        // [WHEN] Import exported permission set
        TempBlob.CreateInStream(InStr);
        Xmlport.Import(Xmlport::"Import Permission Sets", InStr);

        MetadataPermissionSet.SetFilter("Role ID", 'Permission Set A');
        MetadataPermissionSet.FindFirst();

        // [THEN] System PS "Permission Set B" is now found as a tenant permission set with relation
        LibraryAssert.IsTrue(TenantPermissionSet.Get(ZeroGuid, 'Permission Set B'), 'Permission Set B is missing');
        LibraryAssert.IsTrue(TenantPermissionSetRel.Get(ZeroGuid, TenantPermissionSet."Role ID", MetadataPermissionSet."App ID", MetadataPermissionSet."Role ID"), 'Permission set relation to Set A is missing');
        LibraryAssert.IsTrue(TenantPermission.Get(ZeroGuid, TenantPermissionSet."Role ID", TenantPermission."Object Type"::"Table Data", Database::"Tenant Permission"), 'Included permission to Set A is missing');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ExportImportSystemPermissionWithPartialPermissions()
    var
        TenantPermission: Record "Tenant Permission";
        TenantPermissionSet: Record "Tenant Permission Set";
        MetadataPermissionSet: Record "Metadata Permission Set";
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        ZeroGuid: Guid;
    begin
        // [FEATURE] [Import] [XMLPORT] [Permission Set] [Tenant Permission Set]
        // [SCENARIO] System permission set is exported and imported as tenant permission set. The permissions are set correctly.

        Initialize();

        // [GIVEN] System PS "Permission Set C" and includes permission to "Tenant Permission Table"
        MetadataPermissionSet.SetFilter("Role ID", 'Permission Set C');

        TempBlob.CreateOutStream(OutStr);
        // [WHEN] Export System permission set
        Xmlport.Export(Xmlport::"Export Permission Sets System", OutStr, MetadataPermissionSet);

        // [GIVEN] System PS are not found in Tenant permission tables
        TenantPermissionSet.SetFilter("Role ID", 'Permission Set C');
        LibraryAssert.RecordIsEmpty(TenantPermissionSet);
        TenantPermissionSetRel.SetFilter("Role ID", 'Permission Set C');
        LibraryAssert.RecordIsEmpty(TenantPermissionSetRel);

        // [WHEN] Import exported permission set
        TempBlob.CreateInStream(InStr);
        Xmlport.Import(Xmlport::"Import Permission Sets", InStr);

        // [THEN] System PS "Permission Set C" is now found as a tenant permission set with relation
        LibraryAssert.IsTrue(TenantPermissionSet.Get(ZeroGuid, 'Permission Set C'), 'Permission Set C is missing');
        LibraryAssert.IsTrue(TenantPermission.Get(ZeroGuid, TenantPermissionSet."Role ID", TenantPermission."Object Type"::"Table Data", Database::"Tenant Permission"), 'Included permission to Set C is missing');
        LibraryAssert.AreEqual(TenantPermission."Read Permission", TenantPermission."Read Permission"::Yes, 'Read permission is not set correctly.');
        LibraryAssert.AreEqual(TenantPermission."Insert Permission", TenantPermission."Insert Permission"::Indirect, 'Insert permission is not set correctly.');
        LibraryAssert.AreEqual(TenantPermission."Modify Permission", TenantPermission."Modify Permission"::Indirect, 'Modify permission is not set correctly.');
        LibraryAssert.AreEqual(TenantPermission."Delete Permission", TenantPermission."Delete Permission"::" ", 'Delete permission is not set correctly.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ExportImportMultipleSystemPermissions()
    var
        TenantPermission: Record "Tenant Permission";
        TenantPermissionSet: Record "Tenant Permission Set";
        MetadataPermissionSet: Record "Metadata Permission Set";
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        ZeroGuid: Guid;
    begin
        // [FEATURE] [Import] [XMLPORT] [Permission Set] [Tenant Permission Set]
        // [SCENARIO] System permission set is exported and imported as tenant permission set

        Initialize();

        // [GIVEN] System PS "Permission Set B" and "Permission Set A". B includes A. A and B includes permission to "Test Permission Table"
        MetadataPermissionSet.SetFilter("Role ID", '%1|%2', 'Permission Set B', 'Permission Set A');

        TempBlob.CreateOutStream(OutStr);
        // [WHEN] Export System permission set
        Xmlport.Export(Xmlport::"Export Permission Sets System", OutStr, MetadataPermissionSet);

        // [GIVEN] System PS are not found in Tenant permission tables
        TenantPermissionSet.SetFilter("Role ID", '%1|%2', 'Permission Set B', 'Permission Set A');
        LibraryAssert.RecordIsEmpty(TenantPermissionSet);
        TenantPermissionSetRel.SetFilter("Role ID", '%1|%2', 'Permission Set B', 'Permission Set A');
        LibraryAssert.RecordIsEmpty(TenantPermissionSetRel);

        // [WHEN] Import exported permission set
        TempBlob.CreateInStream(InStr);
        Xmlport.Import(Xmlport::"Import Permission Sets", InStr);

        MetadataPermissionSet.SetFilter("Role ID", 'Permission Set A');
        MetadataPermissionSet.FindFirst();

        // [THEN] System PS "Permission Set B" is now found as a tenant permission set with relation
        LibraryAssert.IsTrue(TenantPermissionSet.Get(ZeroGuid, 'Permission Set B'), 'Permission Set B is missing');
        LibraryAssert.IsTrue(TenantPermissionSetRel.Get(ZeroGuid, TenantPermissionSet."Role ID", MetadataPermissionSet."App ID", MetadataPermissionSet."Role ID"), 'Permission set relation to Set A is missing');
        LibraryAssert.IsTrue(TenantPermission.Get(ZeroGuid, TenantPermissionSet."Role ID", TenantPermission."Object Type"::"Table Data", Database::"Tenant Permission"), 'Included permission to Set A is missing');

        // [THEN] System PS "Permission Set A" is now found as a tenant permission set with relation
        LibraryAssert.IsTrue(TenantPermissionSet.Get(ZeroGuid, 'Permission Set A'), 'Permission Set A is missing');
        LibraryAssert.IsTrue(TenantPermission.Get(ZeroGuid, TenantPermissionSet."Role ID", TenantPermission."Object Type"::"Table Data", Database::"Tenant Permission"), 'Included permission to Set B is missing');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ExportImportTenantPermissionSet()
    var
        TenantPermission: Record "Tenant Permission";
        TenantPermissionSet: Record "Tenant Permission Set";
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        ZeroGuid: Guid;
        AppId: Guid;
        NewRoleId: Code[30];
        NewName: Text;
    begin
        // [FEATURE] [Import] [XMLPORT] [Permission Set] [Tenant Permission Set]
        // [SCENARIO] Tenant permission set is exported and imported.

        Initialize();

        NewRoleId := 'Test Permission Set';
        NewName := 'Test Permission Set';

        // [WHEN] Permission Set C is cloned to get a tenant permission set
        PermissionSetRelation.CopyPermissionSet(NewRoleId, NewName, 'Permission Set C', AppId, Scope::System, Enum::"Permission Set Copy Type"::Clone);

        TenantPermissionSet.SetFilter("Role ID", NewRoleId);
        TempBlob.CreateOutStream(OutStr);

        // [WHEN] Export Tenant permission set
        Xmlport.Export(Xmlport::"Export Permission Sets Tenant", OutStr, TenantPermissionSet);

        // [WHEN] No tenant permission sets exists
        TenantPermissionSet.DeleteAll();
        TenantPermissionSet.SetFilter("Role ID", NewRoleId);
        LibraryAssert.RecordIsEmpty(TenantPermissionSet);
        TenantPermissionSetRel.SetFilter("Role ID", NewRoleId);
        LibraryAssert.RecordIsEmpty(TenantPermissionSetRel);

        // [WHEN] Import exported tenant permission set
        TempBlob.CreateInStream(InStr);
        Xmlport.Import(Xmlport::"Import Permission Sets", InStr);

        // [THEN] Tenant permission set is found with the correct permissions
        LibraryAssert.IsTrue(TenantPermissionSet.Get(ZeroGuid, NewRoleId), 'Test permission set is missing');
        LibraryAssert.IsTrue(TenantPermission.Get(ZeroGuid, TenantPermissionSet."Role ID", TenantPermission."Object Type"::"Table Data", Database::"Tenant Permission"), 'Included permission to Test permission set is missing');
        LibraryAssert.AreEqual(TenantPermission."Read Permission", TenantPermission."Read Permission"::Yes, 'Read permission is not set correctly.');
        LibraryAssert.AreEqual(TenantPermission."Insert Permission", TenantPermission."Insert Permission"::Indirect, 'Insert permission is not set correctly.');
        LibraryAssert.AreEqual(TenantPermission."Modify Permission", TenantPermission."Modify Permission"::Indirect, 'Modify permission is not set correctly.');
        LibraryAssert.AreEqual(TenantPermission."Delete Permission", TenantPermission."Delete Permission"::" ", 'Delete permission is not set correctly.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ExportImportTenantPermissionSetWithAdditionalPermissions()
    var
        TenantPermission: Record "Tenant Permission";
        TenantPermissionSet: Record "Tenant Permission Set";
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        TempBlobOriginal: Codeunit "Temp Blob";
        TempBlobModified: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        ZeroGuid: Guid;
        AppId: Guid;
        NewRoleId: Code[20];
        NewName: Text;
    begin
        // [FEATURE] [Import] [XMLPORT] [Permission Set] [Tenant Permission Set]
        // [SCENARIO] Tenant permission set is exported and imported. Then the same permission set is imported again with additional permissions and should add those.

        Initialize();

        NewRoleId := 'Test Permission Set';
        NewName := 'Test Permission Set';

        // [WHEN] Permission Set C is cloned to get a tenant permission set
        PermissionSetRelation.CopyPermissionSet(NewRoleId, NewName, 'Permission Set C', AppId, Scope::System, Enum::"Permission Set Copy Type"::Clone);

        TenantPermissionSet.SetFilter("Role ID", NewRoleId);
        TempBlobOriginal.CreateOutStream(OutStr);

        // [WHEN] Export Tenant permission set
        Xmlport.Export(Xmlport::"Export Permission Sets Tenant", OutStr, TenantPermissionSet);

        LibraryAssert.IsTrue(TenantPermissionSet.Get(ZeroGuid, NewRoleId), 'Test permission set is missing');
        LibraryAssert.IsTrue(TenantPermission.Get(ZeroGuid, TenantPermissionSet."Role ID", TenantPermission."Object Type"::"Table Data", Database::"Tenant Permission"), 'Included permission to Test permission set is missing');

        // [WHEN] Existing permission for the permission set is changed
        TenantPermission."Read Permission" := TenantPermission."Read Permission"::" "; // read permission is removed
        TenantPermission."Delete Permission" := TenantPermission."Delete Permission"::Yes; // delete permission is added
        TenantPermission.Modify();

        // [WHEN] A new permission is added to the permission set
        TenantPermission.Init();
        TenantPermission."Role ID" := NewRoleId;
        TenantPermission."Object Type" := TenantPermission."Object Type"::"Table Data";
        TenantPermission."Object ID" := Database::"Metadata Permission";
        TenantPermission."Read Permission" := TenantPermission."Read Permission"::Indirect;
        TenantPermission."Insert Permission" := TenantPermission."Insert Permission"::" ";
        TenantPermission."Modify Permission" := TenantPermission."Modify Permission"::" ";
        TenantPermission."Delete Permission" := TenantPermission."Delete Permission"::" ";
        TenantPermission.Insert();

        // [WHEN] Tenant permission set is exported again
        TempBlobModified.CreateOutStream(OutStr);
        Xmlport.Export(Xmlport::"Export Permission Sets Tenant", OutStr, TenantPermissionSet);

        // [WHEN] No tenant permission sets exists
        TenantPermissionSet.DeleteAll();
        TenantPermissionSet.SetFilter("Role ID", NewRoleId);
        LibraryAssert.RecordIsEmpty(TenantPermissionSet);
        TenantPermissionSetRel.SetFilter("Role ID", NewRoleId);
        LibraryAssert.RecordIsEmpty(TenantPermissionSetRel);

        // [WHEN] Import the original tenant permission set that was exported
        TempBlobOriginal.CreateInStream(InStr);
        Xmlport.Import(Xmlport::"Import Permission Sets", InStr);

        // [THEN] Tenant permission set is found with the correct permissions
        LibraryAssert.IsTrue(TenantPermissionSet.Get(ZeroGuid, NewRoleId), 'Test permission set is missing');
        LibraryAssert.IsTrue(TenantPermission.Get(ZeroGuid, TenantPermissionSet."Role ID", TenantPermission."Object Type"::"Table Data", Database::"Tenant Permission"), 'Included permission to Test permission set is missing');
        LibraryAssert.AreEqual(TenantPermission."Read Permission", TenantPermission."Read Permission"::Yes, 'Read permission is not set correctly.');
        LibraryAssert.AreEqual(TenantPermission."Insert Permission", TenantPermission."Insert Permission"::Indirect, 'Insert permission is not set correctly.');
        LibraryAssert.AreEqual(TenantPermission."Modify Permission", TenantPermission."Modify Permission"::Indirect, 'Modify permission is not set correctly.');
        LibraryAssert.AreEqual(TenantPermission."Delete Permission", TenantPermission."Delete Permission"::" ", 'Delete permission is not set correctly.');
        LibraryAssert.IsFalse(TenantPermission.Get(ZeroGuid, TenantPermissionSet."Role ID", TenantPermission."Object Type"::"Table Data", Database::"Metadata Permission"), 'Metadata permission should not be included');

        // [WHEN] Import the modified tenant permission set
        TempBlobModified.CreateInStream(InStr);
        Xmlport.Import(Xmlport::"Import Permission Sets", InStr);

        // [THEN] Tenant permission set is found with the modified permissions
        LibraryAssert.IsTrue(TenantPermissionSet.Get(ZeroGuid, NewRoleId), 'Test permission set is missing');
        LibraryAssert.IsTrue(TenantPermission.Get(ZeroGuid, TenantPermissionSet."Role ID", TenantPermission."Object Type"::"Table Data", Database::"Tenant Permission"), 'Included permission to Test permission set is missing');
        LibraryAssert.AreEqual(TenantPermission."Read Permission", TenantPermission."Read Permission"::Yes, 'Read permission is not set correctly.'); // Import is additive, the permission should still be there
        LibraryAssert.AreEqual(TenantPermission."Insert Permission", TenantPermission."Insert Permission"::Indirect, 'Insert permission is not set correctly.');
        LibraryAssert.AreEqual(TenantPermission."Modify Permission", TenantPermission."Modify Permission"::Indirect, 'Modify permission is not set correctly.');
        LibraryAssert.AreEqual(TenantPermission."Delete Permission", TenantPermission."Delete Permission"::Yes, 'Delete permission is not set correctly.');
        LibraryAssert.IsTrue(TenantPermission.Get(ZeroGuid, TenantPermissionSet."Role ID", TenantPermission."Object Type"::"Table Data", Database::"Metadata Permission"), 'Included permission to Test permission set is missing');
        LibraryAssert.AreEqual(TenantPermission."Read Permission", TenantPermission."Read Permission"::Indirect, 'Read permission is not set correctly.');
        LibraryAssert.AreEqual(TenantPermission."Insert Permission", TenantPermission."Insert Permission"::" ", 'Insert permission is not set correctly.');
        LibraryAssert.AreEqual(TenantPermission."Modify Permission", TenantPermission."Modify Permission"::" ", 'Modify permission is not set correctly.');
        LibraryAssert.AreEqual(TenantPermission."Delete Permission", TenantPermission."Delete Permission"::" ", 'Delete permission is not set correctly.');
    end;

    local procedure Initialize()
    var
        TenantPermission: Record "Tenant Permission";
        TenantPermissionSet: Record "Tenant Permission Set";
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
    begin
        TenantPermission.DeleteAll();
        TenantPermissionSet.DeleteAll();
        TenantPermissionSetRel.DeleteAll();
    end;
}