codeunit 139860 "APIV2 - G/L Setup E2E"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        ServiceNameTxt: Label 'generalLedgerSetup';

    [Test]
    procedure TestGetGLSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Response, TargetURL : Text;
    begin
        GeneralLedgerSetup.Get();
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - G/L Setup", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(Response, TargetURL);
        VerifyGeneralLedgerSetupResponse(Response, GeneralLedgerSetup);
    end;

    local procedure VerifyGeneralLedgerSetupResponse(Response: Text; GeneralLedgerSetup: Record "General Ledger Setup")
    var
        JsonObject: JsonObject;
        JsonToken, PropertyJsonToken : JsonToken;
        JsonArray: JsonArray;
    begin
        JsonObject.ReadFrom(Response);
        JsonObject.Get('value', JsonToken);
        JsonArray := JsonToken.AsArray();
        Assert.AreEqual(1, JsonArray.Count(), 'Expected a single record for generalLedgerSetup');
        JsonArray.Get(0, JsonToken);
        JsonToken.AsObject().Get('id', PropertyJsonToken);
        Assert.AreEqual(LowerCase(GeneralLedgerSetup.SystemId).Replace('{', '').Replace('}', ''), PropertyJsonToken.AsValue().AsText(), 'Expected the same id for generalLedgerSetup');
        JsonToken.AsObject().Get('allowPostingFrom', PropertyJsonToken);
        Assert.AreEqual(GeneralLedgerSetup."Allow Posting From", PropertyJsonToken.AsValue().AsDate(), 'Expected the same allowPostingFrom for generalLedgerSetup');
        JsonToken.AsObject().Get('allowPostingTo', PropertyJsonToken);
        Assert.AreEqual(GeneralLedgerSetup."Allow Posting To", PropertyJsonToken.AsValue().AsDate(), 'Expected the same allowPostingTo for generalLedgerSetup');
        JsonToken.AsObject().Get('localCurrencyCode', PropertyJsonToken);
        Assert.AreEqual(GeneralLedgerSetup."LCY Code", PropertyJsonToken.AsValue().AsCode(), 'Expected the same localCurrencyCode for generalLedgerSetup');
        JsonToken.AsObject().Get('additionalReportingCurrency', PropertyJsonToken);
        Assert.AreEqual(GeneralLedgerSetup."Additional Reporting Currency", PropertyJsonToken.AsValue().AsCode(), 'Expected the same additionalReportingCurrency for generalLedgerSetup');
        JsonToken.AsObject().Get('localCurrencySymbol', PropertyJsonToken);
        Assert.AreEqual(GeneralLedgerSetup."Local Currency Symbol", PropertyJsonToken.AsValue().AsText(), 'Expected the same localCurrencySymbol for generalLedgerSetup');
    end;

}