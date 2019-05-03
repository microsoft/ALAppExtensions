// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135091 "Environment Information Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        EnvironmentInformation: Codeunit "Environment Information";

    [Test]
    [Scope('OnPrem')]
    procedure TestIsSandboxIsTrueWhenTestibilitySandboxIsSet()
    begin
        // [Scenario] Set the testability to true. IsSandBox returns correct values.

        // [Given] Set the testability sandbox to True
        EnvironmentInformation.SetTestabilitySandbox(true);

        // [When] Poll for IsSandbox
        // [Then] Should return true
        Assert.IsTrue(EnvironmentInformation.IsSandbox, 'Testability should have dictacted a sandbox environment');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestIsSandboxIsFalseWhenTestibilitySandboxIsNotSet()
    begin
        // [Scenario] Set the testability to false. IsSandBox returns correct values.

        // [Given] Set the testability sandbox to false
        EnvironmentInformation.SetTestabilitySandbox(false);

        // [When] Poll for IsSandbox
        // [Then] Should return false
        Assert.IsFalse(EnvironmentInformation.IsSandbox, 'Testability should have dictacted a non-sandbox environment');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestIsSaaSIsTrueWhenTestibilitySaaSIsSet()
    begin
        // [SCENARIO] Set the testability to true. IsSaaS returns correct values.

        // [Given] Set the testability SaaS to true
        EnvironmentInformation.SetTestabilitySoftwareAsAService(true);

        // [When] Poll for IsSaaS
        // [Then] Should return true
        Assert.IsTrue(EnvironmentInformation.IsSaaS, 'Testability should have dictacted a SaaS environment');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestIsSaaSIsFalseWhenTestibilitySaaSIsNotSet()
    begin
        // [SCENARIO] Set the testability to false. IsSaaS returns correct values.

        // [Given] Set the testability SaaS to false
        EnvironmentInformation.SetTestabilitySoftwareAsAService(false);

        // [When] Poll for IsSaaS
        // [Then] Should return false
        Assert.IsFalse(EnvironmentInformation.IsSaaS, 'Testability should have dictacted a non- SaaS environment');
    end;
}

