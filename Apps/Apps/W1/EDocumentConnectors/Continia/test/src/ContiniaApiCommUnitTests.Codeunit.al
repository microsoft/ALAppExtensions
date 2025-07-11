namespace Microsoft.EServices.EDocumentConnector.Continia;

codeunit 148205 "Continia Api Comm. Unit Tests"
{
    Subtype = Test;
    TestHttpRequestPolicy = AllowOutboundFromHandler;
    Access = Internal;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure GetParticipation200()
    var
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(200, GetMockResponseContent('Participation200-InProcess.txt'));

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Get Participation
        ApiRequests.GetParticipation(Participation);

        // [Then] Make sure Participation values returned correct
        Assert.AreEqual(ConnectorLibrary.ParticipationId(true), Participation.Id, IncorrectValueErr);
        Assert.AreEqual(Enum::"Continia Registration Status"::InProcess, Participation."Registration Status", IncorrectValueErr);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure GetParticipation400()
    var
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(400, GetMockResponseContent('Common400.txt'));

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Get Participation
        asserterror ApiRequests.GetParticipation(Participation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response400ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure GetParticipation401()
    var
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(401, GetMockResponseContent('Common401.txt'));

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Get Participation
        asserterror ApiRequests.GetParticipation(Participation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response401ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure GetParticipation404()
    var
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(404, GetMockResponseContent('Common404.txt'));

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Get Participation
        asserterror ApiRequests.GetParticipation(Participation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response404ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure GetParticipation500()
    var
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(500, GetMockResponseContent('Common500.txt'));

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Get Participation
        asserterror ApiRequests.GetParticipation(Participation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response500ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PostParticipation200()
    var
        TempParticipation: Record "Continia Participation" temporary;
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(200, GetMockResponseContent('Participation200-Draft.txt'));

        // [Given] Filled in Participation info
        ConnectorLibrary.PrepareParticipation(TempParticipation);

        // [When] Post Participation
        ApiRequests.PostParticipation(TempParticipation);

        // [Then] Make sure Participation values returned correct
        ConnectorLibrary.GetParticipation(Participation);
        Assert.AreEqual(ConnectorLibrary.ParticipationId(true), Participation.Id, IncorrectValueErr);
        Assert.AreEqual(Enum::"Continia Registration Status"::Draft, Participation."Registration Status", IncorrectValueErr);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PostParticipation201()
    var
        TempParticipation: Record "Continia Participation" temporary;
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(201, GetMockResponseContent('Participation201-Draft.txt'));

        // [Given] Filled in Participation info
        ConnectorLibrary.PrepareParticipation(TempParticipation);

        // [When] Post Participation
        ApiRequests.PostParticipation(TempParticipation);

        // [Then] Make sure Participation values returned correct
        ConnectorLibrary.GetParticipation(Participation);
        Assert.AreEqual(ConnectorLibrary.ParticipationId(true), Participation.Id, IncorrectValueErr);
        Assert.AreEqual(Enum::"Continia Registration Status"::Draft, Participation."Registration Status", IncorrectValueErr);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PostParticipation400()
    var
        TempParticipation: Record "Continia Participation" temporary;
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(400, GetMockResponseContent('Common400.txt'));

        // [Given] Filled in Participation info
        ConnectorLibrary.PrepareParticipation(TempParticipation);

        // [When] Post Participation
        asserterror ApiRequests.PostParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response400ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PostParticipation401()
    var
        TempParticipation: Record "Continia Participation" temporary;
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(401, GetMockResponseContent('Common401.txt'));

        // [Given] Filled in Participation info
        ConnectorLibrary.PrepareParticipation(TempParticipation);

        // [When] Post Participation
        asserterror ApiRequests.PostParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response401ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PostParticipation404()
    var
        TempParticipation: Record "Continia Participation" temporary;
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(404, GetMockResponseContent('Common404.txt'));

        // [Given] Filled in Participation info
        ConnectorLibrary.PrepareParticipation(TempParticipation);

        // [When] Post Participation
        asserterror ApiRequests.PostParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response404ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PostParticipation422()
    var
        TempParticipation: Record "Continia Participation" temporary;
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(422, GetMockResponseContent('Common422.txt'));

        // [Given] Filled in Participation info
        ConnectorLibrary.PrepareParticipation(TempParticipation);

        // [When] Post Participation
        asserterror ApiRequests.PostParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response422ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PostParticipation500()
    var
        TempParticipation: Record "Continia Participation" temporary;
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(500, GetMockResponseContent('Common500.txt'));

        // [Given] Filled in Participation info
        ConnectorLibrary.PrepareParticipation(TempParticipation);

        // [When] Post Participation
        asserterror ApiRequests.PostParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response500ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PatchParticipation200()
    var
        TempParticipation: Record "Continia Participation" temporary;
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(200, GetMockResponseContent('Participation200-InProcess.txt'));

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Patch Participation
        TempParticipation := Participation;
        ApiRequests.PatchParticipation(TempParticipation);

        // [Then] Make sure Participation values returned correct
        ConnectorLibrary.GetParticipation(Participation);
        Assert.AreEqual(ConnectorLibrary.ParticipationId(true), Participation.Id, IncorrectValueErr);
        Assert.AreEqual(Enum::"Continia Registration Status"::InProcess, Participation."Registration Status", IncorrectValueErr);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PatchParticipation400()
    var
        TempParticipation: Record "Continia Participation" temporary;
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(400, GetMockResponseContent('Common400.txt'));

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Patch Participation
        TempParticipation := Participation;
        asserterror ApiRequests.PatchParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response400ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PatchParticipation401()
    var
        TempParticipation: Record "Continia Participation" temporary;
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(401, GetMockResponseContent('Common401.txt'));

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Patch Participation
        TempParticipation := Participation;
        asserterror ApiRequests.PatchParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response401ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PatchParticipation404()
    var
        TempParticipation: Record "Continia Participation" temporary;
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(404, GetMockResponseContent('Common404.txt'));

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Patch Participation
        TempParticipation := Participation;
        asserterror ApiRequests.PatchParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response404ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PatchParticipation409()
    var
        TempParticipation: Record "Continia Participation" temporary;
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(409, GetMockResponseContent('Common409.txt'));

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Patch Participation
        TempParticipation := Participation;
        asserterror ApiRequests.PatchParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response409ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PatchParticipation422()
    var
        TempParticipation: Record "Continia Participation" temporary;
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(422, GetMockResponseContent('Common422.txt'));

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Patch Participation
        TempParticipation := Participation;
        asserterror ApiRequests.PatchParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response422ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PatchParticipation500()
    var
        TempParticipation: Record "Continia Participation" temporary;
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(500, GetMockResponseContent('Common500.txt'));

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Patch Participation
        TempParticipation := Participation;
        asserterror ApiRequests.PatchParticipation(TempParticipation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response500ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure DeleteParticipation200()
    var
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(200, '');

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Delete Participation
        ApiRequests.DeleteParticipation(Participation);

        // [Then] Make sure Participation does not exist
        Assert.AreEqual(true, Participation.IsEmpty, 'Participation should not exist');
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure DeleteParticipation202()
    var
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(202, '');

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Delete Participation
        ApiRequests.DeleteParticipation(Participation);

        // [Then] Make sure Participation does not exist
        ConnectorLibrary.GetParticipation(Participation);
        Assert.AreEqual(ConnectorLibrary.ParticipationId(true), Participation.Id, IncorrectValueErr);
        Assert.AreEqual(Enum::"Continia Registration Status"::Disabled, Participation."Registration Status", IncorrectValueErr);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure DeleteParticipation400()
    var
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(400, GetMockResponseContent('Common400.txt'));

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Delete Participation
        asserterror ApiRequests.DeleteParticipation(Participation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response400ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure DeleteParticipation401()
    var
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(401, GetMockResponseContent('Common401.txt'));

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Delete Participation
        asserterror ApiRequests.DeleteParticipation(Participation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response401ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure DeleteParticipation404()
    var
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(404, GetMockResponseContent('Common404.txt'));

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Delete Participation
        asserterror ApiRequests.DeleteParticipation(Participation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response404ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure DeleteParticipation422()
    var
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(422, GetMockResponseContent('Common422.txt'));

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Delete Participation
        asserterror ApiRequests.DeleteParticipation(Participation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response422ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure DeleteParticipation500()
    var
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(500, GetMockResponseContent('Common500.txt'));

        // [Given] a Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [When] Delete Participation
        asserterror ApiRequests.DeleteParticipation(Participation);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response500ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PostParticipationProfile200()
    var
        Participation: Record "Continia Participation";
        TempActivatedNetProf: Record "Continia Activated Net. Prof." temporary;
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(200, GetMockResponseContent('ParticipationProfile200-randomId.txt'));

        // [Given] a Connected Participation without Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, TempActivatedNetProf);

        // [When] Post Participation Profile
        ApiRequests.PostParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] Make sure Activated Network Profile exists
        Assert.AreEqual(true, ConnectorLibrary.GetActivatedNetworkProfile(ActivatedNetProf), 'Activated Network Profile must exist');
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PostParticipationProfile400()
    var
        Participation: Record "Continia Participation";
        TempActivatedNetProf: Record "Continia Activated Net. Prof." temporary;
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(400, GetMockResponseContent('Common400.txt'));

        // [Given] a Connected Participation without Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, TempActivatedNetProf);

        // [When] Post Participation Profile
        asserterror ApiRequests.PostParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response400ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PostParticipationProfile401()
    var
        Participation: Record "Continia Participation";
        TempActivatedNetProf: Record "Continia Activated Net. Prof." temporary;
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(401, GetMockResponseContent('Common401.txt'));

        // [Given] a Connected Participation without Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, TempActivatedNetProf);

        // [When] Post Participation Profile
        asserterror ApiRequests.PostParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response401ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PostParticipationProfile404()
    var
        Participation: Record "Continia Participation";
        TempActivatedNetProf: Record "Continia Activated Net. Prof." temporary;
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(404, GetMockResponseContent('Common404.txt'));

        // [Given] a Connected Participation without Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, TempActivatedNetProf);

        // [When] Post Participation Profile
        asserterror ApiRequests.PostParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response404ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PostParticipationProfile422()
    var
        Participation: Record "Continia Participation";
        TempActivatedNetProf: Record "Continia Activated Net. Prof." temporary;
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(422, GetMockResponseContent('Common422.txt'));

        // [Given] a Connected Participation without Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, TempActivatedNetProf);

        // [When] Post Participation Profile
        asserterror ApiRequests.PostParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response422ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PostParticipationProfile500()
    var
        Participation: Record "Continia Participation";
        TempActivatedNetProf: Record "Continia Activated Net. Prof." temporary;
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(500, GetMockResponseContent('Common500.txt'));

        // [Given] a Connected Participation without Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, TempActivatedNetProf);

        // [When] Post Participation Profile
        asserterror ApiRequests.PostParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response500ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PatchParticipationProfile200()
    var
        Participation: Record "Continia Participation";
        TempActivatedNetProf: Record "Continia Activated Net. Prof." temporary;
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        // [Given] a Connected Participation with Outbound Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf);
        ActivatedNetProf."Profile Direction" := ActivatedNetProf."Profile Direction"::Outbound;
        ActivatedNetProf.Modify();

        ContiniaMockHttpHandler.AddResponse(200, GetMockResponseContent('ParticipationProfile200.txt'));

        // [When] Patch Participation Profile
        TempActivatedNetProf := ActivatedNetProf;
        ApiRequests.PatchParticipationProfile(TempActivatedNetProf, Participation.Id);

        // [Then] Make sure Activated Network Profile values returned correct
        ConnectorLibrary.GetActivatedNetworkProfile(ActivatedNetProf);
        Assert.AreEqual(ConnectorLibrary.ActiveNetworkProfileId(true), ActivatedNetProf.Id, IncorrectValueErr);
        Assert.AreEqual(Enum::"Continia Profile Direction"::Both, ActivatedNetProf."Profile Direction", IncorrectValueErr);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PatchParticipationProfile400()
    var
        Participation: Record "Continia Participation";
        TempActivatedNetProf: Record "Continia Activated Net. Prof." temporary;
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(400, GetMockResponseContent('Common400.txt'));

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

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PatchParticipationProfile401()
    var
        Participation: Record "Continia Participation";
        TempActivatedNetProf: Record "Continia Activated Net. Prof." temporary;
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(401, GetMockResponseContent('Common401.txt'));

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

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PatchParticipationProfile404()
    var
        Participation: Record "Continia Participation";
        TempActivatedNetProf: Record "Continia Activated Net. Prof." temporary;
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(404, GetMockResponseContent('Common404.txt'));

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

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PatchParticipationProfile422()
    var
        Participation: Record "Continia Participation";
        TempActivatedNetProf: Record "Continia Activated Net. Prof." temporary;
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(422, GetMockResponseContent('Common422.txt'));

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

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure PatchParticipationProfile500()
    var
        Participation: Record "Continia Participation";
        TempActivatedNetProf: Record "Continia Activated Net. Prof." temporary;
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(500, GetMockResponseContent('Common500.txt'));

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

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure DeleteParticipationProfile200()
    var
        Participation: Record "Continia Participation";
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(200, '');

        // [Given] a Connected Participation with Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf);

        // [When] Delete Participation Profile
        ApiRequests.DeleteParticipationProfile(ActivatedNetProf, Participation.Id);

        // [Then] Make sure Activated Network Profile values returned correct
        ConnectorLibrary.GetActivatedNetworkProfile(ActivatedNetProf);
        Assert.AreEqual(ConnectorLibrary.ActiveNetworkProfileId(true), ActivatedNetProf.Id, IncorrectValueErr);
        Assert.AreNotEqual(0DT, ActivatedNetProf.Disabled, 'Network Profile should be disabled');
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure DeleteParticipationProfile400()
    var
        Participation: Record "Continia Participation";
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(400, GetMockResponseContent('Common400.txt'));

        // [Given] a Connected Participation with Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf);

        // [When] Delete Participation Profile
        asserterror ApiRequests.DeleteParticipationProfile(ActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response400ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure DeleteParticipationProfile401()
    var
        Participation: Record "Continia Participation";
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(401, GetMockResponseContent('Common401.txt'));

        // [Given] a Connected Participation with Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf);

        // [When] Delete Participation Profile
        asserterror ApiRequests.DeleteParticipationProfile(ActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response401ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure DeleteParticipationProfile404()
    var
        Participation: Record "Continia Participation";
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(404, GetMockResponseContent('Common404.txt'));

        // [Given] a Connected Participation with Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf);

        // [When] Delete Participation Profile
        asserterror ApiRequests.DeleteParticipationProfile(ActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response404ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure DeleteParticipationProfile500()
    var
        Participation: Record "Continia Participation";
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        Initialize();
        ContiniaMockHttpHandler.AddResponse(500, GetMockResponseContent('Common500.txt'));

        // [Given] a Connected Participation with Activated Network Profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf);

        // [When] Delete Participation Profile
        asserterror ApiRequests.DeleteParticipationProfile(ActivatedNetProf, Participation.Id);

        // [Then] make sure error is correct
        Assert.ExpectedError(Response500ErrorMessageLbl);
    end;

    [Test]
    [HandlerFunctions('HttpClientHandlerWithParameters')]
    procedure GetnetworkProfilesMultiplePages()
    var
        ContiniaNetworkProfile: Record "Continia Network Profile";
        ApiRequests: Codeunit "Continia Api Requests";
        LibraryRandom: Codeunit "Library - Random";
        ContiniaApiUrlMgt: Codeunit "Continia Api Url";
        NumberOfRecords: Integer;
        LeftRecordsCount: Integer;
        ResponseHeader: Dictionary of [Text, Text];
        PageSize: Integer;
        PageNumber: Integer;
        Url: Text;
        UrlPatternTok: Label '%1/networks/peppol/profiles.xml?page=%2&page_size=%3', Comment = '%1 - Base URL, %2 - page number, %3 - page size', Locked = true;
    begin
        Initialize();
        if not ContiniaNetworkProfile.IsEmpty() then
            ContiniaNetworkProfile.DeleteAll();

        // [Given] Prepare mock response
        LibraryRandom.Init();
        PageSize := 100;
        PageNumber := 0;
        NumberOfRecords := LibraryRandom.RandIntInRange(200, 300);
        ResponseHeader.Add('X-Total-Count', Format(NumberOfRecords));

        LeftRecordsCount := NumberOfRecords;
        while LeftRecordsCount > 0 do begin
            PageNumber += 1;
            if LeftRecordsCount < PageSize then
                PageSize := LeftRecordsCount;
            Url := StrSubstNo(UrlPatternTok, ContiniaApiUrlMgt.CdnBaseUrl(), PageNumber, 100);
            ContiniaMockHttpHandler.AddResponseWithParameters(HttpRequestType::Get, Url, 200, GenerateNetworkProfilesResponse(PageSize), ResponseHeader);
            LeftRecordsCount := LeftRecordsCount - PageSize;
        end;

        // [When] Get Network Profiles
        ApiRequests.GetNetworkProfiles(Enum::"Continia E-Delivery Network"::Peppol);
        // [Then] Make sure Network Profiles exist
        Assert.AreEqual(NumberOfRecords, ContiniaNetworkProfile.Count(), 'Incorrect number of Network Profiles');
    end;

    [Test]
    [HandlerFunctions('HttpClientHandlerWithParameters')]
    procedure GetnetworkIdentifiersMultiplePages()
    var
        ContiniaNetworkIdentifier: Record "Continia Network Identifier";
        ApiRequests: Codeunit "Continia Api Requests";
        LibraryRandom: Codeunit "Library - Random";
        ContiniaApiUrlMgt: Codeunit "Continia Api Url";
        NumberOfRecords: Integer;
        LeftRecordsCount: Integer;
        ResponseHeader: Dictionary of [Text, Text];
        PageSize: Integer;
        PageNumber: Integer;
        Url: Text;
        UrlPatternTok: Label '%1/networks/peppol/id_types.xml?page=%2&page_size=%3', Comment = '%1 - Base URL, %2 - page number, %3 - page size', Locked = true;
    begin
        Initialize();
        if not ContiniaNetworkIdentifier.IsEmpty() then
            ContiniaNetworkIdentifier.DeleteAll();

        // [Given] Prepare mock response
        LibraryRandom.Init();
        PageSize := 100;
        PageNumber := 0;
        NumberOfRecords := LibraryRandom.RandIntInRange(200, 300);
        ResponseHeader.Add('X-Total-Count', Format(NumberOfRecords));

        LeftRecordsCount := NumberOfRecords;
        while LeftRecordsCount > 0 do begin
            PageNumber += 1;
            if LeftRecordsCount < PageSize then
                PageSize := LeftRecordsCount;
            Url := StrSubstNo(UrlPatternTok, ContiniaApiUrlMgt.CdnBaseUrl(), PageNumber, 100);
            ContiniaMockHttpHandler.AddResponseWithParameters(HttpRequestType::Get, Url, 200, GenerateIdentifiersResponse(PageSize), ResponseHeader);
            LeftRecordsCount := LeftRecordsCount - PageSize;
        end;

        // [When] Get Network Profiles
        ApiRequests.GetNetworkIdTypes(Enum::"Continia E-Delivery Network"::Peppol);
        // [Then] Make sure Network Profiles exist
        Assert.AreEqual(NumberOfRecords, ContiniaNetworkIdentifier.Count(), 'Incorrect number of Network Identifiers');
    end;

    [Test]
    [HandlerFunctions('HttpClientHandlerWithParameters')]
    procedure GetParticipationProfilesMultiplePages()
    var
        ContiniaParticipationProfile: Record "Continia Activated Net. Prof.";
        ContiniaNetworkProfile: Record "Continia Network Profile";
        Participation: Record "Continia Participation";
        ApiRequests: Codeunit "Continia Api Requests";
        LibraryRandom: Codeunit "Library - Random";
        ContiniaApiUrlMgt: Codeunit "Continia Api Url";
        NumberOfRecords: Integer;
        LeftRecordsCount: Integer;
        ResponseHeader: Dictionary of [Text, Text];
        PageSize: Integer;
        PageNumber: Integer;
        Url: Text;
        UrlPatternTok: Label '%1/networks/peppol/participations/%2/profiles.xml?page=%3&page_size=%4', Comment = '%1 - Base URL, %2 - Participation Id, %3 - page number, %4 - page size', Locked = true;
    begin
        Initialize();
        if not ContiniaParticipationProfile.IsEmpty() then
            ContiniaParticipationProfile.DeleteAll();
        if not ContiniaNetworkProfile.IsEmpty() then
            ContiniaNetworkProfile.DeleteAll();

        // [Given] Prepare Participation
        ConnectorLibrary.PrepareParticipation(Participation);

        // [Given] Prepare mock response
        LibraryRandom.Init();
        PageSize := 100;
        PageNumber := 0;
        NumberOfRecords := LibraryRandom.RandIntInRange(200, 300);
        ResponseHeader.Add('X-Total-Count', Format(NumberOfRecords));

        LeftRecordsCount := NumberOfRecords;
        while LeftRecordsCount > 0 do begin
            PageNumber += 1;
            if LeftRecordsCount < PageSize then
                PageSize := LeftRecordsCount;
            Url := StrSubstNo(UrlPatternTok, ContiniaApiUrlMgt.CdnBaseUrl(), Format(Participation.Id, 0, 4), PageNumber, 100);
            ContiniaMockHttpHandler.AddResponseWithParameters(HttpRequestType::Get, Url, 200, GenerateParticpationProfilesResponse(PageSize), ResponseHeader);
            LeftRecordsCount := LeftRecordsCount - PageSize;
        end;

        // [When] Get Network Profiles
        ApiRequests.GetAllParticipationProfiles(Participation);
        // [Then] Make sure Network Profiles exist
        Assert.AreEqual(NumberOfRecords, ContiniaParticipationProfile.Count(), 'Incorrect number of Participation Profiles');
    end;

    local procedure Initialize()
    begin
        LibraryPermission.SetOutsideO365Scope();
        ConnectorLibrary.CleanParticipations();
        ContiniaMockHttpHandler.ClearHandler();

        if IsInitialized then
            exit;

        IsInitialized := true;
    end;

    local procedure GenerateNetworkProfilesResponse(NumberOfProfiles: Integer) ResponseText: Text;
    var
        LibraryRandom: Codeunit "Library - Random";
        XMLDoc: XmlDocument;
        RootElement: XmlElement;
        NetworkProfileElement: XmlElement;
        DescriptionElement: XmlElement;
        DocumentIdentifierElement: XmlElement;
        NetworkProfileIdElement: XmlElement;
        ProcessIdentifierElement: XmlElement;
        i: Integer;
    begin
        XMLDoc := XMLDocument.Create();
        RootElement := XmlElement.Create('network_profiles');
        for i := 1 to NumberOfProfiles do begin
            NetworkProfileElement := XmlElement.Create('network_profile');

            DescriptionElement := XmlElement.Create('description');
            DescriptionElement.Add(LibraryRandom.RandText(50));
            NetworkProfileElement.Add(DescriptionElement);

            DocumentIdentifierElement := XmlElement.Create('document_identifier');
            DocumentIdentifierElement.Add(LibraryRandom.RandText(50));
            NetworkProfileElement.Add(DocumentIdentifierElement);

            NetworkProfileIdElement := XmlElement.Create('network_profile_id');
            NetworkProfileIdElement.Add(Format(CreateGuid(), 0, 4));
            NetworkProfileElement.Add(NetworkProfileIdElement);

            ProcessIdentifierElement := XmlElement.Create('process_identifier');
            ProcessIdentifierElement.Add(LibraryRandom.RandText(50));
            NetworkProfileElement.Add(ProcessIdentifierElement);
            RootElement.Add(NetworkProfileElement);
        end;
        XMLDoc.Add(RootElement);
        XMLDoc.WriteTo(ResponseText);
    end;

    local procedure GenerateIdentifiersResponse(NumberOfIdentifiers: Integer) ResponseText: Text;
    var
        LibraryRandom: Codeunit "Library - Random";
        XMLDoc: XmlDocument;
        RootElement: XmlElement;
        NetworkIdTypeElement: XmlElement;
        CodeElement: XmlElement;
        DefaultInCountryElement: XmlElement;
        IcdCodeElement: XmlElement;
        NetworkIdTypeIdElement: XmlElement;
        DescriptionElement: XmlElement;
        SchemeIdElement: XmlElement;
        i: Integer;
    begin
        XMLDoc := XMLDocument.Create();
        RootElement := XmlElement.Create('network_id_types');
        for i := 1 to NumberOfIdentifiers do begin
            NetworkIdTypeElement := XmlElement.Create('network_id_type');

            CodeElement := XmlElement.Create('code_iso6523-1');
            CodeElement.Add(Format(LibraryRandom.RandIntInRange(1000, 9999)));
            NetworkIdTypeElement.Add(CodeElement);

            DefaultInCountryElement := XmlElement.Create('default_in_country_iso3166');
            DefaultInCountryElement.Add(GetRandomCountryCode());
            NetworkIdTypeElement.Add(DefaultInCountryElement);

            IcdCodeElement := XmlElement.Create('icd_code');
            IcdCodeElement.Add(Format(true));
            NetworkIdTypeElement.Add(IcdCodeElement);

            DescriptionElement := XmlElement.Create('description');
            DescriptionElement.Add(LibraryRandom.RandText(50));
            NetworkIdTypeElement.Add(DescriptionElement);

            NetworkIdTypeIdElement := XmlElement.Create('network_id_type_id');
            NetworkIdTypeIdElement.Add(Format(CreateGuid(), 0, 4));
            NetworkIdTypeElement.Add(NetworkIdTypeIdElement);

            SchemeIdElement := XmlElement.Create('scheme_id');
            SchemeIdElement.Add(LibraryRandom.RandText(10));
            NetworkIdTypeElement.Add(SchemeIdElement);

            RootElement.Add(NetworkIdTypeElement);
        end;
        XMLDoc.Add(RootElement);
        XMLDoc.WriteTo(ResponseText);
    end;

    local procedure GenerateParticpationProfilesResponse(NumberOfProfiles: Integer) ResponseText: Text
    var
        XMLDoc: XmlDocument;
        RootElement: XmlElement;
        NetworkProfileElement: XmlElement;
        NetworkProfileIdElement: XmlElement;
        DirectionElement: XmlElement;
        ParticipationProfileIdElement: XmlElement;
        CreatedUtcElement: XmlElement;
        UpdatedUtcElement: XmlElement;
        i: Integer;
    begin
        XMLDoc := XMLDocument.Create();
        RootElement := XmlElement.Create('participation_profiles');
        for i := 1 to NumberOfProfiles do begin
            NetworkProfileElement := XmlElement.Create('participation_profile');

            NetworkProfileIdElement := XmlElement.Create('network_profile_id');
            NetworkProfileIdElement.Add(Format(CreateNetworkProfile().Id, 0, 4));
            NetworkProfileElement.Add(NetworkProfileIdElement);

            ParticipationProfileIdElement := XmlElement.Create('participation_profile_id');
            ParticipationProfileIdElement.Add(Format(CreateGuid(), 0, 4));
            NetworkProfileElement.Add(ParticipationProfileIdElement);

            DirectionElement := XmlElement.Create('direction');
            DirectionElement.Add('BothEnum');
            NetworkProfileElement.Add(DirectionElement);

            CreatedUtcElement := XmlElement.Create('created_utc');
            CreatedUtcElement.Add(Format(CurrentDateTime(), 0, 9));
            NetworkProfileElement.Add(CreatedUtcElement);

            UpdatedUtcElement := XmlElement.Create('updated_utc');
            UpdatedUtcElement.Add(Format(CurrentDateTime(), 0, 9));
            NetworkProfileElement.Add(UpdatedUtcElement);
            RootElement.Add(NetworkProfileElement);
        end;
        XMLDoc.Add(RootElement);
        XMLDoc.WriteTo(ResponseText);
    end;

    local procedure GetRandomCountryCode() CountryCode: Text
    var
        LibraryRandom: Codeunit "Library - Random";
        CountryCodeList: List of [Text];
        CountryCodesTok: Label 'AU,BE,CA,DE,DK,EE,FI,FR,GB,IE,IT,NZ,NL,NO,PL,RU,SE,SG', Comment = 'List of country codes', Locked = true;
    begin
        LibraryRandom.Init();
        CountryCodeList := CountryCodesTok.Split(',');
        CountryCode := CountryCodeList.Get(LibraryRandom.RandIntInRange(1, CountryCodeList.Count()));
    end;

    local procedure CreateNetworkProfile() NetworkProfile: Record "Continia Network Profile";
    begin
        NetworkProfile.Init();
        NetworkProfile.Id := CreateGuid();
        NetworkProfile.Insert()
    end;

    local procedure GetMockResponseContent(FileName: Text) ContentText: Text
    begin
        ContentText := NavApp.GetResourceAsText(FileName, TextEncoding::UTF8);
    end;

    [HttpClientHandler]
    internal procedure HttpClientHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    begin
        if ContiniaMockHttpHandler.HandleAuthorization(Request, Response) then
            exit;

        Response := ContiniaMockHttpHandler.GetResponse(Request);
    end;

    [HttpClientHandler]
    internal procedure HttpClientHandlerWithParameters(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    begin
        if ContiniaMockHttpHandler.HandleAuthorization(Request, Response) then
            exit;

        Response := ContiniaMockHttpHandler.GetResponseWithParameters(Request);
    end;

    var
        LibraryPermission: Codeunit "Library - Lower Permissions";
        Assert: Codeunit Assert;
        ConnectorLibrary: Codeunit "Continia Connector Library";
        ContiniaMockHttpHandler: Codeunit "Continia Mock Http Handler";
        IsInitialized: Boolean;
        IncorrectValueErr: Label 'Wrong value';
        Response400ErrorMessageLbl: Label 'The Continia Delivery Network API returned the following error: Error Code Bad Request - Missing parameter';
        Response401ErrorMessageLbl: Label 'The Continia Delivery Network API returned the following error: Error Code Not Authenticated - Login failed';
        Response404ErrorMessageLbl: Label 'The Continia Delivery Network API returned the following error: Error Code Not Found - Not Found';
        Response409ErrorMessageLbl: Label 'The Continia Delivery Network API returned the following error: Error Code Conflict - Conflict';
        Response422ErrorMessageLbl: Label 'The Continia Delivery Network API returned the following error: Error Code string - string';
        Response500ErrorMessageLbl: Label 'The Continia Delivery Network API returned the following system error: Error Code Internal Server - Unhandled system error';
}