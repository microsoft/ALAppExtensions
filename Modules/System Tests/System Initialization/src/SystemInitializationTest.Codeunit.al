// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 130045 "System Initialization Test"
{
    // Tests for the System Initialization codeunit
    Subtype = Test;
    EventSubscriberInstance = Manual;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        LibrarySignupContext: Codeunit "Library - Signup Context";
        EventInvocationCounter: Integer;
        IsInitialized: Boolean;

    [Test]
    [HandlerFunctions('PasswordDialogModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestPasswordDialogCanBeOpenedAfterSystemInitialization()
    var
        CompanyTriggers: Codeunit "Company Triggers";
        PasswordDialogManagement: Codeunit "Password Dialog Management";
        PermissionsMock: Codeunit "Permissions Mock";
        OldPassword: Text;
        NewPassword: Text;
    begin
        PermissionsMock.Set('System Init Exec');
        // [WHEN] Calling CompanyTriggers.OnCompanyOpen()
        CompanyTriggers.OnCompanyOpenCompleted();

        // [THEN] Calling PasswordDialog.OpenChangePasswordDialog should NOT results in an error
        PasswordDialogManagement.OpenChangePasswordDialog(OldPassword, NewPassword);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure PasswordDialogModalPageHandler(var PasswordDialog: Page "Password Dialog"; var Response: Action)
    begin
        Response := ACTION::OK;
    end;

    [Test]
    procedure TestSignupContextNotSet()
    var
        SignupContextValues: Record "Signup Context Values";
    begin
        // Init
        Initialize();

        // Setup
        LibrarySignupContext.SetBlankSignupContext();

        // Exercise
        TriggerOnCompanyOpen();

        // Verify
        SignupContextValues.Get();
        Assert.AreEqual(enum::"Signup Context"::" ", SignupContextValues."Signup Context", 'The signup context is not blank.');
    end;

    [Test]
    procedure TestSignupContextUnknown()
    var
        SignupContextValues: Record "Signup Context Values";
    begin
        // Init
        Initialize();

        // Setup
        LibrarySignupContext.SetUnknownSignupContext();

        // Exercise
        TriggerOnCompanyOpen();

        // Verify
        SignupContextValues.Get();
        Assert.AreEqual(enum::"Signup Context"::" ", SignupContextValues."Signup Context", 'The signup context is not blank.');
    end;

    [Test]
    procedure TestSignupContextViral()
    var
        SignupContextValues: Record "Signup Context Values";
    begin
        // Init
        Initialize();

        // Setup
        LibrarySignupContext.SetViralSignupContext();

        // Exercise
        TriggerOnCompanyOpen();

        // Verify
        SignupContextValues.Get();
        Assert.AreEqual(enum::"Signup Context"::"Viral Signup", SignupContextValues."Signup Context", 'The signup context is not Viral Signup.');
    end;

    [Test]
    procedure TestSignupContextNotPassed()
    var
        SignupContextValues: Record "Signup Context Values";
    begin
        // Init
        Initialize();

        // Setup
        Assert.TableIsEmpty(Database::"Signup Context");

        // Exercise
        TriggerOnCompanyOpen();

        // Verify
        SignupContextValues.Get();
        Assert.AreEqual(enum::"Signup Context"::" ", SignupContextValues."Signup Context", 'The signup context is not Viral Signup.');
    end;

    [Test]
    procedure TestSignupContextValuesParsed()
    var
        SignupContextValues: Record "Signup Context Values";
        SystemInitializationTest: Codeunit "System Initialization Test";
    begin
        // Init
        Initialize();
        BindSubscription(SystemInitializationTest);

        // Setup
        LibrarySignupContext.SetTestValueSignupContext();

        // Exercise
        TriggerOnCompanyOpen();

        // Verify
        SignupContextValues.Get();
        Assert.AreEqual(enum::"Signup Context"::"Test Value", SignupContextValues."Signup Context", 'The signup context is not Test Value.');
    end;

    [Test]
    procedure TestSignupContextValuesNotParsed()
    var
        SignupContextValues: Record "Signup Context Values";
    begin
        // Init
        Initialize();
        // no bound subscriber to parse the value

        // Setup
        LibrarySignupContext.SetTestValueSignupContext();

        // Exercise
        TriggerOnCompanyOpen();

        // Verify
        SignupContextValues.Get();
        Assert.AreEqual(enum::"Signup Context"::" ", SignupContextValues."Signup Context", 'The signup context is not Viral Signup.');
    end;

    [Test]
    procedure SignupContextIsOnlyPopulatedOnce()
    var
        SignupContextValues: Record "Signup Context Values";
        SystemInitializationTest: Codeunit "System Initialization Test";
    begin
        Initialize();
        BindSubscription(SystemInitializationTest);

        // [GIVEN] The set signup context event was never invoked
        EventInvocationCounter := 0;
        LibrarySignupContext.SetTestValueSignupContext();

        // [WHEN] Calling OnCompanyOpen
        TriggerOnCompanyOpen();

        // Exercise 
        SignupContextValues.Get();
        Assert.AreEqual(1, SystemInitializationTest.GetEventInvocationCounter(), 'The SetSignupContext event should be called when company is opened.');
        Assert.AreEqual(Enum::"Signup Context"::"Test Value", SignupContextValues."Signup Context", 'The signup context must be set Test Value by the test subscriber.');

        // [WHEN] Calling OnCompanyOpen again
        TriggerOnCompanyOpen();

        Assert.AreEqual(1, SystemInitializationTest.GetEventInvocationCounter(), 'The SetSignupContext event should be called only when company is opened.');
    end;

    local procedure Initialize()
    begin
        LibrarySignupContext.DeleteSignupContext();
        LibrarySignupContext.SetDisableSystemUserCheck();

        if IsInitialized then
            exit;

        IsInitialized := true;

        Commit();
    end;

    local procedure TriggerOnCompanyOpen()
    var
        CompanyTriggers: Codeunit "Company Triggers";
    begin
        // [WHEN] Calling OnCompanyOpen once
#if not CLEAN20
#pragma warning disable AL0432
#endif
        CompanyTriggers.OnCompanyOpen();
#if not CLEAN20
#pragma warning restore AL0432
#endif
        Commit(); // Need to commit before calling isolated event OnCompanyOpenCompleted
        CompanyTriggers.OnCompanyOpenCompleted();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnSetSignupContext', '', false, false)]
    local procedure SetContextOnSetSignupContext(SignupContext: Record "Signup Context"; var SignupContextValues: Record "Signup Context Values")
    begin
        EventInvocationCounter += 1;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnSetSignupContext', '', false, false)]
    local procedure SetTestValueContextOnSetSignupContext(SignupContext: Record "Signup Context"; var SignupContextValues: Record "Signup Context Values")
    begin
        if not (SignupContext.KeyName = 'name') then
            exit;

        if not (SignupContext.Value = 'Test Value') then
            exit;

        SignupContextValues."Signup Context" := SignupContextValues."Signup Context"::"Test Value";
        SignupContextValues.Insert();
    end;

    internal procedure GetEventInvocationCounter(): Integer
    begin
        exit(EventInvocationCounter)
    end;
}
