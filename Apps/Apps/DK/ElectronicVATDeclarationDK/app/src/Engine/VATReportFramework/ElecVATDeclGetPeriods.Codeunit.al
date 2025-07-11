namespace Microsoft.Finance.VAT.Reporting;

using System.Telemetry;

codeunit 13610 "Elec. VAT Decl. Get Periods"
{
    Access = Internal;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        PeriodsInsertedLbl: Label '%1 periods were received from server. %2 new periods were inserted.', Comment = '%1, %2: number of periods.';
        FeatureNameTxt: Label 'Electronic VAT Declaration DK', Locked = true;
        VATReturnPeriodsRcvdTxt: Label 'VAT Return Periods received.', Locked = true;

    trigger OnRun()
    var
        SKATResponse: Interface "Elec. VAT Decl. Response";
        StartDate: Date;
        EndDate: Date;
    begin
        FeatureTelemetry.LogUptake('0000LR9', FeatureNameTxt, "Feature Uptake Status"::Used);
        StartDate := WorkDate() - 365;
        EndDate := WorkDate() + 365;
        SKATResponse := GetResponseFromServer(StartDate, EndDate);
        GetVATReturnPeriodsFromResponse(SKATResponse);
        FeatureTelemetry.LogUsage('0000LRA', FeatureNameTxt, VATReturnPeriodsRcvdTxt);
    end;

    local procedure GetResponseFromServer(StartDate: Date; EndDate: Date): Interface "Elec. VAT Decl. Response"
    var
        ElecVATDeclSKATAPI: Codeunit "Elec. VAT Decl. SKAT API";
    begin
        exit(ElecVATDeclSKATAPI.GetVATReturnPeriods(StartDate, EndDate));
    end;

    local procedure GetVATReturnPeriodsFromResponse(SKATResponse: Interface "Elec. VAT Decl. Response")
    var
        ElecVATDeclXml: Codeunit "Elec. VAT Decl. Xml";
        ResponseText: Text;
        DueDate: Date;
        DueDateXmlNode: XmlNode;
        DueDateXmlNodeList: XmlNodeList;
        TotalPeriodsFetched: Integer;
        PeriodsInserted: Integer;
    begin
        ResponseText := SKATResponse.GetResponseBodyAsText();
        DueDateXmlNodeList := ElecVATDeclXml.TryGetDueDateNodesFromResponseText(ResponseText);
        TotalPeriodsFetched := DueDateXmlNodeList.Count();
        foreach DueDateXmlNode in DueDateXmlNodeList do begin
            Evaluate(DueDate, DueDateXmlNode.AsXmlElement().InnerText());
            if InsertVATReturnPeriod(DueDate) then
                PeriodsInserted += 1;
        end;
        Message(PeriodsInsertedLbl, TotalPeriodsFetched, PeriodsInserted);
    end;

    local procedure InsertVATReturnPeriod(DueDate: Date) ActuallyInserted: Boolean
    var
        VATReturnPeriod: Record "VAT Return Period";
        EndDate: Date;
        StartDate: Date;
    begin
        EndDate := CalcDate('<-3M+CM>', DueDate);
        StartDate := CalcDate('<-1Q+1D>', EndDate);
        VATReturnPeriod.SetRange("End Date", EndDate);
        if not VATReturnPeriod.IsEmpty() then
            exit;

        VATReturnPeriod.Validate("End Date", EndDate);
        VATReturnPeriod.Validate("Due Date", DueDate);
        VATReturnPeriod.Validate("Start Date", StartDate);
        VATReturnPeriod.Insert(true);
        ActuallyInserted := true;
    end;
}