codeunit 18913 "TCS Tests Subscribers"
{
    var
        TCSLibrary: Codeunit "TCS - Library";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Test Publishers", 'InsertTCSSetup', '', false, false)]
    local procedure InsertTCSSetup(
       Customer: Record Customer;
       var TCSNOC: Code[10];
       var ConcessionalCode: Code[10])
    var
        TCSNatureofCollection: Record "TCS Nature Of Collection";
        TCSPostingSetup: Record "TCS Posting Setup";
        AssesseCode: Record "Assessee Code";
        TCSConcessionalCode: Record "Concessional Code";
    begin
        TCSLibrary.CreateGSTTCSCommmonSetup(AssesseCode, TCSConcessionalCode);
        TCSLibrary.CreateTCSNatureOfCollection(TCSNatureofCollection);
        TCSLibrary.CreateTCSPostingSetup(TCSPostingSetup, TCSNatureofCollection.Code);
        TCSNOC := TCSNatureofCollection.Code;
        ConcessionalCode := TCSConcessionalCode.Code;
        TCSLibrary.UpdateNOCOnCustomer(Customer."No.", TCSNOC);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Test Publishers", 'ModifyLocationTCAN', '', false, false)]
    local procedure ModifyLocationTCAN(LocationCode: Code[10])
    var
        Location: Record Location;
    begin
        if Location.Get(LocationCode) then begin
            Location.Validate("T.C.A.N. No.", TCSLibrary.CreateTCANNo());
            Location.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Test Publishers", 'ModifyCustomerNOC', '', false, false)]
    local procedure ModifyCustomerNOC(
        Customer: Record Customer;
        ThresholdOverlook: Boolean;
        SurchargeOverlook: Boolean)
    begin
        TCSLibrary.UpdateCustomerWithNOCWithOutConcessionalGST(Customer, ThresholdOverlook, SurchargeOverlook);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Test Publishers", 'OnAfterGetTCSSetupCode', '', false, false)]
    local procedure GetTCSSetupCode(var TCSTaxTypeCode: Code[20])
    var
        TCSSetup: Record "TCS Setup";
    begin
        if TCSSetup.Get() then
            TCSTaxTypeCode := TCSSetup."Tax Type";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Test Publishers", 'ModifySalesLineWithTCSNOC', '', false, false)]
    local procedure UpdateSalesLineWithTCSNOC(
        var SalesLine: Record "Sales Line";
        TCSNOC: Code[10])
    begin
        SalesLine.Validate("TCS Nature of Collection", TCSNOC);
        SalesLine.Modify();
    end;
}