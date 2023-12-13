codeunit 148083 "EET UT CZL"
{
    // // [FEATURE] [EET] [UT]

    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit Assert;
        LibraryEETCZL: Codeunit "Library - EET CZL";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;
        EntryExistsErr: Label 'You cannot delete %1 %2 because there is at least one EET entry.', Comment = '%1 = Table Caption;%2 = Primary Key';
        ProductionEnvironmentQst: Label 'There are still unprocessed EET Entries.\Entering the URL of the production environment, these entries will be registered in a production environment!\\ Do you want to continue?';
        NonproductionEnvironmentQst: Label 'There are still unprocessed EET Entries.\Entering the URL of the non-production environment, these entries will be registered in a non-production environment!\\ Do you want to continue?';
        EETCashRegisterMustBeDeletedErr: Label 'EET Cash Register must be deleted.';
        ServiceURLMustBeFilledByPGURLErr: Label 'Service URL must be filled by playground URL.';
        ServiceURLMustBeErr: Label 'Service URL must be "%1".', Comment = '%1 = url';

    [Test]
    procedure DeleteEETBusinessPremisesWithEETEntries()
    var
        EETBusinessPremisesCZL: Record "EET Business Premises CZL";
    begin
        // [SCENARIO] Delete EET business premises with posted EET entries
        // [GIVEN] Create EET business premises
        // [GIVEN] Create EET entries for created EET business premises
        Initialize();
        CreateEETBusinessPremises(EETBusinessPremisesCZL);
        CreateFakeEntries(EETBusinessPremisesCZL.Code, '');

        // [WHEN] Delete EET business premises
        asserterror EETBusinessPremisesCZL.Delete(true);

        // [THEN] Error occurs
        Assert.ExpectedError(StrSubstNo(EntryExistsErr, EETBusinessPremisesCZL.TableCaption, EETBusinessPremisesCZL.Code));
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler')]
    procedure DeleteEETBusinessPremises()
    var
        EETBusinessPremises: Record "EET Business Premises CZL";
        EETCashRegister: Record "EET Cash Register CZL";
    begin
        // [SCENARIO] Delete EET business premises without posted EET entries
        // [GIVEN] Create EET business premises
        // [GIVEN] Create EET cash register for created EET business premises
        Initialize();
        CreateEETBusinessPremises(EETBusinessPremises);
        CreateEETCashRegister(EETCashRegister, EETBusinessPremises.Code);

        // [WHEN] Delete EET business premises
        EETBusinessPremises.Delete(true);

        // [THEN] EET cash register must be deleted
        Assert.IsFalse(
          EETCashRegister.Get(EETCashRegister."Business Premises Code", EETCashRegister.Code), EETCashRegisterMustBeDeletedErr);
    end;

    [Test]
    procedure DeleteEETCashRegisterWithEETEntries()
    var
        EETBusinessPremises: Record "EET Business Premises CZL";
        EETCashRegister: Record "EET Cash Register CZL";
    begin
        // [SCENARIO] Delete EET cash register with posted EET entries
        // [GIVEN] Create EET business premises
        // [GIVEN] Create EET cash register
        // [GIVEN] Create EET entries for created EET cash register
        Initialize();
        CreateEETBusinessPremises(EETBusinessPremises);
        CreateEETCashRegister(EETCashRegister, EETBusinessPremises.Code);
        CreateFakeEntries(EETCashRegister."Business Premises Code", EETCashRegister.Code);

        // [WHEN] Delete EET business premises
        asserterror EETCashRegister.Delete(true);

        // [THEN] Error occurs
        Assert.ExpectedError(StrSubstNo(EntryExistsErr, EETCashRegister.TableCaption, EETCashRegister.Code));
    end;

    [Test]
    procedure InitEETServiceSetup()
    var
        EETServiceSetup: Record "EET Service Setup CZL";
    begin
        // [SCENARIO] Initialize new EET service setup
        // [GIVEN] Delete actual EET service setup
        Initialize();

        EETServiceSetup.Get();
        EETServiceSetup.Delete(true);

        // [WHEN] Insert new EET service setup
        EETServiceSetup.Init();
        EETServiceSetup.Insert(true);

        // [THEN] Service URL must be filled by playground URL from EET Service Mgt.
        Assert.AreEqual(
          GetWebServicePlayGroundURLTxt(), EETServiceSetup."Service URL", ServiceURLMustBeFilledByPGURLErr);
    end;

    [Test]
    [HandlerFunctions('StrMenuHandler,ConfirmHandler')]
    procedure SetProductionServiceURLToEETServiceSetup()
    begin
        // [SCENARIO] Set production service URL to EET service setup
        SetURLToServiceSetup(GetWebServiceURLTxt());
    end;

    [Test]
    [HandlerFunctions('StrMenuHandler,ConfirmHandler')]
    procedure SetNonproductionServiceURLToEETServiceSetup()
    begin
        // [SCENARIO] Set nonproduction service URL to EET service setup
        SetURLToServiceSetup(GetWebServicePlayGroundURLTxt());
    end;

    local procedure SetURLToServiceSetup(ServiceURL: Text)
    var
        EETServiceSetup: Record "EET Service Setup CZL";
    begin
        // [GIVEN] Create EET entries in state "Send Pending"
        Initialize();

        CreateFakeEntries('', '');

        // [WHEN] SetURLToDefault is called
        case ServiceURL of
            GetWebServiceURLTxt():
                LibraryVariableStorage.Enqueue(1);
            GetWebServicePlayGroundURLTxt():
                LibraryVariableStorage.Enqueue(2);
        end;

        LibraryVariableStorage.Enqueue(ServiceURL);
        EETServiceSetup.SetURLToDefault(true);

        // [THEN] Service URL is filled as expected
        Assert.AreEqual(ServiceURL, EETServiceSetup."Service URL", StrSubstNo(ServiceURLMustBeErr, ServiceURL));
        // Next checks are in the Confirm Handler
    end;

    local procedure Initialize()
    var
        EETServiceSetup: Record "EET Service Setup CZL";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"EET UT CZL");

        LibraryVariableStorage.Clear();
        LibrarySetupStorage.Restore();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"EET UT CZL");

        if not EETServiceSetup.Get() then begin
            EETServiceSetup.Init();
            EETServiceSetup.Insert(true);
        end;

        IsInitialized := true;
        Commit();

        LibrarySetupStorage.Save(Database::"EET Service Setup CZL");
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"EET UT CZL");
    end;

    local procedure CreateEETBusinessPremises(var EETBusinessPremises: Record "EET Business Premises CZL")
    begin
        LibraryEETCZL.CreateEETBusinessPremises(EETBusinessPremises, LibraryEETCZL.GetDefaultBusinessPremisesIdentification());
    end;

    local procedure CreateEETCashRegister(var EETCashRegisterCZL: Record "EET Cash Register CZL"; EETBusinessPremisesCode: Code[10])
    begin
        LibraryEETCZL.CreateEETCashRegister(
          EETCashRegisterCZL, EETBusinessPremisesCode, EETCashRegisterCZL."Cash Register Type"::Default, '');
    end;

    local procedure CreateFakeEntries(BusinessPremisesCode: Code[10]; CashRegisterCode: Code[10])
    var
        EETEntryCZL: Record "EET Entry CZL";
    begin
        EETEntryCZL.DeleteAll();
        EETEntryCZL.Init();
        EETEntryCZL."Business Premises Code" := BusinessPremisesCode;
        EETEntryCZL."Cash Register Code" := CashRegisterCode;
        EETEntryCZL."Receipt Serial No." := LibraryUtility.GenerateRandomCode(EETEntryCZL.FieldNo("Receipt Serial No."), Database::"EET Entry CZL");
        EETEntryCZL.Insert(true);

        EETEntryCZL.ChangeStatus(Enum::"EET Status CZL"::"Send Pending");
        EETEntryCZL.Modify();
    end;

    procedure GetWebServiceURLTxt(): Text[250]
    var
        WebServiceURLTxt: Label 'https://prod.eet.cz/eet/services/EETServiceSOAP/v3', Locked = true;
    begin
        exit(WebServiceURLTxt);
    end;

    procedure GetWebServicePlayGroundURLTxt(): Text[250]
    var
        WebServicePGURLTxt: Label 'https://pg.eet.cz/eet/services/EETServiceSOAP/v3', Locked = true;
    begin
        exit(WebServicePGURLTxt);
    end;


    [ConfirmHandler]
    procedure YesConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        case LibraryVariableStorage.DequeueText() of
            GetWebServiceURLTxt():
                Assert.AreEqual(ProductionEnvironmentQst, Question, '');
            GetWebServicePlayGroundURLTxt():
                Assert.AreEqual(NonproductionEnvironmentQst, Question, '');
        end;

        Reply := true;
    end;

    [StrMenuHandler]
    procedure StrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := LibraryVariableStorage.DequeueInteger();
    end;
}

