tableextension 31010 "Transfer Header CZL" extends "Transfer Header"
{
    fields
    {
        field(31069; "Intrastat Exclude CZL"; Boolean)
        {
            Caption = 'Intrastat Exclude';
            DataClassification = CustomerContent;
        }
    }

    var
        GlobalDocumentNo: Code[20];
        GlobalIsIntrastatTransaction: Boolean;

    procedure CheckIntrastatMandatoryFieldsCZL()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        StatutoryReportingSetupCZL.Get();
        if StatutoryReportingSetupCZL."Transaction Type Mandatory" then
            TestField("Transaction Type");
        if StatutoryReportingSetupCZL."Transaction Spec. Mandatory" then
            TestField("Transaction Specification");
        if StatutoryReportingSetupCZL."Transport Method Mandatory" then
            TestField("Transport Method");
        if StatutoryReportingSetupCZL."Shipment Method Mandatory" then
            TestField("Shipment Method Code");
    end;

    procedure IsIntrastatTransactionCZL() IsIntrastat: Boolean
    begin
        if ("No." <> GlobalDocumentNo) or ("No." = '') then begin
            GlobalDocumentNo := "No.";
            GlobalIsIntrastatTransaction := UpdateGlobalIsIntrastatTransaction();
        end;
        exit(GlobalIsIntrastatTransaction);
    end;

    local procedure UpdateGlobalIsIntrastatTransaction(): Boolean
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
    begin
        if "Intrastat Exclude CZL" then
            exit(false);

        if "Trsf.-from Country/Region Code" = "Trsf.-to Country/Region Code" then
            exit(false);

        CompanyInformation.Get();
        if "Trsf.-from Country/Region Code" in ['', CompanyInformation."Country/Region Code"] then
            exit(CountryRegion.IsIntrastatCZL("Trsf.-to Country/Region Code", false));
        if "Trsf.-to Country/Region Code" in ['', CompanyInformation."Country/Region Code"] then
            exit(CountryRegion.IsIntrastatCZL("Trsf.-from Country/Region Code", false));
        exit(false);
    end;

    procedure ShipOrReceiveInventoriableTypeItemsCZL(): Boolean
    var
        TransferLine: Record "Transfer Line";
        Item: Record Item;
    begin
        TransferLine.SetRange("Document No.", "No.");
        TransferLine.SetFilter("Item No.", '<>%1', '');
        if TransferLine.FindSet() then
            repeat
                if Item.Get(TransferLine."Item No.") then
                    if ((TransferLine."Qty. to Receive" <> 0) or (TransferLine."Qty. to Ship" <> 0)) and Item.IsInventoriableType() then
                        exit(true);
            until TransferLine.Next() = 0;
    end;
}