// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132437 "Permission Import Export Tests"
{
    // [FEATURE] [Permission Sets] [UT]

    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";

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