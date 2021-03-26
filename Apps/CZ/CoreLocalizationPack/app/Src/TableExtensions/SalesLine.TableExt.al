tableextension 11755 "Sales Line CZL" extends "Sales Line"
{
    fields
    {
        field(11769; "Negative CZL"; Boolean)
        {
            Caption = 'Negative';
            DataClassification = CustomerContent;
        }
        field(31064; "Physical Transfer CZL"; Boolean)
        {
            Caption = 'Physical Transfer';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Physical Transfer CZL" then begin
                    TestField(Type, Type::Item);
                    if not ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]) then
                        FieldError("Document Type");
                end;
            end;
        }
        field(31065; "Tariff No. CZL"; Code[20])
        {
            Caption = 'Tariff No.';
            TableRelation = "Tariff Number";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TariffNumber: Record "Tariff Number";
            begin
                if (Type = Type::"G/L Account") and ("Tariff No. CZL" <> xRec."Tariff No. CZL") then begin
                    if not TariffNumber.Get("Tariff No. CZL") then
                        TariffNumber.Init();

                    if ("Job Contract Entry No." <> 0) and
                       (TariffNumber."VAT Stat. UoM Code CZL" <> '') and
                       (TariffNumber."VAT Stat. UoM Code CZL" <> "Unit of Measure Code")
                    then
                        TestField("Unit of Measure Code", TariffNumber."VAT Stat. UoM Code CZL");

                    if "Job Contract Entry No." = 0 then
                        Validate("Unit of Measure Code", TariffNumber."VAT Stat. UoM Code CZL");
                end;

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

    procedure CheckIntrastatMandatoryFieldsCZL(SalesHeader: Record "Sales Header")
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        if Type <> Type::Item then
            exit;
        if ("Qty. to Ship" = 0) and ("Return Qty. to Receive" = 0) then
            exit;
        if not (SalesHeader.Ship or SalesHeader.Receive) then
            exit;
        if not SalesHeader.IsIntrastatTransactionCZL() then
            exit;
        StatutoryReportingSetupCZL.Get();
        if StatutoryReportingSetupCZL."Tariff No. Mandatory" then
            TestField("Tariff No. CZL");
        if StatutoryReportingSetupCZL."Net Weight Mandatory" and IsInventoriableItem() then
            TestField("Net Weight");
    end;
}