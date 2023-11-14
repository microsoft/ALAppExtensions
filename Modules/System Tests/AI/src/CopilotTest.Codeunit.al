namespace System.Test.AI;

using System.AI;
using System.TestLibraries.Utilities;
using System.TestLibraries.AI;

codeunit 132683 "Copilot Test"
{
    Subtype = Test;

    var
        CopilotCapability: Codeunit "Copilot Capability";
        CopilotTestLibrary: Codeunit "Copilot Test Library";
        LibraryAssert: Codeunit "Library Assert";
        LearnMoreUrlLbl: Label 'http://LearnMore.com', Locked = true;
        LearnMoreUrl2Lbl: Label 'http://LearnMore2.com', Locked = true;
        NotRegisteredErr: Label 'Copilot capability has not been registered by the module.';
        AlreadyRegisteredErr: Label 'Capability has already been registered.';

    [Test]
    procedure TestRegisterCapability()
    var
        CopilotSettingsTestLibrary: Codeunit "Copilot Settings Test Library";
        CurrentModuleInfo: ModuleInfo;
    begin
        // [SCENARIO] Register a copilot capability

        // [GIVEN] Copilot capability is not registered
        Initialize();

        // [WHEN] RegisterCapability is called
        CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Text Capability", LearnMoreUrlLbl);

        // [THEN] Copilot capability is registered
        LibraryAssert.IsTrue(CopilotSettingsTestLibrary.FindFirst(), 'Copilot capability should be registered');
        LibraryAssert.AreEqual(Enum::"Copilot Capability"::"Text Capability", CopilotSettingsTestLibrary.GetCapability(), 'Copilot capability is not "Text Capability"');

        // [THEN] Registered capability is associated with the current module
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        LibraryAssert.AreEqual(CurrentModuleInfo.Id(), CopilotSettingsTestLibrary.GetAppId(), 'App Id is different from the current module');

        // [THEN] Registered capability is in preview
        LibraryAssert.AreEqual(Enum::"Copilot Availability"::Preview, CopilotSettingsTestLibrary.GetAvailability(), 'Availability is not preview');
    end;

    [Test]
    procedure TestRegisterCapabilityAlreadyRegistered()
    var
        CopilotSettingsTestLibrary: Codeunit "Copilot Settings Test Library";
    begin
        // [SCENARIO] Register a copilot capability

        // [GIVEN] Copilot capability is not registered
        Initialize();

        // [WHEN] RegisterCapability is called
        CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Text Capability", LearnMoreUrlLbl);
        LibraryAssert.IsFalse(CopilotSettingsTestLibrary.IsEmpty(), 'Copilot capability should be registered');

        // [WHEN] RegisterCapability is called again
        asserterror CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Text Capability", LearnMoreUrlLbl);
        LibraryAssert.ExpectedError(AlreadyRegisteredErr);
    end;

    [Test]
    procedure TestRegisterCapabilityWithGAAvailability()
    var
        CopilotSettingsTestLibrary: Codeunit "Copilot Settings Test Library";
        CurrentModuleInfo: ModuleInfo;
    begin
        // [SCENARIO] Register a copilot capability with availability set to Generally Available

        // [GIVEN] Copilot capability is not registered
        Initialize();

        // [WHEN] RegisterCapability is called
        CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Text Capability", Enum::"Copilot Availability"::"Generally Available", LearnMoreUrlLbl);

        // [THEN] Copilot capability is registered
        LibraryAssert.IsTrue(CopilotSettingsTestLibrary.FindFirst(), 'Copilot capability should be registered');
        LibraryAssert.AreEqual(Enum::"Copilot Capability"::"Text Capability", CopilotSettingsTestLibrary.GetCapability(), 'Copilot capability is not "Text Capability"');

        // [THEN] Registered capability is associated with the current module
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        LibraryAssert.AreEqual(CurrentModuleInfo.Id(), CopilotSettingsTestLibrary.GetAppId(), 'App Id is different from the current module');

        // [THEN] Registered capability is generally available
        LibraryAssert.AreEqual(Enum::"Copilot Availability"::"Generally Available", CopilotSettingsTestLibrary.GetAvailability(), 'Availability is not Generally Available');
    end;

    [Test]
    procedure TestModifyCapability()
    var
        CopilotSettingsTestLibrary: Codeunit "Copilot Settings Test Library";
    begin
        // [SCENARIO] Modify a copilot capability

        // [GIVEN] Copilot capability is registered
        Initialize();
        CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Text Capability", LearnMoreUrlLbl);

        // [WHEN] ModifyCapability is called
        CopilotCapability.ModifyCapability(Enum::"Copilot Capability"::"Text Capability", Enum::"Copilot Availability"::"Generally Available", LearnMoreUrl2Lbl);

        // [THEN] Copilot capability is modified
        CopilotSettingsTestLibrary.FindFirst();
        LibraryAssert.AreEqual(Enum::"Copilot Availability"::"Generally Available", CopilotSettingsTestLibrary.GetAvailability(), 'Availability is not Generally Available');
        LibraryAssert.AreEqual(LearnMoreUrl2Lbl, CopilotSettingsTestLibrary.GetLearnMoreUrl(), 'Learn More Url is not updated');
        LibraryAssert.AreEqual(Enum::"Copilot Status"::Active, CopilotSettingsTestLibrary.GetStatus(), 'Status is not Active');
    end;

    [Test]
    procedure TestModifyCapabilityInactiveCapabilityToGA()
    var
        CopilotSettingsTestLibrary: Codeunit "Copilot Settings Test Library";
    begin
        // [SCENARIO] Modify a copilot capability

        // [GIVEN] Copilot capability is registered
        Initialize();
        CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Text Capability", LearnMoreUrlLbl);
        CopilotTestLibrary.SetCopilotStatus(Enum::"Copilot Capability"::"Text Capability", GetModuleAppId(), Enum::"Copilot Status"::Inactive);

        CopilotSettingsTestLibrary.FindFirst();
        LibraryAssert.AreEqual(Enum::"Copilot Status"::Inactive, CopilotSettingsTestLibrary.GetStatus(), 'Status is not Inactive');

        // [WHEN] ModifyCapability is called
        CopilotCapability.ModifyCapability(Enum::"Copilot Capability"::"Text Capability", Enum::"Copilot Availability"::"Generally Available", LearnMoreUrl2Lbl);

        // [THEN] Copilot capability is modified
        CopilotSettingsTestLibrary.FindFirst();
        LibraryAssert.AreEqual(Enum::"Copilot Availability"::"Generally Available", CopilotSettingsTestLibrary.GetAvailability(), 'Availability is not Generally Available');
        LibraryAssert.AreEqual(LearnMoreUrl2Lbl, CopilotSettingsTestLibrary.GetLearnMoreUrl(), 'Learn More Url is not updated');
        LibraryAssert.AreEqual(Enum::"Copilot Status"::Active, CopilotSettingsTestLibrary.GetStatus(), 'Status is not Active');
    end;

    [Test]
    procedure TestUnregisterCapability()
    var
        CopilotSettingsTestLibrary: Codeunit "Copilot Settings Test Library";
    begin
        // [SCENARIO] Unregister a copilot capability

        // [GIVEN] Copilot capability is registered
        Initialize();
        CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Text Capability", LearnMoreUrlLbl);

        // [THEN]
        LibraryAssert.IsFalse(CopilotSettingsTestLibrary.IsEmpty(), 'Copilot capability should be registered');

        // [WHEN] UnregisterCapability is called
        CopilotCapability.UnregisterCapability(Enum::"Copilot Capability"::"Text Capability");

        // [THEN] Copilot capability is unregistered
        LibraryAssert.IsTrue(CopilotSettingsTestLibrary.IsEmpty(), 'Copilot capability should be unregistered');
    end;

    [Test]
    procedure TestUnregisterCapabilityOfAnotherModule()
    var
        CopilotSettingsTestLibrary: Codeunit "Copilot Settings Test Library";
    begin
        // [SCENARIO] Try to unregister a copilot capability of another module

        // [GIVEN] Copilot capability is registered from another module
        Initialize();
        CopilotTestLibrary.RegisterCopilotCapability(Enum::"Copilot Capability"::"Text Capability");

        // [WHEN] UnregisterCapability is called
        asserterror CopilotCapability.UnregisterCapability(Enum::"Copilot Capability"::"Text Capability");

        // [THEN] Error is thrown
        LibraryAssert.ExpectedError(NotRegisteredErr);

        // [THEN] Copilot capability is still registered
        LibraryAssert.IsFalse(CopilotSettingsTestLibrary.IsEmpty(), 'Copilot capability should be registered');
    end;

    [Test]
    procedure TestIsCapabilityRegistered()
    begin
        // [SCENARIO] Check if a copilot capability is registered after registering

        // [GIVEN] Copilot capability is registered
        Initialize();
        CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Text Capability", LearnMoreUrlLbl);

        // [WHEN] IsCapabilityRegistered is called
        // [THEN] True is returned
        LibraryAssert.IsTrue(CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Text Capability"), 'Copilot capability should be registered');
    end;

    [Test]
    procedure TestIsCapabilityRegisteredOfCapabilityFromAnotherModule()
    var
        ModuleGuid: Guid;
    begin
        // [SCENARIO] Check if a copilot capability is registered after registering

        // [GIVEN] Copilot capability from another module is registered
        Initialize();
        CopilotTestLibrary.RegisterCopilotCapability(Enum::"Copilot Capability"::"Text Capability", ModuleGuid);

        // [WHEN] IsCapabilityRegistered is called
        // [THEN] False is returned
        LibraryAssert.IsFalse(CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Text Capability"), 'Copilot capability should not be registered');

        // [WHEN] IsCapabilityRegistered is called with the module id of the system test library
        // [THEN] True is returned
        LibraryAssert.IsTrue(CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Text Capability", ModuleGuid), 'Copilot capability should be registered');
    end;

    [Test]
    procedure TestIsCapabilityRegisteredWithoutRegistering()
    begin
        // [SCENARIO] Check if a copilot capability is registered without registering

        // [GIVEN] Copilot capability is not registered
        Initialize();

        // [WHEN] IsCapabilityRegistered is called
        // [THEN] False is returned
        LibraryAssert.IsFalse(CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Text Capability"), 'Copilot capability should not be registered');
    end;

    [Test]
    procedure TestIsCapabilityActive()
    begin
        // [SCENARIO] Check if a copilot capability is active after registering

        // [GIVEN] Copilot capability is registered
        Initialize();
        CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Text Capability", LearnMoreUrlLbl);

        // [WHEN] IsCapabilityActive is called
        // [THEN] True is returned
        LibraryAssert.IsTrue(CopilotCapability.IsCapabilityActive(Enum::"Copilot Capability"::"Text Capability"), 'Copilot capability should be enabled');
    end;

    [Test]
    procedure TestIsCapabilityActiveOnInactiveCapability()
    begin
        // [SCENARIO] Check if a copilot capability is active after setting to inactive

        // [GIVEN] Copilot capability is registered and status set to inactive
        Initialize();
        CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Text Capability", LearnMoreUrlLbl);
        CopilotTestLibrary.SetCopilotStatus(Enum::"Copilot Capability"::"Text Capability", GetModuleAppId(), Enum::"Copilot Status"::Inactive);

        // [WHEN] IsCapabilityActive is called
        // [THEN] False is returned
        LibraryAssert.IsFalse(CopilotCapability.IsCapabilityActive(Enum::"Copilot Capability"::"Text Capability"), 'Copilot capability should not be enabled');
    end;

    local procedure Initialize()
    var
        CopilotSettingsTestLibrary: Codeunit "Copilot Settings Test Library";
    begin
        CopilotSettingsTestLibrary.DeleteAll();
    end;

    local procedure GetModuleAppId(): Guid
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        exit(CurrentModuleInfo.Id());
    end;
}