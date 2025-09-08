// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.ExternalFileStorage;

using System.Environment;
using System.ExternalFileStorage;
using System.TestLibraries.Utilities;

codeunit 144581 "Ext. SharePoint Connector Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('AccountRegisterPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestMultipleAccountsCanBeRegistered()
    var
        FileAccount: Record "File Account";
        ExtFileConnector: Codeunit "Ext. SharePoint Connector Impl";
        FileAccounts: TestPage "File Accounts";
        AccountIds: array[3] of Guid;
        AccountName: array[3] of Text[250];
        Index: Integer;
    begin
        // [Scenario] Create multiple accounts
        Initialize();

        // [When] Multiple accounts are registered
        for Index := 1 to 3 do begin
            SetBasicAccount();

            Assert.IsTrue(ExtFileConnector.RegisterAccount(FileAccount), 'Failed to register account.');
            AccountIds[Index] := FileAccount."Account Id";
            AccountName[Index] := FileAccountMock.Name();

            // [Then] Accounts are retrieved from the GetAccounts method
            FileAccount.DeleteAll();
            ExtFileConnector.GetAccounts(FileAccount);
            Assert.RecordCount(FileAccount, Index);
        end;

        FileAccounts.OpenView();
        for Index := 1 to 3 do begin
            FileAccounts.GoToKey(AccountIds[Index], Enum::"Ext. File Storage Connector"::SharePoint);
            Assert.AreEqual(AccountName[Index], FileAccounts.NameField.Value(), 'A different name was expected.');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('AccountRegisterPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestEnviromentCleanupDisablesAccounts()
    var
        FileAccount: Record "File Account";
        ExtSharePointAccount: Record "Ext. SharePoint Account";
        ExtFileConnector: Codeunit "Ext. SharePoint Connector Impl";
        EnvironmentTriggers: Codeunit "Environment Triggers";
        AccountIds: array[3] of Guid;
        Index: Integer;
    begin
        // [Scenario] Create multiple accounts
        Initialize();

        // [When] Multiple accounts are registered
        for Index := 1 to 3 do begin
            SetBasicAccount();

            Assert.IsTrue(ExtFileConnector.RegisterAccount(FileAccount), 'Failed to register account.');
            AccountIds[Index] := FileAccount."Account Id";

            // [Then] Accounts are retrieved from the GetAccounts method
            FileAccount.DeleteAll();
            ExtFileConnector.GetAccounts(FileAccount);
            Assert.RecordCount(FileAccount, Index);
        end;

        ExtSharePointAccount.SetRange(Disabled, true);
        Assert.IsTrue(ExtSharePointAccount.IsEmpty(), 'Accounts are already disabled.');

        EnvironmentTriggers.OnAfterCopyEnvironmentPerCompany(0, Any.AlphabeticText(30), 1, Any.AlphabeticText(30));

        Assert.IsFalse(ExtSharePointAccount.IsEmpty(), 'Accounts are not disabled.');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('AccountRegisterPageHandler,AccountShowPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestShowAccountInformation()
    var
        FileAccount: Record "File Account";
        FileConnector: Codeunit "Ext. SharePoint Connector Impl";
    begin
        // [Scenario] Account Information is displayed in the Account page.

        // [Given] An file account
        Initialize();
        SetBasicAccount();
        FileConnector.RegisterAccount(FileAccount);

        // [When] The ShowAccountInformation method is invoked
        FileConnector.ShowAccountInformation(FileAccount."Account Id");

        // [Then] The account page opens and displays the information
        // Verify in AccountModalPageHandler
    end;

    local procedure Initialize()
    var
        ExtSharePointAccount: Record "Ext. SharePoint Account";
    begin
        ExtSharePointAccount.DeleteAll();
    end;

    local procedure SetBasicAccount()
    begin
        FileAccountMock.Name(CopyStr(Any.AlphanumericText(250), 1, 250));
        FileAccountMock.SharePointUrl(CopyStr(Any.AlphanumericText(250), 1, 250));
        FileAccountMock.BaseRelativeFolderPath(CopyStr(Any.AlphanumericText(250), 1, 250));
        FileAccountMock.TenantId(CreateGuid());
        FileAccountMock.ClientId(CreateGuid());
        FileAccountMock.Password('testpassword');
    end;

    [ModalPageHandler]
    procedure AccountRegisterPageHandler(var AccountWizard: TestPage "Ext. SharePoint Account Wizard")
    begin
        // Setup account
        AccountWizard.NameField.SetValue(FileAccountMock.Name());
        AccountWizard."SharePoint Url".SetValue(FileAccountMock.SharePointUrl());
        AccountWizard."Base Relative Folder Path".SetValue(FileAccountMock.BaseRelativeFolderPath());
        AccountWizard."Tenant Id".SetValue(FileAccountMock.TenantId());
        AccountWizard."Client Id".SetValue(FileAccountMock.ClientId());
        AccountWizard.ClientSecretField.SetValue(FileAccountMock.Password());
        AccountWizard.Next.Invoke();
    end;

    [PageHandler]
    procedure AccountShowPageHandler(var Account: TestPage "Ext. SharePoint Account")
    begin
        // Verify the account
        Assert.AreEqual(FileAccountMock.Name(), Account.NameField.Value(), 'A different name was expected.');
        Assert.AreEqual(FileAccountMock.SharePointUrl(), Account."SharePoint Url".Value(), 'A different sharepoint url was expected.');
        Assert.AreEqual(FileAccountMock.BaseRelativeFolderPath(), Account."Base Relative Folder Path".Value(), 'A different base relative folder path was expected.');
        Assert.AreEqual(Format(FileAccountMock.TenantId()).ToLower(), Format(Account."Tenant Id").ToLower(), 'A different tenant id was expected.');
        Assert.AreEqual(Format(FileAccountMock.ClientId()).ToLower(), Format(Account."Client Id").ToLower(), 'A different client id was expected.');
    end;

    var
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        FileAccountMock: Codeunit "Ext. SharePoint Account Mock";
}