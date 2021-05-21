tableextension 31011 "Transfer Line CZL" extends "Transfer Line"
{
    fields
    {
        field(31065; "Tariff No. CZL"; Code[20])
        {
            Caption = 'Tariff No.';
            TableRelation = "Tariff Number";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Tariff No. CZL" <> xRec."Tariff No. CZL" then
                    "Statistic Indication CZL" := '';
            end;
        }
        field(31066; "Statistic Indication CZL"; Code[10])
        {
            Caption = 'Statistic Indication';
            TableRelation = "Statistic Indication CZL".Code where("Tariff No." = field("Tariff No. CZL"));
            DataClassification = CustomerContent;
        }
        field(31067; "Country/Reg. of Orig. Code CZL"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
    }

    procedure CheckIntrastatMandatoryFieldsCZL()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        StatutoryReportingSetupCZL.Get();
        if StatutoryReportingSetupCZL."Tariff No. Mandatory" then
            TestField("Tariff No. CZL");
        if StatutoryReportingSetupCZL."Net Weight Mandatory" and IsInventoriableItem() then
            TestField("Net Weight");
        if StatutoryReportingSetupCZL."Country/Region of Origin Mand." then
            TestField("Country/Reg. of Orig. Code CZL");
    end;

    local procedure IsInventoriableItem(): Boolean
    var
        Item: Record Item;
    begin
        if "Item No." = '' then
            exit(false);
        Item.Get("Item No.");
        exit(Item.IsInventoriableType());
    end;
}