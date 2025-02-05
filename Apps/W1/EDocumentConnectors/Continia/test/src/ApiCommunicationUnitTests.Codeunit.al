namespace Microsoft.EServices.EDocumentConnector.Continia;

codeunit 148200 "Api Communication Unit Tests"
{
    Subtype = Test;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure GetParticipation200()
    var
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith200ResponseCodeCase();

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Get Participation
        ApiRequests.GetParticipation(Participation);

        // [Then] Make sure Participation values returned correct
        Assert.AreEqual(ConnectorLibrary.ParticipationId(true), Participation.Id, IncorrectValueErr);
        Assert.AreEqual(Enum::"Registration Status"::InProcess, Participation."Registration Status", IncorrectValueErr);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure GetParticipation400()
    var
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith400ResponseCodeCase();

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Get Participation
        asserterror ApiRequests.GetParticipation(Participation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response400ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure GetParticipation401()
    var
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith401ResponseCodeCase();

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Get Participation
        asserterror ApiRequests.GetParticipation(Participation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response401ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure GetParticipation404()
    var
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith404ResponseCodeCase();

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Get Participation
        asserterror ApiRequests.GetParticipation(Participation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response404ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure GetParticipation500()
    var
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith500ResponseCodeCase();

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Get Participation
        asserterror ApiRequests.GetParticipation(Participation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response500ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PostParticipation200()
    var
        TempParticipation: Record Participation temporary;
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith200ResponseCodeCase();

        // [Given] Filled in Participation info
        ConnectorLibrary.PrepareParticipation(TempParticipation);

        // [When] Post Participation
        ApiRequests.PostParticipation(TempParticipation);

        // [Then] Make sure Participation values returned correct
        ConnectorLibrary.GetParticipation(Participation);
        Assert.AreEqual(ConnectorLibrary.ParticipationId(true), Participation.Id, IncorrectValueErr);
        Assert.AreEqual(Enum::"Registration Status"::Draft, Participation."Registration Status", IncorrectValueErr);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PostParticipation201()
    var
        TempParticipation: Record Participation temporary;
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith201ResponseCodeCase();

        // [Given] Filled in Participation info
        ConnectorLibrary.PrepareParticipation(TempParticipation);

        // [When] Post Participation
        ApiRequests.PostParticipation(TempParticipation);

        // [Then] Make sure Participation values returned correct
        ConnectorLibrary.GetParticipation(Participation);
        Assert.AreEqual(ConnectorLibrary.ParticipationId(true), Participation.Id, IncorrectValueErr);
        Assert.AreEqual(Enum::"Registration Status"::Draft, Participation."Registration Status", IncorrectValueErr);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PostParticipation400()
    var
        TempParticipation: Record Participation temporary;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith400ResponseCodeCase();

        // [Given] Filled in Participation info
        ConnectorLibrary.PrepareParticipation(TempParticipation);

        // [When] Post Participation
        asserterror ApiRequests.PostParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response400ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PostParticipation401()
    var
        TempParticipation: Record Participation temporary;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith401ResponseCodeCase();

        // [Given] Filled in Participation info
        ConnectorLibrary.PrepareParticipation(TempParticipation);

        // [When] Post Participation
        asserterror ApiRequests.PostParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response401ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PostParticipation404()
    var
        TempParticipation: Record Participation temporary;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith404ResponseCodeCase();

        // [Given] Filled in Participation info
        ConnectorLibrary.PrepareParticipation(TempParticipation);

        // [When] Post Participation
        asserterror ApiRequests.PostParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response404ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PostParticipation422()
    var
        TempParticipation: Record Participation temporary;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith422ResponseCodeCase();

        // [Given] Filled in Participation info
        ConnectorLibrary.PrepareParticipation(TempParticipation);

        // [When] Post Participation
        asserterror ApiRequests.PostParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response422ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PostParticipation500()
    var
        TempParticipation: Record Participation temporary;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith500ResponseCodeCase();

        // [Given] Filled in Participation info
        ConnectorLibrary.PrepareParticipation(TempParticipation);

        // [When] Post Participation
        asserterror ApiRequests.PostParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response500ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PatchParticipation200()
    var
        TempParticipation: Record Participation temporary;
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith200ResponseCodeCase();

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Patch Participation
        TempParticipation := Participation;
        ApiRequests.PatchParticipation(TempParticipation);

        // [Then] Make sure Participation values returned correct
        ConnectorLibrary.GetParticipation(Participation);
        Assert.AreEqual(ConnectorLibrary.ParticipationId(true), Participation.Id, IncorrectValueErr);
        Assert.AreEqual(Enum::"Registration Status"::InProcess, Participation."Registration Status", IncorrectValueErr);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PatchParticipation400()
    var
        TempParticipation: Record Participation temporary;
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith400ResponseCodeCase();

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Patch Participation
        TempParticipation := Participation;
        asserterror ApiRequests.PatchParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response400ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PatchParticipation401()
    var
        TempParticipation: Record Participation temporary;
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith401ResponseCodeCase();

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Patch Participation
        TempParticipation := Participation;
        asserterror ApiRequests.PatchParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response401ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PatchParticipation404()
    var
        TempParticipation: Record Participation temporary;
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith404ResponseCodeCase();

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Patch Participation
        TempParticipation := Participation;
        asserterror ApiRequests.PatchParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response404ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PatchParticipation409()
    var
        TempParticipation: Record Participation temporary;
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith409ResponseCodeCase();

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Patch Participation
        TempParticipation := Participation;
        asserterror ApiRequests.PatchParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response409ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PatchParticipation422()
    var
        TempParticipation: Record Participation temporary;
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith422ResponseCodeCase();

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Patch Participation
        TempParticipation := Participation;
        asserterror ApiRequests.PatchParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response422ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PatchParticipation500()
    var
        TempParticipation: Record Participation temporary;
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith500ResponseCodeCase();

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Patch Participation
        TempParticipation := Participation;
        asserterror ApiRequests.PatchParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response500ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure DeleteParticipation200()
    var
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiCaseUrlSegment('200');

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Delete Participation
        ApiRequests.DeleteParticipation(Participation);

        // [Then] Make sure Participation does not exist
        Assert.AreEqual(true, Participation.IsEmpty, 'Participation should not exist');
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure DeleteParticipation202()
    var
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiCaseUrlSegment('202');

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Delete Participation
        ApiRequests.DeleteParticipation(Participation);

        // [Then] Make sure Participation does not exist
        ConnectorLibrary.GetParticipation(Participation);
        Assert.AreEqual(ConnectorLibrary.ParticipationId(true), Participation.Id, IncorrectValueErr);
        Assert.AreEqual(Enum::"Registration Status"::Disabled, Participation."Registration Status", IncorrectValueErr);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure DeleteParticipation400()
    var
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith400ResponseCodeCase();

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Delete Participation
        asserterror ApiRequests.DeleteParticipation(Participation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response400ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure DeleteParticipation401()
    var
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith401ResponseCodeCase();

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Delete Participation
        asserterror ApiRequests.DeleteParticipation(Participation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response401ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure DeleteParticipation404()
    var
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith404ResponseCodeCase();

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Delete Participation
        asserterror ApiRequests.DeleteParticipation(Participation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response404ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure DeleteParticipation422()
    var
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith422ResponseCodeCase();

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Delete Participation
        asserterror ApiRequests.DeleteParticipation(Participation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response422ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure DeleteParticipation500()
    var
        Participation: Record Participation;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith500ResponseCodeCase();

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Delete Participation
        asserterror ApiRequests.DeleteParticipation(Participation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response500ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PostParticipationProfile200()
    var
        Participation: Record Participation;
        TempActivatedNetProf: Record "Activated Net. Prof." temporary;
        ActivatedNetProf: Record "Activated Net. Prof.";
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith200ResponseCodeCase();

        // [Given] a Connected Participation without Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, TempActivatedNetProf);

        // [When] Post Participation Profile
        ApiRequests.PostParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] Make sure Activated Network Profile exists
        Assert.AreEqual(true, ConnectorLibrary.GetActivatedNetworkProfile(ActivatedNetProf), 'Activated Network Profile must exist');
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PostParticipationProfile400()
    var
        Participation: Record Participation;
        TempActivatedNetProf: Record "Activated Net. Prof." temporary;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith400ResponseCodeCase();

        // [Given] a Connected Participation without Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, TempActivatedNetProf);

        // [When] Post Participation Profile
        asserterror ApiRequests.PostParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response400ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PostParticipationProfile401()
    var
        Participation: Record Participation;
        TempActivatedNetProf: Record "Activated Net. Prof." temporary;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith401ResponseCodeCase();

        // [Given] a Connected Participation without Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, TempActivatedNetProf);

        // [When] Post Participation Profile
        asserterror ApiRequests.PostParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response401ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PostParticipationProfile404()
    var
        Participation: Record Participation;
        TempActivatedNetProf: Record "Activated Net. Prof." temporary;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith404ResponseCodeCase();

        // [Given] a Connected Participation without Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, TempActivatedNetProf);

        // [When] Post Participation Profile
        asserterror ApiRequests.PostParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response404ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PostParticipationProfile422()
    var
        Participation: Record Participation;
        TempActivatedNetProf: Record "Activated Net. Prof." temporary;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith422ResponseCodeCase();

        // [Given] a Connected Participation without Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, TempActivatedNetProf);

        // [When] Post Participation Profile
        asserterror ApiRequests.PostParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response422ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PostParticipationProfile500()
    var
        Participation: Record Participation;
        TempActivatedNetProf: Record "Activated Net. Prof." temporary;
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith500ResponseCodeCase();

        // [Given] a Connected Participation without Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, TempActivatedNetProf);

        // [When] Post Participation Profile
        asserterror ApiRequests.PostParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response500ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PatchParticipationProfile200()
    var
        Participation: Record Participation;
        TempActivatedNetProf: Record "Activated Net. Prof." temporary;
        ActivatedNetProf: Record "Activated Net. Prof.";
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith200ResponseCodeCase();

        // [Given] a Connected Participation with Outbound Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf);
        ActivatedNetProf."Profile Direction" := ActivatedNetProf."Profile Direction"::Outbound;
        ActivatedNetProf.Modify();

        // [When] Patch Participation Profile
        TempActivatedNetProf := ActivatedNetProf;
        ApiRequests.PatchParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] Make sure Activated Network Profile values returned correct
        ConnectorLibrary.GetActivatedNetworkProfile(ActivatedNetProf);
        Assert.AreEqual(ConnectorLibrary.ActiveNetworkProfileId(true), ActivatedNetProf.Id, IncorrectValueErr);
        Assert.AreEqual(Enum::"Profile Direction"::Both, ActivatedNetProf."Profile Direction", IncorrectValueErr);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PatchParticipationProfile400()
    var
        Participation: Record Participation;
        TempActivatedNetProf: Record "Activated Net. Prof." temporary;
        ActivatedNetProf: Record "Activated Net. Prof.";
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith400ResponseCodeCase();

        // [Given] a Connected Participation with Outbound Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf);
        ActivatedNetProf."Profile Direction" := ActivatedNetProf."Profile Direction"::Outbound;
        ActivatedNetProf.Modify();

        // [When] Patch Participation Profile
        TempActivatedNetProf := ActivatedNetProf;
        asserterror ApiRequests.PatchParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response400ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PatchParticipationProfile401()
    var
        Participation: Record Participation;
        TempActivatedNetProf: Record "Activated Net. Prof." temporary;
        ActivatedNetProf: Record "Activated Net. Prof.";
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith401ResponseCodeCase();

        // [Given] a Connected Participation with Outbound Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf);
        ActivatedNetProf."Profile Direction" := ActivatedNetProf."Profile Direction"::Outbound;
        ActivatedNetProf.Modify();

        // [When] Patch Participation Profile
        TempActivatedNetProf := ActivatedNetProf;
        asserterror ApiRequests.PatchParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response401ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PatchParticipationProfile404()
    var
        Participation: Record Participation;
        TempActivatedNetProf: Record "Activated Net. Prof." temporary;
        ActivatedNetProf: Record "Activated Net. Prof.";
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith404ResponseCodeCase();

        // [Given] a Connected Participation with Outbound Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf);
        ActivatedNetProf."Profile Direction" := ActivatedNetProf."Profile Direction"::Outbound;
        ActivatedNetProf.Modify();

        // [When] Patch Participation Profile
        TempActivatedNetProf := ActivatedNetProf;
        asserterror ApiRequests.PatchParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response404ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PatchParticipationProfile422()
    var
        Participation: Record Participation;
        TempActivatedNetProf: Record "Activated Net. Prof." temporary;
        ActivatedNetProf: Record "Activated Net. Prof.";
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith422ResponseCodeCase();

        // [Given] a Connected Participation with Outbound Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf);
        ActivatedNetProf."Profile Direction" := ActivatedNetProf."Profile Direction"::Outbound;
        ActivatedNetProf.Modify();

        // [When] Patch Participation Profile
        TempActivatedNetProf := ActivatedNetProf;
        asserterror ApiRequests.PatchParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response422ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure PatchParticipationProfile500()
    var
        Participation: Record Participation;
        TempActivatedNetProf: Record "Activated Net. Prof." temporary;
        ActivatedNetProf: Record "Activated Net. Prof.";
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith500ResponseCodeCase();

        // [Given] a Connected Participation with Outbound Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf);
        ActivatedNetProf."Profile Direction" := ActivatedNetProf."Profile Direction"::Outbound;
        ActivatedNetProf.Modify();

        // [When] Patch Participation Profile
        TempActivatedNetProf := ActivatedNetProf;
        asserterror ApiRequests.PatchParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response500ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure DeleteParticipationProfile200()
    var
        Participation: Record Participation;
        ActivatedNetProf: Record "Activated Net. Prof.";
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiCaseUrlSegment('200');

        // [Given] a Connected Participation with Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf);

        // [When] Delete Participation Profile
        ApiRequests.DeleteParticipationProfile(ActivatedNetProf, Participation.Id);

        // [Then] Make sure Activated Network Profile values returned correct
        ConnectorLibrary.GetActivatedNetworkProfile(ActivatedNetProf);
        Assert.AreEqual(ConnectorLibrary.ActiveNetworkProfileId(true), ActivatedNetProf.Id, IncorrectValueErr);
        Assert.AreNotEqual(0DT, ActivatedNetProf.Disabled, 'Network Profile should be disabled');
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure DeleteParticipationProfile400()
    var
        Participation: Record Participation;
        ActivatedNetProf: Record "Activated Net. Prof.";
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith400ResponseCodeCase();

        // [Given] a Connected Participation with Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf);

        // [When] Delete Participation Profile
        asserterror ApiRequests.DeleteParticipationProfile(ActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response400ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure DeleteParticipationProfile401()
    var
        Participation: Record Participation;
        ActivatedNetProf: Record "Activated Net. Prof.";
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith401ResponseCodeCase();

        // [Given] a Connected Participation with Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf);

        // [When] Delete Participation Profile
        asserterror ApiRequests.DeleteParticipationProfile(ActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response401ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure DeleteParticipationProfile404()
    var
        Participation: Record Participation;
        ActivatedNetProf: Record "Activated Net. Prof.";
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith404ResponseCodeCase();

        // [Given] a Connected Participation with Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf);

        // [When] Delete Participation Profile
        asserterror ApiRequests.DeleteParticipationProfile(ActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response404ErrorMessageLbl);
    end;

    /// <summary>
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure DeleteParticipationProfile500()
    var
        Participation: Record Participation;
        ActivatedNetProf: Record "Activated Net. Prof.";
        ApiRequests: Codeunit "Api Requests";
    begin
        Initialize();
        ApiUrlMockSubscribers.SetCdnApiWith500ResponseCodeCase();

        // [Given] a Connected Participation with Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf);

        // [When] Delete Participation Profile
        asserterror ApiRequests.DeleteParticipationProfile(ActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response500ErrorMessageLbl);
    end;

    local procedure Initialize()
    begin
        LibraryPermission.SetOutsideO365Scope();
        ConnectorLibrary.CleanParticipations();

        ApiUrlMockSubscribers.SetCoApiWith200ResponseCodeCase(ConnectorLibrary.ApiMockBaseUrl());
        ApiUrlMockSubscribers.SetCdnApiWith200ResponseCodeCase(ConnectorLibrary.ApiMockBaseUrl());

        if IsInitialized then
            exit;
        ConnectorLibrary.EnableConnectorHttpTraffic();

        BindSubscription(ApiUrlMockSubscribers);

        IsInitialized := true;
    end;

    var
        LibraryPermission: Codeunit "Library - Lower Permissions";
        Assert: Codeunit Assert;
        ApiUrlMockSubscribers: Codeunit "Api Url Mock Subscribers";
        ConnectorLibrary: Codeunit "Connector Library";
        IsInitialized: Boolean;
        IncorrectValueErr: Label 'Wrong value';
        Response400ErrorMessageLbl: Label 'The Continia Delivery Network API returned the following error: Error Code Bad Request - Missing parameter';
        Response401ErrorMessageLbl: Label 'The Continia Delivery Network API returned the following error: Error Code Not Authenticated - Login failed';
        Response404ErrorMessageLbl: Label 'The Continia Delivery Network API returned the following error: Error Code Not Found - Not Found';
        Response409ErrorMessageLbl: Label 'The Continia Delivery Network API returned the following error: Error Code Conflict - Conflict';
        Response422ErrorMessageLbl: Label 'The Continia Delivery Network API returned the following error: Error Code string - string';
        Response500ErrorMessageLbl: Label 'The Continia Delivery Network API returned the following system error: Error Code Internal Server - Unhandled system error';
}