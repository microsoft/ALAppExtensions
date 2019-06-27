// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132700 "Test Client Type Management"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        ClientTypeManagement: Codeunit "Client Type Management";

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure ClientTypeMgtIsClientType()
    begin
        // [FEATURE] [CLIENTTYPE] [UT]
        // [GIVEN, WHEN, THEN] When get current client type is polled, 
        // the default should never be Phone, as the tests are not executed from a Phone client but from a Windows client
        Assert.IsFalse(ClientTypeManagement.GetCurrentClientType() = CLIENTTYPE::Phone, 'Should not be Phone');
        Assert.AreEqual(Format(ClientTypeManagement.GetCurrentClientType()),
          Format(CLIENTTYPE::Web), 'Should be Web client')
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure ClientTypeSetForTestPurpose()
    var
        TestClientTypeSubscriber: Codeunit "Test Client Type Subscriber";
    begin
        // [FEATURE] [CLIENTTYPE] [UT]
        // [GIVEN] Subscription is bound so that the GetCurrentClientType should return Phone
        BindSubscription(TestClientTypeSubscriber);
        TestClientTypeSubscriber.SetClientType(CLIENTTYPE::Phone);

        // [WHEN, THEN] When the call is made, a Phone client is returned.	
        Assert.IsTrue(ClientTypeManagement.GetCurrentClientType() = CLIENTTYPE::Phone, 'Should be Phone client type');

        UnbindSubscription(TestClientTypeSubscriber);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure ClientTypeIsWindowsClient()
    var
        TestClientTypeSubscriber: Codeunit "Test Client Type Subscriber";
    begin
        // [FEATURE] [CLIENTTYPE] [UT]
        BindSubscription(TestClientTypeSubscriber);

        // [GIVEN] A non-windows client is simulated
        TestClientTypeSubscriber.SetClientType(CLIENTTYPE::Web);
        // [WHEN, THEN] The current client type does not return Windows
        Assert.IsFalse(ClientTypeManagement.GetCurrentClientType() = CLIENTTYPE::Windows, 'Should not be Windows client type');

        // [GIVEN] A non-windows client is simulated
        TestClientTypeSubscriber.SetClientType(CLIENTTYPE::Windows);
        // [WHEN, THEN] The current client type returns Windows
        Assert.IsTrue(ClientTypeManagement.GetCurrentClientType() = CLIENTTYPE::Windows, 'Should be Windows client type');

        UnbindSubscription(TestClientTypeSubscriber);
    end;
}

