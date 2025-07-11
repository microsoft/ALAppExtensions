namespace Microsoft.EServices.EDocumentConnector.Continia;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration;

codeunit 148202 "Continia Connector Library"
{
    Access = Internal;

    internal procedure ParticipationId(): Text
    begin
        exit(ParticipationIdLbl);
    end;

    internal procedure ParticipationId(AsGuid: Boolean): Guid
    begin
        exit(ConvertToGuid(ParticipationId()));
    end;

    internal procedure ActiveNetworkProfileId(): Text
    begin
        exit(ActivatedNetworkProfileIdLbl);
    end;

    internal procedure ActiveNetworkProfileId(AsGuid: Boolean): Guid
    begin
        exit(ConvertToGuid(ActiveNetworkProfileId()));
    end;

    internal procedure DefaultNetworkProfileId(): Text
    begin
        exit(DefaultNetworkProfileIdLbl);
    end;

    internal procedure DefaultNetworkProfileId(AsGuid: Boolean): Guid
    begin
        exit(ConvertToGuid(DefaultNetworkProfileId()));
    end;

    internal procedure NetworkProfileIdPeppolBis3Invoice(): Text
    begin
        exit(NetworkProfileIdPeppolBis3InvoiceLbl);
    end;

    internal procedure NetworkProfileIdPeppolBis3Invoice(AsGuid: Boolean): Guid
    begin
        exit(ConvertToGuid(NetworkProfileIdPeppolBis3Invoice()));
    end;

    local procedure ConvertToGuid(GuidText: Text) GuidValue: Guid
    begin
        Evaluate(GuidValue, GuidText);
    end;

    internal procedure InitiateClientCredentials()
    var
        ConnectionSetup: Record "Continia Connection Setup";
    begin
        if not ConnectionSetup.Get() then
            ConnectionSetup.Insert();

        ConnectionSetup.SetClientId(LibraryRandom.RandText(20));
        ConnectionSetup.SetClientSecret(LibraryRandom.RandText(20));
        ConnectionSetup."Local Client Identifier" := CopyStr(LibraryRandom.RandText(MaxStrLen(ConnectionSetup."Local Client Identifier")), 1, MaxStrLen(ConnectionSetup."Local Client Identifier"));
        ConnectionSetup."Subscription Status" := ConnectionSetup."Subscription Status"::Subscription;
        ConnectionSetup.Modify();
    end;

    internal procedure ClearClientCredentials()
    var
        ConnectionSetup: Record "Continia Connection Setup";
    begin
        if ConnectionSetup.Get() then
            ConnectionSetup.Delete();
    end;

    internal procedure PrepareParticipation(EDocumentService: Record "E-Document Service")
    var
        Participation: Record "Continia Participation";
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
    begin
        // Create a participation with profile
        PrepareParticipation(Participation, ActivatedNetProf, EDocumentService)
    end;

    internal procedure PrepareParticipation(var Participation: Record "Continia Participation")
    var
        NetworkIdentifier: Record "Continia Network Identifier";
    begin
        NetworkIdentifier.Init();
        NetworkIdentifier.Id := IdentifierTypeIdLbl;
        NetworkIdentifier.Insert();

        // Create a participation without profile
        Participation.Init();
        Participation.Network := Participation.Network::Peppol;
        Participation."Identifier Type Id" := IdentifierTypeIdLbl;
        Participation."Identifier Value" := IdentifierValueLbl;
        if Participation.IsTemporary then begin
            Participation.Insert();
            exit;
        end;
        Participation.Id := ParticipationIdLbl;
        Participation."Registration Status" := Participation."Registration Status"::Connected;
        Participation.Insert();
    end;

    internal procedure PrepareParticipation(var Participation: Record "Continia Participation"; var ActivatedNetProf: Record "Continia Activated Net. Prof.")
    var
        LibraryEDocument: Codeunit "Library - E-Document";
        EDocServiceCode: Code[20];
    begin
        // Create a participation with profile
        PrepareParticipation(Participation);

        CreateNetworkProfiles();

        EDocServiceCode := LibraryEDocument.CreateService(Enum::"Service Integration"::Continia);
        AddActivatedNetworkProfile(Participation, ActivatedNetProf, EDocServiceCode);
    end;

    internal procedure PrepareParticipation(var Participation: Record "Continia Participation"; var ActivatedNetProf: Record "Continia Activated Net. Prof."; EDocumentService: Record "E-Document Service")
    begin
        // Create a participation with profile
        PrepareParticipation(Participation);

        CreateNetworkProfiles();

        AddActivatedNetworkProfile(Participation, ActivatedNetProf, EDocumentService.Code);
    end;

    internal procedure AddActivatedNetworkProfile(var Participation: Record "Continia Participation"; var ActivatedNetProf: Record "Continia Activated Net. Prof."; EDocServiceCode: Code[20])
    begin
        AddActivatedNetworkProfile(Participation, DefaultNetworkProfileIdLbl, ActivatedNetworkProfileIdLbl, ActivatedNetProf, EDocServiceCode);
    end;

    internal procedure AddActivatedNetworkProfile(var Participation: Record "Continia Participation"; NetworkPrifileId: Guid; ActivatedNetworkPrifileId: Guid; var ActivatedNetProf: Record "Continia Activated Net. Prof."; EDocServiceCode: Code[20])
    begin
        ActivatedNetProf.Init();
        ActivatedNetProf.Network := Participation.Network;
        ActivatedNetProf."Identifier Type Id" := Participation."Identifier Type Id";
        ActivatedNetProf."Identifier Value" := Participation."Identifier Value";
        ActivatedNetProf."Network Profile Id" := NetworkPrifileId;
        ActivatedNetProf."Profile Direction" := ActivatedNetProf."Profile Direction"::Both;
        ActivatedNetProf."E-Document Service Code" := EDocServiceCode;
        if ActivatedNetProf.IsTemporary then begin
            ActivatedNetProf.Insert();
            exit;
        end;
        ActivatedNetProf.Id := ActivatedNetworkPrifileId;
        ActivatedNetProf.Insert();
    end;

    local procedure CreateNetworkProfiles()
    var
        NetworkProfile: Record "Continia Network Profile";
    begin
        NetworkProfile.Init();
        NetworkProfile.Id := DefaultNetworkProfileIdLbl;
        NetworkProfile.Insert();

        NetworkProfile.Init();
        NetworkProfile.Id := NetworkProfileIdPeppolBis3InvoiceLbl;
        NetworkProfile.Insert();
    end;

    [TryFunction]
    internal procedure GetParticipation(var Participation: Record "Continia Participation")
    begin
        Participation.Get(Participation.Network::Peppol, IdentifierTypeIdLbl, IdentifierValueLbl);
    end;

    [TryFunction]
    internal procedure GetActivatedNetworkProfile(var ActivatedNetProf: Record "Continia Activated Net. Prof.")
    begin
        ActivatedNetProf.Get(ActivatedNetProf.Network::Peppol, IdentifierTypeIdLbl, IdentifierValueLbl, DefaultNetworkProfileIdLbl);
    end;

    [TryFunction]
    internal procedure GetActivatedNetworkProfile(NetworkProfileId: Guid; var ActivatedNetProf: Record "Continia Activated Net. Prof.")
    begin
        ActivatedNetProf.Get(ActivatedNetProf.Network::Peppol, IdentifierTypeIdLbl, IdentifierValueLbl, NetworkProfileId);
    end;

    internal procedure CleanParticipations()
    var
        Participation: Record "Continia Participation";
        NetworkIdentifier: Record "Continia Network Identifier";
        NetworkProfile: Record "Continia Network Profile";
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
    begin
        if not Participation.IsEmpty then
            Participation.DeleteAll();
        if not NetworkIdentifier.IsEmpty then
            NetworkIdentifier.DeleteAll();
        if not NetworkProfile.IsEmpty then
            NetworkProfile.DeleteAll();
        if not ActivatedNetProf.IsEmpty then
            ActivatedNetProf.DeleteAll();
    end;

    var
        LibraryRandom: Codeunit "Library - Random";
        ParticipationIdLbl: Label '0de4aedc-f84a-41bc-b511-387aaf96263e', Locked = true;
        ActivatedNetworkProfileIdLbl: Label '1f4111a0-cd49-45e1-9f1e-ed14e71e3438', Locked = true;
        DefaultNetworkProfileIdLbl: Label 'dd2af6bc-a05a-4fd4-a577-0216a56bea84', Locked = true; //Peppol Credit Note profile used as default
        NetworkProfileIdPeppolBis3InvoiceLbl: Label '8f9ab973-c6f0-4dfb-9936-19b56c5a588b', Locked = true;
        IdentifierTypeIdLbl: Label '568c29e7-c2c8-49bb-b135-9199d5b791d1', Locked = true;
        IdentifierValueLbl: Label '111222333', Locked = true;

}