// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148090 "MTD Test Permissions"
{
    Subtype = Test;
    TestPermissions = Restrictive;

    trigger OnRun()
    begin
        // [FEATURE] [Making Tax Digital] [Permissions]
    end;

    var
        MTDPayment: Record "MTD Payment";
        MTDLiability: Record "MTD Liability";
        MTDReturnDetails: Record "MTD Return Details";
        MTDMissingFraudPrevHdr: Record "MTD Missing Fraud Prev. Hdr";
        MTDDefaultFraudPrevHdr: Record "MTD Default Fraud Prev. Hdr";
        MTDSessionFraudPrevHdr: Record "MTD Session Fraud Prev. Hdr";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        ReadLbl: Label 'D365 Read', Locked = true;
        TeamMemberLbl: Label 'D365 Team Member', Locked = true;
        BasicLbl: Label 'D365 Basic', Locked = true;
        BasicISVLbl: Label 'D365 BASIC ISV', Locked = true;
        IntelligentCloudLbl: Label 'INTELLIGENT CLOUD', Locked = true;

    [Test]
    procedure D365_Basic()
    begin
        // [SCENARIO 349684] "D365 Basic" has RIMD permission for all tables
        Initialize();
        LibraryLowerPermissions.PushPermissionSetWithoutDefaults(BasicLbl);
        VerifyRIMD(MTDPayment);
        VerifyRIMD(MTDLiability);
        VerifyRIMD(MTDReturnDetails);
        VerifyRIMD(MTDMissingFraudPrevHdr);
        VerifyRIMD(MTDDefaultFraudPrevHdr);
        VerifyRIMD(MTDSessionFraudPrevHdr);
    end;

    [Test]
    procedure D365_BasicISV()
    begin
        // [SCENARIO 349684] "D365 Basic ISV" has RIMD permission for all tables
        Initialize();
        LibraryLowerPermissions.PushPermissionSetWithoutDefaults(BasicISVLbl);
        VerifyRIMD(MTDPayment);
        VerifyRIMD(MTDLiability);
        VerifyRIMD(MTDReturnDetails);
        VerifyRIMD(MTDMissingFraudPrevHdr);
        VerifyRIMD(MTDDefaultFraudPrevHdr);
        VerifyRIMD(MTDSessionFraudPrevHdr);
    end;

    [Test]
    procedure D365_Read()
    begin
        // [SCENARIO 349684] "D365 Read" has R permission for all tables
        Initialize();

        LibraryLowerPermissions.PushPermissionSetWithoutDefaults(ReadLbl);
        VerifyRead(MTDPayment);
        VerifyRead(MTDLiability);
        VerifyRead(MTDReturnDetails);
        VerifyRead(MTDMissingFraudPrevHdr);
        VerifyRead(MTDDefaultFraudPrevHdr);
        VerifyRead(MTDSessionFraudPrevHdr);
    end;

    [Test]
    procedure D365_TEAM_MEMBER()
    begin
        // [SCENARIO 349684] "D365 Team Member" has RM permission for all tables
        Initialize();

        LibraryLowerPermissions.PushPermissionSetWithoutDefaults(TeamMemberLbl);
        VerifyRM(MTDPayment);
        VerifyRM(MTDLiability);
        VerifyRM(MTDReturnDetails);
        VerifyRM(MTDMissingFraudPrevHdr);
        VerifyRM(MTDDefaultFraudPrevHdr);
        VerifyRM(MTDSessionFraudPrevHdr);
    end;

    [Test]
    procedure D365_IntelligentCloud()
    begin
        // [SCENARIO 349684] "D365 Intelligent Cloud" has R permission for all tables
        Initialize();

        LibraryLowerPermissions.PushPermissionSetWithoutDefaults(IntelligentCloudLbl);
        VerifyRead(MTDPayment);
        VerifyRead(MTDLiability);
        VerifyRead(MTDReturnDetails);
        VerifyRead(MTDMissingFraudPrevHdr);
        VerifyRead(MTDDefaultFraudPrevHdr);
        VerifyRead(MTDSessionFraudPrevHdr);
    end;

    local procedure Initialize()
    begin
        LibraryLowerPermissions.SetOutsideO365Scope();

        if MTDPayment.Insert() then;
        if MTDLiability.Insert() then;
        if MTDReturnDetails.Insert() then;
        if MTDMissingFraudPrevHdr.Insert() then;
        if MTDDefaultFraudPrevHdr.Insert() then;
        if MTDSessionFraudPrevHdr.Insert() then;
        Commit();
    end;

    local procedure VerifyRead(RecVariant: Variant)
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(RecVariant);
        RecordRef.FindFirst();
        asserterror RecordRef.Insert();
        asserterror RecordRef.Modify();
        asserterror RecordRef.Delete();
    end;

    local procedure VerifyRM(RecVariant: Variant)
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(RecVariant);
        RecordRef.FindFirst();
        RecordRef.Modify();
        asserterror RecordRef.Insert();
        asserterror RecordRef.Delete();
    end;

    local procedure VerifyRIMD(RecVariant: Variant)
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(RecVariant);
        RecordRef.FindFirst();
        RecordRef.Modify();
        RecordRef.Delete();
        RecordRef.Insert();
    end;
}
