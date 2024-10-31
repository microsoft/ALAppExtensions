codeunit 134414 "Service Connection Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Document Exchange Service] [Service Connections] [UI]
    end;

    var
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";

    [Test]
    [Scope('OnPrem')]
    procedure VerifyDocExchServiceConnection()
    var
        DocExchServiceSetup: Record "Doc. Exch. Service Setup";
    begin
        // Setup
        Initialize();
        if not DocExchServiceSetup.Get() then begin
            DocExchServiceSetup.Init();
            DocExchServiceSetup.Insert();
        end;
        // Exercise & Verify
        Assert.IsTrue(
          ServiceExist(DocExchServiceSetup.TableCaption()),
          'DocExchService Setup Connection are not recognized');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VerifyNoDocExchServiceConnectionExist()
    var
        DocExchServiceSetup: Record "Doc. Exch. Service Setup";
    begin
        // Setup
        Initialize();
        if DocExchServiceSetup.Get() then
            DocExchServiceSetup.Delete();
        // Exercise & Verify
        Assert.IsTrue(
          ServiceExist(DocExchServiceSetup.TableCaption()),
          'DocExchService Setup Connection should be created automatically');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VerifyBankDataConvServiceSetupConnection()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        // Setup
        Initialize();
        // Exercise & Verify
        Assert.IsTrue(
          ServiceExist(AMCBankingSetup.TableCaption()),
          'AMC Banking Setup Connection are not recognized')
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VerifyBankDataConvServiceSetupDisableConnection()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        ServiceConnection: Record "Service Connection";
    begin
        // Setup
        Initialize();
        AMCBankingSetup.Get();
        AMCBankingSetup."Service URL" := '';
        AMCBankingSetup.Modify();
        ServiceConnection.Status := ServiceConnection.Status::Disabled;

        // Exercise & Verify
        Assert.IsTrue(
          ServiceExist(AMCBankingSetup.TableCaption()),
          'AMC Banking Setup Connection are not recognized');
        Assert.IsTrue(
          ServiceExistWithStatusAsExpected(AMCBankingSetup.TableCaption(), ServiceConnection),
          'AMC Banking Setup Connection have wrong status');
    end;

    local procedure Initialize()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Service Connection Test");
        if not AMCBankingSetup.Get() then begin
            AMCBankingSetup.Init();
            AMCBankingSetup.Insert();
        end;
        AMCBankingSetup."AMC Enabled" := true;
        AMCBankingSetup.Modify();
    end;

    local procedure ServiceExist(Desc: Text): Boolean
    var
        ServiceConnectionsOverview: TestPage "Service Connections";
    begin
        ServiceConnectionsOverview.OpenView();
        ServiceConnectionsOverview.FILTER.SetFilter(Name, Desc);
        ServiceConnectionsOverview.First();
        exit(Format(ServiceConnectionsOverview.Name) = Desc);
    end;

    local procedure ServiceExistWithStatusAsExpected(Desc: Text; ServiceConnection: Record "Service Connection"): Boolean
    var
        ServiceConnectionsOverviewTestPage: TestPage "Service Connections";
    begin
        ServiceConnectionsOverviewTestPage.OpenView();
        ServiceConnectionsOverviewTestPage.FILTER.SetFilter(Name, Desc);
        ServiceConnectionsOverviewTestPage.First();
        exit(Format(ServiceConnectionsOverviewTestPage.Status) = Format(ServiceConnection.Status));
    end;
}

