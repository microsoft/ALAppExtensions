namespace Microsoft.EServices.EDocumentConnector.Continia;

using System.Utilities;

codeunit 148200 "Continia Api Comm. Unit Tests"
{
    Subtype = Test;
    TestHttpRequestPolicy = AllowOutboundFromHandler;

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

    local procedure Initialize()
    begin
        LibraryPermission.SetOutsideO365Scope();
        ConnectorLibrary.CleanParticipations();
        ContiniaMockHttpHandler.ClearHandler();

        if IsInitialized then
            exit;

        IsInitialized := true;
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